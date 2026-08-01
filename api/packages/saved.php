<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$user = require_user();
$uid = (int) $user['id'];

$stmt = db()->prepare(
    'SELECT package_id, created_at FROM saved_packages WHERE user_id = ? ORDER BY created_at DESC'
);
$stmt->bind_param('i', $uid);
$stmt->execute();
$res = $stmt->get_result();
$ids = [];
while ($row = $res->fetch_assoc()) {
    $ids[] = $row['package_id'];
}
$stmt->close();

json_ok(['package_ids' => $ids, 'count' => count($ids)]);
