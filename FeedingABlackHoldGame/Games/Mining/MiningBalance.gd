extends RefCounted
class_name MiningBalance

const MAX_DEPTH_LEVEL := 100
const MAX_UPGRADE_LEVEL := 100
const MAX_MATERIAL_TYPES_PER_LEVEL := 8
const RANK_LABEL := "Rig Rank"
const RANK_XP_LABEL := "Survey XP"
const RANK_UP_LABEL := "(RIG RANK UP!)"
const UPGRADE_EFFECT_GROUP_SIZE := 5
const EARLY_UPGRADE_LEVELS := 5
const LATE_COST_MULTIPLIER_START := 1.8
const LATE_COST_MULTIPLIER_END := 30.0
const LATE_EFFECT_MULTIPLIER_START := 1.0
const LATE_EFFECT_MULTIPLIER_END := 2.25
const LEVEL_BONUS_ROTATION: Array[Dictionary] = [
    {"id": "speed", "move_speed": 4.0},
    {"id": "drill_health", "drill_health": 8.0},
    {"id": "time", "run_time": 0.45}
]

const UPGRADE_CATALOG: Array[Dictionary] = [
    {"id": "timer_reserve", "label": "Timer Reserve", "summary": "Extends each run so upgraded rigs can squeeze in one more haul before the horn sounds.", "base_cost": 24, "cost_mult": 1.148, "max_level": 100, "requires": {}, "act": 1, "icon": "T"},
    {"id": "route_planner", "label": "Route Planner", "summary": "Trims wasted travel and stretches the timer by making each route more efficient.", "base_cost": 42, "cost_mult": 1.17, "max_level": 100, "requires": {"timer_reserve": 3}, "act": 1, "icon": "R"},
    {"id": "engine_tuning", "label": "Engine Tuning", "summary": "Boosts rig acceleration so short runs still feel punchy instead of sluggish.", "base_cost": 26, "cost_mult": 1.152, "max_level": 100, "requires": {}, "act": 1, "icon": "M"},
    {"id": "dirt_softener", "label": "Dirt Softener", "summary": "Keeps deeper layers from stealing too much speed away from the drill rig.", "base_cost": 54, "cost_mult": 1.174, "max_level": 100, "requires": {"engine_tuning": 3}, "act": 2, "icon": "S"},
    {"id": "drill_torque", "label": "Drill Torque", "summary": "Raises drilling throughput so each pass stays close to one-hit territory on the current frontier.", "base_cost": 26, "cost_mult": 1.156, "max_level": 100, "requires": {}, "act": 1, "icon": "D"},
    {"id": "drill_plating", "label": "Drill Plating", "summary": "Adds integrity to the bit so risky dives can survive tougher veins instead of folding a tier early.", "base_cost": 24, "cost_mult": 1.148, "max_level": 100, "requires": {"drill_torque": 2}, "act": 2, "icon": "H"},
    {"id": "cooling_loop", "label": "Cooling Loop", "summary": "Shaves off drill wear so health stays right on the knife edge instead of collapsing when depth pressure spikes.", "base_cost": 28, "cost_mult": 1.152, "max_level": 100, "requires": {"drill_plating": 2}, "act": 2, "icon": "K"},
    {"id": "cargo_pods", "label": "Cargo Pods", "summary": "Lets each trip carry a few more chunks before you have to dump at the surface.", "base_cost": 27, "cost_mult": 1.154, "max_level": 100, "requires": {}, "act": 1, "icon": "C"},
    {"id": "cargo_compressor", "label": "Cargo Compressor", "summary": "Packs ore tighter so every haul holds together longer before a forced dump.", "base_cost": 40, "cost_mult": 1.168, "max_level": 100, "requires": {"cargo_pods": 4}, "act": 3, "icon": "Q"},
    {"id": "ore_refinery", "label": "Ore Refinery", "summary": "Improves payout conversion so every dumped load is worth a little more.", "base_cost": 36, "cost_mult": 1.166, "max_level": 100, "requires": {"cargo_pods": 2}, "act": 2, "icon": "V"},
    {"id": "pickup_radius", "label": "Vacuum Scoop", "summary": "Widens the collection field so more of each broken node actually makes it into cargo.", "base_cost": 30, "cost_mult": 1.158, "max_level": 100, "requires": {"cargo_pods": 1}, "act": 2, "icon": "P"},
    {"id": "xp_calibration", "label": "XP Calibration", "summary": "Keeps progression climbing fast enough that new depths keep unlocking through the full run.", "base_cost": 46, "cost_mult": 1.176, "max_level": 100, "requires": {"ore_refinery": 2}, "act": 3, "icon": "X"},
    {"id": "depth_scanner", "label": "Depth Scanner", "summary": "Unlocks harder strata a little earlier when your rig can actually survive them.", "base_cost": 62, "cost_mult": 1.182, "max_level": 100, "requires": {"xp_calibration": 2}, "act": 4, "icon": "L"},
    {"id": "seismic_sonar", "label": "Seismic Sonar", "summary": "Leans each depth roll toward richer veins so later runs keep feeling like upgrades matter.", "base_cost": 60, "cost_mult": 1.182, "max_level": 100, "requires": {"depth_scanner": 2}, "act": 4, "icon": "N"},
    {"id": "magnet_drone", "label": "Salvage Drone", "summary": "Launches bots that fly out to loose ore chunks and helps counter the deeper-layer slowdown on the salvage lane.", "base_cost": 46, "cost_mult": 1.172, "max_level": 100, "requires": {"pickup_radius": 3}, "act": 4, "icon": "G"},
    {"id": "foreman_bot", "label": "Foreman Bot", "summary": "A helper bot locks onto your current node and adds steady drill pressure during the contact.", "base_cost": 56, "cost_mult": 1.18, "max_level": 100, "requires": {"drill_plating": 5, "magnet_drone": 3}, "act": 5, "icon": "F"},
    {"id": "delivery_drone", "label": "Delivery Drone", "summary": "Dispatches separate bots that ferry cargo back to the base ring while you keep drilling, offsetting the heavier drag in deeper tiers.", "base_cost": 54, "cost_mult": 1.176, "max_level": 100, "requires": {"magnet_drone": 2, "depth_scanner": 1}, "act": 5, "icon": "R"},
    {"id": "auto_sorters", "label": "Auto Sorters", "summary": "Upgrades the delivery lane so each dump drone keeps pace deeper in the mine instead of taking over too early.", "base_cost": 52, "cost_mult": 1.176, "max_level": 100, "requires": {"delivery_drone": 3}, "act": 5, "icon": "B"}
]

