<?php

function ensure_package_extra_columns(): void
{
    static $done = false;
    if ($done) {
        return;
    }
    $done = true;
    if (!table_exists('travel_packages')) {
        return;
    }
    try {
        if (!column_exists('travel_packages', 'highlights')) {
            db()->query('ALTER TABLE travel_packages ADD COLUMN highlights TEXT NULL AFTER description');
        }
    } catch (Throwable $e) {
        // ignore
    }
    try {
        if (!column_exists('travel_packages', 'includes')) {
            db()->query('ALTER TABLE travel_packages ADD COLUMN includes TEXT NULL AFTER highlights');
        }
    } catch (Throwable $e) {
        // ignore
    }
}

/** @return list<string> */
function decode_string_list(?string $raw): array
{
    if ($raw === null || trim($raw) === '') {
        return [];
    }
    $decoded = json_decode($raw, true);
    if (is_array($decoded)) {
        return array_values(array_filter(array_map('strval', $decoded), fn ($s) => trim($s) !== ''));
    }
    // fallback: newline / comma separated
    $parts = preg_split('/[\r\n,]+/', $raw) ?: [];
    return array_values(array_filter(array_map('trim', $parts), fn ($s) => $s !== ''));
}

function encode_string_list($value): string
{
    if (is_string($value)) {
        $list = decode_string_list($value);
    } elseif (is_array($value)) {
        $list = array_values(array_filter(array_map('strval', $value), fn ($s) => trim($s) !== ''));
    } else {
        $list = [];
    }
    return json_encode($list, JSON_UNESCAPED_UNICODE);
}

function package_row_to_api(array $row): array
{
    return [
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
        'description' => $row['description'] ?? '',
        'highlights' => decode_string_list($row['highlights'] ?? null),
        'includes' => decode_string_list($row['includes'] ?? null),
        'active' => (int) ($row['active'] ?? 1) === 1,
    ];
}

function destination_cities(): array
{
    return [
        ['name' => 'Goa', 'country' => 'India'],
        ['name' => 'Dubai', 'country' => 'UAE'],
        ['name' => 'Paris', 'country' => 'France'],
        ['name' => 'Bali', 'country' => 'Indonesia'],
        ['name' => 'Mumbai', 'country' => 'India'],
        ['name' => 'Delhi', 'country' => 'India'],
        ['name' => 'Bengaluru', 'country' => 'India'],
        ['name' => 'Tokyo', 'country' => 'Japan'],
        ['name' => 'New York', 'country' => 'USA'],
        ['name' => 'London', 'country' => 'UK'],
        ['name' => 'Singapore', 'country' => 'Singapore'],
        ['name' => 'Santorini', 'country' => 'Greece'],
        ['name' => 'Kyoto', 'country' => 'Japan'],
        ['name' => 'Ubud', 'country' => 'Indonesia'],
        ['name' => 'Interlaken', 'country' => 'Switzerland'],
        ['name' => 'Male', 'country' => 'Maldives'],
        ['name' => 'Reykjavik', 'country' => 'Iceland'],
        ['name' => 'Manali', 'country' => 'India'],
        ['name' => 'Banff', 'country' => 'Canada'],
        ['name' => 'Jasper', 'country' => 'Canada'],
        ['name' => 'Calgary', 'country' => 'Canada'],
    ];
}
