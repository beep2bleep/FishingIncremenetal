extends RefCounted
class_name ReelIntoDarknessProgress

const REEL_DATA := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
const SAVE_PATH := "user://reel_into_darkness_save_v1.json"

const DEFAULT_DATA := {
	"wallet": REEL_DATA.STARTING_WALLET,
	"best_haul": 0,
	"best_depth": 0.0,
	"total_money": 0,
	"total_fish_caught": 0,
	"runs": 0,
	"last_run_summary": "No Reel Into Darkness run completed yet.",
	"last_run_breakdown": {},
	"meta_upgrades": {}
}

static func get_default_data() -> Dictionary:
	return DEFAULT_DATA.duplicate(true)

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	return REEL_DATA.get_meta_upgrade_catalog()

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
	data["last_run_summary"] = "Reel Into Darkness progress reset."
	save_data(data)
	return data

static func get_wallet() -> int:
	return int(load_data().get("wallet", REEL_DATA.STARTING_WALLET))

static func get_upgrade_levels() -> Dictionary:
	return load_data().get("meta_upgrades", {}).duplicate(true)

static func get_upgrade_level(key: String) -> int:
	return int(get_upgrade_levels().get(key, 0))

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

static func get_run_config() -> Dictionary:
	return REEL_DATA.get_run_config(get_upgrade_levels())

static func apply_run_results(results: Dictionary) -> Dictionary:
	var data: Dictionary = load_data()
	var money_earned: int = max(0, int(results.get("money_earned", 0)))
	var fish_caught: int = max(0, int(results.get("fish_caught", 0)))
	var deepest_depth: float = max(0.0, float(results.get("deepest_depth", 0.0)))
	data["runs"] = int(data.get("runs", 0)) + 1
	data["wallet"] = int(data.get("wallet", 0)) + money_earned
	data["total_money"] = int(data.get("total_money", 0)) + money_earned
	data["total_fish_caught"] = int(data.get("total_fish_caught", 0)) + fish_caught
	data["best_haul"] = max(int(data.get("best_haul", 0)), money_earned)
	data["best_depth"] = max(float(data.get("best_depth", 0.0)), deepest_depth)
	data["last_run_summary"] = str(results.get("summary_text", "Reel Into Darkness run complete."))
	data["last_run_breakdown"] = results.duplicate(true)
	save_data(data)
	return data
