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
    $stmt = db()->prepare('DELETE FROM cities WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    if ($stmt->affected_rows < 1) {
        $stmt->close();
        json_fail('City not found', 404);
    }
    $stmt->close();
    json_ok(['id' => $id, 'message' => 'City deleted']);
} catch (Throwable $e) {
    json_fail('Delete failed: ' . $e->getMessage(), 500);
}
