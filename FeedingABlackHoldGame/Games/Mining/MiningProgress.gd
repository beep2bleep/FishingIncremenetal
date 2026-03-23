extends RefCounted
class_name MiningProgress

const SAVE_PATH := "user://mining_mode_save_v1.json"
const MAX_DEPTH_LEVEL := 13

const DEFAULT_DATA := {
    "wallet": 0,
    "xp": 0,
    "player_level": 1,
    "deepest_level_unlocked": 1,
    "selected_depth_level": 1,
    "upgrades": {},
    "last_run_summary": "No mining run completed yet.",
    "last_run_breakdown": {}
}

const UPGRADE_CATALOG: Array[Dictionary] = [
    {"id": "timer_reserve", "label": "Timer Reserve", "summary": "Adds a few precious seconds to every drilling run.", "base_cost": 24, "cost_mult": 1.42, "max_level": 10, "requires": {}, "act": 1, "icon": "T"},
    {"id": "engine_tuning", "label": "Engine Tuning", "summary": "Move faster through dirt and open tunnels.", "base_cost": 26, "cost_mult": 1.44, "max_level": 10, "requires": {}, "act": 1, "icon": "M"},
    {"id": "drill_torque", "label": "Drill Torque", "summary": "Chews through resource nodes much faster.", "base_cost": 30, "cost_mult": 1.46, "max_level": 10, "requires": {}, "act": 2, "icon": "D"},
    {"id": "drill_plating", "label": "Drill Plating", "summary": "Raises drill health so tougher nodes do less wear.", "base_cost": 34, "cost_mult": 1.48, "max_level": 8, "requires": {"drill_torque": 1}, "act": 2, "icon": "H"},
    {"id": "cargo_pods", "label": "Cargo Pods", "summary": "Carry more drops before returning to base.", "base_cost": 32, "cost_mult": 1.45, "max_level": 8, "requires": {}, "act": 3, "icon": "C"},
    {"id": "ore_refinery", "label": "Ore Refinery", "summary": "Every mined chunk converts into more money.", "base_cost": 38, "cost_mult": 1.48, "max_level": 8, "requires": {"cargo_pods": 1}, "act": 3, "icon": "V"},
    {"id": "pickup_radius", "label": "Vacuum Scoop", "summary": "Pick up spawned drops from farther away.", "base_cost": 36, "cost_mult": 1.46, "max_level": 7, "requires": {"cargo_pods": 1}, "act": 3, "icon": "P"},
    {"id": "xp_calibration", "label": "XP Calibration", "summary": "Mining and hauling gives more XP per run.", "base_cost": 42, "cost_mult": 1.5, "max_level": 7, "requires": {"ore_refinery": 1}, "act": 4, "icon": "X"},
    {"id": "dirt_softener", "label": "Dirt Softener", "summary": "Reduces how much deeper levels slow the rig down.", "base_cost": 48, "cost_mult": 1.52, "max_level": 6, "requires": {"engine_tuning": 2}, "act": 4, "icon": "S"},
    {"id": "depth_scanner", "label": "Depth Scanner", "summary": "Lets the rig challenge deeper strata earlier.", "base_cost": 58, "cost_mult": 1.56, "max_level": 5, "requires": {"xp_calibration": 1}, "act": 5, "icon": "L"},
    {"id": "magnet_drone", "label": "Magnet Drone", "summary": "A support drone tugs nearby drops into your hold.", "base_cost": 92, "cost_mult": 1.78, "max_level": 4, "requires": {"pickup_radius": 2}, "act": 6, "icon": "G"},
    {"id": "delivery_drone", "label": "Delivery Drone", "summary": "Periodically ferries a little cargo back to base.", "base_cost": 136, "cost_mult": 1.85, "max_level": 3, "requires": {"magnet_drone": 1, "depth_scanner": 1}, "act": 6, "icon": "R"}
]

static func get_default_data() -> Dictionary:
    return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
    return UPGRADE_CATALOG.duplicate(true)

static func load_data() -> Dictionary:
    var data: Dictionary = get_default_data()
    if not FileAccess.file_exists(SAVE_PATH):
        return data
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return data
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        data = data.merged(parsed, true)
    data["player_level"] = max(1, int(data.get("player_level", 1)))
    data["deepest_level_unlocked"] = clampi(int(data.get("deepest_level_unlocked", 1)), 1, MAX_DEPTH_LEVEL)
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", 1)), 1, int(data["deepest_level_unlocked"]))
    return data

static func save_data(data: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
    var data: Dictionary = get_default_data()
    save_data(data)
    return data

static func get_wallet() -> int:
    return int(load_data().get("wallet", 0))

static func get_upgrade_level(upgrade_id: String) -> int:
    var data: Dictionary = load_data()
    var upgrades: Dictionary = data.get("upgrades", {})
    return int(upgrades.get(upgrade_id, 0))

static func apply_tree_purchase(upgrade_id: String, level: int, wallet_after_purchase: int) -> void:
    var data: Dictionary = load_data()
    var upgrades: Dictionary = data.get("upgrades", {})
    upgrades[upgrade_id] = max(level, int(upgrades.get(upgrade_id, 0)))
    data["upgrades"] = upgrades
    data["wallet"] = max(0, wallet_after_purchase)
    _refresh_depth_unlocks(data)
    save_data(data)

static func apply_run_results(results: Dictionary) -> Dictionary:
    var data: Dictionary = load_data()
    data["wallet"] = max(0, int(data.get("wallet", 0)) + int(results.get("money", 0)))
    data["xp"] = max(0, int(data.get("xp", 0)) + int(results.get("xp", 0)))
    data["player_level"] = get_level_for_total_xp(int(data["xp"]))
    data["last_run_summary"] = str(results.get("summary_text", "Mining run complete."))
    data["last_run_breakdown"] = results.duplicate(true)
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), int(results.get("depth_level", 1)))
    _refresh_depth_unlocks(data)
    save_data(data)
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data: Dictionary = load_data()
    data["selected_depth_level"] = clampi(depth_level, 1, int(data.get("deepest_level_unlocked", 1)))
    save_data(data)
    return data

static func get_level_for_total_xp(total_xp: int) -> int:
    var level: int = 1
    var remaining_xp: int = max(0, total_xp)
    while remaining_xp >= get_xp_to_next_level(level):
        remaining_xp -= get_xp_to_next_level(level)
        level += 1
    return level

static func get_xp_to_next_level(level: int) -> int:
    return int(round(28.0 + 18.0 * pow(float(max(level, 1)), 1.28)))

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

static func _refresh_depth_unlocks(data: Dictionary) -> void:
    var player_level: int = max(1, int(data.get("player_level", 1)))
    var scanner_level: int = int(data.get("upgrades", {}).get("depth_scanner", 0))
    var unlocked_depth: int = min(MAX_DEPTH_LEVEL, 1 + int(floor(float(player_level - 1) / 1.0)) + scanner_level)
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), unlocked_depth)
    data["selected_depth_level"] = int(data["deepest_level_unlocked"])
