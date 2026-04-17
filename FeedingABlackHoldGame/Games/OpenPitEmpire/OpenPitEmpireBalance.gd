extends RefCounted
class_name OpenPitEmpireBalance

const MAX_DEPTH_LEVEL := 4
const MIN_START_DEPTH_LEVEL := 1
const GROUP_SIZE := 5

const UPGRADE_CATALOG: Array[Dictionary] = [
    {"id": "attack_damage", "label": "Autoloader", "summary": "Improves each mining shot.", "base_cost": 18, "cost_mult": 1.15, "max_level": 24, "requires": {}, "act": 1, "icon": "D"},
    {"id": "attack_speed", "label": "Fire Control", "summary": "Raises mining fire rate.", "base_cost": 22, "cost_mult": 1.15, "max_level": 22, "requires": {"attack_damage": 2}, "act": 1, "icon": "S"},
    {"id": "mining_radius", "label": "Survey Radius", "summary": "Extends target reach around the ship.", "base_cost": 16, "cost_mult": 1.14, "max_level": 18, "requires": {}, "act": 1, "icon": "R"},
    {"id": "pickup_radius", "label": "Vacuum Net", "summary": "Lets the rig scoop more drops safely.", "base_cost": 16, "cost_mult": 1.14, "max_level": 18, "requires": {"mining_radius": 1}, "act": 1, "icon": "P"},
    {"id": "move_speed", "label": "Thruster Rails", "summary": "Improves mouse steering and travel speed.", "base_cost": 18, "cost_mult": 1.14, "max_level": 18, "requires": {}, "act": 1, "icon": "M"},
    {"id": "shield_count", "label": "Crash Shields", "summary": "Adds extra mistakes before a run ends.", "base_cost": 28, "cost_mult": 1.19, "max_level": 10, "requires": {"move_speed": 2}, "act": 2, "icon": "H"},
    {"id": "salvage_keep", "label": "Recovery Claim", "summary": "Keeps part of the haul on death or timeout.", "base_cost": 26, "cost_mult": 1.16, "max_level": 12, "requires": {"pickup_radius": 2}, "act": 2, "icon": "K"},
    {"id": "multi_target", "label": "Splitter Array", "summary": "Lets the rig strike more than one block at once.", "base_cost": 30, "cost_mult": 1.16, "max_level": 14, "requires": {"attack_speed": 2}, "act": 2, "icon": "A"},
    {"id": "ore_value", "label": "Market Contracts", "summary": "Raises the cash value of every collected chunk.", "base_cost": 24, "cost_mult": 1.15, "max_level": 16, "requires": {"pickup_radius": 2}, "act": 3, "icon": "V"},
    {"id": "cargo_capacity", "label": "Hold Expansion", "summary": "Increases how much ore fits in one trip.", "base_cost": 24, "cost_mult": 1.15, "max_level": 18, "requires": {"ore_value": 1}, "act": 3, "icon": "C"},
    {"id": "layer_access", "label": "Pit Permits", "summary": "Unlocks deeper layers in the open pit.", "base_cost": 44, "cost_mult": 1.24, "max_level": 4, "requires": {"cargo_capacity": 2}, "act": 4, "icon": "L"},
    {"id": "crit_chance", "label": "Targeting Optics", "summary": "Occasionally land a critical hit.", "base_cost": 30, "cost_mult": 1.16, "max_level": 14, "requires": {"attack_damage": 3}, "act": 3, "icon": "C"},
    {"id": "explosion_chance", "label": "Blast Charges", "summary": "Killed blocks can splash nearby ore.", "base_cost": 34, "cost_mult": 1.16, "max_level": 14, "requires": {"crit_chance": 2}, "act": 4, "icon": "E"},
    {"id": "chain_chance", "label": "Arc Tethers", "summary": "Shots can jump into nearby blocks.", "base_cost": 34, "cost_mult": 1.16, "max_level": 14, "requires": {"explosion_chance": 1}, "act": 4, "icon": "J"},
    {"id": "companion_ships", "label": "Scout Wings", "summary": "Deploys helper ships that attack and collect.", "base_cost": 42, "cost_mult": 1.17, "max_level": 12, "requires": {"multi_target": 2, "cargo_capacity": 3}, "act": 5, "icon": "W"},
    {"id": "run_time", "label": "Launch Window", "summary": "Adds more seconds to each run.", "base_cost": 20, "cost_mult": 1.15, "max_level": 18, "requires": {}, "act": 1, "icon": "T"},
    {"id": "core_damage", "label": "Core Breakers", "summary": "Deals bonus damage to the deepest core layer and boss blocks.", "base_cost": 46, "cost_mult": 1.17, "max_level": 14, "requires": {"layer_access": 3, "attack_damage": 6}, "act": 5, "icon": "B"},
]

