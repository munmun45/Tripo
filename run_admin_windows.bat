@echo off
REM Tripo Admin — Windows (no Flutter debugger)
cd /d "%~dp0"

echo Building Tripo Admin for Windows...
call flutter build windows -t lib/admin_app/main.dart --release
if errorlevel 1 (
  echo Build failed.
  pause
  exit /b 1
)

set EXE=build\windows\x64\runner\Release\tripo.exe
if not exist "%EXE%" (
  echo EXE not found: %EXE%
  pause
  exit /b 1
)

echo Starting Admin panel...
start "" "%EXE%"
echo Done. Login with admin phone 9876543210 / Tripo@123
exit /b 0
