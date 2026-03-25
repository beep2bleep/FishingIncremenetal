extends RefCounted
class_name MiningBalance

const MAX_DEPTH_LEVEL := 100
const MAX_UPGRADE_LEVEL := 100
const MAX_MATERIAL_TYPES_PER_LEVEL := 8
const EARLY_UPGRADE_LEVELS := 5
const LATE_COST_MULTIPLIER_START := 2.0
const LATE_COST_MULTIPLIER_END := 30.0

const UPGRADE_CATALOG: Array[Dictionary] = [
    {"id": "timer_reserve", "label": "Timer Reserve", "summary": "Extends each run so upgraded rigs can squeeze in one more haul before the horn sounds.", "base_cost": 18, "cost_mult": 1.14, "max_level": 100, "requires": {}, "act": 1, "icon": "T"},
    {"id": "route_planner", "label": "Route Planner", "summary": "Trims wasted travel and stretches the timer by making each route more efficient.", "base_cost": 58, "cost_mult": 1.19, "max_level": 100, "requires": {"timer_reserve": 4}, "act": 1, "icon": "R"},
    {"id": "engine_tuning", "label": "Engine Tuning", "summary": "Boosts rig acceleration so short runs still feel punchy instead of sluggish.", "base_cost": 54, "cost_mult": 1.185, "max_level": 100, "requires": {}, "act": 1, "icon": "M"},
    {"id": "dirt_softener", "label": "Dirt Softener", "summary": "Keeps deeper layers from stealing too much speed away from the drill rig.", "base_cost": 140, "cost_mult": 1.225, "max_level": 100, "requires": {"engine_tuning": 4}, "act": 2, "icon": "S"},
    {"id": "drill_torque", "label": "Drill Torque", "summary": "Raises drilling throughput so each pass breaks more rock before the timer runs dry.", "base_cost": 20, "cost_mult": 1.142, "max_level": 100, "requires": {}, "act": 1, "icon": "D"},
    {"id": "drill_plating", "label": "Drill Plating", "summary": "Adds integrity to the bit so risky dives can survive tougher veins.", "base_cost": 22, "cost_mult": 1.146, "max_level": 100, "requires": {"drill_torque": 2}, "act": 2, "icon": "H"},
    {"id": "cooling_loop", "label": "Cooling Loop", "summary": "Shaves off drill wear so health stays right on the edge instead of collapsing instantly.", "base_cost": 25, "cost_mult": 1.149, "max_level": 100, "requires": {"drill_plating": 2}, "act": 2, "icon": "K"},
    {"id": "cargo_pods", "label": "Cargo Pods", "summary": "Lets each trip carry a few more chunks before you have to dump at the surface.", "base_cost": 21, "cost_mult": 1.143, "max_level": 100, "requires": {}, "act": 1, "icon": "C"},
    {"id": "cargo_compressor", "label": "Cargo Compressor", "summary": "Packs ore tighter so every haul holds together longer before a forced dump.", "base_cost": 29, "cost_mult": 1.156, "max_level": 100, "requires": {"cargo_pods": 6}, "act": 3, "icon": "Q"},
    {"id": "ore_refinery", "label": "Ore Refinery", "summary": "Improves payout conversion so every dumped load is worth a little more.", "base_cost": 24, "cost_mult": 1.148, "max_level": 100, "requires": {"cargo_pods": 2}, "act": 2, "icon": "V"},
    {"id": "pickup_radius", "label": "Vacuum Scoop", "summary": "Widens the collection field so more of each broken node actually makes it into cargo.", "base_cost": 23, "cost_mult": 1.146, "max_level": 100, "requires": {"cargo_pods": 1}, "act": 2, "icon": "P"},
    {"id": "xp_calibration", "label": "XP Calibration", "summary": "Keeps progression climbing fast enough that new depths keep unlocking through the full run.", "base_cost": 27, "cost_mult": 1.152, "max_level": 100, "requires": {"ore_refinery": 2}, "act": 3, "icon": "X"},
    {"id": "depth_scanner", "label": "Depth Scanner", "summary": "Unlocks harder strata a little earlier when your rig can actually survive them.", "base_cost": 34, "cost_mult": 1.162, "max_level": 100, "requires": {"xp_calibration": 2}, "act": 4, "icon": "L"},
    {"id": "seismic_sonar", "label": "Seismic Sonar", "summary": "Leans each depth roll toward richer veins so later runs keep feeling like upgrades matter.", "base_cost": 37, "cost_mult": 1.168, "max_level": 100, "requires": {"depth_scanner": 2}, "act": 4, "icon": "N"},
    {"id": "magnet_drone", "label": "Salvage Drone", "summary": "Launches bots that fly out to loose ore chunks so the player can stay on drilling lines.", "base_cost": 39, "cost_mult": 1.17, "max_level": 100, "requires": {"pickup_radius": 4}, "act": 4, "icon": "G"},
    {"id": "foreman_bot", "label": "Foreman Bot", "summary": "A helper bot locks onto your current node and adds steady drill pressure during the contact.", "base_cost": 41, "cost_mult": 1.172, "max_level": 100, "requires": {"drill_plating": 6, "magnet_drone": 4}, "act": 5, "icon": "F"},
    {"id": "delivery_drone", "label": "Delivery Drone", "summary": "Dispatches separate bots that ferry cargo back to the base ring while you keep drilling.", "base_cost": 46, "cost_mult": 1.178, "max_level": 100, "requires": {"magnet_drone": 2, "depth_scanner": 1}, "act": 5, "icon": "R"},
    {"id": "auto_sorters", "label": "Auto Sorters", "summary": "Upgrades the delivery lane so each dump drone hauls more before it has to turn around.", "base_cost": 45, "cost_mult": 1.176, "max_level": 100, "requires": {"delivery_drone": 4}, "act": 5, "icon": "B"}
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
    return UPGRADE_CATALOG.duplicate(true)

static func get_upgrade_description(upgrade_def: Dictionary) -> String:
    var summary: String = str(upgrade_def.get("summary", "")).strip_edges()
    var effect_lines: Array = _build_upgrade_effect_lines(upgrade_def)
    if effect_lines.is_empty():
        return summary
    var effect_text: String = PackedStringArray(effect_lines).join("\n")
    if summary == "":
        return effect_text
    return "%s\n%s" % [summary, effect_text]

static func get_material_tiers() -> Array[Dictionary]:
    var tiers: Array[Dictionary] = []
    for depth_level in range(1, MAX_DEPTH_LEVEL + 1):
        tiers.append(_build_material_tier_for_depth(depth_level))
    return tiers

static func get_material_by_id(material_id: String) -> Dictionary:
    for material in get_material_tiers():
        if String(material.get("id", "")) == material_id:
            return material.duplicate(true)
    return _build_material_tier_for_depth(1)

static func get_level_for_total_xp(total_xp: int) -> int:
    var level: int = 1
    var remaining_xp: int = max(0, total_xp)
    while remaining_xp >= get_xp_to_next_level(level):
        remaining_xp -= get_xp_to_next_level(level)
        level += 1
    return level

static func get_xp_to_next_level(level: int) -> int:
    var level_value: float = float(max(level, 1))
    return int(round(30.0 + 10.0 * level_value + 6.5 * pow(level_value, 1.42)))

static func get_level_progress(data: Dictionary) -> Dictionary:
    var current_level: int = max(1, int(data.get("player_level", 1)))
    var total_xp: int = max(0, int(data.get("xp", 0)))
    var spent_xp: int = 0
    for level in range(1, current_level):
        spent_xp += get_xp_to_next_level(level)
    var current_level_xp: int = max(0, total_xp - spent_xp)
    var next_level_cost: int = get_xp_to_next_level(current_level)
    return {
        "current_level": current_level,
        "current_xp": current_level_xp,
        "next_level_xp": next_level_cost
    }

static func refresh_depth_unlocks(data: Dictionary) -> void:
    var player_level: int = max(1, int(data.get("player_level", 1)))
    var scanner_level: int = int(data.get("upgrades", {}).get("depth_scanner", 0))
    var unlocked_depth: int = 1 + int(floor(float(player_level - 1) / 2.0)) + scanner_level
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), clampi(unlocked_depth, 1, MAX_DEPTH_LEVEL))
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", data["deepest_level_unlocked"])), 1, int(data["deepest_level_unlocked"]))

