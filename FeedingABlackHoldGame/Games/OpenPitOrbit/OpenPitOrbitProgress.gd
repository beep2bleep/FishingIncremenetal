extends RefCounted
class_name OpenPitOrbitProgress

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const SAVE_PATH := "user://open_pit_orbit_save_v3.json"
const PLANET_SAVE_DIR := "user://open_pit_orbit_planet_state_v2"
const PLANET_META_PATH := "user://open_pit_orbit_planet_state_v2/meta.save"
const LEGACY_PLANET_SAVE_PATH := "user://open_pit_orbit_planet_state_v1.json"
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
    "planet_state": {},
}

static var _cached_data: Dictionary = {}
static var _cache_loaded: bool = false
static var _cached_planet_state: Dictionary = {}
static var _runtime_planet_data = null
static var _runtime_planet_depth: int = -1
static var _planet_save_thread: Thread = null
static var _planet_save_pending: bool = false
static var _planet_save_ok: bool = true

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
    if not (data.get("planet_state", {}) is Dictionary):
        data["planet_state"] = {}
    var inline_planet_state: Dictionary = data.get("planet_state", {}).duplicate(true)
    _cached_planet_state = {}
    if not inline_planet_state.is_empty():
        _cached_planet_state = inline_planet_state
        _write_planet_state_binary(_cached_planet_state)
        data["planet_state"] = {}
    BALANCE.refresh_depth_unlocks(data)
    _cached_data = _sanitize_main_data(data)
    _cache_loaded = true
    if not inline_planet_state.is_empty():
        _write_json(SAVE_PATH, _cached_data)
    return _cached_data.duplicate(true)

static func save_data(data: Dictionary) -> void:
    _cached_data = _sanitize_main_data(data)
    _write_json(SAVE_PATH, _cached_data)
    _cache_loaded = true

static func reset_progress() -> Dictionary:
    var data := get_default_data()
    save_data(data)
    clear_planet_state()
    return data

static func regenerate_planet_state() -> Dictionary:
    var data := load_data()
    data["destroyed_cells"] = []
    data["boss_defeated"] = false
    data["last_run_summary"] = "Open Pit Orbit planet regenerated in editor."
    data["last_run_breakdown"] = {}
    data["planet_state"] = {}
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
    var breakdown := results.duplicate(true)
    breakdown.erase("planet_state")
    data["last_run_breakdown"] = breakdown
    if results.get("destroyed_cells", []) is Array:
        data["destroyed_cells"] = results.get("destroyed_cells", []).duplicate(true)
    if bool(results.get("boss_defeated", false)):
        data["boss_defeated"] = true
    data["core_currency"] = max(0, int(data.get("core_currency", 0)) + int(results.get("core_currency", 0)))
    data["total_cores_destroyed"] = max(0, int(data.get("total_cores_destroyed", 0)) + int(results.get("cores_destroyed", 0)))
    BALANCE.refresh_depth_unlocks(data)
    if results.get("planet_state", {}) is Dictionary:
        var planet_state: Dictionary = results.get("planet_state", {}).duplicate(true)
        if bool(results.get("defer_planet_state_save", false)):
            _cached_planet_state = planet_state
        else:
            save_planet_state(planet_state)
    else:
        clear_planet_state()
    save_data(data)
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data := load_data()
    data["selected_depth_level"] = clampi(depth_level, MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
    save_data(data)
    return data

static func get_display_depth_tier(depth_level: int) -> int:
    return clampi(depth_level, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)

static func load_planet_state() -> Dictionary:
    if _cached_planet_state.is_empty():
        var parsed: Variant = _read_planet_state_binary()
        if parsed is Dictionary:
            _cached_planet_state = Dictionary(parsed).duplicate(true)
        else:
            var legacy: Variant = _read_json(LEGACY_PLANET_SAVE_PATH)
            if legacy is Dictionary:
                _cached_planet_state = Dictionary(legacy).duplicate(true)
    return _cached_planet_state.duplicate(true)

static func save_planet_state(state: Dictionary) -> void:
    _cached_planet_state = _merge_planet_state(state)
    _write_planet_state_binary(state)

static func start_async_planet_state_save(state: Dictionary) -> void:
    flush_async_planet_state_save()
    _cached_planet_state = _merge_planet_state(state)
    _planet_save_ok = true
    _planet_save_pending = true
    _planet_save_thread = Thread.new()
    var err := _planet_save_thread.start(Callable(OpenPitOrbitProgress, "_thread_write_planet_state").bind(state.duplicate(true)))
    if err != OK:
        _planet_save_pending = false
        _planet_save_thread = null
        save_planet_state(_cached_planet_state)

static func update_async_planet_state_save() -> bool:
    if not _planet_save_pending:
        return true
    if _planet_save_thread != null and _planet_save_thread.is_alive():
        return false
    flush_async_planet_state_save()
    return true

static func is_async_planet_state_save_pending() -> bool:
    return _planet_save_pending

static func was_async_planet_state_save_successful() -> bool:
    return _planet_save_ok

static func flush_async_planet_state_save() -> void:
    if _planet_save_thread == null:
        _planet_save_pending = false
        return
    var result: Variant = _planet_save_thread.wait_to_finish()
    _planet_save_ok = bool(result)
    _planet_save_thread = null
    _planet_save_pending = false

static func clear_planet_state() -> void:
    flush_async_planet_state_save()
    _cached_planet_state = {}
    _clear_planet_state_binary()

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
    flush_async_planet_state_save()
    _cached_data = {}
    _cache_loaded = false
    _cached_planet_state = {}
    clear_runtime_planet_data()

static func _sanitize_main_data(data: Dictionary) -> Dictionary:
    var sanitized := data.duplicate(true)
    sanitized["planet_state"] = {}
    var breakdown: Variant = sanitized.get("last_run_breakdown", {})
    if breakdown is Dictionary:
        var breakdown_dict: Dictionary = Dictionary(breakdown).duplicate(true)
        breakdown_dict.erase("planet_state")
        sanitized["last_run_breakdown"] = breakdown_dict
    return sanitized

static func _read_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null
    return JSON.parse_string(file.get_as_text())

static func _write_json(path: String, data: Variant) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data, "\t"))

