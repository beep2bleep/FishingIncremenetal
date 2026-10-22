# RailwayFury / Row Divers

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
- 3: Arrow Shield; 4: Harvester; 5: Shuriken; 6: Slow Down, each requiring its upgrade.
- Escape pauses. Loot enters the wallet immediately on pickup, including when quitting mid-run. Upgrades on the pause/end screen returns to the tree.
- Right-drag pans the upgrade tree; mouse wheel zooms. Hover inspects; click buys an affordable upgrade.

The save is `%APPDATA%\RailwayFury\row_divers_progress_v1.json`. Test fixtures do not write gameplay progress. The reference save was backed up before resetting: `%USERPROFILE%\AppData\LocalLow\Hermurx\RowDivers\savefile.before-railwayfury-20261021.json` and `savefile.reset-backup-20261021.json`. Settings were preserved.

After clearing Prestige 3 and maxing at least 100 upgrade nodes, YOUR FINAL CHOICE appears in the shared upgrade screen. Opening the final chamber then costs 200,000 gold, 10 gems and 4 crowns once, matching the reference. It offers two original endings with the reference's Benevolent God / Evil God achievement states. Each new dive defaults to the highest unlocked prestige; the shared upgrade screen lets you select a lower row before PLAY. A crown is still awarded only once per prestige. Upgrade purchase order affects final stats, matching the reference's compounding percentages.

## Assets and verification

See `FeedingABlackHoldGame/Games/RowDivers/Docs/PLACEHOLDERS.md` for the replacement-art inventory, `Audio/sources.json` for the music/effect provenance, and `Docs/VALIDATION.md` for checks and remaining parity limitations. Rendered previews are in `Docs/Previews`.

## TEMPORARY CHEATS — REMOVE BEFORE RELEASE

The bright pink gameplay panel offers **1× / 2× / 4× / 8×** simulation speed. **F7** cycles speeds; **F8** restores normal speed. The panel stays available while paused. Speed carries between dives in memory until you quit the game; restarting the game restores 1×. It is never written to the progression save. Gameplay, row damage, projectiles, cooldowns and enemy animations all accelerate together; normal-sized physics steps preserve collision checks. Menus and UI remain at normal speed.

Remove these controls by setting `railway_fury/debug/enable_speed_cheats=false` in `FeedingABlackHoldGame/project.godot`. They are automatically absent and inactive in release builds even when that setting remains enabled. The implementation is marked `TEMPORARY QA` in the battle/HUD scripts. Progress earned in a fast run saves normally.

## Original-code comparison

Run `python tools/rowdivers_parity/run.py --campaign --self-test` to compare the original C# methods with our runtime logic. See `tools/rowdivers_parity/README.md` and `FeedingABlackHoldGame/Games/RowDivers/Docs/PARITY_SIMULATION.md` for scope, reproduced differences, fixes and limits. The covered 72 cases pass; exact native-physics and full original-campaign parity is not certified. `--require-end-to-end` fails closed for that stronger requirement.
