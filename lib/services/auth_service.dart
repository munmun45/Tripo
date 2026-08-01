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

  /// Call once at app start — restores token + keeps session if offline.
  static Future<void> restoreSession() async {
    await _api.loadToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final token = _api.token;
    final hasToken = token != null && token.isNotEmpty;
    final flag = prefs.getBool(_keyLoggedIn) ?? false;

    // Token exists but flag missing (partial write) → keep logged in.
    if (hasToken && !flag) {
      await prefs.setBool(_keyLoggedIn, true);
    }

    if (!hasToken) return;

    // Soft refresh profile; never wipe session on network errors.
    try {
      final me = await _api.get(ApiConfig.me, auth: true);
      final user = me['user'];
      if (user is Map) {
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString(_keyName, '${user['name'] ?? 'Traveler'}');
        await prefs.setString(_keyPhone, '${user['phone'] ?? ''}');
        await prefs.setString(_keyEmail, '${user['email'] ?? ''}');
        await prefs.setString(_keyUserId, '${user['id'] ?? ''}');
      }
    } on ApiException catch (e) {
      // Only clear when server says token is invalid/expired.
      if (e.statusCode == 401) {
        await _clearLocalOnly();
      }
    } catch (_) {
      // Offline / timeout — stay logged in with cached profile.
    }
  }

  static Future<bool> isLoggedIn() async {
    await _api.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final token = _api.token;
    if (token != null && token.isNotEmpty) return true;
    return prefs.getBool(_keyLoggedIn) ?? false;
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

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    // refreshed by restoreSession / login via me payload when available
    return prefs.getBool('tripo_user_is_admin') ?? false;
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
    if (token == null || token.isEmpty || user == null) {
      throw ApiException('Invalid login response');
    }
    await _api.saveToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, '${user['name'] ?? 'Traveler'}');
    await prefs.setString(_keyPhone, '${user['phone'] ?? ''}');
    await prefs.setString(_keyEmail, '${user['email'] ?? ''}');
    await prefs.setString(_keyUserId, '${user['id'] ?? ''}');
    await prefs.setBool(
      'tripo_user_is_admin',
      user['is_admin'] == true || user['is_admin'] == 1,
    );
    // Ensure disk write is visible on next cold start.
    await prefs.reload();
  }

  static Future<void> _clearLocalOnly() async {
    await _api.saveToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
    await prefs.remove('tripo_user_is_admin');
  }

  /// Explicit user logout (drawer / profile). Calls API then clears local.
  static Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout, auth: true);
    } catch (_) {
      // Ignore network errors on logout.
    }
    await _clearLocalOnly();
  }
}
