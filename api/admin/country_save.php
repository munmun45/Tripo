<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

if (!table_exists('countries')) {
    json_fail('Run migrate_cities.sql first', 500);
}

$in = body_json();
$name = trim((string) ($in['name'] ?? ''));
if ($name === '') {
    json_fail('Country name required');
}

try {
    $stmt = db()->prepare('INSERT INTO countries (name) VALUES (?)');
    $stmt->bind_param('s', $name);
    $stmt->execute();
    $id = (int) $stmt->insert_id;
    $stmt->close();
    json_ok([
        'country' => ['id' => $id, 'name' => $name],
        'message' => 'Country added',
    ]);
} catch (Throwable $e) {
    if (str_contains($e->getMessage(), 'Duplicate')) {
        json_fail('Country already exists');
    }
    json_fail('Save failed: ' . $e->getMessage(), 500);
}
