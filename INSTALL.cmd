@echo off
setlocal EnableExtensions
title DayZ DLSS5 Offline Demo Installer

rem INSTALL.ps1 requires administrator rights. Self-elevate when launched by double-click.
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo ERROR: Could not request administrator privileges.
        pause
    )
    exit /b
)

echo Starting installer...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
    echo.
    echo ============================================================
    echo INSTALLATION FAILED - PowerShell exit code: %RC%
    echo ============================================================
    echo The window is being kept open so the error above can be read.
    echo.
    pause
)

exit /b %RC%
