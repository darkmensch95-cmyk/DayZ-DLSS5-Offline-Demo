#requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
Ensure-Admin
Ensure-DayZClosed

$cfgFile = Join-Path $Root "config.json"
if (Test-Path $cfgFile) {
    & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Cleanup did not report a clean state." -ForegroundColor Red
        Write-Host "DO NOT launch normal DayZ / BattlEye." -ForegroundColor Red
        Write-Host "Use the manual cleanup guide and Steam file verification before multiplayer." -ForegroundColor Red
        pause
        exit $LASTEXITCODE
    }
}

Write-Host "" 
Write-Host "DayZ cleanup passed for the files known to this project." -ForegroundColor Green
Write-Host "" 
Write-Host "IMPORTANT - DO NOT RETURN TO BATTLEYE MULTIPLAYER YET." -ForegroundColor Red
Write-Host "Before launching normal DayZ, verify the game installation in Steam:" -ForegroundColor Yellow
Write-Host "  Steam -> Library -> DayZ -> Properties -> Installed Files" -ForegroundColor Cyan
Write-Host "        -> Verify integrity of game files" -ForegroundColor Cyan
Write-Host "Wait for Steam verification/repair to finish completely." -ForegroundColor Yellow
Write-Host "" 
Write-Host "A successful cleanup is NOT an anti-cheat or ban-safety guarantee." -ForegroundColor Red
Write-Host "Launching normal DayZ/BattlEye with leftover hook/add-on files may result in anti-cheat action, including a possible ban." -ForegroundColor Red
Write-Host "" 
Write-Host "After Steam verification is complete, you can delete: $Root" -ForegroundColor Yellow
Write-Host "The script does not self-delete so the cleanup/status tools remain available until you confirm everything is clean." -ForegroundColor DarkGray
Pause
