@echo off
setlocal EnableExtensions
title DayZ DLSS5 Offline Demo

set "INSTROOT=C:\DayZ_DLSS5_OFFLINE_DEMO"

rem This CMD exists both in the downloaded repository and in the installed app.
rem config.json only exists after INSTALL.cmd has completed successfully.
if not exist "%~dp0config.json" (
    if exist "%INSTROOT%\config.json" if exist "%INSTROOT%\START_OFFLINE_DEMO.cmd" (
        echo This is the downloaded/source folder, not the installed demo.
        echo Starting the installed copy from:
        echo   %INSTROOT%
        echo.
        call "%INSTROOT%\START_OFFLINE_DEMO.cmd"
        exit /b %ERRORLEVEL%
    )

    echo ============================================================
    echo DAYZ DLSS5 OFFLINE DEMO IS NOT INSTALLED YET
    echo ============================================================
    echo.
    echo You are running START_OFFLINE_DEMO.cmd from the downloaded
    echo repository folder:
    echo   %~dp0
    echo.
    echo Run INSTALL.cmd from this folder first.
    echo The installer will create:
    echo   %INSTROOT%
    echo.
    echo After installation you can start the demo either from the
    echo installed folder or by clicking this file again.
    echo.
    pause
    exit /b 2
)

rem The installed PowerShell launcher requires administrator rights because it
rem temporarily stages files into the DayZ installation and creates a recovery task.
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
