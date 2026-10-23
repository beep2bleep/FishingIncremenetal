# Differential logic comparison — 22 October 2026

Arrow Damage V/VI follow-up: see `UPGRADE_CURRENCY_AUDIT.md`. The expanded original-C#/Godot comparison passes 73 cases / 2,155 checkpoints, including their actual branch prerequisites and gem-only payment. The shared-screen smoke passes 50 assertions. Tooltips and the wallet now name currencies explicitly; source damage, prices and unlocks are unchanged. A fresh QA build is in `Build - RailwayFury/Windows-QA-currency-labels` at the repository root.

Original-art option: the shared settings screen now exposes **Original Row Divers Graphics**. Both rendering modes pass 342 checks, including all 95 source textures and 112 upgrade icons, immediate switching, local preference persistence, and identical simulated gameplay state/random draws for identical inputs. The original and modern views, settings toggle and ending illustrations were rendered and inspected. The full four-row original-art campaign also passes all 66 checks, with the same row times, distances, kills and remaining health as the modern-art fixture. The upgrade layout still uses the same source coordinates and 114 edges. Both ending choices exist; the narrative, credits layout and HUD are Railway Fury presentations, rather than copies of the source screens. Credits now identify the source game's developer/artwork and this version's art/audio separately.

See `PARITY_SIMULATION.md` and `PARITY_SIMULATION.json`: 72 original-C#/Godot replay cases match at 2,129 checkpoints after parity corrections. The four-row gameplay fixture now carries one progress dictionary through all prestiges. Exact full original-campaign/native-physics parity remains **uncertified**; the strict harness gate reports that explicitly.

# Polish verification — 22 October 2026

The main project's AppBootstrap/GameLauncher, shared UpgradeScreen and Settings scenes are reused. The first source upgrade now centers in the viewport; editor-only controls no longer overlap the Row Divers controls. Synty character/weapon art, skeletal idle loops, recoil, floating feedback, boss bars, a replayable four-page tutorial and the final choice scene are implemented. Asset provenance and remaining placeholders are listed in `PLACEHOLDERS.md`.

Temporary QA speed buttons (1×/2×/4×/8×, F7 cycle, F8 reset) are clearly marked for removal and gated by `railway_fury/debug/enable_speed_cheats` plus debug-build status. The smoke checks verify 8× elapsed time/movement and row damage, pause, reset, memory-only carryover between dives, and the off switch. The normal campaign still passes all 66 checks. The panel was rendered and visually inspected at 1280×720.

The follow-up polish fixes collection-popup wheel handling (the underlying tree no longer consumes it), adds original vector achievement/bestiary icons and a solid popup background, and applies the main project's grow/tilt tween plus hover/click audio to buttons throughout the Row Divers flow. Prestige controls remain hidden until the first completed row; ability cards appear individually only after purchase. Enemy idle loops now visibly move the spine, head and arms; nearby enemies and shooting bosses play a torso/arm attack with a short lunge and return to idle. These motions do not change hit bounds or combat timing. The smoke suite sends actual viewport mouse-motion/wheel events over achievement rows and verifies that scrolling advances; the campaign suite checks attack-pose movement and return to idle for all three boss rigs.

- `ValidateRowDivers.gd`: **1,676 assertions, zero failures**, including all 112 nodes, 114 connections, 330 legal purchases and imported arithmetic.
- `SmokeRowDivers.gd`: **42 assertions, zero failures**, including the shared tree, visible root centering, purchase/save integration and core combat.
- `VerifyRowDiversCampaign.gd`: **66 checks, zero failures**. This uses normal runtime movement, steering, aiming, health loss and combat with a loadout obtained through legal purchases. Fixtures supply test currency and leave the player's save untouched. They verify all four ability effects and expiry/cooldown recovery, all three boss volleys reaching and damaging the player, Arrow Shield protection, immediate loot banking without double-counting on run completion, animated skeleton poses, the one-time final-chamber cost and free re-entry, both ending choices, and successful complete rows on all four prestige levels.

| Prestige | Simulated run time | Travel including steering | Defeats | Result |
| --- | --- | --- | --- | --- |
| 0 | 88.7 s | 289.2 m | 33 | Boss defeated |
| 1 | 88.7 s | 289.7 m | 33 | Boss defeated |
| 2 | 88.7 s | 289.5 m | 33 | Boss defeated |
| 3 | 90.5 s | 300.4 m | 63 | Boss defeated; final choice unlocked |

The campaign fixture defers optional percentage tiers until after flat upgrades, aims the Third Eye, steers to avoid contact, and uses running/abilities strategically. It grants no invulnerability or extra damage. The reference's purchase-order dependence is material: the same maxed nodes can yield very different final damage values.

Source checks include 0.5 Hz three-arrow boss volleys, 15-degree spread, speed 4 and two-second projectile lifetime; the miniboss health-index offset; the final Prestige 3 boss multiplier; the reference's critical-chance save correction; close-range immediate hits below 1.3 m; and the final unlock condition of **100 maxed nodes plus Prestige 3 completion**. The final chamber also charges the source's one-time 200,000 gold / 10 gems / 4 crowns fee. The original narrative is replaced by new ending text and credits.

The original executable and current Railway Fury build were played sequentially during this pass. The original opening again showed 95/100 HP and a first enemy with 46 HP; Railway Fury also showed the source's first-enemy value of 46. Main menu → shared upgrades → PLAY → movement → pause → shared settings was exercised in the live build. Native capture worked after activating each target window. Polished screens were rendered at 1280×720 and visually inspected.

