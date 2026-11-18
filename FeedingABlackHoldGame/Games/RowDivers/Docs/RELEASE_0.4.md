# Railway Fury 0.4 — complete controller menu flows

Steam Windows uploads completed November 16, 2026 (America/New_York):

| Edition | App ID | Build ID |
| --- | --- | --- |
| Full | 5520300 | **26717191** |
| Demo | 5520330 | **26717195** |

Both builds are uploaded and unassigned. No Steam branch was set live, no store
category/template was changed, and no review request was submitted. These builds
supersede 0.3 for controller testing.

Local play:

- `Build - RailwayFury/Steam/Full/RailwayFury.exe`
- `Build - RailwayFury/Steam/Demo/RailwayFuryDemo.exe`

Use those release binaries rather than the older `Windows-QA` build. Keep each
executable's PCK and DLLs alongside it.

The existing public [itch.io demo](https://beep2bleep.itch.io/railway-fury-demo)
now serves **Railway Fury Demo 0.4 — Browser** and **Railway Fury Demo 0.4 —
Windows**. Browser play and the Windows platform flag were verified after saving.
The hosted game boots to its menu and visibly reports v0.4. Page/upload and
hosted-menu evidence is in `Docs/Previews/itch-0.4-*.png`; ZIP sizes and SHA-256s
are recorded in `Build - RailwayFury/Demo/build_manifest.json`.

The controller audit found failures not covered by 0.3's isolated menu tests:
results discarded Start/Back and lacked a default selection; upgrade tooltips
removed controller focus; the shared pause screen could intercept input;
confirmation windows did not all accept controller Cancel; and synthetic pointer
coordinates could be scaled twice at different window resolutions.

The fixes introduce explicit controller menu contexts, parent-aware Back handling,
results replay/back actions, pause/results Quit buttons, viewport-local pointer
events, focus-preserving upgrades, confirmed/cancelled purchases, scrollable
panels, disconnect pause/recovery and contextual controller glyph footers.
See [CONTROLLER_MODAL_AUDIT_0.4.md](CONTROLLER_MODAL_AUDIT_0.4.md) for the complete
controls, coverage matrix and remaining physical-device checks.

## Validation

- Source full/demo flow: **142 checks passed**, including a rendered 1280×720
  route after exercising window-mode changes.
- Full QA release package: **142 flow checks passed**; real Quit handlers exited
  successfully from **6** major modes in separate processes.
- Demo QA release package (demo feature forced): **70 flow checks passed**;
  **5** applicable Quit routes exited successfully.
- Both ending choices/return actions: **6 checks passed**.
- Combat/controller suite: **92 checks passed**; legacy controller menu suite:
  **36 checks passed**; menu/presentation regression suite: **19 checks passed**.
- Actual shipping full/demo Steam packages: **15 isolated checks each** for
  version, SDK/dependencies, art, analytics routing, save folders and edition gates.
- itch.io Windows package: **25 isolated checks passed**. Web PCK:
  **185,422,788 bytes**, under the 200 MiB hosting limit.

The QA packages use the same runtime scripts as release, with a separate QA
user-data folder and feature. Fixtures deliver synthetic gamepad events through
Godot input, seed eligible saves and induce results states. They do not certify
physical Xbox/PlayStation pads or Steam Input templates. Tests never reset the
normal gameplay save. Existing renderer/resource-shutdown diagnostics are present
in fixture logs; there are no fixture script errors or failed assertions.

`StoreAssets_RailwayFury/steam/build-manifest.json` records source fingerprints,
shipping binaries, QA package hashes and the successful Steam upload receipts.
`tools/railway_steam/upload-0.4.log` contains the SteamPipe receipts.
Unrelated existing presentation/localization work was preserved in this checkout
and included in these exports.
