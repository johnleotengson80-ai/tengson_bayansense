import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';

/// Where the login session is kept between app launches.
abstract class TokenStore {
  Future<Session?> read();
  Future<void> save(Session session);
  Future<void> clear();
}

/// Stores the session in shared_preferences (browser localStorage on web).
/// Trade-off: simple and works everywhere, but it is not encrypted storage. Acceptable for this
/// project; revisit (e.g. flutter_secure_storage on mobile) before real deployment.
class PrefsTokenStore implements TokenStore {
  static const String _idKey = 'session_id';
  static const String _roleKey = 'session_role';
  static const String _tokenKey = 'session_token';

  @override
  Future<Session?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_idKey);
    final role = prefs.getString(_roleKey);
    final token = prefs.getString(_tokenKey);
    if (id == null || role == null || token == null) return null;
    return Session(id: id, role: role, token: token);
  }

  @override
  Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_idKey, session.id);
    await prefs.setString(_roleKey, session.role);
    await prefs.setString(_tokenKey, session.token);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_tokenKey);
  }
}
