extends RefCounted
class_name OpenPitEmpireProgress

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitEmpire/OpenPitEmpirePlanetData.gd")
const SAVE_PATH := "user://open_pit_empire_save_v3.json"
const PLANET_SAVE_DIR := "user://open_pit_empire_planet_state_v3"
const PLANET_META_PATH := "user://open_pit_empire_planet_state_v3/meta.save"
const PLANET_FULL_PATH := "user://open_pit_empire_planet_state_v3/full.save"
const LEGACY_PLANET_SAVE_PATH := "user://open_pit_empire_planet_state_v1.json"
const MIN_START_DEPTH_LEVEL := BALANCE.MIN_START_DEPTH_LEVEL
const MAX_DEPTH_LEVEL := BALANCE.MAX_DEPTH_LEVEL
const INITIAL_LAYER_BLOCK_COUNTS_BY_LAYOUT_VERSION := {
    5: {
        1: 36513,
        2: 33578,
        3: 33785,
        4: 35270,
        5: 28502,
    },
}

const DEFAULT_DATA := {
    "wallet": 0,
    "xp_currency": 0,
    "deepest_level_unlocked": MIN_START_DEPTH_LEVEL,
    "selected_depth_level": MIN_START_DEPTH_LEVEL,
    "upgrades": {},
    "xp_upgrades": {},
    "destroyed_cells": [],
    "last_run_summary": "No Open Pit Empire sortie completed yet.",
    "last_run_breakdown": {},
    "boss_defeated": false,
    "core_currency": 0,
    "purchased_core_upgrades": [],
    "total_cores_destroyed": 0,
    "planet_mastery_unlocked": false,
    "free_planet_mode": false,
    "planet_state": {},
    "planet_layout_version": BALANCE.PLANET_LAYOUT_VERSION,
    "attempt_history": [],
    "run_clock_seconds": 0.0,
    "demo_core8_clock_seconds": -1.0,
    "full_clear_clock_seconds": -1.0,
    "demo_core8_end_screen_shown": false,
    "best_layer_clear_percents": {},
    "remaining_layer_block_counts": {},
    "chat_line_counts": {},
    "chat_thread_counts": {},
    "chat_active_thread_id": "",
    "chat_active_thread_ids": [],
    "chat_active_thread_target_count": 2,
    "chat_event_signatures": {},
    "chat_log": [],
    "bottom_phase_unlocked": false,
    "editor_assists_used": false,
}

static var _cached_data: Dictionary = {}
static var _cache_loaded: bool = false
static var _cached_planet_state: Dictionary = {}
static var _runtime_planet_data = null
static var _runtime_planet_depth: int = -1
static var _planet_save_thread: Thread = null
static var _planet_save_pending: bool = false
static var _planet_save_ok: bool = true
static var _initial_layer_block_counts: Dictionary = {}

static func get_default_data() -> Dictionary:
    return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
    return BALANCE.get_upgrade_catalog()

static func load_data() -> Dictionary:
    var profile_started_msec := Time.get_ticks_msec()
    if _cache_loaded:
        _print_startup_profile("progress_load_cached", Time.get_ticks_msec() - profile_started_msec)
        return _cached_data.duplicate(true)
    _print_startup_profile("progress_load_begin")
    var data: Dictionary = get_default_data()
    if FileAccess.file_exists(SAVE_PATH):
        var read_started_msec := Time.get_ticks_msec()
        var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file != null:
            var parsed: Variant = JSON.parse_string(file.get_as_text())
            if parsed is Dictionary:
                data = data.merged(parsed, true)
        _print_startup_profile("progress_read_main_save", Time.get_ticks_msec() - read_started_msec)
    data["wallet"] = max(0, int(data.get("wallet", 0)))
    data["xp_currency"] = max(0, int(data.get("xp_currency", 0)))
    if not (data.get("upgrades", {}) is Dictionary):
        data["upgrades"] = {}
    if not (data.get("xp_upgrades", {}) is Dictionary):
        data["xp_upgrades"] = {}
    if not (data.get("destroyed_cells", []) is Array):
        data["destroyed_cells"] = []
    if not (data.get("purchased_core_upgrades", []) is Array):
        data["purchased_core_upgrades"] = []
    if not (data.get("planet_state", {}) is Dictionary):
        data["planet_state"] = {}
    if not (data.get("attempt_history", []) is Array):
        data["attempt_history"] = []
    data["run_clock_seconds"] = max(0.0, float(data.get("run_clock_seconds", 0.0)))
    data["demo_core8_clock_seconds"] = float(data.get("demo_core8_clock_seconds", -1.0))
    data["full_clear_clock_seconds"] = float(data.get("full_clear_clock_seconds", -1.0))
    data["demo_core8_end_screen_shown"] = bool(data.get("demo_core8_end_screen_shown", false))
    if not (data.get("best_layer_clear_percents", {}) is Dictionary):
        data["best_layer_clear_percents"] = {}
    if not (data.get("remaining_layer_block_counts", {}) is Dictionary):
        data["remaining_layer_block_counts"] = {}
    if not (data.get("chat_line_counts", {}) is Dictionary):
        data["chat_line_counts"] = {}
    if not (data.get("chat_thread_counts", {}) is Dictionary):
        data["chat_thread_counts"] = {}
    data["chat_active_thread_id"] = str(data.get("chat_active_thread_id", ""))
    if not (data.get("chat_active_thread_ids", []) is Array):
        data["chat_active_thread_ids"] = []
    data["chat_active_thread_target_count"] = clampi(int(data.get("chat_active_thread_target_count", 2)), 2, 3)
    if not (data.get("chat_event_signatures", {}) is Dictionary):
        data["chat_event_signatures"] = {}
    if not (data.get("chat_log", []) is Array):
        data["chat_log"] = []
    data["bottom_phase_unlocked"] = bool(data.get("bottom_phase_unlocked", false))
    data["editor_assists_used"] = bool(data.get("editor_assists_used", false))
    if int(data.get("planet_layout_version", 0)) != BALANCE.PLANET_LAYOUT_VERSION:
        data["destroyed_cells"] = []
        data["boss_defeated"] = false
        data["planet_state"] = {}
        data["planet_layout_version"] = BALANCE.PLANET_LAYOUT_VERSION
        _cached_planet_state = {}
        _clear_planet_state_binary()
        clear_runtime_planet_data()
    var inline_planet_state: Dictionary = data.get("planet_state", {}).duplicate(true)
    var should_write_save := false
    _cached_planet_state = {}
    if not inline_planet_state.is_empty():
        var migrate_started_msec := Time.get_ticks_msec()
        _cached_planet_state = inline_planet_state
        _write_planet_state_binary(_cached_planet_state)
        data["planet_state"] = {}
        should_write_save = true
        _print_startup_profile("progress_migrate_inline_planet_state", Time.get_ticks_msec() - migrate_started_msec)
    if not _has_complete_remaining_layer_count_cache(data):
        var remaining_started_msec := Time.get_ticks_msec()
        _refresh_remaining_layer_count_cache(data)
        should_write_save = true
        _print_startup_profile("progress_refresh_remaining_layer_count_cache", Time.get_ticks_msec() - remaining_started_msec)
    if not _has_complete_layer_clear_cache(data):
        var clear_started_msec := Time.get_ticks_msec()
        _refresh_best_layer_clear_cache(data)
        should_write_save = true
        _print_startup_profile("progress_refresh_best_layer_clear_cache", Time.get_ticks_msec() - clear_started_msec)
    var depth_started_msec := Time.get_ticks_msec()
    BALANCE.refresh_depth_unlocks(data)
    _print_startup_profile("progress_refresh_unlocks", Time.get_ticks_msec() - depth_started_msec)
    var sanitize_started_msec := Time.get_ticks_msec()
    _cached_data = _sanitize_main_data(data)
    _cache_loaded = true
    _print_startup_profile("progress_sanitize", Time.get_ticks_msec() - sanitize_started_msec)
    if should_write_save:
        var write_started_msec := Time.get_ticks_msec()
        _write_json(SAVE_PATH, _cached_data)
        _print_startup_profile("progress_write_main_save", Time.get_ticks_msec() - write_started_msec)
    _print_startup_profile("progress_load_end", Time.get_ticks_msec() - profile_started_msec)
    return _cached_data.duplicate(true)

