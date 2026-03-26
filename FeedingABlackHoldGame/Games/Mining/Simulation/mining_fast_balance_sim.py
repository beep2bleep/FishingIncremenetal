from __future__ import annotations

import json
import math
import random
import subprocess
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from statistics import mean
from typing import Dict, List, Tuple


ROOT = Path(__file__).resolve().parents[4]
PROJECT_ROOT = ROOT / "FeedingABlackHoldGame"
REPORT_DIR = PROJECT_ROOT / "Games" / "Mining" / "Reports"
VALIDATION_INPUT = REPORT_DIR / "mining_validation_input.json"
VALIDATION_OUTPUT = REPORT_DIR / "mining_validation_output.json"
GODOT_EXE = ROOT / "Godot" / "Godot_v4.6-stable_win64_console.exe"
VALIDATION_SCRIPT = "res://Games/Mining/Simulation/run_live_mining_validation.gd"

WORLD_SIZE = (1650.0, 1950.0)
BASE_RADIUS = 84.0
PLAYER_RADIUS = 18.0
CONTACT_DRILL_PADDING = 10.0
NODE_RADIUS_MIN = 18.0
NODE_RADIUS_MAX = 34.0
MAX_WORLD_NODES = 96
LEVEL_SIZE_GROWTH_PER_10_TIERS = 0.1
TARGET_DEMO_SHORT_SECONDS = 20.0 * 60.0
TARGET_DEMO_LONG_SECONDS = 40.0 * 60.0
TARGET_FULL_SECONDS = 3.0 * 60.0 * 60.0
MAX_RUNS = 520
VALIDATION_SEEDS_PER_CHECKPOINT = 3
MAX_DEPTH_LEVEL = 100
MAX_UPGRADE_LEVEL = 100
MAX_MATERIAL_TYPES_PER_LEVEL = 8
UPGRADE_EFFECT_GROUP_SIZE = 5
EARLY_UPGRADE_LEVELS = 5
LATE_COST_MULTIPLIER_START = 1.8
LATE_COST_MULTIPLIER_END = 30.0
LATE_EFFECT_MULTIPLIER_START = 1.0
LATE_EFFECT_MULTIPLIER_END = 2.25
AUTOPLAY_MOVE_SPEED_MULTIPLIER = 1.22
AUTOPLAY_DRILL_DPS_MULTIPLIER = 5.45
AUTOPLAY_DRILL_WEAR_MULTIPLIER = 0.94
MAX_PURCHASES_PER_RUN = 3
MIN_PURCHASE_SCORE_DELTA = 0.05


UPGRADES: List[Dict] = [
    {"id": "timer_reserve", "label": "Timer Reserve", "base_cost": 24, "cost_mult": 1.148, "max_level": 100, "requires": {}},
    {"id": "route_planner", "label": "Route Planner", "base_cost": 42, "cost_mult": 1.17, "max_level": 100, "requires": {"timer_reserve": 3}},
    {"id": "engine_tuning", "label": "Engine Tuning", "base_cost": 26, "cost_mult": 1.152, "max_level": 100, "requires": {}},
    {"id": "dirt_softener", "label": "Dirt Softener", "base_cost": 54, "cost_mult": 1.174, "max_level": 100, "requires": {"engine_tuning": 3}},
    {"id": "drill_torque", "label": "Drill Torque", "base_cost": 26, "cost_mult": 1.156, "max_level": 100, "requires": {}},
    {"id": "drill_plating", "label": "Drill Plating", "base_cost": 24, "cost_mult": 1.148, "max_level": 100, "requires": {"drill_torque": 2}},
    {"id": "cooling_loop", "label": "Cooling Loop", "base_cost": 28, "cost_mult": 1.152, "max_level": 100, "requires": {"drill_plating": 2}},
    {"id": "cargo_pods", "label": "Cargo Pods", "base_cost": 27, "cost_mult": 1.154, "max_level": 100, "requires": {}},
    {"id": "cargo_compressor", "label": "Cargo Compressor", "base_cost": 40, "cost_mult": 1.168, "max_level": 100, "requires": {"cargo_pods": 4}},
    {"id": "ore_refinery", "label": "Ore Refinery", "base_cost": 36, "cost_mult": 1.166, "max_level": 100, "requires": {"cargo_pods": 2}},
    {"id": "pickup_radius", "label": "Vacuum Scoop", "base_cost": 30, "cost_mult": 1.158, "max_level": 100, "requires": {"cargo_pods": 1}},
    {"id": "xp_calibration", "label": "XP Calibration", "base_cost": 46, "cost_mult": 1.176, "max_level": 100, "requires": {"ore_refinery": 2}},
    {"id": "depth_scanner", "label": "Depth Scanner", "base_cost": 62, "cost_mult": 1.182, "max_level": 100, "requires": {"xp_calibration": 2}},
    {"id": "seismic_sonar", "label": "Seismic Sonar", "base_cost": 60, "cost_mult": 1.182, "max_level": 100, "requires": {"depth_scanner": 2}},
    {"id": "magnet_drone", "label": "Salvage Drone", "base_cost": 46, "cost_mult": 1.172, "max_level": 100, "requires": {"pickup_radius": 3}},
    {"id": "foreman_bot", "label": "Foreman Bot", "base_cost": 56, "cost_mult": 1.18, "max_level": 100, "requires": {"drill_plating": 5, "magnet_drone": 3}},
    {"id": "delivery_drone", "label": "Delivery Drone", "base_cost": 54, "cost_mult": 1.176, "max_level": 100, "requires": {"magnet_drone": 2, "depth_scanner": 1}},
    {"id": "auto_sorters", "label": "Auto Sorters", "base_cost": 52, "cost_mult": 1.176, "max_level": 100, "requires": {"delivery_drone": 3}},
]
UPGRADE_BY_ID = {u["id"]: u for u in UPGRADES}

BASE_MATERIALS: List[Dict] = [
    {"id": "stone", "name": "Stone", "value": 7, "xp": 6, "hardness": 24.0},
    {"id": "bronze", "name": "Bronze", "value": 11, "xp": 9, "hardness": 34.0},
    {"id": "silver", "name": "Silver", "value": 16, "xp": 13, "hardness": 46.0},
    {"id": "gold", "name": "Gold", "value": 23, "xp": 18, "hardness": 60.0},
    {"id": "diamond", "name": "Diamond", "value": 33, "xp": 25, "hardness": 78.0},
    {"id": "platinum_bronze", "name": "Platinum Bronze", "value": 48, "xp": 34, "hardness": 98.0},
    {"id": "platinum_silver", "name": "Platinum Silver", "value": 68, "xp": 45, "hardness": 122.0},
    {"id": "platinum_gold", "name": "Platinum Gold", "value": 94, "xp": 58, "hardness": 150.0},
    {"id": "platinum_diamond", "name": "Platinum Diamond", "value": 128, "xp": 74, "hardness": 182.0},
    {"id": "super_bronze", "name": "Super Bronze", "value": 173, "xp": 94, "hardness": 218.0},
    {"id": "super_silver", "name": "Super Silver", "value": 232, "xp": 119, "hardness": 258.0},
    {"id": "super_gold", "name": "Super Gold", "value": 308, "xp": 150, "hardness": 304.0},
    {"id": "super_diamond", "name": "Super Diamond", "value": 405, "xp": 188, "hardness": 356.0},
]


