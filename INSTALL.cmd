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

rem A previous beta or a failed partial install may already exist.
if exist "%APPROOT%\" goto EXISTING_INSTALL
goto RUN_INSTALL

:EXISTING_INSTALL
echo.
echo ============================================================
echo EXISTING DAYZ DLSS5 OFFLINE DEMO DATA DETECTED
echo ============================================================
echo %APPROOT%
echo.

rem Complete installation: use its own cleanup tool before replacing it.
if exist "%APPROOT%\config.json" if exist "%APPROOT%\COMMON.ps1" if exist "%APPROOT%\CLEAN_FOR_MULTIPLAYER.ps1" goto COMPLETE_INSTALL

rem Partial installation: INSTALL.ps1 creates payload/cache/install.log before config.json.
rem Only recognize this narrow shape; unknown folders are never auto-deleted.
if exist "%APPROOT%\install.log" if exist "%APPROOT%\payload\" if exist "%APPROOT%\cache\" goto PARTIAL_INSTALL
goto UNKNOWN_EXISTING

:COMPLETE_INSTALL
echo A previous complete project installation was found.
echo The installer will run its cleanup tool first, verify success, remove the
echo old project folder, and then install this build fresh.
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

:PARTIAL_INSTALL
echo A previous installer run failed before installation completed.
echo No config.json exists yet, so this is treated as a PARTIAL install.
echo.
echo Before deleting it, the current source tools will verify that:
echo   - no DayZ-related process is running,
echo   - BattlEye is in its normal Steam state,
echo   - no known DLSS5/ReShade demo payload is left in the DayZ root.
echo.
set /p "PARTIAL=Type exactly RETRY to remove the partial install and retry: "
if /I not "%PARTIAL%"=="RETRY" goto UPGRADE_CANCELLED

echo.
echo Verifying DayZ is clean before removing the partial project folder...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0COMMON.ps1'; Ensure-DayZClosed; $d=Find-DayZInstall ''; Assert-BattlEyeNormal $d; $left=@(Get-DemoFilesInDayZ $d); if($left.Count -gt 0){ Write-Host 'Known demo files are still present in the DayZ root:' -ForegroundColor Red; foreach($item in $left){ Write-Host ('  ' + $item) -ForegroundColor Red }; exit 31 }; Write-Host 'DayZ root check passed.' -ForegroundColor Green; exit 0"
if errorlevel 1 goto PARTIAL_CLEAN_FAILED

rmdir /s /q "%APPROOT%"
if exist "%APPROOT%\" goto OLD_REMOVE_FAILED

echo Partial installation removed safely.
echo.
goto RUN_INSTALL

:UNKNOWN_EXISTING
echo ERROR: %APPROOT% exists, but it does not match either a complete installation
echo or the known shape of a failed partial installation from this project.
echo It will NOT be deleted automatically.
echo.
echo Inspect or rename/delete that folder manually, then run INSTALL.cmd again.
echo Nothing in the folder was changed.
echo.
pause
exit /b 20

:UPGRADE_CANCELLED
echo.
echo Upgrade/retry cancelled. Nothing was changed.
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

:PARTIAL_CLEAN_FAILED
echo.
echo ============================================================
echo RETRY ABORTED - DAYZ CLEAN-STATE CHECK FAILED
echo ============================================================
echo The partial project folder was NOT deleted.
echo DO NOT launch normal DayZ / BattlEye until the reported problem is resolved.
echo.
pause
exit /b 23

:OLD_REMOVE_FAILED
echo.
echo ERROR: the project folder could not be removed:
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
