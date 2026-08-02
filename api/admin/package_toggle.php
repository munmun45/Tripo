<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$in = body_json();
$id = trim((string) ($in['id'] ?? ''));
if ($id === '') {
    json_fail('Package id required');
}

try {
    $stmt = db()->prepare('SELECT id, active FROM travel_packages WHERE id = ? LIMIT 1');
    $stmt->bind_param('s', $id);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    if (!$row) {
        json_fail('Package not found', 404);
    }
    $next = (int) $row['active'] === 1 ? 0 : 1;
    $upd = db()->prepare('UPDATE travel_packages SET active = ? WHERE id = ?');
    $upd->bind_param('is', $next, $id);
    $upd->execute();
    $upd->close();
    json_ok([
        'id' => $id,
        'active' => $next === 1,
        'message' => $next === 1 ? 'Package activated' : 'Package deactivated',
    ]);
} catch (Throwable $e) {
    json_fail('Toggle failed: ' . $e->getMessage(), 500);
}
