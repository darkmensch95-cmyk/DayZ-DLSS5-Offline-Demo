# Full manual installation guide — no installer required

> [!CAUTION]
> ## OFFLINE / LOCAL DAYZDIAG ONLY
> Do **not** use this setup on official, community, public, private, or otherwise BattlEye-protected multiplayer servers. This guide temporarily places a ReShade Full Add-on DXGI proxy and rendering add-ons next to the DayZ executable. There is **no anti-cheat / ban-safety guarantee**.
>
> Do not launch `DayZ_x64.exe`, `DayZ_BE.exe`, or `DayZLauncher.exe` while the graphics payload described below is present. Use only `DayZDiag_x64.exe` against a local server on `127.0.0.1:2302`.

This document reproduces the tested DayZ DLSS 5 Neural Rendering showcase **manually**, without running the installer.

## 1. What this setup does

DayZ has no native DLSS integration. The working path is approximately:

```text
DayZ DX11 frame
→ ReShade Full Add-on
→ copied DayZ depth
→ LumeniteFX reconstructed motion vectors
→ DLSS5_Feed.fx
→ DLSS5-Feeder synthetic DLAA/NGX evaluation
→ RenoDX DLSS 5 add-on
→ nvngx_dlssnr.dll
→ Neural Rendering output copied back into the DayZ frame
```

This is **not** native Bohemia Interactive DLSS support, not Frame Generation, not a normal graphics option, and not an anti-cheat bypass.

## 2. Tested reference setup

- DayZ 1.29
- DirectX 11
- NVIDIA GeForce RTX 5090
- 2560×1440
- ReShade 6.8.0 Full Add-on
- DLSS5-Feeder 0.7.0
- RenoDX DLSS5 4.70
- DLSS NR runtime 310.8.SF-v2
- DLSS runtime 310.8.0
- LumeniteFX `mainline`
- native-resolution / 100% work resolution
- `reset_every=1`

The exact versions are pinned because that is the combination that was field-tested.

## 3. Download links

ReShade official website:

https://reshade.me/

ReShade standard shaders:

https://github.com/crosire/reshade-shaders

Use branch `slim`.

DLSS5-Feeder:

https://github.com/jlrouzies-fr/DLSS5-Feeder

Pinned release:

https://github.com/jlrouzies-fr/DLSS5-Feeder/releases/tag/v0.7.0

LumeniteFX:

https://github.com/umar-afzaal/LumeniteFX

Use branch `mainline`.

RHI release repository:

https://github.com/RankFTW/rhi-repo/releases

Pinned RenoDX DLSS5 4.70:

https://github.com/RankFTW/rhi-repo/releases/tag/renodx-dlss5-4.70

Pinned DLSS NR 310.8.SF-v2:

https://github.com/RankFTW/rhi-repo/releases/tag/dlssnr-310.8.SF-v2

Pinned DLSS 310.8.0:

https://github.com/RankFTW/rhi-repo/releases/tag/dlss-310.8.0

DayZ LocalHost helper:

https://github.com/Cho-Buggers/DayZ_LocalHost

Bohemia DayZ Modding Basics:

https://community.bohemia.net/wiki/DayZ%3AModding_Basics

Bohemia DayZ Diag Menu:

https://community.bohemia.net/wiki/DayZ%3ADiag_Menu

NVIDIA DLSS information:

https://developer.nvidia.com/rtx/dlss

## 4. Start from a clean DayZ install

Close all DayZ processes. The real DayZ folder must have normal BattlEye names:

```text
DayZ_BE.exe
BattlEye\
```

It should **not** already contain experiment files such as:

```text
dxgi.dll
dlss5-feed.addon64
renodx-dlss5.addon64
nvngx_dlss.dll
nvngx_dlssnr.dll
ReShade.ini
dlss5.ini
dlss5-feed.cfg
reshade-shaders\
```

If you are unsure, use Steam → DayZ → Properties → Installed Files → Verify integrity.

Typical DayZ path:

```text
C:\Program Files (x86)\Steam\steamapps\common\DayZ
```

## 5. Build a private payload folder

Do not assemble the graphics stack directly in the live DayZ folder.

Create:

