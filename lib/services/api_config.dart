/// Live Tripo backend.
class ApiConfig {
  static const baseUrl = 'http://munmunmaharana.in/tripo/api';

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
}
