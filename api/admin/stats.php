<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

try {
    $users = (int) (db()->query('SELECT COUNT(*) AS c FROM users')->fetch_assoc()['c'] ?? 0);

    $admins = 0;
    if (column_exists('users', 'is_admin')) {
        $admins = (int) (db()->query('SELECT COUNT(*) AS c FROM users WHERE is_admin = 1')->fetch_assoc()['c'] ?? 0);
    }

    $packages = 0;
    $cities = 0;
    if (table_exists('travel_packages')) {
        $packages = (int) (db()->query('SELECT COUNT(*) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
        $cities = (int) (db()->query('SELECT COUNT(DISTINCT city) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
    }

    $saved = 0;
    if (table_exists('saved_packages')) {
        $saved = (int) (db()->query('SELECT COUNT(*) AS c FROM saved_packages')->fetch_assoc()['c'] ?? 0);
    }

    json_ok([
        'stats' => [
            'users' => $users,
            'admins' => $admins,
            'packages' => $packages,
            'cities' => $cities,
            'saved' => $saved,
        ],
    ]);
} catch (Throwable $e) {
    json_fail('Stats failed: ' . $e->getMessage(), 500);
}
