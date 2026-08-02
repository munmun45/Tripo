<?php
/**
 * Shared helpers: CORS, JSON responses, mysqli, auth token.
 */

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Api-Token');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function cfg(): array
{
    static $cfg;
    if ($cfg === null) {
        $cfg = require __DIR__ . '/../config/db.php';
    }
    return $cfg;
}

function db(): mysqli
{
    static $mysqli;
    if ($mysqli instanceof mysqli) {
        return $mysqli;
    }

    $c = cfg();
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $mysqli = new mysqli(
        $c['host'],
        $c['user'],
        $c['pass'],
        $c['name'],
        (int) ($c['port'] ?? 3306)
    );
    $mysqli->set_charset($c['charset'] ?? 'utf8mb4');
    return $mysqli;
}

function json_ok(array $data = [], int $code = 200): void
{
    http_response_code($code);
    echo json_encode(['ok' => true] + $data, JSON_UNESCAPED_UNICODE);
    exit;
}

function json_fail(string $message, int $code = 400, array $extra = []): void
{
    http_response_code($code);
    echo json_encode(['ok' => false, 'message' => $message] + $extra, JSON_UNESCAPED_UNICODE);
    exit;
}

function body_json(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return $_POST ?: [];
    }
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function bearer_token(): ?string
{
    $hdr = $_SERVER['HTTP_AUTHORIZATION']
        ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
        ?? '';
    if (preg_match('/Bearer\s+(\S+)/i', $hdr, $m)) {
        return $m[1];
    }
    $alt = $_SERVER['HTTP_X_API_TOKEN'] ?? '';
    return $alt !== '' ? $alt : null;
}

function table_exists(string $table): bool
{
    static $cache = [];
    if (array_key_exists($table, $cache)) {
        return $cache[$table];
    }
    try {
        $safe = db()->real_escape_string($table);
        $res = db()->query("SHOW TABLES LIKE '{$safe}'");
        $cache[$table] = $res instanceof mysqli_result && $res->num_rows > 0;
        if ($res instanceof mysqli_result) {
            $res->free();
        }
    } catch (Throwable $e) {
        $cache[$table] = false;
    }
    return $cache[$table];
}

function column_exists(string $table, string $column): bool
{
    static $cache = [];
    $key = $table . '.' . $column;
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }
    try {
        $stmt = db()->prepare(
            'SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
             LIMIT 1'
        );
        $stmt->bind_param('ss', $table, $column);
        $stmt->execute();
        $row = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        $cache[$key] = (bool) $row;
    } catch (Throwable $e) {
        $cache[$key] = false;
    }
    return $cache[$key];
}

function require_user(): array
{
    $token = bearer_token();
    if (!$token) {
        json_fail('Missing auth token', 401);
    }

    $hasAdmin = column_exists('users', 'is_admin');
    $adminCol = $hasAdmin ? ', u.is_admin' : ', 0 AS is_admin';
    $hasActive = column_exists('users', 'is_active');
    $activeCol = $hasActive ? ', u.is_active' : ', 1 AS is_active';
    $sql = "SELECT u.id, u.name, u.email, u.phone{$adminCol}{$activeCol}, t.token, t.expires_at
            FROM api_tokens t
            INNER JOIN users u ON u.id = t.user_id
            WHERE t.token = ? LIMIT 1";

    try {
        $stmt = db()->prepare($sql);
        $stmt->bind_param('s', $token);
        $stmt->execute();
        $row = $stmt->get_result()->fetch_assoc();
        $stmt->close();
    } catch (Throwable $e) {
        json_fail('Auth query failed: ' . $e->getMessage(), 500);
    }

    if (!$row) {
        json_fail('Invalid token', 401);
    }
    if (strtotime($row['expires_at']) < time()) {
        json_fail('Token expired — please login again', 401);
    }
    if ((int) ($row['is_active'] ?? 1) !== 1) {
        json_fail('Account is deactivated', 403);
    }

    $user = [
        'id' => (int) $row['id'],
        'name' => $row['name'],
        'email' => $row['email'],
        'phone' => $row['phone'],
        'is_admin' => (int) ($row['is_admin'] ?? 0) === 1,
        'token' => $row['token'],
    ];

    track_user_activity($user['id'], $user['token']);

    return $user;
}

/** Record DAU + last_seen when any authenticated API call succeeds. */
function track_user_activity(int $userId, string $token): void
{
    static $ensured = false;
    if (!$ensured) {
        $ensured = true;
        try {
            if (!column_exists('api_tokens', 'last_seen_at')) {
                db()->query(
                    'ALTER TABLE api_tokens ADD COLUMN last_seen_at DATETIME NULL DEFAULT NULL'
                );
            }
        } catch (Throwable $e) {
            // ignore
        }
        try {
            if (!table_exists('app_activity')) {
                db()->query(
                    'CREATE TABLE IF NOT EXISTS app_activity (
                        id INT UNSIGNED NOT NULL AUTO_INCREMENT,
                        user_id INT UNSIGNED NOT NULL,
                        activity_date DATE NOT NULL,
                        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY uq_user_day (user_id, activity_date),
                        KEY idx_activity_date (activity_date),
                        CONSTRAINT fk_activity_user
                          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
                     ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
                );
            }
        } catch (Throwable $e) {
            // ignore
        }
    }

    try {
        if (column_exists('api_tokens', 'last_seen_at')) {
            $stmt = db()->prepare(
                'UPDATE api_tokens SET last_seen_at = NOW() WHERE token = ? LIMIT 1'
            );
            $stmt->bind_param('s', $token);
            $stmt->execute();
            $stmt->close();
        }
    } catch (Throwable $e) {
        // ignore
    }

    try {
        if (table_exists('app_activity')) {
            $stmt = db()->prepare(
                'INSERT IGNORE INTO app_activity (user_id, activity_date) VALUES (?, CURDATE())'
            );
            $stmt->bind_param('i', $userId);
            $stmt->execute();
            $stmt->close();
        }
    } catch (Throwable $e) {
        // ignore
    }
}

function require_admin(): array
{
    $user = require_user();
    if (empty($user['is_admin'])) {
        json_fail('Admin access required', 403);
    }
    return $user;
}

function issue_token(int $userId): string
{
    $token = bin2hex(random_bytes(32));
    $days = (int) (cfg()['token_days'] ?? 30);
    $expires = (new DateTimeImmutable("+{$days} days"))->format('Y-m-d H:i:s');

    $stmt = db()->prepare(
        'INSERT INTO api_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
    );
    $stmt->bind_param('iss', $userId, $token, $expires);
    $stmt->execute();
    $stmt->close();
    return $token;
}

function user_public(array $u): array
{
    return [
        'id' => (int) $u['id'],
        'name' => $u['name'],
        'email' => $u['email'],
        'phone' => $u['phone'] ?? null,
        'is_admin' => !empty($u['is_admin']),
    ];
}
