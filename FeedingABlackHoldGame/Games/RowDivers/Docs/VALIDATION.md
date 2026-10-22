# Verification record — 21 October 2026

## Automated checks

- `Tools/ValidateRowDivers.gd`: **1,676 assertions passed**, including 112 nodes, 114 edges, noncollapsed coordinates, fresh-save visibility, 330 legal purchases, all nodes reachable and maxed, costs, caps, unlock/stat exclusivity and every stat effect.
- `Tools/SmokeRowDivers.gd`: **15 assertions passed**, covering automatic forward movement, Shift toggle and multiplier, two-second health drain, running damage, projectile damage, firing cooldown, ability duration/cooldown, armor reduction, pause and idempotent run completion. These fixtures disable result persistence.
- Godot 4.6 loaded the upgrade and battle scenes without Row Divers script errors.
- `Tools/PreviewRowDivers.gd` rendered and visually inspected fresh upgrades, the complete tree and first-person gameplay. Images are in `Previews/`.

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
