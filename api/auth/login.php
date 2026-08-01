<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$in = body_json();
$phone = preg_replace('/\D+/', '', (string) ($in['phone'] ?? $in['email'] ?? ''));
$password = (string) ($in['password'] ?? '');

if (strlen($phone) < 10 || $password === '') {
    json_fail('Phone and password required');
}

$stmt = db()->prepare(
    'SELECT id, name, email, phone, password_hash FROM users WHERE phone = ? LIMIT 1'
);
$stmt->bind_param('s', $phone);
$stmt->execute();
$user = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$user || !password_verify($password, $user['password_hash'])) {
    json_fail('Invalid phone or password', 401);
}

$token = issue_token((int) $user['id']);
json_ok([
    'token' => $token,
    'user' => user_public($user),
]);
