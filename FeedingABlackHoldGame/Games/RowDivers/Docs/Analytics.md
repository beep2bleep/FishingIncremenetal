# Railway Fury analytics

Uses the existing GameAnalytics manager and configured project credentials. Railway
Fury now has the `rowdivers` session identity instead of falling through to Vanguard.

| Design event | Trigger |
|---|---|
| `railway_fury:started` | First live dive in this save profile |
| `railway_fury:runs_completed_1` | First finished dive, including death |
| `railway_fury:runs_completed_5` | Fifth finished dive, including deaths |
| `railway_fury:prestige_0_defeated` | Defeat the final boss at Prestige 0 |
| `railway_fury:prestige_1_defeated` | Defeat the final boss at Prestige 1 |
| `railway_fury:prestige_2_defeated` | Defeat the final boss at Prestige 2 |
| `railway_fury:prestige_3_defeated` | Defeat the final boss at Prestige 3 |
| `railway_fury:ending` | Choose either ending after opening the final chamber |

These are once-per-save milestones. `analytics_milestones` in the existing save
persists deduplication across retries, repeated boss callbacks, reloads, and ending
revisits. Classic previous, classic rebalanced, and flying saves track independently.
Older saves catch up the 1/5-run thresholds on their next finished dive; historical
prestige wins and endings are not fabricated on load.

Every event includes `mode` (`classic` / `free_aim`), `upgrade_tree`
(`previous` / `rebalanced` / `flying`), `prestige` (0–3), and `runs_completed`.
Run thresholds also include `won`; ending includes `ending`
(`LastStation` / `BeyondTheRails`). Numeric event values identify the run threshold or
prestige. The existing session progression event is `Start:rowdivers:game`.

Battle and ending hooks require `persist_results`; simulations and previews with
persistence disabled do not emit milestones. Milestones are saved after queueing
through the existing analytics manager. They inherit its delivery behavior rather
than maintaining a second network queue.

`Tools/VerifyAnalytics.gd` exercises 20 cases with an in-memory capture sink and no
network requests: thresholds, deaths, all four prestiges, both endings, reentry,
JSON save/reload deduplication, separate modes/trees, older saves, and missing sink.
Run it in an isolated project with the helper, `RowDiversEndings.gd`, and a fake GameAnalytics node;
it deliberately does not use production analytics.

The full-project integration check passes eight additional cases for actual payload
construction, session identity, and preview suppression in both modes. It replaces
the production manager with an in-memory transport and performs no analytics HTTP
requests or player-progress writes. With `global/HighLevelMode=all`, run:

```powershell
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifyAnalyticsIntegration.gd
```
