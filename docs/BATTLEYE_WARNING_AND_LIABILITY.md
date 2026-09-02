# BattlEye / online-use warning and liability notice

> [!CAUTION]
> ## OFFLINE / LOCAL DAYZDIAG ONLY
> **Do not use this project on official, community, public, private, or any other BattlEye-protected multiplayer server.**

This project temporarily places a ReShade Full Add-on DXGI proxy, rendering add-ons and DLSS-related runtime files next to the DayZ executable.

While those files are present, **do not launch**:

```text
DayZ_x64.exe
DayZ_BE.exe
DayZLauncher.exe
```

Use only:

```text
DayZDiag_x64.exe
```

against the local test server:

```text
127.0.0.1:2302
```

## Why this warning is so prominent

BattlEye-protected multiplayer is outside the intended use of this project. Injectors, proxy DLLs, Full Add-on ReShade components, rendering hooks or other modified runtime files can be detected or rejected by anti-cheat software.

**Launching normal DayZ/BattlEye with the demo payload staged may lead to a kick, restriction or ban.** Nobody maintaining or distributing this project can guarantee otherwise.

This project does **not** disable, patch, circumvent or bypass BattlEye, and it is not designed to do so.

## Required cleanup before returning online

When finished with the experiment:

1. Close the DayZDiag client and local server.
2. Run `CLEAN_FOR_MULTIPLAYER.cmd` or `UNINSTALL.cmd`.
3. Run `STATUS.cmd`.
4. Require:

```text
STATE: MULTIPLAYER CLEAN
```

5. **Then verify DayZ through Steam:**

```text
Steam
→ Library
→ DayZ
→ Properties
→ Installed Files
→ Verify integrity of game files
```

6. Wait for Steam to finish completely.
7. Only then launch normal DayZ/BattlEye again.

`STATUS.cmd` only checks the files and conditions known to this project. A clean result is **not** a certification from BattlEye, Bohemia Interactive or any server administrator.

## Liability disclaimer

This software, configuration and documentation are provided **AS IS**, without warranty of any kind. Use is entirely at your own risk.

To the maximum extent permitted by applicable law, the authors/distributors accept no responsibility for bans, kicks, account restrictions, lost data, corrupted files, game repair/reinstallation, crashes, system instability or other losses/damages resulting from use or misuse of this project.

If you use these files outside the documented local/offline DayZDiag workflow, including on BattlEye-protected multiplayer, you accept the associated risk yourself.

Nothing in this notice excludes rights or liability that cannot legally be excluded under applicable law.

This project is unofficial and is not affiliated with, sponsored by, approved by, or endorsed by Bohemia Interactive, BattlEye, NVIDIA, ReShade, RenoDX, LumeniteFX, DLSS5-Feeder, RankFTW, DayZ_LocalHost, or their respective authors/maintainers.
