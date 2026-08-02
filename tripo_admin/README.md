# Tripo Admin

Admin-only Flutter panel for Tripo. Shows:

1. **Users** — registered accounts (search by name / phone)
2. **Travel packages** — catalog grouped **city-wise**

Non-admin accounts cannot sign in.

## Setup (server)

1. Upload latest `api/` (especially `includes/bootstrap.php`, `auth/login.php`, `admin/*`, `tools/ensure_admin_schema.php`).
2. Open once in browser:  
   `https://munmunmaharana.in/tripo/api/tools/ensure_admin_schema.php`  
   - Creates `is_admin`, `travel_packages`, seeds city packages, marks demo admins.  
   - Then **delete** that file from the server.
3. (Optional) Open `tools/seed_passwords.php` once to reset password to `Tripo@123`, then delete it.

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
