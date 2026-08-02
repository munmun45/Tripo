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

$hasAdmin = column_exists('users', 'is_admin');
$adminSelect = $hasAdmin ? 'is_admin' : '0 AS is_admin';
$hasActive = column_exists('users', 'is_active');
$activeSelect = $hasActive ? 'is_active' : '1 AS is_active';

try {
    $stmt = db()->prepare(
        "SELECT id, name, email, phone, {$adminSelect}, {$activeSelect}, password_hash
         FROM users WHERE phone = ? LIMIT 1"
    );
    $stmt->bind_param('s', $phone);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();
    $stmt->close();
} catch (Throwable $e) {
    json_fail('Login query failed: ' . $e->getMessage(), 500);
}

if (!$user || !password_verify($password, $user['password_hash'])) {
    json_fail('Invalid phone or password', 401);
}

if ((int) ($user['is_active'] ?? 1) !== 1) {
    json_fail('Account is deactivated. Contact admin.', 403);
}

$user['is_admin'] = (int) ($user['is_admin'] ?? 0) === 1;
$token = issue_token((int) $user['id']);
track_user_activity((int) $user['id'], $token);
json_ok([
    'token' => $token,
    'user' => user_public($user),
]);
