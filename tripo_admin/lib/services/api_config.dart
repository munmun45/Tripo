/// Tripo Admin API (same host as mobile app).
class ApiConfig {
  static const baseUrl = 'https://munmunmaharana.in/tripo/api';

  static const login = '$baseUrl/auth/login.php';
  static const me = '$baseUrl/auth/me.php';
  static const logout = '$baseUrl/auth/logout.php';
  static const users = '$baseUrl/admin/users.php';
  static const packages = '$baseUrl/admin/packages.php';
  static const stats = '$baseUrl/admin/stats.php';
}
