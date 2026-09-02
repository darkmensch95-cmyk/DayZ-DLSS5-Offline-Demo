# DayZ DLSS 5 Neural Rendering — Offline Demo

> [!CAUTION]
> ## ⚠️ OFFLINE / LOCAL `DayZDiag_x64.exe` ONLY — DO NOT USE WITH BATTLEYE ⚠️
> **Do not use this setup on official, community, public, private, or any other BattlEye-protected multiplayer server.**
>
> This project temporarily places ReShade Full Add-on, rendering add-ons and DLSS-related runtime files next to the DayZ executable. **Launching normal DayZ / BattlEye while those files are present can trigger anti-cheat action and may result in a kick, account restriction or ban.** There is **no anti-cheat / ban-safety guarantee**.
>
> **Never launch `DayZ_x64.exe`, `DayZ_BE.exe` or `DayZLauncher.exe` while the demo payload is staged.** Use only `DayZDiag_x64.exe` against the local server on `127.0.0.1:2302`.
>
> After you are finished: run the cleanup/uninstaller, confirm `STATE: MULTIPLAYER CLEAN`, **then use Steam → DayZ → Properties → Installed Files → Verify integrity of game files before returning to normal multiplayer.**

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

### Public beta — v1.0-beta7

Use GitHub's **Code → Download ZIP** button or download the current source archive directly:

https://github.com/darkmensch95-cmyk/DayZ-DLSS5-Offline-Demo/archive/refs/heads/main.zip

The repository intentionally contains **no third-party ReShade/NVIDIA/RenoDX/Lumenite binaries or shader packs**. The installer downloads pinned components from their documented upstream sources and verifies exact hashes where applicable.

> [!IMPORTANT]
> **beta7 includes fixes found during a real Windows/DayZ smoke test on the reference RTX 5090 machine.** The installer completed successfully, the local DayZDiag server/client launch path was verified, and the automatic cleanup was manually checked afterward: no known ReShade/DLSS5 demo payload remained in the DayZ root and BattlEye remained in its normal Steam state. This is still a beta and not a universal guarantee for every system/update. See [Testing status](./docs/TESTING_STATUS.md).

## Where the project is installed

The GitHub ZIP/source folder itself can be extracted **anywhere** — Desktop, Downloads, etc. It is only the installer source.

Run `INSTALL.cmd` from that extracted folder. The installer creates the actual working installation at:

```text
C:\DayZ_DLSS5_OFFLINE_DEMO
```

After installation, launch the demo from:

```text
C:\DayZ_DLSS5_OFFLINE_DEMO\START_OFFLINE_DEMO.cmd
```

Do **not** keep launching `START_OFFLINE_DEMO.cmd` from the downloaded/extracted GitHub source folder after installation. The installed copy under `C:\DayZ_DLSS5_OFFLINE_DEMO` contains the generated `config.json`, downloaded payload, LocalHost files, logs and runtime state the launcher needs.

The actual DayZ game directory is **not** the permanent home of this project. During an active offline demo only, the launcher temporarily stages the known ReShade/DLSS5 payload next to DayZ, then removes it again during cleanup.

## Quick start

1. Close DayZ, DayZDiag and DayZ Launcher.
2. Download the repository ZIP and extract it anywhere, for example to your Desktop.
3. Run `INSTALL.cmd` from the extracted GitHub folder as administrator.
4. Read the warning and type exactly: `I UNDERSTAND OFFLINE ONLY`.
5. Wait until the installer reports `INSTALLATION COMPLETE`. The working install is now in `C:\DayZ_DLSS5_OFFLINE_DEMO`.
6. From now on, run `C:\DayZ_DLSS5_OFFLINE_DEMO\START_OFFLINE_DEMO.cmd` — **not** the START file in the downloaded GitHub folder.
7. Type exactly: `OFFLINE`.
8. Wait for the local server and DayZDiag client. beta7 waits for the actual `DayZDiag_x64.exe -server` process, gives the server 40 seconds to finish CE/Hive startup, then stages the render payload and launches the local client.
9. In DayZ, disable Hardware Antialiasing / MSAA.
10. `Home` opens ReShade. In the tested RenoDX build, `F6` toggles Neural Rendering.

If an earlier installer attempt failed and left a recognized partial `C:\DayZ_DLSS5_OFFLINE_DEMO` folder, the current `INSTALL.cmd` can verify the DayZ root is clean and offer a controlled `RETRY` instead of blindly deleting unknown data.

