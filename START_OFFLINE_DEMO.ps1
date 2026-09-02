#requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")
Ensure-Admin
Ensure-DayZClosed

$cfg = Get-Content (Join-Path $Root "config.json") -Raw | ConvertFrom-Json
$DayZ = [string]$cfg.DayZPath
$Diag = [string]$cfg.DiagExe
$LocalHost = [string]$cfg.LocalHostPath
$Payload = Join-Path $Root "payload"
$LogsRoot = Join-Path $Root "logs"
$Pending = Join-Path $Root "cleanup_pending.flag"

Clear-Host
Write-Banner "OFFLINE / LOCAL DAYZDIAG DEMO ONLY" Red
Write-Host "This launcher temporarily places ReShade Full Add-on + DLSS5 hook files next to DayZ." -ForegroundColor Yellow
Write-Host "It starts ONLY DayZDiag_x64.exe against a localhost DayZDiag server." -ForegroundColor Yellow
Write-Host "It actively aborts if normal DayZ, DayZ_BE or the normal DayZ launcher appears while the payload is staged." -ForegroundColor Green
Write-Host ""
Write-Host "DO NOT CONNECT TO ANY PUBLIC / OFFICIAL / COMMUNITY / BATTLEYE-PROTECTED SERVER." -ForegroundColor Red
Write-Host "The safety interlocks reduce accidental misuse; they are not an anti-cheat guarantee." -ForegroundColor Red
$confirm = Read-Host "Type exactly: OFFLINE"
if ($confirm -cne "OFFLINE") { throw "Offline confirmation not accepted." }

