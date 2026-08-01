<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

$q = trim((string) ($_GET['q'] ?? ''));
$like = '%' . $q . '%';

if ($q !== '') {
    $stmt = db()->prepare(
        'SELECT id, name, email, phone, is_admin, created_at
         FROM users
         WHERE name LIKE ? OR phone LIKE ? OR email LIKE ?
         ORDER BY id DESC
         LIMIT 200'
    );
    $stmt->bind_param('sss', $like, $like, $like);
} else {
    $stmt = db()->prepare(
        'SELECT id, name, email, phone, is_admin, created_at
         FROM users
         ORDER BY id DESC
         LIMIT 200'
    );
}

$stmt->execute();
$res = $stmt->get_result();
$users = [];
while ($row = $res->fetch_assoc()) {
    $users[] = [
        'id' => (int) $row['id'],
        'name' => $row['name'],
        'email' => $row['email'],
        'phone' => $row['phone'],
        'is_admin' => (int) $row['is_admin'] === 1,
        'created_at' => $row['created_at'],
    ];
}
$stmt->close();

json_ok(['users' => $users, 'count' => count($users)]);
