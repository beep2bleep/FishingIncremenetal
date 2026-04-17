from __future__ import annotations

from dataclasses import dataclass, field

TOTAL_BLOCKS_PER_LAYER = 71_760
LAYER_HP = [18.0, 42.0, 92.0, 188.0]
LAYER_VALUE = [3.0, 9.0, 24.0, 68.0]
LAYER_NAMES = ["Topsoil", "Mid", "Deep", "Core"]

# This is a design-target simulation rather than a byte-for-byte copy of the
# live scene code. It models the pacing we want the mode to hit once the final
# tuning pass is done.
FRONTIER_BLOCKS = [5_000, 7_000, 32_000, 70_000]
FINAL_BOSS_EQUIVALENT_BLOCKS = 45_000

UPGRADE_ORDER = [
    "damage",
    "rate",
    "cargo",
    "layer",
    "targets",
    "move",
    "pickup",
    "value",
    "time",
    "drones",
    "crit",
    "explosion",
    "chain",
    "core",
]

BASE_COST = {
    "damage": 28,
    "rate": 34,
    "cargo": 30,
    "targets": 65,
    "move": 24,
    "pickup": 20,
    "value": 34,
    "time": 26,
    "drones": 90,
    "crit": 80,
    "explosion": 110,
    "chain": 125,
    "layer": 180,
    "core": 160,
}

COST_MULT = {
    "damage": 1.18,
    "rate": 1.18,
    "cargo": 1.17,
    "targets": 1.24,
    "move": 1.14,
    "pickup": 1.14,
    "value": 1.18,
    "time": 1.16,
    "drones": 1.26,
    "crit": 1.22,
    "explosion": 1.24,
    "chain": 1.24,
    "layer": 1.45,
    "core": 1.24,
}

MAX_LEVEL = {
    "damage": 18,
    "rate": 16,
    "cargo": 16,
    "targets": 8,
    "move": 12,
    "pickup": 12,
    "value": 12,
    "time": 12,
    "drones": 8,
    "crit": 10,
    "explosion": 8,
    "chain": 8,
    "layer": 3,
    "core": 10,
}

REQUIRES = {
    "rate": ("damage", 2),
    "targets": ("rate", 2),
    "drones": ("cargo", 4),
    "explosion": ("crit", 2),
    "chain": ("explosion", 1),
    "layer": ("cargo", 3),
    "core": ("layer", 2),
}


@dataclass
class SimState:
    upgrades: dict[str, int] = field(default_factory=lambda: {key: 0 for key in BASE_COST})
    cash: float = 0.0
    elapsed: float = 0.0
    current_layer: int = 1
    frontier_progress: list[float] = field(default_factory=lambda: [0.0, 0.0, 0.0, 0.0])
    milestones: dict[str, float] = field(default_factory=dict)
    runs: int = 0


def upgrade_cost(key: str, level: int) -> float:
    return BASE_COST[key] * (COST_MULT[key] ** level)


def can_buy(state: SimState, key: str) -> bool:
    if state.upgrades[key] >= MAX_LEVEL[key]:
        return False
    if key in REQUIRES:
        req_key, req_level = REQUIRES[key]
        if state.upgrades[req_key] < req_level:
            return False
    if key == "layer" and state.upgrades["layer"] >= state.current_layer:
        return False
    return state.cash >= upgrade_cost(key, state.upgrades[key])


def buy_one_upgrade(state: SimState) -> str | None:
    for key in UPGRADE_ORDER:
        if not can_buy(state, key):
            continue
        state.cash -= upgrade_cost(key, state.upgrades[key])
        state.upgrades[key] += 1
        return key
    return None


def get_damage(level: int) -> float:
    return 28.0 + 10.0 * level + 2.0 * (level**1.18)


def get_rate(level: int) -> float:
    return 1.1 + 0.12 * level


def get_targets(level: int) -> int:
    return 1 + level // 2


