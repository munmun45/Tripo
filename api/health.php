<?php
require_once __DIR__ . '/includes/bootstrap.php';

try {
    $pong = db()->query('SELECT 1 AS ok')->fetch_assoc();
    json_ok([
        'status' => 'up',
        'db' => ((int) ($pong['ok'] ?? 0) === 1) ? 'connected' : 'unknown',
        'time' => date('c'),
    ]);
} catch (Throwable $e) {
    json_fail('Database connection failed: ' . $e->getMessage(), 500);
}
