extends RefCounted
class_name RedSkyProgress

const RED_SKY_DATA := preload("res://Games/RedSkyDefense/RedSkyData.gd")
const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const SAVE_PATH := "user://red_sky_defense_save_v1.json"
const START_WAVE_STEP := 5
const MIN_START_WAVE := 1
const FIRST_SKIP_START_WAVE := MIN_START_WAVE + START_WAVE_STEP

const DEFAULT_DATA := {
	"wallet": 0,
	"best_score": 0,
	"best_wave": 0,
	"total_score": 0,
	"total_waves_cleared": 0,
	"runs": 0,
	"last_run_summary": "No Red Sky Defense run completed yet.",
	"last_run_breakdown": {},
	"selected_start_wave": MIN_START_WAVE,
	"meta_upgrades": {},
	"wave_frontier_attempts": {},
	"analytics_sent_first_deploy": false,
}

static func get_default_data() -> Dictionary:
	return DEFAULT_DATA.duplicate(true)

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	return RED_SKY_DATA.get_meta_upgrade_catalog()

static func load_data() -> Dictionary:
	var data: Dictionary = get_default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		return _sanitize_loaded_data(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return _sanitize_loaded_data(data)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = data.merged(parsed, true)
	var sanitized: Dictionary = _sanitize_loaded_data(data)
	if sanitized != data:
		save_data(sanitized)
	return sanitized

static func save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
	var data: Dictionary = get_default_data()
	data["last_run_summary"] = "Red Sky Defense progress reset."
	save_data(data)
	return data

static func get_unlocked_start_waves(data: Dictionary = {}) -> Array[int]:
	var source: Dictionary = _sanitize_loaded_data(data if not data.is_empty() else load_data())
	return _build_unlocked_start_waves(source)

static func get_selected_start_wave(data: Dictionary = {}) -> int:
	var source: Dictionary = _sanitize_loaded_data(data if not data.is_empty() else load_data())
	return int(source.get("selected_start_wave", MIN_START_WAVE))

static func set_selected_start_wave(start_wave: int) -> Dictionary:
	var data: Dictionary = load_data()
	data["selected_start_wave"] = _clamp_selected_start_wave(start_wave, data)
	save_data(data)
	return data

static func _build_unlocked_start_waves(data: Dictionary) -> Array[int]:
	var best_wave: int = max(0, int(data.get("best_wave", 0)))
	var unlocked: Array[int] = [MIN_START_WAVE]
	var candidate_start_wave: int = FIRST_SKIP_START_WAVE
	while get_required_best_wave_for_start_wave(candidate_start_wave) <= best_wave:
		unlocked.append(candidate_start_wave)
		candidate_start_wave += START_WAVE_STEP
	return unlocked

static func get_required_best_wave_for_start_wave(start_wave: int) -> int:
	if start_wave <= MIN_START_WAVE:
		return 0
	return max(start_wave, FIRST_SKIP_START_WAVE) + START_WAVE_STEP - 1

static func get_wallet() -> int:
	return int(load_data().get("wallet", 0))

static func get_upgrade_level(key: String) -> int:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {})
	return int(upgrades.get(key, 0))

static func set_upgrade_level(key: String, level: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {}).duplicate(true)
	var safe_level: int = max(0, level)
	if safe_level <= 0:
		upgrades.erase(key)
	else:
		upgrades[key] = safe_level
	data["meta_upgrades"] = upgrades
	save_data(data)

static func apply_tree_purchase(key: String, level: int, wallet_after_purchase: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {}).duplicate(true)
	data["wallet"] = max(0, wallet_after_purchase)
	upgrades[key] = max(1, level)
	data["meta_upgrades"] = upgrades
	save_data(data)

static func apply_tree_sale(key: String, new_level: int, wallet_after_sale: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {}).duplicate(true)
	data["wallet"] = max(0, wallet_after_sale)
	if new_level <= 0:
		upgrades.erase(key)
	else:
		upgrades[key] = new_level
	data["meta_upgrades"] = upgrades
	save_data(data)