const BASE_MATERIAL_TIERS: Array[Dictionary] = [
    {"id": "stone", "name": "Stone", "value": 7, "xp": 6, "hardness": 24.0, "color": Color(0.49, 0.49, 0.52, 1.0), "bg": Color(0.18, 0.15, 0.13, 1.0), "sparkle": 0.0},
    {"id": "bronze", "name": "Bronze", "value": 11, "xp": 9, "hardness": 34.0, "color": Color(0.7, 0.46, 0.24, 1.0), "bg": Color(0.24, 0.16, 0.11, 1.0), "sparkle": 0.0},
    {"id": "silver", "name": "Silver", "value": 16, "xp": 13, "hardness": 46.0, "color": Color(0.76, 0.78, 0.82, 1.0), "bg": Color(0.17, 0.18, 0.22, 1.0), "sparkle": 0.08},
    {"id": "gold", "name": "Gold", "value": 23, "xp": 18, "hardness": 60.0, "color": Color(0.94, 0.78, 0.23, 1.0), "bg": Color(0.28, 0.22, 0.1, 1.0), "sparkle": 0.12},
    {"id": "diamond", "name": "Diamond", "value": 33, "xp": 25, "hardness": 78.0, "color": Color(0.55, 0.93, 1.0, 1.0), "bg": Color(0.11, 0.2, 0.24, 1.0), "sparkle": 0.18},
    {"id": "platinum_bronze", "name": "Platinum Bronze", "value": 48, "xp": 34, "hardness": 98.0, "color": Color(0.83, 0.63, 0.47, 1.0), "bg": Color(0.22, 0.17, 0.19, 1.0), "sparkle": 0.28},
    {"id": "platinum_silver", "name": "Platinum Silver", "value": 68, "xp": 45, "hardness": 122.0, "color": Color(0.92, 0.94, 1.0, 1.0), "bg": Color(0.16, 0.18, 0.24, 1.0), "sparkle": 0.34},
    {"id": "platinum_gold", "name": "Platinum Gold", "value": 94, "xp": 58, "hardness": 150.0, "color": Color(1.0, 0.86, 0.43, 1.0), "bg": Color(0.27, 0.2, 0.15, 1.0), "sparkle": 0.42},
    {"id": "platinum_diamond", "name": "Platinum Diamond", "value": 128, "xp": 74, "hardness": 182.0, "color": Color(0.72, 0.98, 1.0, 1.0), "bg": Color(0.09, 0.18, 0.28, 1.0), "sparkle": 0.5},
    {"id": "super_bronze", "name": "Super Bronze", "value": 173, "xp": 94, "hardness": 218.0, "color": Color(0.96, 0.56, 0.3, 1.0), "bg": Color(0.24, 0.12, 0.1, 1.0), "sparkle": 0.62},
    {"id": "super_silver", "name": "Super Silver", "value": 232, "xp": 119, "hardness": 258.0, "color": Color(0.96, 0.98, 1.0, 1.0), "bg": Color(0.18, 0.19, 0.28, 1.0), "sparkle": 0.72},
    {"id": "super_gold", "name": "Super Gold", "value": 308, "xp": 150, "hardness": 304.0, "color": Color(1.0, 0.91, 0.52, 1.0), "bg": Color(0.3, 0.21, 0.12, 1.0), "sparkle": 0.84},
    {"id": "super_diamond", "name": "Super Diamond", "value": 405, "xp": 188, "hardness": 356.0, "color": Color(0.81, 1.0, 1.0, 1.0), "bg": Color(0.11, 0.23, 0.31, 1.0), "sparkle": 0.98}
]

static func get_upgrade_catalog() -> Array[Dictionary]:
    var localized_catalog: Array[Dictionary] = []
    for entry in UPGRADE_CATALOG:
        localized_catalog.append(_localize_upgrade_entry(entry))
    return localized_catalog

