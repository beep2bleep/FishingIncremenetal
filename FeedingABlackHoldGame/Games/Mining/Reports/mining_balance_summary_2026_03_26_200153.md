# Mining Balance Summary

Date (UTC): 2026-03-26 20:01:53

## Scope

This follow-up pass focused on two items:

- set the mining demo to the recommended `group 6` cap for the longer `35-40 minute` demo
- target late-frontier reward scaling without breaking the already-stable early and midgame pacing

## Files Changed

- `project.godot`
- `Games/Mining/MiningBalance.gd`
- `Games/Mining/Simulation/mining_fast_balance_sim.py`

## Actions Taken

- enabled the mining demo cap explicitly in project settings with `mining_demo_max_group=6`
- added a late-frontier value bonus that starts after roughly depth `20` and ramps up only in the long campaign
- biased late-depth ore weighting harder toward the newest three tiers while trimming the oldest anchor weights, so deep selections are paid more often with frontier materials instead of diluted old pulls
- recalibrated the fast simulator after the gameplay change so the live headless spot checks returned inside the aggregate validation gate again

## Final Validated Results

From `Games/Mining/Reports/mining_fast_sim_report.md` dated `2026-03-26 20:01:53`:

- `20 minute demo`: `51` runs, `88` purchases, `1.725` upgrades/run, avg run `23.50s`, run band `18.85s` to `26.48s`, ending level `16`, depth `7`, wallet `$477`
- `40 minute demo`: `109` runs, `186` purchases, `1.706` upgrades/run, avg run `22.00s`, run band `18.17s` to `26.48s`, ending level `40`, depth `15`, wallet `$204880`
- `3 hour game`: `435` runs, `727` purchases, `1.671` upgrades/run, avg run `24.81s`, run band `15.70s` to `40.78s`, ending level `155`, depth `73`, wallet `$16002`

Validation summary:

- mean money error: `5.7%`
- mean XP error: `5.0%`
- mean time error: `6.3%`
- mean nodes error: `11.9%`
- aggregate `10%` gate: `passed`

## What Changed In Practice

- the short and long demo slices stayed inside the target run-length band without reopening the sub-15-second collapse from the rejected reward pass
- the long campaign kept the late game economically active while staying in the desired `15s` to `45s` run window
- the late frontier is now paid more through richer late-tier rolls and stronger post-depth-20 value growth, instead of leaning only on unlock pacing

## Remaining Read

This pass improved the late reward side cleanly enough to keep, but the far-late frontier still unlocks a bit faster than the ideal farm depth closes the gap. After this reward pass, the next best lever is probably not more reward growth; it is the late survivability and unlock relationship itself, especially drill durability pressure versus depth unlock rate beyond roughly depth `25`.

## Artifacts

- `Games/Mining/Reports/mining_fast_sim_report.md`
- `Games/Mining/Reports/mining_fast_sim_results.json`
- `Games/Mining/Reports/miningRunWithTimeAndDate_2026_03_26_200153.md`
- `Games/Mining/Reports/mining_validation_output.json`
