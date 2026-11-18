# Current Free Aim playthrough — 27 October 2026

Three fresh campaigns use the current 125-node tree and regenerated combat. All completed all four levels and paid the final chamber fee. No gameplay balance or player saves were changed.

| Seed | Runs | Level 1 attempts | Level 2 attempts | Level 3 attempts | Level 4 attempts | Diving time at 1x |
|---:|---:|---:|---:|---:|---:|---:|
| 2401026 | 37 | 8 | 9 | 9 | 8 | 57.8 min |
| 2401027 | 33 | 6 | 9 | 9 | 8 | 49.0 min |
| 2401028 | 33 | 7 | 8 | 8 | 7 | 50.7 min |

Attempts count through the first clear of each level. Total runs also include any final-fee farming. Diving time excludes menus and buying, and is simulation time, not CPU time.

## Primary trace: seed 2401026

| Level | Total runs | Enemies defeated | Kills/run (min–max) | Mean kill distance | Kills at >=80% range |
|---:|---:|---:|---:|---:|---:|
| 1 | 8 | 124 | 15.5 (8–33) | 4.45 m | 2.4% |
| 2 | 9 | 281 | 31.2 (15–50) | 6.31 m | 19.2% |
| 3 | 9 | 226 | 25.1 (6–49) | 5.93 m | 22.1% |
| 4 | 11 | 606 | 55.1 (7–80) | 7.19 m | 30.5% |

Deaths: enemy contact: 9, the row: 14, fire waves: 6, enemy arrows: 1.
Across 1,237 kills, mean separation was 6.49 m, median 6.94 m. 23.6% died at >=80% current attack range; 4.9% died within 2 m.
Hallway deaths with a majority of kills at >=80% range occurred on runs none. Per-run details are in runs.csv; every kill is in kills.csv.

321 purchases and 16 achievement claims were recorded. Achievement rewards totaled [10875.0, 20.0, 3.0] (gold/gems/crowns). 112 nodes were maxed; the final chamber requires 112.
Fire waves hit 88 times in 1024 crossings. The trace records hits/dodges separately by boss stage.

Run distance is forward hallway reach; path_distance includes strafing. Kill range is horizontal separation from the player at death, normalized against the current attack range for the near-maximum measure.

## Current powers and policy

The model includes Shield halving incoming damage, Magpie doubling non-crown pickups, Arrow Storm projectiles, Regen tied to walking drain, and Ghost suppressing ordinary enemy aggression while bosses remain aware. Each power lasts 10 seconds and recharges for 30 seconds after expiry. The pilot activates unlocked powers whenever ready. Powers are not assumed unlocked at the start.

| Power | Bought after run | Level |
|---|---:|---:|
| Magpie | 1 | 1 |
| Ghost | 20 | 3 |
| Regen | 24 | 3 |
| Arrow Storm | 29 | 4 |
| Shield | 31 | 4 |

### Exhaustive power diagnostic

At the primary seed's actual wallet/build after run 30, all 26 affordable upgrades were forecast with the same decision seed. The best single purchase was Shield for 110.0 gold. It improved forecast reach from 128.5 m to 173.4 m and gold from 82000 to 92000. The normal shortlist instead chose Triples Dagger Damage I; Shield was not among its tested alternatives.
This is a one-decision diagnostic, not a fourth full campaign. The primary three traces deliberately retain the current editor buying policy. See power_shortlist_diagnostic.json for all affordable alternatives.


The same editor buyer policy is retained: 60% reach, 28% gold rate, 12% gem rate, two forecast candidates per purchase. Achievements are claimed before shopping and after every purchase, including rewards that fund more buying. The pilot has a 0.18-second reaction interval, aiming error, six clicks/second before Auto, dodges observed threats and moves to collect payouts. All contact, hallway, fire-wave and enemy-projectile damage remains active. It is a reproducible heuristic, not a measured human or a globally optimal purchase search.

Buyer limitation: its inexpensive shortlist proxy explicitly values Magpie but has no direct value term for Shield, Regen, Arrow Storm or Ghost. Their actual combat effects are included once forecasted, but they can be omitted from the two-candidate shortlist. Late power purchases therefore expose a limitation of the current buyer as well as game progression; they are not proof that those powers are weak.

The prior same-seed crown study took 40 runs; the current version takes 37. This compares all intervening changes together, not the isolated effect of one power.

## Verification and files

Six full-run native/model comparisons pass for fresh, maxed and no-fire-control loadouts. The current native shop gates and 161 power checks pass. All three traces replay their purchases, claims and combat results deterministically, and independent audits reconcile rewards, prices, prerequisites and all three currencies including the ending fee. Both actual ending choices accept each completed build in six additional cases with persistence disabled.

- `campaign*.json`: complete trials and scored alternatives.
- `runs.csv`, `choices.csv`, `claims.csv`, `kills.csv`, `waves.csv`: primary trace; seed-prefixed copies hold the other two.
- `replay_<seed>.json`: exact starting loadout for every run and replay checks.
- `summary.json`, `audit.json`, `runtime/`: machine-readable findings and checks.
- `SourceSnapshot/`, `installed_sources.json`: frozen runtime inputs and hashes.
