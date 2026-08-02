/// Tripo Admin API (same host as mobile app).
class ApiConfig {
  static const baseUrl = 'https://munmunmaharana.in/tripo/api';

  static const login = '$baseUrl/auth/login.php';
  static const me = '$baseUrl/auth/me.php';
  static const logout = '$baseUrl/auth/logout.php';
  static const users = '$baseUrl/admin/users.php';
  static const userToggle = '$baseUrl/admin/user_toggle.php';
  static const packages = '$baseUrl/admin/packages.php';
  static const packageSave = '$baseUrl/admin/package_save.php';
  static const packageDelete = '$baseUrl/admin/package_delete.php';
  static const packageToggle = '$baseUrl/admin/package_toggle.php';
  static const locations = '$baseUrl/admin/locations.php';
  static const countrySave = '$baseUrl/admin/country_save.php';
  static const countryDelete = '$baseUrl/admin/country_delete.php';
  static const stateSave = '$baseUrl/admin/state_save.php';
  static const stateDelete = '$baseUrl/admin/state_delete.php';
  static const citySave = '$baseUrl/admin/city_save.php';
  static const cityDelete = '$baseUrl/admin/city_delete.php';
  static const cityToggle = '$baseUrl/admin/city_toggle.php';
  static const stats = '$baseUrl/admin/stats.php';
  static const dashboard = '$baseUrl/admin/dashboard.php';
}
