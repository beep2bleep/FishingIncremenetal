extends RefCounted
class_name MiningProgress

const MINING_BALANCE := preload("res://Games/Mining/MiningBalance.gd")
const SAVE_PATH := "user://mining_mode_save_v1.json"
const MAX_DEPTH_LEVEL := MINING_BALANCE.MAX_DEPTH_LEVEL
const MIN_START_DEPTH_LEVEL := 1

const DEFAULT_DATA := {
    "wallet": 0,
    "xp": 0,
    "player_level": 1,
    "deepest_level_unlocked": MIN_START_DEPTH_LEVEL,
    "selected_depth_level": MIN_START_DEPTH_LEVEL,
    "upgrades": {},
    "depth_frontier_attempts": {},
    "last_run_summary": "No mining run completed yet.",
    "last_run_breakdown": {},
    "summary_hint_history": []
}

static func get_display_depth_tier(depth_level: int) -> int:
    return max(1, depth_level - MIN_START_DEPTH_LEVEL + 1)

static func get_depth_level_for_display_tier(display_tier: int) -> int:
    return clampi(MIN_START_DEPTH_LEVEL + max(1, display_tier) - 1, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)

static func get_max_display_depth_tier() -> int:
    return get_display_depth_tier(MAX_DEPTH_LEVEL)