static func get_move_speed(upgrades: Dictionary) -> float:
    return 205.0 + 4.2 * get_scaled_upgrade_strength(upgrades, "engine_tuning") + 0.7 * get_scaled_upgrade_strength(upgrades, "route_planner")

static func get_dirt_drag_multiplier(depth_level: int, upgrades: Dictionary) -> float:
    var base_drag: float = 0.9 - 0.042 * float(max(0, depth_level - 1))
    base_drag += 0.014 * get_scaled_upgrade_strength(upgrades, "dirt_softener")
    base_drag += 0.004 * get_scaled_upgrade_strength(upgrades, "route_planner")
    return clampf(base_drag, 0.3, 1.08)

static func get_run_time_limit(upgrades: Dictionary) -> float:
    return 16.0 + 0.85 * get_scaled_upgrade_strength(upgrades, "timer_reserve")

static func get_time_drain_rate(depth_level: int, upgrades: Dictionary) -> float:
    var drain: float = 1.0 + 0.055 * float(max(0, depth_level - 1))
    drain -= 0.016 * get_scaled_upgrade_strength(upgrades, "route_planner")
    return clampf(drain, 0.62, 2.4)

static func get_drill_dps(upgrades: Dictionary) -> float:
    return 8.5 + 1.35 * get_scaled_upgrade_strength(upgrades, "drill_torque") + 0.12 * get_scaled_upgrade_strength(upgrades, "cooling_loop") + 0.9 * get_scaled_upgrade_strength(upgrades, "foreman_bot")

