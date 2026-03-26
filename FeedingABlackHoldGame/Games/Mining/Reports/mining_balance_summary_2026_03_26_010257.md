# Mining Balance Summary

Date (UTC): 2026-03-26 01:02:57

## Scope

Rebalanced Mining mode around short repeatable runs, steadier tier pressure, and more frequent meaningful upgrades. This pass targeted:

- 20 minute and 40 minute demo pacing
- A 3 hour long-form progression path
- At least one useful upgrade per run on average
- Run lengths centered around 15 to 45 seconds
- Movement upgrades reduced to roughly 20% of their earlier impact
- Delivery drone return speed reduced to roughly 10% of its earlier speed
- Better parity between the Python fast sim and headless Godot spot checks

## Balance Changes Made

- Reduced movement scaling sharply:
  - `Engine Tuning` now adds much less move speed.
  - `Route Planner` now gives smaller move speed and dirt-drag relief.
  - `Dirt Softener` was flattened so depth still matters.
- Reduced cargo drone throughput sharply:
  - Delivery drones now fly far slower.
  - Dispatch cadence and sorter scaling were rebuilt around that slower lane.
- Tightened tier pressure:
  - Node health and depth scaling were flattened compared with the old runaway curve.
  - Drill DPS, drill health, and wear were re-tuned so the current frontier depth stays closer to the "just barely manageable" line.
  - Time drain now ramps more smoothly by depth.
- Slowed progression unlock runaway:
  - XP requirements were raised.
  - Depth unlocks now grow more slowly from player level.
  - Later material loops scale more gently.
- Repriced the whole upgrade track:
  - Early upgrades stay accessible.
  - Midgame and lategame costs ramp harder.
  - Sim purchasing now tends to make near-max useful buys instead of hoarding or dumping money into low-value upgrades.
- Updated upgrade descriptions/tooltips so the displayed effects match the new formulas.

## Simulation / Validation Work

- Ran repeated fast-sim balance passes during tuning.
- Recalibrated the fast autoplay model against headless Godot validation using saved checkpoints.
- Final fast/live validation averages:
  - Money error: `5.4%`
  - XP error: `5.5%`
  - Time error: `8.5%`
  - 10% gate: `passed`
- Representative passing checkpoints stayed within 10% on aggregate, including the early and mid progression spot checks used during validation.

## Final Progression Results

- 20 minute demo:
  - `53` runs
  - `89` purchases
  - `1.679` upgrades/run
  - average run `22.50s`
  - run range `16.55s` to `25.04s`
  - ending state: level `20`, depth `12`, wallet `$16319`
- 40 minute demo:
  - `117` runs
  - `228` purchases
  - `1.949` upgrades/run
  - average run `20.43s`
  - run range `15.36s` to `25.04s`
  - ending state: level `44`, depth `26`, wallet `$224651`
- 3 hour game:
  - `490` runs
  - `603` purchases
  - `1.231` upgrades/run
  - average run `21.99s`
  - run range `12.93s` to `36.51s`
  - ending state: level `123`, depth `71`, wallet `$498`

## Run-Length Distribution Notes

- `491 / 513` runs landed at `15s` or above.
- `22 / 513` runs were under `15s` (`4.29%` of the campaign).
- `0 / 513` runs exceeded `45s`.
- The remaining short outliers happen in a mid-to-late transition band rather than across the whole game.

## Files / Reports

- Balance code:
  - `Games/Mining/MiningBalance.gd`
- Fast sim and validation tooling:
  - `Games/Mining/Simulation/mining_fast_balance_sim.py`
- Detailed reports generated:
  - `Games/Mining/Reports/mining_fast_sim_report.md`
  - `Games/Mining/Reports/mining_fast_sim_results.json`
  - `Games/Mining/Reports/miningRunWithTimeAndDate_2026_03_26_010257.md`
  - `Games/Mining/Reports/mining_validation_input.json`
  - `Games/Mining/Reports/mining_validation_output.json`

## Outcome

Mining now has a much steadier curve:

- new tiers push back hard enough to feel risky,
- upgrades recover that pressure without letting speed explode,
- demos keep unlocking levels and buying upgrades frequently,
- the 3 hour path still has room to grow without level time getting absurd.
