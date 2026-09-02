@echo off
setlocal
title DayZ DLSS5 - SELF TEST
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0SELF_TEST.ps1" -DeepStage
echo.
pause
