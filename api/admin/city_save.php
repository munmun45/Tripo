<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

if (!table_exists('cities')) {
    json_fail('Run migrate_cities.sql first', 500);
}

$in = body_json();
$id = (int) ($in['id'] ?? 0);
$name = trim((string) ($in['name'] ?? ''));
$countryId = (int) ($in['country_id'] ?? 0);
$stateId = (int) ($in['state_id'] ?? 0);
$imageUrl = trim((string) ($in['image_url'] ?? $in['imageUrl'] ?? ''));
$tagline = trim((string) ($in['tagline'] ?? ''));
$active = !empty($in['active']) ? 1 : 0;

if ($name === '' || $countryId <= 0 || $stateId <= 0) {
    json_fail('City name, country and state are required');
}

try {
    $st = db()->prepare(
        'SELECT id FROM states WHERE id = ? AND country_id = ? LIMIT 1'
    );
    $st->bind_param('ii', $stateId, $countryId);
    $st->execute();
    if (!$st->get_result()->fetch_assoc()) {
        $st->close();
        json_fail('State does not belong to selected country');
    }
    $st->close();

    if ($id > 0) {
        $stmt = db()->prepare(
            'UPDATE cities SET name=?, country_id=?, state_id=?, image_url=?, tagline=?, active=?
             WHERE id=?'
        );
        $stmt->bind_param(
            'siissii',
            $name,
            $countryId,
            $stateId,
            $imageUrl,
            $tagline,
            $active,
            $id
        );
        $stmt->execute();
        $stmt->close();
        $message = 'City updated';
    } else {
        $stmt = db()->prepare(
            'INSERT INTO cities (name, country_id, state_id, image_url, tagline, active)
             VALUES (?,?,?,?,?,?)'
        );
        $stmt->bind_param(
            'siissi',
            $name,
            $countryId,
            $stateId,
            $imageUrl,
            $tagline,
            $active
        );
        $stmt->execute();
        $id = (int) $stmt->insert_id;
        $stmt->close();
        $message = 'City created';
    }

    json_ok([
        'id' => $id,
        'message' => $message,
    ]);
} catch (Throwable $e) {
    if (str_contains($e->getMessage(), 'Duplicate')) {
        json_fail('City already exists in this state');
    }
    json_fail('Save failed: ' . $e->getMessage(), 500);
}
