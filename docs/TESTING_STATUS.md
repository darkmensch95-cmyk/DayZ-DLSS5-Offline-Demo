# Testing status

## Current release candidate: v1.0-beta6

The **DayZ rendering path itself** has been field-tested on the original reference machine (DayZ 1.29, RTX 5090, 2560x1440) and produced a working NGX/DLAA feed with DLSS 5 Neural Rendering output.

The public installer/launcher is a separate layer and must not be described as "10x end-to-end tested". It has undergone repeated static, source, hash, configuration, cleanup and PowerShell-parser audits, but beta6 still needs the full real Windows/DayZ smoke test below before it should be announced as a tested public release.

### Important RenoDX note

The upstream `renodx-dlss5-4.70` release asset was replaced/updated after the original showcase test. The original tested extracted add-on hash recorded by the project was:

```text
E1C28FDE0922B12FC10734E58C3D24A36808E575247F4FD4F36226540D7EE023
```

The current upstream 4.70 asset extracts to:

```text
D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952
```

v1.0-beta6 pins the **current** upstream hash so another upstream replacement cannot silently change the installed binary. Because this is not byte-identical to the original showcase binary, a real Windows/DayZ smoke test is required.

### DLSS NR signature note

The pinned `nvngx_dlssnr.dll` extracted from `dlssnr-310.8.SF-v2` currently reports Authenticode status `NotSigned` on Windows. beta5 incorrectly required every NVIDIA-named runtime to have a valid Authenticode signature and therefore aborted during installation.

beta6 fixes that check. The DLSS NR runtime is accepted only when its exact pinned extracted SHA-256 matches:

```text
6EB209E764F39872625DEBD6ABAF45E2BB6322F6F270F781F70C059AE30B3927
```

The regular `nvngx_dlss.dll` remains required to match its pinned SHA-256 **and** have a valid NVIDIA Authenticode signature.

### Release gate

Before announcing beta6 publicly, run the full flow on the reference Windows machine:

1. clean/Steam-verified DayZ start state;
2. fresh download of the current GitHub source archive;
3. `INSTALL.cmd`;
4. installer `SELF_TEST` completes successfully;
5. `START_OFFLINE_DEMO.cmd`;
6. verify ReShade + Lumenite + DLSS5 Feed + RenoDX Neural Rendering load;
7. verify `dlss5-feed.log` contains `feature ready` and delivered frames;
8. close the demo normally;
9. run `STATUS.cmd`;
10. require `STATE: MULTIPLAYER CLEAN`;
11. run Steam **Verify integrity of game files** before normal BattlEye multiplayer.

Until that real smoke test passes, beta6 should be treated as a **release candidate**, not a proven universal installer.