For the late-game native comparison, the campaign tool exported its exact legally purchased maxed stats. A temporary original-save fixture used those same stats and maxed levels: 15,440 HP, 3,020 armor, approximately 82.19 million arrow damage and 164 million Third Eye damage. The original completed Prestiges 0, 1 and 2 in order and unlocked Prestige 3. Two original Prestige 3 attempts ended in death before the final boss (one aimed the Third Eye at ordinary enemies; the second reserved them for bow healing). Running key injection was not visibly confirmed, and native steering did not reproduce the automated replacement's evasive strategy, so these outcomes are not a controlled comparison of final-row balance.

The native session exposed immediate wallet banking, highest-unlocked-prestige selection on the next dive, and the separate final-chamber fee. All three are now implemented and checked against the source. Steam's local API DLL was temporarily disabled for the fixture to avoid external achievements; it was restored afterward. The original pre-comparison save was restored byte-for-byte and its SHA-256 verified: `928b9033b757793c2fda7db630315cfa32e1c78486f67b732c8a509cb449d443`. Railway Fury's player save was not replaced by the campaign fixture.

**An exact end-to-end match to a complete original playthrough is still not certified.** The replacement completes all four rows and both endings under its normal runtime rules. Original Prestiges 0–2 were completed natively with matching upgrades, but original Prestige 3 and the ending were not completed in this comparison. The fresh-save grind, every collision boundary, and Unity's mutable pooled-projectile quirks have not been compared frame by frame. The renderer still logs inherited shader/UID/headless-controller warnings and shutdown leaks, but these verification runs have no Row Divers script errors. The earlier capture failures below are historical; fullscreen native capture now works.

Additional commands from the repository root:

```powershell
& .\Godot\Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --rendering-method gl_compatibility --script res://Games/RowDivers/Tools/VerifyRowDiversCampaign.gd
& .\Godot\Godot_v4.6-stable_win64_console.exe --path FeedingABlackHoldGame --rendering-method gl_compatibility --script res://Games/RowDivers/Tools/PreviewRowDiversPolish.gd
```

# Earlier verification record — 21 October 2026

## Automated checks

- `Tools/ValidateRowDivers.gd`: **1,676 assertions passed**, including 112 nodes, 114 edges, noncollapsed coordinates, fresh-save visibility, 330 legal purchases, all nodes reachable and maxed, costs, caps, unlock/stat exclusivity and every stat effect.
- `Tools/SmokeRowDivers.gd`: **22 assertions passed**, covering gameplay movement/combat, shared `UpgradeScreen.tscn` loading all 112 source upgrades and 114 source connections, root unlock visibility, Row Divers wallet presentation, PLAY routing label, and a saved upgrade purchase. The purchase fixture backs up and restores its save.
- `Tools/ValidateRowDivers.gd`: **1,676 assertions passed**, including legal upgrade purchases and every imported effect.
- Godot 4.6 loaded the main launcher, shared upgrade screen and battle scene without Row Divers script errors.
- `Tools/PreviewRowDivers.gd` rendered fresh upgrades, the complete shared tree and first-person gameplay. Images are in `Previews/`.

Run checks from the repository root:

```powershell
& .\Godot\Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --rendering-method gl_compatibility --script res://Games/RowDivers/Tools/ValidateRowDivers.gd
& .\Godot\Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --rendering-method gl_compatibility --script res://Games/RowDivers/Tools/SmokeRowDivers.gd
```

## Reference session

The original executable was launched from `C:\Users\stick\Downloads\Row.Divers\Row.Divers\Row Divers\Row Divers\RowDivers.exe`. Its existing save was copied and moved to dated backups before the comparison. The fresh reference showed zero gold, only Arrow Damage I visible, the dive button, the first-run controls prompt, automatic first-person corridor travel, 100 starting HP decreasing to 95, a first enemy showing 46 HP, and death with Retry/Upgrades/menu choices.

The source files additionally verified purchase formulas and priorities, serialized movement speed 1.3 and lateral speed 0.8, a 1.5 running multiplier, 0.1333 speed increases per section trigger, damage/health scaling, spawn groups, drop values, bow modes, automatic dagger attacks, four ability keys/timings, and special damage formulas.

## Comparison still required

**Complete side-by-side parity is not certified.** Native capture of the RailwayFury comparison window repeatedly failed with `encode latest capture frame failed: window crop is outside captured monitor`, including after refreshing the window handle and relocating/relaunching the test window. The replacement game was therefore inspected using its own rendered viewport. A complete original/replacement playthrough, late weapons, boss progression, poison/life-steal patterns and all prestige levels still need side-by-side play verification.

Fullscreen native capture subsequently recovered. The final launch was then played through the upgrade screen, PLAY, first-run controls, automatic travel, a bow input, death and return to upgrades. Its initial enemy showed 46 HP and the run summary saved correctly. The failure remains specific to the attempted windowed side-by-side arrangement.

The runtime uses lightweight shape geometry and approximate hit volumes, so collision/steering feel and miniboss gates need manual comparison. Unity's pooled-projectile lifetime quirks (including mutable damage cached on individual pooled projectiles) have not been proven equivalent. The 112-node upgrade data and arithmetic tests do not establish complete game parity.

The inherited application logs unrelated shader/translation warnings, old missing UID fallbacks and resource-leak messages during shutdown. These are distinguishable from Row Divers script failures and remain in the base project. Reference Steam achievements are represented by local achievement state and reward claims; no new Steam achievement integration was added.
