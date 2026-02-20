from __future__ import annotations

from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple
import json
from pathlib import Path


@dataclass
class UpgradeDef:
    key: str
    base_cost: float
    growth: float = 1.0
    cap: Optional[int] = None
    one_time: bool = False
    requires: Optional[str] = None

    def cost_at(self, level: int) -> float:
        if self.one_time:
            return self.base_cost
        return self.base_cost * (self.growth ** level)


UPGRADES: Dict[str, UpgradeDef] = {
    "damage": UpgradeDef("damage", base_cost=22.0, growth=1.32, cap=30),
    "range": UpgradeDef("range", base_cost=26.0, growth=1.34, cap=20),
    "armor": UpgradeDef("armor", base_cost=30.0, growth=1.36, cap=18),
    "density": UpgradeDef("density", base_cost=28.0, growth=1.34, cap=10),
    "resource": UpgradeDef("resource", base_cost=24.0, growth=1.35, cap=24),
    "auto_unlock": UpgradeDef("auto_unlock", base_cost=68.0, one_time=True),
    "auto_rate": UpgradeDef("auto_rate", base_cost=48.0, growth=1.45, cap=16, requires="auto_unlock"),
    "cursor_unlock": UpgradeDef("cursor_unlock", base_cost=54.0, one_time=True),
    "cursor_bonus": UpgradeDef("cursor_bonus", base_cost=80.0, growth=1.55, cap=8, requires="cursor_unlock"),
}

PURCHASE_PRIORITY = [
    "auto_unlock",
    "cursor_unlock",
    "damage",
    "resource",
    "armor",
    "range",
    "auto_rate",
    "density",
    "cursor_bonus",
]


@dataclass
class SimState:
    currency: float = 0.0
    levels: Dict[str, int] = None

    def __post_init__(self):
        if self.levels is None:
            self.levels = {k: 0 for k in UPGRADES.keys()}


@dataclass
class RunResult:
    level: int
    run_index_in_cycle: int
    boss_defeated: bool
    enemies_killed: int
    reached_boss: bool
    time_seconds: float
    damage_taken_dot: float
    damage_taken_contact: float
    currency_cursor: float
    currency_hero: float
    currency_missed: float
    currency_earned: float
    upgrade_bought: Optional[str]
    upgrade_cost: float
    wallet_after: float


@dataclass
class CycleSummary:
    level: int
    runs_to_clear: int
    cycle_time_seconds: float
    avg_run_seconds: float
    avg_currency_per_run: float
    upgrades_bought: int
    upgrades_per_run: float


def level_params(level_idx: int) -> Dict[str, float]:
    lv = level_idx - 1
    return {
        "regular_count": 24 + 8 * lv,
        "enemy_hp": 45.0 * (1.60 ** lv),
        "enemy_contact_dps": 7.0 * (1.45 ** lv),
        "dot_dps": 2.2 * (1.33 ** lv),
        "enemy_drop": 10.0 * (1.50 ** lv),
        "boss_hp": (45.0 * (1.60 ** lv)) * (14.0 + 2.5 * level_idx),
        "boss_contact_dps": (7.0 * (1.45 ** lv)) * 2.8,
        "boss_drop": (10.0 * (1.50 ** lv)) * (50.0 + 5.0 * level_idx),
        "gap_regular": 3.2,
        "gap_boss": 4.8,
    }


def derived_stats(state: SimState) -> Dict[str, float]:
    damage = 8.0 + state.levels["damage"] * 2.2
    attack_rate_click = 4.5
    attack_rate_auto = 0.0
    if state.levels["auto_unlock"] > 0:
        attack_rate_auto = 1.5 + state.levels["auto_rate"] * 0.75

    rng = 0.5 + state.levels["range"] * 0.18
    armor = min(0.75, state.levels["armor"] * 0.035)
    move_speed = 2.4
    resource_mult = 1.0 + state.levels["resource"] * 0.12
    density_factor = max(0.55, 1.0 - state.levels["density"] * 0.05)
    cursor_bonus = 0.0
    if state.levels["cursor_unlock"] > 0:
        cursor_bonus = 1.0 + state.levels["cursor_bonus"] * 1.0

    return {
        "max_hp": 220.0,
        "damage": damage,
        "dps": damage * (attack_rate_click + attack_rate_auto),
        "range": rng,
        "armor": armor,
        "move_speed": move_speed,
        "resource_mult": resource_mult,
        "density_factor": density_factor,
        "cursor_bonus": cursor_bonus,
    }


