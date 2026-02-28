extends SceneTree

const BATTLE_SCENE_PATH := "res://Fishing/BattleScene.tscn"
const UPGRADE_DATA_PATH := "res://Data/FishingUpgradeData.json"
const OUTPUT_DIR := "res://simulation/20_run_simluations"
const PRICE_MULT := 2.15
const MAX_RUNS_PER_PASS := 200
const PASS_NAMES: Array[String] = ["pass_01", "pass_02", "pass_03"]
const PASS_SEEDS: Array[int] = [1101, 2202, 3303]

var upgrades: Array[Dictionary] = []
var upgrade_by_id: Dictionary = {}

func _init() -> void:
	call_deferred("_run_all")

func _run_all() -> void:
	await process_frame
	_load_upgrade_data()
	_ensure_output_dir()

	var overview_rows: Array[Dictionary] = []
	for i in range(PASS_NAMES.size()):
		var pass_name: String = PASS_NAMES[i]
		var seed_value: int = PASS_SEEDS[i]
		seed(seed_value)
		var result: Dictionary = await _run_single_pass(pass_name, seed_value)
		overview_rows.append(result)
		_write_pass_reports(pass_name, result)

	_write_overview(overview_rows)
	print("Extended passes complete.")
	quit()

func _run_single_pass(pass_name: String, seed_value: int) -> Dictionary:
	_reset_fishing_save()
	var runs: Array[Dictionary] = []
	var current_level: int = 1
	var previous_kills: int = 0
	var total_time_s: float = 0.0
	var level3_boss_defeated: bool = false

	for run_index in range(1, MAX_RUNS_PER_PASS + 1):
		_sh().fishing_next_battle_level = current_level
		_sh().save_fishing_progress()
		var run_result: Dictionary = await _run_single_battle(run_index, current_level)
		total_time_s += float(run_result.get("run_time_s", 0.0))

		var kills: int = int(run_result.get("enemies_killed", 0))
		var kill_delta: int = 0 if run_index == 1 else (kills - previous_kills)
		run_result["kill_delta"] = kill_delta
		previous_kills = kills

		if bool(run_result.get("boss_defeated", false)):
			if int(run_result.get("level", 1)) >= 3:
				level3_boss_defeated = true
			current_level = min(3, current_level + 1)

		var buy_result: Dictionary = _buy_affordable_upgrades()
		run_result["upgrades_bought"] = buy_result.get("keys", [])
		run_result["upgrades_bought_count"] = int(buy_result.get("count", 0))
		run_result["upgrade_cost"] = float(buy_result.get("cost", 0.0))
		run_result["wallet_after_spend"] = int(_sh().fishing_currency)
		runs.append(run_result)

		if level3_boss_defeated:
			break

	var avg_upgrades: float = 0.0
	for run_variant in runs:
		var run: Dictionary = run_variant
		avg_upgrades += float(run.get("upgrades_bought_count", 0))
	avg_upgrades /= max(1.0, float(runs.size()))

	var avg_kill_delta: float = 0.0
	if runs.size() > 1:
		for idx in range(1, runs.size()):
			var run: Dictionary = runs[idx]
			avg_kill_delta += float(run.get("kill_delta", 0))
		avg_kill_delta /= float(runs.size() - 1)

	return {
		"pass": pass_name,
		"seed": seed_value,
		"price_mult": PRICE_MULT,
		"runs": runs,
		"runs_to_l3_boss_clear": runs.size(),
		"total_time_s_to_l3_boss_clear": total_time_s,
		"avg_upgrades_per_run": avg_upgrades,
		"avg_kill_delta_per_run": avg_kill_delta,
		"level3_boss_defeated": level3_boss_defeated,
		"final_currency": int(_sh().fishing_currency),
	}

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
		"wallet_after_earn": int(_sh().fishing_currency),
	}

