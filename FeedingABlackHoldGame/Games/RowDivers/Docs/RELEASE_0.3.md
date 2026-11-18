# Railway Fury 0.3 — controller review fixes

Final Windows Steam builds uploaded November 13, 2026 (America/New_York):

| Edition | App ID | Final build ID |
| --- | --- | --- |
| Full | 5520300 | 26660299 |
| Demo | 5520330 | 26660301 |

These builds are uploaded and unassigned; the public Steam branches were not
changed. Earlier 0.3 candidates 26660209 / 26660216 are superseded. Choose the
**final IDs above** for testing and review. Store controller categories and
developer-recommended Steam Input templates were not changed.

The existing public [itch.io demo](https://beep2bleep.itch.io/railway-fury-demo)
was updated with **Railway Fury Demo 0.3 — Browser** and **Railway Fury Demo
0.3 — Windows**. Browser play and the Windows platform flag were preserved.
`Build - RailwayFury/Demo/build_manifest.json` records the ZIP sizes and SHA-256s.
No full-game itch.io project was created.
The published hosted Web build reached its main menu and visibly reported v0.3.
Upload/page and hosted-menu screenshots are saved in `Docs/Previews/itch-0.3-*.png`.

## Changes

- Launcher and upgrade menus keep the controller cursor available for language,
  settings, collections, achievements, reset/confirmation, leaderboard and exit
  controls. Menu exit and language buttons also accept focus navigation.
- Left stick moves the pointer; D-pad switches to focused selection. Trigger
  confirmation now uses GUI input, so checkboxes toggle and dropdowns open.
- A/Cross, right bumper and right trigger confirm; B/Circle cancels native
  dropdowns and returns through menus. X/Square plus left stick pans the upgrade
  tree; right stick scrolls lists and zooms the tree under the pointer.
- Upgrade navigation stops while a settings/popup overlay is open. Switching
  navigation or pressing Back releases held synthetic clicks; disconnecting
  a controller releases left and right synthetic mouse buttons.
- Y/Triangle alternates the unlocked bow's Hold/Auto modes.
- Web exports omit Gothic editor-preview assets to stay under itch.io's file
  size limit. Runtime Gothic mode remains disabled in the published game.

The working checkout already contained unrelated presentation/localization
changes. They were preserved and included in these exports. Runtime source and
binary hashes are in `StoreAssets_RailwayFury/steam/build-manifest.json`.

## Verification

- 92 controller/combat checks, 19 existing menu checks, and 36 new controller UI
  checks passed against source.
- Each final Steam PCK passed 15 isolated package checks and 36 controller menu
  checks. Each also exited successfully after synthetic controller activation
  of the actual Quit button.
- The final itch.io Windows PCK passed 25 isolated package checks and the same
  36 controller menu checks. Browser PCK: 185,377,300 bytes (under 200 MiB).
- A rendered source menu/settings/upgrade pass was inspected. Headless fixtures
  produce existing shader/display-server and resource-shutdown diagnostics;
  these are not a physical-device certification.

No physical Xbox/PlayStation controller, Steam Input layout, reconnection or
full advanced-save playthrough was certified. Run
[CONTROLLER_ACCEPTANCE_0.3.md](CONTROLLER_ACCEPTANCE_0.3.md) before representing
Full Controller Support as confirmed or resubmitting the build for review.

## Reproduce

From the repository root:

```powershell
& tools/railway_steam/build.ps1
& tools/railway_demo/build.ps1
& 'Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifyController.gd
& 'Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifyControllerMenus.gd
```

Use `--main-pack` with an absolute PCK path, a source-free `pack_runtime` folder,
and the absolute external `VerifyControllerMenus.gd` path to repeat packaged UI
checks. Append `-- --quit` to exercise the real Quit handler in a separate process.
`tools/railway_steam/upload-final-0.3.log` contains final SteamPipe receipts.
