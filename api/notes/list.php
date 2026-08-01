<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$user = require_user();
$uid = (int) $user['id'];

$stmt = db()->prepare(
    'SELECT id, title, body, created_at, updated_at
     FROM notes WHERE user_id = ? ORDER BY updated_at DESC'
);
$stmt->bind_param('i', $uid);
$stmt->execute();
$res = $stmt->get_result();
$notes = [];
while ($row = $res->fetch_assoc()) {
    $notes[] = [
        'id' => (int) $row['id'],
        'title' => $row['title'],
        'body' => $row['body'],
        'created_at' => $row['created_at'],
        'updated_at' => $row['updated_at'],
    ];
}
$stmt->close();

json_ok(['notes' => $notes]);
