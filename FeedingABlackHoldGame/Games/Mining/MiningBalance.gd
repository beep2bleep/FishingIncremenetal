extends RefCounted
class_name MiningBalance

const MAX_DEPTH_LEVEL := 13

const UPGRADE_CATALOG: Array[Dictionary] = [
	{"id": "timer_reserve", "label": "Timer Reserve", "summary": "Extends each run so upgraded rigs can squeeze in one more haul before the horn sounds.", "base_cost": 18, "cost_mult": 1.14, "max_level": 28, "requires": {}, "act": 1, "icon": "T"},
	{"id": "route_planner", "label": "Route Planner", "summary": "Trims wasted travel and stretches the timer by making each route more efficient.", "base_cost": 22, "cost_mult": 1.145, "max_level": 20, "requires": {"timer_reserve": 4}, "act": 1, "icon": "R"},
	{"id": "engine_tuning", "label": "Engine Tuning", "summary": "Boosts rig acceleration so short runs still feel punchy instead of sluggish.", "base_cost": 19, "cost_mult": 1.14, "max_level": 28, "requires": {}, "act": 1, "icon": "M"},
	{"id": "dirt_softener", "label": "Dirt Softener", "summary": "Keeps deeper layers from stealing too much speed away from the drill rig.", "base_cost": 27, "cost_mult": 1.152, "max_level": 22, "requires": {"engine_tuning": 4}, "act": 2, "icon": "S"},
	{"id": "drill_torque", "label": "Drill Torque", "summary": "Raises drilling throughput so each pass breaks more rock before the timer runs dry.", "base_cost": 20, "cost_mult": 1.142, "max_level": 40, "requires": {}, "act": 1, "icon": "D"},
	{"id": "drill_plating", "label": "Drill Plating", "summary": "Adds integrity to the bit so risky dives can survive tougher veins.", "base_cost": 22, "cost_mult": 1.146, "max_level": 32, "requires": {"drill_torque": 2}, "act": 2, "icon": "H"},
	{"id": "cooling_loop", "label": "Cooling Loop", "summary": "Shaves off drill wear so health stays right on the edge instead of collapsing instantly.", "base_cost": 25, "cost_mult": 1.149, "max_level": 24, "requires": {"drill_plating": 2}, "act": 2, "icon": "K"},
	{"id": "cargo_pods", "label": "Cargo Pods", "summary": "Lets each trip carry a few more chunks before you have to dump at the surface.", "base_cost": 21, "cost_mult": 1.143, "max_level": 26, "requires": {}, "act": 1, "icon": "C"},
	{"id": "cargo_compressor", "label": "Cargo Compressor", "summary": "Packs ore tighter so every haul holds together longer before a forced dump.", "base_cost": 29, "cost_mult": 1.156, "max_level": 22, "requires": {"cargo_pods": 6}, "act": 3, "icon": "Q"},
	{"id": "ore_refinery", "label": "Ore Refinery", "summary": "Improves payout conversion so every dumped load is worth a little more.", "base_cost": 24, "cost_mult": 1.148, "max_level": 32, "requires": {"cargo_pods": 2}, "act": 2, "icon": "V"},
	{"id": "pickup_radius", "label": "Vacuum Scoop", "summary": "Widens the collection field so more of each broken node actually makes it into cargo.", "base_cost": 23, "cost_mult": 1.146, "max_level": 22, "requires": {"cargo_pods": 1}, "act": 2, "icon": "P"},
	{"id": "xp_calibration", "label": "XP Calibration", "summary": "Keeps progression climbing fast enough that new depths keep unlocking through the full run.", "base_cost": 27, "cost_mult": 1.152, "max_level": 26, "requires": {"ore_refinery": 2}, "act": 3, "icon": "X"},
	{"id": "depth_scanner", "label": "Depth Scanner", "summary": "Unlocks harder strata a little earlier when your rig can actually survive them.", "base_cost": 34, "cost_mult": 1.162, "max_level": 12, "requires": {"xp_calibration": 2}, "act": 4, "icon": "L"},
	{"id": "seismic_sonar", "label": "Seismic Sonar", "summary": "Leans each depth roll toward richer veins so later runs keep feeling like upgrades matter.", "base_cost": 37, "cost_mult": 1.168, "max_level": 18, "requires": {"depth_scanner": 2}, "act": 4, "icon": "N"},
	{"id": "magnet_drone", "label": "Salvage Drone", "summary": "Launches bots that fly out to loose ore chunks so the player can stay on drilling lines.", "base_cost": 39, "cost_mult": 1.17, "max_level": 20, "requires": {"pickup_radius": 4}, "act": 4, "icon": "G"},
	{"id": "foreman_bot", "label": "Foreman Bot", "summary": "A helper bot locks onto your current node and adds steady drill pressure during the contact.", "base_cost": 41, "cost_mult": 1.172, "max_level": 18, "requires": {"drill_plating": 6, "magnet_drone": 4}, "act": 5, "icon": "F"},
	{"id": "delivery_drone", "label": "Delivery Drone", "summary": "Dispatches separate bots that ferry cargo back to the base ring while you keep drilling.", "base_cost": 46, "cost_mult": 1.178, "max_level": 18, "requires": {"magnet_drone": 2, "depth_scanner": 1}, "act": 5, "icon": "R"},
	{"id": "auto_sorters", "label": "Auto Sorters", "summary": "Upgrades the delivery lane so each dump drone hauls more before it has to turn around.", "base_cost": 45, "cost_mult": 1.176, "max_level": 16, "requires": {"delivery_drone": 4}, "act": 5, "icon": "B"}
]

