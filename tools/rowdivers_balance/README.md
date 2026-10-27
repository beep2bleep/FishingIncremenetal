# Railway Fury offline balance simulator

The installed rebalance and its 35 full campaign comparisons are documented in
[`TUNING_REPORT.md`](../../FeedingABlackHoldGame/Games/RowDivers/Simulation/Tuning/TUNING_REPORT.md).
In the game, **Settings → UPGRADE TREE (RESTART)** selects **REBALANCED** or **PREVIOUS**.
Rebalanced uses `row_divers_progress_balanced_v1.json`; Previous uses the original
`row_divers_progress_v1.json`. Each keeps its own progress, and restart applies the choice.

Reproduce the selected tree with the exact frozen combat and current buying policy:

```powershell
python tools/rowdivers_balance/run.py --frozen-snapshot FeedingABlackHoldGame/Games/RowDivers/Simulation/Tuning/SourceSnapshot --current-runner --catalog FeedingABlackHoldGame/Games/RowDivers/Data/row_divers.json --config FeedingABlackHoldGame/Games/RowDivers/Simulation/Tuning/release/config.json --output FeedingABlackHoldGame/Games/RowDivers/Simulation/Tuning/Recheck/campaign.json
python tools/rowdivers_balance/report_tuning.py --final
python tools/rowdivers_balance/audit_tuning_completion.py
```

Use `--catalog FeedingABlackHoldGame/Games/RowDivers/Data/row_divers_previous.json` for
the previous tree. `--current-runner` retains frozen combat while using the present
selection/reporting code. `--catalog` replaces only the isolated experiment's catalog.
The original baseline snapshot is immutable; `tune_trees.py generate` refuses to overwrite it.

Run commands from the repository root. Requires Python 3 and the bundled Godot 4.6 console executable; no Python packages are needed.

## Flying / free aim

The current crown-gated flying tree, accelerated editor pilot, Auto Buy button, and
two endings are documented in
[`CrownEditorPlaythrough.md`](../../FeedingABlackHoldGame/Games/RowDivers/Docs/CrownEditorPlaythrough.md).
Current verification is in
[`CrownValidation/REPORT.md`](../../FeedingABlackHoldGame/Games/RowDivers/Simulation/CrownValidation/REPORT.md).
The earlier gem-gated balance study remains in
[`Flight/REPORT.md`](../../FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/REPORT.md).
Flying uses `row_divers_free_aim.json` and the separate
`user://row_divers_progress_flying_v1.json` save. Classic tree settings apply to classic mode.

```powershell
# Reproduce the installed flying balance and its bounded active pilot.
python tools/rowdivers_balance/run.py --free-aim --frozen-snapshot FeedingABlackHoldGame/Games/RowDivers/Simulation/CrownValidation/SourceSnapshot --catalog FeedingABlackHoldGame/Games/RowDivers/Simulation/CrownValidation/SourceSnapshot/row_divers_free_aim.json --config FeedingABlackHoldGame/Games/RowDivers/Simulation/CrownValidation/config.json --output flight_reproduced.json

# Test a flying save without buying upgrades or writing to that save.
python tools/rowdivers_balance/run.py --free-aim --snapshot --repeats 20 --input "$env:APPDATA/RailwayFury/row_divers_progress_flying_v1.json" --output flying_save_test.json

# Validate actual game/model parity and actual shop gating/purchases.
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Simulation/ValidateFlight.gd
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Simulation/ValidateFlightTree.gd
python tools/rowdivers_balance/report_crown.py
```

`free_aim=true` enables the observed-threat pilot and generated flying model. Native
projectile travel, enemy arrows, contact, hallway drain, acceleration, aiming, loot
pickup, cooldowns, and waves are simulated. There is no hostile-arrow immunity.
`pilot` accepts `reaction` (seconds, default 0.18) and `aim_error` (radians, default
0.012). It is a reproducible heuristic, not a measured human player. Use a flying
snapshot with `--free-aim`; historical classic snapshots do not contain this model.
Flying campaigns claim ready achievements before shopping and after every purchase,
and include those credits in further purchases. These commands never write live progress.

