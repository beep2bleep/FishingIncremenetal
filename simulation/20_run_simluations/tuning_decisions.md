# 20-Run Tuning Decisions

## Requested Targets
- Buy roughly 1-2 upgrades per run.
- Grow kills by roughly 1-2 per run over repeated runs.
- Use BattleScene infinite-speed simulation for measurements.

## Gameplay Changes Implemented
- Archer damage reduced to ~1/3 baseline output in hero spawn damage init.
- Knight damage increased by 20% in hero spawn damage init.
- Enemy spawn pacing changed to semi-random groups of 1-3 with larger inter-group spacing.
- Enemies stacked behind a front contact enemy now contribute +50% of their contact DPS to hero damage.
- Enemy attack telegraph improved (grow + blink + horizontal shake).
- If a front enemy attacks while compressed, the enemy behind also triggers attack animation.
- Active skills now auto-cast in normal simulation steps (not only in one-off infinite routine), gated by cooldown + power.
- Active base energy cost lowered from 80*mult (min 24) to 60*mult (min 20) to ensure regular usage in runtime.

## Upgrade Economy/Power Retuning
- Added simulation upgrade price multiplier in adapter:
  - `SIM_PRICE_MULT = 2.15`
- Added post-build global upgrade effect tuning pass in BattleScene:
  - compresses upgrade multipliers toward baseline so growth is incremental,
  - especially for damage/speed/coin/power/active modifiers,
  - reduces runaway jumps and aligns with +1 to +2 kill trend target.

## 20-Run Simulation Passes
- Reports generated from `res://simulation/run_20_battle_scene_passes.gd`.
- Three independent passes with distinct seeds.

### Overview
- `pass_01`: avg upgrades/run = 1.00, avg kill delta/run = 1.68
- `pass_02`: avg upgrades/run = 0.95, avg kill delta/run = 1.68
- `pass_03`: avg upgrades/run = 1.00, avg kill delta/run = 1.68

## Interpretation
- Upgrade purchase rate target is met consistently (~1 upgrade/run average).
- Kill growth target is met on average (~1.68/run).
- Progression still contains step changes (not perfectly linear each run), especially around early unlock thresholds and level transition.

## Files Produced
- `overview.md`
- `pass_01.md`, `pass_02.md`, `pass_03.md`
- `pass_01.json`, `pass_02.json`, `pass_03.json`

All are in folder: `simulation/20_run_simluations`.