static func get_upgrade_description(upgrade_def: Dictionary) -> String:
    var summary: String = str(upgrade_def.get("summary", "")).strip_edges()
    var effect_text: String = _build_upgrade_effect_summary(upgrade_def)
    if effect_text == "":
        return summary
    if summary == "":
        return effect_text
    return "%s\n%s" % [summary, effect_text]

static func get_material_tiers() -> Array[Dictionary]:
    var tiers: Array[Dictionary] = []
    var previous_material: Dictionary = {}
    for depth_level in range(1, MAX_DEPTH_LEVEL + 1):
        var material: Dictionary = _build_material_tier_for_depth(depth_level, previous_material)
        material = _localize_material_entry(material)
        tiers.append(material)
        previous_material = material
    return tiers

static func get_material_by_id(material_id: String) -> Dictionary:
    for material in get_material_tiers():
        if String(material.get("id", "")) == material_id:
            return material.duplicate(true)
    return _localize_material_entry(_build_material_tier_for_depth(1))

static func get_rank_label() -> String:
    return RANK_LABEL

static func get_rank_xp_label() -> String:
    return RANK_XP_LABEL

static func get_rank_up_label() -> String:
    return RANK_UP_LABEL

static func get_rank_for_total_xp(total_xp: int) -> int:
    var rank: int = 1
    var remaining_xp: int = max(0, total_xp)
    while remaining_xp >= get_rank_xp_to_next(rank):
        remaining_xp -= get_rank_xp_to_next(rank)
        rank += 1
    return rank

static func get_rank_xp_to_next(rank: int) -> int:
    var rank_value: float = float(max(rank, 1))
    return int(round(65.0 + 16.0 * rank_value + 12.5 * pow(rank_value, 1.53)))

static func get_rank_progress(data: Dictionary) -> Dictionary:
    var current_rank: int = _get_rank_value(data)
    var total_rank_xp: int = _get_rank_xp_value(data)
    var spent_xp: int = 0
    for rank in range(1, current_rank):
        spent_xp += get_rank_xp_to_next(rank)
    var current_rank_xp: int = max(0, total_rank_xp - spent_xp)
    var next_rank_cost: int = get_rank_xp_to_next(current_rank)
    return {
        "current_rank": current_rank,
        "current_xp": current_rank_xp,
        "next_rank_xp": next_rank_cost,
        "current_level": current_rank,
        "next_level_xp": next_rank_cost
    }

static func get_level_for_total_xp(total_xp: int) -> int:
    return get_rank_for_total_xp(total_xp)

static func get_xp_to_next_level(level: int) -> int:
    return get_rank_xp_to_next(level)

static func get_level_progress(data: Dictionary) -> Dictionary:
    return get_rank_progress(data)

static func refresh_depth_unlocks(data: Dictionary) -> void:
    var player_level: int = _get_rank_value(data)
    var scanner_level: int = int(data.get("upgrades", {}).get("depth_scanner", 0))
    var unlocked_depth: int = 1 + int(floor(float(player_level + 1) / 3.2)) + int(floor(float(scanner_level) * 0.7))
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), clampi(unlocked_depth, 1, MAX_DEPTH_LEVEL))
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", data["deepest_level_unlocked"])), 1, int(data["deepest_level_unlocked"]))

static func get_level_bonus_for_level(level: int) -> Dictionary:
    if level <= 1 or LEVEL_BONUS_ROTATION.is_empty():
        return {}
    var rotation_index: int = posmod(level - 2, LEVEL_BONUS_ROTATION.size())
    return LEVEL_BONUS_ROTATION[rotation_index].duplicate(true)

static func get_level_bonus_totals_for_level(player_level: int) -> Dictionary:
    return get_level_bonus_totals_for_range(1, player_level)

static func get_level_bonus_totals_for_range(previous_level: int, new_level: int) -> Dictionary:
    var totals := {
        "move_speed": 0.0,
        "drill_health": 0.0,
        "run_time": 0.0
    }
    if new_level <= previous_level:
        return totals
    for level in range(max(2, previous_level + 1), max(2, new_level) + 1):
        var bonus: Dictionary = get_level_bonus_for_level(level)
        totals["move_speed"] = float(totals.get("move_speed", 0.0)) + float(bonus.get("move_speed", 0.0))
        totals["drill_health"] = float(totals.get("drill_health", 0.0)) + float(bonus.get("drill_health", 0.0))
        totals["run_time"] = float(totals.get("run_time", 0.0)) + float(bonus.get("run_time", 0.0))
    return totals

static func get_move_speed(upgrades: Dictionary, level_bonuses: Dictionary = {}) -> float:
    return 210.0 + 0.84 * get_scaled_upgrade_strength(upgrades, "engine_tuning") + 0.14 * get_scaled_upgrade_strength(upgrades, "route_planner") + float(level_bonuses.get("move_speed", 0.0))

