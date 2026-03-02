extends SceneTree

const BATTLE_SCENE_PATH := "res://Fishing/BattleScene.tscn"
const UPGRADE_DATA_PATH := "res://Data/FishingUpgradeData.json"
const EFFECTIVENESS_PATH := "res://simulation/3_2_2026_20_Sims/upgrade_effectiveness.json"
const OUTPUT_ROOT := "res://simulation/3_2_2026_20_Sims"

const MAX_RUNS_PER_PASS := 300
const TARGET_MIN_SECONDS := 3600.0
const TARGET_MAX_SECONDS := 7200.0

const PASS_NAMES: Array[String] = ["pass_01", "pass_02", "pass_03"]
const PASS_SEEDS: Array[int] = [1101, 2202, 3303]
const PRICE_MULTS: Array[float] = [1.80, 2.00, 2.15, 2.30]

var upgrades: Array[Dictionary] = []
var upgrade_by_id: Dictionary = {}
var effectiveness_by_id: Dictionary = {}

func _init() -> void:
	call_deferred("_run_all")

func _run_all() -> void:
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	_load_upgrade_data()
	_load_effectiveness_data()

	var overview_rows: Array[Dictionary] = []
	for price_mult in PRICE_MULTS:
		for i in range(PASS_NAMES.size()):
			var pass_name: String = PASS_NAMES[i]
			var seed_value: int = PASS_SEEDS[i]
			seed(seed_value)
			var result: Dictionary = await _run_single_pass(pass_name, seed_value, float(price_mult))
			overview_rows.append(result)
			_write_pass_reports(pass_name, price_mult, result)

	_write_overview(overview_rows)
	_write_pricing_recommendation(overview_rows)
	print("Guided run-until-L3-boss progression passes complete.")
	quit()

func _run_single_pass(pass_name: String, seed_value: int, price_mult: float) -> Dictionary:
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

		var buy_result: Dictionary = _buy_single_best_upgrade(price_mult)
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
		"price_mult": price_mult,
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

func _buy_single_best_upgrade(price_mult: float) -> Dictionary:
	var best_id: String = ""
	var best_score: float = 0.0
	var best_cost: int = 0

	for upgrade in upgrades:
		if not _can_buy_upgrade(upgrade):
			continue
		var id: String = str(upgrade.get("id", ""))
		var cost_i: int = int(round(float(upgrade.get("cost", 0.0)) * price_mult))
		if int(_sh().fishing_currency) < cost_i:
			continue

		var score: float = _upgrade_score(id)
		if score <= 0.0:
			continue
		if best_id == "" or score > best_score:
			best_id = id
			best_score = score
			best_cost = cost_i

	if best_id == "":
		return {"keys": [], "count": 0, "cost": 0.0}

	var best_upgrade: Dictionary = upgrade_by_id.get(best_id, {})
	if best_upgrade.is_empty():
		return {"keys": [], "count": 0, "cost": 0.0}

	_sh().fishing_currency -= best_cost
	_sh().unlock_fishing_upgrade(str(best_upgrade.get("key", "")), bool(best_upgrade.get("repeatable", false)))
	_sh().save_fishing_progress()
	return {
		"keys": [best_id],
		"count": 1,
		"cost": float(best_cost),
	}

func _upgrade_score(id: String) -> float:
	if not effectiveness_by_id.has(id):
		return 0.0
	var row: Dictionary = effectiveness_by_id[id]
	var dk: float = float(row.get("delta_kills_per_run", 0.0))
	var dc: float = float(row.get("delta_coins_per_run", 0.0))
	# Prioritize kill rate strongly, with coins as a secondary tie-breaker.
	return dk + dc * 0.01

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

func _load_effectiveness_data() -> void:
	effectiveness_by_id.clear()
	if not FileAccess.file_exists(EFFECTIVENESS_PATH):
		push_error("Guided progression: effectiveness file not found at %s" % EFFECTIVENESS_PATH)
		return
	var raw: String = FileAccess.get_file_as_string(EFFECTIVENESS_PATH)
	if raw == "":
		return
	var parsed = JSON.parse_string(raw)
	if parsed == null or not (parsed is Dictionary):
		return
	var dict_sim: Dictionary = parsed
	var rows_variant: Variant = dict_sim.get("upgrades", [])
	if not (rows_variant is Array):
		return
	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var row: Dictionary = row_variant
		var id: String = str(row.get("id", ""))
		if id == "":
			continue
		effectiveness_by_id[id] = row

