import 'package:flutter/foundation.dart';

import '../error_messages.dart';
import '../constants/app_strings.dart';
import '../models/session.dart';
import '../models/user_account.dart';
import '../services/bayan_sense_service.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/mock_bayan_sense_service.dart';
import '../services/token_store.dart';

class AuthState extends ChangeNotifier {
  AuthState({
    BayanSenseService? service,
    ApiClient? api,
    TokenStore? store,
  })  : _service = service ?? api,
        _store = store {
    _service?.onUnauthorized = handleUnauthorized;
  }

  final BayanSenseService? _service;
  final TokenStore? _store;
  Session? _session;
  UserAccount? _account;
  bool _restoring = true;
  bool _busy = false;
  String? _error;
  Map<String, dynamic>? _errorDetails;
  bool _sessionExpired = false;

  Session? get session => _session;
  UserAccount? get account => _account;
  bool get isAuthenticated => _session != null;

  /// 'resident' | 'staff' | 'admin', or null when signed out.
  String? get role {
    final value = _session?.role;
    return value == 'personnel' ? 'staff' : value;
  }

  bool get restoring => _restoring;
  bool get busy => _busy;
  String? get errorMessage => _error;
  Map<String, dynamic>? get errorDetails => _errorDetails;
  bool get sessionExpired => _sessionExpired;

  Future<void> restore() async {
    try {
      final saved = await _store?.read();
      if (saved != null) {
        _session = saved;
        _service?.token = saved.token;
        _account = _accountFor(saved);
      }
    } on Exception {
      // A failed saved-session read leaves the user signed out.
    }
    _restoring = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _begin();
    try {
      await _setSession(
        await _service!.login(email: email.trim(), password: password),
        email: email.trim(),
      );
      return true;
    } on ApiException catch (e) {
      _error = messageForLogin(e);
      _errorDetails = e.details;
      return false;
    } on MockServiceException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Creates a resident account, then signs in with it.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _begin();
    try {
      try {
        await _service!.register(
          fullName: fullName.trim(),
          email: email.trim(),
          password: password,
        );
      } on ApiException catch (e) {
        _error = messageForRegister(e);
        _errorDetails = e.details;
        return false;
      } on MockServiceException catch (e) {
        _error = e.message;
        return false;
      }
      try {
        await _setSession(
          await _service.login(email: email.trim(), password: password),
          email: email.trim(),
          fullName: fullName.trim(),
        );
      } on ApiException catch (e) {
        _error = AppStrings.accountCreatedLogin;
        _errorDetails = e.details;
        return false;
      } on MockServiceException {
        _error = AppStrings.accountCreatedLogin;
        return false;
      }
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _session = null;
    _account = null;
    _service?.token = null;
    _sessionExpired = false;
    if (_store != null) {
      try {
        await _store.clear();
      } on Exception {
        _error = AppStrings.sessionClearFailure;
      }
    }
    notifyListeners();
  }

  void handleUnauthorized() {
    if (_session == null) return;
    _session = null;
    _account = null;
    _service?.token = null;
    _error = AppStrings.sessionExpired;
    _sessionExpired = true;
    _store?.clear().catchError((Object _) {});
    notifyListeners();
  }

  void clearMessages() {
    if (_error == null && !_sessionExpired) return;
    _error = null;
    _errorDetails = null;
    _sessionExpired = false;
    notifyListeners();
  }

  void _begin() {
    _busy = true;
    _error = null;
    _errorDetails = null;
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> _setSession(
    Session session, {
    String? email,
    String? fullName,
  }) async {
    _session = session;
    _service!.token = session.token;
    _account = _accountFor(
      Session(
        id: session.id,
        role: session.role,
        token: session.token,
        fullName: session.fullName ?? fullName,
        email: session.email ?? email,
        department: session.department,
      ),
    );
    try {
      await _store?.save(session);
    } on Exception {
      // The user remains signed in for this run if session persistence fails.
    }
  }

  UserAccount _accountFor(Session session) {
    final role = switch (session.role) {
      'admin' => UserRole.admin,
      'staff' || 'personnel' => UserRole.staff,
      _ => UserRole.resident,
    };
    final name = session.fullName ??
        (role == UserRole.resident
            ? AppStrings.residentRole
            : role == UserRole.staff
                ? AppStrings.staffRole
                : AppStrings.adminRole);
    return UserAccount(
      id: session.id,
      fullName: name,
      email: session.email ?? '',
      role: role,
      department: session.department,
    );
  }
}
