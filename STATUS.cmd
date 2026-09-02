@echo off
setlocal
title DayZ DLSS5 - STATUS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0STATUS.ps1"
echo.
pause
