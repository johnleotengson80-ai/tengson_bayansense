// Unit tests for the BayanSense app's logic (no screens are pumped here).
//
// The *Json constants below are REAL responses captured from the running BayanSense backend,
// so these tests check the app against what the server actually sends, not against assumptions.
// If the backend's responses change, recapture them (see frontend/README.md).
//
// This file is named widget_test.dart on purpose: `flutter create .` would otherwise add its own
// widget_test.dart (a counter-app test) that fails against this project.
import 'dart:convert';

import 'package:bayansense_app/error_messages.dart';
import 'package:bayansense_app/format.dart';
import 'package:bayansense_app/models/report.dart';
import 'package:bayansense_app/models/session.dart';
import 'package:bayansense_app/models/submission_result.dart';
import 'package:bayansense_app/routing/routes.dart';
import 'package:bayansense_app/services/api_client.dart';
import 'package:bayansense_app/services/api_exception.dart';
import 'package:bayansense_app/services/token_store.dart';
import 'package:bayansense_app/state/auth_state.dart';
import 'package:bayansense_app/state/reports_state.dart';
import 'package:bayansense_app/validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String getReportJson = r'''{"report_id":1,"resident_id":1,"description":"Baha sa kalsada, binaha ang buong purok kagabi. Wala nang daan sa Niño — ’di na makalusot ang mga bata.","image_url":null,"latitude":null,"longitude":null,"predicted_category":"Flooding","confidence_score":0.75,"assigned_department":"Barangay Disaster Risk Reduction and Management (BDRRM)","needs_manual_review":false,"status":"Received","created_at":"2026-10-10T14:26:39.331755","updated_at":"2026-10-10T14:26:39.331755"}''';
const String listReportsJson = r'''[{"report_id":3,"resident_id":1,"description":"Napakaingay ng kapitbahay namin tuwing gabi","image_url":null,"latitude":null,"longitude":null,"predicted_category":null,"confidence_score":null,"assigned_department":"Barangay Council","needs_manual_review":true,"status":"Received","created_at":"2026-10-10T14:26:39.370718","updated_at":"2026-10-10T14:26:39.370718"},{"report_id":2,"resident_id":1,"description":"Kailangan ng doktor ang anak ko, may sakit siya","image_url":null,"latitude":null,"longitude":null,"predicted_category":"Out of Scope","confidence_score":0.9,"assigned_department":null,"needs_manual_review":false,"status":"Received","created_at":"2026-10-10T14:26:39.356862","updated_at":"2026-10-10T14:26:39.356862"},{"report_id":1,"resident_id":1,"description":"Baha sa kalsada, binaha ang buong purok kagabi. Wala nang daan sa Niño — ’di na makalusot ang mga bata.","image_url":null,"latitude":null,"longitude":null,"predicted_category":"Flooding","confidence_score":0.75,"assigned_department":"Barangay Disaster Risk Reduction and Management (BDRRM)","needs_manual_review":false,"status":"Received","created_at":"2026-10-10T14:26:39.331755","updated_at":"2026-10-10T14:26:39.331755"}]''';
const String createReportJson = r'''{"report_id":1,"predicted_category":"Flooding","assigned_department":"Barangay Disaster Risk Reduction and Management (BDRRM)","confidence_score":0.75,"needs_manual_review":false,"status":"Received"}''';
const String createOutOfScopeJson = r'''{"report_id":2,"predicted_category":"Out of Scope","assigned_department":null,"confidence_score":0.9,"needs_manual_review":false,"status":"Received"}''';
const String createUnclassifiedJson = r'''{"report_id":3,"predicted_category":null,"assigned_department":"Barangay Council","confidence_score":null,"needs_manual_review":true,"status":"Received"}''';
const String loginJson = r'''{"id":1,"role":"resident","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6InJlc2lkZW50IiwiZXhwIjoxNzkxNjg1NTk5fQ.kpXnQJ6ur8ZXjyxi4YAnDYy2fyh7F_I2Vuk7Xx9yQhw"}''';
const String registerJson = r'''{"resident_id":1}''';
const String invalidCredentialsJson = r'''{"error":{"code":"INVALID_CREDENTIALS","message":"Incorrect email or password","details":null}}''';
const String descriptionTooShortJson = r'''{"error":{"code":"DESCRIPTION_TOO_SHORT","message":"Some fields are invalid","details":{"description":"String should have at least 10 characters"}}}''';
const String unauthenticatedJson = r'''{"error":{"code":"AUTHENTICATION_REQUIRED","message":"A valid authentication token is required","details":null}}''';
const String duplicateEmailJson = r'''{"error":{"code":"EMAIL_ALREADY_REGISTERED","message":"An account with this email already exists","details":null}}''';

class InMemoryTokenStore implements TokenStore {
  Session? saved;

  @override
  Future<Session?> read() async => saved;

  @override
  Future<void> save(Session session) async {
    saved = session;
  }

  @override
  Future<void> clear() async {
    saved = null;
  }
}

/// A response whose body is UTF-8 bytes with NO charset in the content type, like the real server sends.
http.Response respond(String body, [int status = 200]) => http.Response.bytes(
      utf8.encode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

ApiClient clientWith(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(baseUrl: 'http://api.test/', httpClient: MockClient(handler));

Matcher apiError(String code) =>
    isA<ApiException>().having((e) => e.code, 'code', code);

void main() {
  group('models parse the real server responses', () {
    test('a full report', () {
      final report = Report.fromJson(jsonDecode(getReportJson) as Map<String, dynamic>);
      expect(report.reportId, 1);
      expect(report.predictedCategory, 'Flooding');
      expect(report.confidenceScore, 0.75);
      expect(report.assignedDepartment, startsWith('Barangay Disaster Risk Reduction'));
      expect(report.needsManualReview, isFalse);
      expect(report.status, 'Received');
      expect(report.imageUrl, isNull);
      expect(report.latitude, isNull);
      expect(report.createdAt.year, greaterThanOrEqualTo(2026));
      expect(report.referenceNumber, 'BS-0001');
      expect(report.isOutOfScope, isFalse);
      // non-ASCII characters survive: n-tilde, em dash, curly apostrophe
      expect(report.description, contains('Niño'));
      expect(report.description, contains('—'));
      expect(report.description, contains('’di'));
    });

    test('the list of reports', () {
      final list = (jsonDecode(listReportsJson) as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(list.map((r) => r.reportId).toSet(), {1, 2, 3});
      final unclassified = list.firstWhere((r) => r.reportId == 3);
      expect(unclassified.predictedCategory, isNull);
      expect(unclassified.confidenceScore, isNull);
      expect(unclassified.needsManualReview, isTrue);
      expect(unclassified.assignedDepartment, 'Barangay Council');
    });

    test('numbers that arrive as whole numbers still become doubles', () {
      final json = jsonDecode(getReportJson) as Map<String, dynamic>;
      json['latitude'] = 8;
      json['longitude'] = 125.5;
      final report = Report.fromJson(json);
      expect(report.latitude, 8.0);
      expect(report.longitude, 125.5);
    });

    test('submission results: confident, out of scope, unclassified', () {
      final ok = SubmissionResult.fromJson(jsonDecode(createReportJson) as Map<String, dynamic>);
      expect(ok.predictedCategory, 'Flooding');
      expect(ok.needsManualReview, isFalse);
      expect(ok.isOutOfScope, isFalse);

      final out = SubmissionResult.fromJson(jsonDecode(createOutOfScopeJson) as Map<String, dynamic>);
      expect(out.isOutOfScope, isTrue);
      expect(out.assignedDepartment, isNull);

      final unclassified =
          SubmissionResult.fromJson(jsonDecode(createUnclassifiedJson) as Map<String, dynamic>);
      expect(unclassified.predictedCategory, isNull);
      expect(unclassified.confidenceScore, isNull);
      expect(unclassified.needsManualReview, isTrue);
      expect(unclassified.referenceNumber, 'BS-0003');
    });

    test('a login session', () {
      final session = Session.fromJson(jsonDecode(loginJson) as Map<String, dynamic>);
      expect(session.role, 'resident');
      expect(session.token, isNotEmpty);
    });
  });

  group('ApiClient requests', () {
    test('login: right URL, JSON body, no Authorization header, trailing slash handled', () async {
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(loginJson);
      });
      api.token = 'old-token'; // must NOT be sent to the login endpoint
      final session = await api.login(email: 'maria@bayansense.ph', password: 'Resident-pass-1');

      expect(session.role, 'resident');
      expect(seen!.method, 'POST');
      expect(seen!.url.toString(), 'http://api.test/auth/login');
      expect(seen!.headers.containsKey('Authorization'), isFalse);
      expect(seen!.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(seen!.body), {'email': 'maria@bayansense.ph', 'password': 'Resident-pass-1'});
    });

    test('register sends only name, email and password (never a role) and returns the id', () async {
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(registerJson, 201);
      });
      final id = await api.register(fullName: 'Maria Santos', email: 'maria@bayansense.ph', password: 'Resident-pass-1');

      expect(id, 1);
      expect(seen!.url.path, '/auth/register');
      expect(jsonDecode(seen!.body), {
        'full_name': 'Maria Santos',
        'email': 'maria@bayansense.ph',
        'password': 'Resident-pass-1',
      });
    });

    test('authenticated calls send the Bearer token', () async {
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(listReportsJson);
      });
      api.token = 'abc123';
      final reports = await api.listMyReports();

      expect(reports, hasLength(3));
      expect(seen!.method, 'GET');
      expect(seen!.url.path, '/reports');
      expect(seen!.headers['Authorization'], 'Bearer abc123');
    });

    test('createReport posts the description and parses the result', () async {
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(createReportJson, 201);
      });
      api.token = 't';
      final result = await api.createReport(description: 'Baha sa kalsada, binaha ang buong purok kagabi');

      expect(result.predictedCategory, 'Flooding');
      expect(seen!.url.path, '/reports');
      expect(jsonDecode(seen!.body), {'description': 'Baha sa kalsada, binaha ang buong purok kagabi'});
    });

    test('getReport requests /reports/{id}', () async {
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(getReportJson);
      });
      api.token = 't';
      final report = await api.getReport(1);

      expect(seen!.url.path, '/reports/1');
      expect(report.reportId, 1);
    });

    test('non-ASCII text is read correctly even though the response has no charset', () async {
      final api = clientWith((request) async => respond(getReportJson));
      api.token = 't';
      final report = await api.getReport(1);
      expect(report.description, contains('Niño'));
    });

    test('non-ASCII text is sent as UTF-8', () async {
      List<int>? bodyBytes;
      final api = clientWith((request) async {
        bodyBytes = request.bodyBytes;
        return respond(createReportJson, 201);
      });
      api.token = 't';
      await api.createReport(description: 'Baha sa Niño ’di na makalusot');
      expect(utf8.decode(bodyBytes!), contains('Niño ’di'));
    });
  });

  group('ApiClient errors', () {
    test('wrong password: INVALID_CREDENTIALS, and it does NOT count as an expired session', () async {
      var expired = 0;
      final api = clientWith((request) async => respond(invalidCredentialsJson, 401));
      api.onUnauthorized = () => expired++;

      await expectLater(api.login(email: 'a@b.ph', password: 'wrongwrong'), throwsA(apiError('INVALID_CREDENTIALS')));
      expect(expired, 0);
    });

    test('401 on an authenticated call fires onUnauthorized once', () async {
      var expired = 0;
      final api = clientWith((request) async => respond(unauthenticatedJson, 401));
      api.token = 'stale';
      api.onUnauthorized = () => expired++;

      await expectLater(api.listMyReports(), throwsA(apiError('AUTHENTICATION_REQUIRED')));
      expect(expired, 1);
    });

    test('validation error keeps its code, status and details', () async {
      final api = clientWith((request) async => respond(descriptionTooShortJson, 422));
      api.token = 't';
      await expectLater(
        api.createReport(description: 'too short'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'DESCRIPTION_TOO_SHORT')
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.details!['description'], 'details', isNotNull)),
      );
    });

    test('duplicate email on register', () async {
      final api = clientWith((request) async => respond(duplicateEmailJson, 409));
      await expectLater(
        api.register(fullName: 'M', email: 'maria@bayansense.ph', password: 'Resident-pass-1'),
        throwsA(apiError('EMAIL_ALREADY_REGISTERED')),
      );
    });

    test('no connection becomes a network error', () async {
      final api = clientWith((request) async => throw http.ClientException('connection refused'));
      api.token = 't';
      await expectLater(
        api.listMyReports(),
        throwsA(isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue)),
      );
    });

    test('a successful reply that is not JSON is reported as an unexpected response', () async {
      final api = clientWith((request) async => respond('<html>proxy error</html>'));
      api.token = 't';
      await expectLater(api.getReport(1), throwsA(apiError(ApiException.invalidResponseCode)));
    });

    test('JSON of the wrong shape is reported as an unexpected response', () async {
      final api = clientWith((request) async => respond('[1, 2, 3]'));
      api.token = 't';
      await expectLater(api.getReport(1), throwsA(apiError(ApiException.invalidResponseCode)));
    });

    test('a report with a missing field is reported as an unexpected response', () async {
      final api = clientWith((request) async => respond('{"report_id": 1}'));
      api.token = 't';
      await expectLater(api.getReport(1), throwsA(apiError(ApiException.invalidResponseCode)));
    });

    test('a server error without our error format still gives a clean exception', () async {
      final api = clientWith((request) async => respond('Bad gateway', 502));
      api.token = 't';
      await expectLater(
        api.listMyReports(),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'INTERNAL_ERROR')
            .having((e) => e.statusCode, 'statusCode', 502)),
      );
    });
  });

  group('AuthState', () {
    AuthState authWith(Future<http.Response> Function(http.Request) handler, InMemoryTokenStore store) =>
        AuthState(api: clientWith(handler), store: store);

    test('starts in "restoring" and finishes signed out when nothing is saved', () async {
      final auth = authWith((r) async => respond('{}'), InMemoryTokenStore());
      expect(auth.restoring, isTrue);
      await auth.restore();
      expect(auth.restoring, isFalse);
      expect(auth.isAuthenticated, isFalse);
    });

    test('restores a saved session and gives the token to the API client', () async {
      final store = InMemoryTokenStore()..saved = const Session(id: 7, role: 'resident', token: 'saved-token');
      http.Request? seen;
      final api = clientWith((request) async {
        seen = request;
        return respond(listReportsJson);
      });
      final auth = AuthState(api: api, store: store);
      await auth.restore();

      expect(auth.isAuthenticated, isTrue);
      expect(auth.role, 'resident');
      await api.listMyReports();
      expect(seen!.headers['Authorization'], 'Bearer saved-token');
    });

    test('login success: signs in, remembers the session, notifies listeners', () async {
      final store = InMemoryTokenStore();
      final auth = authWith((r) async => respond(loginJson), store);
      var notifications = 0;
      auth.addListener(() => notifications++);

      final ok = await auth.login('  maria@bayansense.ph ', 'Resident-pass-1');

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.role, 'resident');
      expect(auth.busy, isFalse);
      expect(auth.errorMessage, isNull);
      expect(store.saved!.role, 'resident');
      expect(notifications, greaterThan(0));
    });

    test('login failure shows the Activity 6 message and stays signed out', () async {
      final store = InMemoryTokenStore();
      final auth = authWith((r) async => respond(invalidCredentialsJson, 401), store);

      final ok = await auth.login('maria@bayansense.ph', 'wrong-password');

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, 'Login failed. Please check your credentials and try again.');
      expect(store.saved, isNull);
    });

    test('register signs the new resident in', () async {
      final auth = authWith((r) async {
        if (r.url.path == '/auth/register') return respond(registerJson, 201);
        return respond(loginJson);
      }, InMemoryTokenStore());

      final ok = await auth.register(fullName: 'Maria Santos', email: 'maria@bayansense.ph', password: 'Resident-pass-1');

      expect(ok, isTrue);
      expect(auth.role, 'resident');
    });

    test('register with a taken email explains it', () async {
      final auth = authWith((r) async => respond(duplicateEmailJson, 409), InMemoryTokenStore());
      final ok = await auth.register(fullName: 'M', email: 'maria@bayansense.ph', password: 'Resident-pass-1');
      expect(ok, isFalse);
      expect(auth.errorMessage, contains('already exists'));
    });

    test('if the account is created but the follow-up login fails, the user is told to log in', () async {
      final auth = authWith((r) async {
        if (r.url.path == '/auth/register') return respond(registerJson, 201);
        throw http.ClientException('offline');
      }, InMemoryTokenStore());

      final ok = await auth.register(fullName: 'M', email: 'maria@bayansense.ph', password: 'Resident-pass-1');

      expect(ok, isFalse);
      expect(auth.errorMessage, 'Your account was created. Please log in.');
    });

    test('logout clears the session and the saved copy', () async {
      final store = InMemoryTokenStore();
      final auth = authWith((r) async => respond(loginJson), store);
      await auth.login('maria@bayansense.ph', 'Resident-pass-1');
      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(store.saved, isNull);
    });

    test('a 401 on a later request signs the user out and flags the expired session', () async {
      final store = InMemoryTokenStore();
      final api = clientWith((r) async {
        if (r.url.path == '/auth/login') return respond(loginJson);
        return respond(unauthenticatedJson, 401);
      });
      final auth = AuthState(api: api, store: store);
      await auth.login('maria@bayansense.ph', 'Resident-pass-1');
      expect(auth.isAuthenticated, isTrue);

      await expectLater(api.listMyReports(), throwsA(isA<ApiException>()));

      expect(auth.isAuthenticated, isFalse);
      expect(auth.sessionExpired, isTrue);
      expect(store.saved, isNull);

      auth.clearMessages();
      expect(auth.sessionExpired, isFalse);
    });
  });

  group('ReportsState', () {
    ReportsState stateWith(Future<http.Response> Function(http.Request) handler) {
      final api = clientWith(handler);
      api.token = 't';
      return ReportsState(api);
    }

    test('load fills the list', () async {
      final state = stateWith((r) async => respond(listReportsJson));
      expect(state.loadedOnce, isFalse);
      await state.load();

      expect(state.items, hasLength(3));
      expect(state.loadedOnce, isTrue);
      expect(state.loading, isFalse);
      expect(state.error, isNull);
    });

    test('load failure keeps a readable message and does not claim the list loaded', () async {
      final state = stateWith((r) async => throw http.ClientException('offline'));
      await state.load();

      expect(state.error, contains("Can't reach the server"));
      expect(state.loadedOnce, isFalse);
      expect(state.items, isEmpty);
    });

    test('submit returns the result and marks the list stale', () async {
      final state = stateWith((r) async {
        if (r.method == 'POST') return respond(createReportJson, 201);
        return respond(listReportsJson);
      });
      await state.load();
      expect(state.loadedOnce, isTrue);

      final result = await state.submit('  Baha sa kalsada, binaha ang buong purok kagabi  ');

      expect(result.predictedCategory, 'Flooding');
      expect(state.loadedOnce, isFalse);
    });

    test('submit passes server errors to the caller', () async {
      final state = stateWith((r) async => respond(descriptionTooShortJson, 422));
      await expectLater(state.submit('too short'), throwsA(apiError('DESCRIPTION_TOO_SHORT')));
    });

    test('reset forgets everything', () async {
      final state = stateWith((r) async => respond(listReportsJson));
      await state.load();
      state.reset();

      expect(state.items, isEmpty);
      expect(state.loadedOnce, isFalse);
      expect(state.error, isNull);
    });

    test('fetchReport returns one report', () async {
      final state = stateWith((r) async => respond(getReportJson));
      final report = await state.fetchReport(1);
      expect(report.reportId, 1);
    });
  });

  group('error messages', () {
    test('network problems are explained the same way everywhere', () {
      final e = ApiException.network();
      expect(messageForLogin(e), contains("Can't reach the server"));
      expect(messageForRegister(e), contains("Can't reach the server"));
      expect(messageForSubmit(e), contains("Can't reach the server"));
      expect(messageForLoadList(e), contains("Can't reach the server"));
      expect(messageForLoadReport(e), contains("Can't reach the server"));
    });

    test('submit and load messages match Activity 6', () {
      const tooShort = ApiException(code: 'DESCRIPTION_TOO_SHORT', message: 'x', statusCode: 422);
      const other = ApiException(code: 'INTERNAL_ERROR', message: 'x', statusCode: 500);
      expect(messageForSubmit(tooShort), 'Please describe the concern in more detail.');
      expect(messageForSubmit(other), 'Report could not be submitted. Please try again.');
      expect(messageForLoadList(other), 'Unable to load your reports. Try again.');
    });

    test('someone else\'s report looks the same as a missing one', () {
      const forbidden = ApiException(code: 'ACCESS_NOT_ALLOWED', message: 'x', statusCode: 403);
      const missing = ApiException(code: 'NOT_FOUND', message: 'x', statusCode: 404);
      expect(messageForLoadReport(forbidden), 'This report could not be found.');
      expect(messageForLoadReport(missing), 'This report could not be found.');
    });
  });

  group('validators', () {
    test('email', () {
      expect(validateEmail('maria@bayansense.ph'), isNull);
      expect(validateEmail('  maria@bayansense.ph  '), isNull);
      expect(validateEmail(''), 'Please enter a valid email address.');
      expect(validateEmail(null), 'Please enter a valid email address.');
      expect(validateEmail('maria@'), isNotNull);
      expect(validateEmail('maria@bayansense'), isNotNull);
      expect(validateEmail('ma ria@bayansense.ph'), isNotNull);
    });

    test('passwords', () {
      expect(validateLoginPassword(''), 'Please enter your password.');
      expect(validateLoginPassword('x'), isNull);
      expect(validateNewPassword('1234567'), isNotNull);
      expect(validateNewPassword('12345678'), isNull);
      expect(validateNewPassword('a' * 72), isNull);
      expect(validateNewPassword('a' * 73), isNotNull);
    });

    test('full name', () {
      expect(validateFullName('  '), isNotNull);
      expect(validateFullName('Maria'), isNull);
    });

    test('description needs 10 characters after trimming, counted like the server does', () {
      expect(validateDescription('123456789'), 'Please describe the concern in more detail.');
      expect(validateDescription('1234567890'), isNull);
      expect(validateDescription('   short   '), isNotNull);
      expect(validateDescription(null), isNotNull);
      // an emoji is ONE character for the server, so five of them are too few
      expect(validateDescription('😀😀😀😀😀'), isNotNull);
      expect(validateDescription('😀😀😀😀😀😀😀😀😀😀'), isNull);
    });
  });

  group('routes', () {
    test('each role lands on its own home', () {
      expect(Routes.homeFor('resident'), '/resident/home');
      expect(Routes.homeFor('personnel'), '/personnel/dashboard');
      expect(Routes.homeFor('admin'), '/admin/personnel');
      expect(Routes.homeFor('something-else'), '/resident/home');
    });

    test('browser addresses are cleaned up', () {
      expect(normalizeRoute(null), '/');
      expect(normalizeRoute(''), '/');
      expect(normalizeRoute('/login/'), '/login');
      expect(normalizeRoute('/resident/reports/12?ref=x'), '/resident/reports/12');
      expect(normalizeRoute('/resident/reports/12#top'), '/resident/reports/12');
    });

    test('report detail addresses', () {
      expect(parseReportId('/resident/reports/12'), 12);
      expect(parseReportId(Routes.reportDetail(5)), 5);
      expect(parseReportId('/resident/reports/abc'), isNull);
      expect(parseReportId('/resident/reports'), isNull);
      expect(parseReportId('/resident/reports/12/extra'), isNull);
      expect(parseReportId('/personnel/reports/12'), isNull);
    });
  });

  group('formatting', () {
    test('dates', () {
      expect(formatDate(DateTime(2026, 10, 8)), 'Oct 8, 2026');
      expect(formatDate(DateTime(2027, 1, 1)), 'Jan 1, 2027');
      expect(formatDate(DateTime(2026, 12, 31)), 'Dec 31, 2026');
    });

    test('reference numbers', () {
      expect(referenceFor(7), 'BS-0007');
      expect(referenceFor(101), 'BS-0101');
      expect(referenceFor(12345), 'BS-12345');
    });
  });
}
