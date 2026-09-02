# Reddit release post draft

## Suggested title

**DayZ DLSS 5 Neural Rendering — offline installer + full manual setup guide**

## Suggested post

A bunch of people asked for a tutorial after the DayZ DLSS 5 experiment, so I cleaned the setup up and put it into a public beta.

# ⚠️ BIG WARNING FIRST — OFFLINE / LOCAL DAYZDIAG ONLY ⚠️

**DO NOT USE THIS ON OFFICIAL, COMMUNITY, PUBLIC, PRIVATE OR ANY OTHER BATTLEYE-PROTECTED MULTIPLAYER SERVER.**

The setup temporarily uses ReShade Full Add-on, rendering add-ons and DLSS-related runtime files next to the DayZ executable. **Launching normal DayZ/BattlEye while those files are present can trigger anti-cheat action and may result in a kick, account restriction or ban.** There is no "ban proof" guarantee here.

Use only `DayZDiag_x64.exe` against the local server on `127.0.0.1:2302`.

Do **not** launch `DayZ_x64.exe`, `DayZ_BE.exe` or `DayZLauncher.exe` while the demo payload is staged.

If you ignore the instructions and use it online / with BattlEye, you do so entirely at your own risk.

What it actually does:

```text
DayZ DX11
→ ReShade
→ copied DayZ depth
→ reconstructed Lumenite motion vectors
→ DLSS5-Feeder
→ synthetic native-resolution DLAA / NGX evaluation
→ RenoDX DLSS 5
→ DLSS Neural Rendering
```

So no, this is not native DayZ DLSS support and it isn't frame generation. It's basically bullying DayZ's render pipeline into feeding the information DLSS 5 expects :D

My tested setup:

- DayZ 1.29
- RTX 5090
- 2560×1440
- ReShade 6.8.0 Full Add-on
- DLSS5-Feeder 0.7.0
- RenoDX DLSS5 4.70
- DLSS NR 310.8.SF-v2
- DLSS 310.8.0
- LumeniteFX Kernel motion vectors
- native-resolution / 100% DLAA feed

The repo includes:

- installer scripts
- offline-only launcher
- automatic cleanup
- a watchdog that aborts if normal DayZ/BattlEye is launched while the demo payload is staged
- status + self-test tools
- the tested ReShade / feeder preset from my working showcase
- a full manual installation guide if you don't want to run the installer
- all source/download links
- troubleshooting
- cleanup instructions
- sources/licenses
- disclaimers

The project does **not** bundle third-party ReShade/NVIDIA/RenoDX/Lumenite binaries. The installer downloads the pinned/tested components from the documented upstream sources instead.

One important limitation:

DayZ obviously doesn't give this setup native DLSS motion vectors. Lumenite is reconstructing them. Normal temporal history caused a lot of smearing in my test, so the included showcase preset uses `reset_every=1`. That removes the smearing, but it also means this should be treated as a technical/image-quality demo rather than a perfect native DLSS integration.

The only thing that may still need one manual click on another PC is the DayZ depth buffer. If `DisplayDepth` looks wrong:

```text
ReShade → Add-ons → Generic Depth
→ choose the full-resolution D24S8 buffer
→ Copy depth buffer before clear operations
→ choose the main scene clear
```

On my DayZ 1.29 / 2560×1440 test, that was `CLEAR 1`.

## Before going back to normal multiplayer — do all of this

1. Close the DayZDiag client and local server.
2. Run `CLEAN_FOR_MULTIPLAYER.cmd` (or `UNINSTALL.cmd` if removing the project).
3. Run `STATUS.cmd`.
4. Require:

```text
STATE: MULTIPLAYER CLEAN
```

5. **Then verify DayZ through Steam:**

```text
Steam → Library → DayZ → Properties → Installed Files → Verify integrity of game files
```

6. Only after cleanup **and** the Steam file verification should you launch normal DayZ/BattlEye again.

The cleanup/status scripts only check the files known to this project. They are **not** a promise from BattlEye or any server admin that your system is ban-safe.

### Small liability disclaimer

This is an unofficial technical experiment provided **AS IS**, without warranty. Use it entirely at your own risk. To the maximum extent permitted by applicable law, the authors/distributors accept no responsibility for bans, kicks, account restrictions, lost data, corrupted files, crashes, system instability or other damage caused by use or misuse. This project is not affiliated with or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder or the other referenced projects.

GitHub:

https://github.com/darkmensch95-cmyk/DayZ-DLSS5-Offline-Demo

Showcase video:

https://youtu.be/68b9V59VxeM

Full manual setup instructions:

`docs/FULL_MANUAL_INSTALL_GUIDE_NO_INSTALLER.md`

BattlEye / online-use warning:

`docs/BATTLEYE_WARNING_AND_LIABILITY.md`

All sources/download links:

`docs/ALL_DOWNLOAD_LINKS.md`

This is still a beta. The actual DayZ render stack was tested on my machine, but obviously I can't promise every future DayZ/ReShade/driver update will keep working.

Have fun breaking an old engine in new ways :D

## Suggested first comment

For anyone who doesn't trust random PowerShell installers from Reddit (fair lol): there is a full manual guide in the repo. You can download every component yourself from ReShade/GitHub, build the payload manually, start the local DayZDiag server first, and only stage the graphics files for the local Diag client.

**Again: do not use this with normal DayZ/BattlEye. When you're done, clean it, check `STATE: MULTIPLAYER CLEAN`, and verify the DayZ game files in Steam before going back online.**

Video:
https://youtu.be/68b9V59VxeM
