# Railway Fury balance simulation — 2026-10-24

Fresh campaign: **final chamber unlocked**, 48 runs, 330 legal upgrade purchases, 1619 simulated runs including purchase probes.

Realized runs contain 72.1 minutes of game time (menus and purchase decisions excluded). Experiment wall duration, including upgrade forecasts: 19.9 minutes.

## Experiment

Current repository upgrade catalog and combat rules; fresh wallet and starting stats. Automatically attempt the highest unlocked prestige, carry all loot and upgrades forward, and claim available achievement rewards after unlocking the achievements tab. Keep the player centered and walking (Shift running is off). Use the existing fast-mode targeting, firing, immunity to hostile arrows, and abilities on cooldown. Contact damage, armor depletion, health restoration, projectile travel, loot travel/pickup, boss blocking, and damage every two seconds remain enabled. No game balance files or gameplay saves are changed.

The primary trace uses fixed random seeds and 1/60-second steps, matching normal gameplay steps. It advances as fast as the CPU allows rather than waiting for frames or imposing a 32× limit. Completion means clear Prestiges 0–3, max at least 100 nodes, and pay the final chamber entry cost; no ending choice is made.

## Progression by prestige

| Prestige | Runs spent | Runs to first clear | Kills/run mean (min–max) | Mean kill range | Kills ≥80% range | Row-only deaths |
|---|---:|---:|---:|---:|---:|---:|
| 0 | 12 | 12 | 17.7 (5–33) | 5.93 m | 5.7% | 3 |
| 1 | 9 | 9 | 19.4 (8–33) | 7.76 m | 13.1% | 8 |
| 2 | 11 | 11 | 19.2 (6–33) | 8.03 m | 18.5% | 8 |
| 3 | 16 | 11 | 41.3 (4–63) | 8.67 m | 24.1% | 7 |

## Does it reproduce the reported problem?

Walking damage delivers the final blow in **28/41 failed runs**; **26** failures take no contact damage at all. Across 1259 kills, **18.5%** occur at ≥80% of attack range and **45.7%** at ≥70%. The median kill distance is **67.9% of range**.

Only **run 25** met the strict combined test: no contact damage, a row-damage death, and at least half the kills at ≥80% range. The run reproduces that combination, but the campaign did **not** reproduce a long consecutive stretch under this definition of near-max range.

Thresholds are explicit: “near max range” means ≥80% of the current bow targeting range; ≥70% is also reported. Distance is horizontal world-space separation at the killing hit, including enemies behind the player. Projectile travel reduces kill distance because the player advances during flight. Third Eye starts at bow range minus 2 m. A row-only death means no contact damage throughout that run, not merely a last blow from the row.

Kill distances by position along the corridor (pooled across runs):

| Player distance | Kills | Mean enemy separation | Median fraction of attack range |
|---|---:|---:|---:|
| 0–100 m | 651 | 8.78 m | 77.4% |
| 100–200 m | 389 | 7.84 m | 65.2% |
| 200 m onward | 219 | 5.82 m | 51.1% |

## Your current saved loadout

Read-only snapshot from your existing save (9 prior runs, Prestige 0); 20 fresh-seed repeats. Mean distance **91.0 m**, mean kills **9.9**, mean gold **8.8**, mean gems **1.20**. Deaths: {'the row': 19, 'enemy contact': 1}. Median kill separation **47.2% of range**, 0.0% at ≥80% range.

## Isolating walking damage

Using the exact upgrades before run 25 (Prestige 2), compare 10 identical-seed repeats with normal walking damage versus zero walking damage. Normal: **81.9 m**, **10.0 kills/run**. Without walking damage: **263.7 m**, **28.0 kills/run**. The no-row runs end from {'enemy contact': 10}. This demonstrates a large walking-damage gate, while also showing that enemy contact eventually matters if that gate is removed. The counterfactual modifies only offline damage handling.

## Fully upgraded Prestige 3

Using the campaign’s final, fully maxed loadout on 20 new seeds, **13/20 runs clear**. All 7 failures end from walking damage; contact damage across these repeats is 0, and hostile-arrow damage is zero. Mean distance is 292.29 m. This is a particularly clear late-game survivability gate: the fully upgraded build reaches the final boss, but its small health margin and random healing still decide whether it finishes. Revisit the Prestige 3 walking-damage budget and healing variability before adding more damage upgrades; these results do not imply an enemy-range issue across the entire run.

## Upgrade selection and choices