static func get_dirt_drag_multiplier(depth_level: int, upgrades: Dictionary) -> float:
    var base_drag: float = 0.98 - 0.028 * float(max(0, depth_level - 1))
    base_drag += 0.0035 * get_scaled_upgrade_strength(upgrades, "dirt_softener")
    base_drag += 0.001 * get_scaled_upgrade_strength(upgrades, "route_planner")
    return clampf(base_drag, 0.42, 1.0)

static func get_run_time_limit(upgrades: Dictionary, level_bonuses: Dictionary = {}) -> float:
    return 22.0 + 0.65 * get_scaled_upgrade_strength(upgrades, "timer_reserve") + float(level_bonuses.get("run_time", 0.0))

static func get_time_drain_rate(depth_level: int, upgrades: Dictionary) -> float:
    var drain: float = 1.0 + 0.038 * float(max(0, depth_level - 1))
    drain -= 0.012 * get_scaled_upgrade_strength(upgrades, "route_planner")
    return clampf(drain, 0.68, 2.2)

static func get_drill_dps(upgrades: Dictionary) -> float:
    return 7.4 + 1.12 * get_scaled_upgrade_strength(upgrades, "drill_torque") + 0.12 * get_scaled_upgrade_strength(upgrades, "cooling_loop") + 0.72 * get_scaled_upgrade_strength(upgrades, "foreman_bot")

static func get_drill_health_max(upgrades: Dictionary, level_bonuses: Dictionary = {}) -> float:
    return 54.0 + 9.0 * get_scaled_upgrade_strength(upgrades, "drill_plating") + float(level_bonuses.get("drill_health", 0.0))

static func get_drill_wear_multiplier(upgrades: Dictionary) -> float:
    return clampf(1.0 - 0.0115 * get_scaled_upgrade_strength(upgrades, "cooling_loop"), 0.2, 1.0)

static func get_cargo_capacity(upgrades: Dictionary) -> int:
    return 4 + int(round(get_scaled_upgrade_strength(upgrades, "cargo_pods"))) + int(floor(get_scaled_upgrade_strength(upgrades, "cargo_compressor") / 3.0))

static func get_material_cargo_space(material: Dictionary) -> int:
    var value: float = float(material.get("value", 1))
    var normalized_value: float = max(1.0, value / 260.0)
    return clampi(1 + int(floor(log(normalized_value) / log(2.6))), 1, 5)

static func get_value_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.03 * get_scaled_upgrade_strength(upgrades, "ore_refinery") + 0.008 * get_scaled_upgrade_strength(upgrades, "cargo_compressor")

static func get_xp_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.035 * get_scaled_upgrade_strength(upgrades, "xp_calibration")

static func get_pickup_radius(upgrades: Dictionary) -> float:
    return 18.0 + 2.7 * get_scaled_upgrade_strength(upgrades, "pickup_radius") + 1.6 * get_scaled_upgrade_strength(upgrades, "magnet_drone")

static func get_pickup_drone_count(upgrades: Dictionary) -> int:
    var strength: float = get_scaled_upgrade_strength(upgrades, "magnet_drone")
    if strength <= 0.0:
        return 0
    return 1 + int(floor(max(0.0, strength - 1.0) / 5.0))

static func get_delivery_drone_count(upgrades: Dictionary) -> int:
    var strength: float = get_scaled_upgrade_strength(upgrades, "delivery_drone")
    if strength <= 0.0:
        return 0
    return 1 + int(floor(max(0.0, strength - 1.0) / 4.0))

static func get_delivery_drone_speed(depth_level: int, upgrades: Dictionary) -> float:
    var base_speed: float = 38.0 + 1.05 * get_scaled_upgrade_strength(upgrades, "delivery_drone") + 0.5 * get_scaled_upgrade_strength(upgrades, "auto_sorters")
    return max(5.0, base_speed * get_delivery_drone_depth_drag(depth_level))

static func get_pickup_drone_speed(depth_level: int, upgrades: Dictionary) -> float:
    var base_speed: float = 248.0 + 5.0 * get_scaled_upgrade_strength(upgrades, "magnet_drone")
    return max(86.0, base_speed * get_pickup_drone_depth_drag(depth_level))

static func get_delivery_drone_depth_drag(depth_level: int) -> float:
    return clampf(1.0 - 0.032 * float(max(0, depth_level - 1)), 0.22, 1.0)

static func get_pickup_drone_depth_drag(depth_level: int) -> float:
    return clampf(1.0 - 0.022 * float(max(0, depth_level - 1)), 0.46, 1.0)

static func get_delivery_dispatch_window(upgrades: Dictionary) -> float:
    return clampf(5.65 - 0.09 * get_scaled_upgrade_strength(upgrades, "delivery_drone") - 0.04 * get_scaled_upgrade_strength(upgrades, "auto_sorters"), 0.9, 5.65)

static func get_delivery_cargo_space_per_dispatch(upgrades: Dictionary) -> int:
    return 2 + int(floor(get_scaled_upgrade_strength(upgrades, "auto_sorters") / 5.0))

