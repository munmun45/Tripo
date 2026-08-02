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
    $stmt = db()->prepare('DELETE FROM travel_packages WHERE id = ?');
    $stmt->bind_param('s', $id);
    $stmt->execute();
    $affected = $stmt->affected_rows;
    $stmt->close();
    if ($affected < 1) {
        json_fail('Package not found', 404);
    }
    json_ok(['id' => $id, 'message' => 'Package deleted']);
} catch (Throwable $e) {
    json_fail('Delete failed: ' . $e->getMessage(), 500);
}
