#requires -Version 5.1
param([switch]$NoPause)
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
Ensure-Admin

$cfgFile = Join-Path $Root "config.json"
if (-not (Test-Path $cfgFile)) { throw "config.json missing. Use docs\06_MANUAL_CLEANUP.txt and Steam file verification before normal multiplayer." }
$cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
$DayZ = [string]$cfg.DayZPath

$p = @(Get-DayZRelatedProcesses)
if ($p.Count -gt 0) {
    Write-Host "Cannot clean while a DayZ process is running." -ForegroundColor Red
    $p | Select-Object ProcessName,Id | Format-Table -AutoSize
    if (-not $NoPause) { pause }
    exit 2
}

foreach ($n in @(Get-DemoNames)) {
    $path = Join-Path $DayZ $n
    if (Test-Path $path) { Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue }
}
Get-ChildItem $DayZ -Filter "ReShade.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem $DayZ -Filter "dlss5-feed.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Remove-Item (Join-Path $Root "cleanup_pending.flag") -Force -ErrorAction SilentlyContinue
try { Unregister-ScheduledTask -TaskName "DayZDLSS5EmergencyCleanup" -Confirm:$false -ErrorAction SilentlyContinue } catch {}
try { Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "DayZDLSS5EmergencyCleanup" -ErrorAction SilentlyContinue } catch {}

$beOkay = (Test-Path (Join-Path $DayZ "DayZ_BE.exe")) -and (Test-Path (Join-Path $DayZ "BattlEye"))
$beModified = (Test-Path (Join-Path $DayZ "DayZ_BE.exe.disabled")) -or (Test-Path (Join-Path $DayZ "BattlEye.disabled"))
$left = @(Get-DemoFilesInDayZ $DayZ)

if ($left.Count -eq 0 -and $beOkay -and -not $beModified) {
    Write-Host "CLEAN: no known ReShade/DLSS5 demo hooks remain and BattlEye is in its normal Steam state." -ForegroundColor Green
    Write-Host "" 
    Write-Host "IMPORTANT: DO NOT RETURN TO BATTLEYE MULTIPLAYER YET." -ForegroundColor Red
    Write-Host "Final required step: verify DayZ through Steam:" -ForegroundColor Yellow
    Write-Host "  Steam -> Library -> DayZ -> Properties -> Installed Files" -ForegroundColor Cyan
    Write-Host "        -> Verify integrity of game files" -ForegroundColor Cyan
    Write-Host "Wait for verification/repair to finish before launching normal DayZ." -ForegroundColor Yellow
    Write-Host "This clean result is not an anti-cheat or ban-safety guarantee." -ForegroundColor Red
    $code = 0
} else {
    Write-Host "NOT CLEAN." -ForegroundColor Red
    Write-Host "DO NOT launch normal DayZ / BattlEye." -ForegroundColor Red
    if ($left.Count -gt 0) { $left | ForEach-Object { Write-Host "  Remaining: $_" } }
    if (-not $beOkay -or $beModified) { Write-Host "BattlEye is not in the normal state. Use Steam file verification before multiplayer." -ForegroundColor Red }
    $code = 3
}
if (-not $NoPause) { pause }
exit $code