static func save_data(data: Dictionary) -> void:
    _cached_data = _sanitize_main_data(data)
    _write_json(SAVE_PATH, _cached_data)
    _cache_loaded = true

static func reset_progress() -> Dictionary:
    var data := get_default_data()
    clear_planet_state()
    clear_runtime_planet_data()
    data["planet_state"] = {}
    data["remaining_layer_block_counts"] = _get_initial_layer_block_counts()
    data["best_layer_clear_percents"] = _normalize_layer_clear_percents({})
    save_data(data)
    return data

static func regenerate_planet_state() -> Dictionary:
    var data := load_data()
    data["destroyed_cells"] = []
    data["boss_defeated"] = false
    data["last_run_summary"] = "Open Pit Empire firewall regenerated in editor."
    data["last_run_breakdown"] = {}
    data["attempt_history"] = []
    data["planet_state"] = {}
    data["remaining_layer_block_counts"] = _get_initial_layer_block_counts()
    data["best_layer_clear_percents"] = _normalize_layer_clear_percents({})
    data["purchased_core_upgrades"] = _remove_clear_reward_core_upgrades(data.get("purchased_core_upgrades", []))
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

static func get_xp_wallet() -> int:
    return int(load_data().get("xp_currency", 0))

static func get_core_upgrade_levels() -> Dictionary:
    var levels := {}
    for upgrade_id_variant in load_data().get("purchased_core_upgrades", []):
        levels["core:" + str(upgrade_id_variant)] = 1
    return levels

static func get_xp_upgrade_levels() -> Dictionary:
    return load_data().get("xp_upgrades", {}).duplicate(true)

static func has_editor_assists_used() -> bool:
    return bool(load_data().get("editor_assists_used", false))

static func can_write_leaderboards() -> bool:
    return not has_editor_assists_used()

static func register_demo_core8_time(clear_time_seconds: float) -> bool:
    if clear_time_seconds < 0.0:
        return false
    var data := load_data()
    var existing_time := float(data.get("demo_core8_clock_seconds", -1.0))
    if existing_time >= 0.0 and clear_time_seconds >= existing_time:
        return false
    data["demo_core8_clock_seconds"] = clear_time_seconds
    save_data(data)
    return true

static func get_demo_core8_time() -> float:
    return max(-1.0, float(load_data().get("demo_core8_clock_seconds", -1.0)))

static func register_full_clear_time(clear_time_seconds: float) -> bool:
    if clear_time_seconds < 0.0:
        return false
    var data := load_data()
    var existing_time := float(data.get("full_clear_clock_seconds", -1.0))
    if existing_time >= 0.0 and clear_time_seconds >= existing_time:
        return false
    data["full_clear_clock_seconds"] = clear_time_seconds
    save_data(data)
    return true

static func get_full_clear_time() -> float:
    return max(-1.0, float(load_data().get("full_clear_clock_seconds", -1.0)))

static func mark_editor_assists_used() -> void:
    var data := load_data()
    if bool(data.get("editor_assists_used", false)):
        return
    data["editor_assists_used"] = true
    save_data(data)

static func get_best_persistent_clear_percent() -> float:
    var data := load_data()
    var clear_percent := 0.0
    var breakdown: Variant = data.get("last_run_breakdown", {})
    if breakdown is Dictionary:
        clear_percent = max(clear_percent, float((breakdown as Dictionary).get("persistent_clear", 0.0)))
    var attempt_history: Array = data.get("attempt_history", [])
    for attempt_variant in attempt_history:
        if attempt_variant is Dictionary:
            clear_percent = max(clear_percent, float((attempt_variant as Dictionary).get("persistent_clear", 0.0)))
    return clear_percent

static func get_best_layer_clear_percent(layer_depth: int) -> float:
    return float(get_best_layer_clear_percents().get(clampi(layer_depth, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL), 0.0))

static func get_best_layer_clear_percents() -> Dictionary:
    return _normalize_layer_clear_percents(load_data().get("best_layer_clear_percents", {}))

static func _collect_best_layer_clear_percents(data: Dictionary) -> Dictionary:
    var best_percents := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        best_percents[layer_depth] = 0.0
    var current_percents: Dictionary = _get_current_layer_clear_percents_from_counts(_normalize_layer_block_counts(data.get("remaining_layer_block_counts", {})))
    for layer_depth_variant in current_percents.keys():
        var layer_depth: int = int(layer_depth_variant)
        best_percents[layer_depth] = max(float(best_percents.get(layer_depth, 0.0)), float(current_percents.get(layer_depth_variant, 0.0)))
    var breakdown: Variant = data.get("last_run_breakdown", {})
    if breakdown is Dictionary:
        _merge_layer_clear_percents(best_percents, Dictionary((breakdown as Dictionary).get("layer_clear_percents", {})))
    var attempt_history: Array = data.get("attempt_history", [])
    for attempt_variant in attempt_history:
        if attempt_variant is Dictionary:
            _merge_layer_clear_percents(best_percents, Dictionary((attempt_variant as Dictionary).get("layer_clear_percents", {})))
    return best_percents