Assert-BattlEyeNormal $DayZ
if ((Test-Path $Pending) -or (@(Get-DemoFilesInDayZ $DayZ).Count -gt 0)) {
    Write-Host "Stale demo files detected. Running emergency cleanup first..." -ForegroundColor Yellow
    & (Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1") -NoPause
    if ($LASTEXITCODE -ne 0) { throw "Could not establish a clean starting state." }
}
Assert-DayZRootClean $DayZ

$sessionDir = Join-Path $LogsRoot (Get-Date -Format "yyyyMMdd_HHmmss")
New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null
$serverWindow = $null
$client = $null
$serverPids = @()
$watchdog = $null

function Register-EmergencyCleanup {
    New-Item -ItemType File -Force -Path $Pending | Out-Null
    try {
        $taskName = "DayZDLSS5EmergencyCleanup"
        $userId = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $clean = Join-Path $Root "CLEAN_FOR_MULTIPLAYER.ps1"
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$clean`" -NoPause"
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Emergency cleanup for DayZ DLSS5 offline demo" -Force | Out-Null
    } catch {
        Write-Host "WARNING: reboot-recovery task could not be registered. Live watchdog + manual CLEAN remain available." -ForegroundColor Yellow
    }
}

function Unregister-EmergencyCleanup {
    Remove-Item $Pending -Force -ErrorAction SilentlyContinue
    try { Unregister-ScheduledTask -TaskName "DayZDLSS5EmergencyCleanup" -Confirm:$false -ErrorAction SilentlyContinue } catch {}
    try { Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "DayZDLSS5EmergencyCleanup" -ErrorAction SilentlyContinue } catch {}
}

function Stage-Payload {
    foreach ($n in @("dxgi.dll","dlss5-feed.addon64","renodx-dlss5.addon64","nvngx_dlss.dll","nvngx_dlssnr.dll","ReShade.ini","dlss5.ini","dlss5-feed.cfg")) {
        $src = Join-Path $Payload $n
        if (-not (Test-Path $src)) { throw "Payload file missing: $src" }
        Copy-Item $src (Join-Path $DayZ $n) -Force
    }
    $shaderSrc = Join-Path $Payload "reshade-shaders"
    if (-not (Test-Path $shaderSrc)) { throw "Payload shader folder missing." }
    Copy-Item $shaderSrc (Join-Path $DayZ "reshade-shaders") -Recurse -Force
}

function Save-SessionAndClean {
    foreach ($n in @("ReShade.ini","dlss5.ini","dlss5-feed.cfg")) {
        $src = Join-Path $DayZ $n
        if (Test-Path $src) { Copy-Item $src (Join-Path $Payload $n) -Force -ErrorAction SilentlyContinue }
    }
    foreach ($pattern in @("ReShade.log*","dlss5-feed.log*")) {
        Get-ChildItem $DayZ -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $sessionDir $_.Name) -Force -ErrorAction SilentlyContinue
        }
    }
    if (Test-Path (Join-Path $DayZ "error.log")) { Copy-Item (Join-Path $DayZ "error.log") (Join-Path $sessionDir "DayZ_error.log") -Force -ErrorAction SilentlyContinue }
    foreach ($n in Get-DemoNames) {
        $p = Join-Path $DayZ $n
        if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Get-ChildItem $DayZ -Filter "ReShade.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem $DayZ -Filter "dlss5-feed.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Unregister-EmergencyCleanup
}

try {
    Write-Banner "Start local DayZDiag server (ReShade is NOT staged yet)"
    $bat = Join-Path $LocalHost "DZ_localhost+logmonitor.bat"
    if (-not (Test-Path $bat)) { throw "LocalHost launcher missing: $bat" }

    $serverWindow = Start-Process -FilePath "cmd.exe" -ArgumentList @("/k", "`"$bat`"") -WorkingDirectory $LocalHost -PassThru

    # DayZ_LocalHost's visible monitor can show CE/Hive readiness even when that
    # message is not reliably available in script_*.log on every installation.
    # The reference machine reaches CE/Hive init in ~26s, so beta7 waits for the
    # real DayZDiag -server process and then gives it a conservative 40s startup
    # window before staging ReShade/DLSS and starting the local client.
    $deadline = (Get-Date).AddSeconds(150)
    $ready = $false
    $serverPids = @()
    $serverSeenAt = $null

    Write-Host "Waiting for local DayZDiag server..." -ForegroundColor Cyan

    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 1

        $servers = @(
            Get-CimInstance Win32_Process -Filter "Name='DayZDiag_x64.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -match "(?i)(^|\s)-server(\s|$)" }
        )

        if ($servers.Count -lt 1) {
            $serverSeenAt = $null
            continue
        }

        $serverPids = @($servers | ForEach-Object { [int]$_.ProcessId })

        if (-not $serverSeenAt) {
            $serverSeenAt = Get-Date
            Write-Host "Local DayZDiag server detected." -ForegroundColor Green
            Write-Host "Waiting 40 seconds for CE/Hive initialization..." -ForegroundColor Cyan
        }

        if (((Get-Date) - $serverSeenAt).TotalSeconds -ge 40) {
            $stillRunning = @(
                Get-CimInstance Win32_Process -Filter "Name='DayZDiag_x64.exe'" -ErrorAction SilentlyContinue |
                Where-Object { $_.CommandLine -match "(?i)(^|\s)-server(\s|$)" }
            )

            if ($stillRunning.Count -gt 0) {
                $serverPids = @($stillRunning | ForEach-Object { [int]$_.ProcessId })
                Write-Host "Local DayZDiag server startup wait complete." -ForegroundColor Green
                $ready = $true
                break
            }
        }
    }

    if (-not $ready) { throw "Local DayZDiag server did not remain running long enough to become ready." }
    if ($serverPids.Count -lt 1) { throw "Local DayZDiag server PID could not be identified." }

    Write-Banner "Stage demo payload and launch DayZDiag client"
    Register-EmergencyCleanup
    Stage-Payload
    $client = Start-Process -FilePath $Diag -ArgumentList @("-connect=127.0.0.1:2302","-noPause","-doLogs") -WorkingDirectory $DayZ -PassThru
    $watchdog = Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$Root\WATCHDOG.ps1`"","-LauncherPid",$PID,"-ClientPid",$client.Id) -WindowStyle Hidden -PassThru

    Write-Host "HOME = ReShade overlay | F6 = RenoDX Neural Rendering toggle" -ForegroundColor Cyan
    Write-Host "Hardware Antialiasing/MSAA must remain OFF." -ForegroundColor Yellow
    Write-Host "If depth is wrong: Add-ons -> Generic Depth -> full-resolution D24S8 -> Copy before clear -> Clear 1." -ForegroundColor Yellow

    while (-not $client.HasExited) {
        Start-Sleep -Milliseconds 100
        $client.Refresh()
        $forbidden = @(Get-ForbiddenNormalDayZProcesses)
        if ($forbidden.Count -gt 0) {
            Write-Host "NORMAL DAYZ / BATTLEYE LAUNCH DETECTED WHILE DEMO FILES ARE STAGED." -ForegroundColor Red
            $forbidden | Stop-Process -Force -ErrorAction SilentlyContinue
            throw "Safety interlock aborted the demo and killed the normal DayZ launch. Run STATUS/CLEAN before any multiplayer use."
        }
    }
}
finally {
    Write-Banner "Automatic cleanup"
    try { Save-SessionAndClean } catch { Write-Host "Automatic cleanup error: $($_.Exception.Message)" -ForegroundColor Red }
    foreach ($pid in $serverPids) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
    if ($serverWindow) { Stop-Process -Id $serverWindow.Id -Force -ErrorAction SilentlyContinue }
    if ($watchdog) { Stop-Process -Id $watchdog.Id -Force -ErrorAction SilentlyContinue }
    $remaining = @(Get-DemoFilesInDayZ $DayZ)
    if ($remaining.Count -eq 0) {
        Write-Host "DayZ root is clean again." -ForegroundColor Green
    } else {
        Write-Host "WARNING: cleanup left files behind. DO NOT start normal DayZ. Run CLEAN_FOR_MULTIPLAYER.cmd first." -ForegroundColor Red
        $remaining | ForEach-Object { Write-Host "  $_" }
    }
}

Start-Sleep -Seconds 2
