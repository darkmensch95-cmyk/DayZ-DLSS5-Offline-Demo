# Sources, components and license notes

This repository intentionally contains the project's **original scripts/documentation and plain-text tested preset files**, but does **not** bundle third-party graphics binaries or shader packs. The installer downloads external components from the upstream sources below.

## ReShade
Official website: https://reshade.me/

Source: https://github.com/crosire/reshade

Tested version: ReShade 6.8.0 Full Add-on.

Known SHA-256 for the installer used by this project:

```text
AFE4C8F13048306307983B8B3D41D5BF00A86820440B0E57DEA10950E1176445
```

ReShade source license: BSD 3-Clause. ReShade itself remains subject to its own license/terms.

## ReShade standard shaders
https://github.com/crosire/reshade-shaders

Branch used: `slim`.

Not bundled in this repository/package by the installer; fetched from upstream.

## DLSS5-Feeder
Project: https://github.com/jlrouzies-fr/DLSS5-Feeder

Pinned release: https://github.com/jlrouzies-fr/DLSS5-Feeder/releases/tag/v0.7.0

Files used:
- `dlss5-feed.addon64`
- `DLSS5_Feed.fx`

Not bundled as third-party binary/shader assets; downloaded from upstream.

## LumeniteFX
Official repository: https://github.com/umar-afzaal/LumeniteFX

Branch used: `mainline`.

License information: https://github.com/umar-afzaal/LumeniteFX/blob/mainline/LICENSE.md

The installer fetches the official repository instead of rehosting the shader pack.

## RenoDX DLSS 5 generic add-on
Community release repository: https://github.com/RankFTW/rhi-repo/releases

Pinned release: https://github.com/RankFTW/rhi-repo/releases/tag/renodx-dlss5-4.70

Target file: `renodx-dlss5.addon64`

Known tested SHA-256:

```text
E1C28FDE0922B12FC10734E58C3D24A36808E575247F4FD4F36226540D7EE023
```

## NVIDIA DLSS Neural Rendering runtime
Pinned release page used by the tested setup:
https://github.com/RankFTW/rhi-repo/releases/tag/dlssnr-310.8.SF-v2

Target file: `nvngx_dlssnr.dll`

The installer checks that NVIDIA DLLs have a valid NVIDIA Authenticode signature.

NVIDIA software remains proprietary and is not relicensed by this project.

## NVIDIA DLSS runtime
Pinned release page:
https://github.com/RankFTW/rhi-repo/releases/tag/dlss-310.8.0

Target file: `nvngx_dlss.dll`

NVIDIA DLSS developer information:
https://developer.nvidia.com/rtx/dlss

## DayZ LocalHost helper
Repository: https://github.com/Cho-Buggers/DayZ_LocalHost

Used only as a convenience wrapper for a local DayZDiag server/client workflow.

## Bohemia Interactive DayZ documentation
DayZ Modding Basics:
https://community.bohemia.net/wiki/DayZ%3AModding_Basics

DayZ Diag Menu:
https://community.bohemia.net/wiki/DayZ%3ADiag_Menu

This project does not modify or redistribute DayZ executables.

## Project preset files
This repository includes the project's tested plain-text configuration:

```text
config/ReShade.ini
config/dlss5.ini
config/dlss5-feed.cfg
```

These files contain no third-party binaries and are included so users do not have to reproduce the tested DayZ-specific settings by hand.

## Project scripts/documentation license
The repository's **original scripts and documentation** are released under the MIT License in `LICENSE.txt`.

That license does **not** relicense DayZ, BattlEye, NVIDIA software, ReShade, DLSS5-Feeder, LumeniteFX, RenoDX/community binaries, DayZ_LocalHost, or any other third-party project.

## No affiliation / endorsement
This project is unofficial and is not affiliated with, sponsored by, approved by, or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder, RankFTW, DayZ_LocalHost, or their authors/maintainers.
