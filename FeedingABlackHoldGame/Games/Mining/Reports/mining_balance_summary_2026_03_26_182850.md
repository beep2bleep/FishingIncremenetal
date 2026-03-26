# Mining Balance Summary

Date (UTC): 2026-03-26 18:28:50

## Scope

This pass focused on the follow-up Mining requests:

- keep runs in the `15s` to `45s` band
- keep at least one useful upgrade per run
- keep speed upgrades much weaker than the earlier tuning
- keep delivery drones far slower than the original implementation
- add depth-based drone slowdown so drone upgrades stay relevant
- make drill damage, drill health, and drill wear require ongoing investment
- keep fast sim vs headless Godot validation within the aggregate `10%` gate

## Files Changed

- `Games/Mining/MiningBalance.gd`
- `Games/Mining/Scenes/MiningMain.gd`
- `Games/Mining/Simulation/mining_fast_balance_sim.py`

## Iteration Log

### Pass 01

Changes made:

- added depth drag to delivery and salvage drones
- tightened drill damage, impact damage, drill plating, and drill wear
- made post-depth-13 material progression continuous instead of resetting
- repriced drill, drone, refinery, XP, and scanner upgrades

Fast-sim read:

- `20m`: `53` runs, `75` purchases, `1.415` upgrades/run, avg run `22.41s`
- `40m`: `111` runs, `176` purchases, `1.586` upgrades/run, avg run `21.60s`
- `3h`: `426` runs, `677` purchases, `1.589` upgrades/run, avg run `25.29s`

Outcome:

- frontier depth tracking improved sharply in the midgame
- delivery drones became too weak to matter by the `40m` slice
- late drill deaths were too high

### Pass 02

Changes made:

- eased drill wear slightly and raised drill plating value
- steepened XP requirements so late unlocks slowed down
- restored some delivery lane speed and dispatch cadence

Fast-sim read:

- `20m`: `52` runs, `73` purchases, `1.404` upgrades/run, avg run `22.91s`
- `40m`: `107` runs, `161` purchases, `1.505` upgrades/run, avg run `22.31s`
- `3h`: `423` runs, `700` purchases, `1.655` upgrades/run, avg run `25.50s`

Outcome:

- run times and drill pressure stabilized
- late delivery usage returned
- this became the gameplay balance baseline kept for the final pass

### Pass 03 (Rejected)

Changes made:

- tried increasing late material reward growth to pull the sim closer to the extreme frontier

Fast-sim read:

- `40m` minimum run time fell to `9.24s`
- `39` of the `40m` runs dropped under `15s`

Outcome:

- this over-rewarded the midgame and broke the target run-length band
- rolled back

### Final Calibration

Changes made:

- recalibrated only the fast autoplay model
- raised simulated move/drill throughput and reduced simulated wear so the fast model tracked the live scene better after the drill rebalance

Outcome:

- aggregate validation returned to the `10%` gate without changing gameplay again

## Final Validated Results

From `Games/Mining/Reports/mining_fast_sim_report.md` dated `2026-03-26 18:28:50`:

- `20 minute demo`: `52` runs, `82` purchases, `1.577` upgrades/run, avg run `22.87s`, run band `21.60s` to `25.32s`, ending level `16`, depth `7`, wallet `$786`
- `40 minute demo`: `114` runs, `216` purchases, `1.895` upgrades/run, avg run `20.91s`, run band `15.99s` to `25.32s`, ending level `39`, depth `16`, wallet `$243041`
- `3 hour game`: `439` runs, `736` purchases, `1.677` upgrades/run, avg run `24.58s`, run band `15.90s` to `44.69s`, ending level `155`, depth `72`, wallet `$48205`

Validation summary:

- mean money error: `8.6%`
- mean XP error: `9.6%`
- mean time error: `8.9%`
- aggregate `10%` gate: `passed`

Notes:

- some individual checkpoints still drift, especially around the `purchase_150` band
- aggregate spot checks are back inside the requested gate, but the fast model is still not a perfect predictor at a few late knife-edge states

## Balance Decisions Kept

- movement upgrades remain much weaker than the pre-pass mining tuning
- delivery drones stay slow and now also lose speed with depth, so deeper tiers require more delivery investment
- salvage drones also lose speed with depth, but less aggressively than delivery drones
- drill torque, plating, cooling, and foreman upgrades all matter more often
- post-depth-13 materials no longer reset to easy values; the depth curve now continues upward
- scanner and XP pacing were both slowed to reduce unlock runaway

## Demo Recommendation

Recommended demo cap:

- `20 minute demo`: stop around upgrade `group 4`
- `35-40 minute demo`: stop around upgrade `group 6`

Why:

- `group 4` gives a clean short demo with the core drill/cargo/salvage loop online
- `group 6` lets players see first delivery-drone unlocks without fully entering the long tail where delivery and sorter chains start stacking hard
- the first `Delivery Drone` purchase in the final run report appears at run `75`, and the first `Auto Sorters` purchase appears at run `98`, so `group 6` is the cleanest place to stop a longer public demo

## Remaining Caveat

The main remaining balance smell is late frontier selection: the sim still unlocks deeper tiers faster than it wants to farm them in the far late game. If we do another pass, the next best target is late-depth reward scaling beyond roughly depth `20`, not early or midgame pacing.

## Detailed Artifacts

- `Games/Mining/Reports/mining_fast_sim_report.md`
- `Games/Mining/Reports/mining_fast_sim_results.json`
- `Games/Mining/Reports/miningRunWithTimeAndDate_2026_03_26_182850.md`