The selector is a heuristic with short simulated lookahead, not a proof of a globally optimal purchasing path. It ranks all affordable legal upgrades using changes in effective health, expected weapon damage, healing, range, pickup range, and progress toward child unlocks. It then tests the top four purchases against a baseline run with the same random seed. Final score weights relative distance gain 55%, gold per game-second gain 30%, and gems per game-second gain 15%, plus small stat/unlock bonuses. It discounts expensive options by `1 + sqrt(price / max(1, expected currency earned per run))`, and strongly favors turning a failed run into a win. The relative-income denominators are floored to avoid division by zero. The simulator buys one level, recomputes, and continues until nothing is affordable. It does not reserve currency for a future expensive purchase. Firing-mode unlocks and arrow-defense upgrades have little immediate value under these assist rules, but can still unlock useful descendants or count toward ending requirements.

First 20 decisions:

| After run | Prestige | Upgrade | New level | Price |
|---:|---:|---|---:|---:|
| 1 | 0 | Arrow Damage I | 1 | 1 gold |
| 1 | 0 | Arrow Damage I | 2 | 2 gold |
| 1 | 0 | Arrow Damage I | 3 | 2 gold |
| 2 | 0 | Arrow Damage I | 4 | 2 gold |
| 2 | 0 | Max HP I | 1 | 1 gold |
| 3 | 0 | Arrow Damage I | 5 | 3 gold |
| 3 | 0 | Pickup Range I | 1 | 2 gold |
| 3 | 0 | Bestiary | 1 | 1 gold |
| 4 | 0 | Unlock achievements | 1 | 5 gold |
| 4 | 0 | Max HP I | 2 | 2 gold |
| 4 | 0 | Max HP I | 3 | 2 gold |
| 4 | 0 | Max HP I | 4 | 2 gold |
| 4 | 0 | Max HP I | 5 | 3 gold |
| 4 | 0 | Arrow Damage I | 6 | 3 gold |
| 4 | 0 | Max HP I | 6 | 3 gold |
| 4 | 0 | Max HP I | 7 | 3 gold |
| 4 | 0 | Max HP I | 8 | 4 gold |
| 4 | 0 | Bow Attack Speed I | 1 | 4 gold |
| 4 | 0 | Armor I | 1 | 1 gold |
| 5 | 0 | Syringe I | 1 | 2 gold |

The complete choice log includes the wallet before purchase, baseline forecast, candidate scores, alternatives, and forecast after purchase.

## Validation and limits

Real 3D runtime comparison: **5/5 cases passed**. Fresh stats and legally maxed loadouts at each prestige matched completion frame, victory, distance, kills, wallet income, damage sources, health, and armor exactly under equal seeds. The headless model consumes the same actor idle RNG draw to preserve spawn/combat randomness. Visual effects, audio, gate animation and save writes are replaced; combat update order is retained. Campaign source hashes are recorded in `SourceSnapshot/manifest.json`; `../source_manifest.json` identifies the latest generated model.
Gameplay files were being edited concurrently during the experiment. `SourceSnapshot/` preserves the exact campaign model, runner, progression rules, catalog and original battle source. A later five-case comparison also passes against the classic-mode runtime after the first concurrent changes. New free-aim movement, chasing and airborne enemies are outside this experiment.
Trace accounting checks pass for all three currencies, all purchase affordability and level caps, every kill record, all four crowns, and the final chamber entry fee (`accounting_validation.json`).
The full-project comparison harness exits successfully but emits Godot resource-cleanup/leak diagnostics at shutdown. The isolated experiment runner completes without those diagnostics; the five outcome comparisons all pass.
Step-size check on the same 20 saved-loadout seeds: 60 Hz mean distance 91.05 m / 9.95 kills; 120 Hz 91.04 m / 9.95 kills. Frame-based targeting and contact checks can change outcomes slightly with step size; the main campaign uses the game’s 60 Hz steps.

This is one purchasing-policy trajectory, with randomness in layout, enemies, critical hits and loot. Run counts are evidence for this policy and seed, not guaranteed counts for every player. The player remains centered, so off-lane enemies can pass without contact, matching the collision rules. Bosses stop forward movement at 0.75 m while contact requires less than 0.4 m longitudinal separation; that makes boss stalls principally a row-damage/DPS problem under arrow immunity. Purchase order changes compounded stats. A maxed tree does not imply a unique final damage or health value.

## Files

- `runs.csv`: every run, damage sources, income, distance and kill-range summaries.
- `kills.csv`: every kill, time, enemy type, distance and fraction of range.
- `choices.csv`: every purchase and scored alternatives.
- `fresh_campaign.json`: complete campaign trace and final state.
- `final_loadout.json`: reusable final progression input.
- `current_save.json`: repeated tests of your existing saved upgrades.
- `runtime_validation.json`: comparison with real gameplay.
