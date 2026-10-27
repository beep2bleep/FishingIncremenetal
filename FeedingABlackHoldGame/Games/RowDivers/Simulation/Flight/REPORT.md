# Flying mode balance — 25 October 2026

Installed a separate 128-node tree and save slot for free aim. The automated pilot aims, strafes around observed hazards, moves into pickup range, and uses abilities on cooldown. Native projectile travel, shot cooldowns, acceleration, contact, hallway drain, enemy arrows, and fire waves remain active. Tests run without rendering or real-time waits at 60 simulation ticks per second; no 32× immunity is used.

## Full campaigns

| Seed | Runs to first clear P0 / P1 / P2 / P3 | Total runs through final fee | Maxed nodes | Mean kills/run | Mean kill distance |
|---:|---|---:|---:|---:|---:|
| 2401026 | 11 / 9 / 9 / 11 | 41 | 125/128 | 32.9 | 6.46 m |
| 2401027 | 12 / 9 / 9 / 9 | 40 | 122/128 | 35.6 | 6.49 m |
| 2401028 | 12 / 9 / 11 / 12 | 47 | 128/128 | 35.6 | 6.62 m |

Mean campaign length: **42.7 runs**, versus 49.7 in the assisted release (53 / 47 / 49). All campaigns start with zero resources, earn all four crowns, max at least 116 nodes, and pay 200,000 gold + 10 gems + 4 crowns for the final chamber. Prestige-first-clear counts exclude later farming. 97/111 comparable pre-clear attempts increase forward distance by more than 0.1 m.

Deaths across these campaigns: enemy contact: 30, enemy arrows: 6, the row: 43, poison: 2, fire waves: 30. All four damage sources are recorded; this is no longer gated solely by hallway drain. Across 4,445 kills, 17.9% occur at ≥80% attack range and 2.2% within 2 m. Median separation is 7.05 m. Range fractions can exceed 1 for traveling shots/abilities. Per-run kills, distances, damage, loot, and purchases are in the CSVs.

| Prestige | Total attempts across 3 seeds | Mean kills/run | Mean forward distance | Mean kill separation |
|---:|---:|---:|---:|---:|
| 0 | 35 | 22.6 | 152.6 m | 5.70 m |
| 1 | 27 | 33.5 | 193.5 m | 6.58 m |
| 2 | 29 | 29.3 | 194.2 m | 6.40 m |
| 3 | 37 | 51.3 | 192.9 m | 6.91 m |

## Fire waves and upgrades

Each new dive resets the wave stage; each prestige starts using its own control stat. Defeating the first and second miniboss increases pressure. Damage is fixed for the entire prestige: 15 / 100 / 400 / 1,200 per hit. Escalation changes frequency, speed, and the safe channel, rather than damage. The final boss ends the dive.

| Stage | No control: interval / gap / speed | 80 control: interval / gap / speed |
|---|---|---|
| Before first boss | 5.00 s / 1.90 m / 6.0 m/s | Same |
| After first boss | 1.43 s / 1.45 m / 8.0 m/s | 4.55 s / 1.81 m / 6.4 m/s |
| After second boss | 0.45 s / 1.00 m / 10.0 m/s | 3.57 s / 1.72 m / 6.8 m/s |

Observed crossings include the control levels the buyer had at that point:

| Stage | Crossings | Hits | Hit rate |
|---:|---:|---:|---:|
| 0 | 1318 | 24 | 1.8% |
| 1 | 1589 | 113 | 7.1% |
| 2 | 1209 | 270 | 22.3% |

The 16 Ember Channels nodes are spread behind four existing gem unlocks: Shoot On Hold, Dagger, Dagger Attack Range I, and Row Damage Resistance I. Four nodes per prestige, two ranks each, give +10 whole control points per purchase (80 total). Prestige 0 base prices are 10 / 25 / 50 / 100 gold; Prestige 1 multiplies these by 20, Prestige 2 by 200, Prestige 3 by 2,000. Second ranks cost 1.2×, rounded up. Future-prestige nodes are gated. Earlier control remains owned but does not reduce a later prestige’s waves.

Flame banks use the existing illustrated flame texture with animated distortion and warm light; the center opening is the safe route. [In-game preview](fire_wave_preview.png).

## Tuning decisions

