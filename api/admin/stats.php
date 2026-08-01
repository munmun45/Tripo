<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

$users = (int) (db()->query('SELECT COUNT(*) AS c FROM users')->fetch_assoc()['c'] ?? 0);
$admins = (int) (db()->query('SELECT COUNT(*) AS c FROM users WHERE is_admin = 1')->fetch_assoc()['c'] ?? 0);
$packages = (int) (db()->query('SELECT COUNT(*) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
$cities = (int) (db()->query('SELECT COUNT(DISTINCT city) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
$saved = (int) (db()->query('SELECT COUNT(*) AS c FROM saved_packages')->fetch_assoc()['c'] ?? 0);

json_ok([
    'stats' => [
        'users' => $users,
        'admins' => $admins,
        'packages' => $packages,
        'cities' => $cities,
        'saved' => $saved,
    ],
]);