func _reset_fishing_save() -> void:
	_sh().fishing_currency = 0
	_sh().fishing_lifetime_coins = 0
	_sh().fishing_unlocked_upgrades = {}
	_sh().fishing_active_upgrades = {}
	_sh().fishing_last_battle_summary = {}
	_sh().fishing_next_battle_level = 1
	_sh().fishing_max_unlocked_battle_level = 1
	_sh().save_fishing_progress()

func _write_pass_reports(pass_name: String, price_mult: float, result: Dictionary) -> void:
	var tag: String = "mult_%.2f_%s_to_l3_boss" % [price_mult, pass_name]
	var abs_base: String = ProjectSettings.globalize_path(OUTPUT_ROOT) + "/" + tag

	var json_file: FileAccess = FileAccess.open(abs_base + ".json", FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(JSON.stringify(result, "\t"))
		json_file.close()

	var md: PackedStringArray = []
	md.append("# Guided Run Until L3 Boss - %s" % tag)
	md.append("")
	md.append("- Seed: `%d`" % int(result.get("seed", 0)))
	md.append("- Price Multiplier: `%.2f`" % float(result.get("price_mult", 1.0)))
	md.append("- Runs to L3 boss clear: `%d`" % int(result.get("runs_to_l3_boss_clear", 0)))
	md.append("- Total time to L3 boss clear (s): `%.1f`" % float(result.get("total_time_s_to_l3_boss_clear", 0.0)))
	md.append("- Avg upgrades/run: `%.2f`" % float(result.get("avg_upgrades_per_run", 0.0)))
	md.append("- Avg kill delta/run: `%.2f`" % float(result.get("avg_kill_delta_per_run", 0.0)))
	md.append("- Level 3 boss defeated: `%s`" % str(result.get("level3_boss_defeated", false)))
	md.append("")
	md.append("| Run | Level | Time(s) | Kills | Delta | Boss Seg | Boss Defeated | Earned | Upgrades Bought | Cost | Wallet After Spend |")
	md.append("|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
	for run_variant in result.get("runs", []):
		var run: Dictionary = run_variant
		md.append("| %d | %d | %.1f | %d | %d | %d | %s | %d | %d | %.1f | %d |" % [
			int(run.get("run", 0)),
			int(run.get("level", 1)),
			float(run.get("run_time_s", 0.0)),
			int(run.get("enemies_killed", 0)),
			int(run.get("kill_delta", 0)),
			int(run.get("boss_segments_broken", 0)),
			str(run.get("boss_defeated", false)),
			int(run.get("coins_gained", 0)),
			int(run.get("upgrades_bought_count", 0)),
			float(run.get("upgrade_cost", 0.0)),
			int(run.get("wallet_after_spend", 0)),
		])

	var md_file: FileAccess = FileAccess.open(abs_base + ".md", FileAccess.WRITE)
	if md_file != null:
		md_file.store_string("\n".join(md) + "\n")
		md_file.close()

func _write_overview(rows: Array[Dictionary]) -> void:
	var md: PackedStringArray = []
	md.append("# Guided Run Until L3 Boss Overview")
	md.append("")
	md.append("| Price Mult | Pass | Seed | L3 Boss Defeated | Runs to L3 | Time to L3 (s) | Avg Upgrades/Run | Avg Kill Δ/Run |")
	md.append("|---:|---|---:|---:|---:|---:|---:|---:|")
	for row_variant in rows:
		var row: Dictionary = row_variant
		md.append("| %.2f | %s | %d | %s | %d | %.1f | %.2f | %.2f |" % [
			float(row.get("price_mult", 1.0)),
			str(row.get("pass", "")),
			int(row.get("seed", 0)),
			str(row.get("level3_boss_defeated", false)),
			int(row.get("runs_to_l3_boss_clear", 0)),
			float(row.get("total_time_s_to_l3_boss_clear", 0.0)),
			float(row.get("avg_upgrades_per_run", 0.0)),
			float(row.get("avg_kill_delta_per_run", 0.0)),
		])

	var path: String = ProjectSettings.globalize_path(OUTPUT_ROOT) + "/guided_l3_overview.md"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(md) + "\n")
		file.close()

func _write_pricing_recommendation(rows: Array[Dictionary]) -> void:
	if rows.is_empty():
		return

	var by_mult: Dictionary = {}
	for row_variant in rows:
		var row: Dictionary = row_variant
		var m: float = float(row.get("price_mult", 1.0))
		if not by_mult.has(m):
			by_mult[m] = []
		var arr: Array = by_mult[m]
		arr.append(row)
		by_mult[m] = arr

	var best_mult: float = -1.0
	var best_score: float = -INF

	for mult_variant in by_mult.keys():
		var m: float = float(mult_variant)
		var arr: Array = by_mult[m]
		var total_time: float = 0.0
		var total_runs: float = 0.0
		var total_upgrades_per_run: float = 0.0
		var clears: int = 0
		for row_variant in arr:
			var row: Dictionary = row_variant
			total_time += float(row.get("total_time_s_to_l3_boss_clear", 0.0))
			total_runs += float(row.get("runs_to_l3_boss_clear", 0))
			total_upgrades_per_run += float(row.get("avg_upgrades_per_run", 0.0))
			if bool(row.get("level3_boss_defeated", false)):
				clears += 1
		var n: float = max(1.0, float(arr.size()))
		var avg_time: float = total_time / n
		var avg_runs: float = total_runs / n
		var avg_upgrades: float = total_upgrades_per_run / n

		# Require that, on average, L3 boss is defeated and time is in the 1–2h band.
		if clears <= 0:
			continue
		if avg_time < TARGET_MIN_SECONDS or avg_time > TARGET_MAX_SECONDS:
			continue

		# Score prefers ~1 upgrade per run and time near 1.5h mid-point.
		var upgrades_penalty: float = abs(avg_upgrades - 1.0)
		var time_mid: float = (TARGET_MIN_SECONDS + TARGET_MAX_SECONDS) * 0.5
		var time_penalty: float = abs(avg_time - time_mid) / time_mid
		var score: float = -upgrades_penalty * 2.0 - time_penalty
		if best_mult < 0.0 or score > best_score:
			best_mult = m
			best_score = score

	var rec: Dictionary = {
		"target_min_seconds": TARGET_MIN_SECONDS,
		"target_max_seconds": TARGET_MAX_SECONDS,
		"recommended_price_mult": best_mult,
		"note": "Apply this multiplier to upgrade costs in progression sims to target a level 3 boss clear between 1 and 2 hours with roughly one impactful upgrade per run.",
	}
	var json_path: String = ProjectSettings.globalize_path(OUTPUT_ROOT) + "/guided_l3_pricing_recommendation.json"
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(JSON.stringify(rec, "\t"))
		json_file.close()

	var md: PackedStringArray = []
	md.append("# Guided L3 Boss Pricing Recommendation")
	md.append("")
	md.append("- Target window: %.0f–%.0f seconds (1–2 hours)" % [TARGET_MIN_SECONDS, TARGET_MAX_SECONDS])
	if best_mult > 0.0:
		md.append("- **Recommended price multiplier**: `%.2f`" % best_mult)
	else:
		md.append("- **No multiplier in the tested set satisfied the constraints.**")
	md.append("")
	md.append("See `guided_l3_overview.md` for per-multiplier details.")

	var md_path: String = ProjectSettings.globalize_path(OUTPUT_ROOT) + "/guided_l3_pricing_recommendation.md"
	var md_file: FileAccess = FileAccess.open(md_path, FileAccess.WRITE)
	if md_file != null:
		md_file.store_string("\n".join(md) + "\n")
		md_file.close()

func _sh() -> Node:
	return root.get_node_or_null("/root/SaveHandler")