static func get_material_weights(available_tiers: int, upgrades: Dictionary) -> Array[float]:
    if available_tiers <= 1:
        return [1.0]
    var sonar_level: float = float(upgrades.get("seismic_sonar", 0))
    var frontier_pressure: float = clampf((float(available_tiers) - 20.0) / 24.0, 0.0, 1.0)
    var weights: Array[float] = []
    for index in range(available_tiers):
        var weight: float = 1.0 + float(index == 0) * 4.0
        if index == available_tiers - 1:
            weight = 7.3 + sonar_level * 0.55
        elif index == available_tiers - 2:
            weight = 3.0 + sonar_level * 0.24
        elif index <= available_tiers - 3:
            weight = max(0.5, weight - sonar_level * 0.05)
        if frontier_pressure > 0.0:
            if index == available_tiers - 1:
                weight *= 1.0 + 1.0 * frontier_pressure
            elif index == available_tiers - 2:
                weight *= 1.0 + 0.55 * frontier_pressure
            elif index == available_tiers - 3:
                weight *= 1.0 + 0.25 * frontier_pressure
            elif index == 0:
                weight *= 1.0 - 0.45 * frontier_pressure
            else:
                weight *= 1.0 - 0.12 * frontier_pressure
        weights.append(weight)
    return weights

static func get_material_pool_indices(available_tiers: int) -> Array[int]:
    var capped_tiers: int = max(1, available_tiers)
    if capped_tiers <= MAX_MATERIAL_TYPES_PER_LEVEL:
        var all_indices: Array[int] = []
        for index in range(capped_tiers):
            all_indices.append(index)
        return all_indices

    var recent_count: int = min(5, MAX_MATERIAL_TYPES_PER_LEVEL - 1)
    var recent_start: int = max(0, capped_tiers - recent_count)
    var anchor_count: int = MAX_MATERIAL_TYPES_PER_LEVEL - recent_count
    var anchor_limit: int = max(1, recent_start)
    var indices: Array[int] = []
    for anchor_index in range(anchor_count):
        var progress: float = 0.0
        if anchor_count > 1:
            progress = float(anchor_index) / float(anchor_count - 1)
        var selected_index: int = int(round(progress * float(anchor_limit - 1)))
        if indices.is_empty() or indices[indices.size() - 1] != selected_index:
            indices.append(selected_index)
    for recent_index in range(recent_start, capped_tiers):
        if not indices.has(recent_index):
            indices.append(recent_index)
    return indices

static func get_material_weights_for_indices(indices: Array[int], upgrades: Dictionary) -> Array[float]:
    if indices.is_empty():
        return [1.0]
    var weights_by_tier: Array[float] = get_material_weights(indices[indices.size() - 1] + 1, upgrades)
    var pool_size: int = indices.size()
    var weights: Array[float] = []
    for pool_index in range(pool_size):
        var tier_index: int = indices[pool_index]
        var weight: float = float(weights_by_tier[tier_index])
        var recency_progress: float = float(pool_index + 1) / float(pool_size)
        if pool_index >= pool_size - min(3, pool_size):
            weight *= 1.15 + recency_progress * 0.35
        elif pool_index == 0:
            weight *= 0.9
        else:
            weight *= 0.95 + recency_progress * 0.15
        weights.append(weight)
    return weights

static func get_drop_count_for_node(node: Dictionary) -> int:
    var value: float = float(node.get("value", 1))
    return clampi(1 + int(floor(sqrt(value) / 8.5)), 1, 5)

static func get_node_health(material: Dictionary, depth_level: int) -> float:
    var hardness: float = float(material.get("hardness", 24.0))
    return hardness * (1.0 + 0.0205 * float(max(0, depth_level - 1)))

static func get_node_wear_per_second(node: Dictionary, upgrades: Dictionary) -> float:
    var wear: float = 2.3 + float(node.get("max_health", 20.0)) * 0.049
    return wear * get_drill_wear_multiplier(upgrades)

static func get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    for upgrade_def in UPGRADE_CATALOG:
        if String(upgrade_def.get("id", "")) == upgrade_id:
            var base_cost: float = float(upgrade_def.get("base_cost", 0))
            var cost_mult: float = float(upgrade_def.get("cost_mult", 1.0))
            var level_to_buy: int = current_level + 1
            var late_mult: float = get_late_upgrade_multiplier(level_to_buy, int(upgrade_def.get("max_level", MAX_UPGRADE_LEVEL)))
            return int(round(base_cost * pow(cost_mult, current_level) * late_mult))
    return 0

static func get_scaled_upgrade_strength(upgrades: Dictionary, upgrade_id: String) -> float:
    var owned_level: int = int(upgrades.get(upgrade_id, 0))
    return _get_scaled_level_total(owned_level, _get_upgrade_max_level(upgrade_id))

static func get_upgrade_effect_multiplier(level: int, max_level: int = MAX_UPGRADE_LEVEL) -> float:
    var grouped_level: int = _group_start_level(level)
    if grouped_level <= EARLY_UPGRADE_LEVELS:
        return 1.0
    var late_levels: int = max(1, max_level - EARLY_UPGRADE_LEVELS)
    var progress: float = float(grouped_level - EARLY_UPGRADE_LEVELS - 1) / float(late_levels - 1 if late_levels > 1 else 1)
    return lerpf(LATE_EFFECT_MULTIPLIER_START, LATE_EFFECT_MULTIPLIER_END, clampf(progress, 0.0, 1.0))

