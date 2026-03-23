# Mining Rework Plan

## Goal

Rebuild Mining into a top-down drilling game with short repeatable runs, surface banking, persistent upgrades, XP-based depth progression, and a cleaner runway for future drones, weapons, hazards, and content tiers.

## Prototype Loop

1. Start a run at the currently unlocked depth tier.
2. Move through dirt while looking for resource nodes.
3. Drill nodes to break them into pickups.
4. Drive over pickups to load cargo.
5. Return to the surface ring to bank cargo and free space.
6. Run ends when the timer or drill health hits zero.
7. Summary converts banked cargo into money and applies XP.
8. Spend money in the upgrade tree, then repeat.

## Current Math Model

### Run stats

- Base timer: `10 + 1.5 * timer_reserve`
- Base move speed: `130 + 14 * engine_tuning`
- Dirt movement multiplier: `clamp(0.72 - 0.035 * (depth_level - 1) + 0.04 * dirt_softener, 0.34, 0.95)`
- Drill DPS: `22 + 5.5 * drill_torque`
- Drill health: `84 + 18 * drill_plating`
- Cargo capacity: `10 + 3 * cargo_pods`
- Pickup radius: `30 + 7 * pickup_radius + 18 * magnet_drone`
- Value multiplier: `1.0 + 0.12 * ore_refinery`
- XP multiplier: `1.0 + 0.11 * xp_calibration`

### Depth progression

- Prototype currently auto-selects the deepest unlocked tier.
- Depth unlock cap: `1 + (player_level - 1) + depth_scanner`
- Max depth tier currently configured: `13`
- This gives fast prototype progression so we can iterate on feel before tightening the curve.

### XP curve

- XP needed for next level: `round(28 + 18 * level^1.28)`
- This is intentionally light early so new depth tiers unlock quickly during tuning.

### Resource tiers

- Base material: `Stone`
- Upgrade tiers: `Bronze`, `Silver`, `Gold`, `Diamond`
- Premium tiers: `Platinum Bronze`, `Platinum Silver`, `Platinum Gold`, `Platinum Diamond`
- Late tiers: `Super Bronze`, `Super Silver`, `Super Gold`, `Super Diamond`
- Each tier increases value, XP reward, hardness, and sparkle intensity.
- Each deeper level still includes older materials, but weights the newest material much more heavily.

## Simulation Plan

We should add a proper mining balance simulation pass next. The simulation should:

1. Generate expected nodes per depth tier from the spawn weights.
2. Estimate average time spent moving, drilling, collecting, and banking.
3. Estimate expected money and XP per run at each upgrade package.
4. Compare "clear percent of map" versus "time to reach next tier" curves.
5. Flag outliers where one upgrade dominates or a depth tier stalls too hard.

Suggested simulation outputs:

- Expected money per minute by depth tier
- Expected XP per minute by depth tier
- Average nodes broken before timeout
- Average cargo bank trips per run
- Average runs required to afford each upgrade
- Average runs required to unlock next depth tier

## Implementation Roadmap

### Complete next

- Add actual depth selection UI instead of auto-advancing to the deepest unlocked tier
- Add hazards that damage hull
- Convert timer pressure into oxygen support if we want separate oxygen and time stats
- Add drone actors instead of passive stat-based drone effects
- Add lasers, missiles, and other active power systems
- Add richer cave generation and chokepoints instead of simple open-field resource placement
- Add icons and bespoke VFX for the new upgrade tree nodes

### Content work

- Generate real icons for all mining upgrades
- Create distinct pickup sprites by material tier
- Add sparkles/overlays instead of pure color-only differentiation
- Add drilling hit effects, banking effects, and summary polish
- Replace placeholder HUD labels with mining-specific art direction

### Balance work

- Tune early game timer/drill/cargo values
- Tune resource value and hardness across all tiers
- Decide how much depth unlocks should come from XP versus upgrades
- Tune drone upgrades so they are strong but not mandatory
- Add diminishing returns or branching choices if the tree becomes too linear