static func apply_tree_purchase(upgrade_id: String, level: int, wallet_after_purchase: int) -> void:
    if BALANCE.is_demo_upgrade_hidden(upgrade_id):
        return
    var data := load_data()
    if BALANCE.is_core_upgrade(upgrade_id):
        if BALANCE.is_reward_core_upgrade(upgrade_id):
            return
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
    if BALANCE.is_xp_upgrade(upgrade_id):
        var xp_upgrades: Dictionary = data.get("xp_upgrades", {}).duplicate(true)
        xp_upgrades[upgrade_id] = max(level, int(xp_upgrades.get(upgrade_id, 0)))
        data["xp_upgrades"] = xp_upgrades
        data["xp_currency"] = max(0, wallet_after_purchase)
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
        if BALANCE.is_reward_core_upgrade(upgrade_id):
            return
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
    if BALANCE.is_xp_upgrade(upgrade_id):
        var xp_upgrades: Dictionary = data.get("xp_upgrades", {}).duplicate(true)
        if level <= 0:
            xp_upgrades.erase(upgrade_id)
        else:
            xp_upgrades[upgrade_id] = level
        data["xp_upgrades"] = xp_upgrades
        data["xp_currency"] = max(0, wallet_after_sale)
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
    if bool(results.get("count_leaderboard_time", true)):
        data["run_clock_seconds"] = max(0.0, float(data.get("run_clock_seconds", 0.0)) + max(0.0, float(results.get("sortie_time_seconds", 0.0))))
    data["wallet"] = max(0, int(data.get("wallet", 0)) + int(results.get("money", 0)))
    data["xp_currency"] = max(0, int(data.get("xp_currency", 0)) + int(results.get("xp", 0)))
    data["last_run_summary"] = str(results.get("summary_text", "Open Pit Empire sortie complete."))
    var breakdown := results.duplicate(false)
    breakdown.erase("planet_state")
    breakdown.erase("chat_line_counts")
    breakdown.erase("chat_thread_counts")
    breakdown.erase("chat_active_thread_id")
    breakdown.erase("chat_active_thread_ids")
    breakdown.erase("chat_active_thread_target_count")
    breakdown.erase("chat_event_signatures")
    breakdown.erase("chat_log")
    data["last_run_breakdown"] = breakdown
    var attempt_history: Array = data.get("attempt_history", []).duplicate(true)
    var next_flight_number := attempt_history.size() + 1
    if not attempt_history.is_empty() and attempt_history[0] is Dictionary:
        next_flight_number = max(next_flight_number, int(Dictionary(attempt_history[0]).get("flight", attempt_history.size())) + 1)
    attempt_history.push_front({
        "flight": next_flight_number,
        "summary": str(results.get("summary_text", "Open Pit Empire sortie complete.")),
        "money": int(results.get("money", 0)),
        "xp": int(results.get("xp", 0)),
        "nodes_broken": int(results.get("nodes_broken", 0)),
        "persistent_clear": float(results.get("persistent_clear", 0.0)),
        "depth_level": int(results.get("depth_level", 1)),
    })
    if attempt_history.size() > 8:
        attempt_history.resize(8)
    data["attempt_history"] = attempt_history
    if results.get("destroyed_cells", []) is Array:
        data["destroyed_cells"] = results.get("destroyed_cells", []).duplicate(true)
    if results.get("chat_line_counts", {}) is Dictionary:
        data["chat_line_counts"] = results.get("chat_line_counts", {}).duplicate(true)
    if results.get("chat_thread_counts", {}) is Dictionary:
        data["chat_thread_counts"] = results.get("chat_thread_counts", {}).duplicate(true)
    if results.has("chat_active_thread_id"):
        data["chat_active_thread_id"] = str(results.get("chat_active_thread_id", ""))
    if results.get("chat_active_thread_ids", []) is Array:
        data["chat_active_thread_ids"] = results.get("chat_active_thread_ids", []).duplicate(true)
    if results.has("chat_active_thread_target_count"):
        data["chat_active_thread_target_count"] = clampi(int(results.get("chat_active_thread_target_count", 2)), 2, 3)
    if results.get("chat_event_signatures", {}) is Dictionary:
        data["chat_event_signatures"] = results.get("chat_event_signatures", {}).duplicate(true)
    if results.get("chat_log", []) is Array:
        data["chat_log"] = results.get("chat_log", []).duplicate(true)
    if bool(results.get("bottom_phase_unlocked", false)):
        data["bottom_phase_unlocked"] = true
    if bool(results.get("boss_defeated", false)):
        data["boss_defeated"] = true
    data["core_currency"] = max(0, int(data.get("core_currency", 0)) + int(results.get("core_currency", 0)))
    data["total_cores_destroyed"] = max(0, int(data.get("total_cores_destroyed", 0)) + int(results.get("cores_destroyed", 0)))
    BALANCE.refresh_depth_unlocks(data)
    var used_live_remaining_counts := false
    if results.get("planet_state", {}) is Dictionary:
        var planet_state: Dictionary = Dictionary(results.get("planet_state", {})).duplicate(false)
        if bool(results.get("defer_planet_state_save", false)):
            var merge_result: Dictionary = _try_merge_planet_state(planet_state)
            if bool(merge_result.get("ok", false)):
                _cached_planet_state = Dictionary(merge_result.get("state", {})).duplicate(false)
                data["remaining_layer_block_counts"] = _normalize_layer_block_counts(merge_result.get("remaining_layer_block_counts", {}))
        else:
            var merge_result: Dictionary = _try_merge_planet_state(planet_state)
            if bool(merge_result.get("ok", false)):
                _cached_planet_state = Dictionary(merge_result.get("state", {})).duplicate(false)
                data["remaining_layer_block_counts"] = _normalize_layer_block_counts(merge_result.get("remaining_layer_block_counts", {}))
                _write_planet_state_binary(_cached_planet_state)
    else:
        clear_planet_state()
        data["remaining_layer_block_counts"] = _get_initial_layer_block_counts()
    if results.get("remaining_layer_block_counts", {}) is Dictionary:
        data["remaining_layer_block_counts"] = _normalize_layer_block_counts(results.get("remaining_layer_block_counts", {}))
        used_live_remaining_counts = true
    var layer_clear_percents: Dictionary = _get_current_layer_clear_percents_from_counts(_normalize_layer_block_counts(data.get("remaining_layer_block_counts", {})))
    breakdown["layer_clear_percents"] = layer_clear_percents.duplicate(true)
    breakdown["used_live_remaining_layer_counts"] = used_live_remaining_counts
    data["last_run_breakdown"] = breakdown
    if not attempt_history.is_empty():
        var latest_attempt: Dictionary = Dictionary(attempt_history[0]).duplicate(true)
        latest_attempt["layer_clear_percents"] = layer_clear_percents.duplicate(true)
        attempt_history[0] = latest_attempt
        data["attempt_history"] = attempt_history
    var best_layer_clear_percents: Dictionary = _normalize_layer_clear_percents(data.get("best_layer_clear_percents", {}))
    _merge_layer_clear_percents(best_layer_clear_percents, layer_clear_percents)
    data["best_layer_clear_percents"] = best_layer_clear_percents
    _grant_clear_reward_upgrades(data, layer_clear_percents)
    save_data(data)
    return data