static func get_late_upgrade_multiplier(level: int, max_level: int = MAX_UPGRADE_LEVEL) -> float:
    if level <= EARLY_UPGRADE_LEVELS:
        return 1.0
    var late_levels: int = max(1, max_level - EARLY_UPGRADE_LEVELS)
    var progress: float = float(level - EARLY_UPGRADE_LEVELS - 1) / float(late_levels - 1 if late_levels > 1 else 1)
    return lerpf(LATE_COST_MULTIPLIER_START, LATE_COST_MULTIPLIER_END, clampf(progress, 0.0, 1.0))

static func _get_scaled_level_total(level: int, max_level: int) -> float:
    var total: float = 0.0
    for tier_level in range(1, level + 1):
        total += get_upgrade_effect_multiplier(tier_level, max_level)
    return total

static func _get_upgrade_max_level(upgrade_id: String) -> int:
    for upgrade_def in UPGRADE_CATALOG:
        if String(upgrade_def.get("id", "")) == upgrade_id:
            return int(upgrade_def.get("max_level", MAX_UPGRADE_LEVEL))
    return MAX_UPGRADE_LEVEL

static func _build_upgrade_effect_summary(upgrade_def: Dictionary) -> String:
    var upgrade_key: String = str(upgrade_def.get("key", upgrade_def.get("id", "")))
    if upgrade_key == "":
        return ""
    var start_level: int = max(1, int(upgrade_def.get("level", 1)))
    var tier_count: int = max(1, int(upgrade_def.get("max_tier", 1)))
    var end_level: int = start_level + tier_count - 1
    var prefix: String = _translate("MINING_EFFECT_THIS_LEVEL") if tier_count == 1 else _translate("MINING_EFFECT_EACH_LEVEL_GROUP")
    var effect_text: String = _describe_upgrade_level_effect(upgrade_key, start_level)
    if tier_count <= 1:
        return "%s %s" % [prefix, effect_text]
    return "%s %s%s" % [prefix, effect_text, _trf("MINING_EFFECT_LEVEL_RANGE", [start_level, end_level])]

static func _describe_upgrade_level_effect(upgrade_key: String, level: int) -> String:
    var strength_delta: float = get_upgrade_effect_multiplier(level, _get_upgrade_max_level(upgrade_key))
    match upgrade_key:
        "timer_reserve":
            return _format_effect_list([
                _trf("MINING_EFFECT_RUN_TIME", [_format_number(0.65 * strength_delta)])
            ])
        "route_planner":
            return _format_effect_list([
                _trf("MINING_EFFECT_MOVE_SPEED", [_format_number(0.14 * strength_delta)]),
                _trf("MINING_EFFECT_DIRT_SPEED_MULT", [_format_number(0.1 * strength_delta)]),
                _trf("MINING_EFFECT_TIMER_DRAIN", [_format_number(1.2 * strength_delta)])
            ])
        "engine_tuning":
            return _format_effect_list([
                _trf("MINING_EFFECT_MOVE_SPEED", [_format_number(0.84 * strength_delta)])
            ])
        "dirt_softener":
            return _format_effect_list([
                _trf("MINING_EFFECT_DIRT_SPEED_MULT", [_format_number(0.35 * strength_delta)])
            ])
        "drill_torque":
            return _format_effect_list([
                _trf("MINING_EFFECT_DRILL_DPS", [_format_number(1.12 * strength_delta)])
            ])
        "drill_plating":
            return _format_effect_list([
                _trf("MINING_EFFECT_DRILL_HEALTH", [_format_number(9.0 * strength_delta)])
            ])
        "cooling_loop":
            return _format_effect_list([
                _trf("MINING_EFFECT_DRILL_DPS", [_format_number(0.12 * strength_delta)]),
                _trf("MINING_EFFECT_DRILL_WEAR", [_format_number(1.15 * strength_delta)])
            ])
        "cargo_pods":
            return _describe_cargo_pods_level(level)
        "cargo_compressor":
            return _describe_cargo_compressor_level(level)
        "ore_refinery":
            return _format_effect_list([
                _trf("MINING_EFFECT_ORE_VALUE", [_format_number(3.0 * strength_delta)])
            ])
        "pickup_radius":
            return _format_effect_list([
                _trf("MINING_EFFECT_PICKUP_RADIUS", [_format_number(2.7 * strength_delta)])
            ])
        "xp_calibration":
            return _format_effect_list([
                _trf("MINING_EFFECT_XP_GAIN", [_format_number(3.5 * strength_delta)])
            ])
        "depth_scanner":
            return _format_effect_list([
                _translate("MINING_EFFECT_MAX_UNLOCKED_DEPTH")
            ])
        "seismic_sonar":
            return _format_effect_list([
                _translate("MINING_EFFECT_TOP_TIER_ORE_WEIGHT"),
                _translate("MINING_EFFECT_NEAR_TOP_ORE_WEIGHT"),
                _translate("MINING_EFFECT_OLDER_TIER_WEIGHT")
            ])
        "magnet_drone":
            return _describe_magnet_drone_level(level)
        "foreman_bot":
            return _format_effect_list([
                _trf("MINING_EFFECT_DRILL_DPS", [_format_number(0.72 * strength_delta)])
            ])
        "delivery_drone":
            return _describe_delivery_drone_level(level)
        "auto_sorters":
            return _describe_auto_sorters_level(level)
        _:
            return _translate("MINING_EFFECT_UNLOCK_ONLY")