def get_cargo(level: int) -> int:
    return 40 + 12 * level + 16 * (level // 3)


def get_value_mult(level: int) -> float:
    return 1.0 + 0.12 * level


def get_run_time(level: int) -> float:
    return 30.0 + 2.5 * level


def get_frontier_efficiency(state: SimState) -> float:
    move_level = state.upgrades["move"]
    pickup_level = state.upgrades["pickup"]
    return 0.26 + 0.02 * move_level + 0.015 * pickup_level


def get_banked_fraction(state: SimState) -> float:
    return 0.55 + 0.02 * state.upgrades["pickup"]


def get_drone_count(level: int) -> int:
    return level


def get_power_multiplier(state: SimState) -> float:
    crit_level = state.upgrades["crit"]
    crit_bonus = min(0.4, 0.025 * crit_level) * (1.8 + 0.08 * crit_level - 1.0)
    explosion_bonus = 0.08 * state.upgrades["explosion"]
    chain_bonus = 0.06 * state.upgrades["chain"]
    drone_bonus = 0.12 * get_drone_count(state.upgrades["drones"])
    core_bonus = 0.18 * state.upgrades["core"] if state.current_layer == 4 else 0.0
    return (1.0 + crit_bonus) * (1.0 + explosion_bonus + chain_bonus) * (1.0 + drone_bonus) * (1.0 + core_bonus)


def run_once(state: SimState) -> None:
    state.runs += 1
    layer_index = state.current_layer - 1

    damage = get_damage(state.upgrades["damage"])
    rate = get_rate(state.upgrades["rate"])
    targets = get_targets(state.upgrades["targets"])
    run_time = get_run_time(state.upgrades["time"])
    cargo = get_cargo(state.upgrades["cargo"]) + 20 * get_drone_count(state.upgrades["drones"])

    raw_blocks = damage * rate * targets * get_power_multiplier(state) * run_time / LAYER_HP[layer_index]
    frontier_blocks = raw_blocks * get_frontier_efficiency(state)
    banked_blocks = min(raw_blocks * get_banked_fraction(state), cargo)

    state.frontier_progress[layer_index] += frontier_blocks
    state.cash += banked_blocks * LAYER_VALUE[layer_index] * get_value_mult(state.upgrades["value"])
    state.elapsed += run_time + 10.0

    buy_one_upgrade(state)

    while state.current_layer <= 4 and state.frontier_progress[state.current_layer - 1] >= FRONTIER_BLOCKS[state.current_layer - 1]:
        key = f"layer_{state.current_layer}_clear"
        state.milestones.setdefault(key, state.elapsed)
        if state.current_layer == 4:
            break
        if state.upgrades["layer"] < state.current_layer:
            return
        state.current_layer += 1
    if state.current_layer == 4 and state.frontier_progress[3] >= FRONTIER_BLOCKS[3] + FINAL_BOSS_EQUIVALENT_BLOCKS:
        state.milestones.setdefault("campaign_complete", state.elapsed)


def run_campaign() -> SimState:
    state = SimState()
    while "campaign_complete" not in state.milestones and state.elapsed < 6 * 60 * 60:
        run_once(state)
    return state


def fmt_minutes(seconds: float) -> str:
    return f"{seconds / 60.0:.1f}m"


def build_report(state: SimState) -> str:
    lines: list[str] = []
    lines.append("# Open Pit Empire Progression Simulation")
    lines.append("")
    lines.append("This is a design-target pacing model for Open Pit Empire.")
    lines.append("It assumes a huge persistent pit, but the campaign is paced around clearing a frontier path, hauling value back, and buying one meaningful upgrade per run.")
    lines.append("")
    lines.append("## Pit Scale")
    lines.append(f"- Total mineable blocks per layer in the live pit: {TOTAL_BLOCKS_PER_LAYER:,}")
    lines.append(f"- Total mineable blocks across 4 layers: {TOTAL_BLOCKS_PER_LAYER * 4:,}")
    lines.append("- Frontier objective blocks used for pacing:")
    for index, amount in enumerate(FRONTIER_BLOCKS):
        percent = 100.0 * float(amount) / float(TOTAL_BLOCKS_PER_LAYER)
        lines.append(f"  - {LAYER_NAMES[index]}: {amount:,} ({percent:.1f}% of that layer)")
    lines.append(f"  - Final boss equivalent: {FINAL_BOSS_EQUIVALENT_BLOCKS:,} extra core-damage work after reaching the core")
    lines.append("")
    lines.append("## Milestones")
    for key in ["layer_1_clear", "layer_2_clear", "layer_3_clear", "layer_4_clear", "campaign_complete"]:
        if key in state.milestones:
            lines.append(f"- `{key}`: {fmt_minutes(state.milestones[key])}")
    lines.append("")
    lines.append("## Upgrade Shape")
    lines.append("- Early game: damage, fire rate, cargo, and the first permit drive the 0-40 minute ramp.")
    lines.append("- Mid game: splitter targets, movement, pickup, and value upgrades sustain repeated Mid and Deep runs.")
    lines.append("- Late game: drones, crit/AOE, and core tuning carry the Core push without needing to excavate the full 287k+ block pit.")
    lines.append("")
    lines.append("## Result Snapshot")
    lines.append(f"- Runs: {state.runs}")
    lines.append(f"- Elapsed: {fmt_minutes(state.elapsed)}")
    lines.append("- Final upgrade levels:")
    for key in UPGRADE_ORDER:
        lines.append(f"  - {key}: {state.upgrades[key]}")
    return "\n".join(lines)


if __name__ == "__main__":
    result = run_campaign()
    print(build_report(result))
