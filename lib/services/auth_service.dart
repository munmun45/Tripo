import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'api_config.dart';

class AuthResult {
  final bool ok;
  final String message;

  const AuthResult({required this.ok, this.message = ''});
}

class AuthService {
  static const _keyLoggedIn = 'tripo_logged_in';
  static const _keyName = 'tripo_user_name';
  static const _keyPhone = 'tripo_user_phone';
  static const _keyEmail = 'tripo_user_email';
  static const _keyUserId = 'tripo_user_id';

  static final _api = ApiClient.instance;

  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<Map<String, String>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyLoggedIn) ?? false)) return null;
    return {
      'id': prefs.getString(_keyUserId) ?? '',
      'name': prefs.getString(_keyName) ?? 'Traveler',
      'phone': prefs.getString(_keyPhone) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
    };
  }

  static Future<String?> token() async {
    await _api.loadToken();
    return _api.token;
  }

  static Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final p = digitsOnly(phone);
    if (p.length < 10 || password.trim().isEmpty) {
      return const AuthResult(
        ok: false,
        message: 'Enter phone (10+ digits) and password',
      );
    }
    try {
      final data = await _api.post(
        ApiConfig.login,
        body: {
          'phone': p,
          'password': password,
        },
      );
      await _persistSession(data);
      return const AuthResult(ok: true, message: 'Welcome back');
    } on ApiException catch (e) {
      return AuthResult(ok: false, message: e.message);
    } catch (_) {
      return const AuthResult(
        ok: false,
        message: 'Cannot reach server. Check internet / API host.',
      );
    }
  }

  static Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final p = digitsOnly(phone);
    if (name.trim().isEmpty || p.length < 10 || password.trim().length < 4) {
      return const AuthResult(
        ok: false,
        message: 'Name, phone (10+ digits) & password (min 4) required',
      );
    }
    try {
      final data = await _api.post(
        ApiConfig.register,
        body: {
          'name': name.trim(),
          'phone': p,
          'password': password,
        },
      );
      await _persistSession(data);
      return const AuthResult(ok: true, message: 'Account created');
    } on ApiException catch (e) {
      return AuthResult(ok: false, message: e.message);
    } catch (_) {
      return const AuthResult(
        ok: false,
        message: 'Cannot reach server. Check internet / API host.',
      );
    }
  }

  static Future<void> _persistSession(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (token == null || user == null) {
      throw ApiException('Invalid login response');
    }
    await _api.saveToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, '${user['name'] ?? 'Traveler'}');
    await prefs.setString(_keyPhone, '${user['phone'] ?? ''}');
    await prefs.setString(_keyEmail, '${user['email'] ?? ''}');
    await prefs.setString(_keyUserId, '${user['id'] ?? ''}');
  }

  static Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout, auth: true);
    } catch (_) {
      // Ignore network errors on logout.
    }
    await _api.saveToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
  }
}
