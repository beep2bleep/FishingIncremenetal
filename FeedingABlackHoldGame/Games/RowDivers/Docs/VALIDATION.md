# Polish verification — 22 October 2026

The main project's AppBootstrap/GameLauncher, shared UpgradeScreen and Settings scenes are reused. The first source upgrade now centers in the viewport; editor-only controls no longer overlap the Row Divers controls. Synty character/weapon art, skeletal idle loops, recoil, floating feedback, boss bars, a replayable four-page tutorial and the final choice scene are implemented. Asset provenance and remaining placeholders are listed in `PLACEHOLDERS.md`.

- `ValidateRowDivers.gd`: **1,676 assertions, zero failures**, including all 112 nodes, 114 connections, 330 legal purchases and imported arithmetic.
- `SmokeRowDivers.gd`: **23 assertions, zero failures**, including the shared tree, visible root centering, purchase/save integration and core combat.
- `VerifyRowDiversCampaign.gd`: **52 checks, zero failures**. This uses normal runtime movement, steering, aiming, health loss and combat with a loadout obtained through legal purchases. Fixtures supply test currency and leave the player's save untouched. They verify all four ability effects and expiry/cooldown recovery, all three boss volleys reaching and damaging the player, Arrow Shield protection, animated skeleton poses, both ending choices, and successful complete rows on all four prestige levels.

| Prestige | Simulated run time | Travel including steering | Defeats | Result |
| --- | --- | --- | --- | --- |
| 0 | 88.7 s | 289.2 m | 33 | Boss defeated |
| 1 | 88.7 s | 289.7 m | 33 | Boss defeated |
| 2 | 88.7 s | 289.5 m | 33 | Boss defeated |
| 3 | 90.5 s | 300.4 m | 63 | Boss defeated; final choice unlocked |

The campaign fixture defers optional percentage tiers until after flat upgrades, aims the Third Eye, steers to avoid contact, and uses running/abilities strategically. It grants no invulnerability or extra damage. The reference's purchase-order dependence is material: the same maxed nodes can yield very different final damage values.

Source checks include 0.5 Hz three-arrow boss volleys, 15-degree spread, speed 4 and two-second projectile lifetime; the miniboss health-index offset; the final Prestige 3 boss multiplier; the reference's critical-chance save correction; close-range immediate hits below 1.3 m; and the final unlock condition of **100 maxed nodes plus Prestige 3 completion**. The original narrative is replaced by new ending text and credits.

The original executable and current Railway Fury build were played sequentially during this pass. The original opening again showed 95/100 HP and a first enemy with 46 HP; Railway Fury also showed the source's first-enemy value of 46. Main menu → shared upgrades → PLAY → movement → pause → shared settings was exercised in the live build. Native capture worked after activating each target window. Polished screens were rendered at 1280×720 and visually inspected.

**An exact end-to-end match to a complete original playthrough is still not certified.** The campaign test establishes that the replacement completes all four rows and endings with ordinary runtime rules; it does not compare a complete original campaign, the fresh-save grind, every collision boundary, or Unity's mutable pooled-projectile quirks frame by frame. The earlier comparison limitations below remain relevant. The renderer still logs inherited shader/UID/headless-controller warnings and shutdown leaks, but these verification runs have no Row Divers script errors.

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