func _buy_affordable_upgrades() -> Dictionary:
	var bought: Array[String] = []
	var total_cost: float = 0.0
	var made_purchase: bool = true
	while made_purchase:
		made_purchase = false
		for upgrade in upgrades:
			if not _can_buy_upgrade(upgrade):
				continue
			var cost_i: int = _upgrade_cost(upgrade)
			if int(_sh().fishing_currency) < cost_i:
				continue
			_sh().fishing_currency -= cost_i
			_sh().unlock_fishing_upgrade(str(upgrade.get("key", "")), bool(upgrade.get("repeatable", false)))
			bought.append(str(upgrade.get("id", "")))
			total_cost += cost_i
			made_purchase = true
	_sh().save_fishing_progress()
	return {"keys": bought, "count": bought.size(), "cost": total_cost}

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

func _upgrade_cost(upgrade: Dictionary) -> int:
	return int(round(float(upgrade.get("cost", 0.0)) * PRICE_MULT))

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
		var a_cost: float = float(a.get("cost", 0.0))
		var b_cost: float = float(b.get("cost", 0.0))
		if a_cost != b_cost:
			return a_cost < b_cost
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

func _ensure_output_dir() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)

func _write_pass_reports(pass_name: String, result: Dictionary) -> void:
	var abs_base: String = ProjectSettings.globalize_path(OUTPUT_DIR) + "/" + pass_name + "_to_l3_boss"
	var json_file: FileAccess = FileAccess.open(abs_base + ".json", FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(JSON.stringify(result, "\t"))
		json_file.close()

	var md: PackedStringArray = []
	md.append("# Extended Run To Level 3 Boss - %s" % pass_name)
	md.append("")
	md.append("- Seed: `%d`" % int(result.get("seed", 0)))
	md.append("- Runs to L3 boss clear: `%d`" % int(result.get("runs_to_l3_boss_clear", 0)))
	md.append("- Total time to L3 boss clear (s): `%.1f`" % float(result.get("total_time_s_to_l3_boss_clear", 0.0)))
	md.append("- Avg upgrades/run: `%.2f`" % float(result.get("avg_upgrades_per_run", 0.0)))
	md.append("- Avg kill delta/run: `%.2f`" % float(result.get("avg_kill_delta_per_run", 0.0)))
	md.append("")
	md.append("| Run | Level | Time(s) | Kills | Delta | Boss Seg | Boss Defeated | Earned | Upgrades Bought |")
	md.append("|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
	for run_variant in result.get("runs", []):
		var run: Dictionary = run_variant
		md.append("| %d | %d | %.1f | %d | %d | %d | %s | %d | %d |" % [
			int(run.get("run", 0)),
			int(run.get("level", 1)),
			float(run.get("run_time_s", 0.0)),
			int(run.get("enemies_killed", 0)),
			int(run.get("kill_delta", 0)),
			int(run.get("boss_segments_broken", 0)),
			str(run.get("boss_defeated", false)),
			int(run.get("coins_gained", 0)),
			int(run.get("upgrades_bought_count", 0)),
		])
	var md_file: FileAccess = FileAccess.open(abs_base + ".md", FileAccess.WRITE)
	if md_file != null:
		md_file.store_string("\n".join(md) + "\n")
		md_file.close()

func _write_overview(rows: Array[Dictionary]) -> void:
	var md: PackedStringArray = []
	md.append("# Extended To Level 3 Boss Overview")
	md.append("")
	md.append("| Pass | Seed | Runs to L3 Boss Clear | Time to L3 Clear (s) | Avg Upgrades/Run | Avg Kill Delta/Run |")
	md.append("|---|---:|---:|---:|---:|---:|")
	for row_variant in rows:
		var row: Dictionary = row_variant
		md.append("| %s | %d | %d | %.1f | %.2f | %.2f |" % [
			str(row.get("pass", "")),
			int(row.get("seed", 0)),
			int(row.get("runs_to_l3_boss_clear", 0)),
			float(row.get("total_time_s_to_l3_boss_clear", 0.0)),
			float(row.get("avg_upgrades_per_run", 0.0)),
			float(row.get("avg_kill_delta_per_run", 0.0)),
		])
	var path: String = ProjectSettings.globalize_path(OUTPUT_DIR) + "/overview_to_l3_boss.md"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(md) + "\n")
		file.close()

func _sh() -> Node:
	return root.get_node_or_null("/root/SaveHandler")
