# Railway Fury upgrade-tree rebalance — 2026-10-24

Installed **Rebalanced** (experiment `round_numbers_p3_buffer`), selected after **53 complete campaigns** covering **18 new numeric trees plus the previous tree**. The complete campaigns include 2728 realized player runs. Forecast trials, fixed-seed replays and final-build stress tests are recorded separately.

## Result against the previous tree

Both columns use the same final upgrade-buying policy, combat source, 60 Hz simulation and three independent campaign seeds (2401026–2401028). Each starts with a fresh wallet and ends after clearing all four prestiges, maxing at least 100 nodes and paying the unchanged final-chamber fee.

| Measure | Previous tree | Installed tree |
|---|---:|---:|
| Mean runs to final chamber | 46.7 | 49.7 |
| Attempts that advance farther before prestige clearance | 88.2% | 93.4% |
| Runs followed by a tree upgrade | 140/140 | 149/149 |
| Kills within 2 m | 3.1% | 8.7% |
| Kills at ≥80% of bow range | 14.2% | 13.3% |
| Mean enemy separation at death | 7.60 m | 6.03 m |
| Median enemy separation at death | 8.06 m | 6.60 m |
| Runs with at least one kill within 2 m | 56/140 | 113/149 |
| Contact-damage deaths | 40 | 45 |
| Victories ending with ≤10% health | — | 10 |
| Deaths with walking damage and no contact damage | 72 | 36 |

Campaign length changes by +6.4%. Close kills are 2.8× as frequent. All 149 realized runs support at least one subsequent upgrade purchase. Of 121 comparable progression attempts, 113 advance, 4 tie and 4 regress. Permanent upgrades improve every run; random layouts, enemy types and healing/critical rolls still cause occasional distance setbacks. Strictly farther on every possible random seed is not guaranteed.

229 of the 296 close kills occur with the enemy still in front of the player.

A crown counts as prestige clearance even if a fatal hit and the boss kill occur in the same physics step, matching the existing runtime. A completed corridor counts as 300 m of progression even when the boss dies before the player reaches its position. Distance comparisons exclude prestige resets and farming after that prestige is cleared. Kill separation is horizontal world-space distance at the killing hit; close means ≤2 m.

## Runs per prestige

| Seed | Prestige 0 | Prestige 1 | Prestige 2 | Prestige 3 | Runs to final chamber |
|---:|---:|---:|---:|---:|---:|
| 2401026 | 11 | 9 | 13 | 15 | 53 |
| 2401027 | 10 | 10 | 10 | 11 | 47 |
| 2401028 | 11 | 10 | 12 | 11 | 49 |

## Why this tree

- **Keep ordinary enemies relevant.** Later flat arrow damage is about 70% of the old values, with the final tier set to 200,000 per level. Dagger damage is reduced and its reach grows to 4.7 m rather than 7 m. Bow reach grows to 10.75 m rather than 13 m. Enemies spend more of their life approaching the player.
- **Make close combat survivable.** Impact Armor becomes an affordable starting option: 4 gold, 85% contact reduction, numeric prerequisite threshold 0. Contact still kills players during progression, rather than every close encounter ending the run.
- **Smooth survival growth.** The first health upgrade gives 6 HP rather than 5. Larger late health rewards increase by approximately 35%, with smaller adjustments to the intermediate tiers. Full health reaches 20,350 instead of 15,440. Corridor damage itself is unchanged.
- **Give boss specialization a purpose.** The four existing boss-only damage tiers give 100, 6,000, 400,000 and 200,000,000 bonus damage per level. Their prices scale with progression. This shortens stalls at the fixed gates without erasing the ordinary enemies that create close calls.
- **Keep the existing achievement reachable.** The last arrow tier preserves a legal 62,155,026-damage build. Stronger uniform nerfs fell below the unchanged 60-million Bow Master requirement and were rejected.
- **Keep progression length familiar.** Gold prices are generally 10% higher, with explicit prices for the boss tiers and early impact armor. Currency types, caps, purchase-price growth, node identities, positions, parent/child lists and weapon/ability unlock types remain unchanged.

The full numeric diff is [installed_value_changes.csv](installed_value_changes.csv). Descriptions were updated to display the new amounts. Base player/enemy stats, enemy spawning, movement, walking/contact damage rules, projectile logic and ability durations/cooldowns were not retuned.

## Experiments and rejected variants

Early sweeps used earlier versions of the buying model and are exploratory. Only the final matched-policy controls above support the direct before/after claim. The selector was refined to value impact armor and to score normal-enemy DPS separately from boss-only DPS. The latter prevents a huge boss bonus from hiding a lack of ordinary-enemy damage.

