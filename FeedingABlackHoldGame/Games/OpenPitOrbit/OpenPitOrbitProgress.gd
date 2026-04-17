extends RefCounted
class_name OpenPitOrbitProgress

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const SAVE_PATH := "user://open_pit_orbit_save_v3.json"
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
    "core_currency": 0,
    "purchased_core_upgrades": [],
    "total_cores_destroyed": 0,
    "planet_mastery_unlocked": false,
    "free_planet_mode": false,
}

static var _cached_data: Dictionary = {}
static var _cache_loaded: bool = false
static var _cached_planet_state: Dictionary = {}
static var _runtime_planet_data = null
static var _runtime_planet_depth: int = -1

static func get_default_data() -> Dictionary:
    return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
    return BALANCE.get_upgrade_catalog()

static func load_data() -> Dictionary:
    if _cache_loaded:
        return _cached_data.duplicate(true)
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
    if not (data.get("purchased_core_upgrades", []) is Array):
        data["purchased_core_upgrades"] = []
    data.erase("planet_state")
    BALANCE.refresh_depth_unlocks(data)
    _cached_data = data.duplicate(true)
    _cache_loaded = true
    return data.duplicate(true)

static func save_data(data: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data, "\t"))
    _cached_data = data.duplicate(true)
    _cache_loaded = true

static func reset_progress() -> Dictionary:
    var data := get_default_data()
    save_data(data)
    return data

static func regenerate_planet_state() -> Dictionary:
    var data := load_data()
    data["destroyed_cells"] = []
    data["boss_defeated"] = false
    data["last_run_summary"] = "Open Pit Orbit planet regenerated in editor."
    data["last_run_breakdown"] = {}
    save_data(data)
    clear_planet_state()
    clear_runtime_planet_data()
    return data

static func get_wallet() -> int:
    return int(load_data().get("wallet", 0))

static func get_upgrade_levels() -> Dictionary:
    return load_data().get("upgrades", {}).duplicate(true)

static func get_core_wallet() -> int:
    return int(load_data().get("core_currency", 0))

static func get_core_upgrade_levels() -> Dictionary:
    var levels := {}
    for upgrade_id_variant in load_data().get("purchased_core_upgrades", []):
        levels["core:" + str(upgrade_id_variant)] = 1
    return levels

static func apply_tree_purchase(upgrade_id: String, level: int, wallet_after_purchase: int) -> void:
    var data := load_data()
    if BALANCE.is_core_upgrade(upgrade_id):
        var core_upgrade_id: String = upgrade_id.trim_prefix(BALANCE.CORE_PREFIX)
        var purchased: Array = data.get("purchased_core_upgrades", []).duplicate()
        if core_upgrade_id not in purchased:
            purchased.append(core_upgrade_id)
        data["purchased_core_upgrades"] = purchased
        data["core_currency"] = max(0, wallet_after_purchase)
        if core_upgrade_id == "planet_mastery":
            data["planet_mastery_unlocked"] = true
            data["free_planet_mode"] = true
        elif core_upgrade_id == "center_unlock":
            data["free_planet_mode"] = false
        save_data(data)
        return
    var upgrades: Dictionary = data.get("upgrades", {}).duplicate(true)
    upgrades[upgrade_id] = max(level, int(upgrades.get(upgrade_id, 0)))
    data["upgrades"] = upgrades
    data["wallet"] = max(0, wallet_after_purchase)
    BALANCE.refresh_depth_unlocks(data)
    save_data(data)

static func apply_tree_sale(upgrade_id: String, level: int, wallet_after_sale: int) -> void:
    var data := load_data()
    if BALANCE.is_core_upgrade(upgrade_id):
        var core_upgrade_id: String = upgrade_id.trim_prefix(BALANCE.CORE_PREFIX)
        var purchased: Array = data.get("purchased_core_upgrades", []).duplicate()
        purchased.erase(core_upgrade_id)
        data["purchased_core_upgrades"] = purchased
        data["core_currency"] = max(0, wallet_after_sale)
        if core_upgrade_id == "planet_mastery":
            data["planet_mastery_unlocked"] = false
            data["free_planet_mode"] = false
        save_data(data)
        return
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
    data["core_currency"] = max(0, int(data.get("core_currency", 0)) + int(results.get("core_currency", 0)))
    data["total_cores_destroyed"] = max(0, int(data.get("total_cores_destroyed", 0)) + int(results.get("cores_destroyed", 0)))
    BALANCE.refresh_depth_unlocks(data)
    save_data(data)
    if results.get("planet_state", {}) is Dictionary:
        save_planet_state(results.get("planet_state", {}))
    else:
        clear_planet_state()
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data := load_data()
    data["selected_depth_level"] = clampi(depth_level, MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
    save_data(data)
    return data

static func get_display_depth_tier(depth_level: int) -> int:
    return clampi(depth_level, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)

static func load_planet_state() -> Dictionary:
    return _cached_planet_state.duplicate(true)

static func save_planet_state(state: Dictionary) -> void:
    _cached_planet_state = state.duplicate(true)

static func clear_planet_state() -> void:
    _cached_planet_state = {}

static func load_runtime_planet_data(depth_level: int):
    if _runtime_planet_data == null:
        return null
    if _runtime_planet_depth != depth_level:
        return null
    return _runtime_planet_data

static func save_runtime_planet_data(depth_level: int, planet_data) -> void:
    _runtime_planet_depth = depth_level
    _runtime_planet_data = planet_data

static func clear_runtime_planet_data() -> void:
    _runtime_planet_data = null
    _runtime_planet_depth = -1

static func clear_cache() -> void:
    _cached_data = {}
    _cache_loaded = false
    _cached_planet_state = {}
    clear_runtime_planet_data()
