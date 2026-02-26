# Simulation V2 Design (Battle/Upgrade Alignment)

## Goals
- Keep upgrade prices unchanged.
- Reflect new battle behavior:
  - heroes start near left edge
  - enemies spawn in waves/groups
  - archer uses projectile hit timing (slower arrow flight)
  - archer effective range is full-screen
- Preserve prior progression targets from existing 2h report as closely as possible.

## Combat Model Changes
- Wave cadence:
  - `wave_size = 3`
  - follow-up enemies in the same wave use reduced contact gap.
- Archer projectile model:
  - archer DPS is scaled by projectile uptime multiplier.
  - each encounter includes an archer hit-delay penalty when archer is active.
- Other class scaling and upgrade effects remain unchanged.

## Tunables
- `SIM_WAVE_SIZE`
- `SIM_WAVE_FOLLOWUP_GAP_MULT`
- `SIM_ARCHER_PROJECTILE_DPS_MULT`
- `SIM_ARCHER_PROJECTILE_HIT_DELAY`

## Success Targets (from prior expectations)
- 2-hour sim runtime in same envelope.
- Similar run count (roughly 80-95 runs).
- Similar boss defeats (roughly 3-6).
- Max level around 4-5.
- No major early-game purchase dead zones.

## Pricing Policy
- Upgrade prices are unchanged in V2.
- Scenario selection is based on progression fit, not repricing.
