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

function require_user(): array
{
    $token = bearer_token();
    if (!$token) {
        json_fail('Missing auth token', 401);
    }

    $sql = 'SELECT u.id, u.name, u.email, u.phone, t.token, t.expires_at
            FROM api_tokens t
            INNER JOIN users u ON u.id = t.user_id
            WHERE t.token = ? LIMIT 1';
    $stmt = db()->prepare($sql);
    $stmt->bind_param('s', $token);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    if (!$row) {
        json_fail('Invalid token', 401);
    }
    if (strtotime($row['expires_at']) < time()) {
        json_fail('Token expired — please login again', 401);
    }

    return [
        'id' => (int) $row['id'],
        'name' => $row['name'],
        'email' => $row['email'],
        'phone' => $row['phone'],
        'token' => $row['token'],
    ];
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
    ];
}
