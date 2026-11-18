# RailwayFury / Row Divers

The full Windows itch build 0.9 is uploaded as a private draft at `https://itch.io/game/edit/5397032` (owner preview: `https://beep2bleep.itch.io/railway-fury`). The demo remains public at `https://beep2bleep.itch.io/railway-fury-demo`. Full Steam 0.9 is live; the Steam demo 0.9 activation still requires Steam Mobile confirmation. See the 0.9 manifest for edition-specific upload status.

Version **0.9** adds consistent controller cursor menus and detailed run/section analytics. Steam Full **26767539** is default; Demo **26767544** is uploaded and awaiting Steam Mobile confirmation to replace default 0.8. The Steam demo is released. Itch browser/Windows 0.9 are published with wishlist links. Cloud storage is owned by the released demo, with the full app sharing it. See `FeedingABlackHoldGame/Games/RowDivers/Docs/RELEASE_0.9.md` and `Build - RailwayFury/build_manifest_0.9.json` for status.

Version **0.8** is verified on Steam's default branches: Full **26758129**, Demo **26758130**. Progress and achievement claims share a save; the demo always runs Level 1 without erasing later full-game progress. Demo Cloud now shares full app 5520300. Valve's unreleased-base-app limitation and the local Steam client's No Connection state prevent end-to-end Cloud confirmation yet. See `FeedingABlackHoldGame/Games/RowDivers/Docs/SHARED_PROGRESS_0.8.md` and `RELEASE_0.8.md`. Itch remains 0.6.

Version **0.7** was rebuilt and uploaded November 18, 2026. Steam Full **26757742** and Demo **26757748** are verified live on their **default branches**. Demo wishlist links and the five-second demo completion countdown are included; packaged checks confirm Railway death text and integer achievement rewards. Close the game, let Steam update, and confirm v0.7. Itch remains 0.6. See `FeedingABlackHoldGame/Games/RowDivers/Docs/RELEASE_0.7.md`.

Version **0.6** was rebuilt and uploaded November 17, 2026. Steam Full build **26745603** and Demo build **26745607** remain unassigned. The itch Windows and browser demos are published at https://beep2bleep.itch.io/railway-fury-demo . This release includes whole-number achievement rewards, controller death countdown/cursor choices, the full-width menu image and the complete Railway wording/translation refresh. See `FeedingABlackHoldGame/Games/RowDivers/Docs/RELEASE_0.6.md`.

Version **0.5** local builds include the November 17 controller navigation,
hover, hint layout, demo label and continuous upgrade music fixes. Run
`Build - RailwayFury/Steam/Full/RailwayFury.exe` for the full game or
`Build - RailwayFury/Steam/Demo/RailwayFuryDemo.exe` for the Steam demo.
Itch Windows/Web ZIPs are under `Build - RailwayFury/Demo`. The 0.5 itch Windows and browser demos were uploaded on November 17, 2026:
https://beep2bleep.itch.io/railway-fury-demo . Steam 0.5 was uploaded November 17, 2026: full **26739109**, demo **26739113**,
both unassigned. See `FeedingABlackHoldGame/Games/RowDivers/Docs/RELEASE_0.5.md`.
The historical Steam upload record below refers to 0.4.

Steam Windows builds for version **0.4** were uploaded on November 16, 2026: full game **26717191**, demo **26717195**. They were not set live. See [the upload record](FeedingABlackHoldGame/Games/RowDivers/Docs/RELEASE_0.4.md) and [controller modality audit](FeedingABlackHoldGame/Games/RowDivers/Docs/CONTROLLER_MODAL_AUDIT_0.4.md). For local controller testing, run `Build - RailwayFury/Steam/Full/RailwayFury.exe` or `Build - RailwayFury/Steam/Demo/RailwayFuryDemo.exe`; the older Windows-QA build is not the 0.4 release.

Open `FeedingABlackHoldGame/project.godot` with Godot 4.6, or run `Launch-RailwayFury.ps1`.

This checkout uses branch `RailwayFury`, based on GitHub HEAD `041f383a036fdb06c216335010abf67647dcc792` of `beep2bleep/FishingIncremenetal`. Startup uses the main project's `AppBootstrap` and `GameLauncher`, with a single Railway Fury / Row Divers entry. That entry opens the main project's shared `UpgradeScreen.tscn`; PLAY opens `Games/RowDivers/Scenes/RowDiversBattleScene.tscn`, and the end screen returns to the shared upgrade screen.

The module is under `FeedingABlackHoldGame/Games/RowDivers`. Other games' gameplay files are unchanged. Routing is added to `Util.gd`; the existing shared application services remain loaded.

The polish pass uses selected Synty Dark Fantasy character and weapon meshes, with looping skeletal idle animations, weapon recoil, damage/loot feedback, boss bars and ability cooldown cards. Start, settings and upgrades reuse the main project's scenes. The pause screen embeds the same `Settings.tscn`, including volume, display and text-size controls. A four-page tutorial appears on the first dive and can be reopened through HOW TO PLAY.

## Imported design

`Data/row_divers.json` records the reference's 112 upgrade nodes, 114 directed connections, original tree coordinates, descriptions, level caps, parent-level thresholds, currencies, base costs, stat effects and unlock types. `RowDiversUpgradeTreeAdapter.gd` presents this data through the main project's upgrade graph, including the original node positions and all parent connections. It also records 37 nonzero base stats, ability timings, enemy prefab values, spawn groups for all six corridor variants, and 18 achievements with their rewards. The importer uses the local decompiled Unity data; it copies no reference textures, models, music, or sound effects.

Regenerate with Python plus PyYAML: `python tools/import_row_divers.py --source "C:\Decompiled\Row Divers\ExportedProject"`.

