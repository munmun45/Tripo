@echo off
REM Tripo app — Windows (skip broken Flutter debugger)
cd /d "%~dp0"

echo Building Tripo for Windows (release)...
call flutter build windows --release
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

echo Starting Tripo...
start "" "%EXE%"
exit /b 0