const MATERIAL_TIERS: Array[Dictionary] = [
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

static func get_material_tiers() -> Array[Dictionary]:
	return MATERIAL_TIERS.duplicate(true)

static func get_material_by_id(material_id: String) -> Dictionary:
	for material in MATERIAL_TIERS:
		if String(material.get("id", "")) == material_id:
			return material.duplicate(true)
	return MATERIAL_TIERS[0].duplicate(true)

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
	return 205.0 + 6.5 * float(upgrades.get("engine_tuning", 0)) + 1.8 * float(upgrades.get("route_planner", 0))

static func get_dirt_drag_multiplier(depth_level: int, upgrades: Dictionary) -> float:
	var base_drag: float = 0.9 - 0.042 * float(max(0, depth_level - 1))
	base_drag += 0.034 * float(upgrades.get("dirt_softener", 0))
	base_drag += 0.01 * float(upgrades.get("route_planner", 0))
	return clampf(base_drag, 0.3, 1.08)

static func get_run_time_limit(upgrades: Dictionary) -> float:
	return 16.0 + 0.85 * float(upgrades.get("timer_reserve", 0))

static func get_time_drain_rate(depth_level: int, upgrades: Dictionary) -> float:
	var drain: float = 1.0 + 0.055 * float(max(0, depth_level - 1))
	drain -= 0.016 * float(upgrades.get("route_planner", 0))
	return clampf(drain, 0.62, 2.4)

static func get_drill_dps(upgrades: Dictionary) -> float:
	return 8.5 + 1.35 * float(upgrades.get("drill_torque", 0)) + 0.12 * float(upgrades.get("cooling_loop", 0)) + 0.9 * float(upgrades.get("foreman_bot", 0))

static func get_drill_health_max(upgrades: Dictionary) -> float:
	return 60.0 + 8.5 * float(upgrades.get("drill_plating", 0))

static func get_drill_wear_multiplier(upgrades: Dictionary) -> float:
	return clampf(1.0 - 0.012 * float(upgrades.get("cooling_loop", 0)), 0.45, 1.0)

static func get_cargo_capacity(upgrades: Dictionary) -> int:
	return 4 + int(upgrades.get("cargo_pods", 0)) + int(floor(float(upgrades.get("cargo_compressor", 0)) / 2.0))

static func get_value_multiplier(upgrades: Dictionary) -> float:
	return 1.0 + 0.045 * float(upgrades.get("ore_refinery", 0)) + 0.012 * float(upgrades.get("cargo_compressor", 0))

static func get_xp_multiplier(upgrades: Dictionary) -> float:
	return 1.0 + 0.06 * float(upgrades.get("xp_calibration", 0))

static func get_pickup_radius(upgrades: Dictionary) -> float:
	return 18.0 + 3.0 * float(upgrades.get("pickup_radius", 0)) + 2.5 * float(upgrades.get("magnet_drone", 0))

static func get_pickup_drone_count(upgrades: Dictionary) -> int:
	var level: int = int(upgrades.get("magnet_drone", 0))
	if level <= 0:
		return 0
	return 1 + int(floor(float(max(0, level - 1)) / 4.0))

static func get_delivery_drone_count(upgrades: Dictionary) -> int:
	var level: int = int(upgrades.get("delivery_drone", 0))
	if level <= 0:
		return 0
	return 1 + int(floor(float(max(0, level - 1)) / 3.0))

static func get_delivery_drone_speed(upgrades: Dictionary) -> float:
	return 380.0 + 12.0 * float(upgrades.get("delivery_drone", 0)) + 6.0 * float(upgrades.get("auto_sorters", 0))

static func get_pickup_drone_speed(upgrades: Dictionary) -> float:
	return 300.0 + 9.0 * float(upgrades.get("magnet_drone", 0))

static func get_delivery_dispatch_window(upgrades: Dictionary) -> float:
	return clampf(6.5 - 0.12 * float(upgrades.get("delivery_drone", 0)) - 0.05 * float(upgrades.get("auto_sorters", 0)), 2.0, 6.5)

static func get_delivery_items_per_dispatch(upgrades: Dictionary) -> int:
	return 1 + int(floor(float(upgrades.get("auto_sorters", 0)) / 5.0))

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

static func get_drop_count_for_node(node: Dictionary) -> int:
	var value: float = float(node.get("value", 1))
	return clampi(1 + int(floor(sqrt(value) / 7.0)), 1, 6)

static func get_node_health(material: Dictionary, depth_level: int) -> float:
	var hardness: float = float(material.get("hardness", 24.0))
	return hardness * (1.0 + 0.08 * float(max(0, depth_level - 1)))

static func get_node_wear_per_second(node: Dictionary, upgrades: Dictionary) -> float:
	var wear: float = 2.6 + float(node.get("max_health", 20.0)) * 0.048
	return wear * get_drill_wear_multiplier(upgrades)
