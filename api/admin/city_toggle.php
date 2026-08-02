<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

$id = (int) ((body_json()['id'] ?? 0));
if ($id <= 0) {
    json_fail('City id required');
}

try {
    $stmt = db()->prepare('SELECT id, active FROM cities WHERE id = ? LIMIT 1');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    if (!$row) {
        json_fail('City not found', 404);
    }
    $next = (int) $row['active'] === 1 ? 0 : 1;
    $upd = db()->prepare('UPDATE cities SET active = ? WHERE id = ?');
    $upd->bind_param('ii', $next, $id);
    $upd->execute();
    $upd->close();
    json_ok([
        'id' => $id,
        'active' => $next === 1,
        'message' => $next === 1 ? 'City activated' : 'City deactivated',
    ]);
} catch (Throwable $e) {
    json_fail('Toggle failed: ' . $e->getMessage(), 500);
}
