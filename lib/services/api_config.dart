/// Live Tripo backend.
class ApiConfig {
  /// Must be HTTPS — host returns 301 from HTTP.
  static const baseUrl = 'https://munmunmaharana.in/tripo/api';

  static const health = '$baseUrl/health.php';
  static const register = '$baseUrl/auth/register.php';
  static const login = '$baseUrl/auth/login.php';
  static const me = '$baseUrl/auth/me.php';
  static const logout = '$baseUrl/auth/logout.php';
  static const savedPackages = '$baseUrl/packages/saved.php';
  static const savedToggle = '$baseUrl/packages/saved_toggle.php';
  static const notesList = '$baseUrl/notes/list.php';
  static const notesSave = '$baseUrl/notes/save.php';
  static const notesDelete = '$baseUrl/notes/delete.php';
  static const adminStats = '$baseUrl/admin/stats.php';
  static const adminUsers = '$baseUrl/admin/users.php';
  static const adminUserDelete = '$baseUrl/admin/user_delete.php';
}
