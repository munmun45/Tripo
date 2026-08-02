<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

if (!table_exists('travel_packages')) {
    json_ok([
        'packages' => [],
        'cities' => [],
        'count' => 0,
        'city_count' => 0,
        'message' => 'Run api/sql/migrate_admin.sql (or seed_packages.sql) to create travel_packages.',
    ]);
}

$city = trim((string) ($_GET['city'] ?? ''));

try {
    if ($city !== '') {
        $stmt = db()->prepare(
            'SELECT id, title, city, country, image_url, price, duration_days, rating, reviews, category, description, active
             FROM travel_packages
             WHERE city = ?
             ORDER BY title ASC'
        );
        $stmt->bind_param('s', $city);
    } else {
        $stmt = db()->prepare(
            'SELECT id, title, city, country, image_url, price, duration_days, rating, reviews, category, description, active
             FROM travel_packages
             ORDER BY city ASC, title ASC'
        );
    }

    $stmt->execute();
    $res = $stmt->get_result();
    $packages = [];
    $byCity = [];
    while ($row = $res->fetch_assoc()) {
        $pkg = [
            'id' => $row['id'],
            'title' => $row['title'],
            'city' => $row['city'],
            'country' => $row['country'],
            'image_url' => $row['image_url'],
            'price' => (float) $row['price'],
            'duration_days' => (int) $row['duration_days'],
            'rating' => (float) $row['rating'],
            'reviews' => (int) $row['reviews'],
            'category' => $row['category'],
            'description' => $row['description'],
            'active' => (int) $row['active'] === 1,
        ];
        $packages[] = $pkg;
        $c = $row['city'];
        if (!isset($byCity[$c])) {
            $byCity[$c] = [
                'city' => $c,
                'country' => $row['country'],
                'count' => 0,
                'packages' => [],
            ];
        }
        $byCity[$c]['count']++;
        $byCity[$c]['packages'][] = $pkg;
    }
    $stmt->close();

    json_ok([
        'packages' => $packages,
        'cities' => array_values($byCity),
        'count' => count($packages),
        'city_count' => count($byCity),
    ]);
} catch (Throwable $e) {
    json_fail('Packages failed: ' . $e->getMessage(), 500);
}
