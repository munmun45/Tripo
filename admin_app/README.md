# Tripo Admin (Windows)

Desktop admin panel for Tripo users & stats.

## Run on Windows

```bash
flutter pub get
flutter run -d windows -t lib/admin_app/main.dart
```

## Build .exe

```bash
flutter build windows -t lib/admin_app/main.dart
```

Output: `build/windows/x64/runner/Release/tripo.exe`  
(You can rename the shortcut to **Tripo Admin**.)

## Server setup (required)

1. Upload latest `api/` folder (includes `admin/`).
2. Run in phpMyAdmin: `api/sql/migrate_admin.sql`
3. Seed passwords if needed: `.../tools/seed_passwords.php` (then delete it)

## Admin login

- Phone: `9876543210`
- Password: `Tripo@123`

(Only users with `is_admin = 1` can open this panel.)

## Features

- Dashboard counts (users, admins, saved packages, notes, sessions)
- Users list + search
- Delete non-admin users
