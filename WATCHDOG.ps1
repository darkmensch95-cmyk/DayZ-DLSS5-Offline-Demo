#requires -Version 5.1
param(
    [Parameter(Mandatory=$true)][int]$LauncherPid,
    [Parameter(Mandatory=$true)][int]$ClientPid
)
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
$Pending = Join-Path $Root "cleanup_pending.flag"

while ($true) {
    Start-Sleep -Milliseconds 250
    if (-not (Test-Path $Pending)) { exit 0 }

    $forbidden = @(Get-ForbiddenNormalDayZProcesses)
    if ($forbidden.Count -gt 0) {
        $forbidden | Stop-Process -Force -ErrorAction SilentlyContinue
        Get-CimInstance Win32_Process -Filter "Name='DayZDiag_x64.exe'" -ErrorAction SilentlyContinue |
            ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
        Start-Sleep -Milliseconds 500
        & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
        exit $LASTEXITCODE
    }

    $launcherAlive = Get-Process -Id $LauncherPid -ErrorAction SilentlyContinue
    $clientAlive = Get-Process -Id $ClientPid -ErrorAction SilentlyContinue

    if (-not $launcherAlive) {
        if ($clientAlive) { Stop-Process -Id $ClientPid -Force -ErrorAction SilentlyContinue }
        Get-CimInstance Win32_Process -Filter "Name='DayZDiag_x64.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -match '-server' } |
            ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
        Start-Sleep -Milliseconds 500
        & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
        exit $LASTEXITCODE
    }

    if (-not $clientAlive) {
        Start-Sleep -Seconds 3
        if (Test-Path $Pending) {
            & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
            exit $LASTEXITCODE
        }
        exit 0
    }
}
