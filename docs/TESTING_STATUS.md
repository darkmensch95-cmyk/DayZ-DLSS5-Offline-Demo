# Testing status

## Current release candidate: v1.0-beta5

The **DayZ rendering path itself** has been field-tested on the original reference machine (DayZ 1.29, RTX 5090, 2560x1440) and produced a working NGX/DLAA feed with DLSS 5 Neural Rendering output.

The public installer/launcher is a separate layer and must not be described as "10x end-to-end tested". It has undergone repeated static, source, hash, configuration, cleanup and PowerShell-parser audits.

### Important RenoDX note

The upstream `renodx-dlss5-4.70` release asset was replaced/updated after the original showcase test. The original tested extracted add-on hash recorded by the project was:

```text
E1C28FDE0922B12FC10734E58C3D24A36808E575247F4FD4F36226540D7EE023
```

The current upstream 4.70 asset (checked 2026-09-02) extracts to:

```text
D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952
```

v1.0-beta5 pins the **current** upstream hash so an upstream replacement cannot silently change the installed binary again. Because this is not byte-identical to the original showcase binary, a real Windows/DayZ smoke test of beta5 is required before the release should be announced as tested.

### Release gate

Before announcing beta5 publicly, run the full flow on the reference Windows machine:

1. clean/Steam-verified DayZ start state;
2. `INSTALL.cmd`;
3. installer `SELF_TEST`;
4. `START_OFFLINE_DEMO.cmd`;
5. verify ReShade + Lumenite + DLSS5 Feed load;
6. verify `dlss5-feed.log` contains `feature ready` and delivered frames;
7. close the demo normally;
8. run `STATUS.cmd`;
9. require `STATE: MULTIPLAYER CLEAN`;
10. run Steam **Verify integrity of game files** before normal BattlEye multiplayer.

Until that real smoke test passes, beta5 should be treated as a **release candidate**, not a proven universal installer.
