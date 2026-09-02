#requires -Version 5.1
param([switch]$DeepStage)
$Root = Split-Path -Parent $PSCommandPath
. (Join-Path $Root "COMMON.ps1")

$fail = 0
function Pass([string]$m) { Write-Host "[PASS] $m" -ForegroundColor Green }
function Fail([string]$m) { Write-Host "[FAIL] $m" -ForegroundColor Red; $script:fail++ }
function Check([bool]$ok,[string]$m) { if ($ok) { Pass $m } else { Fail $m } }

$cfgFile = Join-Path $Root "config.json"
Check (Test-Path $cfgFile) "config.json exists"
if (-not (Test-Path $cfgFile)) { exit 10 }
$cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
$DayZ = [string]$cfg.DayZPath
$Payload = Join-Path $Root "payload"
$LocalHost = [string]$cfg.LocalHostPath

Write-Banner "SELF TEST"
Check (Test-Path (Join-Path $DayZ "DayZDiag_x64.exe")) "DayZDiag_x64.exe exists"
Check (Test-Path (Join-Path $DayZ "DayZ_x64.exe")) "DayZ_x64.exe exists"
Check ((Test-Path (Join-Path $DayZ "DayZ_BE.exe")) -and (Test-Path (Join-Path $DayZ "BattlEye"))) "BattlEye is in normal state"
Check (-not (Test-Path (Join-Path $DayZ "DayZ_BE.exe.disabled")) -and -not (Test-Path (Join-Path $DayZ "BattlEye.disabled"))) "No .disabled BattlEye names"

foreach ($n in @("dxgi.dll","dlss5-feed.addon64","renodx-dlss5.addon64","nvngx_dlss.dll","nvngx_dlssnr.dll","ReShade.ini","dlss5.ini","dlss5-feed.cfg","reshade-shaders")) {
    Check (Test-Path (Join-Path $Payload $n)) "payload/$n exists"
}
Check (Test-Path (Join-Path $Payload "reshade-shaders\Shaders\DLSS5_Feed.fx")) "DLSS5_Feed.fx exists"
Check (Test-Path (Join-Path $Payload "reshade-shaders\Shaders\lumenite_Kernel.fx")) "lumenite_Kernel.fx exists"
Check (Test-Path (Join-Path $Payload "reshade-shaders\Shaders\DisplayDepth.fx")) "DisplayDepth.fx exists"
Check (Test-Path (Join-Path $Payload "reshade-shaders\Shaders\ReShade.fxh")) "ReShade.fxh exists"
Check (Test-Path (Join-Path $Root "WATCHDOG.ps1")) "independent cleanup/safety watchdog exists"

try {
    $sig1 = Get-AuthenticodeSignature (Join-Path $Payload "nvngx_dlss.dll")
    $sig2 = Get-AuthenticodeSignature (Join-Path $Payload "nvngx_dlssnr.dll")
    Check ($sig1.Status -eq [System.Management.Automation.SignatureStatus]::Valid -and [string]$sig1.SignerCertificate.Subject -match "NVIDIA") "nvngx_dlss.dll has a valid NVIDIA signature"
    Check ($sig2.Status -eq [System.Management.Automation.SignatureStatus]::Valid -and [string]$sig2.SignerCertificate.Subject -match "NVIDIA") "nvngx_dlssnr.dll has a valid NVIDIA signature"
} catch { Fail "Could not verify NVIDIA Authenticode signatures: $($_.Exception.Message)" }

$renoExpected = "D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952"
$renoActual = (Get-FileHash (Join-Path $Payload "renodx-dlss5.addon64") -Algorithm SHA256).Hash.ToUpperInvariant()
Check ($renoActual -eq $renoExpected) "RenoDX DLSS5 4.70 hash matches the pinned build"

$ri = Get-Content (Join-Path $Payload "ReShade.ini") -Raw
Check ($ri -match 'PresetPath=\.\\dlss5\.ini') "ReShade uses dlss5.ini preset"
Check ($ri -match 'DLSS5_MV_PROVIDER=3') "Lumenite provider define is set"
Check ($ri -match 'DepthCopyAtClearIndex=1') "DayZ clear index preset is set"
Check ($ri -match 'DepthCopyBeforeClears=2') "Depth copy-before-clear is enabled"
Check ($ri -match 'RESHADE_DEPTH_INPUT_IS_REVERSED=1') "Reversed depth define is set"
Check ($ri -match 'EnableHooks=2') "RenoDX NGX-only hook mode is set"
Check ($ri -match 'NREnableUpscaling=0') "Native-resolution/DLAA showcase mode is set"

