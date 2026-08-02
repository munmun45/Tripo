<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if (!table_exists('countries') || !table_exists('states') || !table_exists('cities')) {
    json_ok([
        'countries' => [],
        'states' => [],
        'cities' => [],
        'message' => 'Run api/sql/migrate_cities.sql in phpMyAdmin',
    ]);
}

try {
    $countries = [];
    $res = db()->query('SELECT id, name FROM countries ORDER BY name ASC');
    while ($row = $res->fetch_assoc()) {
        $countries[] = [
            'id' => (int) $row['id'],
            'name' => $row['name'],
        ];
    }

    $states = [];
    $res = db()->query(
        'SELECT s.id, s.name, s.country_id, c.name AS country_name
         FROM states s
         INNER JOIN countries c ON c.id = s.country_id
         ORDER BY c.name ASC, s.name ASC'
    );
    while ($row = $res->fetch_assoc()) {
        $states[] = [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'country_id' => (int) $row['country_id'],
            'country_name' => $row['country_name'],
        ];
    }

    $cities = [];
    $res = db()->query(
        'SELECT ci.id, ci.name, ci.image_url, ci.tagline, ci.active,
                ci.country_id, ci.state_id,
                c.name AS country_name, s.name AS state_name
         FROM cities ci
         INNER JOIN countries c ON c.id = ci.country_id
         INNER JOIN states s ON s.id = ci.state_id
         ORDER BY c.name ASC, s.name ASC, ci.name ASC'
    );
    while ($row = $res->fetch_assoc()) {
        $cities[] = [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'image_url' => $row['image_url'],
            'tagline' => $row['tagline'],
            'active' => (int) $row['active'] === 1,
            'country_id' => (int) $row['country_id'],
            'state_id' => (int) $row['state_id'],
            'country_name' => $row['country_name'],
            'state_name' => $row['state_name'],
        ];
    }

    json_ok([
        'countries' => $countries,
        'states' => $states,
        'cities' => $cities,
        'count' => count($cities),
    ]);
} catch (Throwable $e) {
    json_fail('Locations failed: ' . $e->getMessage(), 500);
}
