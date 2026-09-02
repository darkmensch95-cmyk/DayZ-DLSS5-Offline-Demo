# Testing status

## Current public beta: v1.0-beta7

The **DayZ rendering path itself** has been field-tested on the original reference machine (DayZ 1.29, RTX 5090, 2560x1440) and produced a working NGX/DLAA feed with DLSS 5 Neural Rendering output.

beta7 also incorporates fixes found during a real Windows/DayZ installer/launcher smoke test on that same reference machine.

### What was actually tested on the reference machine

The following parts were run for real rather than only statically inspected:

1. the installer completed successfully;
2. the pinned DLSS NR `310.8.SF-v2` runtime passed the exact SHA-256 check while correctly reporting `NotSigned` instead of being falsely rejected;
3. the LocalHost DayZDiag server started and reached CE/Hive initialization;
4. the public launcher detected the real `DayZDiag_x64.exe -server` process and successfully continued to the local DayZDiag client launch;
5. the launcher cleanup ran after the session;
6. a separate manual PowerShell audit found no known ReShade/DLSS5 demo payload left in the DayZ root;
7. no DayZ/DayZDiag/BattlEye process remained running after cleanup;
8. `DayZ_BE.exe` and the normal `BattlEye` directory were present;
9. no `.disabled` BattlEye names were present;
10. the resulting manual audit reported `STATE: CLEAN`.

This is still a beta. A successful run on the reference machine is not a guarantee that every Windows configuration, future DayZ build, driver or upstream component will behave identically.

### beta7 launcher readiness fix

The earlier launcher waited for `[CE][Hive] :: Init sequence finished.` specifically inside `script_*.log`. On the reference system that message was visible in the LocalHost/CE output but was not reliably available through the file the launcher was polling, so the launcher timed out after 120 seconds even though the server was actually ready.

beta7 no longer depends on that fragile logfile match. It:

- starts the local server while the DayZ root is still clean;
- waits until a real `DayZDiag_x64.exe` process with `-server` is present;
- gives that server a conservative 40-second startup window (the reference run reached CE/Hive init in about 26 seconds);
- verifies the server process is still alive;
- only then stages the ReShade/DLSS5 payload and launches the local DayZDiag client.

This exact simplified readiness method is the one that worked in the real reference-machine test.

### Important RenoDX note

The upstream `renodx-dlss5-4.70` release asset was replaced/updated after the original showcase test. The original tested extracted add-on hash recorded by the project was:

```text
E1C28FDE0922B12FC10734E58C3D24A36808E575247F4FD4F36226540D7EE023
```

The current upstream 4.70 asset extracts to:

```text
D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952
```

beta7 pins the **current** upstream hash so another upstream replacement cannot silently change the installed binary.

### DLSS NR signature note

The pinned `nvngx_dlssnr.dll` extracted from `dlssnr-310.8.SF-v2` reports Authenticode status `NotSigned` on the reference Windows machine.

The installer accepts that file only when its exact pinned extracted SHA-256 matches:

```text
6EB209E764F39872625DEBD6ABAF45E2BB6322F6F270F781F70C059AE30B3927
```

The regular `nvngx_dlss.dll` remains required to match its pinned SHA-256 **and** have a valid NVIDIA Authenticode signature.

### Before normal BattlEye multiplayer

Even after the cleanup reports clean, the documented final step remains mandatory:

1. close the demo;
2. run `CLEAN_FOR_MULTIPLAYER.cmd` if needed;
3. run `STATUS.cmd` and require `STATE: MULTIPLAYER CLEAN`;
4. use Steam → DayZ → Properties → Installed Files → **Verify integrity of game files**;
5. only then return to normal DayZ/BattlEye multiplayer.

The project cannot provide an anti-cheat or ban-safety guarantee.
