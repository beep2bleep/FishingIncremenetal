# Railway Fury analytics

Uses the existing REST GameAnalytics manager with separate Windows/Steam games in
the Beep2Bleep organization:

| Edition | GameAnalytics game | Project settings prefix |
|---|---|---|
| Full | [Railway Fury (359020)](https://tool.gameanalytics.com/game/359020/realtime/live-events) | `gameanalytics/railway_full_` |
| Demo | [Railway Fury Demo (359021)](https://tool.gameanalytics.com/game/359021/realtime/live-events) | `gameanalytics/railway_demo_` |

Each prefix has `game_key` and `secret_key` settings loaded from the ignored local
file `res://railway_analytics.local.cfg`. The file has a `[gameanalytics]` section
with `railway_full_game_key`, `railway_full_secret_key`, `railway_demo_game_key`,
and `railway_demo_secret_key` string values. Keep these values out of GitHub.
The export tooling includes this local file in release packs, and the Steam build
script requires it before exporting. The demo
export feature (or the editor demo setting) selects the demo credentials; full
builds select the full credentials. Neither falls back to another game's keys.
The session identity remains `rowdivers`, with separate state files
`user://gameanalytics_state_rowdivers_full.cfg` and
`user://gameanalytics_state_rowdivers_demo.cfg`. These new state names also reset
first-start tracking previously sent to the shared game's credentials.
The launcher starts a session when entering Railway Fury, even when the save's
once-only gameplay milestones have already been sent.

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

The full-project integration check covers twelve cases for actual payload
construction, edition credentials/state isolation, session identity, and preview
suppression in both modes. It replaces
the production manager with an in-memory transport and performs no analytics HTTP
requests or player-progress writes. With `global/HighLevelMode=all`, run:

```powershell
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifyAnalyticsIntegration.gd
```

On 2026-10-30, both editions passed a live smoke check through the real Godot
manager: init and events requests returned HTTP 200. Verification sessions use
build `analytics-verification-20261030` and the design event
`railway_fury:integration_check`, with `verification=true` and the edition's `demo`
flag. This intentionally creates a labelled test session in each live game.
Run the explicit network check from the repository root with the source project
in launcher mode (never as part of routine offline checks):

```powershell
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script "$PWD/tools/railway_steam/verify_analytics_live.gd" -- full
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script "$PWD/tools/railway_steam/verify_analytics_live.gd" -- demo
```

Inspect Realtime > Live events for immediate verification; aggregated dashboards
can lag behind ingestion. Older distributed builds retain their old keys until
replaced by a rebuilt version.
