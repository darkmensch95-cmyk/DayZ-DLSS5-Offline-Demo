@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_PACKAGE.ps1"
echo.
pause
