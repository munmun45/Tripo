<?php
require_once __DIR__ . '/includes/bootstrap.php';

json_ok([
    'service' => 'Tripo API',
    'base' => 'http://munmunmaharana.in/tripo/api',
    'version' => '1.0.0',
    'endpoints' => [
        'GET  /health.php',
        'POST /auth/register.php',
        'POST /auth/login.php',
        'GET  /auth/me.php',
        'POST /auth/logout.php',
        'GET  /packages/saved.php',
        'POST /packages/saved_toggle.php',
        'GET  /notes/list.php',
        'POST /notes/save.php',
        'POST /notes/delete.php',
    ],
    'capacity' => 'Designed for ~100 concurrent mobile users (PHP + MySQLi).',
]);
