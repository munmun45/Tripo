<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$admin = require_admin();
$in = body_json();
$id = (int) ($in['id'] ?? 0);

if ($id <= 0) {
    json_fail('User id required');
}
if ($id === (int) $admin['id']) {
    json_fail('You cannot delete your own admin account');
}

$stmt = db()->prepare('DELETE FROM users WHERE id = ? AND is_admin = 0 LIMIT 1');
$stmt->bind_param('i', $id);
$stmt->execute();
$ok = $stmt->affected_rows > 0;
$stmt->close();

if (!$ok) {
    json_fail('User not found or is admin', 404);
}

json_ok(['message' => 'User deleted']);
