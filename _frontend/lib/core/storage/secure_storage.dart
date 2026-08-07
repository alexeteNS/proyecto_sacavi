import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Wrapper sobre SharedPreferences para guardar y recuperar el JWT y el
/// JSON del usuario autenticado.
class SecureStorageService {
  SecureStorageService(this._prefs);

  final SharedPreferences _prefs;

  // ─── JWT ──────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _prefs.setString(AppConfig.jwtStorageKey, token);

  Future<String?> getToken() async =>
      _prefs.getString(AppConfig.jwtStorageKey);

  Future<void> deleteToken() =>
      _prefs.remove(AppConfig.jwtStorageKey);

  // ─── User JSON ────────────────────────────────────────────────────────────

  Future<void> saveUser(String userJson) =>
      _prefs.setString(AppConfig.userStorageKey, userJson);

  Future<String?> getUser() async =>
      _prefs.getString(AppConfig.userStorageKey);

  Future<void> deleteUser() =>
      _prefs.remove(AppConfig.userStorageKey);

  // ─── Clear all ────────────────────────────────────────────────────────────

  Future<void> clearAll() => _prefs.clear();
}

