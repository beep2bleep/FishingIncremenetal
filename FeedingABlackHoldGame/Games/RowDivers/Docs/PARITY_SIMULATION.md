# Differential logic simulation — 22 October 2026

**72/72 isolated replay cases match at 2,129 action checkpoints. Recorded native controls do not produce matching whole-game outcomes.** The machine report deliberately records `exact_end_to_end_certified: false`; the strict certification gate returns a nonzero exit code.

The comparison executes original Row Divers C# against our real gameplay/progression methods, rather than comparing two translations of our implementation. Fifty original source-file fingerprints are recorded. Selected larger-controller methods are extracted by name without rewriting their bodies. Scene/prefab design data is independently regenerated from the decompiled project and has **zero differences** from the committed catalog. Both extractions share the importer, so its assumptions are not independently proven by this check.

No game windows were launched. Original methods run in a .NET console harness with explicit Unity substitutes; our methods run through Godot's headless runtime. A separate, instrumented copy of the original also ran in Unity batch mode with native physics and recorded controls. Original files and both games' progression saves are untouched; the instrumented copy uses its own resettable save directory. Generated sources, binaries, inputs, complete state traces and logs stay in the ignored `.validation/rowdivers-parity/` directory.

## Results

| Comparison | Result |
| --- | --- |
| All 112 upgrades, 330 legal purchases, three purchase orders | Every intermediate level, price, stat, visibility rule and unlock matches |
| Consecutive/repeated victory progression | Prestige unlocks, achievements and one-time crowns match |
| Final chamber and both ending states | Insufficient funds, exact fee, free repeat entry, both choices and reward claims match |
| Enemy health | All seven kinds × four prestiges × four group indices match |
| All four abilities | Activation, effects, expiry, cooldown recovery, repeated input, pause and movement match for tested tapes |
| Projectile effects | Original arrow, fire, curse and shuriken hit methods match, including pooled-instance reuse and overlapping statuses |
| Dagger / Third Eye | Damage, critical bonus, boss bonus and status interactions match for tested impacts |
| Enemy arrows / economy | All prestige damage levels, poison, life steal, critical shots, shield blocks and Harvester's currency rule match |
| Boss-finishing life steal | Remaining damage/healing and the original duplicate-crown/prestige-unlock behavior match |
| Harness negative control | A deliberately injected +1 original-arrow damage error was detected by five cases; the temporary copy was restored |

These are normalized logic inputs, including explicit impacts and random draws. They are **not identical raw keyboard/mouse recordings through both complete engines**. Some fixtures grant purchase currency or force victory/impact events to test state transitions without a native physics world.

## Differences found and fixed

The initial 53-case comparison failed 20 cases. The suite was then expanded while correcting the runtime:

- Spending achievements use the **updated next upgrade price** in the source's `UpgradeFlow`, not the amount just paid. Our achievement thresholds now reproduce that counting; the wallet still deducts the price actually paid.
- Original pooled projectile components retain mutable base damage and curse multipliers. We now retain a separate cached state for each pooled projectile, initialized on first use. This preserves sticky curse multipliers and cumulative fire/shuriken damage.
- Burn, curse and bleed icons can coexist in the original. A new status replaces the expiration timer but does not clear the earlier status flags; expiration clears them together. Our damage checks now reproduce this behavior.
- Poison applies its first 10 damage **immediately**, before the enemy arrow's principal hit, then applies two later ticks.
- The source row-damage wait continues through pause and skips a tick that occurs while paused. Our previous timer froze its phase.
- Ability expiration is applied after the simulation step, matching the reference replay's coroutine ordering and fixing the one-frame Slow Down displacement difference.
- Original `Boss.Die` skips the normal enemy dead flag and heal-on-kill callback. If life steal kills it, the arrow's remaining hit can invoke the boss reward again. We preserve its cached crown flag and allow the remaining healing, damage and reward callbacks; ordinary kill/bestiary counts still increase once.

## Consecutive complete Railway Fury rows

The full headless gameplay fixture now retains one progress dictionary between dives; it previously duplicated the loadout for every prestige. It uses 330 legal purchases funded by fixture currency, normal health/damage rules and scripted steering/aiming/ability inputs. No invulnerability or extra damage is granted. This verifies a continuous maximum-loadout campaign, **not the natural fresh-save earning grind**.