def build_materials() -> List[Dict]:
    materials: List[Dict] = []
    base_count = len(BASE_MATERIALS)
    for depth_level in range(1, MAX_DEPTH_LEVEL + 1):
        base_index = max(0, min(depth_level - 1, base_count - 1))
        if depth_level <= base_count:
            materials.append(dict(BASE_MATERIALS[base_index]))
            continue
        loop_index = (depth_level - 1) % base_count
        cycle_number = 1 + (depth_level - 1) // base_count
        previous = materials[-1]
        base = dict(BASE_MATERIALS[loop_index])
        base["id"] = f"{base['id']}_{cycle_number}"
        base["name"] = f"{base['name']} {cycle_number}"
        base["value"] = int(round(float(previous["value"]) * 1.072))
        base["xp"] = int(round(float(previous["xp"]) * 1.069))
        base["hardness"] = float(previous["hardness"]) * 1.075
        materials.append(base)
    return materials


MATERIALS: List[Dict] = build_materials()


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")


def get_base_position(depth_level: int) -> Tuple[float, float]:
    world_size = world_size_for_depth(depth_level)
    return (0.0, -world_size[1] * 0.5 + 120.0)


def dist(a: Tuple[float, float], b: Tuple[float, float]) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def xp_to_next(level: int) -> int:
    level_value = float(max(level, 1))
    return int(round(65.0 + 16.0 * level_value + 12.5 * pow(level_value, 1.53)))


def level_for_total_xp(total_xp: int) -> int:
    level = 1
    remaining = max(0, total_xp)
    while remaining >= xp_to_next(level):
        remaining -= xp_to_next(level)
        level += 1
    return level


def refresh_depth_unlocks(data: Dict) -> None:
    player_level = max(1, int(data.get("player_level", 1)))
    scanner_level = int(data.get("upgrades", {}).get("depth_scanner", 0))
    unlocked = 1 + int(math.floor(float(player_level - 1) / 3.2)) + int(math.floor(float(scanner_level) * 0.7))
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), min(MAX_DEPTH_LEVEL, unlocked))
    data["selected_depth_level"] = min(int(data["deepest_level_unlocked"]), max(1, int(data.get("selected_depth_level", 1))))


def get_default_state() -> Dict:
    data = {
        "wallet": 0,
        "xp": 0,
        "player_level": 1,
        "deepest_level_unlocked": 1,
        "selected_depth_level": 1,
        "upgrades": {},
    }
    refresh_depth_unlocks(data)
    return data


def get_upgrade_cost(upgrade_id: str, current_level: int) -> int:
    upgrade = UPGRADE_BY_ID[upgrade_id]
    level_to_buy = current_level + 1
    late_mult = get_late_upgrade_multiplier(level_to_buy, int(upgrade["max_level"]))
    return int(round(float(upgrade["base_cost"]) * pow(float(upgrade["cost_mult"]), current_level) * late_mult))


def get_late_upgrade_multiplier(level: int, max_level: int = MAX_UPGRADE_LEVEL) -> float:
    if level <= EARLY_UPGRADE_LEVELS:
        return 1.0
    late_levels = max(1, max_level - EARLY_UPGRADE_LEVELS)
    denominator = late_levels - 1 if late_levels > 1 else 1
    progress = float(level - EARLY_UPGRADE_LEVELS - 1) / float(denominator)
    progress = max(0.0, min(1.0, progress))
    return LATE_COST_MULTIPLIER_START + (LATE_COST_MULTIPLIER_END - LATE_COST_MULTIPLIER_START) * progress


def get_upgrade_effect_multiplier(level: int, max_level: int = MAX_UPGRADE_LEVEL) -> float:
    grouped_level = get_group_start_level(level)
    if grouped_level <= EARLY_UPGRADE_LEVELS:
        return 1.0
    late_levels = max(1, max_level - EARLY_UPGRADE_LEVELS)
    denominator = late_levels - 1 if late_levels > 1 else 1
    progress = float(grouped_level - EARLY_UPGRADE_LEVELS - 1) / float(denominator)
    progress = max(0.0, min(1.0, progress))
    return LATE_EFFECT_MULTIPLIER_START + (LATE_EFFECT_MULTIPLIER_END - LATE_EFFECT_MULTIPLIER_START) * progress


