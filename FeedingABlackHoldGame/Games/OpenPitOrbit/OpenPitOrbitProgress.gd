extends RefCounted
class_name OpenPitOrbitProgress

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const SAVE_PATH := "user://open_pit_orbit_save_v1.json"
const MIN_START_DEPTH_LEVEL := BALANCE.MIN_START_DEPTH_LEVEL
const MAX_DEPTH_LEVEL := BALANCE.MAX_DEPTH_LEVEL

const DEFAULT_DATA := {
    "wallet": 0,
    "deepest_level_unlocked": MIN_START_DEPTH_LEVEL,
    "selected_depth_level": MIN_START_DEPTH_LEVEL,
    "upgrades": {},
    "destroyed_cells": [],
    "last_run_summary": "No Open Pit Orbit sortie completed yet.",
    "last_run_breakdown": {},
    "boss_defeated": false,
}

static func get_default_data() -> Dictionary:
    return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
    return BALANCE.get_upgrade_catalog()

static func load_data() -> Dictionary:
    var data: Dictionary = get_default_data()
    if FileAccess.file_exists(SAVE_PATH):
        var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file != null:
            var parsed: Variant = JSON.parse_string(file.get_as_text())
            if parsed is Dictionary:
                data = data.merged(parsed, true)
    data["wallet"] = max(0, int(data.get("wallet", 0)))
    if not (data.get("upgrades", {}) is Dictionary):
        data["upgrades"] = {}
    if not (data.get("destroyed_cells", []) is Array):
        data["destroyed_cells"] = []
    BALANCE.refresh_depth_unlocks(data)
    return data

static func save_data(data: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
    var data := get_default_data()
    save_data(data)
    return data

static func get_wallet() -> int:
    return int(load_data().get("wallet", 0))

static func get_upgrade_levels() -> Dictionary:
    return load_data().get("upgrades", {}).duplicate(true)

static func apply_tree_purchase(upgrade_id: String, level: int, wallet_after_purchase: int) -> void:
    var data := load_data()
    var upgrades: Dictionary = data.get("upgrades", {}).duplicate(true)
    upgrades[upgrade_id] = max(level, int(upgrades.get(upgrade_id, 0)))
    data["upgrades"] = upgrades
    data["wallet"] = max(0, wallet_after_purchase)
    BALANCE.refresh_depth_unlocks(data)
    save_data(data)

static func apply_tree_sale(upgrade_id: String, level: int, wallet_after_sale: int) -> void:
    var data := load_data()
    var upgrades: Dictionary = data.get("upgrades", {}).duplicate(true)
    if level <= 0:
        upgrades.erase(upgrade_id)
    else:
        upgrades[upgrade_id] = level
    data["upgrades"] = upgrades
    data["wallet"] = max(0, wallet_after_sale)
    BALANCE.refresh_depth_unlocks(data)
    save_data(data)

static func apply_run_results(results: Dictionary) -> Dictionary:
    var data := load_data()
    data["wallet"] = max(0, int(data.get("wallet", 0)) + int(results.get("money", 0)))
    data["last_run_summary"] = str(results.get("summary_text", "Open Pit Orbit sortie complete."))
    data["last_run_breakdown"] = results.duplicate(true)
    if results.get("destroyed_cells", []) is Array:
        data["destroyed_cells"] = results.get("destroyed_cells", []).duplicate(true)
    if bool(results.get("boss_defeated", false)):
        data["boss_defeated"] = true
    BALANCE.refresh_depth_unlocks(data)
    save_data(data)
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data := load_data()
    data["selected_depth_level"] = clampi(depth_level, MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
    save_data(data)
    return data

static func get_display_depth_tier(depth_level: int) -> int:
    return clampi(depth_level, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