The experiment table averages percentages per campaign; the main comparison pools the underlying attempts and kills.

| Candidate / policy group | Campaigns | Mean runs | Advances | Close kills | Mean contact deaths | Every run buys an upgrade |
|---|---:|---:|---:|---:|---:|---|
| balanced | 3 | 53.7 | 86.2% | 10.7% | 17.7 | no |
| balanced_edge | 3 | 59.0 | 86.5% | 10.4% | 24.3 | yes |
| balanced_safe | 3 | 54.3 | 85.7% | 10.6% | 16.3 | yes |
| balanced_v4 | 3 | 51.0 | 88.7% | 9.0% | 16.7 | no |
| close | 1 | 57.0 | 76.0% | 8.7% | 37.0 | no |
| control | 1 | 44.0 | 91.9% | 3.3% | 14.0 | no |
| control_p3_buffer | 3 | 46.7 | 88.3% | 3.1% | 13.3 | yes |
| control_v2 | 1 | 45.0 | 81.6% | 2.8% | 15.0 | yes |
| control_v3 | 3 | 48.0 | 88.7% | 3.8% | 16.3 | yes |
| control_v4 | 3 | 47.0 | 87.4% | 2.3% | 12.7 | yes |
| gates | 1 | 49.0 | 81.0% | 7.0% | 26.0 | yes |
| gates_light | 1 | 58.0 | 82.4% | 5.7% | 27.0 | yes |
| gentle | 1 | 45.0 | 78.9% | 7.1% | 21.0 | no |
| guarded | 1 | 48.0 | 80.5% | 7.5% | 27.0 | yes |
| guarded_plus | 1 | 48.0 | 80.5% | 8.3% | 27.0 | yes |
| ladder | 3 | 65.3 | 80.6% | 8.5% | 20.0 | no |
| release | 3 | 48.3 | 91.0% | 8.7% | 15.7 | yes |
| round_numbers | 3 | 48.0 | 92.5% | 9.1% | 13.7 | no |
| round_numbers_final | 3 | 52.0 | 89.0% | 10.1% | 11.7 | no |
| round_numbers_p3_buffer | 3 | 49.7 | 93.3% | 8.7% | 15.0 | yes |
| round_numbers_refined | 3 | 53.3 | 85.4% | 8.6% | 19.3 | no |
| round_numbers_whole | 3 | 50.3 | 86.0% | 8.8% | 13.0 | no |
| smooth | 1 | 51.0 | 77.3% | 8.6% | 32.0 | no |
| steady | 1 | 48.0 | 78.0% | 6.5% | 29.0 | yes |
| steady_close | 1 | 55.0 | 79.2% | 9.4% | 40.0 | yes |

Large offense reductions (close/smooth) made contact deaths too common and extended campaigns. The guarded versions improved close kills but still had too many setbacks. The balanced versions restored steadier progression, but some produced an empty-income run with no affordable upgrade, and several could not reach Bow Master. Moving multipliers too early (ladder) hurt the later build because percentage upgrades depend on purchase order. The installed final arrow adjustment retained the better balanced curve, removed the observed empty-upgrade run in the validation seeds, and restored achievement reachability. This is the best tested tradeoff, rather than a proof of a global optimum over all possible trees and purchase sequences.

## Upgrade-buying model

The simulated player ranks affordable, legal purchases by effective health against walking/contact damage, normal DPS, boss DPS, healing, range, pickup range and child unlocks. It simulates the top four candidates using the same forecast seed and weights reach 60%, gold income rate 28% and gem income rate 12%, with stat/unlock potential and an expected-runs cost penalty. Realized runs use separate seeds. Purchases are recalculated one level at a time and retain the game’s purchase-order compounding. After the ending is available, it buys one upgrade per dive and banks entry funds, avoiding a tail of runs with nothing left to buy. No income is injected. This buyer is a simulation tool; the live game still lets the player choose upgrades.

## Achievement rewards and round upgrade values

Achievement rewards were already included in all of the original campaign results. The simulator checks and claims every available reward before shopping and after each purchase. This includes rewards made available by that purchase; unlocking the Achievements tab immediately claims any banked achievements. Rewards earned during combat enter the next shop phase. The next purchase recommendation uses the updated wallet, so rewards can fund further upgrades in the same visit. For example, in the pre-rounding seed 2401026 campaign, unlocking Achievements after run 5 left 2 gold; First Dive added 25, and the next 3-gold upgrade was purchased from a 27-gold wallet.

