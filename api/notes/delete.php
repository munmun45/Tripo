<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$user = require_user();
$uid = (int) $user['id'];
$in = body_json();
$id = (int) ($in['id'] ?? 0);

if ($id <= 0) {
    json_fail('id is required');
}

$stmt = db()->prepare('DELETE FROM notes WHERE id = ? AND user_id = ?');
$stmt->bind_param('ii', $id, $uid);
$stmt->execute();
$ok = $stmt->affected_rows > 0;
$stmt->close();

if (!$ok) {
    json_fail('Note not found', 404);
}

json_ok(['message' => 'Deleted']);