static func bank_partial_run_rewards(results: Dictionary) -> Dictionary:
    var data := load_data()
    var money := int(results.get("money", 0))
    var xp := int(results.get("xp", 0))
    var core_currency := int(results.get("core_currency", 0))
    var cores_destroyed := int(results.get("cores_destroyed", 0))
    var has_chat_update := results.get("chat_line_counts", {}) is Dictionary or results.get("chat_thread_counts", {}) is Dictionary or results.has("chat_active_thread_id") or results.get("chat_active_thread_ids", []) is Array or results.has("chat_active_thread_target_count") or results.get("chat_event_signatures", {}) is Dictionary or results.get("chat_log", []) is Array
    if money <= 0 and xp <= 0 and core_currency <= 0 and cores_destroyed <= 0 and not has_chat_update:
        return data
    data["wallet"] = max(0, int(data.get("wallet", 0)) + money)
    data["xp_currency"] = max(0, int(data.get("xp_currency", 0)) + xp)
    data["core_currency"] = max(0, int(data.get("core_currency", 0)) + core_currency)
    data["total_cores_destroyed"] = max(0, int(data.get("total_cores_destroyed", 0)) + cores_destroyed)
    if results.get("chat_line_counts", {}) is Dictionary:
        data["chat_line_counts"] = results.get("chat_line_counts", {}).duplicate(true)
    if results.get("chat_thread_counts", {}) is Dictionary:
        data["chat_thread_counts"] = results.get("chat_thread_counts", {}).duplicate(true)
    if results.has("chat_active_thread_id"):
        data["chat_active_thread_id"] = str(results.get("chat_active_thread_id", ""))
    if results.get("chat_active_thread_ids", []) is Array:
        data["chat_active_thread_ids"] = results.get("chat_active_thread_ids", []).duplicate(true)
    if results.has("chat_active_thread_target_count"):
        data["chat_active_thread_target_count"] = clampi(int(results.get("chat_active_thread_target_count", 2)), 2, 3)
    if results.get("chat_event_signatures", {}) is Dictionary:
        data["chat_event_signatures"] = results.get("chat_event_signatures", {}).duplicate(true)
    if results.get("chat_log", []) is Array:
        data["chat_log"] = results.get("chat_log", []).duplicate(true)
    if bool(results.get("bottom_phase_unlocked", false)):
        data["bottom_phase_unlocked"] = true
    if bool(results.get("boss_defeated", false)):
        data["boss_defeated"] = true
    if money > 0 or xp > 0 or core_currency > 0 or cores_destroyed > 0:
        var attempt_history: Array = data.get("attempt_history", []).duplicate(true)
        var next_flight_number := attempt_history.size() + 1
        if not attempt_history.is_empty() and attempt_history[0] is Dictionary:
            next_flight_number = max(next_flight_number, int(Dictionary(attempt_history[0]).get("flight", attempt_history.size())) + 1)
        attempt_history.push_front({
            "flight": next_flight_number,
            "summary": str(results.get("summary_text", "Open Pit Empire rewards banked before defense.")),
            "money": money,
            "xp": xp,
            "nodes_broken": int(results.get("nodes_broken", 0)),
            "persistent_clear": float(results.get("persistent_clear", 0.0)),
            "depth_level": int(results.get("depth_level", 1)),
        })
        if attempt_history.size() > 8:
            attempt_history.resize(8)
        data["attempt_history"] = attempt_history
        data["last_run_summary"] = str(results.get("summary_text", "Open Pit Empire rewards banked before defense."))
        BALANCE.refresh_depth_unlocks(data)
    save_data(data)
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data := load_data()
    data["selected_depth_level"] = clampi(depth_level, MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
    save_data(data)
    return data

static func get_display_depth_tier(depth_level: int) -> int:
    return 1

static func load_planet_state(depth_level: int = -1) -> Dictionary:
    if _planet_save_pending:
        flush_async_planet_state_save()
    if _cached_planet_state.is_empty():
        var parsed: Variant = _read_planet_state_binary()
        if parsed is Dictionary:
            _cached_planet_state = Dictionary(parsed).duplicate(true)
        else:
            var legacy: Variant = _read_json(LEGACY_PLANET_SAVE_PATH)
            if legacy is Dictionary:
                _cached_planet_state = Dictionary(legacy).duplicate(true)
    if depth_level >= MIN_START_DEPTH_LEVEL and not _cached_planet_state.is_empty():
        var saved_depth_level: int = int(_cached_planet_state.get("depth_level", MIN_START_DEPTH_LEVEL))
        if saved_depth_level != depth_level:
            return {}
    return _cached_planet_state.duplicate(true)

static func save_planet_state(state: Dictionary) -> bool:
    var merge_result: Dictionary = _try_merge_planet_state(state)
    if not bool(merge_result.get("ok", false)):
        if state.get("remaining_layer_block_counts", {}) is Dictionary:
            _save_remaining_layer_counts(Dictionary(state.get("remaining_layer_block_counts", {})))
        return false
    _cached_planet_state = Dictionary(merge_result.get("state", {})).duplicate(false)
    _save_remaining_layer_counts_from_merge(merge_result)
    return _write_planet_state_binary(_cached_planet_state)

static func start_async_planet_state_save(state: Dictionary) -> void:
    flush_async_planet_state_save()
    var merge_result: Dictionary = _try_merge_planet_state(state)
    if not bool(merge_result.get("ok", false)):
        if state.get("remaining_layer_block_counts", {}) is Dictionary:
            _save_remaining_layer_counts(Dictionary(state.get("remaining_layer_block_counts", {})))
        _planet_save_ok = false
        _planet_save_pending = false
        _planet_save_thread = null
        return
    _cached_planet_state = Dictionary(merge_result.get("state", {})).duplicate(false)
    _save_remaining_layer_counts_from_merge(merge_result)
    _planet_save_ok = true
    _planet_save_pending = true
    _planet_save_thread = Thread.new()
    var err := _planet_save_thread.start(Callable(OpenPitEmpireProgress, "_thread_write_planet_state").bind(_cached_planet_state.duplicate(false)))
    if err != OK:
        _planet_save_pending = false
        _planet_save_thread = null
        _planet_save_ok = save_planet_state(_cached_planet_state)

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

static func peek_cached_planet_state() -> Dictionary:
    return _cached_planet_state.duplicate(true)

static func clear_cache() -> void:
    flush_async_planet_state_save()
    _cached_data = {}
    _cache_loaded = false
    _cached_planet_state = {}
    clear_runtime_planet_data()

static func _sanitize_main_data(data: Dictionary) -> Dictionary:
    var sanitized := data.duplicate(false)
    sanitized["planet_state"] = {}
    sanitized["deepest_level_unlocked"] = clampi(int(sanitized.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    sanitized["selected_depth_level"] = clampi(int(sanitized.get("selected_depth_level", sanitized["deepest_level_unlocked"])), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    sanitized["planet_layout_version"] = BALANCE.PLANET_LAYOUT_VERSION
    var breakdown: Variant = sanitized.get("last_run_breakdown", {})
    if breakdown is Dictionary:
        var breakdown_dict: Dictionary = Dictionary(breakdown).duplicate(false)
        breakdown_dict.erase("planet_state")
        sanitized["last_run_breakdown"] = breakdown_dict
    var attempt_history: Variant = sanitized.get("attempt_history", [])
    if attempt_history is Array:
        var sanitized_attempts: Array = []
        for attempt_variant: Variant in attempt_history:
            if attempt_variant is Dictionary:
                var attempt_dict: Dictionary = Dictionary(attempt_variant).duplicate(false)
                attempt_dict.erase("planet_state")
                sanitized_attempts.append(attempt_dict)
            else:
                sanitized_attempts.append(attempt_variant)
        sanitized["attempt_history"] = sanitized_attempts
    if sanitized.get("upgrades", {}) is Dictionary:
        sanitized["upgrades"] = Dictionary(sanitized.get("upgrades", {})).duplicate(true)
    if sanitized.get("xp_upgrades", {}) is Dictionary:
        sanitized["xp_upgrades"] = Dictionary(sanitized.get("xp_upgrades", {})).duplicate(true)
    if sanitized.get("purchased_core_upgrades", []) is Array:
        sanitized["purchased_core_upgrades"] = Array(sanitized.get("purchased_core_upgrades", [])).duplicate(true)
    sanitized["run_clock_seconds"] = max(0.0, float(sanitized.get("run_clock_seconds", 0.0)))
    sanitized["demo_core8_clock_seconds"] = float(sanitized.get("demo_core8_clock_seconds", -1.0))
    sanitized["full_clear_clock_seconds"] = float(sanitized.get("full_clear_clock_seconds", -1.0))
    sanitized["demo_core8_end_screen_shown"] = bool(sanitized.get("demo_core8_end_screen_shown", false))
    if sanitized.get("chat_line_counts", {}) is Dictionary:
        sanitized["chat_line_counts"] = Dictionary(sanitized.get("chat_line_counts", {})).duplicate(true)
    else:
        sanitized["chat_line_counts"] = {}
    if sanitized.get("chat_thread_counts", {}) is Dictionary:
        sanitized["chat_thread_counts"] = Dictionary(sanitized.get("chat_thread_counts", {})).duplicate(true)
    else:
        sanitized["chat_thread_counts"] = {}
    sanitized["chat_active_thread_id"] = str(sanitized.get("chat_active_thread_id", ""))
    if sanitized.get("chat_active_thread_ids", []) is Array:
        sanitized["chat_active_thread_ids"] = Array(sanitized.get("chat_active_thread_ids", [])).duplicate(true)
    else:
        sanitized["chat_active_thread_ids"] = []
    sanitized["chat_active_thread_target_count"] = clampi(int(sanitized.get("chat_active_thread_target_count", 2)), 2, 3)
    if sanitized.get("chat_event_signatures", {}) is Dictionary:
        sanitized["chat_event_signatures"] = Dictionary(sanitized.get("chat_event_signatures", {})).duplicate(true)
    else:
        sanitized["chat_event_signatures"] = {}
    if sanitized.get("chat_log", []) is Array:
        var chat_log: Array = Array(sanitized.get("chat_log", [])).duplicate(true)
        while chat_log.size() > 120:
            chat_log.remove_at(0)
        sanitized["chat_log"] = chat_log
    else:
        sanitized["chat_log"] = []
    sanitized["editor_assists_used"] = bool(sanitized.get("editor_assists_used", false))
    sanitized["remaining_layer_block_counts"] = _normalize_layer_block_counts(sanitized.get("remaining_layer_block_counts", {}))
    sanitized["best_layer_clear_percents"] = _normalize_layer_clear_percents(sanitized.get("best_layer_clear_percents", {}))
    BALANCE.refresh_depth_unlocks(sanitized)
    return sanitized

static func _refresh_best_layer_clear_cache(data: Dictionary) -> void:
    data["best_layer_clear_percents"] = _collect_best_layer_clear_percents(data)

static func _refresh_remaining_layer_count_cache(data: Dictionary) -> void:
    data["remaining_layer_block_counts"] = _scan_remaining_layer_block_counts()

static func _grant_clear_reward_upgrades(data: Dictionary, layer_clear_percents: Dictionary) -> void:
    var purchased: Array = data.get("purchased_core_upgrades", []).duplicate()
    for reward_id in BALANCE.get_clear_reward_core_upgrades_for_layer_progress(layer_clear_percents):
        var trimmed: String = reward_id.trim_prefix(BALANCE.CORE_PREFIX)
        if trimmed not in purchased:
            purchased.append(trimmed)
    data["purchased_core_upgrades"] = purchased

static func _remove_clear_reward_core_upgrades(source: Variant) -> Array:
    var purchased: Array = source.duplicate() if source is Array else []
    var filtered: Array = []
    for upgrade_id_variant in purchased:
        var upgrade_id := str(upgrade_id_variant)
        if upgrade_id in BALANCE.REWARD_CORE_UPGRADES:
            continue
        filtered.append(upgrade_id_variant)
    return filtered

static func _merge_layer_clear_percents(target: Dictionary, source: Dictionary) -> void:
    for layer_depth_variant in source.keys():
        var layer_depth: int = int(layer_depth_variant)
        if layer_depth < MIN_START_DEPTH_LEVEL or layer_depth > MAX_DEPTH_LEVEL:
            continue
        target[layer_depth] = max(float(target.get(layer_depth, 0.0)), float(source.get(layer_depth_variant, 0.0)))

static func _normalize_layer_clear_percents(source: Variant) -> Dictionary:
    var normalized := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        normalized[layer_depth] = 0.0
    if not (source is Dictionary):
        return normalized
    for layer_depth_variant in (source as Dictionary).keys():
        var layer_depth: int = int(layer_depth_variant)
        if layer_depth < MIN_START_DEPTH_LEVEL or layer_depth > MAX_DEPTH_LEVEL:
            continue
        normalized[layer_depth] = clampf(float((source as Dictionary).get(layer_depth_variant, 0.0)), 0.0, 100.0)
    return normalized

static func _has_complete_layer_clear_cache(data: Dictionary) -> bool:
    var cache: Variant = data.get("best_layer_clear_percents", {})
    if not (cache is Dictionary):
        return false
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        if not (cache as Dictionary).has(layer_depth) and not (cache as Dictionary).has(str(layer_depth)):
            return false
    return true

static func _get_current_layer_clear_percents() -> Dictionary:
    return _get_current_layer_clear_percents_from_counts(_normalize_layer_block_counts(load_data().get("remaining_layer_block_counts", {})))

static func _get_current_layer_clear_percents_from_counts(remaining_counts: Dictionary) -> Dictionary:
    var initial_counts: Dictionary = _get_initial_layer_block_counts()
    var percents := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        var initial_count: int = int(initial_counts.get(layer_depth, 0))
        var remaining_count: int = int(remaining_counts.get(layer_depth, initial_count))
        if initial_count <= 0:
            percents[layer_depth] = 0.0
            continue
        var cleared_count: int = maxi(0, initial_count - remaining_count)
        percents[layer_depth] = clampf(100.0 * float(cleared_count) / float(initial_count), 0.0, 100.0)
    return percents

static func _get_initial_layer_block_counts() -> Dictionary:
    if not _initial_layer_block_counts.is_empty():
        return _initial_layer_block_counts.duplicate(true)
    var cached_counts: Dictionary = INITIAL_LAYER_BLOCK_COUNTS_BY_LAYOUT_VERSION.get(BALANCE.PLANET_LAYOUT_VERSION, {})
    if _has_complete_layer_depth_dictionary(cached_counts):
        _initial_layer_block_counts = _normalize_layer_count_constant(cached_counts)
        return _initial_layer_block_counts.duplicate(true)
    var counts := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        counts[layer_depth] = 0
    var planet_data = PLANET_DATA_SCRIPT.new()
    var rng := RandomNumberGenerator.new()
    rng.seed = 1
    planet_data.generate_sync(MIN_START_DEPTH_LEVEL, {}, BALANCE, rng)
    for block_variant in planet_data.blocks.values():
        var block: Dictionary = block_variant
        if int(block.get("type", PLANET_DATA_SCRIPT.BlockType.NORMAL)) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
            continue
        if bool(block.get("unbreakable", false)):
            continue
        var layer_depth: int = clampi(int(block.get("layer_depth", 1)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
        counts[layer_depth] = int(counts.get(layer_depth, 0)) + 1
    _initial_layer_block_counts = counts.duplicate(true)
    return counts

static func _normalize_layer_count_constant(source: Dictionary) -> Dictionary:
    var normalized := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        normalized[layer_depth] = maxi(0, int(source.get(layer_depth, source.get(str(layer_depth), 0))))
    return normalized

static func _scan_remaining_layer_block_counts() -> Dictionary:
    var profile_started_msec := Time.get_ticks_msec()
    var counts := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        counts[layer_depth] = 0
    var state := _cached_planet_state.duplicate(true)
    if state.is_empty():
        var load_state_started_msec := Time.get_ticks_msec()
        state = load_planet_state()
        _print_startup_profile("progress_scan_load_planet_state", Time.get_ticks_msec() - load_state_started_msec)
    if state.is_empty():
        var initial_started_msec := Time.get_ticks_msec()
        var initial_counts := _get_initial_layer_block_counts()
        _print_startup_profile("progress_scan_initial_counts", Time.get_ticks_msec() - initial_started_msec)
        _print_startup_profile("progress_scan_remaining_layer_block_counts", Time.get_ticks_msec() - profile_started_msec)
        return initial_counts
    var format_version: int = int(state.get("format_version", 1))
    if format_version >= 2 and state.get("sections", {}) is Dictionary:
        var sections: Dictionary = state.get("sections", {})
        var section_scan_started_msec := Time.get_ticks_msec()
        var legacy_planet_data = null
        for section_variant in sections.values():
            for row_variant in Array(section_variant):
                var row: Array = row_variant
                if format_version >= 3:
                    if row.size() < 10:
                        continue
                    if (row.size() > 10 and bool(row[10])) or int(row[2]) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
                        continue
                    var layer_depth_v3: int = clampi(int(row[9]), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
                    counts[layer_depth_v3] = int(counts.get(layer_depth_v3, 0)) + 1
                    continue
                if row.size() < 10:
                    continue
                if int(row[2]) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
                    continue
                if legacy_planet_data == null:
                    legacy_planet_data = PLANET_DATA_SCRIPT.new()
                var layer_depth_v2: int = clampi(legacy_planet_data.get_depth_level_for_pos(Vector2i(int(row[0]), int(row[1])), MAX_DEPTH_LEVEL), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
                counts[layer_depth_v2] = int(counts.get(layer_depth_v2, 0)) + 1
        _print_startup_profile("progress_scan_sections count=%d" % sections.size(), Time.get_ticks_msec() - section_scan_started_msec)
        _print_startup_profile("progress_scan_remaining_layer_block_counts", Time.get_ticks_msec() - profile_started_msec)
        return counts
    var blocks: Dictionary = state.get("blocks", {})
    for key_variant in blocks.keys():
        var arr: Array = blocks.get(key_variant, [])
        if arr.size() < 9:
            continue
        if int(arr[0]) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
            continue
        if arr.size() > 9 and bool(arr[9]):
            continue
        var layer_depth: int = clampi(int(arr[8]), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
        counts[layer_depth] = int(counts.get(layer_depth, 0)) + 1
    _print_startup_profile("progress_scan_legacy_blocks count=%d" % blocks.size(), Time.get_ticks_msec() - profile_started_msec)
    return counts

static func _normalize_layer_block_counts(source: Variant) -> Dictionary:
    var normalized := {}
    if source is Dictionary and _has_complete_layer_depth_dictionary(source):
        var source_dict: Dictionary = source
        for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
            if source_dict.has(layer_depth):
                normalized[layer_depth] = maxi(0, int(source_dict.get(layer_depth, 0)))
            else:
                normalized[layer_depth] = maxi(0, int(source_dict.get(str(layer_depth), 0)))
        return normalized
    var initial_counts: Dictionary = _get_initial_layer_block_counts()
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        normalized[layer_depth] = int(initial_counts.get(layer_depth, 0))
    if not (source is Dictionary):
        return normalized
    for layer_depth_variant in (source as Dictionary).keys():
        var layer_depth: int = int(layer_depth_variant)
        if layer_depth < MIN_START_DEPTH_LEVEL or layer_depth > MAX_DEPTH_LEVEL:
            continue
        normalized[layer_depth] = maxi(0, int((source as Dictionary).get(layer_depth_variant, initial_counts.get(layer_depth, 0))))
    return normalized

static func _has_complete_layer_depth_dictionary(source: Variant) -> bool:
    if not (source is Dictionary):
        return false
    var source_dict: Dictionary = source
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        if not source_dict.has(layer_depth) and not source_dict.has(str(layer_depth)):
            return false
    return true

static func _has_complete_remaining_layer_count_cache(data: Dictionary) -> bool:
    var cache: Variant = data.get("remaining_layer_block_counts", {})
    if not (cache is Dictionary):
        return false
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        if not (cache as Dictionary).has(layer_depth) and not (cache as Dictionary).has(str(layer_depth)):
            return false
    return true

static func _count_layer_blocks_in_section(section_rows: Array, format_version: int) -> Dictionary:
    var counts := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        counts[layer_depth] = 0
    var legacy_planet_data = null
    for row_variant in section_rows:
        var row: Array = row_variant
        if format_version >= 3:
            if row.size() < 10:
                continue
            if int(row[2]) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
                continue
            if row.size() > 10 and bool(row[10]):
                continue
            var layer_depth_v3: int = clampi(int(row[9]), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
            counts[layer_depth_v3] = int(counts.get(layer_depth_v3, 0)) + 1
            continue
        if row.size() < 10:
            continue
        if int(row[2]) == int(PLANET_DATA_SCRIPT.BlockType.CORE):
            continue
        if legacy_planet_data == null:
            legacy_planet_data = PLANET_DATA_SCRIPT.new()
        var layer_depth_v2: int = clampi(legacy_planet_data.get_depth_level_for_pos(Vector2i(int(row[0]), int(row[1])), MAX_DEPTH_LEVEL), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
        counts[layer_depth_v2] = int(counts.get(layer_depth_v2, 0)) + 1
    return counts

static func _count_layer_blocks_in_sections(sections: Dictionary, format_version: int) -> Dictionary:
    var counts := {}
    for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
        counts[layer_depth] = 0
    for section_variant in sections.values():
        var section_counts: Dictionary = _count_layer_blocks_in_section(Array(section_variant), format_version)
        for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
            counts[layer_depth] = int(counts.get(layer_depth, 0)) + int(section_counts.get(layer_depth, 0))
    return counts

static func _save_remaining_layer_counts_from_merge(merge_result: Dictionary) -> void:
    if not bool(merge_result.get("ok", false)):
        return
    _save_remaining_layer_counts(Dictionary(merge_result.get("remaining_layer_block_counts", {})))

static func _save_remaining_layer_counts(layer_counts: Dictionary) -> void:
    var data := _cached_data.duplicate(true) if _cache_loaded else load_data()
    data["remaining_layer_block_counts"] = _normalize_layer_block_counts(layer_counts)
    var layer_clear_percents: Dictionary = _get_current_layer_clear_percents_from_counts(data["remaining_layer_block_counts"])
    var best_layer_clear_percents: Dictionary = _normalize_layer_clear_percents(data.get("best_layer_clear_percents", {}))
    _merge_layer_clear_percents(best_layer_clear_percents, layer_clear_percents)
    data["best_layer_clear_percents"] = best_layer_clear_percents
    _cached_data = _sanitize_main_data(data)
    _cache_loaded = true
    _write_json(SAVE_PATH, _cached_data)

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
    var profile_started_msec := Time.get_ticks_msec()
    var full_state: Variant = _read_planet_full_file()
    if full_state is Dictionary:
        _print_startup_profile("progress_read_planet_state_full", Time.get_ticks_msec() - profile_started_msec)
        return full_state
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
    if int(state.get("planet_layout_version", 0)) != BALANCE.PLANET_LAYOUT_VERSION:
        return null
    var sections := {}
    var expected_section_ids: Array = state.get("section_ids", [])
    if expected_section_ids.is_empty():
        var section_count: int = int(state.get("angle_slices", 10)) * int(state.get("depth_slices", 10))
        for section_id in range(section_count):
            var fallback_path := _planet_section_path(section_id)
            if FileAccess.file_exists(fallback_path):
                expected_section_ids.append(section_id)
    for section_id_variant in expected_section_ids:
        var section_id: int = int(section_id_variant)
        var section_data: Variant = _read_planet_section_file(_planet_section_path(section_id))
        if not (section_data is Array):
            return null
        sections[section_id] = Array(section_data).duplicate(true)
    state["sections"] = sections
    _print_startup_profile("progress_read_planet_state_binary sections=%d" % sections.size(), Time.get_ticks_msec() - profile_started_msec)
    return state

static func _read_planet_full_file() -> Variant:
    if not FileAccess.file_exists(PLANET_FULL_PATH):
        return null
    var file := FileAccess.open(PLANET_FULL_PATH, FileAccess.READ)
    if file == null:
        return null
    var state: Variant = file.get_var()
    file.close()
    if not (state is Dictionary):
        return null
    if int(Dictionary(state).get("planet_layout_version", 0)) != BALANCE.PLANET_LAYOUT_VERSION:
        return null
    return state

static func _print_startup_profile(label: String, elapsed_msec: int = -1) -> void:
    if not Util.is_open_pit_game_active():
        return
    if elapsed_msec >= 0 and elapsed_msec < 8:
        return
    var since_scene_request_msec: int = Time.get_ticks_msec() - Global.open_pit_upgrade_startup_started_msec if Global.open_pit_upgrade_startup_started_msec > 0 else 0
    if elapsed_msec >= 0:
        print("[OpenPitUpgradeStartup] %s %.3fms since_request=%.3fms" % [label, float(elapsed_msec), float(since_scene_request_msec)])
    else:
        print("[OpenPitUpgradeStartup] %s since_request=%.3fms" % [label, float(since_scene_request_msec)])

static func _write_planet_state_binary(state: Dictionary) -> bool:
    if DirAccess.make_dir_recursive_absolute(PLANET_SAVE_DIR) != OK and not DirAccess.dir_exists_absolute(PLANET_SAVE_DIR):
        return false
    var payload: Dictionary = state.duplicate(false)
    payload["planet_layout_version"] = BALANCE.PLANET_LAYOUT_VERSION
    var sections: Dictionary = payload.get("sections", {})
    var section_ids: Array = []
    for section_id_variant in sections.keys():
        section_ids.append(int(section_id_variant))
    section_ids.sort()
    var dirty_section_ids: Array = payload.get("_dirty_section_ids", section_ids).duplicate()
    payload["section_ids"] = section_ids
    var full_payload := payload.duplicate(true)
    payload.erase("sections")
    payload.erase("_dirty_section_ids")
    for section_id_variant in dirty_section_ids:
        var section_id: int = int(section_id_variant)
        if not sections.has(section_id) and not sections.has(str(section_id)):
            continue
        var section_payload: Variant = sections.get(section_id, sections.get(str(section_id), []))
        if not _write_var_file_atomically(_planet_section_path(section_id), section_payload):
            return false
    if not _write_var_file_atomically(PLANET_FULL_PATH, full_payload):
        return false
    return _write_var_file_atomically(PLANET_META_PATH, payload)

static func _clear_planet_state_binary() -> void:
    for section_id in range(100):
        var section_path := _planet_section_path(section_id)
        if FileAccess.file_exists(section_path):
            DirAccess.remove_absolute(section_path)
    if FileAccess.file_exists(PLANET_META_PATH):
        DirAccess.remove_absolute(PLANET_META_PATH)
    if FileAccess.file_exists(PLANET_FULL_PATH):
        DirAccess.remove_absolute(PLANET_FULL_PATH)
    if FileAccess.file_exists(LEGACY_PLANET_SAVE_PATH):
        DirAccess.remove_absolute(LEGACY_PLANET_SAVE_PATH)

static func _planet_section_path(section_id: int) -> String:
    return "%s/section_%03d.save" % [PLANET_SAVE_DIR, section_id]

static func _planet_temp_path(path: String) -> String:
    return "%s.tmp" % path

static func _planet_backup_path(path: String) -> String:
    return "%s.bak" % path

static func _read_planet_section_file(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null
    var data: Variant = file.get_var()
    file.close()
    return data

static func _write_var_file_atomically(path: String, data: Variant) -> bool:
    var temp_path := _planet_temp_path(path)
    var backup_path := _planet_backup_path(path)
    if FileAccess.file_exists(temp_path):
        DirAccess.remove_absolute(temp_path)
    if FileAccess.file_exists(backup_path):
        DirAccess.remove_absolute(backup_path)
    var temp_file := FileAccess.open(temp_path, FileAccess.WRITE)
    if temp_file == null:
        return false
    temp_file.store_var(data, true)
    temp_file.close()
    if FileAccess.file_exists(path):
        if DirAccess.rename_absolute(path, backup_path) != OK:
            DirAccess.remove_absolute(temp_path)
            return false
    if DirAccess.rename_absolute(temp_path, path) != OK:
        if FileAccess.file_exists(backup_path):
            DirAccess.rename_absolute(backup_path, path)
        DirAccess.remove_absolute(temp_path)
        return false
    if FileAccess.file_exists(backup_path):
        DirAccess.remove_absolute(backup_path)
    return true

static func _merge_planet_state(update: Dictionary) -> Dictionary:
    var merge_result: Dictionary = _try_merge_planet_state(update)
    if bool(merge_result.get("ok", false)):
        return Dictionary(merge_result.get("state", {})).duplicate(true)
    return {}

static func _try_merge_planet_state(update: Dictionary) -> Dictionary:
    var merged: Dictionary = {}
    var has_full_base := false
    var remaining_layer_block_counts := _normalize_layer_block_counts(_cached_data.get("remaining_layer_block_counts", {}) if _cache_loaded else {})
    if not _cached_planet_state.is_empty():
        if int(_cached_planet_state.get("planet_layout_version", 0)) == BALANCE.PLANET_LAYOUT_VERSION:
            merged = _cached_planet_state.duplicate(false)
            has_full_base = true
    else:
        var existing: Variant = _read_planet_state_binary()
        if existing is Dictionary:
            merged = Dictionary(existing).duplicate(false)
            has_full_base = true
    if int(merged.get("planet_layout_version", 0)) != BALANCE.PLANET_LAYOUT_VERSION:
        merged = {}
        has_full_base = false
    var update_sections: Dictionary = update.get("sections", {})
    var expected_section_count: int = int(update.get("angle_slices", 10)) * int(update.get("depth_slices", 10))
    var is_partial_update: bool = not update_sections.is_empty() and update_sections.size() < max(1, expected_section_count)
    if is_partial_update and not has_full_base:
        return {"ok": false, "state": {}}
    var update_depth_level: int = int(update.get("depth_level", -1))
    if update_depth_level >= MIN_START_DEPTH_LEVEL:
        var merged_depth_level: int = int(merged.get("depth_level", update_depth_level))
        if merged_depth_level != update_depth_level:
            merged = {}
            has_full_base = false
            if is_partial_update:
                return {"ok": false, "state": {}}
    for key_variant in update.keys():
        var key: String = str(key_variant)
        if key == "sections":
            continue
        merged[key] = update[key_variant]
    merged["planet_layout_version"] = BALANCE.PLANET_LAYOUT_VERSION
    var merged_sections: Dictionary = Dictionary(merged.get("sections", {})).duplicate(false)
    var format_version: int = int(update.get("format_version", merged.get("format_version", 1)))
    var dirty_section_ids: Array = []
    for section_id_variant in update_sections.keys():
        var section_id: int = int(section_id_variant)
        dirty_section_ids.append(section_id)
        var old_counts: Dictionary = _count_layer_blocks_in_section(Array(merged_sections.get(section_id, [])), format_version)
        var new_section: Array = Array(update_sections[section_id_variant])
        var new_counts: Dictionary = _count_layer_blocks_in_section(new_section, format_version)
        for layer_depth in range(MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL + 1):
            remaining_layer_block_counts[layer_depth] = maxi(
                0,
                int(remaining_layer_block_counts.get(layer_depth, 0)) - int(old_counts.get(layer_depth, 0)) + int(new_counts.get(layer_depth, 0))
            )
        merged_sections[section_id] = new_section
    merged["sections"] = merged_sections
    merged["_dirty_section_ids"] = dirty_section_ids
    if not is_partial_update:
        remaining_layer_block_counts = _count_layer_blocks_in_sections(merged_sections, format_version)
    if update.get("remaining_layer_block_counts", {}) is Dictionary:
        remaining_layer_block_counts = _normalize_layer_block_counts(update.get("remaining_layer_block_counts", {}))
    return {"ok": true, "state": merged, "remaining_layer_block_counts": remaining_layer_block_counts}