> [!WARNING]
> While the demo payload is staged, **do not start normal DayZ, DayZ Launcher or BattlEye**. This setup is for the local DayZDiag client only.

### Mandatory cleanup before normal multiplayer

When you are done with the experiment:

1. Close the DayZDiag client and local server.
2. Run `C:\DayZ_DLSS5_OFFLINE_DEMO\CLEAN_FOR_MULTIPLAYER.cmd` (or `UNINSTALL.cmd` if removing the project).
3. Run `C:\DayZ_DLSS5_OFFLINE_DEMO\STATUS.cmd` and require:

```text
STATE: MULTIPLAYER CLEAN
```

4. **Then verify the DayZ installation through Steam:**

```text
Steam → Library → DayZ → Properties → Installed Files → Verify integrity of game files
```

5. Only after cleanup **and** the Steam verification should you return to normal BattlEye multiplayer.

The cleanup/status tools check the files known to this project. They are **not a promise from BattlEye or a server operator that your system is ban-safe**.

## Runtime verification model

The public beta pins exact hashes for the downloaded/extracted runtime components.

For `nvngx_dlssnr.dll` from the pinned `dlssnr-310.8.SF-v2` package, Windows reports Authenticode status `NotSigned`. The installer therefore requires the exact pinned extracted SHA-256 for that file instead of falsely requiring/claiming a valid NVIDIA signature.

The regular `nvngx_dlss.dll` must match its pinned SHA-256 **and** have a valid NVIDIA Authenticode signature.

See [Sources and licenses](./docs/SOURCES_AND_LICENSES.md) and [Testing status](./docs/TESTING_STATUS.md) for the exact values and provenance notes.

## Manual installation

Don't trust a random PowerShell installer from Reddit? Fair enough.

The manual path explains the whole stack and lets you download every component yourself:

- [Full manual installation guide](./docs/FULL_MANUAL_INSTALL_GUIDE_NO_INSTALLER.md)
- [BattlEye / online-use warning and liability](./docs/BATTLEYE_WARNING_AND_LIABILITY.md)
- [Testing status](./docs/TESTING_STATUS.md)
- [All download links](./docs/ALL_DOWNLOAD_LINKS.md)
- [Sources and licenses](./docs/SOURCES_AND_LICENSES.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [Manual cleanup](./docs/MANUAL_CLEANUP.md)
- [Reddit release-post draft](./docs/REDDIT_RELEASE_POST.md)

## Important DayZ depth setup

The exact depth resource can differ by PC, resolution and game version.

Reference test at 2560×1440 / DayZ 1.29:

- full-resolution `D24S8`
- **Copy depth buffer before clear operations**
- reference scene clear: `CLEAR 1`

Use `DisplayDepth` to verify that the selected depth buffer actually shows recognizable DayZ scene geometry.

## Tested presets included

The repo includes sanitized plain-text presets based on the working showcase:

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
- showcase validation settings
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

This is an unofficial community technical experiment. **Use is entirely at your own risk.**

The project is not affiliated with, sponsored by, approved by, or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder, RankFTW, DayZ_LocalHost, or their authors/maintainers.

The scripts and documentation are provided **AS IS**, without warranty. To the maximum extent permitted by applicable law, the authors/distributors accept no responsibility for bans, kicks, account restrictions, lost data, corrupted game files, crashes, system instability, or other damage caused by use or misuse of this project. Nothing here excludes rights or liability that cannot legally be excluded.

No author or distributor can guarantee that BattlEye, a game/server update, server administrator, driver update, or other software will consider any setup safe. **If you use these files with normal DayZ/BattlEye or on an online server, you accept the risk of anti-cheat action, including a possible ban.**

## Credits / upstream projects

- ReShade — https://reshade.me/
- ReShade shaders — https://github.com/crosire/reshade-shaders
- DLSS5-Feeder — https://github.com/jlrouzies-fr/DLSS5-Feeder
- LumeniteFX — https://github.com/umar-afzaal/LumeniteFX
- RHI release repository — https://github.com/RankFTW/rhi-repo/releases
- DayZ LocalHost — https://github.com/Cho-Buggers/DayZ_LocalHost
- Bohemia DayZ Modding Basics — https://community.bohemia.net/wiki/DayZ%3AModding_Basics
- NVIDIA DLSS — https://developer.nvidia.com/rtx/dlss
