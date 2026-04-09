from __future__ import annotations

import argparse
import json
import math
import random
import re
from copy import deepcopy
from dataclasses import dataclass
from pathlib import Path
from statistics import mean


ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "FeedingABlackHoldGame" / "Games" / "RedSkyDefense" / "RedSkyData.gd"

CAMPAIGN_SEEDS = [11, 23, 47, 89, 131, 233]


def _extract_block(text: str, marker: str, open_char: str, close_char: str) -> str:
    start = text.index(marker)
    start = text.index(open_char, start + len(marker))
    depth = 0
    in_string = False
    escape = False
    for idx in range(start, len(text)):
        ch = text[idx]
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
            continue
        if ch == open_char:
            depth += 1
        elif ch == close_char:
            depth -= 1
            if depth == 0:
                return text[start : idx + 1]
    raise ValueError(f"Could not extract block for {marker}")


def _extract_array(text: str, const_name: str) -> str:
    marker = f"const {const_name}"
    start = text.index(marker)
    assign_idx = text.index("=", start + len(marker))
    array_start = text.index("[", assign_idx)
    return _extract_block(text[array_start:], "", "[", "]")


def _extract_dict(text: str, const_name: str) -> str:
    marker = f"const {const_name}"
    start = text.index(marker)
    assign_idx = text.index("=", start + len(marker))
    dict_start = text.index("{", assign_idx)
    return _extract_block(text[dict_start:], "", "{", "}")


def _split_top_level_dicts(array_text: str) -> list[str]:
    items: list[str] = []
    depth = 0
    start = -1
    in_string = False
    escape = False
    for idx, ch in enumerate(array_text):
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
            continue
        if ch == "{":
            if depth == 0:
                start = idx
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and start != -1:
                items.append(array_text[start : idx + 1])
                start = -1
    return items


def _find_number(text: str, key: str, default: float = 0.0) -> float:
    match = re.search(rf'"{re.escape(key)}":\s*(-?[0-9]+(?:\.[0-9]+)?)', text)
    return float(match.group(1)) if match else default


def _find_int(text: str, key: str, default: int = 0) -> int:
    return int(round(_find_number(text, key, default)))


def _find_string(text: str, key: str, default: str = "") -> str:
    match = re.search(rf'"{re.escape(key)}":\s*"([^"]*)"', text)
    return match.group(1) if match else default


def _find_bool(text: str, key: str, default: bool = False) -> bool:
    match = re.search(rf'"{re.escape(key)}":\s*(true|false)', text)
    if not match:
        return default
    return match.group(1) == "true"


def _find_array_strings(text: str, key: str) -> list[str]:
    match = re.search(rf'"{re.escape(key)}":\s*\[(.*?)\]', text, re.S)
    if not match:
        return []
    return re.findall(r'"([^"]+)"', match.group(1))


def _find_effects(text: str, kind: str) -> dict[str, float]:
    match = re.search(rf'"{kind}":\s*\{{(.*?)\}}', text, re.S)
    if not match:
        return {}
    body = match.group(1)
    return {
        key: float(value)
        for key, value in re.findall(r'"([^"]+)":\s*(-?[0-9]+(?:\.[0-9]+)?)', body)
    }


def load_red_sky_data() -> dict:
    text = DATA_PATH.read_text(encoding="utf-8")
    meta_cost_multiplier = float(re.search(r"META_COST_MULTIPLIER := ([0-9.]+)", text).group(1))
    meta_first_tier_discount = float(re.search(r"META_FIRST_TIER_DISCOUNT := ([0-9.]+)", text).group(1))
    max_step_m = re.search(r"DEMO_MAX_META_STEP_DEFAULT := (\d+)", text)
    demo_max_meta_step_default = int(max_step_m.group(1)) if max_step_m else 3
    tentacle_branch_m = re.search(r"DEMO_ALWAYS_LOCKED_META_BRANCH_TENTACLES := (\d+)", text)
    demo_always_locked_tentacle_branch = int(tentacle_branch_m.group(1)) if tentacle_branch_m else 6

    base_config_text = _extract_dict(text, "BASE_RUN_CONFIG")
    base_config = {
        key: (_find_bool(base_config_text, key) if val in ("true", "false") else float(val) if "." in val or key not in ["offer_roll_bonus", "level_up_choice_count"] else int(val))
        for key, val in re.findall(r'"([^"]+)":\s*([^,\n}]+)', base_config_text)
    }
    base_config["offer_roll_bonus"] = int(base_config.get("offer_roll_bonus", 0))
    base_config["level_up_choice_count"] = int(base_config.get("level_up_choice_count", 3))

    meta_upgrades = []
    for entry_text in _split_top_level_dicts(_extract_array(text, "META_UPGRADES")):
        meta_upgrades.append(
            {
                "id": _find_string(entry_text, "id"),
                "label": _find_string(entry_text, "label"),
                "summary": _find_string(entry_text, "summary"),
                "dependency": _find_string(entry_text, "dependency"),
                "branch": _find_int(entry_text, "branch", 0),
                "step": _find_int(entry_text, "step", 0),
                "base_cost": _find_int(entry_text, "base_cost"),
                "cost_scale": _find_number(entry_text, "cost_scale", 1.5),
                "max_tier": _find_int(entry_text, "max_tier", 5),
            }
        )

    wave_upgrades = []
    for entry_text in _split_top_level_dicts(_extract_array(text, "WAVE_UPGRADES")):
        wave_upgrades.append(
            {
                "id": _find_string(entry_text, "id"),
                "label": _find_string(entry_text, "label"),
                "summary": _find_string(entry_text, "summary"),
                "weight": _find_number(entry_text, "weight", 1.0),
                "rarity": _find_int(entry_text, "rarity", 0),
                "max_stacks": _find_int(entry_text, "max_stacks", 1),
                "min_wave": _find_int(entry_text, "min_wave", 1),
                "requires": _find_array_strings(entry_text, "requires"),
                "effects": {
                    "add": _find_effects(entry_text, "add"),
                    "mult": _find_effects(entry_text, "mult"),
                },
            }
        )

    demo_eligible_meta_node_count = _count_demo_eligible_meta_nodes_demo_slice(
        meta_upgrades, demo_max_meta_step_default, demo_always_locked_tentacle_branch
    )

    return {
        "meta_cost_multiplier": meta_cost_multiplier,
        "meta_first_tier_discount": meta_first_tier_discount,
        "demo_max_meta_step_default": demo_max_meta_step_default,
        "demo_always_locked_tentacle_branch": demo_always_locked_tentacle_branch,
        "demo_eligible_meta_node_count": demo_eligible_meta_node_count,
        "base_config": base_config,
        "meta_upgrades": meta_upgrades,
        "wave_upgrades": wave_upgrades,
    }


