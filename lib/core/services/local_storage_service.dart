import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCurrency = 'currency_type';
  static const String _keyOnboarded = 'onboarded';
  static const String _keyUserToken = 'user_token';
  static const String _keyUserData = 'user_data';

  // Theme mode: light, dark, system
  Future<void> setThemeMode(String value) async {
    await _prefs.setString(_keyThemeMode, value);
  }

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  // Currency selection
  Future<void> setCurrency(String value) async {
    await _prefs.setString(_keyCurrency, value);
  }

  String getCurrency() {
    return _prefs.getString(_keyCurrency) ?? 'inr';
  }

  // Onboarded status
  Future<void> setOnboarded(bool value) async {
    await _prefs.setBool(_keyOnboarded, value);
  }

  bool isOnboarded() {
    return _prefs.getBool(_keyOnboarded) ?? false;
  }

  // Secure / Standard Local Cache
  Future<void> setToken(String token) async {
    await _prefs.setString(_keyUserToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyUserToken);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyUserToken);
    await _prefs.remove(_keyUserData);
  }
}
