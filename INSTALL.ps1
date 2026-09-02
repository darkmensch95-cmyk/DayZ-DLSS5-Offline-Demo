#requires -Version 5.1
param([string]$DayZPath = "")

$Here = Split-Path -Parent $PSCommandPath
. (Join-Path $Here "COMMON.ps1")

$Version = "1.0-beta2"
$AppRoot = "C:\DayZ_DLSS5_OFFLINE_DEMO"
$Payload = Join-Path $AppRoot "payload"
$Cache = Join-Path $AppRoot "cache"
$LocalHost = Join-Path $AppRoot "LocalHost"
$Manifest = [ordered]@{}

$ReShadeVersion = "6.8.0"
$ReShadeUrl = "https://reshade.me/downloads/ReShade_Setup_6.8.0_Addon.exe"
$ReShadeSha256 = "AFE4C8F13048306307983B8B3D41D5BF00A86820440B0E57DEA10950E1176445"
$FeederTag = "v0.7.0"
$RenoTag = "renodx-dlss5-4.70"
$RenoSha256 = "E1C28FDE0922B12FC10734E58C3D24A36808E575247F4FD4F36226540D7EE023"
$DlssNrTag = "dlssnr-310.8.SF-v2"
$DlssTag = "dlss-310.8.0"

Ensure-Admin
Ensure-DayZClosed

Clear-Host
Write-Banner "DAYZ DLSS 5 OFFLINE DEMO INSTALLER - $Version" Red
Write-Host "OFFLINE / LOCAL DAYZDIAG ONLY." -ForegroundColor Yellow
Write-Host "DO NOT USE THIS SETUP ON OFFICIAL, COMMUNITY, PUBLIC OR BATTLEYE-PROTECTED SERVERS." -ForegroundColor Red
Write-Host "THIS PROJECT DOES NOT DISABLE, PATCH, CIRCUMVENT OR BYPASS BATTLEYE." -ForegroundColor Green
Write-Host "ReShade's Full Add-on build itself warns that it is intended for single-player use and may cause bans in multiplayer games." -ForegroundColor Yellow
Write-Host "No anti-cheat safety guarantee is made. If you use these files outside the documented local DayZDiag workflow, you accept the risk." -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Type exactly: I UNDERSTAND OFFLINE ONLY"
if ($confirm -cne "I UNDERSTAND OFFLINE ONLY") { throw "Disclaimer not accepted." }

Write-Banner "1/9 - Locate and validate DayZ"
$DayZPath = Find-DayZInstall $DayZPath
$DiagExe = Join-Path $DayZPath "DayZDiag_x64.exe"
$GameExe = Join-Path $DayZPath "DayZ_x64.exe"
if (-not (Test-Path $DiagExe) -or -not (Test-Path $GameExe)) { throw "DayZ executables are missing." }
Assert-BattlEyeNormal $DayZPath
Assert-DayZRootClean $DayZPath
Write-Host "DayZ: $DayZPath" -ForegroundColor Green

$dayzVersion = (Get-Item $GameExe).VersionInfo.FileVersion
Write-Host "DayZ file version: $dayzVersion"
if ($dayzVersion -and -not $dayzVersion.StartsWith("1.29")) {
    Write-Host "WARNING: this package was field-tested on DayZ 1.29. A newer game build may change depth-buffer/render behavior." -ForegroundColor Yellow
    $v = Read-Host "Type CONTINUE to install anyway"
    if ($v -cne "CONTINUE") { throw "Stopped because DayZ is outside the field-tested version." }
}

$gpuNames = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
Write-Host "GPU(s): $($gpuNames -join '; ')"
if (-not ($gpuNames -match "NVIDIA.*RTX 50")) {
    throw "No NVIDIA RTX 50-series GPU detected. This package is released only for the RTX 50-series target used by the DLSS 5 neural-rendering build."
}

if (Test-Path $AppRoot) {
    throw "$AppRoot already exists. Run UNINSTALL from the old install (after cleaning DayZ) before installing this build."
}
New-Item -ItemType Directory -Force -Path $AppRoot,$Payload,$Cache | Out-Null
Assert-FreeSpace $AppRoot 1.5 "C: demo storage"
Assert-FreeSpace $DayZPath 0.6 "DayZ staging drive"
Start-Transcript -Path (Join-Path $AppRoot "install.log") -Force | Out-Null