def get_group_start_level(level: int) -> int:
    return ((max(level, 1) - 1) // UPGRADE_EFFECT_GROUP_SIZE) * UPGRADE_EFFECT_GROUP_SIZE + 1


def scaled_upgrade_strength(upgrades: Dict[str, int], upgrade_id: str) -> float:
    owned_level = int(upgrades.get(upgrade_id, 0))
    max_level = int(UPGRADE_BY_ID.get(upgrade_id, {}).get("max_level", MAX_UPGRADE_LEVEL))
    total = 0.0
    for level in range(1, owned_level + 1):
        total += get_upgrade_effect_multiplier(level, max_level)
    return total


def move_speed(upgrades: Dict[str, int]) -> float:
    return 210.0 + 0.84 * scaled_upgrade_strength(upgrades, "engine_tuning") + 0.14 * scaled_upgrade_strength(upgrades, "route_planner")


def dirt_drag(depth_level: int, upgrades: Dict[str, int]) -> float:
    base = 0.98 - 0.028 * max(0, depth_level - 1)
    base += 0.0035 * scaled_upgrade_strength(upgrades, "dirt_softener")
    base += 0.001 * scaled_upgrade_strength(upgrades, "route_planner")
    return max(0.42, min(1.0, base))


def world_scale_multiplier(depth_level: int) -> float:
    completed_tier_bands = math.floor(depth_level / 10.0)
    return 1.0 + completed_tier_bands * LEVEL_SIZE_GROWTH_PER_10_TIERS


def world_size_for_depth(depth_level: int) -> Tuple[float, float]:
    scale = world_scale_multiplier(depth_level)
    return (WORLD_SIZE[0] * scale, WORLD_SIZE[1] * scale)


def world_area_multiplier(depth_level: int) -> float:
    scale = world_scale_multiplier(depth_level)
    return scale * scale


def run_time_limit(upgrades: Dict[str, int]) -> float:
    return 22.0 + 0.65 * scaled_upgrade_strength(upgrades, "timer_reserve")


def time_drain(depth_level: int, upgrades: Dict[str, int]) -> float:
    drain = 1.0 + 0.038 * max(0, depth_level - 1) - 0.012 * scaled_upgrade_strength(upgrades, "route_planner")
    return max(0.68, min(2.2, drain))


def drill_dps(upgrades: Dict[str, int]) -> float:
    return 7.4 + 1.12 * scaled_upgrade_strength(upgrades, "drill_torque") + 0.12 * scaled_upgrade_strength(upgrades, "cooling_loop") + 0.72 * scaled_upgrade_strength(upgrades, "foreman_bot")


def drill_health_max(upgrades: Dict[str, int]) -> float:
    return 54.0 + 9.0 * scaled_upgrade_strength(upgrades, "drill_plating")


def drill_wear_multiplier(upgrades: Dict[str, int]) -> float:
    return max(0.2, min(1.0, 1.0 - 0.0115 * scaled_upgrade_strength(upgrades, "cooling_loop")))


def cargo_capacity(upgrades: Dict[str, int]) -> int:
    return 4 + int(round(scaled_upgrade_strength(upgrades, "cargo_pods"))) + int(math.floor(scaled_upgrade_strength(upgrades, "cargo_compressor") / 3.0))


def value_multiplier(upgrades: Dict[str, int]) -> float:
    return 1.0 + 0.03 * scaled_upgrade_strength(upgrades, "ore_refinery") + 0.008 * scaled_upgrade_strength(upgrades, "cargo_compressor")


def xp_multiplier(upgrades: Dict[str, int]) -> float:
    return 1.0 + 0.035 * scaled_upgrade_strength(upgrades, "xp_calibration")


def pickup_radius(upgrades: Dict[str, int]) -> float:
    return 18.0 + 2.7 * scaled_upgrade_strength(upgrades, "pickup_radius") + 1.6 * scaled_upgrade_strength(upgrades, "magnet_drone")


def pickup_drone_count(upgrades: Dict[str, int]) -> int:
    strength = scaled_upgrade_strength(upgrades, "magnet_drone")
    return 0 if strength <= 0.0 else 1 + int(math.floor(max(0.0, strength - 1.0) / 5.0))


def pickup_drone_depth_drag(depth_level: int) -> float:
    return max(0.46, min(1.0, 1.0 - 0.022 * max(0, depth_level - 1)))


def pickup_drone_speed(depth_level: int, upgrades: Dict[str, int]) -> float:
    base = 248.0 + 5.0 * scaled_upgrade_strength(upgrades, "magnet_drone")
    return max(86.0, base * pickup_drone_depth_drag(depth_level))


def delivery_drone_count(upgrades: Dict[str, int]) -> int:
    strength = scaled_upgrade_strength(upgrades, "delivery_drone")
    return 0 if strength <= 0.0 else 1 + int(math.floor(max(0.0, strength - 1.0) / 4.0))


def delivery_drone_depth_drag(depth_level: int) -> float:
    return max(0.22, min(1.0, 1.0 - 0.032 * max(0, depth_level - 1)))


def delivery_speed(depth_level: int, upgrades: Dict[str, int]) -> float:
    base = 38.0 + 1.05 * scaled_upgrade_strength(upgrades, "delivery_drone") + 0.5 * scaled_upgrade_strength(upgrades, "auto_sorters")
    return max(5.0, base * delivery_drone_depth_drag(depth_level))


def dispatch_window(upgrades: Dict[str, int]) -> float:
    return max(0.9, min(5.65, 5.65 - 0.09 * scaled_upgrade_strength(upgrades, "delivery_drone") - 0.04 * scaled_upgrade_strength(upgrades, "auto_sorters")))


def delivery_items(upgrades: Dict[str, int]) -> int:
    return 1 + int(math.floor(scaled_upgrade_strength(upgrades, "auto_sorters") / 5.0))


def material_weights(available_tiers: int, upgrades: Dict[str, int]) -> List[float]:
    if available_tiers <= 1:
        return [1.0]
    sonar = upgrades.get("seismic_sonar", 0)
    weights: List[float] = []
    for idx in range(available_tiers):
        weight = 1.0 + (4.0 if idx == 0 else 0.0)
        if idx == available_tiers - 1:
            weight = 7.3 + sonar * 0.55
        elif idx == available_tiers - 2:
            weight = 3.0 + sonar * 0.24
        elif idx <= available_tiers - 3:
            weight = max(0.5, weight - sonar * 0.05)
        weights.append(weight)
    return weights


def material_pool_indices(available_tiers: int) -> List[int]:
    capped_tiers = max(1, available_tiers)
    if capped_tiers <= MAX_MATERIAL_TYPES_PER_LEVEL:
        return list(range(capped_tiers))

    recent_count = min(5, MAX_MATERIAL_TYPES_PER_LEVEL - 1)
    recent_start = max(0, capped_tiers - recent_count)
    anchor_count = MAX_MATERIAL_TYPES_PER_LEVEL - recent_count
    anchor_limit = max(1, recent_start)
    indices: List[int] = []
    for anchor_index in range(anchor_count):
        progress = 0.0 if anchor_count <= 1 else float(anchor_index) / float(anchor_count - 1)
        selected_index = int(round(progress * float(anchor_limit - 1)))
        if not indices or indices[-1] != selected_index:
            indices.append(selected_index)
    for recent_index in range(recent_start, capped_tiers):
        if recent_index not in indices:
            indices.append(recent_index)
    return indices


def material_weights_for_indices(indices: List[int], upgrades: Dict[str, int]) -> List[float]:
    if not indices:
        return [1.0]
    weights_by_tier = material_weights(indices[-1] + 1, upgrades)
    pool_size = len(indices)
    weights: List[float] = []
    for pool_index, tier_index in enumerate(indices):
        weight = float(weights_by_tier[tier_index])
        recency_progress = float(pool_index + 1) / float(pool_size)
        if pool_index >= pool_size - min(3, pool_size):
            weight *= 1.15 + recency_progress * 0.35
        elif pool_index == 0:
            weight *= 0.9
        else:
            weight *= 0.95 + recency_progress * 0.15
        weights.append(weight)
    return weights


def node_health(material: Dict, depth_level: int) -> float:
    return float(material["hardness"]) * (1.0 + 0.018 * max(0, depth_level - 1))


def node_wear_per_second(max_health: float, upgrades: Dict[str, int]) -> float:
    return (2.3 + max_health * 0.049) * drill_wear_multiplier(upgrades)


def drop_count(node_value: int) -> int:
    return max(1, min(5, 1 + int(math.floor(math.sqrt(node_value) / 8.5))))


def weight_roll(rng: random.Random, weights: List[float]) -> int:
    total = sum(weights)
    roll = rng.random() * total
    for idx, weight in enumerate(weights):
        roll -= weight
        if roll <= 0.0:
            return idx
    return len(weights) - 1


@dataclass
class Node:
    pos: Tuple[float, float]
    radius: float
    health: float
    max_health: float
    material_id: str
    material_name: str
    value: int
    xp: int


@dataclass
class Pickup:
    pos: Tuple[float, float]
    material_id: str


@dataclass
class RunResult:
    money: int
    xp: int
    depth_level: int
    simulated_seconds: float
    nodes_broken: int
    bank_trips: int
    delivery_dumps: int
    reason: str
    time_left: float
    time_limit: float
    drill_left: float
    drill_max: float
    projected_data: Dict

    def to_dict(self) -> Dict:
        return {
            "money": self.money,
            "xp": self.xp,
            "depth_level": self.depth_level,
            "simulated_seconds": round(self.simulated_seconds, 3),
            "nodes_broken": self.nodes_broken,
            "bank_trips": self.bank_trips,
            "delivery_dumps": self.delivery_dumps,
            "reason": self.reason,
            "time_left": round(self.time_left, 3),
            "time_limit": round(self.time_limit, 3),
            "drill_left": round(self.drill_left, 3),
            "drill_max": round(self.drill_max, 3),
            "projected_data": self.projected_data,
        }


def generate_world(depth_level: int, upgrades: Dict[str, int], seed: int) -> List[Node]:
    rng = random.Random(seed)
    base = get_base_position(depth_level)
    available_tiers = min(depth_level, len(MATERIALS))
    selected_indices = material_pool_indices(available_tiers)
    world_size = world_size_for_depth(depth_level)
    area_multiplier = world_area_multiplier(depth_level)
    node_count = min(round(MAX_WORLD_NODES * area_multiplier), round((28 + depth_level * 6) * area_multiplier))
    nodes: List[Node] = []
    weights = material_weights_for_indices(selected_indices, upgrades)
    for _ in range(node_count):
        mat = MATERIALS[selected_indices[weight_roll(rng, weights)]]
        health = node_health(mat, depth_level)
        radius = max(NODE_RADIUS_MIN, min(NODE_RADIUS_MAX, 14.0 + math.sqrt(health) * 1.9))
        pos = (0.0, 0.0)
        attempts = 0
        while attempts < 32:
            pos = (
                rng.uniform(-world_size[0] * 0.47, world_size[0] * 0.47),
                rng.uniform(-world_size[1] * 0.36, world_size[1] * 0.47),
            )
            if dist(pos, base) < BASE_RADIUS + 150.0:
                attempts += 1
                continue
            if any(dist(pos, n.pos) < radius + n.radius + 18.0 for n in nodes):
                attempts += 1
                continue
            break
        nodes.append(
            Node(
                pos=pos,
                radius=radius,
                health=health,
                max_health=health,
                material_id=mat["id"],
                material_name=mat["name"],
                value=int(mat["value"]),
                xp=int(mat["xp"]),
            )
        )
    return nodes


def simulate_fast_run(state: Dict, depth_level: int, seed: int) -> Dict:
    upgrades = dict(state.get("upgrades", {}))
    base = get_base_position(depth_level)
    position = base
    rng = random.Random(seed * 3571 + depth_level * 211)
    time_limit = run_time_limit(upgrades)
    time_left = time_limit
    drill_max = drill_health_max(upgrades)
    drill_left = drill_max
    cargo = 0
    banked: Dict[str, int] = {}
    carried: Dict[str, int] = {}
    pickups: List[Pickup] = []
    nodes = generate_world(depth_level, upgrades, seed)
    nodes_broken = 0
    bank_trips = 0
    delivery_dumps = 0
    elapsed = 0.0
    delivery_progress = 0.0
    pickup_progress = 0.0
    run_xp = 0
    player_speed = max(1.0, move_speed(upgrades) * dirt_drag(depth_level, upgrades) * AUTOPLAY_MOVE_SPEED_MULTIPLIER)
    dps = max(1.0, drill_dps(upgrades) * AUTOPLAY_DRILL_DPS_MULTIPLIER)
    collect_radius = pickup_radius(upgrades)
    pickup_bot_count = pickup_drone_count(upgrades)
    delivery_rate_floor = delivery_drone_count(upgrades)
    carry_order: List[str] = []

    def add_carried(material_id: str, count: int) -> None:
        nonlocal cargo
        if count <= 0:
            return
        if material_id not in carried:
            carry_order.append(material_id)
        carried[material_id] = carried.get(material_id, 0) + count
        cargo += count

    def remove_one_carried(material_id: str) -> None:
        nonlocal cargo
        if material_id not in carried:
            return
        carried[material_id] -= 1
        cargo = max(0, cargo - 1)
        if carried[material_id] <= 0:
            carried.pop(material_id, None)
            if material_id in carry_order:
                carry_order.remove(material_id)

    def offload_background(seconds: float, current_distance: float) -> None:
        nonlocal delivery_progress, delivery_dumps
        if delivery_rate_floor <= 0 or cargo <= 0:
            return
        cycle_time = dispatch_window(upgrades) + current_distance / max(1.0, delivery_speed(depth_level, upgrades))
        if cycle_time <= 0:
            return
        items_per_second = (delivery_rate_floor * delivery_items(upgrades)) / cycle_time
        delivery_progress += seconds * items_per_second
        to_dump = min(cargo, int(delivery_progress))
        if to_dump <= 0:
            return
        delivery_progress -= to_dump
        delivery_dumps += to_dump
        while to_dump > 0 and carry_order:
            material_id = carry_order[0]
            available = carried.get(material_id, 0)
            if available <= 0:
                carry_order.pop(0)
                carried.pop(material_id, None)
                continue
            banked[material_id] = banked.get(material_id, 0) + 1
            remove_one_carried(material_id)
            to_dump -= 1

    def collect_with_pickup_drones(seconds: float) -> None:
        nonlocal pickup_progress
        if pickup_bot_count <= 0 or cargo >= cargo_capacity(upgrades) or not pickups:
            return
        nearest_distance = min(dist(position, pickup.pos) for pickup in pickups)
        cycle_time = max(0.45, 0.2 + nearest_distance * 2.0 / max(1.0, pickup_drone_speed(depth_level, upgrades)))
        items_per_second = pickup_bot_count / cycle_time
        pickup_progress += seconds * items_per_second
        collected = min(len(pickups), cargo_capacity(upgrades) - cargo, int(pickup_progress))
        if collected <= 0:
            return
        pickup_progress -= collected
        for _ in range(collected):
            nearest_index = min(range(len(pickups)), key=lambda idx: dist(position, pickups[idx].pos))
            pickup = pickups.pop(nearest_index)
            add_carried(pickup.material_id, 1)

    def spend_seconds(seconds: float, current_distance: float) -> None:
        nonlocal elapsed, time_left
        if seconds <= 0.0:
            return
        elapsed += seconds
        time_left -= seconds * time_drain(depth_level, upgrades)
        offload_background(seconds, current_distance)
        collect_with_pickup_drones(seconds)

    def find_nearest_pickup_index() -> int:
        if not pickups:
            return -1
        return min(range(len(pickups)), key=lambda idx: dist(position, pickups[idx].pos))

    def estimate_wear_buffer() -> float:
        if not nodes:
            return 8.0
        nearest_index = min(range(len(nodes)), key=lambda idx: dist(position, nodes[idx].pos))
        node = nodes[nearest_index]
        expected_contact_time = node.health / max(1.0, drill_dps(upgrades) * 4.2)
        return 6.0 + node_wear_per_second(node.max_health, upgrades) * max(0.4, expected_contact_time)

    while time_left > 0.0 and drill_left > 0.0 and nodes:
        should_bank = False
        if cargo >= cargo_capacity(upgrades):
            should_bank = True
        elif cargo > 0 and time_left <= dist(position, base) / player_speed + 1.2:
            should_bank = True
        elif cargo > 0 and drill_left <= estimate_wear_buffer():
            should_bank = True
        if should_bank:
            travel = dist(position, base) / player_speed
            spend_seconds(max(0.0, travel), dist(position, base))
            position = base
            if time_left <= 0.0:
                break
            for material_id, count in list(carried.items()):
                banked[material_id] = banked.get(material_id, 0) + count
            carried.clear()
            carry_order.clear()
            cargo = 0
            bank_trips += 1
            continue

        nearest_pickup_index = find_nearest_pickup_index()
        nearest_node_index = min(range(len(nodes)), key=lambda idx: dist(position, nodes[idx].pos))
        nearest_node = nodes[nearest_node_index]
        target_pickup = False
        if cargo < cargo_capacity(upgrades) and nearest_pickup_index != -1:
            pickup = pickups[nearest_pickup_index]
            pickup_distance = dist(position, pickup.pos)
            node_distance = dist(position, nearest_node.pos) if nodes else math.inf
            pickup_priority_distance = max(72.0, collect_radius + 32.0)
            target_pickup = pickup_distance <= pickup_priority_distance or pickup_distance + 24.0 < node_distance

        if target_pickup:
            pickup = pickups[nearest_pickup_index]
            travel_distance = max(0.0, dist(position, pickup.pos) - collect_radius)
            spend_seconds(travel_distance / player_speed, dist(position, base))
            position = pickup.pos
            if time_left <= 0.0:
                break
            if pickup in pickups and cargo < cargo_capacity(upgrades):
                pickups.remove(pickup)
                add_carried(pickup.material_id, 1)
            continue

        node = nearest_node
        var_distance = dist(position, node.pos)
        contact_offset = PLAYER_RADIUS + node.radius + 1.0
        target_distance = max(0.0, var_distance - (PLAYER_RADIUS + node.radius + CONTACT_DRILL_PADDING))
        travel = target_distance / player_speed
        if var_distance > 0.0:
            direction = ((node.pos[0] - position[0]) / var_distance, (node.pos[1] - position[1]) / var_distance)
            contact_pos = (node.pos[0] - direction[0] * contact_offset, node.pos[1] - direction[1] * contact_offset)
        else:
            direction = (0.0, -1.0)
            contact_pos = (node.pos[0], node.pos[1] - contact_offset)
        spend_seconds(travel, dist(position, base))
        position = contact_pos
        if time_left <= 0.0:
            break

        drill_time = node.health / dps
        spend_seconds(drill_time, dist(position, base))
        drill_left -= node_wear_per_second(node.max_health, upgrades) * AUTOPLAY_DRILL_WEAR_MULTIPLIER * drill_time
        if time_left <= 0.0 or drill_left <= 0.0:
            break

        nodes.pop(nearest_node_index)
        nodes_broken += 1
        run_xp += int(round(node.xp * xp_multiplier(upgrades)))
        drops = drop_count(node.value)
        for _ in range(drops):
            angle = rng.random() * math.tau
            radius = rng.uniform(14.0, 28.0)
            pickup_pos = (node.pos[0] + math.cos(angle) * radius, node.pos[1] + math.sin(angle) * radius)
            if dist(position, pickup_pos) <= collect_radius and cargo < cargo_capacity(upgrades):
                add_carried(node.material_id, 1)
            else:
                pickups.append(Pickup(pos=pickup_pos, material_id=node.material_id))

    for material_id, count in carried.items():
        banked[material_id] = banked.get(material_id, 0) + count

    total_money = 0
    material_lookup = {m["id"]: m for m in MATERIALS}
    for material_id, count in banked.items():
        material = material_lookup[material_id]
        total_money += count * int(round(material["value"] * value_multiplier(upgrades)))

    projected = json.loads(json.dumps(state))
    projected["wallet"] = int(projected.get("wallet", 0)) + total_money
    projected["xp"] = int(projected.get("xp", 0)) + run_xp
    projected["player_level"] = level_for_total_xp(projected["xp"])
    projected["deepest_level_unlocked"] = max(int(projected.get("deepest_level_unlocked", 1)), depth_level)
    refresh_depth_unlocks(projected)
    reason = "Drill health depleted." if drill_left <= 0.0 and time_left > 0.0 else "Timer expired."
    result = RunResult(
        money=total_money,
        xp=run_xp,
        depth_level=depth_level,
        simulated_seconds=elapsed,
        nodes_broken=nodes_broken,
        bank_trips=bank_trips,
        delivery_dumps=delivery_dumps,
        reason=reason,
        time_left=max(0.0, time_left),
        time_limit=time_limit,
        drill_left=max(0.0, drill_left),
        drill_max=drill_max,
        projected_data=projected,
    )
    return result.to_dict()


def score_run(run: Dict) -> float:
    run_time = max(1.0, float(run["simulated_seconds"]))
    money_per_second = float(run["money"]) / run_time
    xp_per_second = float(run["xp"]) / run_time
    depth_bonus = float(run["depth_level"]) * 0.34
    time_pressure = 1.0 - (float(run["time_left"]) / max(0.1, float(run["time_limit"])))
    drill_pressure = 1.0 - (float(run["drill_left"]) / max(0.1, float(run["drill_max"])))
    time_band_bonus = 0.0
    if run_time < 15.0:
        time_band_bonus -= (15.0 - run_time) * 2.6
    elif run_time > 45.0:
        time_band_bonus -= (run_time - 45.0) * 1.4
    else:
        time_band_bonus += min(1.8, (run_time - 15.0) / 30.0 * 1.8)
    return money_per_second + xp_per_second * 0.68 + depth_bonus + time_pressure * 0.8 + drill_pressure * 0.5 + time_band_bonus


def affordable_upgrades(state: Dict) -> List[Dict]:
    wallet = int(state.get("wallet", 0))
    upgrades = state.get("upgrades", {})
    options = []
    for upgrade in UPGRADES:
        current = int(upgrades.get(upgrade["id"], 0))
        if current >= int(upgrade["max_level"]):
            continue
        if any(int(upgrades.get(req, 0)) < req_level for req, req_level in upgrade["requires"].items()):
            continue
        cost = get_upgrade_cost(upgrade["id"], current)
        if wallet >= cost:
            options.append({"id": upgrade["id"], "label": upgrade["label"], "level": current + 1, "cost": cost})
    options.sort(key=lambda item: (item["cost"], item["id"]))
    return options


def apply_purchase(state: Dict, purchase: Dict) -> Dict:
    upgraded = json.loads(json.dumps(state))
    upgraded["wallet"] = max(0, int(upgraded.get("wallet", 0)) - int(purchase["cost"]))
    upgraded.setdefault("upgrades", {})
    upgraded["upgrades"][purchase["id"]] = int(purchase["level"])
    refresh_depth_unlocks(upgraded)
    return upgraded


def preview_depth_candidates(state: Dict, preferred_depth: int) -> List[int]:
    deepest = min(MAX_DEPTH_LEVEL, int(state.get("deepest_level_unlocked", 1)))
    candidates = {
        max(1, min(deepest, preferred_depth)),
        max(1, min(deepest, preferred_depth - 1)),
        max(1, min(deepest, preferred_depth + 1)),
        deepest,
    }
    return sorted(candidates)


def search_depth_candidates(state: Dict) -> List[int]:
    deepest = min(MAX_DEPTH_LEVEL, int(state.get("deepest_level_unlocked", 1)))
    if deepest <= 8:
        return list(range(1, deepest + 1))
    candidates = {1, deepest}
    for offset in range(1, 7):
        candidates.add(max(1, deepest - offset))
    candidates.add(max(1, int(round(deepest * 0.8))))
    candidates.add(max(1, int(round(deepest * 0.6))))
    candidates.add(max(1, int(round(deepest * 0.4))))
    return sorted(candidates)


def choose_best_depth(state: Dict, base_seed: int, run_index: int) -> Dict:
    best = None
    best_score = -1e18
    for depth in search_depth_candidates(state):
        run = simulate_fast_run(state, depth, base_seed * 100000 + run_index * 113 + depth * 17)
        run_score = score_run(run)
        if run_score > best_score:
            best = run
            best_score = run_score
    return best


def preview_best_run(state: Dict, preferred_depth: int, base_seed: int, run_index: int, salt: int) -> Dict:
    best = None
    best_score = -1e18
    for depth in preview_depth_candidates(state, preferred_depth):
        preview = simulate_fast_run(state, depth, base_seed * 100000 + run_index * 199 + depth * 29 + salt)
        preview_score = score_run(preview)
        if preview_score > best_score:
            best = preview
            best_score = preview_score
    return best


def choose_best_purchase(state: Dict, baseline_run: Dict, base_seed: int, run_index: int, purchase_index: int) -> Dict | None:
    candidates = affordable_upgrades(state)
    if not candidates:
        return None
    baseline_score = score_run(baseline_run)
    baseline_depth = int(baseline_run["depth_level"])
    affordable_ids_before = {candidate["id"] for candidate in candidates}
    best = None
    best_score = -1e18
    for candidate in candidates:
        purchased_state = apply_purchase(state, candidate)
        preview = preview_best_run(
            purchased_state,
            baseline_depth,
            base_seed,
            run_index,
            purchase_index * 97 + candidate["level"] * 29,
        )
        preview_score = score_run(preview)
        score_delta = preview_score - baseline_score
        new_affordable_ids = {option["id"] for option in affordable_upgrades(purchased_state)}
        unlock_bonus = min(1.0, 0.25 * len(new_affordable_ids - affordable_ids_before))
        depth_bonus = max(0, int(preview["depth_level"]) - baseline_depth) * 0.6
        affordability_bonus = min(0.8, 40.0 / max(1.0, candidate["cost"]))
        weighted_score = score_delta * 3.0 + unlock_bonus + depth_bonus + affordability_bonus
        if weighted_score > best_score:
            best = dict(candidate)
            best["projected_data"] = purchased_state
            best["preview_run"] = preview
            best["preview_score"] = preview_score
            best["score_delta"] = score_delta
            best["unlock_bonus"] = unlock_bonus
            best["depth_bonus"] = depth_bonus
            best["weighted_score"] = weighted_score
            best_score = weighted_score
    return best


def choose_purchase_sequence(state: Dict, baseline_run: Dict, base_seed: int, run_index: int) -> Tuple[List[Dict], Dict]:
    purchases: List[Dict] = []
    current_state = json.loads(json.dumps(state))
    current_baseline = dict(baseline_run)
    for purchase_index in range(1, MAX_PURCHASES_PER_RUN + 1):
        candidate = choose_best_purchase(current_state, current_baseline, base_seed, run_index, purchase_index)
        if not candidate:
            break
        score_delta = float(candidate.get("score_delta", 0.0))
        unlock_bonus = float(candidate.get("unlock_bonus", 0.0))
        depth_bonus = float(candidate.get("depth_bonus", 0.0))
        required_delta = MIN_PURCHASE_SCORE_DELTA * float(purchase_index)
        if score_delta < required_delta and unlock_bonus < 0.5 and depth_bonus <= 0.0:
            break
        current_state = candidate["projected_data"]
        current_baseline = candidate["preview_run"]
        purchase_record = {
            "id": candidate["id"],
            "label": candidate["label"],
            "level": candidate["level"],
            "cost": candidate["cost"],
            "score_delta": score_delta,
            "preview_depth_level": int(current_baseline["depth_level"]),
            "wallet_after_spend": int(current_state["wallet"]),
            "save_data": json.loads(json.dumps(current_state)),
        }
        purchases.append(purchase_record)
    return purchases, current_state


def run_campaign(seed: int) -> Dict:
    state = get_default_state()
    runs: List[Dict] = []
    purchases: List[Dict] = []
    total_time = 0.0
    for run_index in range(1, MAX_RUNS + 1):
        best_run = choose_best_depth(state, seed, run_index)
        best_run["run_index"] = run_index
        total_time += float(best_run["simulated_seconds"])
        state = best_run["projected_data"]
        wallet_before_spend = int(state["wallet"])
        purchases_this_run, state = choose_purchase_sequence(state, best_run, seed, run_index)
        if purchases_this_run:
            best_run["upgrade_bought"] = " + ".join(purchase["id"] for purchase in purchases_this_run)
            best_run["upgrade_level"] = int(purchases_this_run[-1]["level"])
            best_run["upgrade_cost"] = int(sum(int(purchase["cost"]) for purchase in purchases_this_run))
            best_run["purchase_count_after_run"] = len(purchases_this_run)
            best_run["purchases_after_run"] = json.loads(json.dumps(purchases_this_run))
            best_run["wallet_before_spend"] = wallet_before_spend
            best_run["wallet_after_spend"] = int(state["wallet"])
            for purchase in purchases_this_run:
                purchases.append(
                    {
                        "run_index": run_index,
                        "label": purchase["label"],
                        "id": purchase["id"],
                        "level": purchase["level"],
                        "cost": purchase["cost"],
                        "cumulative_time_seconds": total_time,
                        "wallet_after_spend": int(purchase["wallet_after_spend"]),
                        "preview_depth_level": int(purchase["preview_depth_level"]),
                        "save_data": json.loads(json.dumps(purchase["save_data"])),
                    }
                )
        else:
            best_run["upgrade_bought"] = ""
            best_run["upgrade_level"] = 0
            best_run["upgrade_cost"] = 0
            best_run["purchase_count_after_run"] = 0
            best_run["purchases_after_run"] = []
            best_run["wallet_before_spend"] = wallet_before_spend
            best_run["wallet_after_spend"] = int(state["wallet"])
        runs.append(best_run)
        if all(int(state.get("upgrades", {}).get(u["id"], 0)) >= int(u["max_level"]) for u in UPGRADES):
            break
        if total_time >= TARGET_FULL_SECONDS + 600.0:
            break
    return {
        "seed": seed,
        "runs": runs,
        "purchases": purchases,
        "total_time_seconds": total_time,
        "total_runs": len(runs),
        "purchase_count": len(purchases),
        "upgrades_per_run": len(purchases) / max(1, len(runs)),
        "final_state": state,
    }


def build_validation_scenarios(campaign: Dict) -> List[Dict]:
    purchase_targets = [1, 10, 25, 50, 100, 150, 220, 300]
    checkpoint_specs = []
    for purchase_index, purchase in enumerate(campaign["purchases"], start=1):
        if purchase_index in purchase_targets:
            checkpoint_specs.append(
                {
                    "checkpoint_id": f"purchase_{purchase_index}",
                    "purchase_index": purchase_index,
                    "depth_level": int(purchase.get("preview_depth_level", 1)),
                    "save_data": purchase.get("save_data", get_default_state()),
                }
            )
        if len(checkpoint_specs) >= len(purchase_targets):
            break
    scenarios = []
    for checkpoint in checkpoint_specs:
        for seed_offset in range(VALIDATION_SEEDS_PER_CHECKPOINT):
            scenarios.append(
                {
                    "id": f"{checkpoint['checkpoint_id']}_seed_{seed_offset + 1}",
                    "checkpoint_id": checkpoint["checkpoint_id"],
                    "seed": 900 + checkpoint["purchase_index"] * 23 + seed_offset,
                    "depth_level": checkpoint["depth_level"],
                    "save_data": checkpoint["save_data"],
                }
            )
    if not scenarios:
        scenarios.append(
            {
                "id": "baseline_seed_1",
                "checkpoint_id": "baseline",
                "seed": 901,
                "depth_level": 1,
                "save_data": get_default_state(),
            }
        )
    return scenarios


def run_live_validation(scenarios: List[Dict]) -> Dict:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    VALIDATION_INPUT.write_text(json.dumps({"scenarios": scenarios}, indent=2), encoding="utf-8")
    command = [
        str(GODOT_EXE),
        "--headless",
        "--path",
        str(PROJECT_ROOT),
        "--script",
        VALIDATION_SCRIPT,
        f"--input={VALIDATION_INPUT}",
        f"--output={VALIDATION_OUTPUT}",
    ]
    subprocess.run(command, check=True, cwd=str(ROOT))
    return json.loads(VALIDATION_OUTPUT.read_text(encoding="utf-8"))


def compare_validation(scenarios: List[Dict], live_results: Dict) -> Dict:
    live_by_id = {row["scenario_id"]: row for row in live_results.get("results", [])}
    scenario_rows = []
    checkpoint_buckets: Dict[str, List[Dict]] = defaultdict(list)
    for scenario in scenarios:
        scenario_id = scenario["id"]
        fast = simulate_fast_run(scenario["save_data"], int(scenario["depth_level"]), int(scenario["seed"]))
        live = live_by_id.get(scenario_id, {})
        row = {
            "id": scenario_id,
            "checkpoint_id": str(scenario.get("checkpoint_id", scenario_id)),
            "depth_level": scenario["depth_level"],
        }
        for key in ("money", "xp", "simulated_seconds", "nodes_broken"):
            fast_value = float(fast.get(key, 0.0))
            live_value = float(live.get(key, 0.0))
            denominator = max(1.0, abs(live_value))
            row[f"fast_{key}"] = fast_value
            row[f"live_{key}"] = live_value
            row[f"{key}_error_pct"] = abs(fast_value - live_value) / denominator * 100.0
        scenario_rows.append(row)
        checkpoint_buckets[row["checkpoint_id"]].append(row)

    checkpoint_rows = []
    tracked_metrics = ("money", "xp", "simulated_seconds", "nodes_broken")
    for checkpoint_id in sorted(checkpoint_buckets.keys()):
        rows = checkpoint_buckets[checkpoint_id]
        checkpoint_row = {
            "checkpoint_id": checkpoint_id,
            "depth_level": rows[0]["depth_level"],
            "sample_count": len(rows),
        }
        for key in tracked_metrics:
            fast_avg = mean(float(row[f"fast_{key}"]) for row in rows)
            live_avg = mean(float(row[f"live_{key}"]) for row in rows)
            checkpoint_row[f"fast_avg_{key}"] = fast_avg
            checkpoint_row[f"live_avg_{key}"] = live_avg
            checkpoint_row[f"{key}_avg_error_pct"] = abs(fast_avg - live_avg) / max(1.0, abs(live_avg)) * 100.0
        checkpoint_rows.append(checkpoint_row)

    overall_error = {
        f"{key}_avg_error_pct": mean(row[f"{key}_avg_error_pct"] for row in checkpoint_rows)
        for key in tracked_metrics
    } if checkpoint_rows else {}
    overall_error["passes_10pct_gate"] = all(
        overall_error.get(f"{key}_avg_error_pct", 100.0) <= 10.0
        for key in ("money", "xp", "simulated_seconds")
    )
    return {
        "scenario_rows": scenario_rows,
        "checkpoint_rows": checkpoint_rows,
        "overall": overall_error,
    }


def build_time_slice(campaign: Dict, seconds: float, label: str) -> Dict:
    elapsed = 0.0
    included_runs: List[Dict] = []
    for run in campaign["runs"]:
        run_time = float(run.get("simulated_seconds", 0.0))
        if elapsed + run_time > seconds + 1e-6:
            break
        elapsed += run_time
        included_runs.append(run)

    included_purchases = [
        purchase
        for purchase in campaign["purchases"]
        if float(purchase.get("cumulative_time_seconds", 0.0)) <= seconds + 1e-6
    ]
    final_state = (
        included_purchases[-1]["save_data"]
        if included_purchases
        else included_runs[-1]["projected_data"] if included_runs else get_default_state()
    )
    run_times = [float(run.get("simulated_seconds", 0.0)) for run in included_runs]
    return {
        "label": label,
        "seconds": seconds,
        "elapsed_seconds": elapsed,
        "run_count": len(included_runs),
        "purchase_count": len(included_purchases),
        "upgrades_per_run": len(included_purchases) / max(1, len(included_runs)),
        "avg_run_seconds": mean(run_times) if run_times else 0.0,
        "min_run_seconds": min(run_times) if run_times else 0.0,
        "max_run_seconds": max(run_times) if run_times else 0.0,
        "final_wallet": int(final_state.get("wallet", 0)),
        "final_player_level": int(final_state.get("player_level", 1)),
        "final_depth_unlocked": int(final_state.get("deepest_level_unlocked", 1)),
    }


def write_reports(campaign: Dict, validation: Dict) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    time_slices = [
        build_time_slice(campaign, TARGET_DEMO_SHORT_SECONDS, "20 minute demo"),
        build_time_slice(campaign, TARGET_DEMO_LONG_SECONDS, "40 minute demo"),
        build_time_slice(campaign, TARGET_FULL_SECONDS, "3 hour game"),
    ]
    summary = {
        "date_utc": now_utc(),
        "campaign": campaign,
        "validation": validation,
        "time_slices": time_slices,
    }
    (REPORT_DIR / "mining_fast_sim_results.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    md = [
        "# Mining Fast Simulation Report",
        "",
        "Source: Python fast run simulator with live Godot validation spot-checks.",
        f"Date (UTC): {summary['date_utc']}",
        "",
        "## Campaign",
        "",
        f"- Total runs: {campaign['total_runs']}",
        f"- Total purchases: {campaign['purchase_count']}",
        f"- Upgrades per run: {campaign['upgrades_per_run']:.3f}",
        f"- Full campaign time: {campaign['total_time_seconds']:.1f} sec",
        "",
        "## Time Slices",
        "",
        "| Slice | Target Time (s) | Completed Time (s) | Runs | Purchases | Upgrades/Run | Avg Run (s) | Min Run (s) | Max Run (s) | Wallet | Level | Depth |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for slice_row in time_slices:
        md.append(
            f"| {slice_row['label']} | {slice_row['seconds']:.0f} | {slice_row['elapsed_seconds']:.1f} | {slice_row['run_count']} | "
            f"{slice_row['purchase_count']} | {slice_row['upgrades_per_run']:.3f} | {slice_row['avg_run_seconds']:.2f} | "
            f"{slice_row['min_run_seconds']:.2f} | {slice_row['max_run_seconds']:.2f} | {slice_row['final_wallet']} | "
            f"{slice_row['final_player_level']} | {slice_row['final_depth_unlocked']} |"
        )
    md.extend([
        "",
        "## Validation Averages",
        "",
        f"- Seeds per checkpoint: {VALIDATION_SEEDS_PER_CHECKPOINT}",
        f"- Mean money error: {validation.get('overall', {}).get('money_avg_error_pct', 0.0):.1f}%",
        f"- Mean XP error: {validation.get('overall', {}).get('xp_avg_error_pct', 0.0):.1f}%",
        f"- Mean time error: {validation.get('overall', {}).get('simulated_seconds_avg_error_pct', 0.0):.1f}%",
        f"- Mean nodes error: {validation.get('overall', {}).get('nodes_broken_avg_error_pct', 0.0):.1f}%",
        f"- 10% gate passed: {'yes' if validation.get('overall', {}).get('passes_10pct_gate', False) else 'no'}",
        "",
        "| Checkpoint | Depth | Samples | Fast Money Avg | Live Money Avg | Money Error % | Fast XP Avg | Live XP Avg | XP Error % | Fast Time Avg | Live Time Avg | Time Error % |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ])
    for row in validation.get("checkpoint_rows", []):
        md.append(
            f"| {row['checkpoint_id']} | {row['depth_level']} | {row['sample_count']} | {row['fast_avg_money']:.1f} | {row['live_avg_money']:.1f} | {row['money_avg_error_pct']:.1f} | "
            f"{row['fast_avg_xp']:.1f} | {row['live_avg_xp']:.1f} | {row['xp_avg_error_pct']:.1f} | {row['fast_avg_simulated_seconds']:.1f} | "
            f"{row['live_avg_simulated_seconds']:.1f} | {row['simulated_seconds_avg_error_pct']:.1f} |"
        )
    md.append("")
    md.append("## Validation Samples")
    md.append("")
    md.append("| Scenario | Checkpoint | Depth | Fast Money | Live Money | Money Error % | Fast XP | Live XP | XP Error % | Fast Time | Live Time | Time Error % |")
    md.append("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for row in validation.get("scenario_rows", []):
        md.append(
            f"| {row['id']} | {row['checkpoint_id']} | {row['depth_level']} | {row['fast_money']:.1f} | {row['live_money']:.1f} | {row['money_error_pct']:.1f} | "
            f"{row['fast_xp']:.1f} | {row['live_xp']:.1f} | {row['xp_error_pct']:.1f} | {row['fast_simulated_seconds']:.1f} | "
            f"{row['live_simulated_seconds']:.1f} | {row['simulated_seconds_error_pct']:.1f} |"
        )
    md.append("")
    md.append("## Purchase Order")
    md.append("")
    md.append("| # | Run | Upgrade | Level | Cost | Depth Preview | Wallet After Spend | Cumulative Time (s) |")
    md.append("|---:|---:|---|---:|---:|---:|---:|---:|")
    for idx, purchase in enumerate(campaign["purchases"], start=1):
        md.append(
            f"| {idx} | {purchase['run_index']} | {purchase['label']} | {purchase['level']} | {purchase['cost']} | "
            f"{purchase['preview_depth_level']} | {purchase['wallet_after_spend']} | {purchase['cumulative_time_seconds']:.1f} |"
        )
    md.append("")
    md.append("## Run Breakdown")
    md.append("")
    md.append("| Run | Depth | Time (s) | Money | XP | Reason | Wallet Before Spend | Purchases After Run | Wallet After Spend |")
    md.append("|---:|---:|---:|---:|---:|---|---:|---|---:|")
    for run in campaign["runs"]:
        purchase_text = ", ".join(
            f"{purchase['id']} {purchase['level']}"
            for purchase in run.get("purchases_after_run", [])
        )
        md.append(
            f"| {run['run_index']} | {run['depth_level']} | {float(run['simulated_seconds']):.2f} | {run['money']} | {run['xp']} | "
            f"{run['reason']} | {run.get('wallet_before_spend', 0)} | {purchase_text if purchase_text else '-'} | "
            f"{run['wallet_after_spend']} |"
        )
    (REPORT_DIR / "mining_fast_sim_report.md").write_text("\n".join(md), encoding="utf-8")

    timestamp = datetime.now(timezone.utc).strftime("%Y_%m_%d_%H%M%S")
    dated_report = [
        "# Mining Run With Time And Date",
        "",
        f"Date (UTC): {summary['date_utc']}",
        f"Simulated full campaign time: {campaign['total_time_seconds']:.1f} sec",
        f"Average upgrades/run: {campaign['upgrades_per_run']:.3f}",
        "",
        "## Time Slices",
        "",
        "| Slice | Runs | Purchases | Avg Run (s) | Wallet | Level | Depth |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    for slice_row in time_slices:
        dated_report.append(
            f"| {slice_row['label']} | {slice_row['run_count']} | {slice_row['purchase_count']} | {slice_row['avg_run_seconds']:.2f} | "
            f"{slice_row['final_wallet']} | {slice_row['final_player_level']} | {slice_row['final_depth_unlocked']} |"
        )
    dated_report.extend([
        "",
        "## Upgrades Bought",
        "",
        "| # | Run | Upgrade | Level | Cost | Wallet After Spend |",
        "|---:|---:|---|---:|---:|---:|",
    ])
    for index, purchase in enumerate(campaign["purchases"], start=1):
        dated_report.append(
            f"| {index} | {purchase['run_index']} | {purchase['label']} | {purchase['level']} | {purchase['cost']} | {purchase['wallet_after_spend']} |"
        )
    dated_report.extend([
        "",
        "## Run Breakdown",
        "",
        "| Run | Depth | Time (s) | Money | XP | Wallet Before Spend | Purchases After Run | Wallet After Spend |",
        "|---:|---:|---:|---:|---:|---:|---|---:|",
    ])
    for run in campaign["runs"]:
        purchase_text = ", ".join(
            f"{purchase['label']} {purchase['level']}"
            for purchase in run.get("purchases_after_run", [])
        )
        dated_report.append(
            f"| {run['run_index']} | {run['depth_level']} | {float(run['simulated_seconds']):.2f} | {run['money']} | {run['xp']} | "
            f"{run.get('wallet_before_spend', 0)} | {purchase_text if purchase_text else '-'} | {run['wallet_after_spend']} |"
        )
    (REPORT_DIR / f"miningRunWithTimeAndDate_{timestamp}.md").write_text("\n".join(dated_report), encoding="utf-8")


def main() -> None:
    campaign = run_campaign(seed=73)
    scenarios = build_validation_scenarios(campaign)
    live_results = run_live_validation(scenarios)
    validation = compare_validation(scenarios, live_results)
    write_reports(campaign, validation)


if __name__ == "__main__":
    main()
