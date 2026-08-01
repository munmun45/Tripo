<?php
/**
 * One-time: set demo user passwords to Tripo@123
 * Open once after importing sql, then DELETE this file.
 */
require_once __DIR__ . '/../includes/bootstrap.php';

$hash = password_hash('Tripo@123', PASSWORD_DEFAULT);
$phones = ['9999999999', '9876543210'];

$updated = 0;
foreach ($phones as $phone) {
    $stmt = db()->prepare(
        'UPDATE users SET password_hash = ?, is_admin = 1 WHERE phone = ?'
    );
    $stmt->bind_param('ss', $hash, $phone);
    $stmt->execute();
    $updated += $stmt->affected_rows;
    $stmt->close();
}

json_ok([
    'message' => 'Demo passwords set to Tripo@123 and marked admin',
    'updated_rows' => $updated,
    'admin_login' => [
        'phone' => '9876543210',
        'password' => 'Tripo@123',
    ],
]);