def resolve_encounter(
    hp_left: float,
    dps: float,
    rng: float,
    move_speed: float,
    armor: float,
    dot_dps: float,
    contact_dps: float,
    enemy_hp: float,
    gap: float,
) -> Tuple[bool, float, float, float, float]:
    """
    Returns: (enemy_killed, hp_after, time_spent, dot_damage_taken, contact_damage_taken)
    """
    time_to_contact = gap / move_speed
    pre_contact_attack = min(time_to_contact, rng / move_speed)
    delay_before_attack = max(0.0, time_to_contact - pre_contact_attack)
    ttk = enemy_hp / max(1e-8, dps)

    damage_mult = 1.0 - armor

    phase1_t = delay_before_attack
    phase1_dot = phase1_t * dot_dps * damage_mult

    phase2_t = min(ttk, pre_contact_attack)
    phase2_dot = phase2_t * dot_dps * damage_mult

    phase3_t = max(0.0, ttk - pre_contact_attack)
    phase3_dot = phase3_t * dot_dps * damage_mult
    phase3_contact = phase3_t * contact_dps * damage_mult

    total_dot = phase1_dot + phase2_dot + phase3_dot
    total_contact = phase3_contact
    total_damage = total_dot + total_contact

    if total_damage < hp_left:
        return True, hp_left - total_damage, phase1_t + phase2_t + phase3_t, total_dot, total_contact

    # Determine death timing exactly by phases
    remaining = hp_left

    # Phase 1
    phase1_rate = dot_dps * damage_mult
    if phase1_rate > 0:
        t_to_die = remaining / phase1_rate
        if t_to_die <= phase1_t:
            return False, 0.0, t_to_die, t_to_die * phase1_rate, 0.0
        remaining -= phase1_t * phase1_rate

    # Phase 2
    phase2_rate = dot_dps * damage_mult
    if phase2_rate > 0:
        t_to_die = remaining / phase2_rate
        if t_to_die <= phase2_t:
            return False, 0.0, phase1_t + t_to_die, phase1_t * phase1_rate + t_to_die * phase2_rate, 0.0
        remaining -= phase2_t * phase2_rate

    # Phase 3
    phase3_rate = (dot_dps + contact_dps) * damage_mult
    if phase3_rate <= 0:
        return False, remaining, phase1_t + phase2_t + phase3_t, total_dot, total_contact

    t_to_die = remaining / phase3_rate
    if t_to_die <= phase3_t:
        return (
            False,
            0.0,
            phase1_t + phase2_t + t_to_die,
            phase1_t * phase1_rate + phase2_t * phase2_rate + t_to_die * dot_dps * damage_mult,
            t_to_die * contact_dps * damage_mult,
        )

    return False, 0.0, phase1_t + phase2_t + phase3_t, total_dot, total_contact


def run_single(level_idx: int, run_idx: int, state: SimState) -> RunResult:
    lp = level_params(level_idx)
    s = derived_stats(state)

    hp = s["max_hp"]
    time_spent = 0.0
    dot_taken = 0.0
    contact_taken = 0.0

    regular_count = max(8, int(round(lp["regular_count"] * s["density_factor"])))
    enemies_killed = 0

    cursor = 0.0
    hero = 0.0
    missed = 0.0

    for _ in range(regular_count):
        killed, hp, t, dot_dmg, con_dmg = resolve_encounter(
            hp,
            s["dps"],
            s["range"],
            s["move_speed"],
            s["armor"],
            lp["dot_dps"],
            lp["enemy_contact_dps"],
            lp["enemy_hp"],
            lp["gap_regular"],
        )

        time_spent += t
        dot_taken += dot_dmg
        contact_taken += con_dmg

        if not killed:
            break

        enemies_killed += 1
        drop = lp["enemy_drop"] * s["resource_mult"]
        cursor += 0.60 * drop + s["cursor_bonus"]
        hero += 0.30 * drop
        missed += 0.10 * drop

    reached_boss = enemies_killed == regular_count and hp > 0
    boss_defeated = False

    if reached_boss:
        killed, hp, t, dot_dmg, con_dmg = resolve_encounter(
            hp,
            s["dps"],
            s["range"],
            s["move_speed"],
            s["armor"],
            lp["dot_dps"],
            lp["boss_contact_dps"],
            lp["boss_hp"],
            lp["gap_boss"],
        )
        time_spent += t
        dot_taken += dot_dmg
        contact_taken += con_dmg

        if killed:
            boss_defeated = True
            drop = lp["boss_drop"] * s["resource_mult"]
            cursor += 0.60 * drop + s["cursor_bonus"]
            hero += 0.30 * drop
            missed += 0.10 * drop

    earned = cursor + hero
    state.currency += earned

    upgrade_key, upgrade_cost = buy_one_upgrade(state)

    return RunResult(
        level=level_idx,
        run_index_in_cycle=run_idx,
        boss_defeated=boss_defeated,
        enemies_killed=enemies_killed,
        reached_boss=reached_boss,
        time_seconds=time_spent,
        damage_taken_dot=dot_taken,
        damage_taken_contact=contact_taken,
        currency_cursor=cursor,
        currency_hero=hero,
        currency_missed=missed,
        currency_earned=earned,
        upgrade_bought=upgrade_key,
        upgrade_cost=upgrade_cost,
        wallet_after=state.currency,
    )