static func get_drill_health_max(upgrades: Dictionary) -> float:
    return 60.0 + 8.5 * get_scaled_upgrade_strength(upgrades, "drill_plating")

static func get_drill_wear_multiplier(upgrades: Dictionary) -> float:
    return clampf(1.0 - 0.012 * get_scaled_upgrade_strength(upgrades, "cooling_loop"), 0.08, 1.0)

static func get_cargo_capacity(upgrades: Dictionary) -> int:
    return 4 + int(round(get_scaled_upgrade_strength(upgrades, "cargo_pods"))) + int(floor(get_scaled_upgrade_strength(upgrades, "cargo_compressor") / 2.0))

static func get_value_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.045 * get_scaled_upgrade_strength(upgrades, "ore_refinery") + 0.012 * get_scaled_upgrade_strength(upgrades, "cargo_compressor")

static func get_xp_multiplier(upgrades: Dictionary) -> float:
    return 1.0 + 0.06 * get_scaled_upgrade_strength(upgrades, "xp_calibration")

static func get_pickup_radius(upgrades: Dictionary) -> float:
    return 18.0 + 3.0 * get_scaled_upgrade_strength(upgrades, "pickup_radius") + 2.5 * get_scaled_upgrade_strength(upgrades, "magnet_drone")

static func get_pickup_drone_count(upgrades: Dictionary) -> int:
    var strength: float = get_scaled_upgrade_strength(upgrades, "magnet_drone")
    if strength <= 0.0:
        return 0
    return 1 + int(floor(max(0.0, strength - 1.0) / 4.0))

static func get_delivery_drone_count(upgrades: Dictionary) -> int:
    var strength: float = get_scaled_upgrade_strength(upgrades, "delivery_drone")
    if strength <= 0.0:
        return 0
    return 1 + int(floor(max(0.0, strength - 1.0) / 3.0))

static func get_delivery_drone_speed(upgrades: Dictionary) -> float:
    return 380.0 + 12.0 * get_scaled_upgrade_strength(upgrades, "delivery_drone") + 6.0 * get_scaled_upgrade_strength(upgrades, "auto_sorters")

static func get_pickup_drone_speed(upgrades: Dictionary) -> float:
    return 300.0 + 9.0 * get_scaled_upgrade_strength(upgrades, "magnet_drone")

static func get_delivery_dispatch_window(upgrades: Dictionary) -> float:
    return clampf(6.5 - 0.12 * get_scaled_upgrade_strength(upgrades, "delivery_drone") - 0.05 * get_scaled_upgrade_strength(upgrades, "auto_sorters"), 0.4, 6.5)

static func get_delivery_items_per_dispatch(upgrades: Dictionary) -> int:
    return 1 + int(floor(get_scaled_upgrade_strength(upgrades, "auto_sorters") / 5.0))

static func get_material_weights(available_tiers: int, upgrades: Dictionary) -> Array[float]:
    if available_tiers <= 1:
        return [1.0]
    var sonar_level: float = float(upgrades.get("seismic_sonar", 0))
    var weights: Array[float] = []
    for index in range(available_tiers):
        var weight: float = 1.0 + float(index == 0) * 4.0
        if index == available_tiers - 1:
            weight = 7.0 + sonar_level * 0.65
        elif index == available_tiers - 2:
            weight = 3.0 + sonar_level * 0.28
        elif index <= available_tiers - 3:
            weight = max(0.45, weight - sonar_level * 0.08)
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
    return clampi(1 + int(floor(sqrt(value) / 7.0)), 1, 6)

