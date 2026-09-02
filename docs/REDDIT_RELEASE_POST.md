# Reddit release post draft

## Suggested title

**DayZ DLSS 5 Neural Rendering — offline installer + full manual setup guide**

## Suggested post

A bunch of people asked for a tutorial after the DayZ DLSS 5 experiment, so I cleaned the setup up and put it into a public beta.

**BIG WARNING FIRST:**

**THIS IS OFFLINE / LOCAL DAYZDIAG ONLY.**

Do not use this on official, community or any other BattlEye-protected multiplayer server. The setup temporarily uses ReShade Full Add-on and graphics add-ons next to the DayZ executable. The launcher is built around a local DayZDiag server/client workflow and cleans the temporary files again after the demo, but there is no magical "ban proof" guarantee.

If you decide to ignore the instructions and use it online, that's entirely on you.

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

Before going back to normal multiplayer:

1. Close the DayZDiag demo.
2. Run `CLEAN_FOR_MULTIPLAYER.cmd`.
3. Run `STATUS.cmd`.
4. It should say:

```text
STATE: MULTIPLAYER CLEAN
```

If you're still unsure, verify DayZ through Steam.

GitHub:

https://github.com/darkmensch95-cmyk/DayZ-DLSS5-Offline-Demo

Showcase video:

https://youtu.be/68b9V59VxeM

Full manual setup instructions:

`docs/FULL_MANUAL_INSTALL_GUIDE_NO_INSTALLER.md`

All sources/download links:

`docs/ALL_DOWNLOAD_LINKS.md`

This is still a beta. The actual DayZ render stack was tested on my machine, but obviously I can't promise every future DayZ/ReShade/driver update will keep working.

Have fun breaking an old engine in new ways :D

## Suggested first comment

For anyone who doesn't trust random PowerShell installers from Reddit (fair lol): there is a full manual guide in the repo. You can download every component yourself from ReShade/GitHub, build the payload manually, start the local DayZDiag server first, and only stage the graphics files for the local Diag client.

Video:
https://youtu.be/68b9V59VxeM