$pi = Get-Content (Join-Path $Payload "dlss5.ini") -Raw
Check ($pi -match '^Techniques=Lumenite_Kernel@lumenite_Kernel\.fx,DLSS5_Feed@DLSS5_Feed\.fx') "Lumenite executes before DLSS5 Feed"
Check ($pi -match 'MV_SIGN=1\.000000,1\.000000') "Motion-vector sign is +1/+1"
Check ($pi -match 'MV_SCALE=1\.000000') "Motion-vector scale is 1.0"
Check ($pi -match 'MV_VALIDATE=1') "Master MV validation is enabled"
Check ($pi -match 'VALIDATE_DEPTH=0') "Depth sub-validation is disabled (tested DayZ preset)"
Check ($pi -match 'VALIDATE_MV=0') "Consistency sub-validation is disabled (tested DayZ preset)"
Check ($pi -match 'VALIDATE_STATIC=0') "Static sub-validation is disabled (tested DayZ preset)"

$fc = Get-Content (Join-Path $Payload "dlss5-feed.cfg") -Raw
Check ($fc -match 'reset_every=1') "reset_every=1 showcase anti-smear workaround is set"
Check ($fc -match 'work_resolution=100') "Native 100% work resolution is set"

$serverPs = Join-Path $LocalHost "DZ_server.ps1"
Check (Test-Path $serverPs) "DayZ_LocalHost server script exists at expected non-nested path"
if (Test-Path $serverPs) {
    $st = Get-Content $serverPs -Raw
    $escaped = [regex]::Escape($DayZ.Replace("'","''"))
    $pathPattern = [regex]::Escape('$dzPath') + "\s*=\s*'" + $escaped + "'"
    Check ($st -match $pathPattern) "DayZ_LocalHost path was safely patched"
}
Check (Test-Path (Join-Path $LocalHost "DZ_localhost+logmonitor.bat")) "server-only LocalHost launcher exists"

$rootFiles = @(Get-DemoFilesInDayZ $DayZ)
Check ($rootFiles.Count -eq 0) "DayZ root is clean before deep-stage test"
Check (@(Get-ConflictingHookFiles $DayZ).Count -eq 0) "No conflicting graphics proxy/add-on is present in DayZ root"

if ($DeepStage -and $fail -eq 0) {
    Write-Banner "DEEP STAGE / ROLLBACK TEST"
    Ensure-Admin
    Ensure-DayZClosed
    try {
        foreach ($n in @("dxgi.dll","dlss5-feed.addon64","renodx-dlss5.addon64","nvngx_dlss.dll","nvngx_dlssnr.dll","ReShade.ini","dlss5.ini","dlss5-feed.cfg")) {
            Copy-Item (Join-Path $Payload $n) (Join-Path $DayZ $n) -Force
        }
        Copy-Item (Join-Path $Payload "reshade-shaders") (Join-Path $DayZ "reshade-shaders") -Recurse -Force
        Check ((Test-Path (Join-Path $DayZ "dxgi.dll")) -and (Test-Path (Join-Path $DayZ "reshade-shaders"))) "Payload can be staged into the real DayZ directory"
        Check ((Test-Path (Join-Path $DayZ "DayZ_BE.exe")) -and (Test-Path (Join-Path $DayZ "BattlEye"))) "BattlEye remained untouched while payload was staged"
    } finally {
        foreach ($n in Get-DemoNames) {
            $p = Join-Path $DayZ $n
            if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
        }
        Get-ChildItem $DayZ -Filter "ReShade.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem $DayZ -Filter "dlss5-feed.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    Check (@(Get-DemoFilesInDayZ $DayZ).Count -eq 0) "Deep-stage rollback returned DayZ to clean state"
    Check ((Test-Path (Join-Path $DayZ "DayZ_BE.exe")) -and (Test-Path (Join-Path $DayZ "BattlEye"))) "Deep-stage test did not alter BattlEye"
}

$report = Join-Path $Root "last_self_test.txt"
"Self-test: $(Get-Date -Format s)`r`nFailures: $fail`r`nDayZ: $DayZ`r`nVersion: $($cfg.DayZVersion)" | Set-Content $report -Encoding UTF8
if ($fail -eq 0) { Write-Banner "SELF TEST PASSED" Green; exit 0 }
Write-Banner "SELF TEST FAILED ($fail checks)" Red
exit 20
