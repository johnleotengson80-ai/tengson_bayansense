import 'constants/app_strings.dart';

/// Client-side checks. They give instant feedback only; the API re-checks everything.
/// Messages match Activity 6, Part F.
final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Same minimum the server enforces on report descriptions (after trimming).
const int minDescriptionLength = 10;

String? validateEmail(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty || !_emailPattern.hasMatch(text)) {
    return AppStrings.invalidEmail;
  }
  return null;
}

String? validateLoginPassword(String? value) {
  if ((value ?? '').isEmpty) return AppStrings.passwordRequired;
  return null;
}

String? validateDemoLoginPassword(String? value) {
  if ((value ?? '').length < 8) return AppStrings.passwordTooShort;
  return null;
}

/// The server requires 8-72 characters.
String? validateNewPassword(String? value) {
  final text = value ?? '';
  if (text.length < 8) return AppStrings.passwordTooShort;
  if (text.length > 72) return 'Use 72 characters or fewer.';
  return null;
}

String? validateFullName(String? value) {
  if ((value ?? '').trim().isEmpty) return AppStrings.nameRequired;
  return null;
}

String? validateDescription(String? value) {
  // runes.length counts characters the way the server does (an emoji is 1, not 2).
  if ((value ?? '').trim().runes.length < minDescriptionLength) {
    return AppStrings.reportDescriptionRequired;
  }
  return null;
}

String? validateReportLocation(String? value) {
  if ((value ?? '').trim().isEmpty) return AppStrings.reportLocationRequired;
  return null;
}

String? validateLatitude(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  final coordinate = double.tryParse(text);
  if (coordinate == null ||
      !coordinate.isFinite ||
      coordinate < -90 ||
      coordinate > 90) {
    return AppStrings.latitudeInvalid;
  }
  return null;
}

String? validateLongitude(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  final coordinate = double.tryParse(text);
  if (coordinate == null ||
      !coordinate.isFinite ||
      coordinate < -180 ||
      coordinate > 180) {
    return AppStrings.longitudeInvalid;
  }
  return null;
}
