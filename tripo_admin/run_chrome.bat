@echo off
REM Windows Smart App Control blocks unsigned Flutter .exe files.
REM Run admin panel in Chrome instead.
cd /d "%~dp0"
flutter run -d chrome --web-port=5173
