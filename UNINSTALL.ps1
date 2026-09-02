#requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
Ensure-Admin
Ensure-DayZClosed

$cfgFile = Join-Path $Root "config.json"
if (Test-Path $cfgFile) {
    & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Cleanup did not report a clean state. Do NOT delete this folder yet; use Steam file verification/manual cleanup." -ForegroundColor Red
        pause
        exit $LASTEXITCODE
    }
}
Write-Host "DayZ cleanup passed." -ForegroundColor Green
Write-Host "You can now close this window and delete: $Root" -ForegroundColor Yellow
Write-Host "The script does not self-delete to keep the cleanup log/tools available until you confirm." -ForegroundColor DarkGray
Pause
