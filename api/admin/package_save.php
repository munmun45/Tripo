<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/_packages_lib.php';

require_admin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_fail('Method not allowed', 405);
}

if (!table_exists('travel_packages')) {
    json_fail('travel_packages table missing — run migrate_admin.sql', 500);
}

ensure_package_extra_columns();

$in = body_json();
$id = trim((string) ($in['id'] ?? ''));
$title = trim((string) ($in['title'] ?? ''));
$city = trim((string) ($in['city'] ?? ''));
$country = trim((string) ($in['country'] ?? ''));
$imageUrl = trim((string) ($in['image_url'] ?? $in['imageUrl'] ?? ''));
$price = (float) ($in['price'] ?? 0);
$durationDays = max(1, (int) ($in['duration_days'] ?? $in['durationDays'] ?? 1));
$rating = (float) ($in['rating'] ?? 0);
$reviews = max(0, (int) ($in['reviews'] ?? 0));
$category = trim((string) ($in['category'] ?? ''));
$description = trim((string) ($in['description'] ?? ''));
$highlights = encode_string_list($in['highlights'] ?? []);
$includes = encode_string_list($in['includes'] ?? []);
$active = !empty($in['active']) ? 1 : 0;

if ($title === '' || $city === '' || $country === '') {
    json_fail('Title, city and country are required');
}

$isUpdate = $id !== '';
if (!$isUpdate) {
    $id = (string) time() . substr((string) mt_rand(100, 999), 0);
}

try {
    if ($isUpdate) {
        $check = db()->prepare('SELECT id FROM travel_packages WHERE id = ? LIMIT 1');
        $check->bind_param('s', $id);
        $check->execute();
        $exists = (bool) $check->get_result()->fetch_assoc();
        $check->close();
        if (!$exists) {
            json_fail('Package not found', 404);
        }

        $stmt = db()->prepare(
            'UPDATE travel_packages SET
                title=?, city=?, country=?, image_url=?, price=?, duration_days=?,
                rating=?, reviews=?, category=?, description=?, highlights=?, includes=?, active=?
             WHERE id=?'
        );
        $stmt->bind_param(
            'ssssdiddssssis',
            $title,
            $city,
            $country,
            $imageUrl,
            $price,
            $durationDays,
            $rating,
            $reviews,
            $category,
            $description,
            $highlights,
            $includes,
            $active,
            $id
        );
    } else {
        $stmt = db()->prepare(
            'INSERT INTO travel_packages
             (id, title, city, country, image_url, price, duration_days, rating, reviews, category, description, highlights, includes, active)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
        );
        $stmt->bind_param(
            'sssssdiddsssssi',
            $id,
            $title,
            $city,
            $country,
            $imageUrl,
            $price,
            $durationDays,
            $rating,
            $reviews,
            $category,
            $description,
            $highlights,
            $includes,
            $active
        );
    }

    $stmt->execute();
    $stmt->close();

    $sel = db()->prepare(
        'SELECT id, title, city, country, image_url, price, duration_days, rating, reviews, category, description, highlights, includes, active
         FROM travel_packages WHERE id = ? LIMIT 1'
    );
    $sel->bind_param('s', $id);
    $sel->execute();
    $row = $sel->get_result()->fetch_assoc();
    $sel->close();

    json_ok([
        'package' => package_row_to_api($row ?: []),
        'message' => $isUpdate ? 'Package updated' : 'Package created',
    ]);
} catch (Throwable $e) {
    json_fail('Save failed: ' . $e->getMessage(), 500);
}