static func get_depth_tier_progression_token(depth_level: int) -> String:
    return "tier_%d" % get_display_depth_tier(depth_level)

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
    var deepest_before_refresh: int = clampi(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    var selected_before_refresh: int = clampi(int(data.get("selected_depth_level", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, deepest_before_refresh)
    data["deepest_level_unlocked"] = deepest_before_refresh
    data["selected_depth_level"] = selected_before_refresh
    _refresh_depth_unlocks(data)
    data["deepest_level_unlocked"] = clampi(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", selected_before_refresh)), MIN_START_DEPTH_LEVEL, int(data["deepest_level_unlocked"]))
    var repaired_missing_fields := false
    if not (data.get("depth_frontier_attempts", {}) is Dictionary):
        data["depth_frontier_attempts"] = {}
        repaired_missing_fields = true
    if not (data.get("summary_hint_history", []) is Array):
        data["summary_hint_history"] = []
        repaired_missing_fields = true
    if repaired_missing_fields or int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)) != deepest_before_refresh or int(data.get("selected_depth_level", selected_before_refresh)) != selected_before_refresh:
        save_data(data)
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

static func apply_tree_sale(upgrade_id: String, level: int, wallet_after_sale: int) -> void:
    var data: Dictionary = load_data()
    var upgrades: Dictionary = data.get("upgrades", {})
    var safe_level: int = max(0, level)
    if safe_level > 0:
        upgrades[upgrade_id] = safe_level
    else:
        upgrades.erase(upgrade_id)
    data["upgrades"] = upgrades
    data["wallet"] = max(0, wallet_after_sale)
    _refresh_depth_unlocks(data)
    save_data(data)

static func apply_run_results(results: Dictionary) -> Dictionary:
    var data: Dictionary = load_data()
    var previous_level: int = max(1, int(data.get("player_level", 1)))
    var previous_deepest_level: int = max(MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
    data["wallet"] = max(0, int(data.get("wallet", 0)) + int(results.get("money", 0)))
    data["xp"] = max(0, int(data.get("xp", 0)) + int(results.get("xp", 0)))
    data["player_level"] = get_level_for_total_xp(int(data["xp"]))
    var new_level: int = max(1, int(data.get("player_level", previous_level)))
    data["last_run_summary"] = str(results.get("summary_text", "Mining run complete."))
    data["last_run_breakdown"] = results.duplicate(true)
    data["deepest_level_unlocked"] = max(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), int(results.get("depth_level", MIN_START_DEPTH_LEVEL)))
    _refresh_depth_unlocks(data)
    var new_deepest_level: int = max(previous_deepest_level, int(data.get("deepest_level_unlocked", previous_deepest_level)))
    if new_deepest_level > previous_deepest_level:
        data["selected_depth_level"] = new_deepest_level
    save_data(data)
    _track_depth_frontier_progression_event(previous_deepest_level, new_deepest_level, results, data)
    _track_level_progression_events(previous_level, new_level, int(data.get("xp", 0)), results)
    return data

static func track_run_start(depth_level: int, data: Dictionary = {}) -> void:
    var ga_manager: Node = _get_game_analytics_manager()
    if ga_manager == null:
        return
    var snapshot: Dictionary = data if not data.is_empty() else load_data()
    var safe_depth_level: int = max(1, depth_level)
    # Treat only the current frontier tier as a progression attempt so replay/farm dives
    # do not dilute the depth funnel with intentional backfills.
    if not _is_frontier_depth_attempt(safe_depth_level, snapshot):
        return
    var safe_display_tier: int = get_display_depth_tier(safe_depth_level)
    var frontier_depth_before_run: int = clampi(int(snapshot.get("deepest_level_unlocked", safe_depth_level)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    ga_manager.call(
        "track_progression_event",
        "start",
        "mining",
        "depth_frontier",
        get_depth_tier_progression_token(safe_depth_level),
        null,
        {
            "depth_level": safe_depth_level,
            "depth_tier": safe_display_tier,
            "selected_depth_level": int(snapshot.get("selected_depth_level", safe_depth_level)),
            "selected_depth_tier": get_display_depth_tier(int(snapshot.get("selected_depth_level", safe_depth_level))),
            "deepest_depth_unlocked": int(snapshot.get("deepest_level_unlocked", safe_depth_level)),
            "frontier_depth_tier_before_run": get_display_depth_tier(frontier_depth_before_run),
            "player_level": int(snapshot.get("player_level", 1)),
            "total_xp": int(snapshot.get("xp", 0)),
            "wallet": int(snapshot.get("wallet", 0)),
        }
    )

static func set_selected_depth_level(depth_level: int) -> Dictionary:
    var data: Dictionary = load_data()
    data["selected_depth_level"] = clampi(depth_level, MIN_START_DEPTH_LEVEL, int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)))
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

static func _track_depth_frontier_progression_event(previous_deepest_level: int, new_deepest_level: int, results: Dictionary, data: Dictionary) -> void:
    var run_depth_level: int = clampi(int(results.get("depth_level", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    var frontier_depth_before_run: int = clampi(previous_deepest_level, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    if run_depth_level != frontier_depth_before_run:
        return
    var ga_manager: Node = _get_game_analytics_manager()
    var progression_token: String = get_depth_tier_progression_token(run_depth_level)
    var attempts: Dictionary = _get_depth_frontier_attempts(data)
    var previous_attempt_failures: int = max(0, int(attempts.get(progression_token, 0)))
    var attempt_num: int = previous_attempt_failures + 1
    var unlocked_new_frontier: bool = new_deepest_level > previous_deepest_level
    if unlocked_new_frontier:
        attempts.erase(progression_token)
    else:
        attempts[progression_token] = attempt_num
    data["depth_frontier_attempts"] = attempts
    save_data(data)
    if ga_manager == null:
        return
    var completion_fields: Dictionary = {
        "depth_level": run_depth_level,
        "depth_tier": get_display_depth_tier(run_depth_level),
        "frontier_depth_level_before_run": frontier_depth_before_run,
        "frontier_depth_tier_before_run": get_display_depth_tier(frontier_depth_before_run),
        "frontier_depth_level_after_run": new_deepest_level,
        "frontier_depth_tier_after_run": get_display_depth_tier(new_deepest_level),
        "new_frontier_unlocked": unlocked_new_frontier,
        "new_tiers_unlocked": max(0, new_deepest_level - previous_deepest_level),
        "reason_key": str(results.get("reason_key", "")),
        "reason": str(results.get("reason", "")),
        "money_earned": int(results.get("money", 0)),
        "xp_earned": int(results.get("xp", 0)),
        "nodes_broken": int(results.get("nodes_broken", 0)),
        "ore_banked": int(results.get("ore_banked", 0)),
        "player_level": int(data.get("player_level", 1)),
        "total_xp": int(data.get("xp", 0)),
        "wallet": int(data.get("wallet", 0)),
        "attempt_num": attempt_num,
    }
    ga_manager.call(
        "track_progression_event",
        "complete" if unlocked_new_frontier else "fail",
        "mining",
        "depth_frontier",
        progression_token,
        int(results.get("money", 0)),
        completion_fields,
        attempt_num
    )

static func _get_game_analytics_manager() -> Node:
    var main_loop: MainLoop = Engine.get_main_loop()
    if main_loop is SceneTree:
        var root: Node = (main_loop as SceneTree).root
        var ga_manager: Node = root.get_node_or_null("GameAnalytics")
        if ga_manager == null:
            ga_manager = root.get_node_or_null("GameAnalyticsManager")
        return ga_manager
    return null

static func _is_frontier_depth_attempt(depth_level: int, data: Dictionary) -> bool:
    var safe_depth_level: int = clampi(depth_level, MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    var frontier_depth_level: int = clampi(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    return safe_depth_level == frontier_depth_level

static func _get_depth_frontier_attempts(data: Dictionary) -> Dictionary:
    var attempts_variant: Variant = data.get("depth_frontier_attempts", {})
    if attempts_variant is Dictionary:
        return (attempts_variant as Dictionary).duplicate(true)
    return {}