def _count_demo_eligible_meta_nodes_demo_slice(
    meta_upgrades: list[dict], max_step: int, tentacle_branch: int
) -> int:
    ms = max(1, int(max_step))
    tb = int(tentacle_branch)
    n = sum(
        1
        for u in meta_upgrades
        if int(u.get("branch", 0)) != tb and int(u.get("step", 0)) <= ms
    )
    return max(1, n)


def build_tier_costs(base_cost: int, cost_scale: float, max_tier: int, meta_cost_multiplier: float, first_tier_discount: float) -> list[int]:
    costs: list[int] = []
    running_cost = float(base_cost) * meta_cost_multiplier
    for tier in range(max_tier):
        if tier == 0:
            running_cost = float(base_cost) * meta_cost_multiplier
        else:
            running_cost *= cost_scale
        tier_cost = running_cost
        if tier == 0:
            tier_cost *= first_tier_discount
        costs.append(int(round(tier_cost)))
    return costs


def build_meta_bonuses(meta_levels: dict[str, int], base_config: dict) -> dict:
    bonuses = deepcopy(base_config)
    levels = deepcopy(meta_levels)

    tower_level = int(levels.get("tower_fabrication", 0))
    drone_level = int(levels.get("drone_hangar", 0))
    tentacle_level = int(levels.get("tentacle_vat", 0))
    signal_level = int(levels.get("signal_decoder", 0))
    magnet_level = int(levels.get("magnet_array", 0))
    pierce_level = int(levels.get("piercing_rifling", 0))
    blast_level = int(levels.get("blast_chambers", 0))
    reflector_level = int(levels.get("reflector_grid", 0))

    bonuses["unlock_towers"] = tower_level > 0
    bonuses["unlock_drones"] = drone_level > 0
    bonuses["unlock_tentacles"] = tentacle_level > 0
    bonuses["unlock_reflectors"] = reflector_level > 0
    bonuses["unlock_pierce"] = pierce_level > 0
    bonuses["unlock_blast"] = blast_level > 0
    bonuses["unlock_salvage"] = magnet_level > 0 or int(levels.get("salvage_bays", 0)) > 0
    bonuses["unlock_rare"] = signal_level > 0
    bonuses["rare_offer_unlocks"] = signal_level

    for key, level in levels.items():
        level = max(0, min(int(level), 99))
        if level <= 0:
            continue
        if key == "command_armor":
            bonuses["base_health"] += 18.0 * level
        elif key == "shield_array":
            bonuses["base_shield"] += 20.0 * level
        elif key == "shield_relay":
            bonuses["shield_regen"] += 3.8 * level
            bonuses["shield_regen_delay"] = max(0.8, float(bonuses.get("shield_regen_delay", 2.6)) - 0.18 * level)
        elif key == "emergency_bulkheads":
            bonuses["damage_reduction"] = min(0.35, float(bonuses.get("damage_reduction", 0.0)) + 0.035 * level)
        elif key == "repair_crews":
            bonuses["repair_between_waves"] += 12.0 * level
        elif key == "damage_uplink":
            bonuses["gun_damage"] += 1.45 * level
        elif key == "rapid_loader":
            bonuses["fire_interval"] /= 1.0 + 0.06 * level
        elif key == "tracking_array":
            bonuses["bullet_speed"] += 72.0 * level
        elif key == "capacitor_bank":
            bonuses["crit_chance"] += 0.03 * level
        elif key == "high_energy_cells":
            bonuses["crit_bonus"] += 0.18 * level
        elif key == "reserve_nukes":
            bonuses["starting_nukes"] += int((level + 1) / 2)
            bonuses["nuke_max"] += 1 + int(level / 2)
            bonuses["nuke_regen_per_wave"] += int(level / 3)
        elif key == "bigger_blasts":
            bonuses["nuke_radius"] *= 1.0 + 0.055 * level
        elif key == "fusion_payload":
            bonuses["nuke_damage"] *= 1.0 + 0.10 * level
        elif key == "piercing_rifling":
            bonuses["bullet_pierce"] += int(level / 3)
        elif key == "blast_chambers":
            bonuses["bullet_blast_damage"] *= 1.0 + 0.10 * level
        elif key == "tower_fabrication":
            bonuses["tower_count"] += int(level / 2)
        elif key == "tower_targeting":
            bonuses["tower_damage"] *= 1.0 + 0.16 * level
            bonuses["tower_range"] *= 1.0 + 0.05 * level
        elif key == "tower_cooling":
            bonuses["tower_fire_interval"] /= 1.0 + 0.09 * level
        elif key == "reflector_grid":
            bonuses["projectile_redirect_chance"] = min(0.7, float(bonuses.get("projectile_redirect_chance", 0.0)) + 0.045 * level)
        elif key == "signal_decoder":
            bonuses["offer_quality_bonus"] += 0.12 * level
        elif key == "drone_hangar":
            bonuses["drone_count"] += int(level / 2)
        elif key == "drone_ai":
            bonuses["drone_damage"] *= 1.0 + 0.16 * level
        elif key == "drone_flight_pack":
            bonuses["drone_fire_interval"] /= 1.0 + 0.08 * level
            bonuses["drone_speed"] *= 1.0 + 0.08 * level
        elif key == "magnet_array":
            bonuses["pickup_radius"] += 22.0 * level
        elif key == "salvage_bays":
            bonuses["salvage_multiplier"] *= 1.0 + 0.08 * level
        elif key == "scrap_ledgers":
            bonuses["meta_reward_multiplier"] *= 1.0 + 0.09 * level
        elif key == "contract_bounties":
            bonuses["wave_scrap_bonus"] += 4.5 * level
        elif key == "recovery_barges":
            bonuses["wave_auto_bank_ratio"] = min(0.96, float(bonuses.get("wave_auto_bank_ratio", 0.68)) + 0.04 * level)
            bonuses["salvage_lifetime"] += 0.7 * level
        elif key == "salvage_markets":
            bonuses["salvage_multiplier"] *= 1.0 + 0.06 * level
        elif key == "sweep_drones":
            bonuses["pickup_radius"] += 18.0 * level
            bonuses["wave_auto_bank_ratio"] = min(0.98, float(bonuses.get("wave_auto_bank_ratio", 0.68)) + 0.02 * level)
        elif key == "profit_directive":
            bonuses["meta_reward_multiplier"] *= 1.0 + 0.06 * level
            bonuses["wave_scrap_bonus"] += 3.0 * level
        elif key == "threat_analysis":
            bonuses["enemy_count_scale"] *= 0.95 ** level
        elif key == "gravitic_dragnet":
            bonuses["enemy_speed_scale"] *= 0.955 ** level
        elif key == "signal_jammers":
            bonuses["enemy_projectile_speed_scale"] *= 0.95 ** level
            bonuses["enemy_projectile_damage_scale"] *= 0.955 ** level
        elif key == "hunter_killer_doctrine":
            bonuses["heavy_enemy_health_scale"] *= 0.91 ** level
            bonuses["elite_spawn_scale"] *= 0.96 ** level
        elif key == "apex_countermeasures":
            bonuses["apex_enemy_health_scale"] *= 0.88 ** level
            bonuses["apex_enemy_damage_scale"] *= 0.93 ** level
        elif key == "tentacle_vat":
            bonuses["tentacle_count"] += int(level / 2)
        elif key == "tentacle_spines":
            bonuses["tentacle_damage"] *= 1.0 + 0.18 * level
        elif key == "tentacle_reach":
            bonuses["tentacle_range"] *= 1.0 + 0.12 * level
            bonuses["tentacle_slow"] += 0.03 * level
        elif key == "engineer_crew":
            bonuses["offer_roll_bonus"] += level
        elif key == "tactical_briefing":
            bonuses["level_up_choice_count"] = min(6, int(bonuses.get("level_up_choice_count", 3)) + level)
        elif key == "overclock_protocol":
            bonuses["upgrade_power_multiplier"] *= 1.0 + 0.08 * level

    bonuses["nuke_max"] = max(int(bonuses.get("nuke_max", 5)), int(bonuses.get("starting_nukes", 1)))
    return bonuses


