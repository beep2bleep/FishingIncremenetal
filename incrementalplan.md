# Deterministic Combat Incremental Plan

## Vision
Build a deterministic combat incremental game from your current base where each run progresses through a fixed level layout, pushes toward a boss, and grants enough currency to buy at least one upgrade per run.

No randomization is used.

## Core Loop
1. Start a run on a selected level.
2. Hero moves forward through a fixed enemy lane.
3. Hero deals damage by perfect clicking.
4. Hero takes damage from:
- continuous damage-over-time while alive
- contact damage while physically blocked by living enemies
5. Enemy kills drop currency pickups.
6. Collection split is fixed:
- 60% collected by cursor
- 30% collected by hero walk-over
- 10% lost off-screen
7. End run on hero death or boss death.
8. Buy upgrades.
9. Repeat until boss is defeated, then move to next harder level with higher rewards.

## Deterministic Gameplay Model

### Level Structure
Each level has:
- fixed list/count of regular enemies
- fixed boss at the end
- fixed base enemy stats (HP, contact damage, currency)
- fixed environmental DoT
- deterministic scaling by level index

No procedural spawn logic, no RNG rolls.

### Movement and Combat
- Hero moves forward at fixed speed.
- Enemy blocks lane; hero cannot pass while enemy is alive.
- Hero attack model:
- Base attack is perfect clicking at fixed clicks-per-second.
- Later, Auto-Attack upgrade adds passive attacks on top of clicks.
- Range determines how early hero starts damaging the current enemy before contact.

Per enemy deterministic resolution:
1. Approach time until entering range.
2. Time-to-kill from effective DPS.
3. Contact time = max(0, TTK - pre-contact attack time).
4. Apply DoT during full encounter time.
5. Apply contact damage during contact time.
6. Add currency drop and split by collection percentages.

### Explicit Simulation Equations (v1)
- `hero_dps = attack_damage * (perfect_click_rate + auto_attack_rate_if_unlocked)`
- `ttk = enemy_hp / hero_dps`
- `time_to_contact = enemy_gap / hero_move_speed`
- `pre_contact_attack_time = min(time_to_contact, range / hero_move_speed)`
- `contact_time = max(0, ttk - pre_contact_attack_time)`
- `dot_damage_taken = dot_dps * (delay_before_attack + ttk) * (1 - armor_reduction)`
- `contact_damage_taken = enemy_contact_dps * contact_time * (1 - armor_reduction)`
- run ends when hero HP <= 0 or boss HP <= 0

### Damage Intake and Armor
Incoming damage per second:
- `incoming = (dot_dps + contact_dps_when_colliding) * (1 - armor_reduction)`

Armor is deterministic and capped.

### Currency Collection Rules
For each enemy drop amount `drop`:
- Cursor-collected: `0.6 * drop`
- Hero-collected: `0.3 * drop`
- Missed: `0.1 * drop`

If cursor bonus upgrade is unlocked:
- add `+1` currency per enemy to cursor-collected amount
- this bonus can be upgraded to `+N` if desired

Total credited currency per enemy:
- `credited = 0.9 * drop + cursor_bonus_per_enemy`

Boss follows same collection logic and grants a large base drop.

## Upgrade Set
Permanent upgrades between runs:
- Damage: increases damage per attack.
- Range: increases pre-contact damage window.
- Armor: reduces all incoming damage.
- Enemy Density: increases regular enemy count in level (more danger, more drops, more income ceiling).
- Resource Yield: multiplies enemy currency drops.
- Auto-Attack Unlock: adds passive attacks while player still clicks.
- Auto-Attack Speed: increases passive attack rate.
- Cursor Bonus Unlock: enables +1 currency from cursor pickup per enemy.
- Cursor Bonus Amount: increases that +1 bonus to +N.

### Train Characters (v2)
Characters are unlocked progressively and move as one train behind the lead knight.

- Knight (starting character):
- role: primary frontliner and baseline click-damage source
- active: `Vampirism` (short duration), healing hero HP based on knight damage dealt

- Archer (first unlocked teammate):
- role: sustained ranged damage before contact
- active: `Piercing Arrow` (short duration), increased archer damage and extended effective range

- Guardian (mid unlock teammate):
- role: survivability support, raises max HP and baseline armor
- active: `Fortify` (short duration), adds large temporary damage reduction

- Mage (later unlock teammate):
- role: backline damage and power economy support
- active: `Storm` (short duration), adds burst magic DPS against current target

### Captured Power System (v2)
- enemies drop deterministic power when killed
- captured power gain is modified by `Power Capture` upgrades
- power is capped by `Power Capacity`
- player can click hero portraits (Knight/Archer/Guardian/Mage) to spend power and trigger that hero active
- active duration is modified by `Active Duration` upgrades
- cooldowns on hero actives prevent spam while still using power immediately when available

Simulation policy used for validation:
- activations are deterministic and used as soon as possible when enough power exists
- each active has an explicit cooldown timer
- cooldowns/capacity are tuned so power does not sit capped with no available character target
- no random activation decisions