const LAYER_DATA: Array[Dictionary] = [
    {"id": "topsoil", "name": "Topsoil", "materials": ["dirt", "coal"], "value": 3, "health": 18.0, "cargo_weight": 0, "color": Color(0.49, 0.34, 0.22, 1.0), "accent": Color(0.14, 0.14, 0.14, 1.0)},
    {"id": "mid", "name": "Mid", "materials": ["iron", "copper"], "value": 9, "health": 42.0, "cargo_weight": 1, "color": Color(0.58, 0.45, 0.34, 1.0), "accent": Color(0.76, 0.46, 0.25, 1.0)},
    {"id": "deep", "name": "Deep", "materials": ["gold", "rare"], "value": 24, "health": 92.0, "cargo_weight": 1, "color": Color(0.73, 0.59, 0.18, 1.0), "accent": Color(0.22, 0.8, 0.72, 1.0)},
    {"id": "core", "name": "Core", "materials": ["exotic"], "value": 68, "health": 188.0, "cargo_weight": 2, "color": Color(0.53, 0.2, 0.18, 1.0), "accent": Color(0.85, 0.26, 0.24, 1.0)},
]

static func get_upgrade_catalog() -> Array[Dictionary]:
    var copy: Array[Dictionary] = []
    for entry in UPGRADE_CATALOG:
        copy.append(entry.duplicate(true))
    return copy

static func get_layer_for_depth(depth_level: int) -> Dictionary:
    return LAYER_DATA[clampi(depth_level - 1, 0, LAYER_DATA.size() - 1)].duplicate(true)

static func refresh_depth_unlocks(data: Dictionary) -> void:
    var upgrades: Dictionary = data.get("upgrades", {})
    var unlocked: int = clampi(max(1, int(upgrades.get("layer_access", 0))), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), unlocked)
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", data["deepest_level_unlocked"])), MIN_START_DEPTH_LEVEL, int(data["deepest_level_unlocked"]))

static func get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    for entry in UPGRADE_CATALOG:
        if str(entry.get("id", "")) != upgrade_id:
            continue
        return int(round(float(entry.get("base_cost", 0)) * pow(float(entry.get("cost_mult", 1.0)), current_level)))
    return 0

static func get_move_speed(upgrades: Dictionary) -> float:
    var level: float = float(upgrades.get("move_speed", 0))
    return 320.0 + 26.0 * level + 4.0 * pow(level, 1.2)

static func get_attack_damage(upgrades: Dictionary) -> float:
    var level: float = float(upgrades.get("attack_damage", 0))
    return 24.0 + 18.0 * level + 6.0 * pow(level, 1.24)

static func get_attack_rate(upgrades: Dictionary) -> float:
    var level: float = float(upgrades.get("attack_speed", 0))
    return 1.5 + 0.22 * level + 0.04 * pow(level, 1.15)

static func get_attack_radius(upgrades: Dictionary) -> float:
    return 96.0 + 16.0 * float(upgrades.get("mining_radius", 0))

static func get_pickup_radius(upgrades: Dictionary) -> float:
    return 62.0 + 14.0 * float(upgrades.get("pickup_radius", 0)) + 8.0 * float(get_companion_ship_count(upgrades))

static func get_shield_count(upgrades: Dictionary) -> int:
    return int(upgrades.get("shield_count", 0))

static func get_salvage_keep_percent(upgrades: Dictionary) -> float:
    var level: float = float(upgrades.get("salvage_keep", 0))
    if level <= 0.0:
        return 0.0
    return clampf(0.18 + 0.08 * level, 0.0, 0.92)

static func get_multi_target_count(upgrades: Dictionary) -> int:
    return 1 + int(floor(float(upgrades.get("multi_target", 0)) / 2.0))

static func get_value_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.18 * float(upgrades.get("ore_value", 0))

static func get_cargo_capacity(upgrades: Dictionary) -> int:
    var level: int = int(upgrades.get("cargo_capacity", 0))
    return 96 + 44 * level + 36 * int(floor(float(level) / 2.0))

static func get_run_time(upgrades: Dictionary) -> float:
    return 30.0 + 2.8 * float(upgrades.get("run_time", 0))

static func get_companion_ship_count(upgrades: Dictionary) -> int:
    var level: int = int(upgrades.get("companion_ships", 0))
    if level <= 0:
        return 0
    return int(min(6.0, ceil(float(level) / 2.0)))

static func get_companion_damage(upgrades: Dictionary) -> float:
    var level: int = int(upgrades.get("companion_ships", 0))
    if level <= 0:
        return 0.0
    return get_attack_damage(upgrades) * (0.22 + 0.07 * float(level))

static func get_companion_target_count(upgrades: Dictionary) -> int:
    return 1 + int(floor(float(upgrades.get("companion_ships", 0)) / 4.0))

static func get_crit_chance(upgrades: Dictionary) -> float:
    return min(0.62, 0.04 * float(upgrades.get("crit_chance", 0)))

static func get_crit_multiplier(upgrades: Dictionary) -> float:
    return 2.0 + 0.14 * float(upgrades.get("crit_chance", 0))

static func get_explosion_chance(upgrades: Dictionary) -> float:
    return min(0.55, 0.04 * float(upgrades.get("explosion_chance", 0)))

static func get_chain_chance(upgrades: Dictionary) -> float:
    return min(0.48, 0.035 * float(upgrades.get("chain_chance", 0)))

static func get_core_damage_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.35 * float(upgrades.get("core_damage", 0))