def buy_one_upgrade(state: SimState) -> Tuple[Optional[str], float]:
    for key in PURCHASE_PRIORITY:
        up = UPGRADES[key]
        lvl = state.levels[key]

        if up.one_time and lvl > 0:
            continue
        if up.cap is not None and lvl >= up.cap:
            continue
        if up.requires is not None and state.levels[up.requires] <= 0:
            continue

        cost = up.cost_at(lvl)
        if state.currency >= cost:
            state.currency -= cost
            state.levels[key] += 1
            return key, cost

    return None, 0.0


def run_progression(max_levels: int = 6, max_runs_per_level: int = 40) -> Tuple[List[RunResult], List[CycleSummary], SimState]:
    state = SimState()
    runs: List[RunResult] = []
    cycles: List[CycleSummary] = []

    for level_idx in range(1, max_levels + 1):
        cycle_runs: List[RunResult] = []
        cleared = False

        for r in range(1, max_runs_per_level + 1):
            res = run_single(level_idx, r, state)
            runs.append(res)
            cycle_runs.append(res)
            if res.boss_defeated:
                cleared = True
                break

        cycle_time = sum(x.time_seconds for x in cycle_runs)
        upgrades_bought = sum(1 for x in cycle_runs if x.upgrade_bought is not None)
        avg_currency = sum(x.currency_earned for x in cycle_runs) / len(cycle_runs)
        cycles.append(
            CycleSummary(
                level=level_idx,
                runs_to_clear=len(cycle_runs),
                cycle_time_seconds=cycle_time,
                avg_run_seconds=cycle_time / len(cycle_runs),
                avg_currency_per_run=avg_currency,
                upgrades_bought=upgrades_bought,
                upgrades_per_run=upgrades_bought / len(cycle_runs),
            )
        )

        if not cleared:
            break

    return runs, cycles, state


def fmt_time(seconds: float) -> str:
    m = int(seconds // 60)
    s = seconds - m * 60
    return f"{m:02d}:{s:04.1f}"


def main() -> None:
    runs, cycles, final_state = run_progression(max_levels=6, max_runs_per_level=50)

    print("Cycle Summary")
    print("level | runs_to_clear | upgrades/run | avg_currency/run | avg_run_time | cycle_time")
    for c in cycles:
        print(
            f"{c.level:>5} | {c.runs_to_clear:>13} | {c.upgrades_per_run:>12.2f} | "
            f"{c.avg_currency_per_run:>16.1f} | {fmt_time(c.avg_run_seconds):>12} | {fmt_time(c.cycle_time_seconds):>9}"
        )

    no_upgrade_runs = [r for r in runs if r.upgrade_bought is None]
    print("\nRun Validation")
    print(f"total_runs={len(runs)}")
    print(f"runs_without_upgrade={len(no_upgrade_runs)}")
    if runs:
        print(f"upgrade_purchase_rate={1.0 - (len(no_upgrade_runs) / len(runs)):.3f}")

    print("\nFinal Upgrade Levels")
    for key in PURCHASE_PRIORITY:
        print(f"{key}: {final_state.levels[key]}")

    out = {
        "cycle_summary": [asdict(c) for c in cycles],
        "runs": [asdict(r) for r in runs],
        "final_upgrade_levels": final_state.levels,
        "final_wallet": final_state.currency,
    }

    out_path = Path(__file__).resolve().parent / "simulation_results.json"
    out_path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
