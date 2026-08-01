<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$user = require_user();
$token = $user['token'];

$stmt = db()->prepare('DELETE FROM api_tokens WHERE token = ?');
$stmt->bind_param('s', $token);
$stmt->execute();
$stmt->close();

json_ok(['message' => 'Logged out']);
