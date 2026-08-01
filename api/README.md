# Tripo API (MySQLi) — deploy to `https://munmunmaharana.in/tripo/api`

## Capacity
Yes — this stack comfortably handles **~100 concurrent app users** for Tripo
(login, saved packages, notes). Use InnoDB, prepared statements, and shared hosting
MySQL. For heavier load later: PHP-FPM + connection pooling / Redis.

## Upload
1. Create MySQL database (e.g. `tripo_db`) in cPanel.
2. Import `sql/tripo.sql`.
3. Edit `config/db.php` with host / db name / user / password.
4. Upload the whole `api/` folder to:
   `public_html/tripo/api/`
   so URLs look like:
   `http://munmunmaharana.in/tripo/api/health.php`
5. Open once: `http://munmunmaharana.in/tripo/api/tools/seed_passwords.php`
   then **delete** that file.
6. Test: `http://munmunmaharana.in/tripo/api/health.php`

## Demo login (after seed)
- Email: `demo@tripo.app`
- Password: `Tripo@123`

## Main endpoints
| Method | Path | Auth |
|--------|------|------|
| GET | `/health.php` | no |
| POST | `/auth/register.php` | no |
| POST | `/auth/login.php` | no |
| GET | `/auth/me.php` | Bearer token |
| POST | `/auth/logout.php` | Bearer token |
| GET | `/packages/saved.php` | Bearer token |
| POST | `/packages/saved_toggle.php` | Bearer token |
| GET | `/notes/list.php` | Bearer token |
| POST | `/notes/save.php` | Bearer token |
| POST | `/notes/delete.php` | Bearer token |

Auth header: `Authorization: Bearer <token>`

## Example login body
```json
{ "email": "demo@tripo.app", "password": "Tripo@123" }
```
