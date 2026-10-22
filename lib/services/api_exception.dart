/// Any failure talking to the API. `code` is the server's error code (Activity 7), or one of the
/// two codes below when the problem happened on this side of the connection.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  static const String networkCode = 'NETWORK_ERROR';
  static const String invalidResponseCode = 'INVALID_RESPONSE';

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  /// The server could not be reached (offline, DNS, timeout, blocked by CORS, ...).
  factory ApiException.network() => const ApiException(
        code: networkCode,
        message: 'Cannot reach the server. Check that the backend is running.',
      );

  factory ApiException.invalidResponse([int? statusCode]) => ApiException(
        code: invalidResponseCode,
        message: 'The server sent an unexpected response. Please try again.',
        statusCode: statusCode,
      );

  bool get isNetwork => code == networkCode;

  @override
  String toString() => 'ApiException($code, status: $statusCode): $message';
}