### Boss Survivability Layer
- bosses are intentionally much tougher than regular enemies:
- significantly higher HP multipliers
- significantly higher contact DPS multipliers
- add `Boss Armor` upgrade that only reduces incoming boss damage (does not reduce regular enemy damage)

### Initial Upgrade Cost Model (v1)
- Damage: `cost = 22 * 1.32^level`
- Range: `cost = 26 * 1.34^level`
- Armor: `cost = 30 * 1.36^level`
- Enemy Density Control: `cost = 28 * 1.34^level`
- Resource Yield: `cost = 24 * 1.35^level`
- Auto-Attack Unlock: one-time `68`
- Auto-Attack Speed: `cost = 48 * 1.45^level` (requires Auto-Attack Unlock)
- Cursor Bonus Unlock: one-time `54`
- Cursor Bonus Amount: `cost = 80 * 1.55^level` (requires Cursor Bonus Unlock)

Purchase policy for sim validation:
- buy exactly one upgrade after each run, using deterministic priority
- this lets us verify one-upgrade-per-run economy pacing cleanly

### Added Upgrade Groups (v2)
- Character unlocks:
- `unlock_archer`, `unlock_guardian`, `unlock_mage`

- Character progression:
- `archer_damage`, `archer_rate`
- `guardian_vitality`
- `mage_focus`

- Power/active progression:
- `power_capture`
- `power_capacity`
- `active_duration`
- Boss-specific mitigation:
- `boss_armor`

## Progression Rules
- A cycle = repeated runs on one level until boss is defeated.
- After boss defeat, unlock next level.
- Next level has significantly harder enemies and larger rewards.
- The same cycle repeats: fail forward, buy upgrades, clear boss, move on.

Balancing goal:
- each run should yield enough currency for at least one upgrade purchase
- each level cycle should feel like measurable forward progress in boss reach

## Simulation Design

### Purpose
Use deterministic simulation to validate pacing and economy before full gameplay tuning.

### Inputs
- Level definitions (enemy count, HP, contact DPS, DoT, rewards)
- Upgrade definitions (cost, scaling, caps, stat deltas)
- Player base stats (HP, move speed, click rate, base damage)
- Collection assumptions (60/30/10 split)
- Character train definitions (passive stats + active skill rules)
- Power economy definitions (power drops, costs, capacity, duration scaling)

### Outputs per Run
- time survived / clear time
- regular enemies killed
- boss reached and boss defeated flags
- total damage taken by source
- currency earned (cursor/hero/missed breakdown)
- active ability uses by character
- captured power remaining
- upgrades purchased after run

### Outputs per Level Cycle
- number of runs to beat boss
- total cycle time
- average run duration
- average currency per run
- average upgrades purchased per run

## Godot Integration Plan

### Data and Systems
- Add deterministic data resources for levels and upgrades in `Data/`.
- Add `SimulationManager.gd` singleton that can run offline cycles.
- Keep combat formulas in shared utility script used by both:
- runtime combat logic
- simulation logic

### Runtime Usage
- Real gameplay uses exact same formulas from shared module.
- Simulation mode executes the same formulas in a fixed-step data loop without scenes/physics.

### UI Tooling
Add a Simulation Panel scene with:
- start level
- max levels to test
- run-until-clear toggle
- output summary table
- export JSON/CSV

### Save Data
Extend `SaveHandler.gd` with:
- simulation benchmark presets
- last simulation report
- balance version tag

## Balance Acceptance Criteria
- Deterministic replay: same inputs always produce same outputs.
- Economy target: roughly one upgrade purchased per run on average in each cycle.
- Cycle target: boss kill time per level stays in a target band (for example 3 to 10 runs early, scaling upward slowly).
- Progression target: each new level initially difficult but solvable through repeat runs and upgrades.

## Implementation Sequence
1. Define deterministic formulas and data schemas.
2. Implement offline simulation runner.
3. Create initial level table and upgrade table.
4. Run benchmark and tune until one-upgrade-per-run target is met.
5. Integrate formulas into Godot gameplay scripts.
6. Add simulation UI/debug tools.
7. Lock v1 balance snapshot.

## Immediate Deliverables
- `incrementalplan.md` (this document)
- deterministic combat simulation script
- initial upgrade set and costs
- benchmark report showing:
- upgrades per run
- cycle durations
- boss clear progression by level

## Implemented First Validation Assets
- `simulation/deterministic_combat_sim.ps1`
- `simulation/deterministic_combat_sim.py` (legacy mirror script; PowerShell version is current validation source)
- `simulation/simulation_results.json`

## Latest Validation Snapshot (v2)
Using the deterministic train + power model:
- one upgrade purchased every run in benchmark (`upgrade_purchase_rate = 1.000`)
- all train unlocks reached in simulation (`unlock_archer`, `unlock_guardian`, `unlock_mage`)
- hero actives are used in-run with deterministic triggers (Knight, Archer, Guardian, Mage)
