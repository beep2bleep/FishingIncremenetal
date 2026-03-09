# DOT armor per level – analysis (game code only)

## Design goal

**Target:** For each level (depth), total DOT damage over that level should be **about 0.5% of the hero’s max HP**, assuming the player has invested in the **appropriate amount of DOT mitigation for that level**.

This document uses **only the live game code** (`FeedingABlackHoldGame/Fishing/BattleScene.gd`). Old simulation scripts are not used.

---

## How DOT is calculated in the game (BattleScene.gd)

### 1. DOT increases each level

**Yes. DOT DPS scales with battle level.**

In `_level_params(level_index)`:

```gdscript
var lv: int = level_index - 1
# ...
"dot_dps": 2.2 * pow(1.33, lv),
```

So:

- **dot_dps(level) = 2.2 × 1.33^(level − 1)**
- Level 1: 2.2  
- Level 2: 2.93  
- Level 3: 3.89  
- Level 5: 6.88  
- Level 10: ~24.5  

DOT DPS grows **exponentially** with level (base 1.33 per level).

### 2. Where DOT is applied (every frame)

From the same file, in the block that runs each frame (e.g. before spawn loop):

```gdscript
var lp: Dictionary = _level_params(current_level)
var armor_scale: float = _player_armor_scale()
if shield_time > 0.0:
    armor_scale *= 0.4
var dot_damage_per_second: float = float(lp["dot_dps"]) * _enemy_dot_mult() * armor_scale
dot_damage_per_second = max(0.0, dot_damage_per_second - _player_dot_damage_block())
_apply_player_damage(dot_damage_per_second * delta, ...)
```

So the **effective DOT per second** is:

1. **Base:** `dot_dps(level)` from level params (increases each level as above).
2. **Multipliers:** `_enemy_dot_mult()` (default 1.0 from `battle_mods["enemy_dot_mult"]`) and `armor_scale`.
3. **armor_scale** = `max(0.45, 1.0 - armor_bonus)`. So general armor reduces DOT multiplicatively, with a floor of 0.45.
4. **Flat block:** `_player_dot_damage_block()` is **subtracted** from the product above. So:
   - **Effective DOT DPS** = `max(0, dot_dps(level) × enemy_dot_mult × armor_scale − dot_flat_damage_reduction)`.

There is **no** percentage-based “dot resistance” in the game; DOT mitigation is:

- Multiplicative: `armor_scale` (general armor).
- Then flat subtraction: `dot_flat_damage_reduction`.

### 3. DOT armor (flat block) – core_armor_dot

DOT “armor” in the game is **flat damage blocked per second**, not a percentage.

From `_apply_upgrade_key_modifiers`:

- Keys: `core_armor_dot_1` … `core_armor_dot_5` (5 tracks).
- For each track at upgrade **level** (purchases in that track):
  - **Total block from that track** = `(3^(level + 1) − 3) / 2`.
- All tracks sum into `battle_mods["dot_flat_damage_reduction"]`.

Examples for **one track**:

- level 1: (9 − 3) / 2 = **3** flat block
- level 2: (27 − 3) / 2 = **12**
- level 3: (81 − 3) / 2 = **39**
- level 4: (243 − 3) / 2 = **120**
- level 5: (729 − 3) / 2 = **363**

So “appropriate dot armor per level” in this game means: **how much flat `dot_flat_damage_reduction` the player should have at each battle level** so that net DOT over that level ≈ 0.5% of max HP.

### 4. Max HP (for the 0.5% target)

```gdscript
func _max_health() -> float:
    var base: float = BASE_PLAYER_HEALTH + float(battle_mods.get("health_bonus_flat", 0.0))
    return base * float(battle_mods.get("health_mult", 1.0))
```

`BASE_PLAYER_HEALTH` = 100. So max_hp = (100 + health_bonus_flat) × health_mult.

---

## Target: 0.5% of max HP per level

We want **total DOT damage over the level** = 0.5% of max HP:

- **Total DOT** = ∫ (effective DOT DPS) dt over the level.

If we approximate effective DOT DPS as **constant** over the level (same level params and mods):

- **Total DOT** ≈ `effective_dot_dps × T_level`
- **Target:** `effective_dot_dps × T_level = 0.005 × max_hp`

So:

- **effective_dot_dps** = `0.005 × max_hp / T_level`

And in the game:

