import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/report.dart';
import '../models/session.dart';
import '../models/submission_result.dart';
import 'api_exception.dart';
import 'bayan_sense_service.dart';

/// All communication with the BayanSense REST API (Activity 7). Screens never build requests themselves.
class ApiClient implements BayanSenseService {
  ApiClient({
    required String baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 15),
  })  : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _http = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _http;
  final Duration timeout;

  /// Sent as "Authorization: Bearer ..." on every request except login and register.
  @override
  String? token;

  /// Called when the server rejects our token (HTTP 401) on an authenticated request.
  @override
  void Function()? onUnauthorized;

  // ---------------- endpoints ----------------

  /// EP-02. Returns the new resident's id. Residents only: there is no role field to send.
  @override
  Future<int> register({
    required String fullName,
    required String email,
    required String password,
    String? contactNumber,
    String? barangayZone,
  }) async {
    final body = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'password': password,
    };
    if (contactNumber != null) body['contact_number'] = contactNumber;
    if (barangayZone != null) body['barangay_zone'] = barangayZone;
    final json = _asMap(await _request(
      'POST',
      '/auth/register',
      body: body,
      authenticated: false,
    ));
    return _parse(() => json['resident_id'] as int);
  }

  /// EP-01 / CON-03.
  @override
  Future<Session> login(
      {required String email, required String password}) async {
    final json = _asMap(await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    ));
    return _parse(() => Session.fromJson(json));
  }

  /// EP-03 / CON-01. The server classifies and routes the report in this same request.
  @override
  Future<SubmissionResult> createReport({
    required String description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{'description': description};
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    final json = _asMap(await _request(
      'POST',
      '/reports',
      body: body,
    ));
    return _parse(() => SubmissionResult.fromJson(json));
  }

  /// EP-04: the signed-in resident's own reports, newest first.
  @override
  Future<List<Report>> listReports({int? departmentId, String? status}) async {
    final query = <String, String>{};
    if (departmentId != null) query['department_id'] = '$departmentId';
    if (status != null) query['status'] = status;
    final uri =
        Uri(path: '/reports', queryParameters: query.isEmpty ? null : query);
    final list = _asList(await _request('GET', uri.toString()));
    return _parse(() =>
        list.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<List<Report>> listMyReports() => listReports();

  /// EP-05 / CON-04.
  @override
  Future<Report> getReport(int reportId) async {
    final json = _asMap(await _request('GET', '/reports/$reportId'));
    return _parse(() => Report.fromJson(json));
  }

  @override
  Future<Report> updateStatus({
    required int reportId,
    required String status,
    String? resolutionNote,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (resolutionNote != null) body['resolution_note'] = resolutionNote;
    await _request('PATCH', '/reports/$reportId/status', body: body);
    return getReport(reportId);
  }

  @override
  Future<int> createPersonnel({
    required String fullName,
    required String email,
    required String password,
    required int departmentId,
  }) async {
    final json = _asMap(await _request(
      'POST',
      '/admin/personnel',
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'department_id': departmentId,
      },
    ));
    return _parse(() => json['personnel_id'] as int);
  }

  void close() => _http.close();

  // ---------------- plumbing ----------------

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (authenticated && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final http.Response response;
    try {
      if (method == 'GET') {
        response = await _http.get(uri, headers: headers).timeout(timeout);
      } else if (method == 'POST') {
        headers['Content-Type'] = 'application/json; charset=utf-8';
        response = await _http
            .post(uri,
                headers: headers,
                body: utf8.encode(jsonEncode(body ?? <String, dynamic>{})))
            .timeout(timeout);
      } else if (method == 'PATCH') {
        headers['Content-Type'] = 'application/json; charset=utf-8';
        response = await _http
            .patch(uri,
                headers: headers,
                body: utf8.encode(jsonEncode(body ?? <String, dynamic>{})))
            .timeout(timeout);
      } else {
        throw ArgumentError('Unsupported HTTP method: $method');
      }
    } on Exception {
      // Offline, DNS failure, timeout, TLS problem, or (on web) a CORS block.
      throw ApiException.network();
    }

    // Decode the raw bytes as UTF-8 ourselves. The server sends "application/json" with no charset,
    // and reports contain characters like n-tilde and curly quotes, so we do not rely on the http
    // package's default guess for the encoding.
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    dynamic decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } on FormatException {
        decoded = null;
      }
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      if (decoded == null) throw ApiException.invalidResponse(status);
      return decoded;
    }

    if (status == 401 && authenticated) onUnauthorized?.call();
    throw _errorFrom(status, decoded);
  }

  ApiException _errorFrom(int status, dynamic decoded) {
    if (decoded is Map<String, dynamic> &&
        decoded['error'] is Map<String, dynamic>) {
      final err = decoded['error'] as Map<String, dynamic>;
      return ApiException(
        code: (err['code'] as String?) ?? 'HTTP_ERROR',
        message: (err['message'] as String?) ?? 'Request failed.',
        statusCode: status,
        details: err['details'] as Map<String, dynamic>?,
      );
    }
    return ApiException(
      code: status >= 500 ? 'INTERNAL_ERROR' : 'HTTP_ERROR',
      message: 'Request failed ($status).',
      statusCode: status,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw ApiException.invalidResponse();
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    throw ApiException.invalidResponse();
  }

  /// Any surprise in the shape of server data becomes a clean "unexpected response" error.
  T _parse<T>(T Function() build) {
    try {
      return build();
    } catch (_) {
      throw ApiException.invalidResponse();
    }
  }
}
