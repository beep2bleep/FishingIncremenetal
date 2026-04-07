extends RefCounted
class_name TurkeyProgress

const TURKEY_DATA := preload("res://Games/Turkey/TurkeyData.gd")
const SAVE_PATH := "user://turkey_mode_save_v1.json"

const DEFAULT_DATA := {
	"wallet": 0,
	"best_score": 0,
	"best_reward": 0,
	"runs": 0,
	"total_score": 0,
	"last_run_summary": "No turkey series completed yet.",
	"last_run_breakdown": {},
	"meta_upgrades": {},
}

static func get_default_data() -> Dictionary:
	return DEFAULT_DATA.duplicate(true)

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	return TURKEY_DATA.get_meta_upgrade_catalog()

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
	return data

static func save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
	var data: Dictionary = get_default_data()
	data["last_run_summary"] = "Turkey progress reset."
	save_data(data)
	return data

static func get_wallet() -> int:
	return int(load_data().get("wallet", 0))

static func has_any_upgrade() -> bool:
	var upgrades: Dictionary = load_data().get("meta_upgrades", {})
	for level_variant in upgrades.values():
		if int(level_variant) > 0:
			return true
	return false

static func get_upgrade_level(key: String) -> int:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {})
	return int(upgrades.get(key, 0))

static func apply_tree_purchase(key: String, level: int, wallet_after_purchase: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {}).duplicate(true)
	upgrades[key] = max(1, level)
	data["meta_upgrades"] = upgrades
	data["wallet"] = max(0, wallet_after_purchase)
	save_data(data)

static func apply_tree_sale(key: String, new_level: int, wallet_after_sale: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("meta_upgrades", {}).duplicate(true)
	if new_level <= 0:
		upgrades.erase(key)
	else:
		upgrades[key] = new_level
	data["meta_upgrades"] = upgrades
	data["wallet"] = max(0, wallet_after_sale)
	save_data(data)

static func apply_run_results(results: Dictionary) -> Dictionary:
	var data: Dictionary = load_data()
	var reward: int = max(0, int(results.get("wallet_gain", TURKEY_DATA.calculate_meta_reward(results, data))))
	var score: int = max(0, int(results.get("score", 0)))
	data["runs"] = int(data.get("runs", 0)) + 1
	data["wallet"] = int(data.get("wallet", 0)) + reward
	data["total_score"] = int(data.get("total_score", 0)) + score
	data["best_score"] = max(int(data.get("best_score", 0)), score)
	data["best_reward"] = max(int(data.get("best_reward", 0)), reward)
	data["last_run_summary"] = str(results.get("summary_text", "Turkey series complete."))
	data["last_run_breakdown"] = results.duplicate(true)
	save_data(data)
	return data