- **effective_dot_dps** = `max(0, dot_dps(level) × enemy_dot_mult × armor_scale − dot_flat_damage_reduction)`.

So for the target we need:

- `dot_dps(level) × enemy_dot_mult × armor_scale − dot_flat_damage_reduction = 0.005 × max_hp / T_level`
- **Required flat block (appropriate dot armor for that level):**
  - **dot_flat_damage_reduction(level)** = `dot_dps(level) × enemy_dot_mult × armor_scale − 0.005 × max_hp / T_level`

You can’t have negative block, so this only makes sense when:

- `dot_dps(level) × enemy_dot_mult × armor_scale ≥ 0.005 × max_hp / T_level`.

If the right-hand side is larger, then even with zero block, DOT would be **below** 0.5% of max_hp per level (short level or low dot_dps).

---

## “Appropriate” flat DOT block by level (example numbers)

Assume:

- **max_hp** = 100 (base).
- **enemy_dot_mult** = 1.0.
- **armor_scale** = 0.7 (e.g. 30% armor_bonus).
- **T_level** = total seconds the player spends in that level (in combat / with DOT ticking). This is build- and level-dependent; we use a simple reference: e.g. **T_level ≈ 120 + 60×level** (level 1 ≈ 180 s, level 5 ≈ 420 s, level 10 ≈ 720 s). Replace with real play data when available.

Then:

- **Raw DOT DPS (before block)** = dot_dps(level) × 1.0 × 0.7 = 0.7 × 2.2 × 1.33^(level−1).
- **Target effective DOT DPS** = 0.005 × 100 / T_level = 0.5 / T_level.
- **Required block** = raw_dot_dps − 0.5/T_level.

| Level | dot_dps(level) | Raw DOT DPS (×0.7) | T_level (ref) | Target eff. DPS | **Required flat block** |
|-------|----------------|--------------------|---------------|------------------|--------------------------|
| 1     | 2.20           | 1.54               | 180           | 0.00278          | **1.54**                 |
| 2     | 2.93           | 2.05               | 240           | 0.00208          | **2.05**                 |
| 3     | 3.89           | 2.72               | 300           | 0.00167          | **2.72**                 |
| 5     | 6.88           | 4.82               | 420           | 0.00119          | **4.82**                 |
| 10    | ~24.5          | ~17.2              | 720           | 0.00069          | **17.2**                 |

So with these assumptions, “appropriate dot armor” is roughly **equal to the raw DOT DPS** (after armor_scale), so that net DOT is tiny (0.5% of 100 HP over the whole level). That implies **high flat block** relative to dot_dps if you want to hit 0.5% per level.

- Level 1: block ≈ 1.54/s → one track at level 1 (3 block) is already above that; you’d overshoot (DOT would be 0 or near 0).
- Level 5: block ≈ 4.82/s → one track level 2 (12 total) would zero out DOT; one track level 1 (3) would leave net DOT DPS ≈ 1.82/s.

So “appropriate” depends heavily on **T_level** and how much of the level is actually spent with DOT active. If T_level is smaller (e.g. fast clears), target effective DPS is higher and required block is lower.

---

## Summary (game code only)

1. **DOT increases each level:**  
   `dot_dps(level) = 2.2 × 1.33^(level − 1)` in `_level_params()` in `BattleScene.gd`.

2. **DOT formula (every frame):**  
   - Effective DOT DPS = `max(0, dot_dps(level) × enemy_dot_mult × armor_scale − dot_flat_damage_reduction)`.
   - General armor only scales DOT (armor_scale, min 0.45). DOT-specific mitigation is **flat block** only.

3. **DOT armor in the game:**  
   - From `core_armor_dot_1` … `core_armor_dot_5`.  
   - Per track at `level` purchases: flat block = `(3^(level+1) − 3) / 2`.  
   - Sum of all tracks = `dot_flat_damage_reduction`.

4. **Target (0.5% max HP per level):**  
   - Required **flat block** for that level ≈  
     `dot_dps(level) × enemy_dot_mult × armor_scale − 0.005 × max_hp / T_level`.  
   - Depends on `T_level` (time in level). Tune or measure T_level, then use this to decide how much flat dot armor is “appropriate” per level (or per track/level of upgrades).

5. **No old simulations:**  
   This analysis uses only the game logic in `BattleScene.gd`; no simulation scripts.