```text
C:\DayZ_DLSS5_MANUAL\payload\
C:\DayZ_DLSS5_MANUAL\payload\reshade-shaders\Shaders\
C:\DayZ_DLSS5_MANUAL\payload\reshade-shaders\Textures\
```

The payload is copied into DayZ only **after** the local DayZDiag server is running.

## 6. Obtain ReShade 6.8.0 Full Add-on

Download ReShade from https://reshade.me/ and choose the **Full Add-on support** build.

The normal limited-add-on build is not sufficient for DLSS5-Feeder/RenoDX.

A safe manual bootstrap method is:

1. Create `C:\DayZ_DLSS5_MANUAL\bootstrap\`.
2. Copy `DayZDiag_x64.exe` from DayZ into that bootstrap folder.
3. Run the ReShade Full Add-on installer against the copied EXE.
4. Select DirectX 10/11/12.
5. Copy the produced `dxgi.dll` into your private payload folder.

Known SHA-256 for the ReShade 6.8.0 Full Add-on installer used by this project:

```text
AFE4C8F13048306307983B8B3D41D5BF00A86820440B0E57DEA10950E1176445
```

PowerShell verification:

```powershell
Get-FileHash "PATH\TO\ReShade_Setup_6.8.0_Addon.exe" -Algorithm SHA256
```

## 7. ReShade standard shaders

From https://github.com/crosire/reshade-shaders use branch `slim` and download the ZIP.

Copy the repository's `Shaders` and `Textures` contents into:

```text
payload\reshade-shaders\Shaders\
payload\reshade-shaders\Textures\
```

You should see files such as `ReShade.fxh`, `ReShadeUI.fxh`, and `DisplayDepth.fx`.

## 8. DLSS5-Feeder 0.7.0

From the pinned release download:

```text
dlss5-feed.addon64
DLSS5_Feed.fx
```

Place:

```text
payload\dlss5-feed.addon64
payload\reshade-shaders\Shaders\DLSS5_Feed.fx
```

Do not add unrelated bridge components. The feeder is the synthetic DLAA/NGX path used by this DayZ experiment.

## 9. LumeniteFX motion vectors

Use the official repository and branch `mainline`.

Copy **all** contents of the Lumenite `Shaders` and `Textures` folders into the corresponding payload shader/texture folders. Do not copy only `lumenite_Kernel.fx`; its includes/textures are required too.

Important files include:

```text
lumenite_Kernel.fx
include\lumenite_*.fxh
lumenite_bluenoise256.png
```

DayZ does not provide native DLSS motion vectors to this external setup. Lumenite reconstructs them, which is the biggest technical limitation.

## 10. RenoDX DLSS5 + NVIDIA runtimes

From the pinned RenoDX 4.70 release extract:

```text
renodx-dlss5.addon64
```

Place it in the payload root.

Pinned SHA-256 for the current beta5 RenoDX 4.70 asset:

```text
D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952
```

> [!IMPORTANT]
> The upstream 4.70 release asset was updated after the original showcase. The current beta5 installer pins the hash above so a future asset replacement cannot silently change the binary. See `docs/TESTING_STATUS.md` for the distinction between the original showcase build and the current beta5 release candidate.

From `dlssnr-310.8.SF-v2`, extract:

```text
nvngx_dlssnr.dll
```

From `dlss-310.8.0`, extract:

```text
nvngx_dlss.dll
```

Place both DLLs in the payload root.

Check their signatures:

```powershell
Get-AuthenticodeSignature "C:\DayZ_DLSS5_MANUAL\payload\nvngx_dlss.dll"
Get-AuthenticodeSignature "C:\DayZ_DLSS5_MANUAL\payload\nvngx_dlssnr.dll"
```

You want valid NVIDIA signatures.

## 11. Copy the tested preset files

This repository contains the sanitized plain-text preset files:

```text
config\ReShade.ini
config\dlss5.ini
config\dlss5-feed.cfg
```

Copy those three files into the payload root.

Important values include:

```text
PresetPath=.\dlss5.ini
DLSS5_MV_PROVIDER=3
DepthCopyAtClearIndex=1
DepthCopyBeforeClears=2
RESHADE_DEPTH_INPUT_IS_REVERSED=1
EnableHooks=2
NREnableUpscaling=0
MV_SIGN=1.000000,1.000000
MV_SCALE=1.000000
VALIDATE_DEPTH=0
VALIDATE_MV=0
VALIDATE_STATIC=0
reset_every=1
work_resolution=100
```

The effect order is:

```text
Lumenite_Kernel
DLSS5_Feed
```

`reset_every=1` is deliberate. Normal temporal history caused visible smear/ghosting with reconstructed motion vectors during the reference test.

## 12. Set up the local DayZDiag server

Download DayZ LocalHost from:

https://github.com/Cho-Buggers/DayZ_LocalHost

Extract it outside DayZ, for example:

```text
C:\DayZ_LocalHost\
```

Create the profile directory if needed:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\Documents\DayZServer"
```

