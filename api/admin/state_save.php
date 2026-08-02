<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

if (!table_exists('states')) {
    json_fail('Run migrate_cities.sql first', 500);
}

$in = body_json();
$name = trim((string) ($in['name'] ?? ''));
$countryId = (int) ($in['country_id'] ?? 0);
if ($name === '' || $countryId <= 0) {
    json_fail('State name and country are required');
}

try {
    $chk = db()->prepare('SELECT id FROM countries WHERE id = ? LIMIT 1');
    $chk->bind_param('i', $countryId);
    $chk->execute();
    if (!$chk->get_result()->fetch_assoc()) {
        $chk->close();
        json_fail('Country not found', 404);
    }
    $chk->close();

    $stmt = db()->prepare('INSERT INTO states (country_id, name) VALUES (?, ?)');
    $stmt->bind_param('is', $countryId, $name);
    $stmt->execute();
    $id = (int) $stmt->insert_id;
    $stmt->close();
    json_ok([
        'state' => [
            'id' => $id,
            'name' => $name,
            'country_id' => $countryId,
        ],
        'message' => 'State added',
    ]);
} catch (Throwable $e) {
    if (str_contains($e->getMessage(), 'Duplicate')) {
        json_fail('State already exists for this country');
    }
    json_fail('Save failed: ' . $e->getMessage(), 500);
}
