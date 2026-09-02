# Manual cleanup before normal multiplayer

> [!CAUTION]
> Do not launch normal DayZ while any of the experiment hook/add-on files remain in the DayZ folder.

Close the DayZDiag client and local DayZDiag server first.

Remove these experiment files/folders from the real DayZ root if present:

```text
dxgi.dll
dlss5-feed.addon64
renodx-dlss5.addon64
nvngx_dlss.dll
nvngx_dlssnr.dll
ReShade.ini
ReShadePreset.ini
dlss5.ini
dlss5-feed.cfg
reshade-shaders\
ReShade.log*
dlss5-feed.log*
```

Normal BattlEye files should exist with normal names:

```text
DayZ_BE.exe
BattlEye\
```

They should **not** be named `DayZ_BE.exe.disabled` or `BattlEye.disabled`.

PowerShell check:

```powershell
$dayz = "C:\Program Files (x86)\Steam\steamapps\common\DayZ"

Get-ChildItem $dayz -Force |
Where-Object {
    $_.Name -match "^(dxgi\.dll|dlss5-feed|dlss5\.ini|renodx|nvngx_dlss|ReShade|reshade-shaders)$" -or
    $_.Name -match "^ReShade\."
} |
Select-Object Name,Length
```

For this experiment, that should return nothing.

Then verify:

```powershell
Get-Item "$dayz\DayZ_BE.exe"
Get-Item "$dayz\BattlEye"
```

The installed launcher also provides `CLEAN_FOR_MULTIPLAYER.cmd` and `STATUS.cmd`. Require:

```text
STATE: MULTIPLAYER CLEAN
```

This only confirms that the known experiment files are absent and BattlEye has its normal names. It is **not** a promise from BattlEye or any server operator that unrelated software cannot cause a kick or ban.

If you are unsure, use Steam → DayZ → Properties → Installed Files → Verify integrity before normal multiplayer.
