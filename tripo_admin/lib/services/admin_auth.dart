import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'api_config.dart';

class AdminAuth {
  static final AdminAuth instance = AdminAuth._();
  AdminAuth._();

  static const _nameKey = 'tripo_admin_name';
  static const _phoneKey = 'tripo_admin_phone';

  final _api = ApiClient.instance;
  String name = '';
  String phone = '';

  Future<bool> restore() async {
    await _api.loadToken();
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(_nameKey) ?? '';
    phone = prefs.getString(_phoneKey) ?? '';
    final token = prefs.getString('tripo_admin_token') ?? '';
    if (token.isEmpty) return false;
    try {
      final data = await _api.get(ApiConfig.me, auth: true);
      final user = data['user'];
      if (user is! Map || user['is_admin'] != true) {
        await logout();
        return false;
      }
      name = '${user['name'] ?? name}';
      phone = '${user['phone'] ?? phone}';
      await prefs.setString(_nameKey, name);
      await prefs.setString(_phoneKey, phone);
      return true;
    } catch (_) {
      // Keep local session if offline.
      return name.isNotEmpty;
    }
  }

  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    final p = phone.replaceAll(RegExp(r'\D'), '');
    try {
      final data = await _api.post(
        ApiConfig.login,
        body: {'phone': p, 'password': password},
      );
      final user = data['user'];
      final token = data['token']?.toString();
      if (token == null || user is! Map) return 'Invalid server response';
      if (user['is_admin'] != true) {
        return 'This account is not an admin';
      }
      await _api.saveToken(token);
      name = '${user['name'] ?? 'Admin'}';
      this.phone = '${user['phone'] ?? p}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, name);
      await prefs.setString(_phoneKey, this.phone);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Cannot reach API';
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout, auth: true);
    } catch (_) {}
    await _api.saveToken(null);
    name = '';
    phone = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
  }
}
