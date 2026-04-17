# Open Pit Empire Progression Simulation

This is a design-target pacing model for Open Pit Empire.
It assumes a huge persistent pit, but the campaign is paced around clearing a frontier path, hauling value back, and buying one meaningful upgrade per run.

## Pit Scale
- Total mineable blocks per layer in the live pit: 71,760
- Total mineable blocks across 4 layers: 287,040
- Frontier objective blocks used for pacing:
  - Topsoil: 5,000 (7.0% of that layer)
  - Mid: 7,000 (9.8% of that layer)
  - Deep: 32,000 (44.6% of that layer)
  - Core: 70,000 (97.5% of that layer)
  - Final boss equivalent: 45,000 extra core-damage work after reaching the core

## Milestones
- `layer_1_clear`: 23.3m
- `layer_2_clear`: 43.3m
- `layer_3_clear`: 70.2m
- `layer_4_clear`: 109.2m
- `campaign_complete`: 119.8m

## Upgrade Shape
- Early game: damage, fire rate, cargo, and the first permit drive the 0-40 minute ramp.
- Mid game: splitter targets, movement, pickup, and value upgrades sustain repeated Mid and Deep runs.
- Late game: drones, crit/AOE, and core tuning carry the Core push without needing to excavate the full 287k+ block pit.

## Result Snapshot
- Runs: 147
- Elapsed: 119.8m
- Final upgrade levels:
  - damage: 18
  - rate: 16
  - cargo: 16
  - layer: 3
  - targets: 8
  - move: 12
  - pickup: 12
  - value: 12
  - time: 12
  - drones: 8
  - crit: 10
  - explosion: 8
  - chain: 8
  - core: 4