def should_ignore_power_scaling_for_add(key: str) -> bool:
    return key in {"nukes", "nuke_max", "nuke_regen_per_wave", "bullet_pierce", "tower_count", "drone_count", "tentacle_count", "level_up_choice_count"}


def should_ignore_power_scaling_for_mult(key: str) -> bool:
    return key == "upgrade_power_multiplier"


def round_up_effect_amount(value: float) -> int:
    if value <= 0.0:
        return int(round(value))
    return max(1, int(math.ceil(value - 0.0001)))


def scaled_wave_effects(upgrade: dict, upgrade_power_multiplier: float, offer_tier_multiplier: float = 1.0) -> dict:
    scaled = {"add": {}, "mult": {}}
    for key, base_value in upgrade["effects"]["add"].items():
        value = float(base_value) * offer_tier_multiplier
        if not should_ignore_power_scaling_for_add(key):
            value *= upgrade_power_multiplier
        if key in {"nukes", "nuke_max", "nuke_regen_per_wave", "bullet_pierce", "tower_count", "drone_count", "tentacle_count"}:
            value = float(round_up_effect_amount(value))
        scaled["add"][key] = value
    for key, base_mult in upgrade["effects"]["mult"].items():
        if should_ignore_power_scaling_for_mult(key):
            scaled["mult"][key] = 1.0 + (float(base_mult) - 1.0) * offer_tier_multiplier
        else:
            scaled["mult"][key] = 1.0 + (float(base_mult) - 1.0) * offer_tier_multiplier * upgrade_power_multiplier
    return scaled


def can_offer_wave_upgrade(upgrade: dict, current_wave: int, wave_upgrades: dict, meta_bonuses: dict, runtime_flags: dict) -> bool:
    if int(wave_upgrades.get(upgrade["id"], 0)) >= int(upgrade["max_stacks"]):
        return False
    if current_wave < int(upgrade.get("min_wave", 1)):
        return False
    for req in upgrade.get("requires", []):
        if req == "shield" and float(runtime_flags.get("shield_max", meta_bonuses.get("base_shield", 0.0))) <= 0.0:
            return False
        if req == "tower" and not bool(meta_bonuses.get("unlock_towers", False)):
            return False
        if req == "drone" and not bool(meta_bonuses.get("unlock_drones", False)):
            return False
        if req == "tentacle" and not bool(meta_bonuses.get("unlock_tentacles", False)):
            return False
        if req == "reflector" and not bool(meta_bonuses.get("unlock_reflectors", False)):
            return False
        if req == "pierce" and not bool(meta_bonuses.get("unlock_pierce", False)):
            return False
        if req == "blast" and not bool(meta_bonuses.get("unlock_blast", False)):
            return False
        if req == "salvage" and not bool(meta_bonuses.get("unlock_salvage", False)):
            return False
        if req == "rare" and not bool(meta_bonuses.get("unlock_rare", False)):
            return False
    return True


def get_offer_weight(upgrade: dict, wave_upgrades: dict, meta_bonuses: dict) -> float:
    weight = float(upgrade.get("weight", 1.0))
    rarity = int(upgrade.get("rarity", 0))
    stacks = int(wave_upgrades.get(upgrade["id"], 0))
    weight *= 1.0 / (1.0 + stacks * 0.18)
    weight *= 1.0 + float(meta_bonuses.get("offer_quality_bonus", 0.0)) * (rarity + 1) * 0.4
    if stacks == 0:
        weight *= 1.0 + float(meta_bonuses.get("offer_roll_bonus", 0)) * 0.04
    return max(weight, 0.01)


