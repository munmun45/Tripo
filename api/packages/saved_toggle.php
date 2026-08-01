<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$user = require_user();
$uid = (int) $user['id'];
$in = body_json();
$packageId = trim((string) ($in['package_id'] ?? ''));

if ($packageId === '') {
    json_fail('package_id is required');
}

// Already saved?
$check = db()->prepare(
    'SELECT id FROM saved_packages WHERE user_id = ? AND package_id = ? LIMIT 1'
);
$check->bind_param('is', $uid, $packageId);
$check->execute();
$existing = $check->get_result()->fetch_assoc();
$check->close();

if ($existing) {
    $del = db()->prepare('DELETE FROM saved_packages WHERE id = ?');
    $id = (int) $existing['id'];
    $del->bind_param('i', $id);
    $del->execute();
    $del->close();
    $saved = false;
} else {
    $ins = db()->prepare(
        'INSERT INTO saved_packages (user_id, package_id) VALUES (?, ?)'
    );
    $ins->bind_param('is', $uid, $packageId);
    $ins->execute();
    $ins->close();
    $saved = true;
}

$countStmt = db()->prepare('SELECT COUNT(*) AS c FROM saved_packages WHERE user_id = ?');
$countStmt->bind_param('i', $uid);
$countStmt->execute();
$count = (int) ($countStmt->get_result()->fetch_assoc()['c'] ?? 0);
$countStmt->close();

json_ok([
    'package_id' => $packageId,
    'saved' => $saved,
    'count' => $count,
]);
