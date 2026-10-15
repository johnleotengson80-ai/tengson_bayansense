import 'services/api_exception.dart';

/// Resident-facing wording. Where Activity 6 (Part H) defines the text, it is used verbatim.

String messageForLogin(ApiException e) {
  if (e.isNetwork) return e.message;
  if (e.code == 'INVALID_CREDENTIALS') {
    return 'Login failed. Please check your credentials and try again.';
  }
  if (e.statusCode == 422) return 'Please enter a valid email address and password.';
  return 'Login failed. Please try again.';
}

String messageForRegister(ApiException e) {
  if (e.isNetwork) return e.message;
  if (e.code == 'EMAIL_ALREADY_REGISTERED') {
    return 'An account with this email already exists. Try logging in instead.';
  }
  if (e.statusCode == 422) return 'Please check your details and try again.';
  return 'Could not create your account. Please try again.';
}

String messageForSubmit(ApiException e) {
  if (e.isNetwork) return e.message;
  if (e.code == 'DESCRIPTION_TOO_SHORT' || e.code == 'INVALID_DESCRIPTION') {
    return 'Please describe the concern in more detail.';
  }
  if (e.statusCode == 401) return 'Your session has expired. Please log in again.';
  return 'Report could not be submitted. Please try again.';
}

String messageForLoadList(ApiException e) {
  if (e.isNetwork) return e.message;
  return 'Unable to load your reports. Try again.';
}

String messageForLoadReport(ApiException e) {
  if (e.isNetwork) return e.message;
  if (e.statusCode == 403 || e.statusCode == 404) return 'This report could not be found.';
  return 'Unable to load this report. Try again.';
}
