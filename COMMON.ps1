# Common helper functions for DayZ DLSS5 Offline Demo
$ErrorActionPreference = "Stop"

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

function Write-Banner([string]$Text, [ConsoleColor]$Color = [ConsoleColor]::Cyan) {
    Write-Host ""
    Write-Host ("=" * 76) -ForegroundColor $Color
    Write-Host $Text -ForegroundColor $Color
    Write-Host ("=" * 76) -ForegroundColor $Color
}

function Ensure-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator privileges are required. Right-click the CMD file and choose 'Run as administrator'."
    }
}

function Get-DayZRelatedProcesses {
    Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -in @("DayZ_x64","DayZDiag_x64","DayZ_BE","DayZLauncher") }
}

function Get-ForbiddenNormalDayZProcesses {
    @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -in @("DayZ_x64","DayZ_BE","DayZLauncher") })
}

function Ensure-DayZClosed {
    $p = @(Get-DayZRelatedProcesses)
    if ($p.Count -gt 0) {
        Write-Host "DayZ-related processes are still running:" -ForegroundColor Red
        $p | Select-Object ProcessName,Id | Format-Table -AutoSize
        throw "Close DayZ, DayZDiag and the DayZ launcher first."
    }
}

function Find-DayZInstall([string]$ExplicitPath = "") {
    if ($ExplicitPath -and (Test-Path (Join-Path $ExplicitPath "DayZDiag_x64.exe"))) { return (Resolve-Path $ExplicitPath).Path }
    $candidates = New-Object System.Collections.Generic.List[string]
    try {
        $reg = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\bohemia interactive\dayz" -ErrorAction Stop
        if ($reg.main) { $candidates.Add([string]$reg.main) }
    } catch {}
    $steamRoots = New-Object System.Collections.Generic.List[string]
    try {
        $s = Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction Stop
        if ($s.SteamPath) { $steamRoots.Add(([string]$s.SteamPath -replace '/', '\')) }
    } catch {}
    try {
        $s = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction Stop
        if ($s.InstallPath) { $steamRoots.Add([string]$s.InstallPath) }
    } catch {}
    foreach ($steam in @($steamRoots | Select-Object -Unique)) {
        $candidates.Add((Join-Path $steam "steamapps\common\DayZ"))
        $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            $raw = Get-Content $vdf -Raw
            foreach ($m in [regex]::Matches($raw, '"path"\s+"([^"]+)"')) {
                $lib = $m.Groups[1].Value -replace '\\\\','\'
                $candidates.Add((Join-Path $lib "steamapps\common\DayZ"))
            }
        }
    }
    $candidates.Add("C:\Program Files (x86)\Steam\steamapps\common\DayZ")
    $candidates.Add("C:\Program Files\Steam\steamapps\common\DayZ")
    foreach ($c in @($candidates | Select-Object -Unique)) {
        if ($c -and (Test-Path (Join-Path $c "DayZDiag_x64.exe"))) { return (Resolve-Path $c).Path }
    }
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select the DayZ folder containing DayZDiag_x64.exe"
    $dlg.ShowNewFolderButton = $false
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        if (Test-Path (Join-Path $dlg.SelectedPath "DayZDiag_x64.exe")) { return $dlg.SelectedPath }
    }
    throw "Could not locate the DayZ installation."
}

function Assert-BattlEyeNormal([string]$DayZ) {
    $normalExe = Test-Path (Join-Path $DayZ "DayZ_BE.exe")
    $normalDir = Test-Path (Join-Path $DayZ "BattlEye")
    $disabledExe = Test-Path (Join-Path $DayZ "DayZ_BE.exe.disabled")
    $disabledDir = Test-Path (Join-Path $DayZ "BattlEye.disabled")
    if (-not $normalExe -or -not $normalDir -or $disabledExe -or $disabledDir) {
        Write-Host "BattlEye is not in the normal Steam/DayZ state." -ForegroundColor Red
        Write-Host "This project does NOT disable, patch or bypass BattlEye." -ForegroundColor Yellow
        Write-Host "Use Steam -> DayZ -> Properties -> Installed Files -> Verify integrity before continuing." -ForegroundColor Yellow
        throw "BattlEye preflight failed."
    }
}

function Get-DemoNames {
    @("dxgi.dll","dlss5-feed.addon64","renodx-dlss5.addon64","nvngx_dlss.dll","nvngx_dlssnr.dll","ReShade.ini","dlss5.ini","dlss5-feed.cfg","reshade-shaders")
}

function Get-DemoFilesInDayZ([string]$DayZ) {
    $found = @()
    foreach ($n in Get-DemoNames) { $p = Join-Path $DayZ $n; if (Test-Path $p) { $found += $p } }
    return @($found | Sort-Object -Unique)
}

function Get-DemoLogFilesInDayZ([string]$DayZ) {
    $found = @()
    $found += @(Get-ChildItem $DayZ -Filter "ReShade.log*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
    $found += @(Get-ChildItem $DayZ -Filter "dlss5-feed.log*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
    return @($found | Sort-Object -Unique)
}

function Get-ConflictingHookFiles([string]$DayZ) {
    $names = @("dxgi.dll","d3d9.dll","d3d10.dll","d3d11.dll","d3d12.dll","ddraw.dll","opengl32.dll")
    $found = @()
    foreach ($n in $names) { $p = Join-Path $DayZ $n; if (Test-Path $p) { $found += $p } }
    $found += @(Get-ChildItem $DayZ -Filter "*.addon64" -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
    $found += @(Get-ChildItem $DayZ -Filter "ReShade*.ini" -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
    if (Test-Path (Join-Path $DayZ "reshade-shaders")) { $found += (Join-Path $DayZ "reshade-shaders") }
    return @($found | Sort-Object -Unique)
}

function Assert-DayZRootClean([string]$DayZ) {
    $found = @(Get-ConflictingHookFiles $DayZ)
    if ($found.Count -gt 0) {
        Write-Host "The DayZ folder already contains graphics hook/add-on files:" -ForegroundColor Red
        $found | ForEach-Object { Write-Host "  $_" }
        Write-Host "Remove/disable the other graphics mod first, or verify DayZ in Steam." -ForegroundColor Yellow
        throw "Refusing to overwrite an existing graphics-hook setup."
    }
}

function Assert-FreeSpace([string]$Path,[double]$RequiredGB,[string]$Label) {
    $root = [System.IO.Path]::GetPathRoot((Resolve-Path $Path).Path)
    $driveName = $root.Substring(0,1)
    $drive = Get-PSDrive -Name $driveName -ErrorAction Stop
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host "$Label free space: $freeGB GB"
    if ($freeGB -lt $RequiredGB) { throw "$Label needs at least $RequiredGB GB free space for a safe install/stage." }
}

function Download-File([string]$Url,[string]$OutFile,[long]$MinimumBytes=1) {
    $parent = Split-Path -Parent $OutFile
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $attempt = 0
    while ($attempt -lt 3) {
        $attempt++
        try {
            Invoke-WebRequest -UseBasicParsing -Headers @{"User-Agent"="DayZ-DLSS5-Offline-Demo/1.0-beta6"} -Uri $Url -OutFile $OutFile
            if (-not (Test-Path $OutFile)) { throw "Download did not create $OutFile" }
            $len = (Get-Item $OutFile).Length
            if ($len -lt $MinimumBytes) { throw "Downloaded file is unexpectedly small ($len bytes): $Url" }
            return
        } catch {
            Remove-Item $OutFile -Force -ErrorAction SilentlyContinue
            if ($attempt -ge 3) { throw }
            Start-Sleep -Seconds (2 * $attempt)
        }
    }
}

function Get-GitHubRelease([string]$Repo,[string]$Tag) {
    Invoke-RestMethod -Headers @{"User-Agent"="DayZ-DLSS5-Offline-Demo"} -Uri "https://api.github.com/repos/$Repo/releases/tags/$Tag"
}

function Test-AssetDigest([object]$Asset,[string]$FilePath) {
    $prop = $Asset.PSObject.Properties["digest"]
    if ($prop -and $prop.Value -and ([string]$prop.Value).StartsWith("sha256:")) {
        $expected = ([string]$prop.Value).Substring(7).ToUpperInvariant()
        $actual = (Get-FileHash $FilePath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actual -ne $expected) { throw "SHA-256 mismatch for $($Asset.name)." }
        return $expected
    }
    return $null
}

function Download-ReleaseAsset([object]$Release,[string]$AssetName,[string]$OutFile,[long]$MinimumBytes=1) {
    $asset = $Release.assets | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
    if (-not $asset) { throw "Asset '$AssetName' not found in release '$($Release.tag_name)'." }
    Download-File $asset.browser_download_url $OutFile $MinimumBytes
    [void](Test-AssetDigest $asset $OutFile)
    return $asset
}

function Extract-FileFromRelease([string]$Repo,[string]$Tag,[string]$TargetName,[string]$Destination,[string]$Cache) {
    $rel = Get-GitHubRelease $Repo $Tag
    $direct = $rel.assets | Where-Object { $_.name -eq $TargetName } | Select-Object -First 1
    if ($direct) {
        Download-File $direct.browser_download_url $Destination 1024
        [void](Test-AssetDigest $direct $Destination)
        return $rel
    }
    foreach ($asset in @($rel.assets | Where-Object { $_.name -like "*.zip" })) {
        $zip = Join-Path $Cache ("asset-" + [guid]::NewGuid().ToString() + ".zip")
        $ex = Join-Path $Cache ("asset-" + [guid]::NewGuid().ToString())
        Download-File $asset.browser_download_url $zip 1024
        [void](Test-AssetDigest $asset $zip)
        Expand-Archive $zip $ex -Force
        $found = Get-ChildItem $ex -Recurse -File | Where-Object { $_.Name -eq $TargetName } | Select-Object -First 1
        if ($found) {
            Copy-Item $found.FullName $Destination -Force
            Remove-Item $zip -Force -ErrorAction SilentlyContinue
            Remove-Item $ex -Recurse -Force -ErrorAction SilentlyContinue
            return $rel
        }
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        Remove-Item $ex -Recurse -Force -ErrorAction SilentlyContinue
    }
    throw "$TargetName could not be found in $Repo release $Tag."
}

function Resolve-GitHubBranch([string]$Repo,[string]$Branch) {
    Invoke-RestMethod -Headers @{"User-Agent"="DayZ-DLSS5-Offline-Demo"} -Uri "https://api.github.com/repos/$Repo/branches/$Branch"
}

function Assert-NvidiaSignature([string]$Path) {
    $sig = Get-AuthenticodeSignature $Path
    $fileName = [System.IO.Path]::GetFileName($Path)

    # The pinned DLSS NR 310.8.SF-v2 runtime from the documented upstream package
    # is currently NotSigned. INSTALL.ps1 verifies its exact pinned SHA-256 before
    # this function is called, so allow only that specific runtime to be unsigned.
    if ($fileName -ieq "nvngx_dlssnr.dll" -and $sig.Status -eq [System.Management.Automation.SignatureStatus]::NotSigned) {
        Write-Host "DLSS NR SF-v2 is unsigned; exact pinned SHA-256 verification already passed." -ForegroundColor Yellow
        return
    }

    if ($sig.Status -ne [System.Management.Automation.SignatureStatus]::Valid) { throw "NVIDIA runtime signature is not Valid: $Path ($($sig.Status))" }
    $subject = if ($sig.SignerCertificate) { [string]$sig.SignerCertificate.Subject } else { "" }
    if ($subject -notmatch "NVIDIA") { throw "Runtime signer is not NVIDIA: $Path ($subject)" }
}

function Test-Sha256([string]$Path,[string]$Expected,[string]$Label) {
    $actual = (Get-FileHash $Path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $Expected.ToUpperInvariant()) { throw "$Label SHA-256 mismatch. Expected $Expected, got $actual" }
    return $actual
}