static func apply_run_results(results: Dictionary) -> Dictionary:
	var data: Dictionary = load_data()
	var previous_highest_start_wave: int = get_unlocked_start_waves(data).back()
	var score: int = max(0, int(results.get("score", 0)))
	var wallet_gain: int = max(0, int(results.get("wallet_gain", RED_SKY_DATA.calculate_meta_scrap_reward(results))))
	var waves_cleared: int = max(0, int(results.get("waves_cleared", 0)))
	data["runs"] = int(data.get("runs", 0)) + 1
	data["wallet"] = int(data.get("wallet", 0)) + wallet_gain
	data["total_score"] = int(data.get("total_score", 0)) + score
	data["best_score"] = max(int(data.get("best_score", 0)), score)
	data["best_wave"] = max(int(data.get("best_wave", 0)), waves_cleared)
	CROSS_GAME_BONUSES.award_red_sky_wave(int(data["best_wave"]))
	data["total_waves_cleared"] = int(data.get("total_waves_cleared", 0)) + waves_cleared
	data["last_run_summary"] = str(results.get("summary_text", "Red Sky Defense run complete."))
	data["last_run_breakdown"] = results.duplicate(true)
	var new_highest_start_wave: int = get_unlocked_start_waves(data).back()
	if new_highest_start_wave > previous_highest_start_wave:
		data["selected_start_wave"] = new_highest_start_wave
	else:
		data["selected_start_wave"] = _clamp_selected_start_wave(int(data.get("selected_start_wave", MIN_START_WAVE)), data)
	save_data(data)
	return data

static func _sanitize_loaded_data(data: Dictionary) -> Dictionary:
	var safe_data: Dictionary = get_default_data().merged(data, true)
	safe_data["wallet"] = max(0, int(safe_data.get("wallet", 0)))
	safe_data["best_score"] = max(0, int(safe_data.get("best_score", 0)))
	safe_data["best_wave"] = max(0, int(safe_data.get("best_wave", 0)))
	safe_data["total_score"] = max(0, int(safe_data.get("total_score", 0)))
	safe_data["total_waves_cleared"] = max(0, int(safe_data.get("total_waves_cleared", 0)))
	safe_data["runs"] = max(0, int(safe_data.get("runs", 0)))
	safe_data["selected_start_wave"] = _clamp_selected_start_wave(int(safe_data.get("selected_start_wave", MIN_START_WAVE)), safe_data)
	if not (safe_data.get("wave_frontier_attempts", {}) is Dictionary):
		safe_data["wave_frontier_attempts"] = {}
	safe_data["analytics_sent_first_deploy"] = bool(safe_data.get("analytics_sent_first_deploy", false))
	if bool(ProjectSettings.get_setting("global/Demo", false)):
		safe_data["meta_upgrades"] = _strip_demo_locked_meta_upgrades(safe_data.get("meta_upgrades", {}))
	return safe_data

static func _strip_demo_locked_meta_upgrades(meta_upgrades: Dictionary) -> Dictionary:
	var out: Dictionary = meta_upgrades.duplicate(true)
	for entry in RED_SKY_DATA.get_meta_upgrade_catalog():
		var upgrade_id: String = str(entry.get("id", ""))
		if upgrade_id.is_empty():
			continue
		if RED_SKY_DATA.should_lock_meta_upgrade_in_demo(entry):
			out.erase(upgrade_id)
	return out

static func _clamp_selected_start_wave(start_wave: int, data: Dictionary) -> int:
	var desired_start_wave: int = max(MIN_START_WAVE, start_wave)
	var unlocked_waves: Array[int] = _build_unlocked_start_waves(data)
	var best_match: int = MIN_START_WAVE
	for unlocked_wave in unlocked_waves:
		if unlocked_wave <= desired_start_wave:
			best_match = unlocked_wave
	return best_match


