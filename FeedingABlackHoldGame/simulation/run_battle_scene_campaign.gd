extends SceneTree

const BATTLE_SCENE_PATH := "res://Fishing/BattleScene.tscn"
const UPGRADE_DATA_PATH := "res://Data/FishingUpgradeData.json"
const TARGET_SECONDS := 7200.0
const MAX_RUNS := 300

var upgrades: Array[Dictionary] = []
var upgrade_by_id: Dictionary = {}
var results: Array[Dictionary] = []

func _init() -> void:
	call_deferred("_run_campaign")

func _run_campaign() -> void:
	await process_frame
	if _sh() == null:
		push_error("SaveHandler autoload not found at /root/SaveHandler")
		quit()
		return
	_reset_fishing_save()
	_load_upgrade_data()

	var total_time: float = 0.0
	var current_level: int = 1
	var boss_defeats: int = 0
	var run_index: int = 0

	while total_time < TARGET_SECONDS and run_index < MAX_RUNS:
		run_index += 1
		_sh().fishing_next_battle_level = current_level
		_sh().save_fishing_progress()

		var run_result: Dictionary = await _run_single_battle(run_index, current_level)
		total_time += float(run_result.get("run_time_s", 0.0))
		results.append(run_result)

		if bool(run_result.get("boss_defeated", false)):
			boss_defeats += 1
			current_level = min(3, current_level + 1)

		var bought: Array[String] = _buy_affordable_upgrades()
		run_result["upgrades_bought"] = bought
		run_result["wallet_after_spend"] = _sh().fishing_currency
		results[results.size() - 1] = run_result

		if total_time >= TARGET_SECONDS:
			break

	var summary: Dictionary = {
		"source": "battle_scene_infinite_sim",
		"date_utc": Time.get_datetime_string_from_system(true, true),
		"target_seconds": TARGET_SECONDS,
		"simulated_seconds": total_time,
		"total_runs": results.size(),
		"boss_defeats": boss_defeats,
		"max_level_reached": _max_level_reached(),
		"final_level": current_level,
		"final_currency": _sh().fishing_currency,
		"runs": results,
	}

	var json_out: String = JSON.stringify(summary, "\t")
	var out_path: String = ProjectSettings.globalize_path("res://simulation/simulation_results_2h_battlescene_progression.json")
	var out_file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if out_file != null:
		out_file.store_string(json_out)
		out_file.close()

	print(json_out)
	quit()

func _run_single_battle(run_index: int, level: int) -> Dictionary:
	var packed: PackedScene = load(BATTLE_SCENE_PATH)
	var battle: Node = packed.instantiate()
	root.add_child(battle)
	await process_frame

	battle.call("_run_infinite_simulation")
	if not bool(battle.get("battle_completed")):
		battle.call("_end_battle", false)

	var summary: Dictionary = _sh().fishing_last_battle_summary.duplicate(true)
	var run_time_s: float = float(battle.get("last_sim_seconds"))
	var killed: int = int(summary.get("enemies_killed", 0))
	var segments: int = int(summary.get("boss_segments_broken", 0))
	var defeated: bool = bool(summary.get("victory", false))
	var coins: int = int(summary.get("coins_gained", 0))
	var wallet_before: int = int(_sh().fishing_currency) - coins

	battle.queue_free()
	await process_frame

	return {
		"run": run_index,
		"level": level,
		"run_time_s": run_time_s,
		"enemies_killed": killed,
		"boss_segments_broken": segments,
		"boss_defeated": defeated,
		"coins_gained": coins,
		"wallet_before": wallet_before,
		"wallet_after_earn": _sh().fishing_currency,
		"upgrades_bought": [],
		"wallet_after_spend": _sh().fishing_currency,
	}

func _buy_affordable_upgrades() -> Array[String]:
	var bought: Array[String] = []
	var made_purchase: bool = true
	while made_purchase:
		made_purchase = false
		for upgrade in upgrades:
			if not _can_buy_upgrade(upgrade):
				continue
			var cost_i: int = int(round(float(upgrade.get("cost", 0.0))))
			if int(_sh().fishing_currency) < cost_i:
				continue
			_sh().fishing_currency -= cost_i
			_sh().unlock_fishing_upgrade(str(upgrade.get("key", "")), bool(upgrade.get("repeatable", false)))
			bought.append(str(upgrade.get("id", "")))
			made_purchase = true
	_sh().save_fishing_progress()
	return bought

func _can_buy_upgrade(upgrade: Dictionary) -> bool:
	var key: String = str(upgrade.get("key", ""))
	var level: int = int(upgrade.get("level", 1))
	var repeatable: bool = bool(upgrade.get("repeatable", false))
	var dependency = upgrade.get("dependency", null)

	if dependency != null and str(dependency) != "" and not _is_dependency_met(str(dependency)):
		return false

	var current_level: int = _sh().get_fishing_upgrade_level(key)
	if repeatable:
		return current_level + 1 == level
	return current_level < level

func _is_dependency_met(dependency_id: String) -> bool:
	if upgrade_by_id.has(dependency_id):
		var dep: Dictionary = upgrade_by_id[dependency_id]
		var dep_key: String = str(dep.get("key", ""))
		var dep_level: int = int(dep.get("level", 1))
		return _sh().get_fishing_upgrade_level(dep_key) >= dep_level
	return _sh().get_fishing_upgrade_level(dependency_id) > 0

func _load_upgrade_data() -> void:
	upgrades.clear()
	upgrade_by_id.clear()
	var raw: String = FileAccess.get_file_as_string(UPGRADE_DATA_PATH)
	var parsed = JSON.parse_string(raw)
	if parsed == null:
		push_error("Failed to parse upgrade data at %s" % UPGRADE_DATA_PATH)
		return
	var arr: Array = parsed.get("upgrades", [])
	for entry_variant in arr:
		var entry: Dictionary = entry_variant
		upgrades.append(entry)
		upgrade_by_id[str(entry.get("id", ""))] = entry
	upgrades.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ay: int = int(a.get("grid_y", 0))
		var by: int = int(b.get("grid_y", 0))
		if ay != by:
			return ay < by
		var ax: int = int(a.get("grid_x", 0))
		var bx: int = int(b.get("grid_x", 0))
		if ax != bx:
			return ax < bx
		return int(a.get("level", 1)) < int(b.get("level", 1))
	)

func _reset_fishing_save() -> void:
	_sh().fishing_currency = 0
	_sh().fishing_lifetime_coins = 0
	_sh().fishing_unlocked_upgrades = {}
	_sh().fishing_active_upgrades = {}
	_sh().fishing_last_battle_summary = {}
	_sh().fishing_next_battle_level = 1
	_sh().fishing_max_unlocked_battle_level = 1
	_sh().save_fishing_progress()

func _max_level_reached() -> int:
	var max_level: int = 1
	for run in results:
		max_level = max(max_level, int(run.get("level", 1)))
	return max_level

func _sh() -> Node:
	return root.get_node_or_null("/root/SaveHandler")