@dataclass
class Targets:
    demo_minutes: float
    full_minutes: float
    demo_node_target: int
    practical_max_tier: int
    full_tier_target: int


class RedSkyBalanceSim:
    def __init__(self, data: dict, meta_cost_multiplier: float | None = None, first_tier_discount: float | None = None, targets: Targets | None = None):
        self.data = data
        self.base_config = data["base_config"]
        self.meta_cost_multiplier = meta_cost_multiplier if meta_cost_multiplier is not None else data["meta_cost_multiplier"]
        self.first_tier_discount = first_tier_discount if first_tier_discount is not None else data["meta_first_tier_discount"]
        node_count = len(data["meta_upgrades"])
        default_targets = Targets(
            demo_minutes=40.0,
            full_minutes=120.0,
            demo_node_target=int(data.get("demo_eligible_meta_node_count", node_count)),
            practical_max_tier=3,
            full_tier_target=node_count * 3,
        )
        self.targets = targets or default_targets
        self.meta_upgrades = deepcopy(data["meta_upgrades"])
        for entry in self.meta_upgrades:
            entry["tier_costs"] = build_tier_costs(
                entry["base_cost"],
                entry["cost_scale"],
                entry["max_tier"],
                self.meta_cost_multiplier,
                self.first_tier_discount,
            )
        self.wave_upgrades = deepcopy(data["wave_upgrades"])

    def run_report(self, pass_name: str) -> dict:
        campaigns = [self.simulate_campaign(seed) for seed in CAMPAIGN_SEEDS]
        avg_demo = self._avg(campaigns, "minutes_to_demo_nodes")
        avg_full = self._avg(campaigns, "minutes_to_full_tiers")
        avg_nodes = self._avg(campaigns, "minutes_to_full_nodes")
        return {
            "pass": pass_name,
            "meta_cost_multiplier": round(self.meta_cost_multiplier, 4),
            "meta_first_tier_discount": round(self.first_tier_discount, 4),
            "meta_node_count": len(self.meta_upgrades),
            "wave_upgrade_count": len(self.wave_upgrades),
            "demo_target_minutes": self.targets.demo_minutes,
            "full_target_minutes": self.targets.full_minutes,
            "demo_node_target": self.targets.demo_node_target,
            "practical_max_tier": self.targets.practical_max_tier,
            "full_tier_target": self.targets.full_tier_target,
            "avg_minutes_to_demo_nodes": round(avg_demo, 1),
            "avg_minutes_to_full_nodes": round(avg_nodes, 1),
            "avg_minutes_to_full_tiers": round(avg_full, 1),
            "avg_run_minutes": round(self._avg(campaigns, "average_run_minutes"), 1),
            "avg_run_waves": round(self._avg(campaigns, "average_waves"), 1),
            "avg_run_score": round(self._avg(campaigns, "average_score"), 1),
            "avg_run_wallet_gain": round(self._avg(campaigns, "average_wallet_gain"), 1),
            "assessment": self._assess(avg_demo, avg_full),
            "campaigns": campaigns,
        }

    def simulate_campaign(self, seed: int) -> dict:
        rng = random.Random(seed)
        meta_levels: dict[str, int] = {}
        wallet = 0
        total_minutes = 0.0
        minutes_to_demo = -1.0
        minutes_to_full_nodes = -1.0
        minutes_to_full_tiers = -1.0
        runs = []
        run_history = []
        for run_index in range(32):
            run_seed = rng.randrange(1 << 30)
            run_result = self.simulate_run(meta_levels, run_seed)
            runs.append(run_result)
            wallet += int(run_result["wallet_gain"])
            total_minutes += float(run_result["minutes"])
            wallet, purchases = self.purchase_meta_upgrades(meta_levels, wallet)
            run_history.append(
                {
                    "run": run_index + 1,
                    "seed": run_seed,
                    "waves_cleared": run_result["waves_cleared"],
                    "minutes": round(run_result["minutes"], 2),
                    "score": run_result["score"],
                    "wallet_gain": run_result["wallet_gain"],
                    "offers_taken": run_result["offers_taken"],
                    "meta_buys_after_run": purchases,
                    "ending_wallet": wallet,
                }
            )
            unique_nodes = self.count_unique_nodes(meta_levels)
            total_tiers = self.count_total_tiers(meta_levels)
            if minutes_to_demo < 0.0 and unique_nodes >= self.targets.demo_node_target:
                minutes_to_demo = total_minutes
            if minutes_to_full_nodes < 0.0 and unique_nodes >= len(self.meta_upgrades):
                minutes_to_full_nodes = total_minutes
            if minutes_to_full_tiers < 0.0 and total_tiers >= self.targets.full_tier_target:
                minutes_to_full_tiers = total_minutes
            if unique_nodes >= len(self.meta_upgrades) and total_tiers >= self.targets.full_tier_target:
                break
        return {
            "seed": seed,
            "minutes_to_demo_nodes": round(minutes_to_demo, 1) if minutes_to_demo >= 0 else -1.0,
            "minutes_to_full_nodes": round(minutes_to_full_nodes, 1) if minutes_to_full_nodes >= 0 else -1.0,
            "minutes_to_full_tiers": round(minutes_to_full_tiers, 1) if minutes_to_full_tiers >= 0 else -1.0,
            "average_run_minutes": self._avg(runs, "minutes"),
            "average_waves": self._avg(runs, "waves_cleared"),
            "average_score": self._avg(runs, "score"),
            "average_wallet_gain": self._avg(runs, "wallet_gain"),
            "ending_wallet": wallet,
            "ending_nodes": self.count_unique_nodes(meta_levels),
            "ending_tiers": self.count_total_tiers(meta_levels),
            "ending_meta_levels": deepcopy(meta_levels),
            "run_history": run_history,
        }

    def simulate_run(self, meta_levels: dict[str, int], seed: int) -> dict:
        rng = random.Random(seed)
        state = self.build_run_state(meta_levels)
        waves_cleared = 0
        minutes = 0.0
        score = 0.0
        offers_taken = []
        for wave in range(1, 80):
            wave_result = self.resolve_wave(state, wave, rng)
            minutes += wave_result["minutes"]
            if not wave_result["cleared"]:
                break
            waves_cleared = wave
            score += wave_result["score"]
            state["remaining_nukes"] = min(int(state["remaining_nukes"]) + max(int(state["nuke_regen_per_wave"]), 1), int(state["nuke_max"]))
            state["hull"] = min(float(state["base_max_health"]), float(state["hull"]) + float(state["repair_between_waves"]))
            state["shield"] = min(float(state["shield_max"]), float(state["shield"]) + float(state["shield_regen"]) * 2.2)
            offers = self.roll_wave_offers(state, wave, rng)
            if offers:
                chosen_offer = self.choose_best_wave_offer(state, offers, wave)
                self.apply_wave_upgrade_to_state(state, chosen_offer)
                offers_taken.append({"wave": wave, "picked": chosen_offer, "from": offers})
        wallet_gain = int(round(score * max(float(state["meta_reward_multiplier"]), 1.0)))
        return {
            "waves_cleared": waves_cleared,
            "minutes": minutes,
            "score": int(round(score)),
            "wallet_gain": wallet_gain,
            "offers_taken": offers_taken,
        }

    def resolve_wave(self, state: dict, wave: int, rng: random.Random) -> dict:
        offense = self.calc_offense(state)
        defense = self.calc_defense(state)
        economy = self.calc_economy(state)
        control = self.calc_control(state, wave)
        elite_bonus = 1.0 + (0.045 if wave >= 4 else 0.0) + (0.08 if wave >= 6 else 0.0) + (0.14 if wave >= 8 else 0.0) + (0.18 if wave >= 11 else 0.0) + (0.26 if wave >= 14 else 0.0)
        threat = (48.0 + 11.0 * wave + math.pow(float(wave), 1.34) * 7.2) * elite_bonus * control
        efficiency = max(0.58, min(offense / max(threat * 0.82, 1.0), 1.26))
        nuke_burst = 0.0
        if int(state["remaining_nukes"]) > 0 and offense < threat * 1.03:
            state["remaining_nukes"] = int(state["remaining_nukes"]) - 1
            nuke_burst = float(state["nuke_damage"]) * (float(state["nuke_radius"]) / 250.0) * 0.32
            efficiency = max(0.68, min((offense + nuke_burst) / max(threat * 0.82, 1.0), 1.3))

        incoming_damage = max(0.0, threat * 0.19 - defense * 0.098 - offense * 0.031)
        shield = float(state["shield"])
        if shield > 0.0:
            absorbed = min(shield, incoming_damage)
            state["shield"] = shield - absorbed
            incoming_damage -= absorbed
        hull_loss = incoming_damage * (1.0 - float(state["damage_reduction"]))
        state["hull"] = float(state["hull"]) - hull_loss

        score_gain = (18.0 + 6.5 * wave + math.pow(float(wave), 1.22) * 4.8) * economy * efficiency
        score_gain += float(state["wave_scrap_bonus"]) * wave
        wave_time_seconds = 20.0 + wave * 3.2 + math.pow(float(wave), 1.05) * 1.7
        wave_time_seconds -= max(0.0, wave - 8) * 1.6
        wave_time_seconds *= max(0.84, min(control ** 0.18, 1.12))
        minutes = max(0.28, wave_time_seconds / 60.0) * rng.uniform(0.94, 1.06)
        cleared = float(state["hull"]) > 0.0 and (offense + nuke_burst) >= threat * 0.745
        return {"cleared": cleared, "score": score_gain, "minutes": minutes}

    def roll_wave_offers(self, state: dict, wave: int, rng: random.Random) -> list[str]:
        candidates = []
        runtime_flags = {"shield_max": state.get("shield_max", 0.0)}
        choice_count = max(3, min(int(state.get("level_up_choice_count", 3)), 6))
        for upgrade in self.wave_upgrades:
            if can_offer_wave_upgrade(upgrade, wave, state["wave_upgrades"], state["meta_bonuses"], runtime_flags):
                candidates.append(upgrade)
        offers: list[str] = []
        while len(offers) < choice_count and len(offers) < len(candidates):
            chosen = self.pick_weighted_offer(candidates, offers, state["wave_upgrades"], state["meta_bonuses"], rng)
            if not chosen:
                break
            offers.append(chosen)
        return offers

    def pick_weighted_offer(self, candidates: list[dict], chosen: list[str], wave_upgrades: dict, meta_bonuses: dict, rng: random.Random) -> str:
        weighted = []
        total = 0.0
        for entry in candidates:
            if entry["id"] in chosen:
                continue
            weight = get_offer_weight(entry, wave_upgrades, meta_bonuses)
            weighted.append((entry["id"], weight))
            total += weight
        if total <= 0.0:
            return ""
        roll = rng.random() * total
        for upgrade_id, weight in weighted:
            roll -= weight
            if roll <= 0.0:
                return upgrade_id
        return weighted[-1][0]

    def choose_best_wave_offer(self, state: dict, offers: list[str], wave: int) -> str:
        baseline = self.score_run_state(state, wave + 1)
        best_offer = offers[0]
        best_value = -10**9
        for offer_id in offers:
            trial = deepcopy(state)
            self.apply_wave_upgrade_to_state(trial, offer_id)
            future_value = 0.0
            for lookahead_wave in range(wave + 1, min(wave + 4, 21)):
                future_value += self.score_run_state(trial, lookahead_wave)
            hull_pressure_bonus = 0.0
            hull_ratio = float(state["hull"]) / max(float(state["base_max_health"]), 1.0)
            if hull_ratio < 0.55:
                hull_pressure_bonus = self.calc_defense(trial) - self.calc_defense(state)
            score = future_value - baseline + hull_pressure_bonus * 0.6
            if score > best_value:
                best_value = score
                best_offer = offer_id
        return best_offer

    def apply_wave_upgrade_to_state(self, state: dict, upgrade_id: str) -> None:
        upgrade = next(item for item in self.wave_upgrades if item["id"] == upgrade_id)
        state["wave_upgrades"][upgrade_id] = int(state["wave_upgrades"].get(upgrade_id, 0)) + 1
        bundle = scaled_wave_effects(upgrade, float(state["upgrade_power_multiplier"]), 1.0)
        self.apply_effect_bundle_to_state(state, bundle)

    def apply_effect_bundle_to_state(self, state: dict, bundle: dict) -> None:
        for key, value in bundle["add"].items():
            if key == "base_max_health":
                state["base_max_health"] += value
                state["hull"] += value
            elif key == "repair":
                state["hull"] = min(float(state["base_max_health"]), float(state["hull"]) + value)
            elif key == "shield_max":
                state["shield_max"] += value
                state["shield"] += value
            elif key == "shield_fill":
                state["shield"] = min(float(state["shield_max"]), float(state["shield"]) + value)
            elif key == "nukes":
                state["remaining_nukes"] = min(int(state["nuke_max"]), int(state["remaining_nukes"]) + int(round(value)))
            elif key == "nuke_max":
                state["nuke_max"] = int(state["nuke_max"]) + int(round(value))
                state["remaining_nukes"] = min(int(state["remaining_nukes"]), int(state["nuke_max"]))
            elif key == "nuke_regen_per_wave":
                state["nuke_regen_per_wave"] = max(1, int(state["nuke_regen_per_wave"]) + int(round(value)))
            elif key in {"bullet_pierce", "tower_count", "drone_count", "tentacle_count", "level_up_choice_count"}:
                state[key] = int(state.get(key, 0)) + int(round(value))
            else:
                state[key] = float(state.get(key, 0.0)) + value
        for key, value in bundle["mult"].items():
            if key == "fire_rate":
                state["fire_interval"] /= value
            elif key == "tower_fire_rate":
                state["tower_fire_interval"] /= value
            elif key == "drone_fire_rate":
                state["drone_fire_interval"] /= value
            else:
                state[key] = float(state.get(key, 1.0)) * value
        state["remaining_nukes"] = min(int(state["remaining_nukes"]), int(state["nuke_max"]))

    def purchase_meta_upgrades(self, meta_levels: dict[str, int], wallet: int) -> tuple[int, list[dict]]:
        purchases = []
        while True:
            purchase = self.pick_best_meta_purchase(meta_levels, wallet)
            if not purchase:
                return wallet, purchases
            upgrade_id = purchase["id"]
            cost = purchase["cost"]
            wallet -= cost
            meta_levels[upgrade_id] = int(meta_levels.get(upgrade_id, 0)) + 1
            purchases.append(purchase)

    def pick_best_meta_purchase(self, meta_levels: dict[str, int], wallet: int) -> dict | None:
        base_state = self.build_run_state(meta_levels)
        base_score = self.score_run_state(base_state, 6) + self.score_run_state(base_state, 12) * 0.7
        best_purchase = None
        best_value = -10**9
        for entry in self.meta_upgrades:
            current_level = int(meta_levels.get(entry["id"], 0))
            if current_level >= entry["max_tier"]:
                continue
            if entry["dependency"] and int(meta_levels.get(entry["dependency"], 0)) <= 0:
                continue
            cost = entry["tier_costs"][current_level]
            if cost > wallet:
                continue
            trial_levels = deepcopy(meta_levels)
            trial_levels[entry["id"]] = current_level + 1
            trial_state = self.build_run_state(trial_levels)
            new_score = self.score_run_state(trial_state, 6) + self.score_run_state(trial_state, 12) * 0.7
            gain = new_score - base_score
            if current_level == 0:
                gain *= 1.4
            if current_level >= self.targets.practical_max_tier:
                gain *= 0.52
            elif current_level >= self.targets.practical_max_tier - 1:
                gain *= 0.76
            value = gain / max(float(cost), 1.0)
            if value > best_value:
                best_value = value
                best_purchase = {
                    "id": entry["id"],
                    "label": entry["label"],
                    "new_level": current_level + 1,
                    "cost": cost,
                    "value_score": round(value, 5),
                }
        return best_purchase

    def build_run_state(self, meta_levels: dict[str, int]) -> dict:
        bonuses = build_meta_bonuses(meta_levels, self.base_config)
        return {
            "meta_bonuses": bonuses,
            "wave_upgrades": {},
            "base_max_health": float(bonuses.get("base_health", 0.0)),
            "hull": float(bonuses.get("base_health", 0.0)),
            "shield_max": float(bonuses.get("base_shield", 0.0)),
            "shield": float(bonuses.get("base_shield", 0.0)),
            "shield_regen": float(bonuses.get("shield_regen", 0.0)),
            "damage_reduction": float(bonuses.get("damage_reduction", 0.0)),
            "repair_between_waves": float(bonuses.get("repair_between_waves", 0.0)),
            "gun_damage": float(bonuses.get("gun_damage", 0.0)),
            "fire_interval": float(bonuses.get("fire_interval", 0.17)),
            "crit_chance": float(bonuses.get("crit_chance", 0.0)),
            "crit_bonus": float(bonuses.get("crit_bonus", 1.65)),
            "bullet_pierce": int(bonuses.get("bullet_pierce", 0)),
            "bullet_blast_radius": float(bonuses.get("bullet_blast_radius", 0.0)),
            "bullet_blast_damage": float(bonuses.get("bullet_blast_damage", 1.0)),
            "bullet_speed": float(bonuses.get("bullet_speed", 930.0)),
            "nuke_damage": float(bonuses.get("nuke_damage", 0.0)),
            "nuke_radius": float(bonuses.get("nuke_radius", 0.0)),
            "nuke_max": int(bonuses.get("nuke_max", 5)),
            "nuke_regen_per_wave": max(int(bonuses.get("nuke_regen_per_wave", 1)), 1),
            "remaining_nukes": max(0, min(int(bonuses.get("starting_nukes", 1)), int(bonuses.get("nuke_max", 5)))),
            "tower_count": int(bonuses.get("tower_count", 0)),
            "tower_damage": float(bonuses.get("tower_damage", 0.0)),
            "tower_fire_interval": float(bonuses.get("tower_fire_interval", 1.0)),
            "tower_range": float(bonuses.get("tower_range", 0.0)),
            "drone_count": int(bonuses.get("drone_count", 0)),
            "drone_damage": float(bonuses.get("drone_damage", 0.0)),
            "drone_fire_interval": float(bonuses.get("drone_fire_interval", 1.0)),
            "drone_speed": float(bonuses.get("drone_speed", 0.0)),
            "drone_range": float(bonuses.get("drone_range", 0.0)),
            "tentacle_count": int(bonuses.get("tentacle_count", 0)),
            "tentacle_damage": float(bonuses.get("tentacle_damage", 0.0)),
            "tentacle_range": float(bonuses.get("tentacle_range", 0.0)),
            "tentacle_cooldown": float(bonuses.get("tentacle_cooldown", 1.05)),
            "tentacle_slow": float(bonuses.get("tentacle_slow", 0.0)),
            "projectile_redirect_chance": float(bonuses.get("projectile_redirect_chance", 0.0)),
            "pickup_radius": float(bonuses.get("pickup_radius", 0.0)),
            "salvage_multiplier": float(bonuses.get("salvage_multiplier", 1.0)),
            "salvage_lifetime": float(bonuses.get("salvage_lifetime", 7.4)),
            "meta_reward_multiplier": float(bonuses.get("meta_reward_multiplier", 1.0)),
            "wave_scrap_bonus": float(bonuses.get("wave_scrap_bonus", 0.0)),
            "wave_auto_bank_ratio": float(bonuses.get("wave_auto_bank_ratio", 0.68)),
            "level_up_choice_count": int(bonuses.get("level_up_choice_count", 3)),
            "upgrade_power_multiplier": float(bonuses.get("upgrade_power_multiplier", 1.0)),
            "enemy_count_scale": float(bonuses.get("enemy_count_scale", 1.0)),
            "enemy_speed_scale": float(bonuses.get("enemy_speed_scale", 1.0)),
            "enemy_projectile_speed_scale": float(bonuses.get("enemy_projectile_speed_scale", 1.0)),
            "enemy_projectile_damage_scale": float(bonuses.get("enemy_projectile_damage_scale", 1.0)),
            "elite_spawn_scale": float(bonuses.get("elite_spawn_scale", 1.0)),
            "heavy_enemy_health_scale": float(bonuses.get("heavy_enemy_health_scale", 1.0)),
            "heavy_enemy_damage_scale": float(bonuses.get("heavy_enemy_damage_scale", 1.0)),
            "apex_enemy_health_scale": float(bonuses.get("apex_enemy_health_scale", 1.0)),
            "apex_enemy_damage_scale": float(bonuses.get("apex_enemy_damage_scale", 1.0)),
        }

    def score_run_state(self, state: dict, wave: int) -> float:
        return self.calc_offense(state) * 1.15 + self.calc_defense(state) * 0.95 + self.calc_economy(state) * 42.0 + self.calc_control(state, wave) * 28.0 - wave * 8.5

    def calc_offense(self, state: dict) -> float:
        gun_dps = float(state["gun_damage"]) * (1.0 + float(state["crit_chance"]) * (float(state["crit_bonus"]) - 1.0)) / max(float(state["fire_interval"]), 0.04)
        gun_dps *= 1.0 + float(state["bullet_pierce"]) * 0.22
        gun_dps *= 1.0 + float(state["bullet_blast_radius"]) / 120.0 * 0.22 * float(state["bullet_blast_damage"])
        gun_dps *= 1.0 + max(float(state["bullet_speed"]) - 930.0, 0.0) / 1600.0
        tower_dps = float(state["tower_count"]) * float(state["tower_damage"]) / max(float(state["tower_fire_interval"]), 0.1)
        drone_dps = float(state["drone_count"]) * float(state["drone_damage"]) / max(float(state["drone_fire_interval"]), 0.08) * 0.72
        drone_dps *= 1.0 + float(state["drone_speed"]) / 900.0 + float(state["drone_range"]) / 1200.0
        tentacle_dps = float(state["tentacle_count"]) * float(state["tentacle_damage"]) / max(float(state["tentacle_cooldown"]), 0.12) * 0.64
        tentacle_dps *= 1.0 + float(state["tentacle_range"]) / 1000.0
        return gun_dps + tower_dps * 0.9 + drone_dps + tentacle_dps

    def calc_defense(self, state: dict) -> float:
        return (
            float(state["base_max_health"]) * 0.34
            + float(state["shield_max"]) * 0.55
            + float(state["shield_regen"]) * 4.6
            + float(state["damage_reduction"]) * 260.0
            + float(state["repair_between_waves"]) * 4.0
            + float(state["projectile_redirect_chance"]) * 180.0
            + float(state["tentacle_slow"]) * 120.0
        )

    def calc_economy(self, state: dict) -> float:
        salvage_term = float(state["salvage_multiplier"]) * (1.0 + float(state["pickup_radius"]) / 240.0)
        lifetime_term = 1.0 + max(float(state["salvage_lifetime"]) - 7.4, 0.0) / 20.0
        bank_term = 1.0 + (float(state["wave_auto_bank_ratio"]) - 0.68) * 0.55
        wave_bonus_term = 1.0 + float(state["wave_scrap_bonus"]) / 70.0
        payout_term = float(state["meta_reward_multiplier"])
        return salvage_term * lifetime_term * bank_term * wave_bonus_term * payout_term

    def calc_control(self, state: dict, wave: int) -> float:
        heavy_weight = 1.0 + max(wave - 5, 0) * 0.018
        apex_weight = 1.0 + max(wave - 10, 0) * 0.03
        return (
            float(state["enemy_count_scale"]) ** 0.9
            * (0.55 + 0.45 * float(state["enemy_speed_scale"]))
            * (0.72 + 0.28 * float(state["enemy_projectile_speed_scale"]))
            * (0.78 + 0.22 * float(state["enemy_projectile_damage_scale"]))
            * (1.0 + (float(state["elite_spawn_scale"]) - 1.0) * heavy_weight)
            * (1.0 + (float(state["heavy_enemy_health_scale"]) - 1.0) * heavy_weight)
            * (1.0 + (float(state["heavy_enemy_damage_scale"]) - 1.0) * heavy_weight * 0.8)
            * (1.0 + (float(state["apex_enemy_health_scale"]) - 1.0) * apex_weight)
            * (1.0 + (float(state["apex_enemy_damage_scale"]) - 1.0) * apex_weight)
        )

    @staticmethod
    def count_unique_nodes(meta_levels: dict[str, int]) -> int:
        return sum(1 for value in meta_levels.values() if int(value) > 0)

    @staticmethod
    def count_total_tiers(meta_levels: dict[str, int]) -> int:
        return sum(int(value) for value in meta_levels.values())

    @staticmethod
    def _avg(entries: list[dict], key: str) -> float:
        values = [float(entry.get(key, 0.0)) for entry in entries if float(entry.get(key, 0.0)) >= 0.0]
        return mean(values) if values else 0.0

    def _assess(self, demo_minutes: float, full_minutes: float) -> str:
        if demo_minutes < self.targets.demo_minutes - 4.0:
            return "demo progression too fast"
        if demo_minutes > self.targets.demo_minutes + 6.0:
            return "demo progression too slow"
        if full_minutes < self.targets.full_minutes - 8.0:
            return "full progression too fast"
        if full_minutes > self.targets.full_minutes + 10.0:
            return "full progression too slow"
        return "near target"