static func _describe_cargo_pods_level(level: int) -> String:
    var before: Dictionary = {"cargo_pods": max(0, level - 1)}
    var after: Dictionary = {"cargo_pods": level}
    var cargo_delta: int = get_cargo_capacity(after) - get_cargo_capacity(before)
    return _format_effect_list([
        _pluralize_effect(
            cargo_delta,
            "MINING_EFFECT_CARGO_SLOT_ONE",
            "MINING_EFFECT_CARGO_SLOT_MANY"
        )
    ])

static func _describe_cargo_compressor_level(level: int) -> String:
    var before: Dictionary = {"cargo_compressor": max(0, level - 1)}
    var after: Dictionary = {"cargo_compressor": level}
    var cargo_delta: int = get_cargo_capacity(after) - get_cargo_capacity(before)
    var value_delta: float = (get_value_multiplier(after) - get_value_multiplier(before)) * 100.0
    var effect_parts: Array = []
    if cargo_delta > 0:
        effect_parts.append(_pluralize_effect(
            cargo_delta,
            "MINING_EFFECT_CARGO_SLOT_ONE",
            "MINING_EFFECT_CARGO_SLOT_MANY"
        ))
    effect_parts.append(_trf("MINING_EFFECT_ORE_VALUE", [_format_number(value_delta)]))
    return _format_effect_list(effect_parts)

static func _describe_magnet_drone_level(level: int) -> String:
    var before: Dictionary = {"magnet_drone": max(0, level - 1)}
    var after: Dictionary = {"magnet_drone": level}
    var effect_parts: Array = [
        _trf("MINING_EFFECT_PICKUP_RADIUS", [_format_number(get_pickup_radius(after) - get_pickup_radius(before))]),
        _trf("MINING_EFFECT_SALVAGE_LANE_SPEED", [_format_number((248.0 + 5.0 * get_scaled_upgrade_strength(after, "magnet_drone")) - (248.0 + 5.0 * get_scaled_upgrade_strength(before, "magnet_drone")))])
    ]
    var drone_delta: int = get_pickup_drone_count(after) - get_pickup_drone_count(before)
    if drone_delta > 0:
        effect_parts.append(_pluralize_effect(
            drone_delta,
            "MINING_EFFECT_SALVAGE_DRONE_ONE",
            "MINING_EFFECT_SALVAGE_DRONE_MANY"
        ))
    return _format_effect_list(effect_parts)

static func _describe_delivery_drone_level(level: int) -> String:
    var before: Dictionary = {"delivery_drone": max(0, level - 1)}
    var after: Dictionary = {"delivery_drone": level}
    var effect_parts: Array = [
        _trf("MINING_EFFECT_DELIVERY_LANE_SPEED", [_format_number((38.0 + 1.05 * get_scaled_upgrade_strength(after, "delivery_drone")) - (38.0 + 1.05 * get_scaled_upgrade_strength(before, "delivery_drone")))]),
        _trf("MINING_EFFECT_DISPATCH_WINDOW", [_format_number(get_delivery_dispatch_window(before) - get_delivery_dispatch_window(after))])
    ]
    var drone_delta: int = get_delivery_drone_count(after) - get_delivery_drone_count(before)
    if drone_delta > 0:
        effect_parts.append(_pluralize_effect(
            drone_delta,
            "MINING_EFFECT_DELIVERY_DRONE_ONE",
            "MINING_EFFECT_DELIVERY_DRONE_MANY"
        ))
    return _format_effect_list(effect_parts)

static func _describe_auto_sorters_level(level: int) -> String:
    var before: Dictionary = {"auto_sorters": max(0, level - 1)}
    var after: Dictionary = {"auto_sorters": level}
    var effect_parts: Array = [
        _trf("MINING_EFFECT_DELIVERY_LANE_SPEED", [_format_number((38.0 + 0.5 * get_scaled_upgrade_strength(after, "auto_sorters")) - (38.0 + 0.5 * get_scaled_upgrade_strength(before, "auto_sorters")))]),
        _trf("MINING_EFFECT_DISPATCH_WINDOW", [_format_number(get_delivery_dispatch_window(before) - get_delivery_dispatch_window(after))])
    ]
    var cargo_delta: int = get_delivery_cargo_space_per_dispatch(after) - get_delivery_cargo_space_per_dispatch(before)
    if cargo_delta > 0:
        effect_parts.append(_trf("MINING_EFFECT_CARGO_SPACE_PER_DISPATCH", [cargo_delta]))
    return _format_effect_list(effect_parts)

static func _format_effect_list(effect_parts: Array) -> String:
    return ", ".join(effect_parts)

static func _pluralize_effect(amount: int, singular_key: String, plural_key: String) -> String:
    return _trf(singular_key if amount == 1 else plural_key, [amount])