| Prestige | Simulated time | Travel | Kills | HP remaining | Result |
| --- | --- | --- | --- | --- | --- |
| 0 | 88.7 s | 289.2 m | 33 | 15,440 | Boss defeated |
| 1 | 88.7 s | 289.7 m | 33 | 15,440 | Boss defeated |
| 2 | 88.7 s | 289.5 m | 33 | 13,304 | Boss defeated |
| 3 | 90.8 s | 301.6 m | 63 | 445 | Boss defeated; ending gate available |

The existing **66 campaign checks**, **42 smoke checks** and **1,676 data assertions** also pass. Godot reports resource cleanup leaks on test shutdown; the assertions pass with no script errors. Original C# victory/unlock/reward events are replayed separately in the differential suite. These rows use an adaptive controller and are separate from the recorded-control replay below.

## Native original and identical recorded controls

`NativeParityRuntime.cs` runs the actual original scenes, collision world, projectiles and coroutines in an isolated Unity project copy. It uses the same maximum-loadout fixture, carries original progression across dives, records axis values, key-down events and mouse pixels, and stops at death or four victories. Steam is disabled, save writes are redirected, input is instrumented, and RNG is seeded in the copy. The capture completed with **zero exceptions** using Unity 6000.0.68f1; the export targets 6000.0.27f1, so this is not a bit-for-bit test of the released executable.

`ReplayNativeRowDiversInputs.gd` then replays those recorded controls in our actual battle scene at the recorded 640×480 viewport. No prestige needed forcing between these runs. Results are preserved in `NATIVE_CONTROL_REPLAY.json`:

| Prestige | Original result/time | Railway Fury result/time | Final original / Railway Fury HP |
| --- | --- | --- | --- |
| 0 | Win, 88.78 s | Win, 88.68 s | 15,440 / 15,440; armor differs |
| 1 | Win, 88.78 s | Win, 88.68 s | 15,440 / 15,440; armor matches in this capture |
| 2 | Win, 88.78 s | Win, 88.70 s | 13,326 / 12,389.475 |
| 3 | Death, 82.35 s | Death, 61.97 s | 0 / 0 |

**This does not pass exact parity.** The random layouts, section choices and projectile shuffle streams are not synchronized. Native fixed updates run at 50 Hz, while our replay steps at the captured 60 Hz; collider, raycast, warmup and scheduling behavior also differ. These confounds prevent attributing all damage differences to a particular gameplay formula. The first differing health/armor checkpoint per row and maximum position difference are in the JSON. The earliest recorded divergence is row 3 at about 24.02 seconds. Both runs dying on row 3 is not proof of equivalence, given the different death times. Repeated native captures vary despite fixed seeds (the earlier capture died at 82.18 seconds), so a seeded capture is not yet a deterministic cross-engine world replay.

## What is not certified

Cross-engine equivalence for collision and rigidbody resolution, input-axis smoothing, actual render/fixed/coroutine scheduling, complete projectile flight/raycast ordering, projectile shuffles, section-selection RNG, beam acquisition/retention, dagger travel, and a full original winning campaign/fresh-save grind remain unverified. Native execution exercises some of these systems, but does not establish that our versions match them. A supplied-hit damage test does not prove both engines generate that hit from the same mouse input. Passing these fixtures cannot establish identical outcomes for every run or every possible input sequence.

Further certification requires synchronizing the environment/random events and simulation scheduling, resolving the first divergent collision/attack events, and then completing winning native/replacement campaigns plus fresh-save earning/purchase sequences. The current harness fails closed when that stronger certification is requested.

## Reproduce

```powershell
python -m pip install -r tools/rowdivers_parity/requirements.txt
python tools/rowdivers_parity/run.py --campaign --self-test
python tools/rowdivers_parity/run.py --require-end-to-end
```

The first comparison command returns 0 when covered cases match. The strict command returns **2** while full end-to-end coverage is unverified. A behavioral/design difference returns **1**. Full implementation and adapter boundaries are documented in `tools/rowdivers_parity/README.md`. The committed `PARITY_SIMULATION.json` records the matching cases, source fingerprints, tolerances and campaign results.
