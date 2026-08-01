import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  static const _tokenKey = 'tripo_admin_token';
  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth && (_token ?? '').isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
      h['X-Api-Token'] = _token!;
    }
    return h;
  }

  Future<Map<String, dynamic>> get(String url, {bool auth = false}) async {
    await loadToken();
    final res = await http
        .get(Uri.parse(url), headers: _headers(auth: auth))
        .timeout(const Duration(seconds: 25));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    await loadToken();
    final res = await http
        .post(
          Uri.parse(url),
          headers: _headers(auth: auth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 25));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(res.body);
      data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'ok': false, 'message': 'Bad response'};
    } catch (_) {
      throw ApiException('Server error (${res.statusCode})',
          statusCode: res.statusCode);
    }
    if (data['ok'] != true) {
      throw ApiException(
        (data['message'] as String?) ?? 'Request failed',
        statusCode: res.statusCode,
      );
    }
    return data;
  }
}