static func _format_number(value: float) -> String:
    var rounded: float = snappedf(value, 0.01)
    if is_equal_approx(rounded, round(rounded)):
        return str(int(round(rounded)))
    var text: String = "%.2f" % rounded
    while text.contains(".") and (text.ends_with("0") or text.ends_with(".")):
        text = text.left(text.length() - 1)
    return text

static func _group_start_level(level: int) -> int:
    return (int(floor(float(max(level, 1) - 1) / float(UPGRADE_EFFECT_GROUP_SIZE))) * UPGRADE_EFFECT_GROUP_SIZE) + 1

static func _translate(key: String) -> String:
    return TranslationServer.translate(key)

static func _trf(key: String, args: Array = []) -> String:
    var translated: String = _translate(key)
    for index in range(args.size()):
        translated = translated.replace("{%d}" % index, str(args[index]))
    return translated

static func _localize_upgrade_entry(entry: Dictionary) -> Dictionary:
    var localized: Dictionary = entry.duplicate(true)
    var upgrade_id: String = str(entry.get("id", "")).strip_edges()
    if upgrade_id.is_empty():
        return localized
    localized["label"] = _translate("MINING_UPGRADE_%s_NAME" % upgrade_id.to_upper())
    localized["summary"] = _translate("MINING_UPGRADE_%s_SUMMARY" % upgrade_id.to_upper())
    return localized

static func _localize_material_entry(entry: Dictionary) -> Dictionary:
    var localized: Dictionary = entry.duplicate(true)
    var material_id: String = str(entry.get("id", "")).strip_edges()
    if material_id.is_empty():
        return localized

    var base_material_id: String = material_id
    var cycle_number: int = -1
    var id_parts: PackedStringArray = material_id.split("_")
    if id_parts.size() > 1 and id_parts[id_parts.size() - 1].is_valid_int():
        cycle_number = int(id_parts[id_parts.size() - 1])
        id_parts.remove_at(id_parts.size() - 1)
        base_material_id = "_".join(id_parts)

    var base_name_key := "MINING_MATERIAL_%s_NAME" % base_material_id.to_upper()
    var base_name: String = _translate(base_name_key)
    localized["name"] = base_name if cycle_number <= 1 else _trf("MINING_MATERIAL_CYCLE_FORMAT", [base_name, cycle_number])
    return localized

static func _get_rank_value(data: Dictionary) -> int:
    return max(1, int(data.get("rig_rank", data.get("player_level", 1))))

static func _get_rank_xp_value(data: Dictionary) -> int:
    return max(0, int(data.get("rig_xp", data.get("xp", 0))))

static func _build_material_tier_for_depth(depth_level: int, previous_material: Dictionary = {}) -> Dictionary:
    var base_count: int = BASE_MATERIAL_TIERS.size()
    var base_index: int = clampi(depth_level - 1, 0, base_count - 1)
    if depth_level <= base_count:
        return BASE_MATERIAL_TIERS[base_index].duplicate(true)

    var loop_index: int = (depth_level - 1) % base_count
    var cycle_number: int = 1 + int(floor(float(depth_level - 1) / float(base_count)))
    var base_material: Dictionary = BASE_MATERIAL_TIERS[loop_index].duplicate(true)
    if previous_material.is_empty():
        previous_material = _build_material_tier_for_depth(depth_level - 1)
    var late_frontier_bonus: float = min(0.02, 0.001 * float(max(0, depth_level - 20)))
    var sparkle_bonus: float = min(0.44, 0.03 * float(max(0, cycle_number - 1)))
    base_material["id"] = "%s_%d" % [String(base_material.get("id", "ore")), cycle_number]
    base_material["name"] = "%s %d" % [String(base_material.get("name", "Ore")), cycle_number]
    base_material["value"] = int(round(float(previous_material.get("value", base_material.get("value", 1))) * (1.072 + late_frontier_bonus)))
    base_material["xp"] = int(round(float(previous_material.get("xp", base_material.get("xp", 1))) * 1.069))
    base_material["hardness"] = float(previous_material.get("hardness", base_material.get("hardness", 24.0))) * 1.081

    var ore_color: Color = base_material.get("color", Color.WHITE)
    var bg_color: Color = base_material.get("bg", Color(0.1, 0.1, 0.1, 1.0))
    var hue_wobble: float = 0.015 * float(max(0, cycle_number - 1))
    base_material["color"] = Color.from_hsv(
        fposmod(ore_color.h + hue_wobble, 1.0),
        clampf(ore_color.s * (0.98 + 0.02 * float(max(0, cycle_number - 1))), 0.0, 1.0),
        clampf(ore_color.v * (1.0 + 0.02 * float(max(0, cycle_number - 1))), 0.0, 1.0),
        1.0
    )
    base_material["bg"] = Color.from_hsv(
        fposmod(bg_color.h + hue_wobble * 0.5, 1.0),
        clampf(bg_color.s * (1.0 + 0.03 * float(max(0, cycle_number - 1))), 0.0, 1.0),
        clampf(bg_color.v * (0.97 + 0.012 * float(max(0, cycle_number - 1))), 0.0, 1.0),
        1.0
    )
    base_material["sparkle"] = clampf(float(base_material.get("sparkle", 0.0)) + sparkle_bonus, 0.0, 1.5)
    return base_material
