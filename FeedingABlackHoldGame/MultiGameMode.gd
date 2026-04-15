extends RefCounted
class_name MultiGameMode

const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const MINING_PROGRESS := preload("res://Games/Mining/MiningProgress.gd")
const RED_SKY_PROGRESS := preload("res://Games/RedSkyDefense/RedSkyProgress.gd")
const TURKEY_PROGRESS := preload("res://Games/Turkey/TurkeyProgress.gd")
const REEL_PROGRESS := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")

const SAVE_PATH := "user://multi_game_mode_save_v1.json"
const TIER_REWARD_GEMS := 2

const DEFAULT_PROGRESS := {
    "highest_completed_tier": 0,
}

const TIER_DEFINITIONS := [
    {
        "tier": 1,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 2, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [2]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 3, "nodes_goal": 10, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [10, 20, 3]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 6, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [6]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 1, "frame_pin_goal": 8, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [8, 20, 2]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 1, "fish_goal": 3, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [3, 20, 2]},
        ],
    },
    {
        "tier": 2,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 3, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [3]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 4, "nodes_goal": 11, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [11, 20, 4]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 7, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [7]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 1, "frame_pin_goal": 9, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [9, 20, 2]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 1, "fish_goal": 4, "time_limit": 20.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [4, 20, 2]},
        ],
    },
    {
        "tier": 3,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 4, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [4]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 5, "nodes_goal": 12, "time_limit": 19.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [12, 19, 5]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 8, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [8]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 2, "frame_pin_goal": 10, "time_limit": 19.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [10, 19, 3]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 2, "fish_goal": 4, "time_limit": 19.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [4, 19, 3]},
        ],
    },
    {
        "tier": 4,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 5, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [5]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 6, "nodes_goal": 13, "time_limit": 19.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [13, 19, 6]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 9, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [9]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 2, "frame_pin_goal": 11, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [11, 18, 3]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 2, "fish_goal": 5, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [5, 18, 3]},
        ],
    },
    {
        "tier": 5,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 6, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [6]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 7, "nodes_goal": 14, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [14, 18, 7]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 10, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [10]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 12, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [12, 18, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 3, "fish_goal": 5, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [5, 18, 4]},
        ],
    },
    {
        "tier": 6,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 7, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [7]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 8, "nodes_goal": 15, "time_limit": 18.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [15, 18, 8]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 11, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [11]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 13, "time_limit": 17.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [13, 17, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 3, "fish_goal": 6, "time_limit": 17.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [6, 17, 4]},
        ],
    },
    {
        "tier": 7,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 8, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [8]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 9, "nodes_goal": 16, "time_limit": 17.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [16, 17, 9]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 12, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [12]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 14, "time_limit": 17.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [14, 17, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 4, "fish_goal": 6, "time_limit": 16.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [6, 16, 5]},
        ],
    },
    {
        "tier": 8,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 9, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [9]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 10, "nodes_goal": 17, "time_limit": 17.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [17, 17, 10]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 13, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [13]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 15, "time_limit": 16.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [15, 16, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 4, "fish_goal": 7, "time_limit": 16.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [7, 16, 5]},
        ],
    },
    {
        "tier": 9,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 10, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [10]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 11, "nodes_goal": 18, "time_limit": 16.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [18, 16, 11]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 14, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [14]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 16, "time_limit": 15.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [16, 15, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 5, "fish_goal": 7, "time_limit": 15.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [7, 15, 6]},
        ],
    },
    {
        "tier": 10,
        "steps": [
            {"game_id": Util.ACTIVE_GAME_VANGUARD, "battle_level": 11, "spawn_boss_immediately": true, "intro_key": "MULTI_MODE_OBJECTIVE_VANGUARD", "intro_args": [11]},
            {"game_id": Util.ACTIVE_GAME_MINING, "depth_level": 12, "nodes_goal": 20, "time_limit": 16.0, "intro_key": "MULTI_MODE_OBJECTIVE_MINING", "intro_args": [20, 16, 12]},
            {"game_id": Util.ACTIVE_GAME_RED_SKY, "target_wave": 15, "disable_wave_upgrades": true, "intro_key": "MULTI_MODE_OBJECTIVE_REDSKY", "intro_args": [15]},
            {"game_id": Util.ACTIVE_GAME_TURKEY, "lane_tier": 3, "frame_pin_goal": 18, "time_limit": 14.0, "intro_key": "MULTI_MODE_OBJECTIVE_TURKEY", "intro_args": [18, 14, 4]},
            {"game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_tier_index": 5, "fish_goal": 8, "time_limit": 14.0, "intro_key": "MULTI_MODE_OBJECTIVE_REEL", "intro_args": [8, 14, 6]},
        ],
    },
]

