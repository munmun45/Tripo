<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$in = body_json();
$name = trim((string) ($in['name'] ?? ''));
$phone = preg_replace('/\D+/', '', (string) ($in['phone'] ?? ''));
$password = (string) ($in['password'] ?? '');

if ($name === '' || strlen($name) < 2) {
    json_fail('Name is required');
}
if (strlen($phone) < 10) {
    json_fail('Valid phone number is required (min 10 digits)');
}
if (strlen($password) < 4) {
    json_fail('Password must be at least 4 characters');
}

$hash = password_hash($password, PASSWORD_DEFAULT);
// Optional placeholder email for older schema compatibility
$email = $phone . '@tripo.phone';

try {
    $stmt = db()->prepare(
        'INSERT INTO users (name, email, password_hash, phone) VALUES (?, ?, ?, ?)'
    );
    $stmt->bind_param('ssss', $name, $email, $hash, $phone);
    $stmt->execute();
    $userId = (int) $stmt->insert_id;
    $stmt->close();
} catch (mysqli_sql_exception $e) {
    if ((int) $e->getCode() === 1062) {
        json_fail('Phone number already registered', 409);
    }
    json_fail('Register failed', 500);
}

$token = issue_token($userId);
json_ok([
    'token' => $token,
    'user' => [
        'id' => $userId,
        'name' => $name,
        'email' => $email,
        'phone' => $phone,
    ],
], 201);