static func maybe_track_first_deploy() -> void:
	var data: Dictionary = load_data()
	if bool(data.get("analytics_sent_first_deploy", false)):
		return
	data["analytics_sent_first_deploy"] = true
	save_data(data)
	var ga_manager: Node = _get_game_analytics_manager()
	if ga_manager == null:
		return
	ga_manager.call(
		"track_design_event",
		"red_sky:first_deploy",
		null,
		{
			"runs_completed": int(data.get("runs", 0)),
			"best_wave": int(data.get("best_wave", 0)),
		}
	)


static func track_run_start(run_start_wave: int, snapshot: Dictionary) -> void:
	var unlocked: Array[int] = get_unlocked_start_waves(snapshot)
	if unlocked.is_empty():
		return
	if run_start_wave != unlocked.back():
		return
	var ga_manager: Node = _get_game_analytics_manager()
	if ga_manager == null:
		return
	var career_best: int = max(0, int(snapshot.get("best_wave", 0)))
	var token: String = "from_%d" % run_start_wave
	ga_manager.call(
		"track_progression_event",
		"start",
		"redsky",
		"wave_frontier",
		token,
		null,
		{
			"run_start_wave": run_start_wave,
			"career_best_wave": career_best,
			"runs": int(snapshot.get("runs", 0)),
		}
	)


static func track_run_end(run_start_wave: int, snapshot_before: Dictionary, waves_cleared: int, score: int, reason: String) -> void:
	var unlocked: Array[int] = get_unlocked_start_waves(snapshot_before)
	if unlocked.is_empty() or run_start_wave != unlocked.back():
		return
	var prev_best: int = max(0, int(snapshot_before.get("best_wave", 0)))
	var new_best: int = max(prev_best, waves_cleared)
	var ga_manager: Node = _get_game_analytics_manager()
	var token: String = "from_%d" % run_start_wave
	var data: Dictionary = load_data()
	var attempts: Dictionary = _get_wave_frontier_attempts(data)
	var previous_attempt_failures: int = max(0, int(attempts.get(token, 0)))
	var attempt_num: int = previous_attempt_failures + 1
	var beat_record: bool = new_best > prev_best
	if beat_record:
		attempts.erase(token)
	else:
		attempts[token] = attempt_num
	data["wave_frontier_attempts"] = attempts
	save_data(data)
	if ga_manager == null:
		return
	var fields: Dictionary = {
		"run_start_wave": run_start_wave,
		"waves_cleared": waves_cleared,
		"career_best_before": prev_best,
		"career_best_after": new_best,
		"beat_record": beat_record,
		"score": score,
		"reason": reason,
		"attempt_num": attempt_num,
	}
	ga_manager.call(
		"track_progression_event",
		"complete" if beat_record else "fail",
		"redsky",
		"wave_frontier",
		token,
		waves_cleared,
		fields,
		attempt_num
	)


static func track_wave_cleared_runtime(
	waves_cleared: int,
	run_start_wave: int,
	career_best_at_run_start: int,
	run_score: int
) -> void:
	var ga_manager: Node = _get_game_analytics_manager()
	if ga_manager == null:
		return
	var fields: Dictionary = {
		"waves_cleared": waves_cleared,
		"run_start_wave": run_start_wave,
		"career_best_at_run_start": career_best_at_run_start,
		"run_score": run_score,
	}
	ga_manager.call("track_design_event", "red_sky:wave_cleared", float(waves_cleared), fields)
	if waves_cleared > 0 and waves_cleared % 5 == 0:
		ga_manager.call(
			"track_design_event",
			"red_sky:milestone:wave",
			float(waves_cleared),
			fields
		)


static func _get_wave_frontier_attempts(data: Dictionary) -> Dictionary:
	var raw: Variant = data.get("wave_frontier_attempts", {})
	if raw is Dictionary:
		return (raw as Dictionary).duplicate(true)
	return {}


static func _get_game_analytics_manager() -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Node = (main_loop as SceneTree).root
		var ga_manager: Node = root.get_node_or_null("GameAnalytics")
		if ga_manager == null:
			ga_manager = root.get_node_or_null("GameAnalyticsManager")
		return ga_manager
	return null
