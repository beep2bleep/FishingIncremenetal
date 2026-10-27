# Crown-gated playthrough — 26 October 2026

One fresh seeded campaign completed all four prestiges and paid the final fee in **40 runs**. This is a verification run, not a new multi-seed balance study.

| Prestige | Attempts to first clear | All attempts, including fee farming |
|---:|---:|---:|
| 0 | 8 | 8 |
| 1 | 12 | 12 |
| 2 | 8 | 8 |
| 3 | 10 | 12 |

Deaths: enemy contact: 8, the row: 10, enemy arrows: 2, fire waves: 14. Across 1,505 kills, mean horizontal separation was 6.77 m, median 7.22 m, and 24.9% occurred at ≥80% attack range.

The buyer made 352 legal purchases and collected achievement rewards of [10875.0, 20.0, 3.0]. The audit reconciles every purchase wallet and total gold/gems/crowns, validates crown prerequisites and prestige gates, checks fixed wave damage, and rejects time-capped runs. The complete trace replays within JSON numeric serialization tolerance.

Thirty-six runtime feature checks cover crown gating, refunds, autopilot aim/shot/dodge/collection, normal-step 64×/128× speeds, manual restoration, editor gating, and the two new endings. Twenty editor auto-buy checks include the actual button, tree refresh, real costs, cancellation, same selector/weights, achievement funding, reserved ending funds, and the selected classic Previous catalog. Six native/model flying comparisons pass. New endings also pass the analytics capture checks. Full-project tests retain existing startup/render-resource cleanup diagnostics; no script errors appear in these successful checks.

[Feature guide](../../Docs/CrownEditorPlaythrough.md) · [Audit](audit.json) · [Choices](choices.csv) · [Runs](runs.csv) · [Replay](replay.json)

The exact campaign inputs are archived in `SourceSnapshot/`. Current runtime sources also initialize the migration marker for new saves and animate the editor crosshair; these do not change legal campaign combat. Editor forecasts always copy the current runtime models and progression rules.
