#requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
$cfgFile = Join-Path $Root "config.json"
if (-not (Test-Path $cfgFile)) { Write-Host "Not installed yet (config.json missing)." -ForegroundColor Yellow; exit 1 }
$cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
$DayZ = [string]$cfg.DayZPath

Write-Banner "DAYZ DLSS5 OFFLINE DEMO STATUS"
Write-Host "DayZ: $DayZ"
Write-Host "DayZ version at install: $($cfg.DayZVersion)"
Write-Host ""

$found = @(Get-DemoFilesInDayZ $DayZ)
$beExe = Test-Path (Join-Path $DayZ "DayZ_BE.exe")
$beDir = Test-Path (Join-Path $DayZ "BattlEye")
$beModified = (Test-Path (Join-Path $DayZ "DayZ_BE.exe.disabled")) -or (Test-Path (Join-Path $DayZ "BattlEye.disabled"))
$pending = Test-Path (Join-Path $Root "cleanup_pending.flag")

if ($found.Count -eq 0 -and $beExe -and $beDir -and -not $beModified -and -not $pending) {
    Write-Host "STATE: MULTIPLAYER CLEAN" -ForegroundColor Green
    Write-Host "This means the known demo hook/add-on files are absent and BattlEye has its normal names." -ForegroundColor DarkGray
    Write-Host "It is not a promise from BattlEye or any server operator that no unrelated software can cause a kick/ban." -ForegroundColor DarkGray
    exit 0
}

Write-Host "STATE: NOT CLEAN / DEMO ACTIVE OR INTERRUPTED" -ForegroundColor Red
if ($pending) { Write-Host "Emergency cleanup marker is present." -ForegroundColor Yellow }
if ($found.Count -gt 0) {
    Write-Host "Demo files currently in DayZ:" -ForegroundColor Yellow
    $found | ForEach-Object { Write-Host "  $_" }
}
if (-not $beExe -or -not $beDir -or $beModified) { Write-Host "BattlEye is not in its normal Steam state." -ForegroundColor Red }
Write-Host "Run CLEAN_FOR_MULTIPLAYER.cmd before launching normal DayZ." -ForegroundColor Yellow
exit 2
