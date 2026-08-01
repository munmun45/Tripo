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

  /// True when a saved session exists (token and/or login flag).
  static Future<bool> isLoggedIn() async {
    await _api.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final flagged = prefs.getBool(_keyLoggedIn) ?? false;
    final hasToken = (_api.token ?? '').isNotEmpty;
    return flagged || hasToken;
  }

  static Future<Map<String, String>?> currentUser() async {
    if (!await isLoggedIn()) return null;
    final prefs = await SharedPreferences.getInstance();
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

  /// Call on app start — keeps session after close/reopen.
  /// Does NOT logout on network errors.
  static Future<void> restoreSession() async {
    await _api.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final hasToken = (_api.token ?? '').isNotEmpty;
    final flagged = prefs.getBool(_keyLoggedIn) ?? false;

    if (!hasToken && !flagged) return;

    // Heal flag if token exists but bool was lost.
    if (hasToken && !flagged) {
      await prefs.setBool(_keyLoggedIn, true);
    }

    // Soft validate token. Keep local session unless clearly unauthorized
    // AND we got a JSON auth failure (avoid wiping session on HTML/proxy errors).
    if (!hasToken) return;
    try {
      final data = await _api.get(ApiConfig.me, auth: true);
      final user = data['user'];
      if (user is Map) {
        await prefs.setString(_keyName, '${user['name'] ?? 'Traveler'}');
        await prefs.setString(_keyPhone, '${user['phone'] ?? ''}');
        await prefs.setString(_keyEmail, '${user['email'] ?? ''}');
        await prefs.setString(_keyUserId, '${user['id'] ?? ''}');
        await prefs.setBool(_keyLoggedIn, true);
      }
    } on ApiException catch (e) {
      final msg = e.message.toLowerCase();
      final authFail = e.statusCode == 401 &&
          (msg.contains('token') ||
              msg.contains('invalid') ||
              msg.contains('expired') ||
              msg.contains('missing'));
      if (authFail) {
        await _clearLocalSession();
      }
      // Network / 500 / HTML errors: keep logged-in locally.
    } catch (_) {
      // Keep local session.
    }
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
    final token = data['token']?.toString();
    final userRaw = data['user'];
    if (token == null || token.isEmpty || userRaw is! Map) {
      throw ApiException('Invalid login response');
    }
    final user = Map<String, dynamic>.from(userRaw);

    await _api.saveToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, '${user['name'] ?? 'Traveler'}');
    await prefs.setString(_keyPhone, '${user['phone'] ?? ''}');
    await prefs.setString(_keyEmail, '${user['email'] ?? ''}');
    await prefs.setString(_keyUserId, '${user['id'] ?? ''}');

    // Ensure disk write completed (important on some Android devices).
    await prefs.reload();
    final saved = prefs.getBool(_keyLoggedIn) ?? false;
    final savedToken = prefs.getString('tripo_api_token') ?? '';
    if (!saved || savedToken.isEmpty) {
      // Retry once
      await prefs.setBool(_keyLoggedIn, true);
      await _api.saveToken(token);
    }
  }

  static Future<void> _clearLocalSession() async {
    await _api.saveToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
  }

  static Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout, auth: true);
    } catch (_) {
      // Ignore network errors on logout.
    }
    await _clearLocalSession();
  }
}
