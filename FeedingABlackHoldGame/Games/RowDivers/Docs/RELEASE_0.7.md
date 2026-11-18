# Railway Fury 0.7

Rebuilt and uploaded November 18, 2026 for Steam Full and Demo Windows.

- Demo main menu and upgrade screen show Wishlist Now. Completing the first
  demo level shows a large Wishlist Now button on the result screen.
- All wishlist links target https://store.steampowered.com/app/5520300/Railway_Fury/.
- Demo completion blocks every result action for at least five seconds, using
  a draining/fading circular countdown for mouse, keyboard and controller.
  The controller cursor then targets Wishlist Now.
- Ordinary controller death retains its one-second countdown and cursor choices.
- Actual packaged UI verifies THE RAILWAY CLAIMS YOU and whole-number achievement
  rewards. All 558 source messages were regenerated across 17 languages.

| Edition | App ID | Build ID | Branch |
| --- | --- | --- | --- |
| Full | 5520300 | 26757742 | default |
| Demo | 5520330 | 26757748 | default |

Both default branches were assigned and verified in Steamworks, including the
Set live history. Previously the default branches still pointed to the old
26332676 / 26332680 builds, explaining why installed copies lacked earlier fixes.
No store configuration, app release status or review submission was changed.
The itch releases remain 0.6.

Validation passed: 15 shipping package checks per edition; 54 source release UX
checks; 54 Full QA package UX checks; 31 Demo QA package UX checks; 20,341 packed
localization checks; 37 focused source controller checks. QA uses the isolated
RailwayFuryControllerQA save folder. Visual previews cover the demo menu,
upgrades, achievements, completion countdown and unlocked wishlist screen.
Physical controllers and Steam Input still require hardware testing.

Receipts: tools/railway_steam/upload-0.7.log. Release fingerprints:
StoreAssets_RailwayFury/steam/build-manifest.json and
Build - RailwayFury/build_manifest_0.7.json. Steam default proof screenshots:
Docs/Previews/steam-0.7-full-default.png and steam-0.7-demo-default.png.

For testing, close the game, let Steam update, and confirm the menu reads v0.7.