```powershell
# Fresh campaign, as fast as the CPU permits; all four prestiges and final chamber.
python tools/rowdivers_balance/run.py

# Repeat a read-only test of your saved upgrades.
python tools/rowdivers_balance/run.py --snapshot --repeats 20 --input "$env:APPDATA/RailwayFury/row_divers_progress_v1.json" --output FeedingABlackHoldGame/Games/RowDivers/Simulation/Results/current_save.json

# Custom starting upgrades, prestige, resources and selection weights.
python tools/rowdivers_balance/run.py --config tools/rowdivers_balance/scenario.example.json --output FeedingABlackHoldGame/Games/RowDivers/Simulation/Results/scenario.json

# Build the local report and CSV logs after the fresh campaign.
python tools/rowdivers_balance/report.py
python tools/rowdivers_balance/verify_results.py

# Compare the stripped model with real battle code. This uses the full project's
# autoloads, but disables progression persistence in both test battles.
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Simulation/ValidateBalanceModel.gd
```

The Python launcher builds a temporary, autoload-free Godot project, copies the current catalog and progression rules, regenerates combat methods directly from `RowDiversBattleScene.gd`, and runs the offline runner. It does not read your save unless you pass `--input`, and never writes it. Output files contain full starting/final state, so experiments remain reviewable even if the real save changes later.

The recorded campaign's exact source and runner are preserved in `Results/SourceSnapshot`. Reproduce that version after gameplay changes with `--frozen-snapshot FeedingABlackHoldGame/Games/RowDivers/Simulation/Results/SourceSnapshot`. The recorded campaign models classic assisted combat; the concurrently developed free-aim variant is outside its scope.

`GeneratedCombatModel.gd` is generated; edit `build_model.py` or the real game source instead. `source_manifest.json` hashes the original combat methods. Normal combat, projectile pooling behavior, healing, armor, loot collection, contact checks, spawns and cooldown update order are retained. Visual/audio/persistence work is removed. Gates retain their gameplay behavior (boss position blocks forward progress); their opening animation is omitted.

Configuration supports:

- `mode`: `campaign`, `snapshot`, or `recommend` (select one affordable next purchase and log the alternatives).
- `input`: absolute path to a full progression JSON; optionally override `wallet` and `prestige` for snapshot/recommend experiments. `--input` overrides this field.
- `upgrades`: ordered `{ "name": "Max HP I", "levels": 2 }` purchases, by displayed name or ID. Parent prerequisites and caps are enforced. They are added to the input loadout; resources are not charged against the scenario wallet. Order matters for compounded stats. To represent a previously played build accurately, use its full saved stats and levels instead.
- `wallet`: `[gold, gems, crowns]`; `prestige`: 0–3.
- `weights`: `distance`, `gold_rate`, `gem_rate` (defaults 0.55/0.30/0.15).
- `shortlist`: how many proxy-ranked affordable purchases receive a full run forecast (default 4). Use 112 for every classic candidate or 128 for every flying candidate; shortlists are approximate. The recorded flying campaigns use 2.
- `seed`, `dt` (default 1/60), `repeats`, `max_runs`, `max_run_seconds` (1800 game seconds per run).
- `row_damage_scale` (default 1): counterfactual analysis only. Set to 0 to isolate the effect of hallway damage. This does not change live game balance.

Campaigns choose the highest unlocked prestige each run; snapshots/recommendations honor the requested prestige. In classic simulations, walking is enabled; Shift running and lateral steering are off. Classic assist rules automatically aim/fire, ignore hostile arrows, and activate unlocked abilities on cooldown. Ordinary enemy contact and row damage remain active. Flying uses the active pilot described above. This is an offline balance tool, not a runtime cheat toggle or automatic upgrade buyer in the live game.

The weighting model combines forecast improvements in reach and income per game-second with effective health against walking/contact damage, normal and boss DPS, healing, range, pickup and unlock potential, plus a currency-specific expected-run price penalty. Winning the row receives an additional bonus. Each decision logs its affordable shortlist, scores, costs, forecasts and wallet. It recomputes after each purchase, preserving real purchase-order effects. It is a greedy policy; it does not search future purchase sequences. Set `ending_reserve=true` to buy one upgrade per run and bank entry funds once GodTab is available. The selected-tree experiments use reach/gold/gem weights 0.60/0.28/0.12 and shortlist 4. One seed is used per decision and separate seeds for realized campaign runs.

`Results/runs.csv` logs every realized run; `kills.csv` logs every kill's range and time; `choices.csv` logs every purchase. Full JSON retains the order of purchases, claimed rewards, initial/final states and per-kill detail. No balancing changes are made by this tool.
