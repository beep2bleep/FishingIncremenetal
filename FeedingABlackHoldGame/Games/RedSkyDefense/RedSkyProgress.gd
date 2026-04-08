extends RefCounted
class_name RedSkyProgress

const RED_SKY_DATA := preload("res://Games/RedSkyDefense/RedSkyData.gd")
const SAVE_PATH := "user://red_sky_defense_save_v1.json"
const START_WAVE_STEP := 5
const MIN_START_WAVE := 1

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
	"meta_upgrades": {}
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
	var candidate_start_wave: int = START_WAVE_STEP
	while candidate_start_wave + START_WAVE_STEP <= best_wave:
		unlocked.append(candidate_start_wave)
		candidate_start_wave += START_WAVE_STEP
	return unlocked

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
	return safe_data

static func _clamp_selected_start_wave(start_wave: int, data: Dictionary) -> int:
	var desired_start_wave: int = max(MIN_START_WAVE, start_wave)
	var unlocked_waves: Array[int] = _build_unlocked_start_waves(data)
	var best_match: int = MIN_START_WAVE
	for unlocked_wave in unlocked_waves:
		if unlocked_wave <= desired_start_wave:
			best_match = unlocked_wave
	return best_match