If the helper looks for `C:\DayZDiag_x64.exe`, open `DZ_server.ps1` and set `$dzPath` to your real DayZ path.

## 13. Launch order — this matters

The local server and local client both use `DayZDiag_x64.exe`. ReShade loads because `dxgi.dll` sits beside that executable. Therefore the local server must start **before** the graphics payload is copied into DayZ.

Safe order:

1. Confirm DayZ root is clean.
2. Start `DZ_localhost+logmonitor.bat`.
3. Wait until the server reaches a line similar to:

```text
[CE][Hive] :: Init sequence finished.
```

4. Only now copy the payload into the real DayZ root.
5. Start only the DayZDiag client:

```powershell
cd "C:\Program Files (x86)\Steam\steamapps\common\DayZ"
.\DayZDiag_x64.exe "-connect=127.0.0.1:2302" -noPause -doLogs
```

Do **not** launch normal DayZ while the payload is present.

## 14. First in-game setup

Disable DayZ Hardware Antialiasing / MSAA.

Press `Home` to open ReShade.

If ReShade reports add-ons were skipped because it has only limited add-on functionality, you installed the wrong ReShade build. Use Full Add-on support.

The RenoDX component may appear in its own ReShade tab named `DLSS 5 Neural Rendering`.

## 15. Select the correct DayZ depth buffer

Open:

```text
ReShade → Add-ons → Generic Depth
```

Choose the full-resolution scene depth buffer. In the 2560×1440 DayZ 1.29 reference test this was a full-resolution `D24S8` resource.

Enable:

```text
Copy depth buffer before clear operations
```

Reference test scene clear:

```text
CLEAR 1
```

This is a reference, not a universal ID. Resource handles and draw-call counts can differ.

Enable `DisplayDepth` temporarily. A correct depth buffer must visibly contain recognizable scene geometry: terrain, buildings, trees, roads, foreground and distance. If it is just solid purple/white/black or nonsense, select another depth resource/clear.

Turn `DisplayDepth` off afterward.

## 16. Enable the effect chain

In the ReShade Home effect list enable:

```text
Lumenite_Kernel
DLSS 5 Feed
```

Keep Lumenite above the feed.

Do not leave the DLSS5 Feed debug view enabled for normal captures.

## 17. Verify the feeder really works

Open `DayZ\dlss5-feed.log` and look for lines similar to:

```text
NVSDK_NGX_D3D12_Init -> Success
feature ready: 2560x1440 DLAA
frame 1 delivered
frame 2 delivered
frame 3 delivered
```

The exact resolution/frame numbers may differ.

This is a better verification than relying only on visual differences.

## 18. Motion vectors and temporal smear

The reference test showed periods with almost no non-zero motion vectors, followed by periods with high coverage. The Lumenite debug view confirmed that reconstructed vectors existed, but validation could discard large areas.

The showcase preset uses:

```text
MV sign = +1 / +1
MV scale = 1.0
reset_every=1
```

The included preset also contains the captured showcase validation settings. The history reset is the important anti-smear workaround: without it, camera motion visibly smeared the image in the reference test. Resetting every frame removes that temporal history, so treat this as a technical/image-quality demo rather than native-quality temporal DLSS integration.

## 19. RenoDX panel / comparison captures

The RenoDX add-on may have its own tab called `DLSS 5 Neural Rendering`.

The supplied ReShade config uses:

```text
EnableHooks=2
NeuralUplift=1
NREnableUpscaling=0
NRPreset=0
NRStyle=1
```

In the tested 4.70 build, `F6` toggles Neural Rendering.