Upgrade prices use `ceil(base * 1.2^level)` after the initial base-price purchase. Percentage upgrades compound against the current stat in purchase order. Unlock nodes grant their weapon, firing mode, ability or tab instead of applying stat payloads. A child becomes visible when any connected parent reaches its required level. All tree positions use one uniform scale and invert Unity's Y axis.

## Controls and progression

- Left/right arrows or A/D steer; forward movement is automatic.
- Shift toggles running, multiplying forward speed and row damage by 1.5.
- Left click shoots. Hold fire and automatic fire require their original upgrades; 1/2 switch bow firing modes after Auto Shoot unlocks.
- Dagger attacks automatically in range after unlocking. Third Eye targets enemies under the mouse.
- Space activates the next ready, unlocked ability highlighted in the HUD.
- Escape pauses. Loot enters the wallet immediately on pickup, including when quitting mid-run. Upgrades on the pause/end screen returns to the tree.
- Enter starts a run from the upgrade screen.
- Controllers: left stick steers, right stick aims in Free Aim, RT/RB (R2/R1) shoots, and LT/LB (L2/L1) activates the next ready power. Holding fire follows the same Hold/Auto upgrade rules as the mouse. Left stick click toggles running. Menu/Options starts a run or pauses/resumes gameplay.
- In menus, the left stick moves the cursor; D-pad switches to focused selection. A/Cross, right trigger or bumper buys/confirms/plays. B/Circle backs out one mode or opens settings from the launcher/tree. The right stick pans the upgrade tree; hold LT/L2 and move it vertically to zoom. Hold X/Square and move the left stick on the tree background also pans. In other menus, the right stick scrolls. Y/Triangle selects upgrade menu actions, and switches the unlocked bow's Hold/Auto mode in combat. After a controller-played death, a one-second fading circular countdown blocks choices, then places the cursor over Upgrades. Use the left stick and A/Cross or RT/RB to click a choice; D-pad, Start and B shortcuts are disabled on that death screen. Victory results retain Start/Options replay and B/Circle return to upgrades. Pause/results both offer Quit Game. Prompts follow the active mode and switch to Xbox or PlayStation artwork.
- Right-drag pans the upgrade tree; mouse wheel zooms. Hover inspects; click buys an affordable upgrade.

The save is `%APPDATA%\RailwayFury\row_divers_progress_v1.json`. Test fixtures do not write gameplay progress. The reference save was backed up before resetting: `%USERPROFILE%\AppData\LocalLow\Hermurx\RowDivers\savefile.before-railwayfury-20261021.json` and `savefile.reset-backup-20261021.json`. Settings were preserved.

After clearing Prestige 3 and maxing at least 100 upgrade nodes, YOUR FINAL CHOICE appears in the shared upgrade screen. Opening the final chamber then costs 200,000 gold, 10 gems and 4 crowns once, matching the reference. It offers two original endings with the reference's Benevolent God / Evil God achievement states. Each new dive defaults to the highest unlocked prestige; the shared upgrade screen lets you select a lower row before PLAY. A crown is still awarded only once per prestige. Upgrade purchase order affects final stats, matching the reference's compounding percentages.

## Assets and verification

See `FeedingABlackHoldGame/Games/RowDivers/Docs/PLACEHOLDERS.md` for the replacement-art inventory, `Audio/sources.json` for the music/effect provenance, and `Docs/VALIDATION.md` for checks and remaining parity limitations. Rendered previews are in `Docs/Previews`.

## TEMPORARY CHEATS — REMOVE BEFORE RELEASE

The bright pink gameplay panel offers **1× / 2× / 4× / 8×** simulation speed. **F7** cycles speeds; **F8** restores normal speed. The panel stays available while paused. Speed carries between dives in memory until you quit the game; restarting the game restores 1×. It is never written to the progression save. Gameplay, row damage, projectiles, cooldowns and enemy animations all accelerate together; normal-sized physics steps preserve collision checks. Menus and UI remain at normal speed.

Remove these controls by setting `railway_fury/debug/enable_speed_cheats=false` in `FeedingABlackHoldGame/project.godot`. They are automatically absent and inactive in release builds even when that setting remains enabled. The implementation is marked `TEMPORARY QA` in the battle/HUD scripts. Progress earned in a fast run saves normally.

## Original-code comparison

Settings → **Original Row Divers Graphics** toggles the source artwork immediately and remembers the preference. The shared start/settings/upgrade screens remain in use. The option covers enemies, weapon/projectile/loot artwork, corridor textures, all upgrade icons, collections/ability icons and ending illustrations; it does not reproduce Unity's shaders or exact HUD. See `Games/RowDivers/Docs/PLACEHOLDERS.md` under the Godot project for the art manifest and scope. Verify with `VerifyOriginalGraphics.gd`, or run `VerifyRowDiversCampaign.gd -- --original-graphics` for the complete original-art campaign fixture.

Run `python tools/rowdivers_parity/run.py --campaign --self-test` to compare the original C# methods with our runtime logic. See `tools/rowdivers_parity/README.md` and `FeedingABlackHoldGame/Games/RowDivers/Docs/PARITY_SIMULATION.md` for scope, reproduced differences, fixes and limits. The covered 72 cases pass; exact native-physics and full original-campaign parity is not certified. `--require-end-to-end` fails closed for that stronger requirement.

## Windows QA build

Launch `Build - RailwayFury/Windows-QA/RailwayFury.exe`. Keep its `.pck` and both DLLs beside the executable. This debug build includes speed cheats and the original-art toggle, and uses the normal RailwayFury save folder. `BUILD_INFO.json` beside it records the source revision and file hashes.

Rebuild from the repository root with `Godot/Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --export-debug "Railway Fury QA"`. The preset includes JSON/CSV design data and excludes the module's test tools and documentation.