Standalone recommendation mode had a separate omission: it did not claim pending rewards before evaluating the supplied snapshot. It now does. Three regression fixtures verify immediate use of a ready reward, no duplicate payout, and respect for the Achievements-tab lock ([results](recommendation_rewards/validation.json)).

The rounding follow-up rounds fractional health and damage additions and percentage bonuses to whole values, and 0.9 bow-rate additions to 1. Small range and dagger-rate increments retain clean quarters (0.25 and 0.75). All other health, armor, damage and percentage upgrade amounts are whole numbers. The adjusted amounts are recorded in [rounding_changes.json](round_numbers_p3_buffer/rounding_changes.json). Compounding percentage bonuses can still produce fractional resulting stats; upgrade additions themselves follow these rules.

Whole-number rounding changed the buying order and exposed a zero-income Prestige 3 transition in the initial candidates. Coarser and nearest-integer rounding variants, and 90% Impact Armor, were tested. The installed follow-up keeps Impact Armor at 85% and improves the simulation buyer: at Prestige 3, after one purchase in a shop, it retains an affordable option for a possible zero-income next run. The reserve check includes rewards that the proposed purchase would make claimable. Once the final chamber is available, the existing entry-fee banking rule takes over. Both the previous and rounded trees were rerun with this same policy for a matched comparison. This buyer change affects the simulation recommendations; the live game still leaves purchases to the player.

An initial policy that reserved an option from Prestige 0 delayed foundational upgrades and was rejected. Its partial traces and rejection reason remain in `round_numbers_buffered/` and `control_buffered/`; incomplete campaigns are excluded from completed-campaign totals.

The follow-up reruns three complete campaigns with the same reward-aware buyer and seeds. An independent [reward and rounding audit](reward_rounding_audit.json) reconciles reward credits against every shop phase and purchase wallet, checks catalog reward amounts and duplicate claims, and verifies every installed increment.

## Installed setting and saves

**Settings → UPGRADE TREE (RESTART)** selects **REBALANCED** (default) or **PREVIOUS**. Restart the game to apply. The choice stays locked during the session so a mid-run setting change cannot redirect loot or mix stats between trees.

- Rebalanced progress: `%APPDATA%/RailwayFury/row_divers_progress_balanced_v1.json`; starts fresh on first use.
- Previous progress: `%APPDATA%/RailwayFury/row_divers_progress_v1.json`; restores the original build and wallet.
- The original catalog is preserved byte-for-byte as `Games/RowDivers/Data/row_divers_previous.json`.

The shop adapter also renders zero-prerequisite entries as starting options, matching the existing progression API. The live shop test verifies that the new 4-gold impact upgrade is visible, affordable and applies its catalog value.

## Verification

- 6/6 rebalanced runtime/model comparisons match completion frame, distance, kills, income, HP, armor and damage sources; failures: 0. Six additional comparisons pass for the previous tree.
- All 21 setting/save/shop checks pass; original save hash unchanged: True.
- All three selected campaigns replay their recorded purchases and every realized outcome exactly, including the final saved state.
- Currency balances, purchase affordability, kill records, all four crowns, 100 maxed nodes and the final entry fee pass the per-campaign audits.
- Achievement reachability: pass; legal all-flat-before-percentage build reaches 62,155,026 arrow damage.
- Legally maxed build: 20/20 Prestige 3 clears on new seeds.
- Actual final campaign build: 20/20 Prestige 3 clears on new seeds.

All simulations use the requested assisted conditions: centered walking, automatic targeting/fire, no hostile-arrow damage and automatic abilities. Normal contact and corridor damage remain active. Free-aim and unassisted play are outside this validation. Full-project headless Godot test runs emit existing shader/resource-cleanup diagnostics; their behavioral assertions pass. Isolated campaigns and replays exit cleanly.

## Reproduce and inspect

- [Installed values and provenance](installed_tree.json)
- [All audited campaign comparisons](audited_comparison.json)
- [Whole-objective completion audit](completion_audit.json)
- [round_numbers_p3_buffer campaign traces and CSVs](round_numbers_p3_buffer/campaign.json)
- [Every run, seed 2401026](round_numbers_p3_buffer/campaign_runs.csv)
- [Every purchase and alternatives, seed 2401026](round_numbers_p3_buffer/campaign_choices.csv)
- [Every kill distance, seed 2401026](round_numbers_p3_buffer/campaign_kills.csv)
- `replay_2401026.json` / `...27.json` / `...28.json`: exact replays and starting loadouts for every run.
- `SourceSnapshot/`: frozen combat/progression source; runner snapshots are archived beside final candidate results.
- Run `python tools/rowdivers_balance/report_tuning.py --final` to regenerate this report.
