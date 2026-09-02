@echo off
setlocal
title DayZ DLSS5 Offline Demo Installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_PACKAGE.ps1"
if errorlevel 1 (
  echo.
  echo Package verification failed. Installation aborted.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL.ps1"