For fair comparisons, keep the same camera, weather, time, and graphics settings between OFF and ON shots.

## 20. Cleanup before normal multiplayer

Close the DayZDiag client and local server.

Remove these from the real DayZ root:

```text
dxgi.dll
dlss5-feed.addon64
renodx-dlss5.addon64
nvngx_dlss.dll
nvngx_dlssnr.dll
ReShade.ini
dlss5.ini
dlss5-feed.cfg
reshade-shaders\
ReShade.log*
dlss5-feed.log*
```

Verify normal BattlEye files exist:

```text
DayZ_BE.exe
BattlEye\
```

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

For this experiment that should return nothing.

**Required before normal multiplayer:** use Steam → DayZ → Properties → Installed Files → **Verify integrity of game files**, and wait for Steam to finish completely.

## 21. Troubleshooting summary

**Extensions/add-ons skipped:** wrong ReShade build → use Full Add-on.

**`DLSS5_Feed.fx` missing:** place it in `reshade-shaders\Shaders` and reload ReShade.

**Depth purple/white/nonsense:** choose full-resolution D24S8, enable copy-before-clear, then select the main scene clear.

**Everything smears when moving:** confirm `reset_every=1` and use the included `dlss5.ini`.

**No motion vectors:** make sure `Lumenite_Kernel` is enabled above `DLSS 5 Feed`, `DLSS5_MV_PROVIDER=3` is set, and all Lumenite includes/textures were copied.

**Server unreachable:** use `-connect=127.0.0.1:2302` and confirm the local server is still running.

**LocalHost looks for wrong DayZ path:** edit `$dzPath` in `DZ_server.ps1`.

**No delivered frames:** check ReShade Full Add-on, effect order, depth, NVIDIA runtimes, RenoDX add-on, `ReShade.log`, and `dlss5-feed.log`.

## 22. File-by-file explanation

- `dxgi.dll` — ReShade DXGI proxy that loads ReShade into the DX11 client.
- `ReShade.ini` — search paths, depth reference, preprocessor defines and RenoDX settings.
- `dlss5.ini` — active effect preset and DLSS5 Feed parameters.
- `dlss5-feed.addon64` — feeder add-on that builds/evaluates the NGX contract.
- `DLSS5_Feed.fx` — companion effect supplying color/depth/motion inputs.
- `dlss5-feed.cfg` — feeder runtime config including `reset_every=1` and work resolution.
- `lumenite_Kernel.fx` — reconstructed motion-vector provider.
- `renodx-dlss5.addon64` — generic RenoDX DLSS5 Neural Rendering add-on.
- `nvngx_dlss.dll` — NVIDIA DLSS runtime used for the synthetic DLAA/NGX path.
- `nvngx_dlssnr.dll` — NVIDIA Neural Rendering runtime.
- `DayZDiag_x64.exe` — Bohemia diagnostic executable used for local development/testing.

## 23. Final checklist

Before the demo:

- [ ] normal DayZ is closed
- [ ] DayZ Launcher is closed
- [ ] BattlEye has normal names
- [ ] real DayZ root is clean
- [ ] local server starts first
- [ ] payload is staged only after server is ready
- [ ] client is `DayZDiag_x64.exe` only
- [ ] client connects to `127.0.0.1:2302`
- [ ] MSAA is off
- [ ] correct scene depth is selected
- [ ] Lumenite is above DLSS5 Feed
- [ ] feeder log shows `feature ready`
- [ ] feeder log shows delivered frames

Before normal multiplayer:

- [ ] DayZDiag client closed
- [ ] local server closed
- [ ] ReShade/DLSS5 payload removed
- [ ] logs removed if desired
- [ ] `DayZ_BE.exe` exists
- [ ] `BattlEye\` exists
- [ ] Steam integrity verification completed after cleanup/uninstall

## Disclaimer

This is an unofficial community technical experiment. It is not affiliated with, sponsored by, approved by, or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder, RankFTW, DayZ_LocalHost, or their authors/maintainers.

The scripts and documentation are provided **AS IS**, without warranty. No author/distributor can guarantee that an anti-cheat system, server owner, game update, driver update, or future software change will consider any setup safe. If you use these files outside the documented local/offline DayZDiag environment, you do so entirely at your own risk.
