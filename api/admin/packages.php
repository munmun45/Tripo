<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/_packages_lib.php';

require_admin();
ensure_package_extra_columns();

if (!table_exists('travel_packages')) {
    json_ok([
        'packages' => [],
        'cities' => [],
        'destination_cities' => destination_cities(),
        'categories' => ['Romantic', 'Culture', 'Wellness', 'Adventure', 'Luxury', 'Beach', 'Mountain'],
        'count' => 0,
        'city_count' => 0,
        'message' => 'Run api/sql/migrate_admin.sql to create travel_packages.',
    ]);
}

$city = trim((string) ($_GET['city'] ?? ''));
$q = trim((string) ($_GET['q'] ?? ''));
$hasHighlights = column_exists('travel_packages', 'highlights');
$extraCols = $hasHighlights ? ', highlights, includes' : '';

try {
    $sql = "SELECT id, title, city, country, image_url, price, duration_days, rating, reviews, category, description, active{$extraCols}
            FROM travel_packages WHERE 1=1";
    $types = '';
    $params = [];

    if ($city !== '') {
        $sql .= ' AND city = ?';
        $types .= 's';
        $params[] = $city;
    }
    if ($q !== '') {
        $sql .= ' AND (title LIKE ? OR city LIKE ? OR country LIKE ? OR category LIKE ?)';
        $like = '%' . $q . '%';
        $types .= 'ssss';
        array_push($params, $like, $like, $like, $like);
    }
    $sql .= ' ORDER BY city ASC, title ASC';

    $stmt = db()->prepare($sql);
    if ($types !== '') {
        $stmt->bind_param($types, ...$params);
    }
    $stmt->execute();
    $res = $stmt->get_result();
    $packages = [];
    $byCity = [];
    while ($row = $res->fetch_assoc()) {
        if (!$hasHighlights) {
            $row['highlights'] = null;
            $row['includes'] = null;
        }
        $pkg = package_row_to_api($row);
        $packages[] = $pkg;
        $c = $row['city'];
        if (!isset($byCity[$c])) {
            $byCity[$c] = [
                'city' => $c,
                'country' => $row['country'],
                'count' => 0,
            ];
        }
        $byCity[$c]['count']++;
    }
    $stmt->close();

    json_ok([
        'packages' => $packages,
        'cities' => array_values($byCity),
        'destination_cities' => destination_cities(),
        'categories' => ['Romantic', 'Culture', 'Wellness', 'Adventure', 'Luxury', 'Beach', 'Mountain'],
        'count' => count($packages),
        'city_count' => count($byCity),
    ]);
} catch (Throwable $e) {
    json_fail('Packages failed: ' . $e->getMessage(), 500);
}
