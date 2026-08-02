<?php
require_once __DIR__ . '/../includes/bootstrap.php';

require_admin();

try {
    $db = db();

    $totalUsers = (int) ($db->query('SELECT COUNT(*) AS c FROM users')->fetch_assoc()['c'] ?? 0);

    $admins = 0;
    if (column_exists('users', 'is_admin')) {
        $admins = (int) ($db->query('SELECT COUNT(*) AS c FROM users WHERE is_admin = 1')->fetch_assoc()['c'] ?? 0);
    }

    $newToday = (int) ($db->query(
        'SELECT COUNT(*) AS c FROM users WHERE DATE(created_at) = CURDATE()'
    )->fetch_assoc()['c'] ?? 0);

    $newMonth = (int) ($db->query(
        'SELECT COUNT(*) AS c FROM users
         WHERE YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())'
    )->fetch_assoc()['c'] ?? 0);

    $newYear = (int) ($db->query(
        'SELECT COUNT(*) AS c FROM users WHERE YEAR(created_at) = YEAR(CURDATE())'
    )->fetch_assoc()['c'] ?? 0);

    $activeToday = 0;
    $activeWeek = 0;
    $activeMonth = 0;

    if (table_exists('app_activity')) {
        $activeToday = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM app_activity WHERE activity_date = CURDATE()'
        )->fetch_assoc()['c'] ?? 0);
        $activeWeek = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM app_activity
             WHERE activity_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)'
        )->fetch_assoc()['c'] ?? 0);
        $activeMonth = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM app_activity
             WHERE activity_date >= DATE_FORMAT(CURDATE(), \'%Y-%m-01\')'
        )->fetch_assoc()['c'] ?? 0);
    } elseif (column_exists('api_tokens', 'last_seen_at')) {
        $activeToday = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens
             WHERE DATE(last_seen_at) = CURDATE()'
        )->fetch_assoc()['c'] ?? 0);
        $activeWeek = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens
             WHERE last_seen_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)'
        )->fetch_assoc()['c'] ?? 0);
        $activeMonth = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens
             WHERE last_seen_at >= DATE_FORMAT(CURDATE(), \'%Y-%m-01\')'
        )->fetch_assoc()['c'] ?? 0);
    } else {
        // Fallback: sessions created today / week / month
        $activeToday = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens WHERE DATE(created_at) = CURDATE()'
        )->fetch_assoc()['c'] ?? 0);
        $activeWeek = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens
             WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)'
        )->fetch_assoc()['c'] ?? 0);
        $activeMonth = (int) ($db->query(
            'SELECT COUNT(DISTINCT user_id) AS c FROM api_tokens
             WHERE created_at >= DATE_FORMAT(CURDATE(), \'%Y-%m-01\')'
        )->fetch_assoc()['c'] ?? 0);
    }

    // Last 14 days: active users + new signups
    $daily = [];
    for ($i = 13; $i >= 0; $i--) {
        $daily[date('Y-m-d', strtotime("-{$i} days"))] = [
            'date' => date('Y-m-d', strtotime("-{$i} days")),
            'label' => date('d M', strtotime("-{$i} days")),
            'active' => 0,
            'signups' => 0,
        ];
    }

    if (table_exists('app_activity')) {
        $res = $db->query(
            'SELECT activity_date AS d, COUNT(DISTINCT user_id) AS c
             FROM app_activity
             WHERE activity_date >= DATE_SUB(CURDATE(), INTERVAL 13 DAY)
             GROUP BY activity_date'
        );
        while ($row = $res->fetch_assoc()) {
            $d = $row['d'];
            if (isset($daily[$d])) {
                $daily[$d]['active'] = (int) $row['c'];
            }
        }
    }

    $res = $db->query(
        'SELECT DATE(created_at) AS d, COUNT(*) AS c
         FROM users
         WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY)
         GROUP BY DATE(created_at)'
    );
    while ($row = $res->fetch_assoc()) {
        $d = $row['d'];
        if (isset($daily[$d])) {
            $daily[$d]['signups'] = (int) $row['c'];
        }
    }

    // Last 12 months signups
    $monthly = [];
    for ($i = 11; $i >= 0; $i--) {
        $key = date('Y-m', strtotime(date('Y-m-01') . " -{$i} months"));
        $monthly[$key] = [
            'month' => $key,
            'label' => date('M y', strtotime($key . '-01')),
            'signups' => 0,
        ];
    }
    $res = $db->query(
        'SELECT DATE_FORMAT(created_at, \'%Y-%m\') AS m, COUNT(*) AS c
         FROM users
         WHERE created_at >= DATE_SUB(DATE_FORMAT(CURDATE(), \'%Y-%m-01\'), INTERVAL 11 MONTH)
         GROUP BY DATE_FORMAT(created_at, \'%Y-%m\')'
    );
    while ($row = $res->fetch_assoc()) {
        $m = $row['m'];
        if (isset($monthly[$m])) {
            $monthly[$m]['signups'] = (int) $row['c'];
        }
    }

    // Yearly totals (last 5 years)
    $yearly = [];
    $res = $db->query(
        'SELECT YEAR(created_at) AS y, COUNT(*) AS c
         FROM users
         GROUP BY YEAR(created_at)
         ORDER BY y DESC
         LIMIT 5'
    );
    while ($row = $res->fetch_assoc()) {
        $yearly[] = [
            'year' => (int) $row['y'],
            'users' => (int) $row['c'],
        ];
    }
    $yearly = array_reverse($yearly);

    $packages = 0;
    $cities = 0;
    if (table_exists('travel_packages')) {
        $packages = (int) ($db->query('SELECT COUNT(*) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
        $cities = (int) ($db->query('SELECT COUNT(DISTINCT city) AS c FROM travel_packages')->fetch_assoc()['c'] ?? 0);
    }

    $saved = 0;
    if (table_exists('saved_packages')) {
        $saved = (int) ($db->query('SELECT COUNT(*) AS c FROM saved_packages')->fetch_assoc()['c'] ?? 0);
    }

    $notes = 0;
    if (table_exists('notes')) {
        $notes = (int) ($db->query('SELECT COUNT(*) AS c FROM notes')->fetch_assoc()['c'] ?? 0);
    }

    $recent = [];
    $hasAdmin = column_exists('users', 'is_admin');
    $adminSelect = $hasAdmin ? 'is_admin' : '0 AS is_admin';
    $stmt = $db->prepare(
        "SELECT id, name, phone, {$adminSelect}, created_at
         FROM users ORDER BY id DESC LIMIT 8"
    );
    $stmt->execute();
    $r = $stmt->get_result();
    while ($row = $r->fetch_assoc()) {
        $recent[] = [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'phone' => $row['phone'],
            'is_admin' => (int) $row['is_admin'] === 1,
            'created_at' => $row['created_at'],
        ];
    }
    $stmt->close();

    json_ok([
        'dashboard' => [
            'total_users' => $totalUsers,
            'admins' => $admins,
            'new_today' => $newToday,
            'new_month' => $newMonth,
            'new_year' => $newYear,
            'active_today' => $activeToday,
            'active_week' => $activeWeek,
            'active_month' => $activeMonth,
            'packages' => $packages,
            'cities' => $cities,
            'saved' => $saved,
            'notes' => $notes,
            'daily' => array_values($daily),
            'monthly' => array_values($monthly),
            'yearly' => $yearly,
            'recent_users' => $recent,
        ],
    ]);
} catch (Throwable $e) {
    json_fail('Dashboard failed: ' . $e->getMessage(), 500);
}