static func load_progress() -> Dictionary:
    var data: Dictionary = DEFAULT_PROGRESS.duplicate(true)
    if not FileAccess.file_exists(SAVE_PATH):
        return data
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return data
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        data = data.merged(parsed, true)
    data["highest_completed_tier"] = clampi(int(data.get("highest_completed_tier", 0)), 0, get_tier_count())
    return data

static func save_progress(data: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
    var data: Dictionary = DEFAULT_PROGRESS.duplicate(true)
    save_progress(data)
    Global.multi_game_run = {}
    Global.multi_game_step_config = {}
    Global.multi_game_pending_summary = {}
    return data

static func get_tier_count() -> int:
    return TIER_DEFINITIONS.size()

static func get_highest_completed_tier() -> int:
    return int(load_progress().get("highest_completed_tier", 0))

static func get_max_selectable_tier() -> int:
    return clampi(get_highest_completed_tier() + 1, 1, get_tier_count())

static func get_selectable_tiers() -> Array[int]:
    var out: Array[int] = []
    for tier in range(1, get_max_selectable_tier() + 1):
        out.append(tier)
    return out

static func tier_has_reward(tier: int) -> bool:
    return tier > get_highest_completed_tier()

static func get_tier_definition(tier: int) -> Dictionary:
    if tier < 1 or tier > TIER_DEFINITIONS.size():
        return {}
    return TIER_DEFINITIONS[tier - 1].duplicate(true)

static func is_run_active() -> bool:
    return not Global.multi_game_run.is_empty()

static func get_active_step() -> Dictionary:
    if not is_run_active():
        return {}
    var steps: Array = Global.multi_game_run.get("steps", [])
    if steps.is_empty():
        var tier_definition: Dictionary = get_tier_definition(int(Global.multi_game_run.get("tier", 0)))
        steps = tier_definition.get("steps", [])
    var step_index: int = int(Global.multi_game_run.get("step_index", 0))
    if step_index < 0 or step_index >= steps.size():
        return {}
    return Dictionary(steps[step_index]).duplicate(true)

static func get_active_step_for_game(game_id: String) -> Dictionary:
    var step: Dictionary = get_active_step()
    if str(step.get("game_id", "")) != game_id:
        return {}
    return step

static func get_active_intro_text() -> String:
    var step: Dictionary = get_active_step()
    if step.is_empty():
        return ""
    var key: String = str(step.get("intro_key", "")).strip_edges()
    var args: Array = step.get("intro_args", [])
    if key == "":
        return ""
    var translated: String = TranslationServer.translate(key)
    if args.is_empty():
        return translated
    return translated % args

static func start_tier(tier: int) -> void:
    var tier_definition: Dictionary = get_tier_definition(tier)
    if tier_definition.is_empty():
        return
    var shuffled_steps: Array = tier_definition.get("steps", []).duplicate(true)
    shuffled_steps.shuffle()
    Global.multi_game_run = {
        "tier": tier,
        "step_index": 0,
        "reward_available": tier_has_reward(tier),
        "completed_steps": [],
        "steps": shuffled_steps,
    }
    _launch_current_step()

static func cancel_run() -> void:
    Global.multi_game_run = {}
    Global.multi_game_step_config = {}

static func complete_current_step(success: bool, payload: Dictionary = {}) -> void:
    if not is_run_active():
        return
    var step: Dictionary = get_active_step()
    if step.is_empty():
        cancel_run()
        return
    var completed_steps: Array = Global.multi_game_run.get("completed_steps", [])
    completed_steps.append(_build_completed_step(step, success, payload))
    Global.multi_game_run["completed_steps"] = completed_steps
    if not success:
        _finish_run(false)
        return
    Global.multi_game_run["step_index"] = int(Global.multi_game_run.get("step_index", 0)) + 1
    var steps: Array = Global.multi_game_run.get("steps", [])
    if int(Global.multi_game_run.get("step_index", 0)) >= steps.size():
        _finish_run(true)
        return
    _launch_current_step()

static func consume_pending_summary() -> Dictionary:
    var summary: Dictionary = Global.multi_game_pending_summary.duplicate(true)
    Global.multi_game_pending_summary = {}
    return summary

static func _finish_run(success: bool) -> void:
    var tier: int = int(Global.multi_game_run.get("tier", 0))
    var reward_available: bool = bool(Global.multi_game_run.get("reward_available", false))
    var rewarded_gems := 0
    if success and reward_available:
        rewarded_gems = TIER_REWARD_GEMS
        CROSS_GAME_BONUSES.grant_multi_gems(rewarded_gems)
        var progress: Dictionary = load_progress()
        progress["highest_completed_tier"] = max(int(progress.get("highest_completed_tier", 0)), tier)
        save_progress(progress)
    Global.multi_game_pending_summary = {
        "success": success,
        "tier": tier,
        "rewarded_gems": rewarded_gems,
        "reward_available": reward_available,
        "completed_steps": Global.multi_game_run.get("completed_steps", []).duplicate(true),
    }
    cancel_run()
    SceneChanger.change_to_new_scene(Util.PATH_GAME_LAUNCHER, null, 0.2)

static func _launch_current_step() -> void:
    var step: Dictionary = get_active_step()
    if step.is_empty():
        _finish_run(false)
        return
    var game_id: String = str(step.get("game_id", ""))
    Util.set_active_game_id(game_id)
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = false
    Global.multi_game_step_config = step.duplicate(true)
    _prepare_step_launch(step)
    SceneChanger.change_to_new_scene(_get_scene_path_for_game(game_id), null, 0.2)

static func _prepare_step_launch(step: Dictionary) -> void:
    var game_id: String = str(step.get("game_id", ""))
    if game_id == Util.ACTIVE_GAME_VANGUARD:
        SaveHandler.load_fishing_progress()
        SaveHandler.fishing_next_battle_level = int(step.get("battle_level", 1))
        SaveHandler.save_fishing_progress()

static func _build_completed_step(step: Dictionary, success: bool, payload: Dictionary) -> Dictionary:
    var safe_payload: Dictionary = payload.duplicate(true)
    var game_id: String = str(step.get("game_id", ""))
    var tier: int = int(Global.multi_game_run.get("tier", 0))
    var objective_text: String = _get_intro_text_for_step(step)
    var meta_reward: int = _grant_step_meta_reward(step, success, safe_payload)
    return {
        "game_id": game_id,
        "game_name": _get_game_name(game_id),
        "success": success,
        "objective_text": objective_text,
        "status_text": _build_status_text(step, success, safe_payload, meta_reward),
        "performance_text": _build_performance_text(step, success, safe_payload),
        "meta_reward": meta_reward,
        "meta_reward_label": _get_meta_reward_label(game_id, meta_reward),
        "chart_rows": _build_chart_rows(step, success, safe_payload, meta_reward),
        "payload": safe_payload,
        "tier": tier,
    }

static func _grant_step_meta_reward(step: Dictionary, success: bool, payload: Dictionary) -> int:
    if not success:
        return 0
    var reward: int = _get_step_meta_reward(step, payload)
    if reward <= 0:
        return 0
    match str(step.get("game_id", "")):
        Util.ACTIVE_GAME_VANGUARD:
            SaveHandler.load_fishing_progress()
            SaveHandler.fishing_currency = max(0, int(SaveHandler.fishing_currency) + reward)
            SaveHandler.save_fishing_progress()
        Util.ACTIVE_GAME_MINING:
            var mining_data: Dictionary = MINING_PROGRESS.load_data()
            mining_data["wallet"] = max(0, int(mining_data.get("wallet", 0)) + reward)
            MINING_PROGRESS.save_data(mining_data)
        Util.ACTIVE_GAME_RED_SKY:
            var red_sky_data: Dictionary = RED_SKY_PROGRESS.load_data()
            red_sky_data["wallet"] = max(0, int(red_sky_data.get("wallet", 0)) + reward)
            RED_SKY_PROGRESS.save_data(red_sky_data)
        Util.ACTIVE_GAME_TURKEY:
            var turkey_data: Dictionary = TURKEY_PROGRESS.load_data()
            turkey_data["wallet"] = max(0, int(turkey_data.get("wallet", 0)) + reward)
            TURKEY_PROGRESS.save_data(turkey_data)
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            var reel_data: Dictionary = REEL_PROGRESS.load_data()
            reel_data["wallet"] = max(0, int(reel_data.get("wallet", 0)) + reward)
            REEL_PROGRESS.save_data(reel_data)
    return reward

static func _get_step_meta_reward(step: Dictionary, payload: Dictionary) -> int:
    var tier: int = int(Global.multi_game_run.get("tier", 1))
    match str(step.get("game_id", "")):
        Util.ACTIVE_GAME_VANGUARD:
            return 20 + int(step.get("battle_level", tier)) * 6
        Util.ACTIVE_GAME_MINING:
            return 18 + int(step.get("depth_level", tier)) * 5
        Util.ACTIVE_GAME_RED_SKY:
            return 24 + int(step.get("target_wave", tier)) * 4
        Util.ACTIVE_GAME_TURKEY:
            return 18 + int(step.get("frame_pin_goal", 8)) * 3
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return 16 + int(step.get("fish_goal", 3)) * 6
        _:
            return 0

static func _build_chart_rows(step: Dictionary, success: bool, payload: Dictionary, meta_reward: int) -> Array[Dictionary]:
    var game_id: String = str(step.get("game_id", ""))
    var rows: Array[Dictionary] = []
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            var boss_level: int = int(step.get("battle_level", 1))
            rows.append({"label": _tr("MULTI_MODE_CHART_BOSS_LEVEL"), "value": float(boss_level), "max_value": float(max(1, boss_level)), "value_text": _trf("MULTI_MODE_VALUE_LEVEL_SHORT", [boss_level]), "color": Color(0.76, 0.52, 1.0, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_META_REWARD"), "value": float(meta_reward), "max_value": float(max(1, meta_reward)), "value_text": _get_meta_reward_label(game_id, meta_reward), "color": Color(0.96, 0.8, 0.38, 1.0)})
        Util.ACTIVE_GAME_MINING:
            var nodes_goal: int = int(step.get("nodes_goal", 0))
            var depth_level: int = int(step.get("depth_level", 1))
            rows.append({"label": _tr("MULTI_MODE_CHART_NODES_BROKEN"), "value": float(payload.get("nodes_broken", 0)), "max_value": float(max(1, nodes_goal)), "value_text": _trf("MULTI_MODE_VALUE_PROGRESS", [int(payload.get("nodes_broken", 0)), nodes_goal]), "color": Color(0.38, 0.86, 0.56, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_DEPTH"), "value": float(depth_level), "max_value": float(max(1, depth_level)), "value_text": _trf("MULTI_MODE_VALUE_DEPTH", [depth_level]), "color": Color(0.42, 0.82, 0.98, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_META_REWARD"), "value": float(meta_reward), "max_value": float(max(1, meta_reward)), "value_text": _get_meta_reward_label(game_id, meta_reward), "color": Color(0.97, 0.84, 0.42, 1.0)})
        Util.ACTIVE_GAME_RED_SKY:
            var target_wave: int = int(step.get("target_wave", 0))
            rows.append({"label": _tr("MULTI_MODE_CHART_WAVE_CLEARED"), "value": float(payload.get("waves_cleared", 0)), "max_value": float(max(1, target_wave)), "value_text": _trf("MULTI_MODE_VALUE_PROGRESS", [int(payload.get("waves_cleared", 0)), target_wave]), "color": Color(0.98, 0.52, 0.44, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_META_REWARD"), "value": float(meta_reward), "max_value": float(max(1, meta_reward)), "value_text": _get_meta_reward_label(game_id, meta_reward), "color": Color(0.98, 0.84, 0.44, 1.0)})
        Util.ACTIVE_GAME_TURKEY:
            var frame_pin_goal: int = int(step.get("frame_pin_goal", 0))
            var lane_tier: int = int(step.get("lane_tier", 0)) + 1
            rows.append({"label": _tr("MULTI_MODE_CHART_FRAME_PINS"), "value": float(payload.get("frame_total", 0)), "max_value": float(max(1, frame_pin_goal)), "value_text": _trf("MULTI_MODE_VALUE_PROGRESS", [int(payload.get("frame_total", 0)), frame_pin_goal]), "color": Color(0.98, 0.78, 0.36, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_LANE_TIER"), "value": float(lane_tier), "max_value": float(max(1, lane_tier)), "value_text": _trf("MULTI_MODE_VALUE_TIER", [lane_tier]), "color": Color(0.94, 0.58, 0.34, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_META_REWARD"), "value": float(meta_reward), "max_value": float(max(1, meta_reward)), "value_text": _get_meta_reward_label(game_id, meta_reward), "color": Color(0.95, 0.88, 0.46, 1.0)})
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            var fish_goal: int = int(step.get("fish_goal", 0))
            var depth_tier: int = int(step.get("depth_tier_index", 0)) + 1
            rows.append({"label": _tr("MULTI_MODE_CHART_FISH_CAUGHT"), "value": float(payload.get("fish_caught", 0)), "max_value": float(max(1, fish_goal)), "value_text": _trf("MULTI_MODE_VALUE_PROGRESS", [int(payload.get("fish_caught", 0)), fish_goal]), "color": Color(0.44, 0.86, 0.98, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_DEPTH_TIER"), "value": float(depth_tier), "max_value": float(max(1, depth_tier)), "value_text": _trf("MULTI_MODE_VALUE_TIER", [depth_tier]), "color": Color(0.62, 0.78, 0.98, 1.0)})
            rows.append({"label": _tr("MULTI_MODE_CHART_META_REWARD"), "value": float(meta_reward), "max_value": float(max(1, meta_reward)), "value_text": _get_meta_reward_label(game_id, meta_reward), "color": Color(0.72, 0.94, 0.72, 1.0)})
    _append_time_chart_rows(rows, payload)
    return rows

static func _append_time_chart_rows(rows: Array[Dictionary], payload: Dictionary) -> void:
    if not payload.has("time_limit"):
        return
    var time_limit: float = maxf(0.01, float(payload.get("time_limit", 0.0)))
    var elapsed: float = clampf(float(payload.get("elapsed", time_limit - float(payload.get("time_remaining", 0.0)))), 0.0, time_limit)
    var remaining: float = clampf(float(payload.get("time_remaining", maxf(0.0, time_limit - elapsed))), 0.0, time_limit)
    rows.append({
        "label": _tr("MULTI_MODE_CHART_TIME_USED"),
        "value": elapsed,
        "max_value": time_limit,
        "value_text": _trf("MULTI_MODE_VALUE_SECONDS", [elapsed]),
        "color": Color(0.86, 0.72, 0.98, 1.0)
    })
    rows.append({
        "label": _tr("MULTI_MODE_CHART_TIME_LEFT"),
        "value": remaining,
        "max_value": time_limit,
        "value_text": _trf("MULTI_MODE_VALUE_SECONDS", [remaining]),
        "color": Color(0.52, 0.9, 0.92, 1.0)
    })

static func _build_status_text(step: Dictionary, success: bool, payload: Dictionary, meta_reward: int) -> String:
    if success:
        var reward_text: String = _get_meta_reward_label(str(step.get("game_id", "")), meta_reward)
        return _trf("MULTI_MODE_STATUS_CLEARED_REWARD", [reward_text]) if reward_text != "" else _tr("MULTI_MODE_STATUS_CLEARED")
    match str(step.get("game_id", "")):
        Util.ACTIVE_GAME_VANGUARD:
            return _trf("MULTI_MODE_STATUS_FAIL_VANGUARD", [int(step.get("battle_level", 1))])
        Util.ACTIVE_GAME_MINING:
            var reason: String = str(payload.get("reason", ""))
            if reason == "MINING_REASON_TIMER_EXPIRED":
                return _trf("MULTI_MODE_STATUS_FAIL_MINING_TIMER", [int(payload.get("nodes_broken", 0)), int(step.get("nodes_goal", 0))])
            if reason == "MINING_REASON_DRILL_DEPLETED":
                return _trf("MULTI_MODE_STATUS_FAIL_MINING_DRILL", [int(step.get("nodes_goal", 0))])
            return _trf("MULTI_MODE_STATUS_FAIL_MINING", [int(payload.get("nodes_broken", 0)), int(step.get("nodes_goal", 0))])
        Util.ACTIVE_GAME_RED_SKY:
            return _trf("MULTI_MODE_STATUS_FAIL_REDSKY", [int(step.get("target_wave", 0)), int(payload.get("waves_cleared", 0))])
        Util.ACTIVE_GAME_TURKEY:
            if str(payload.get("reason", "")) == "timer":
                return _trf("MULTI_MODE_STATUS_FAIL_TURKEY_TIMER", [int(step.get("frame_pin_goal", 0))])
            return _trf("MULTI_MODE_STATUS_FAIL_TURKEY", [int(step.get("frame_pin_goal", 0))])
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return _trf("MULTI_MODE_STATUS_FAIL_REEL", [int(payload.get("fish_caught", 0)), int(step.get("fish_goal", 0))])
        _:
            return _tr("MULTI_MODE_STATUS_FAILED")

static func _build_performance_text(step: Dictionary, success: bool, payload: Dictionary) -> String:
    var game_id: String = str(step.get("game_id", ""))
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return _tr("MULTI_MODE_PERF_VANGUARD_SUCCESS") if success else _tr("MULTI_MODE_PERF_VANGUARD_FAIL")
        Util.ACTIVE_GAME_MINING:
            var goal: int = int(step.get("nodes_goal", 0))
            var broken: int = int(payload.get("nodes_broken", 0))
            if success:
                var remaining: float = float(payload.get("time_remaining", 0.0))
                var extra_nodes: int = max(0, broken - goal)
                if extra_nodes > 0:
                    return _trf("MULTI_MODE_PERF_MINING_SUCCESS_EXTRA", [remaining, extra_nodes])
                return _trf("MULTI_MODE_PERF_MINING_SUCCESS", [remaining])
            return _trf("MULTI_MODE_PERF_MINING_FAIL", [broken, goal])
        Util.ACTIVE_GAME_RED_SKY:
            var target_wave: int = int(step.get("target_wave", 0))
            var cleared: int = int(payload.get("waves_cleared", 0))
            return _tr("MULTI_MODE_PERF_REDSKY_SUCCESS") if success else _trf("MULTI_MODE_PERF_REDSKY_FAIL", [cleared, target_wave])
        Util.ACTIVE_GAME_TURKEY:
            var goal_pins: int = int(step.get("frame_pin_goal", 0))
            var frame_total: int = int(payload.get("frame_total", 0))
            var time_left: float = float(payload.get("time_remaining", 0.0))
            return _trf("MULTI_MODE_PERF_TURKEY_SUCCESS", [time_left]) if success else _trf("MULTI_MODE_PERF_TURKEY_FAIL", [frame_total, goal_pins])
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            var fish_goal: int = int(step.get("fish_goal", 0))
            var fish_caught: int = int(payload.get("fish_caught", 0))
            var reel_time_left: float = float(payload.get("time_remaining", 0.0))
            return _trf("MULTI_MODE_PERF_REEL_SUCCESS", [reel_time_left]) if success else _trf("MULTI_MODE_PERF_REEL_FAIL", [fish_caught, fish_goal])
        _:
            return ""

static func _get_meta_reward_label(game_id: String, amount: int) -> String:
    if amount <= 0:
        return ""
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return _trf("MULTI_MODE_REWARD_COINS", [amount])
        Util.ACTIVE_GAME_MINING:
            return "$%d" % amount
        Util.ACTIVE_GAME_RED_SKY:
            return _trf("MULTI_MODE_REWARD_SCRAP", [amount])
        Util.ACTIVE_GAME_TURKEY:
            return "$%d" % amount
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return "$%d" % amount
        _:
            return "%d" % amount

static func _get_intro_text_for_step(step: Dictionary) -> String:
    var key: String = str(step.get("intro_key", "")).strip_edges()
    var args: Array = step.get("intro_args", [])
    if key == "":
        return ""
    var translated: String = TranslationServer.translate(key)
    return translated % args if not args.is_empty() else translated

static func _get_game_name(game_id: String) -> String:
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return _tr("VANGUARD")
        Util.ACTIVE_GAME_MINING:
            return _tr("DEEPCORE")
        Util.ACTIVE_GAME_RED_SKY:
            return _tr("RED SKY DEFENSE")
        Util.ACTIVE_GAME_TURKEY:
            return _tr("TURKEY")
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return _tr("REEL INTO DARKNESS")
        _:
            return game_id

static func _tr(key: String) -> String:
    return TranslationServer.translate(key)

static func _trf(key: String, args: Array) -> String:
    var translated: String = _tr(key)
    return translated % args if not args.is_empty() else translated

static func _get_scene_path_for_game(game_id: String) -> String:
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return Util.PATH_VANGUARD_BATTLE
        Util.ACTIVE_GAME_MINING:
            return Util.PATH_MINING_MAIN
        Util.ACTIVE_GAME_RED_SKY:
            return Util.PATH_RED_SKY_MAIN
        Util.ACTIVE_GAME_TURKEY:
            return Util.PATH_TURKEY_MAIN
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return Util.PATH_REEL_INTO_DARKNESS_MAIN
        _:
            return Util.PATH_GAME_LAUNCHER
