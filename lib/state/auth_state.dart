import 'package:flutter/foundation.dart';

import '../error_messages.dart';
import '../constants/app_strings.dart';
import '../models/session.dart';
import '../models/user_account.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/token_store.dart';

class AuthState extends ChangeNotifier {
  AuthState({
    ApiClient? api,
    TokenStore? store,
  })  : _api = api,
        _store = store {
    _api?.onUnauthorized = handleUnauthorized;
  }

  final ApiClient? _api;
  final TokenStore? _store;
  Session? _session;
  UserAccount? _account;
  bool _restoring = true;
  bool _busy = false;
  String? _error;
  bool _sessionExpired = false;

  Session? get session => _session;
  UserAccount? get account => _account;
  bool get isAuthenticated => _session != null;

  /// 'resident' | 'staff' | 'admin', or null when signed out.
  String? get role => _session?.role;
  bool get restoring => _restoring;
  bool get busy => _busy;
  String? get errorMessage => _error;
  bool get sessionExpired => _sessionExpired;

  Future<void> restore() async {
    try {
      final saved = await _store!.read();
      if (saved != null) {
        _session = saved;
        _api!.token = saved.token;
      }
    } catch (_) {
      // A failed saved-session read leaves the user signed out.
    }
    _restoring = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _begin();
    try {
      await _setSession(
        await _api!.login(email: email.trim(), password: password),
      );
      return true;
    } on ApiException catch (e) {
      _error = messageForLogin(e);
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
        await _api!.register(
          fullName: fullName.trim(),
          email: email.trim(),
          password: password,
        );
      } on ApiException catch (e) {
        _error = messageForRegister(e);
        return false;
      }
      try {
        await _setSession(
          await _api.login(email: email.trim(), password: password),
        );
      } on ApiException {
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
    if (_api != null) _api.token = null;
    _sessionExpired = false;
    if (_store != null) {
      try {
        await _store.clear();
      } catch (_) {}
    }
    notifyListeners();
  }

  void handleUnauthorized() {
    if (_session == null) return;
    _session = null;
    _account = null;
    if (_api != null) _api.token = null;
    _sessionExpired = true;
    _store?.clear().catchError((_) {});
    notifyListeners();
  }

  void clearMessages() {
    if (_error == null && !_sessionExpired) return;
    _error = null;
    _sessionExpired = false;
    notifyListeners();
  }

  void _begin() {
    _busy = true;
    _error = null;
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> _setSession(Session session) async {
    _session = session;
    _api!.token = session.token;
    try {
      await _store!.save(session);
    } catch (_) {
      // The user remains signed in for this run if session persistence fails.
    }
  }
}
