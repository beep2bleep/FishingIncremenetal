# Arrow Damage V / VI audit — 22 October 2026

The source's `HomeScene.unity` UpgradeData fields and `CurrencyType.cs` define these prices and requirements:

| Upgrade | Effect per purchase | First / second price | Prerequisite |
| --- | --- | --- | --- |
| Arrow Damage II | +25 arrow damage | 2 / 3 gold | Bow Attack Range I, level 1 |
| Arrow Damage V | +4,000 arrow damage | 3 / 4 gems | Bleed Duration, level 1 |
| Arrow Damage VI | +18,000 arrow damage | 3 / 4 gems | Arrow Damage V, level 2 |

The original graph branches through dagger/bleed upgrades to V; it does not require Arrow Damage IV first. `UpgradeController.ActivateChildUpgrades` reads the child's `unlockAtParentLevel`, and `UpgradeData.CalculateUpgradeCost` rounds `baseUpgradeCost * 1.2^level` upward. `CurrencyType.GoldCoin` is 0 and `Gem` is 1. These costs, effects and edges already match our runtime. No balance or unlock change was made.

The UI previously distinguished currencies with small glyphs. Tooltips now spell out GOLD / GEMS / CROWNS and show parent-level requirements; the wallet also names its currencies explicitly.

`damage-v-vi-source-branch-and-gem-payment` executes the same 26-action purchase tape against original C# and our progression code. It follows legal prerequisites, attempts gold-only payments, pays three then four gems for V, tests VI before/after the second V purchase, and buys VI with gems. Every checkpoint matches. The complete differential run passes **73 cases / 2,155 checkpoints**; the shared-screen smoke passes **50 assertions**, including actual tooltip text and wallet deductions. This audit does not establish full combat/native-physics parity.
