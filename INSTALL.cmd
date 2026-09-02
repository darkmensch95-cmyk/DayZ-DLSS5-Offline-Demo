@echo off
setlocal EnableExtensions
title DayZ DLSS5 Offline Demo Installer

set "APPROOT=C:\DayZ_DLSS5_OFFLINE_DEMO"

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

rem A previous beta may already be installed. Do not just fail and make the user
rem manually untangle it. Only auto-upgrade a folder that clearly belongs to this project.
if exist "%APPROOT%\" goto EXISTING_INSTALL
goto RUN_INSTALL

:EXISTING_INSTALL
echo.
echo ============================================================
echo EXISTING DAYZ DLSS5 OFFLINE DEMO INSTALLATION DETECTED
echo ============================================================
echo %APPROOT%
echo.

if not exist "%APPROOT%\config.json" goto UNKNOWN_EXISTING
if not exist "%APPROOT%\COMMON.ps1" goto UNKNOWN_EXISTING
if not exist "%APPROOT%\CLEAN_FOR_MULTIPLAYER.ps1" goto UNKNOWN_EXISTING

echo The installer can safely replace the previous project installation.
echo It will first run the OLD installation's cleanup tool, verify that cleanup

echo succeeds, then remove the old project folder and install the new build.
echo.
echo BattlEye itself will NOT be renamed, disabled, patched or deleted.
echo Existing demo session logs inside %APPROOT% will be removed with the old install.
echo.
set /p "UPGRADE=Type exactly UPGRADE to continue: "
if /I not "%UPGRADE%"=="UPGRADE" goto UPGRADE_CANCELLED

echo.
echo Cleaning any staged files from the previous installation...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%APPROOT%\CLEAN_FOR_MULTIPLAYER.ps1" -NoPause
if errorlevel 1 goto OLD_CLEAN_FAILED

echo.
echo Previous DayZ demo files were cleaned successfully.
echo Removing old project installation...
rmdir /s /q "%APPROOT%"
if exist "%APPROOT%\" goto OLD_REMOVE_FAILED

echo Old installation removed.
echo.
goto RUN_INSTALL

:UNKNOWN_EXISTING
echo ERROR: %APPROOT% exists, but it does not look like a complete installation

echo of this project. It will NOT be deleted automatically.
echo.
echo Inspect or rename/delete that folder manually, then run INSTALL.cmd again.
echo Nothing in the folder was changed.
echo.
pause
exit /b 20

:UPGRADE_CANCELLED
echo.
echo Upgrade cancelled. Nothing was changed.
pause
exit /b 0

:OLD_CLEAN_FAILED
echo.
echo ============================================================
echo UPGRADE ABORTED - OLD INSTALLATION COULD NOT BE CLEANED

echo ============================================================
echo DO NOT delete the old installation yet.
echo DO NOT launch normal DayZ / BattlEye until the cleanup problem is resolved.
echo Run the old STATUS.cmd / CLEAN_FOR_MULTIPLAYER.cmd and inspect its output.
echo.
pause
exit /b 21

:OLD_REMOVE_FAILED
echo.
echo ERROR: cleanup succeeded, but the old project folder could not be removed:
echo %APPROOT%
echo.
echo Close any Explorer/editor window using files from that folder and try again.
echo.
pause
exit /b 22

:RUN_INSTALL
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
