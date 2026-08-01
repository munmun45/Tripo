# Tripo Admin

Admin-only Flutter panel for Tripo. Shows:

1. **Users** — registered accounts (search by name / phone)
2. **Travel packages** — catalog grouped **city-wise**

Non-admin accounts cannot sign in.

## Setup (server)

1. Upload latest `api/` (especially `includes/bootstrap.php`, `auth/login.php`, `admin/*`, `sql/migrate_admin.sql`).
2. In phpMyAdmin, run `api/sql/migrate_admin.sql`  
   - If `is_admin` already exists, skip that `ALTER` and run the rest.
3. Open once: `https://munmunmaharana.in/tripo/api/tools/seed_passwords.php`  
   - Sets password `Tripo@123` and `is_admin = 1` for demo phones.  
   - Then **delete** `seed_passwords.php` from the server.

## Run locally

Windows Smart App Control may block the Windows EXE. Prefer Chrome:

```bat
cd tripo_admin
flutter pub get
flutter run -d chrome
```

Or double-click `run_chrome.bat`.

## Login

| Phone       | Password  |
|-------------|-----------|
| 9876543210  | Tripo@123 |
| 9999999999  | Tripo@123 |

API base: `https://munmunmaharana.in/tripo/api`
