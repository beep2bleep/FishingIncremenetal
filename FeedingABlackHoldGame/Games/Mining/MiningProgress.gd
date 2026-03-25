extends RefCounted
class_name MiningProgress

const MINING_BALANCE := preload("res://Games/Mining/MiningBalance.gd")
const SAVE_PATH := "user://mining_mode_save_v1.json"
const MAX_DEPTH_LEVEL := MINING_BALANCE.MAX_DEPTH_LEVEL

const DEFAULT_DATA := {
    "wallet": 0,
    "xp": 0,
    "player_level": 1,
    "deepest_level_unlocked": 1,
    "selected_depth_level": 1,
    "upgrades": {},
    "last_run_summary": "No mining run completed yet.",
    "last_run_breakdown": {},
    "summary_hint_history": []
}

static func get_default_data() -> Dictionary:
    return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
    return MINING_BALANCE.get_upgrade_catalog()

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
    if not (data.get("summary_hint_history", []) is Array):
        data["summary_hint_history"] = []
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
    var previous_level: int = max(1, int(data.get("player_level", 1)))
    var previous_deepest_level: int = max(1, int(data.get("deepest_level_unlocked", 1)))
    data["wallet"] = max(0, int(data.get("wallet", 0)) + int(results.get("money", 0)))
    data["xp"] = max(0, int(data.get("xp", 0)) + int(results.get("xp", 0)))
    data["player_level"] = get_level_for_total_xp(int(data["xp"]))
    var new_level: int = max(1, int(data.get("player_level", previous_level)))
    data["last_run_summary"] = str(results.get("summary_text", "Mining run complete."))
    data["last_run_breakdown"] = results.duplicate(true)
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", 1)), int(results.get("depth_level", 1)))
    _refresh_depth_unlocks(data)
    var new_deepest_level: int = max(previous_deepest_level, int(data.get("deepest_level_unlocked", previous_deepest_level)))
    if new_deepest_level > previous_deepest_level:
        data["selected_depth_level"] = new_deepest_level
    save_data(data)
    _track_level_progression_events(previous_level, new_level, int(data.get("xp", 0)), results)
    return data

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data: Dictionary = load_data()
    data["selected_depth_level"] = clampi(depth_level, 1, int(data.get("deepest_level_unlocked", 1)))
    save_data(data)
    return data

static func get_level_for_total_xp(total_xp: int) -> int:
    return MINING_BALANCE.get_level_for_total_xp(total_xp)

static func get_xp_to_next_level(level: int) -> int:
    return MINING_BALANCE.get_xp_to_next_level(level)

static func get_level_progress(data: Dictionary) -> Dictionary:
    return MINING_BALANCE.get_level_progress(data)

static func _refresh_depth_unlocks(data: Dictionary) -> void:
    MINING_BALANCE.refresh_depth_unlocks(data)

static func _track_level_progression_events(previous_level: int, new_level: int, total_xp: int, results: Dictionary) -> void:
    if new_level <= previous_level:
        return
    var ga_manager: Node = _get_game_analytics_manager()
    if ga_manager == null:
        return
    var depth_level: int = int(results.get("depth_level", 1))
    var run_xp: int = int(results.get("xp", 0))
    for completed_level in range(previous_level, new_level):
        ga_manager.call(
            "track_progression_event",
            "complete",
            "mining",
            "player_level",
            "level_%d" % completed_level,
            total_xp,
            {
                "completed_level": completed_level,
                "new_player_level": new_level,
                "total_xp": total_xp,
                "run_xp": run_xp,
                "depth_level": depth_level,
            }
        )
    ga_manager.call(
        "track_progression_event",
        "start",
        "mining",
        "player_level",
        "level_%d" % new_level,
        null,
        {
            "player_level": new_level,
            "total_xp": total_xp,
            "depth_level": depth_level,
        }
    )

static func _get_game_analytics_manager() -> Node:
    var main_loop: MainLoop = Engine.get_main_loop()
    if main_loop is SceneTree:
        return (main_loop as SceneTree).root.get_node_or_null("GameAnalytics")
    return null
