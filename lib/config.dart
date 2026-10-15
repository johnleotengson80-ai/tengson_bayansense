/// Base URL of the BayanSense API. Override when running or building:
///
///   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
///
/// The Android emulator reaches the computer running the backend at http://10.0.2.2:8000
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
