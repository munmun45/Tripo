<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$user = require_user();
$uid = (int) $user['id'];
$in = body_json();

$id = isset($in['id']) ? (int) $in['id'] : 0;
$title = trim((string) ($in['title'] ?? ''));
$body = trim((string) ($in['body'] ?? ''));

if ($body === '') {
    json_fail('Note body is required');
}

if ($id > 0) {
    $stmt = db()->prepare(
        'UPDATE notes SET title = ?, body = ? WHERE id = ? AND user_id = ?'
    );
    $stmt->bind_param('ssii', $title, $body, $id, $uid);
    $stmt->execute();
    if ($stmt->affected_rows < 0) {
        $stmt->close();
        json_fail('Update failed', 500);
    }
    $stmt->close();
} else {
    $stmt = db()->prepare(
        'INSERT INTO notes (user_id, title, body) VALUES (?, ?, ?)'
    );
    $stmt->bind_param('iss', $uid, $title, $body);
    $stmt->execute();
    $id = (int) $stmt->insert_id;
    $stmt->close();
}

json_ok(['id' => $id, 'message' => 'Saved']);
