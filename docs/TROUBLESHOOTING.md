# Troubleshooting

## ReShade says some extensions/add-ons could not be loaded
Open `ReShade.log`. If it says add-ons were skipped because the build has only limited add-on functionality, install **ReShade 6.8.0 Full Add-on support**, not the normal build.

## `DLSS5_Feed.fx` is missing / technique not found
Make sure `DLSS5_Feed.fx` exists in `reshade-shaders\Shaders\` and reload ReShade.

## RenoDX is not in the normal shader list
The RenoDX component can appear as its own ReShade tab called **DLSS 5 Neural Rendering**. Check the Add-ons tab and `ReShade.log` for `Registered add-on "DLSS 5 Neural Rendering"`.

## DisplayDepth is purple, white, black, or nonsense
Go to `ReShade → Add-ons → Generic Depth` and select the full-resolution scene depth buffer. In the 2560×1440 DayZ 1.29 reference test it was a full-resolution `D24S8` resource. Enable **Copy depth buffer before clear operations** and select the main scene clear. The reference test used `CLEAR 1`, but this can differ.

## Everything smears while moving the camera
Confirm that `dlss5-feed.cfg` contains `reset_every=1` and use the included `config/dlss5.ini`. Normal temporal history caused strong ghosting with reconstructed DayZ motion vectors in the reference test.

## Feeder reports almost no motion vectors
Make sure `Lumenite_Kernel` is enabled and appears **above** `DLSS 5 Feed`. Confirm `DLSS5_MV_PROVIDER=3` in `ReShade.ini`. Copy all Lumenite include files and textures, not only the kernel shader.

## Local client says server unreachable
Use `-connect=127.0.0.1:2302` and confirm the local server is still running.

## DayZ LocalHost looks for `C:\DayZDiag_x64.exe`
Edit `DZ_server.ps1` and set `$dzPath` to the actual Steam DayZ folder.

## `Documents\DayZServer` does not exist
Run:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\Documents\DayZServer"
```

## Feeder initializes but there are no delivered frames
Check:
- ReShade Full Add-on build
- `DLSS5_Feed.fx` loaded
- Lumenite Kernel active
- correct DayZ depth
- `nvngx_dlss.dll` present
- `nvngx_dlssnr.dll` present
- `renodx-dlss5.addon64` present
- `ReShade.log`
- `dlss5-feed.log`

A working log should eventually show `feature ready` and delivered frames.