Free aim starts with arrow damage 30, arrow speed 8, and strafe speed 1. Gold payouts are 2× assisted payouts; gems remain 1×. The pickup attraction is strong enough to catch a drop once the player enters its collection radius. Projectile armor now reduces hostile-arrow damage in free aim. Classic outcomes remain unchanged in the six runtime regression cases.

The initial active balance left maxed survival at 10/20. Increased Medicine II from +540 to +800 health per rank, Red Heart from +1,620 to +2,000 health, and Shiny Armor from +500 to +750 armor per rank, retaining prices. Fully maxed health is 23,330 and armor 3,520. Health/damage increments remain whole numbers; percentage effects can still produce fractional resulting stats. The adjustment improves survival without changing early wave damage or escalation.

| Repeated P3 test, same 20 seeds | Wins | Deaths | Fire hits |
|---|---:|---|---:|
| Initial health, max control | 10/20 | enemy contact: 6, the row: 2, enemy arrows: 1, fire waves: 1 | 12 |
| Final health, max control | 18/20 | enemy arrows: 2 | 9 |
| Final health, no P3 control | 0/20 | fire waves: 18, the row: 2 | 211 |
| Final health, slower pilot, max control | 20/20 | None | 11 |

These snapshots use seeds 81240–81259 and a legally purchased maxed fixture, with P3 control removed for the no-control counterfactual. Slower reactions change discrete target and route decisions, so survival is not monotonic in the reaction setting. The slower result is a sensitivity check, not evidence that slower human reactions are better. Each raw trace retains its exact initial state; `initial_maxed_loadout.json` preserves the pre-adjustment fixture.

Initial active health campaign totals on the same three seeds: 42 / 43 / 47. Final totals: 41 / 40 / 47. Both use the same frozen physics, pilot, and purchase policy.

## Purchase policy, claims, and limits

Before each shop and after every purchase, claim every ready achievement once the Achievements tab is unlocked, then spend the resulting resources. Combat achievements are claimed at the next shop. The independent audit reconciles every shop wallet and the campaign-wide gold/gem/crown totals. Choices include prices, before-purchase wallets, scores, predictions, and alternatives.

The buyer shortlists two affordable upgrades using survivability, damage, healing, range, pickup reach, control, and unlock value. It simulates both against the same baseline seed. Score weights are 60% relative forward reach, 28% gold per second, and 12% gems per second, plus stat/unlock value, divided by a price-in-expected-runs penalty. Winning a previously losing probe gets an additional bonus. Prestige 3 retains one affordable future purchase when possible; after the ending unlock it banks entry funds while taking at most one upgrade per shop.

This is a bounded heuristic, not a global optimum or a human-calibrated model. The default pilot reacts every 0.18 s, aims at at most 5 rad/s with 0.012 rad error, clicks at most six times per second, and only plans around observed threats and drops. It cannot see future random spawns. The slower test uses 0.30 s reactions and 0.025 rad error. Deterministic seeds enable fair comparisons, but three campaigns and 20-run snapshots do not measure every play style.

## Verification and files

Six exact current-runtime/model combat comparisons passed, including all four prestiges and a no-control P3 fixture. Fifteen actual-shop checks cover catalog selection, purchase gating/costs, control isolation, and projectiles at 32×. Existing free-aim checks passed for all three visual styles (78 checks). Six classic runtime/model cases preserve the prior classic outcomes. All three tuned campaigns reproduce wave crossings, clicks, pilot decisions, loot, damage, kills, and final wallets; replay numeric tolerance is 1e-6 absolute / 1e-9 relative for JSON serialization. Saved player progress hashes were unchanged. Full-project validators emit existing startup/shader/exit-cleanup diagnostics; behavioral assertions pass, and the isolated campaign launcher rejects script errors.

The flying slot is `user://row_divers_progress_flying_v1.json`; classic slots and catalogs remain available. The new mode begins its own progression.

[Audit](audit.json) · [Installed source/catalog hashes](installed_flight.json) · [Runtime parity](runtime_validation.json) · [Shop checks](tree_validation.json). The `tuned/` directory contains three complete raw campaign traces and per-seed runs, choices, achievements, kill separations, and wave-crossing CSVs. `final/` retains the initial active balance comparison; rejected/exploratory traces remain separately labeled.

Reproduce from the repository root:

```powershell
python tools/rowdivers_balance/run.py --free-aim --frozen-snapshot FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/SourceSnapshotFinal --catalog FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/tuned/catalog.json --config FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/tuned/config.json --output flight_reproduced.json
python tools/rowdivers_balance/report_flight.py
```
