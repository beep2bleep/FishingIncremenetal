# Mining Balance Summary

Date (UTC): 2026-03-26 21:49:36

## Scope

This pass focused on restoring cargo-space pressure over the full mining campaign without breaking the stable pacing from the prior balance work.

- make richer late-tier ore consume meaningfully more hold space so cargo upgrades stay relevant
- keep the bank/dropoff loop active instead of letting high-value material trivialize the hold
- preserve the usefulness of collection and delivery drones through the `3 hour` campaign rather than letting raw hold growth invalidate them

## Files Changed

- `Games/Mining/MiningBalance.gd`
- `Games/Mining/Scenes/MiningMain.gd`
- `Games/Mining/Simulation/mining_fast_balance_sim.py`

## Actions Taken

- replaced the old flat `1 item = 1 cargo slot` rule with weighted cargo space based on material value, capped so deep ore is heavier without becoming impossible to move
- changed delivery drone dispatching from item-count throughput to cargo-space throughput, so higher-value materials also tax delivery efficiency unless the player keeps buying support upgrades
- taught pickup logic, manual collection, and drone collection to respect weighted hold space, preventing drones from bypassing the intended hold pressure
- updated the fast simulator to mirror the live cargo-space rules so the long-run buying path and headless validations stayed trustworthy
- refreshed the UI text and upgrade tooltip copy so the player sees cargo space instead of raw item count where behavior changed

## Final Validated Results

From `Games/Mining/Reports/mining_fast_sim_report.md` dated `2026-03-26 21:49:36`:

- `20 minute demo`: `51` runs, `88` purchases, `1.725` upgrades/run, avg run `23.50s`, ending level `16`, depth `7`, wallet `$477`
- `40 minute demo`: `109` runs, `186` purchases, `1.706` upgrades/run, avg run `22.00s`, ending level `40`, depth `15`, wallet `$204880`
- `3 hour game`: `435` runs, `727` purchases, `1.671` upgrades/run, avg run `24.81s`, ending level `155`, depth `73`, wallet `$16002`

Validation summary:

- mean money error: `6.4%`
- mean XP error: `6.9%`
- mean time error: `6.2%`
- mean nodes error: `13.5%`
- aggregate `10%` gate: `passed`

## Cargo Pressure Read

The hold loop is materially more relevant again in the long campaign:

- first `20 minutes`: average `1.08` bank trips/run and `0.00` delivery dumps/run, which keeps the early demo mostly player-driven
- first `40 minutes`: average `0.63` bank trips/run and `0.06` delivery dumps/run, showing drones entering the loop without taking it over
- `3 hour` slice: average `0.49` bank trips/run and `12.12` delivery dumps/run
- late campaign (`runs 301-435`): average `0.57` bank trips/run and `33.33` delivery dumps/run, with runs peaking at `59` delivery dumps

That is the intended direction: late ore now pressures both hold capacity and cargo throughput hard enough that cargo pods, compressors, delivery drones, and sorters all stay meaningful.

## What Changed In Practice

- deep materials no longer behave like free value in the hold; richer ore now consumes more of the cargo budget and reaches the dropoff loop sooner
- collection drones no longer quietly erase the hold constraint because they only target pickups that still fit in the remaining cargo space
- delivery drones continue to matter late, but they no longer neutralize the hold problem purely by scaling item count, because their dispatch is budgeted in cargo space as well
- run times stayed in the desired band while restoring cargo friction, so this pass did not reintroduce the runaway level-duration problem

## Remaining Read

This pass is worth keeping. The main remaining question is feel, not stability: if we want even more visible cargo pressure in the late frontier, the next lever should be node composition and per-node value density rather than making ore dramatically heavier again. In other words, the next step would be deciding whether deeper tiers should pay through more medium-heavy nodes instead of a few very rich ones.

## Artifacts

- `Games/Mining/Reports/mining_fast_sim_report.md`
- `Games/Mining/Reports/mining_fast_sim_results.json`
- `Games/Mining/Reports/miningRunWithTimeAndDate_2026_03_26_214936.md`
- `Games/Mining/Reports/mining_validation_output.json`