static func _thread_write_planet_state(state: Dictionary) -> bool:
    return _write_planet_state_binary(state)

static func _read_planet_state_binary() -> Variant:
    if not FileAccess.file_exists(PLANET_META_PATH):
        return null
    var meta_file := FileAccess.open(PLANET_META_PATH, FileAccess.READ)
    if meta_file == null:
        return null
    var meta: Variant = meta_file.get_var()
    meta_file.close()
    if not (meta is Dictionary):
        return null
    var state: Dictionary = Dictionary(meta).duplicate(true)
    var sections := {}
    var section_count: int = int(state.get("angle_slices", 10)) * int(state.get("depth_slices", 10))
    for section_id in range(section_count):
        var section_path := _planet_section_path(section_id)
        if not FileAccess.file_exists(section_path):
            continue
        var section_file := FileAccess.open(section_path, FileAccess.READ)
        if section_file == null:
            continue
        var section_data: Variant = section_file.get_var()
        section_file.close()
        if section_data is Array:
            sections[section_id] = Array(section_data).duplicate(true)
    state["sections"] = sections
    return state

static func _write_planet_state_binary(state: Dictionary) -> bool:
    if DirAccess.make_dir_recursive_absolute(PLANET_SAVE_DIR) != OK and not DirAccess.dir_exists_absolute(PLANET_SAVE_DIR):
        return false
    var payload: Dictionary = state.duplicate(true)
    var sections: Dictionary = payload.get("sections", {})
    payload.erase("sections")
    var meta_file := FileAccess.open(PLANET_META_PATH, FileAccess.WRITE)
    if meta_file == null:
        return false
    meta_file.store_var(payload, true)
    meta_file.close()
    for section_id_variant in sections.keys():
        var section_id: int = int(section_id_variant)
        var section_file := FileAccess.open(_planet_section_path(section_id), FileAccess.WRITE)
        if section_file == null:
            return false
        section_file.store_var(sections[section_id_variant], true)
        section_file.close()
    return true

static func _clear_planet_state_binary() -> void:
    for section_id in range(100):
        var section_path := _planet_section_path(section_id)
        if FileAccess.file_exists(section_path):
            DirAccess.remove_absolute(section_path)
    if FileAccess.file_exists(PLANET_META_PATH):
        DirAccess.remove_absolute(PLANET_META_PATH)
    if FileAccess.file_exists(LEGACY_PLANET_SAVE_PATH):
        DirAccess.remove_absolute(LEGACY_PLANET_SAVE_PATH)

static func _planet_section_path(section_id: int) -> String:
    return "%s/section_%03d.save" % [PLANET_SAVE_DIR, section_id]

static func _merge_planet_state(update: Dictionary) -> Dictionary:
    var merged: Dictionary = {}
    if not _cached_planet_state.is_empty():
        merged = _cached_planet_state.duplicate(true)
    else:
        var existing: Variant = _read_planet_state_binary()
        if existing is Dictionary:
            merged = Dictionary(existing).duplicate(true)
    for key_variant in update.keys():
        var key: String = str(key_variant)
        if key == "sections":
            continue
        merged[key] = update[key_variant]
    var merged_sections: Dictionary = merged.get("sections", {}).duplicate(true)
    var update_sections: Dictionary = update.get("sections", {})
    for section_id_variant in update_sections.keys():
        merged_sections[int(section_id_variant)] = update_sections[section_id_variant]
    merged["sections"] = merged_sections
    return merged
