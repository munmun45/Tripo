<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$admin = require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

if (!column_exists('users', 'is_active')) {
    try {
        db()->query(
            'ALTER TABLE users ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER phone'
        );
    } catch (Throwable $e) {
        json_fail('is_active column missing', 500);
    }
}

$in = body_json();
$id = (int) ($in['id'] ?? 0);
if ($id <= 0) {
    json_fail('User id required');
}

if ($id === (int) $admin['id']) {
    json_fail('You cannot deactivate your own admin account');
}

$hasAdmin = column_exists('users', 'is_admin');
$adminCol = $hasAdmin ? ', is_admin' : ', 0 AS is_admin';
$stmt = db()->prepare("SELECT id, is_active{$adminCol} FROM users WHERE id = ? LIMIT 1");
$stmt->bind_param('i', $id);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$row) {
    json_fail('User not found', 404);
}

if ((int) ($row['is_admin'] ?? 0) === 1) {
    json_fail('Admin accounts cannot be deactivated');
}

$next = (int) $row['is_active'] === 1 ? 0 : 1;
$upd = db()->prepare('UPDATE users SET is_active = ? WHERE id = ?');
$upd->bind_param('ii', $next, $id);
$upd->execute();
$upd->close();

json_ok([
    'id' => $id,
    'is_active' => $next === 1,
    'message' => $next === 1 ? 'User activated' : 'User deactivated',
]);
