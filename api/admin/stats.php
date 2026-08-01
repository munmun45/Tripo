<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

$users = (int) (db()->query('SELECT COUNT(*) AS c FROM users')->fetch_assoc()['c'] ?? 0);
$admins = (int) (db()->query('SELECT COUNT(*) AS c FROM users WHERE is_admin = 1')->fetch_assoc()['c'] ?? 0);
$saved = (int) (db()->query('SELECT COUNT(*) AS c FROM saved_packages')->fetch_assoc()['c'] ?? 0);
$notes = (int) (db()->query('SELECT COUNT(*) AS c FROM notes')->fetch_assoc()['c'] ?? 0);
$tokens = (int) (db()->query('SELECT COUNT(*) AS c FROM api_tokens WHERE expires_at > NOW()')->fetch_assoc()['c'] ?? 0);

json_ok([
    'stats' => [
        'users' => $users,
        'admins' => $admins,
        'saved_packages' => $saved,
        'notes' => $notes,
        'active_sessions' => $tokens,
    ],
]);
