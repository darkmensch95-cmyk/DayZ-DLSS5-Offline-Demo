@echo off
setlocal EnableExtensions
title DayZ DLSS5 Offline Demo

rem The PowerShell launcher requires administrator rights because it stages
rem temporary files into the DayZ installation and creates the recovery task.
rem Self-elevate instead of silently failing when launched by double-click.
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

echo Starting DayZ DLSS5 Offline Demo...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0START_OFFLINE_DEMO.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
    echo.
    echo ============================================================
    echo OFFLINE DEMO FAILED - PowerShell exit code: %RC%
    echo ============================================================
    echo The window is being kept open so the error above can be read.
    echo.
    pause
)

exit /b %RC%
