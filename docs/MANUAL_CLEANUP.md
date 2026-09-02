# Manual cleanup before normal multiplayer

> [!CAUTION]
> ## DO NOT LAUNCH NORMAL DAYZ / BATTLEYE UNTIL THIS ENTIRE CLEANUP IS FINISHED
> The experiment temporarily places ReShade Full Add-on, rendering add-ons and DLSS-related runtime files next to the DayZ executable. **Launching normal DayZ/BattlEye while those files remain can trigger anti-cheat action and may result in a kick, restriction or ban.**
>
> There is no anti-cheat / ban-safety guarantee. Cleanup tools can only check files known to this project.

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

## Final required step: verify DayZ through Steam

Even after the cleanup/status check passes, **verify the game files before returning to normal multiplayer:**

```text
Steam
→ Library
→ DayZ
→ Properties
→ Installed Files
→ Verify integrity of game files
```

Wait for Steam to finish the verification/repair completely.

Only after:

1. the experiment payload has been removed;
2. `STATUS.cmd` reports `STATE: MULTIPLAYER CLEAN`; **and**
3. Steam has finished verifying DayZ;

should you launch normal DayZ/BattlEye again.

The cleanup/status tools confirm only that the known experiment files are absent and BattlEye has its normal names. They are **not a promise from BattlEye, Bohemia Interactive or any server operator that your system/account is ban-safe**.

## Liability disclaimer

This project is an unofficial technical experiment provided **AS IS**, without warranty. Use is entirely at your own risk. To the maximum extent permitted by applicable law, the authors/distributors accept no responsibility for bans, kicks, account restrictions, lost data, corrupted files, crashes, system instability or other damage caused by use or misuse. Nothing here excludes rights or liability that cannot legally be excluded.