def render_markdown_report(report: dict) -> str:
    lines = [
        "# Red Sky Defense Balance Report",
        "",
        "## Targets",
        f"- Demo target: `{report['demo_target_minutes']}` minutes to `{report['demo_node_target']}` unlocked nodes.",
        f"- Full target: `{report['full_target_minutes']}` minutes to `{report['full_tier_target']}` total tiers.",
        f"- Practical player max tier target: `{report['practical_max_tier']}`.",
        "",
        "## Aggregate Result",
        f"- Assessment: `{report['assessment']}`",
        f"- Meta nodes: `{report['meta_node_count']}`",
        f"- Wave upgrades: `{report['wave_upgrade_count']}`",
        f"- Meta cost multiplier: `{report['meta_cost_multiplier']}`",
        f"- First-tier discount: `{report['meta_first_tier_discount']}`",
        f"- Avg minutes to demo target: `{report['avg_minutes_to_demo_nodes']}`",
        f"- Avg minutes to full-node breadth: `{report['avg_minutes_to_full_nodes']}`",
        f"- Avg minutes to full-tier target: `{report['avg_minutes_to_full_tiers']}`",
        f"- Avg run minutes: `{report['avg_run_minutes']}`",
        f"- Avg run waves: `{report['avg_run_waves']}`",
        f"- Avg run score: `{report['avg_run_score']}`",
        f"- Avg run wallet gain: `{report['avg_run_wallet_gain']}`",
        "",
        "## Campaign Notes",
    ]
    for campaign in report["campaigns"]:
        lines.append(f"### Seed {campaign['seed']}")
        lines.append(f"- Demo threshold reached at `{campaign['minutes_to_demo_nodes']}` minutes.")
        lines.append(f"- Full breadth reached at `{campaign['minutes_to_full_nodes']}` minutes.")
        lines.append(f"- Practical full-tier target reached at `{campaign['minutes_to_full_tiers']}` minutes.")
        lines.append(f"- Ending nodes/tiers: `{campaign['ending_nodes']}` / `{campaign['ending_tiers']}`")
        lines.append(f"- Ending wallet: `{campaign['ending_wallet']}`")
        lines.append("- Run path:")
        for run in campaign["run_history"][:10]:
            offer_summary = ", ".join(f"W{item['wave']}:{item['picked']}" for item in run["offers_taken"][:5]) or "none"
            buy_summary = ", ".join(f"{item['id']}->{item['new_level']}" for item in run["meta_buys_after_run"][:6]) or "none"
            lines.append(f"  - Run {run['run']}: wave `{run['waves_cleared']}`, `{run['minutes']}` min, wallet `{run['wallet_gain']}`, offers `{offer_summary}`, buys `{buy_summary}`")
        lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pass-name", default="pass")
    parser.add_argument("--meta-cost-multiplier", type=float, default=None)
    parser.add_argument("--first-tier-discount", type=float, default=None)
    parser.add_argument("--demo-node-target", type=int, default=None)
    parser.add_argument("--practical-max-tier", type=int, default=3)
    parser.add_argument("--demo-minutes", type=float, default=40.0)
    parser.add_argument("--full-minutes", type=float, default=120.0)
    parser.add_argument("--output-json", type=Path, default=None)
    parser.add_argument("--output-md", type=Path, default=None)
    args = parser.parse_args()

    data = load_red_sky_data()
    demo_node_target = (
        args.demo_node_target
        if args.demo_node_target is not None
        else int(data.get("demo_eligible_meta_node_count", len(data["meta_upgrades"])))
    )
    targets = Targets(
        demo_minutes=args.demo_minutes,
        full_minutes=args.full_minutes,
        demo_node_target=demo_node_target,
        practical_max_tier=args.practical_max_tier,
        full_tier_target=len(data["meta_upgrades"]) * args.practical_max_tier,
    )
    sim = RedSkyBalanceSim(
        data,
        meta_cost_multiplier=args.meta_cost_multiplier,
        first_tier_discount=args.first_tier_discount,
        targets=targets,
    )
    report = sim.run_report(args.pass_name)
    print(json.dumps(report, indent=2))
    if args.output_json:
        args.output_json.write_text(json.dumps(report, indent=2), encoding="utf-8")
    if args.output_md:
        args.output_md.write_text(render_markdown_report(report), encoding="utf-8")


if __name__ == "__main__":
    main()
