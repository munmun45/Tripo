import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'tripo_logged_in';
  static const _keyName = 'tripo_user_name';
  static const _keyEmail = 'tripo_user_email';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<Map<String, String>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyLoggedIn) ?? false)) return null;
    return {
      'name': prefs.getString(_keyName) ?? 'Traveler',
      'email': prefs.getString(_keyEmail) ?? '',
    };
  }

  /// Demo login — no database. Accept any non-empty email/password.
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.setString(
      _keyName,
      email.split('@').first.replaceAll('.', ' '),
    );
    return true;
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().length < 4) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.setString(_keyName, name.trim());
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
