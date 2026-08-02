<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

ensure_user_active_column();

$q = trim((string) ($_GET['q'] ?? ''));
$like = '%' . $q . '%';
$hasAdmin = column_exists('users', 'is_admin');
$adminSelect = $hasAdmin ? 'is_admin' : '0 AS is_admin';
$activeSelect = column_exists('users', 'is_active') ? 'is_active' : '1 AS is_active';

try {
    if ($q !== '') {
        $stmt = db()->prepare(
            "SELECT id, name, email, phone, {$adminSelect}, {$activeSelect}, created_at
             FROM users
             WHERE name LIKE ? OR phone LIKE ? OR email LIKE ?
             ORDER BY id DESC
             LIMIT 200"
        );
        $stmt->bind_param('sss', $like, $like, $like);
    } else {
        $stmt = db()->prepare(
            "SELECT id, name, email, phone, {$adminSelect}, {$activeSelect}, created_at
             FROM users
             ORDER BY id DESC
             LIMIT 200"
        );
    }

    $stmt->execute();
    $res = $stmt->get_result();
    $users = [];
    $now = new DateTimeImmutable('today');
    while ($row = $res->fetch_assoc()) {
        $created = $row['created_at'] ?? null;
        $days = 0;
        if ($created) {
            try {
                $join = new DateTimeImmutable($created);
                // Inclusive tenure (join day counts as day 1)
                $days = max(1, (int) $join->diff($now)->days + 1);
            } catch (Throwable $e) {
                $days = 0;
            }
        }
        $users[] = [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'email' => $row['email'],
            'phone' => $row['phone'],
            'is_admin' => (int) $row['is_admin'] === 1,
            'is_active' => (int) ($row['is_active'] ?? 1) === 1,
            'created_at' => $row['created_at'],
            'join_date' => $created ? date('Y-m-d', strtotime($created)) : null,
            'days_on_app' => $days,
        ];
    }
    $stmt->close();

    json_ok(['users' => $users, 'count' => count($users)]);
} catch (Throwable $e) {
    json_fail('Users failed: ' . $e->getMessage(), 500);
}

function ensure_user_active_column(): void
{
    static $done = false;
    if ($done) {
        return;
    }
    $done = true;
    try {
        if (!column_exists('users', 'is_active')) {
            db()->query(
                'ALTER TABLE users ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER phone'
            );
        }
    } catch (Throwable $e) {
        // ignore duplicate / permission
    }
}