try {
    Write-Banner "2/9 - ReShade $ReShadeVersion Full Add-on"
    $reshSetup = Join-Path $Cache "ReShade_Setup_6.8.0_Addon.exe"
    Download-File $ReShadeUrl $reshSetup 1000000
    $actual = Test-Sha256 $reshSetup $ReShadeSha256 "Official ReShade Full Add-on installer"
    $Manifest.ReShade = @{ version=$ReShadeVersion; url=$ReShadeUrl; sha256=$actual; note="Downloaded at install time; not bundled" }
    Write-Host "Official ReShade installer hash verified." -ForegroundColor Green

    $bootstrap = Join-Path $Cache "reshade-bootstrap"
    New-Item -ItemType Directory -Force -Path $bootstrap | Out-Null
    $bootstrapExe = Join-Path $bootstrap "DayZDiag_x64.exe"
    Copy-Item $DiagExe $bootstrapExe -Force
    $p = Start-Process -FilePath $reshSetup -ArgumentList @("`"$bootstrapExe`"","--api","dxgi","--headless") -WorkingDirectory $bootstrap -Wait -PassThru
    if ($p.ExitCode -ne 0) { throw "ReShade headless bootstrap failed with exit code $($p.ExitCode)." }
    $reshDll = Join-Path $bootstrap "dxgi.dll"
    if (-not (Test-Path $reshDll)) { throw "ReShade bootstrap did not produce dxgi.dll." }
    $product = (Get-Item $reshDll).VersionInfo.ProductName
    if ($product -notmatch "ReShade") { throw "Generated dxgi.dll does not identify as ReShade." }
    Copy-Item $reshDll (Join-Path $Payload "dxgi.dll") -Force

    Write-Banner "3/9 - ReShade standard shader pack"
    $reshBranch = Resolve-GitHubBranch "crosire/reshade-shaders" "slim"
    $reshSha = [string]$reshBranch.commit.sha
    $reshZip = Join-Path $Cache "reshade-shaders.zip"
    $reshEx = Join-Path $Cache "reshade-shaders"
    Download-File "https://github.com/crosire/reshade-shaders/archive/$reshSha.zip" $reshZip 10000
    Expand-Archive $reshZip $reshEx -Force
    $reshRoot = Get-ChildItem $reshEx -Directory | Select-Object -First 1
    if (-not $reshRoot) { throw "ReShade shader archive layout was unexpected." }
    $shaderDir = Join-Path $Payload "reshade-shaders\Shaders"
    $textureDir = Join-Path $Payload "reshade-shaders\Textures"
    New-Item -ItemType Directory -Force -Path $shaderDir,$textureDir | Out-Null
    Copy-Item (Join-Path $reshRoot.FullName "Shaders\*") $shaderDir -Recurse -Force
    if (Test-Path (Join-Path $reshRoot.FullName "Textures")) { Copy-Item (Join-Path $reshRoot.FullName "Textures\*") $textureDir -Recurse -Force }
    $Manifest.ReShadeShaders = @{ branch="slim"; commit=$reshSha; source="https://github.com/crosire/reshade-shaders"; note="Downloaded at install time" }

    Write-Banner "4/9 - DLSS5-Feeder $FeederTag"
    $feedRel = Get-GitHubRelease "jlrouzies-fr/DLSS5-Feeder" $FeederTag
    [void](Download-ReleaseAsset $feedRel "dlss5-feed.addon64" (Join-Path $Payload "dlss5-feed.addon64") 50000)
    [void](Download-ReleaseAsset $feedRel "DLSS5_Feed.fx" (Join-Path $shaderDir "DLSS5_Feed.fx") 10000)
    $Manifest.Feeder = @{ tag=$FeederTag; source="https://github.com/jlrouzies-fr/DLSS5-Feeder"; addon_sha256=(Get-FileHash (Join-Path $Payload "dlss5-feed.addon64") -Algorithm SHA256).Hash; shader_sha256=(Get-FileHash (Join-Path $shaderDir "DLSS5_Feed.fx") -Algorithm SHA256).Hash; license="MIT" }

    Write-Banner "5/9 - LumeniteFX from the author's official repository"
    $lumiBranch = Resolve-GitHubBranch "umar-afzaal/LumeniteFX" "mainline"
    $lumiSha = [string]$lumiBranch.commit.sha
    $lumiZip = Join-Path $Cache "LumeniteFX.zip"
    $lumiEx = Join-Path $Cache "LumeniteFX"
    Download-File "https://github.com/umar-afzaal/LumeniteFX/archive/$lumiSha.zip" $lumiZip 10000
    Expand-Archive $lumiZip $lumiEx -Force
    $lumiRoot = Get-ChildItem $lumiEx -Directory | Select-Object -First 1
    if (-not $lumiRoot) { throw "LumeniteFX archive layout was unexpected." }
    Copy-Item (Join-Path $lumiRoot.FullName "Shaders\*") $shaderDir -Recurse -Force
    Copy-Item (Join-Path $lumiRoot.FullName "Textures\*") $textureDir -Recurse -Force
    $Manifest.LumeniteFX = @{ branch="mainline"; commit=$lumiSha; source="https://github.com/umar-afzaal/LumeniteFX"; license="AGNYA Rev 1.4; fetched through the author's official link; not bundled" }

    Write-Banner "6/9 - RenoDX DLSS5 and NVIDIA NGX runtimes"
    [void](Extract-FileFromRelease "RankFTW/rhi-repo" $RenoTag "renodx-dlss5.addon64" (Join-Path $Payload "renodx-dlss5.addon64") $Cache)
    [void](Test-Sha256 (Join-Path $Payload "renodx-dlss5.addon64") $RenoSha256 "renodx-dlss5.addon64 4.70")
    [void](Extract-FileFromRelease "RankFTW/rhi-repo" $DlssNrTag "nvngx_dlssnr.dll" (Join-Path $Payload "nvngx_dlssnr.dll") $Cache)
    [void](Extract-FileFromRelease "RankFTW/rhi-repo" $DlssTag "nvngx_dlss.dll" (Join-Path $Payload "nvngx_dlss.dll") $Cache)
    Assert-NvidiaSignature (Join-Path $Payload "nvngx_dlssnr.dll")
    Assert-NvidiaSignature (Join-Path $Payload "nvngx_dlss.dll")
    $Manifest.RenoDX = @{ tag=$RenoTag; source="https://github.com/RankFTW/rhi-repo"; sha256=(Get-FileHash (Join-Path $Payload "renodx-dlss5.addon64") -Algorithm SHA256).Hash; note="Community-distributed closed-source add-on; not bundled in this release ZIP" }
    $Manifest.DLSSNR = @{ tag=$DlssNrTag; source="https://github.com/RankFTW/rhi-repo"; sha256=(Get-FileHash (Join-Path $Payload "nvngx_dlssnr.dll") -Algorithm SHA256).Hash; authenticode="NVIDIA signature verified" }
    $Manifest.DLSS = @{ tag=$DlssTag; source="https://github.com/RankFTW/rhi-repo"; sha256=(Get-FileHash (Join-Path $Payload "nvngx_dlss.dll") -Algorithm SHA256).Hash; authenticode="NVIDIA signature verified" }

    Write-Banner "7/9 - Install the tested DayZ preset"
    foreach ($n in @("ReShade.ini","dlss5.ini","dlss5-feed.cfg")) {
        $src = Join-Path $Here "config\$n"
        if (-not (Test-Path $src)) { throw "Bundled preset/config missing: $src" }
        Copy-Item $src (Join-Path $Payload $n) -Force
    }
    $ini = Join-Path $Payload "ReShade.ini"
    $txt = Get-Content $ini -Raw
    $cachePath = Join-Path $env:LOCALAPPDATA "Temp\ReShade"
    $txt = $txt.Replace("%LOCALAPPDATA%\Temp\ReShade", $cachePath)
    Set-Content $ini $txt -Encoding UTF8

    Write-Banner "8/9 - Local DayZDiag server helper"
    $lhBranch = Resolve-GitHubBranch "Cho-Buggers/DayZ_LocalHost" "main"
    $lhSha = [string]$lhBranch.commit.sha
    $lhZip = Join-Path $Cache "DayZ_LocalHost.zip"
    $lhEx = Join-Path $Cache "DayZ_LocalHost"
    Download-File "https://github.com/Cho-Buggers/DayZ_LocalHost/archive/$lhSha.zip" $lhZip 10000
    Expand-Archive $lhZip $lhEx -Force
    $lhRoot = Get-ChildItem $lhEx -Directory | Select-Object -First 1
    if (-not $lhRoot) { throw "DayZ_LocalHost archive layout was unexpected." }
    New-Item -ItemType Directory -Force -Path $LocalHost | Out-Null
    Copy-Item (Join-Path $lhRoot.FullName "*") $LocalHost -Recurse -Force

    $serverPs = Join-Path $LocalHost "DZ_server.ps1"
    if (-not (Test-Path $serverPs)) { throw "DayZ_LocalHost copy failed: DZ_server.ps1 not found at expected path." }
    $serverText = Get-Content $serverPs -Raw
    $oldLine = '$dzPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\bohemia interactive\dayz").main'
    if (-not $serverText.Contains($oldLine)) { throw "DayZ_LocalHost changed upstream; the exact safe path-patch line was not found. Installer stopped rather than guessing." }
    $safePath = $DayZPath.Replace("'","''")
    $serverText = $serverText.Replace($oldLine, "`$dzPath = '$safePath'")
    Set-Content $serverPs $serverText -Encoding UTF8
    New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE "Documents\DayZServer") | Out-Null
    $Manifest.DayZLocalHost = @{ branch="main"; commit=$lhSha; source="https://github.com/Cho-Buggers/DayZ_LocalHost"; license="GPL-3.0"; note="Downloaded at install time and locally patched only with the detected DayZ path" }

    Write-Banner "9/9 - Install launcher, safety tools and self-test"
    foreach ($n in @(
        "COMMON.ps1","START_OFFLINE_DEMO.ps1","START_OFFLINE_DEMO.cmd","WATCHDOG.ps1",
        "CLEAN_FOR_MULTIPLAYER.ps1","CLEAN_FOR_MULTIPLAYER.cmd",
        "STATUS.ps1","STATUS.cmd","SELF_TEST.ps1","SELF_TEST.cmd",
        "UNINSTALL.ps1","UNINSTALL.cmd"
    )) { Copy-Item (Join-Path $Here $n) (Join-Path $AppRoot $n) -Force }
    Copy-Item (Join-Path $Here "docs") (Join-Path $AppRoot "docs") -Recurse -Force
    Copy-Item (Join-Path $Here "LICENSE.txt") (Join-Path $AppRoot "LICENSE.txt") -Force
    Copy-Item (Join-Path $Here "VERSION.txt") (Join-Path $AppRoot "VERSION.txt") -Force

    $cfg = [ordered]@{
        InstallerVersion=$Version
        DayZPath=$DayZPath
        DayZVersion=$dayzVersion
        DiagExe=$DiagExe
        LocalHostPath=$LocalHost
        Installed=(Get-Date).ToString("s")
    }
    $cfg | ConvertTo-Json | Set-Content (Join-Path $AppRoot "config.json") -Encoding UTF8
    $Manifest | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $AppRoot "component_manifest.json") -Encoding UTF8

    Assert-BattlEyeNormal $DayZPath
    Assert-DayZRootClean $DayZPath

    & (Join-Path $AppRoot "SELF_TEST.ps1") -DeepStage
    if ($LASTEXITCODE -ne 0) { throw "Self-test failed. Do not use/publish this install until the report is reviewed." }

    Remove-Item $Cache -Recurse -Force -ErrorAction SilentlyContinue
    Write-Banner "INSTALLATION COMPLETE" Green
    Write-Host "Installed to: $AppRoot" -ForegroundColor Green
    Write-Host "Start offline demo: $AppRoot\START_OFFLINE_DEMO.cmd" -ForegroundColor Yellow
    Write-Host "Check clean state:   $AppRoot\STATUS.cmd"
    Write-Host "Emergency cleanup:   $AppRoot\CLEAN_FOR_MULTIPLAYER.cmd"
    Write-Host ""
    Write-Host "The normal DayZ directory is CLEAN and BattlEye was never renamed/disabled by this installer." -ForegroundColor Green
}
finally {
    if ($DayZPath -and (Test-Path $DayZPath)) {
        foreach ($n in Get-DemoNames) {
            $p = Join-Path $DayZPath $n
            if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
        }
        Get-ChildItem $DayZPath -Filter "ReShade.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem $DayZPath -Filter "dlss5-feed.log*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    try { Stop-Transcript | Out-Null } catch {}
}

pause