static func get_node_health(material: Dictionary, depth_level: int) -> float:
    var hardness: float = float(material.get("hardness", 24.0))
    return hardness * (1.0 + 0.08 * float(max(0, depth_level - 1)))

static func get_node_wear_per_second(node: Dictionary, upgrades: Dictionary) -> float:
    var wear: float = 2.6 + float(node.get("max_health", 20.0)) * 0.048
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

static func get_late_upgrade_multiplier(level: int, max_level: int = MAX_UPGRADE_LEVEL) -> float:
    if level <= EARLY_UPGRADE_LEVELS:
        return 1.0
    var late_levels: int = max(1, max_level - EARLY_UPGRADE_LEVELS)
    var progress: float = float(level - EARLY_UPGRADE_LEVELS - 1) / float(late_levels - 1 if late_levels > 1 else 1)
    return lerpf(LATE_COST_MULTIPLIER_START, LATE_COST_MULTIPLIER_END, clampf(progress, 0.0, 1.0))

static func _get_scaled_level_total(level: int, max_level: int) -> float:
    var total: float = 0.0
    for tier_level in range(1, level + 1):
        total += get_late_upgrade_multiplier(tier_level, max_level)
    return total

static func _get_upgrade_max_level(upgrade_id: String) -> int:
    for upgrade_def in UPGRADE_CATALOG:
        if String(upgrade_def.get("id", "")) == upgrade_id:
            return int(upgrade_def.get("max_level", MAX_UPGRADE_LEVEL))
    return MAX_UPGRADE_LEVEL

static func _build_material_tier_for_depth(depth_level: int) -> Dictionary:
    var base_count: int = BASE_MATERIAL_TIERS.size()
    var base_index: int = clampi(depth_level - 1, 0, base_count - 1)
    if depth_level <= base_count:
        return BASE_MATERIAL_TIERS[base_index].duplicate(true)

    var loop_index: int = (depth_level - 1) % base_count
    var cycle_number: int = 1 + int(floor(float(depth_level - 1) / float(base_count)))
    var band: int = max(0, cycle_number - 1)
    var base_material: Dictionary = BASE_MATERIAL_TIERS[loop_index].duplicate(true)
    var band_scale: float = pow(1.42, band)
    var intra_band_scale: float = 1.0 + 0.035 * float(loop_index)
    var sparkle_bonus: float = min(0.4, 0.04 * float(band))
    base_material["id"] = "%s_%d" % [String(base_material.get("id", "ore")), cycle_number]
    base_material["name"] = "%s %d" % [String(base_material.get("name", "Ore")), cycle_number]
    base_material["value"] = int(round(float(base_material.get("value", 1)) * band_scale * intra_band_scale))
    base_material["xp"] = int(round(float(base_material.get("xp", 1)) * pow(1.46, band) * intra_band_scale))
    base_material["hardness"] = float(base_material.get("hardness", 24.0)) * pow(1.38, band) * (1.0 + 0.04 * float(loop_index))

    var ore_color: Color = base_material.get("color", Color.WHITE)
    var bg_color: Color = base_material.get("bg", Color(0.1, 0.1, 0.1, 1.0))
    var hue_wobble: float = 0.015 * float(band)
    base_material["color"] = Color.from_hsv(
        fposmod(ore_color.h + hue_wobble, 1.0),
        clampf(ore_color.s * (0.98 + 0.02 * float(band)), 0.0, 1.0),
        clampf(ore_color.v * (1.0 + 0.03 * float(band)), 0.0, 1.0),
        1.0
    )
    base_material["bg"] = Color.from_hsv(
        fposmod(bg_color.h + hue_wobble * 0.5, 1.0),
        clampf(bg_color.s * (1.0 + 0.04 * float(band)), 0.0, 1.0),
        clampf(bg_color.v * (0.96 + 0.015 * float(band)), 0.0, 1.0),
        1.0
    )
    base_material["sparkle"] = clampf(float(base_material.get("sparkle", 0.0)) + sparkle_bonus, 0.0, 1.5)
    return base_material
