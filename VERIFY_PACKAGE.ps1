#requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath
$manifest = Join-Path $Root "FILE_MANIFEST_SHA256.txt"
if (-not (Test-Path $manifest)) { Write-Host "FILE_MANIFEST_SHA256.txt missing." -ForegroundColor Red; exit 2 }
$fail = 0
Get-Content $manifest | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith("#")) { return }
    $parts = $line -split '\s{2,}',2
    if ($parts.Count -ne 2) { Write-Host "Malformed manifest line: $line" -ForegroundColor Red; $script:fail++; return }
    $expected = $parts[0].Trim().ToUpperInvariant()
    $rel = $parts[1].Trim()
    $path = Join-Path $Root $rel
    if (-not (Test-Path $path)) { Write-Host "[MISSING] $rel" -ForegroundColor Red; $script:fail++; return }
    $actual = (Get-FileHash $path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $expected) { Write-Host "[BAD] $rel" -ForegroundColor Red; $script:fail++ } else { Write-Host "[OK]  $rel" -ForegroundColor Green }
}
if ($fail -eq 0) { Write-Host "Package file manifest verified." -ForegroundColor Green; exit 0 }
Write-Host "$fail package file(s) failed verification." -ForegroundColor Red
exit 3
