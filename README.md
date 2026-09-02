# DayZ DLSS 5 Neural Rendering — Offline Demo

> [!CAUTION]
> ## OFFLINE / LOCAL `DayZDiag_x64.exe` ONLY
> **Do not use this setup on official, community, public, private, or otherwise BattlEye-protected multiplayer servers.**
>
> This project temporarily uses ReShade Full Add-on and rendering add-ons next to the DayZ executable. It is an unofficial technical experiment and there is **no anti-cheat / ban-safety guarantee**.
>
> The included workflow is built around a **local DayZDiag server/client** only. Before normal multiplayer, run the cleanup tool and require `STATE: MULTIPLAYER CLEAN`.

Experimental DLSS 5 Neural Rendering in **DayZ 1.29**, fed through ReShade, copied DayZ depth, reconstructed Lumenite motion vectors, DLSS5-Feeder, a synthetic native-resolution DLAA/NGX evaluation, and RenoDX DLSS 5.

This is **not native DayZ DLSS support**, not Frame Generation, and not an anti-cheat bypass.

## Showcase

Video: https://youtu.be/68b9V59VxeM

Tested reference setup:

- DayZ 1.29
- NVIDIA GeForce RTX 5090
- 2560×1440
- ReShade 6.8.0 Full Add-on
- DLSS5-Feeder 0.7.0
- RenoDX DLSS5 4.70
- DLSS NR 310.8.SF-v2
- DLSS 310.8.0
- LumeniteFX Kernel motion vectors
- native-resolution / 100% DLAA feed
- `reset_every=1` showcase preset

## How it works

```text
DayZ DX11
→ ReShade
→ copied DayZ depth
→ reconstructed Lumenite motion vectors
→ DLSS5-Feeder
→ synthetic native-resolution DLAA / NGX evaluation
→ RenoDX DLSS 5
→ NVIDIA DLSS Neural Rendering
```

DayZ does not provide native DLSS motion vectors to this external setup. Lumenite reconstructs them, which is the main technical limitation. Normal temporal history produced obvious smearing in the reference test, so the included showcase preset uses `reset_every=1`.

## Download

### Public beta

**v1.0-beta4**

[Download `DayZ_DLSS5_Offline_Demo_v1.0-beta4_PUBLIC.zip`](./dist/DayZ_DLSS5_Offline_Demo_v1.0-beta4_PUBLIC.zip)

SHA-256:

```text
1EA7F398F0052B3DD06C14DA27AD573706FA897BDA14347492E7F0EA0B8365B7
```

The ZIP contains **no third-party ReShade/NVIDIA/RenoDX/Lumenite binaries or shader packs**. The installer downloads pinned/tested components from the documented upstream sources.

## Quick start

1. Close DayZ, DayZDiag and DayZ Launcher.
2. Download and extract the beta ZIP.
3. Run `VERIFY_PACKAGE.cmd`.
4. Run `INSTALL.cmd` as administrator.
5. Read the warning and type exactly:
   `I UNDERSTAND OFFLINE ONLY`
6. After installation, run:
   `C:\DayZ_DLSS5_OFFLINE_DEMO\START_OFFLINE_DEMO.cmd`
7. Type exactly:
   `OFFLINE`
8. Wait for the local server and DayZDiag client.
9. In DayZ, disable Hardware Antialiasing / MSAA.
10. `Home` opens ReShade. In the tested RenoDX build, `F6` toggles Neural Rendering.

### Before normal multiplayer

Run:

```text
CLEAN_FOR_MULTIPLAYER.cmd
STATUS.cmd
```

Require:

```text
STATE: MULTIPLAYER CLEAN
```

If you are unsure, verify DayZ through Steam before launching normal multiplayer.

## Manual installation

Don't trust a random PowerShell installer from Reddit? Fair enough.

The full manual guide explains **every component, download, file location, tested version, depth-buffer setting, launch order, log check, troubleshooting step, and cleanup step**:

- [Full manual installation guide](./docs/FULL_MANUAL_INSTALL_GUIDE_NO_INSTALLER.md)
- [All download links](./docs/ALL_DOWNLOAD_LINKS.md)
- [Sources and licenses](./docs/SOURCES_AND_LICENSES.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [Manual cleanup](./docs/MANUAL_CLEANUP.md)

## Important DayZ depth setup

The exact depth resource can differ by PC, resolution and game version.

Reference test at 2560×1440 / DayZ 1.29:

- full-resolution `D24S8`
- **Copy depth buffer before clear operations**
- reference scene clear: `CLEAR 1`

Use `DisplayDepth` to verify that the selected depth buffer actually shows recognizable DayZ scene geometry.

## Tested presets included

The repo/package includes sanitized plain-text presets from the working showcase:

- `config/ReShade.ini`
- `config/dlss5.ini`
- `config/dlss5-feed.cfg`

Important reference values include:

- `DLSS5_MV_PROVIDER=3`
- `DepthCopyAtClearIndex=1`
- reversed depth enabled
- `Lumenite_Kernel` before `DLSS5_Feed`
- MV sign `+1 / +1`
- MV scale `1.0`
- problematic validation sub-tests disabled
- `reset_every=1`
- native 100% work resolution
- RenoDX NR enabled
- NR upscaling disabled

## Verification

A working feeder log should eventually contain lines similar to:

```text
feature ready: 2560x1440 DLAA
frame 1 delivered
frame 2 delivered
frame 3 delivered
```

The exact resolution and frame numbers may differ.

## Disclaimer

This is an unofficial community technical experiment.

It is not affiliated with, sponsored by, approved by, or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder, RankFTW, DayZ_LocalHost, or their authors/maintainers.

The scripts and documentation are provided **AS IS**, without warranty. No author or distributor can guarantee that an anti-cheat system, server owner, game update, driver update, or future software change will consider any particular setup safe.

If you use these files outside the documented local/offline DayZDiag environment, you do so entirely at your own risk.

## Credits / upstream projects

- ReShade — https://reshade.me/
- ReShade shaders — https://github.com/crosire/reshade-shaders
- DLSS5-Feeder — https://github.com/jlrouzies-fr/DLSS5-Feeder
- LumeniteFX — https://github.com/umar-afzaal/LumeniteFX
- RHI release repository — https://github.com/RankFTW/rhi-repo/releases
- DayZ LocalHost — https://github.com/Cho-Buggers/DayZ_LocalHost
- Bohemia DayZ Modding Basics — https://community.bohemia.net/wiki/DayZ%3AModding_Basics
- NVIDIA DLSS — https://developer.nvidia.com/rtx/dlss
