extends SceneTree

const MINING_SCENE_PATH := "res://Games/Mining/Scenes/MiningMain.tscn"
const OUTPUT_DIR := "res://Games/Mining/Reports"
const MINING_BALANCE := preload("res://Games/Mining/MiningBalance.gd")
const MINING_PROGRESS := preload("res://Games/Mining/MiningProgress.gd")

const SEARCH_SEED := 73
const VALIDATION_SEEDS := [101, 211, 307, 401, 503]
const TARGET_DEMO_PURCHASES := 100
const TARGET_DEMO_SECONDS := 40.0 * 60.0
const TARGET_FULL_SECONDS := 3.0 * 60.0 * 60.0
const MAX_RUNS := 520

var upgrade_catalog: Array[Dictionary] = []
var upgrade_by_id: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	upgrade_catalog = MINING_BALANCE.get_upgrade_catalog()
	for upgrade in upgrade_catalog:
		upgrade_by_id[str(upgrade.get("id", ""))] = upgrade

	var search_campaign: Dictionary = await _run_campaign(true, SEARCH_SEED, [])
	var purchase_plan: Array = search_campaign.get("purchase_plan", [])

	var validations: Array[Dictionary] = []
	for seed in VALIDATION_SEEDS:
		validations.append(await _run_campaign(false, seed, purchase_plan))

	var summary: Dictionary = _build_summary(search_campaign, validations)
	_write_outputs(summary)
	print(JSON.stringify(summary, "\t"))
	quit()

func _run_campaign(use_search: bool, base_seed: int, purchase_plan: Array) -> Dictionary:
	var state: Dictionary = MINING_PROGRESS.get_default_data()
	MINING_BALANCE.refresh_depth_unlocks(state)
	var runs: Array[Dictionary] = []
	var planned_purchase_index := 0
	var total_time := 0.0
	var purchase_order: Array[Dictionary] = []

	for run_index in range(1, MAX_RUNS + 1):
		var best_run: Dictionary = await _choose_best_depth_run(state, base_seed, run_index, 0)
		best_run["run_index"] = run_index
		runs.append(best_run)
		total_time += float(best_run.get("simulated_seconds", 0.0))
		state = best_run.get("projected_data", state).duplicate(true)

		var purchase: Dictionary = {}
		if use_search:
			purchase = await _choose_best_purchase(state, best_run, base_seed, run_index)
		else:
			purchase = _take_next_planned_purchase(state, purchase_plan, planned_purchase_index)
			if not purchase.is_empty():
				planned_purchase_index += 1
		if not purchase.is_empty():
			state = purchase.get("projected_data", state).duplicate(true)
			purchase_order.append(purchase.duplicate(true))
			runs[runs.size() - 1]["upgrade_bought"] = purchase.get("id", "")
			runs[runs.size() - 1]["upgrade_level"] = int(purchase.get("level", 0))
			runs[runs.size() - 1]["upgrade_cost"] = int(purchase.get("cost", 0))
			runs[runs.size() - 1]["wallet_after_spend"] = int(state.get("wallet", 0))
		else:
			runs[runs.size() - 1]["upgrade_bought"] = ""
			runs[runs.size() - 1]["upgrade_level"] = 0
			runs[runs.size() - 1]["upgrade_cost"] = 0
			runs[runs.size() - 1]["wallet_after_spend"] = int(state.get("wallet", 0))

		if _all_upgrades_maxed(state):
			break

	return {
		"seed": base_seed,
		"use_search": use_search,
		"runs": runs,
		"purchase_plan": purchase_order,
		"final_data": state.duplicate(true),
		"total_runs": runs.size(),
		"total_time_seconds": total_time,
		"purchase_count": purchase_order.size(),
		"upgrades_per_run": float(purchase_order.size()) / float(max(1, runs.size())),
		"demo_time_seconds": _get_time_at_purchase_count(purchase_order, TARGET_DEMO_PURCHASES),
	}

func _choose_best_depth_run(state: Dictionary, base_seed: int, run_index: int, salt: int) -> Dictionary:
	var best_run: Dictionary = {}
	var best_score := -INF
	var deepest_level: int = clampi(int(state.get("deepest_level_unlocked", 1)), 1, MINING_BALANCE.MAX_DEPTH_LEVEL)
	for depth_level in range(1, deepest_level + 1):
		var sim_seed: int = _make_seed(base_seed, run_index, depth_level, salt)
		var run_result: Dictionary = await _simulate_run(state, depth_level, sim_seed)
		var score: float = _score_run(run_result)
		if score > best_score:
			best_score = score
			best_run = run_result
	return best_run

func _choose_best_purchase(state: Dictionary, best_run: Dictionary, base_seed: int, run_index: int) -> Dictionary:
	var affordable: Array[Dictionary] = _get_affordable_upgrades(state)
	if affordable.is_empty():
		return {}
	var current_depth: int = int(best_run.get("depth_level", 1))
	var best_purchase: Dictionary = {}
	var best_score := -INF
	for candidate in affordable:
		var purchased_state: Dictionary = _apply_purchase_to_state(state, candidate)
		if purchased_state.is_empty():
			continue
		var preview_seed: int = _make_seed(base_seed, run_index + 1, current_depth, int(candidate.get("level", 0)) + 37)
		var preview_run: Dictionary = await _simulate_run(purchased_state, current_depth, preview_seed)
		var preview_score: float = _score_run(preview_run)
		var discount: float = float(candidate.get("cost", 1))
		var weighted_score: float = preview_score + min(4.0, 240.0 / max(1.0, discount))
		if weighted_score > best_score:
			best_score = weighted_score
			best_purchase = candidate.duplicate(true)
			best_purchase["preview_score"] = preview_score
			best_purchase["projected_data"] = purchased_state.duplicate(true)
	return best_purchase

func _take_next_planned_purchase(state: Dictionary, purchase_plan: Array, start_index: int) -> Dictionary:
	for index in range(start_index, purchase_plan.size()):
		var candidate: Dictionary = purchase_plan[index]
		if not _matches_next_level(state, candidate):
			continue
		var purchased_state: Dictionary = _apply_purchase_to_state(state, candidate)
		if purchased_state.is_empty():
			return {}
		var out: Dictionary = candidate.duplicate(true)
		out["projected_data"] = purchased_state
		return out
	return {}

func _simulate_run(state: Dictionary, depth_level: int, seed: int) -> Dictionary:
	var packed: PackedScene = load(MINING_SCENE_PATH)
	var mining: Node = packed.instantiate()
	root.add_child(mining)
	await process_frame
	var result: Dictionary = mining.call("simulate_autoplay_run", {
		"save_data": state,
		"depth_level": depth_level,
		"seed": seed,
		"autoplay": true,
		"commit_results": false,
		"fixed_delta": 1.0 / 30.0,
		"step_limit": 2400,
	})
	mining.queue_free()
	await process_frame
	return result

func _score_run(run_result: Dictionary) -> float:
	var run_time: float = max(1.0, float(run_result.get("simulated_seconds", 0.0)))
	var money_per_second: float = float(run_result.get("money", 0)) / run_time
	var xp_per_second: float = float(run_result.get("xp", 0)) / run_time
	var depth_bonus: float = float(run_result.get("depth_level", 1)) * 0.42
	var time_utilization: float = 1.0 - (float(run_result.get("time_left", 0.0)) / max(0.1, float(run_result.get("time_limit", 1.0))))
	var drill_pressure: float = 1.0 - (float(run_result.get("drill_left", 0.0)) / max(0.1, float(run_result.get("drill_max", 1.0))))
	return money_per_second + xp_per_second * 0.72 + depth_bonus + time_utilization * 0.7 + drill_pressure * 0.45

func _get_affordable_upgrades(state: Dictionary) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for upgrade in upgrade_catalog:
		var upgrade_id: String = str(upgrade.get("id", ""))
		var current_level: int = int(state.get("upgrades", {}).get(upgrade_id, 0))
		var max_level: int = int(upgrade.get("max_level", 1))
		if current_level >= max_level:
			continue
		if not _requirements_met(state, upgrade):
			continue
		var cost: int = _get_upgrade_cost(upgrade, current_level)
		if int(state.get("wallet", 0)) < cost:
			continue
		options.append({
			"id": upgrade_id,
			"label": str(upgrade.get("label", upgrade_id)),
			"level": current_level + 1,
			"cost": cost,
		})
	options.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("cost", 0)) != int(b.get("cost", 0)):
			return int(a.get("cost", 0)) < int(b.get("cost", 0))
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return options

func _requirements_met(state: Dictionary, upgrade: Dictionary) -> bool:
	var upgrades: Dictionary = state.get("upgrades", {})
	var requires: Dictionary = upgrade.get("requires", {})
	for req_variant in requires.keys():
		var req_id: String = str(req_variant)
		var req_level: int = int(requires[req_variant])
		if int(upgrades.get(req_id, 0)) < req_level:
			return false
	return true

func _apply_purchase_to_state(state: Dictionary, purchase: Dictionary) -> Dictionary:
	if not _matches_next_level(state, purchase):
		return {}
	var upgraded: Dictionary = state.duplicate(true)
	upgraded["wallet"] = max(0, int(upgraded.get("wallet", 0)) - int(purchase.get("cost", 0)))
	var upgrades: Dictionary = upgraded.get("upgrades", {}).duplicate(true)
	upgrades[str(purchase.get("id", ""))] = int(purchase.get("level", 1))
	upgraded["upgrades"] = upgrades
	MINING_BALANCE.refresh_depth_unlocks(upgraded)
	return upgraded

func _matches_next_level(state: Dictionary, purchase: Dictionary) -> bool:
	var purchase_id: String = str(purchase.get("id", ""))
	if purchase_id == "" or not upgrade_by_id.has(purchase_id):
		return false
	var upgrade_def: Dictionary = upgrade_by_id[purchase_id]
	if not _requirements_met(state, upgrade_def):
		return false
	var current_level: int = int(state.get("upgrades", {}).get(purchase_id, 0))
	var desired_level: int = int(purchase.get("level", current_level + 1))
	if desired_level != current_level + 1:
		return false
	return int(state.get("wallet", 0)) >= int(purchase.get("cost", 0))

func _get_upgrade_cost(upgrade: Dictionary, current_level: int) -> int:
	var base_cost: float = float(upgrade.get("base_cost", 0))
	var scale: float = float(upgrade.get("cost_mult", 1.0))
	return int(round(base_cost * pow(scale, current_level)))

func _all_upgrades_maxed(state: Dictionary) -> bool:
	for upgrade in upgrade_catalog:
		var upgrade_id: String = str(upgrade.get("id", ""))
		if int(state.get("upgrades", {}).get(upgrade_id, 0)) < int(upgrade.get("max_level", 1)):
			return false
	return true

func _get_time_at_purchase_count(purchase_plan: Array, purchase_count: int) -> float:
	if purchase_count <= 0 or purchase_plan.is_empty():
		return 0.0
	var actual_index: int = min(purchase_count, purchase_plan.size()) - 1
	return float(purchase_plan[actual_index].get("cumulative_time_seconds", 0.0))

func _build_summary(search_campaign: Dictionary, validations: Array[Dictionary]) -> Dictionary:
	var purchase_index := 0
	for run_index in range(search_campaign.get("runs", []).size()):
		var run_data: Dictionary = search_campaign["runs"][run_index]
		if not str(run_data.get("upgrade_bought", "")).is_empty() and purchase_index < search_campaign.get("purchase_plan", []).size():
			search_campaign["purchase_plan"][purchase_index]["run_index"] = run_index + 1
			search_campaign["purchase_plan"][purchase_index]["cumulative_time_seconds"] = _cumulative_time_for_runs(search_campaign["runs"], purchase_index + 1)
			purchase_index += 1

	var validation_summaries: Array[Dictionary] = []
	for campaign in validations:
		validation_summaries.append(_build_campaign_metrics(campaign))

	var average_total_time := 0.0
	var average_demo_time := 0.0
	var average_run_time := 0.0
	var average_purchase_rate := 0.0
	for metrics in validation_summaries:
		average_total_time += float(metrics.get("total_time_seconds", 0.0))
		average_demo_time += float(metrics.get("demo_time_seconds", 0.0))
		average_run_time += float(metrics.get("avg_run_seconds", 0.0))
		average_purchase_rate += float(metrics.get("upgrades_per_run", 0.0))
	var divisor: float = float(max(1, validation_summaries.size()))
	average_total_time /= divisor
	average_demo_time /= divisor
	average_run_time /= divisor
	average_purchase_rate /= divisor

	var recommended_campaign: Dictionary = _pick_best_validation(validation_summaries)
	return {
		"source": "MiningMain live autoplay campaign",
		"date_utc": Time.get_datetime_string_from_system(true, true),
		"search_campaign": _build_campaign_metrics(search_campaign),
		"search_purchase_plan": search_campaign.get("purchase_plan", []),
		"validations": validation_summaries,
		"targets": {
			"demo_seconds": TARGET_DEMO_SECONDS,
			"full_seconds": TARGET_FULL_SECONDS,
			"upgrades_per_run": 1.0,
			"min_run_seconds": 10.0,
			"max_run_seconds": 40.0,
		},
		"averages": {
			"full_seconds": average_total_time,
			"demo_seconds": average_demo_time,
			"avg_run_seconds": average_run_time,
			"upgrades_per_run": average_purchase_rate,
		},
		"recommended_validation": recommended_campaign,
		"xp_table": _build_xp_table(),
		"upgrade_catalog": upgrade_catalog,
	}

func _build_campaign_metrics(campaign: Dictionary) -> Dictionary:
	var runs: Array = campaign.get("runs", [])
	var total_time: float = float(campaign.get("total_time_seconds", 0.0))
	var total_runs: int = int(campaign.get("total_runs", runs.size()))
	var purchase_count: int = int(campaign.get("purchase_count", 0))
	var avg_run_seconds: float = total_time / float(max(1, total_runs))
	var drill_out_runs := 0
	var timeout_runs := 0
	var min_run := INF
	var max_run := 0.0
	for run_variant in runs:
		var run: Dictionary = run_variant
		var duration: float = float(run.get("simulated_seconds", 0.0))
		min_run = min(min_run, duration)
		max_run = max(max_run, duration)
		var reason: String = str(run.get("reason", ""))
		if reason == "Drill health depleted.":
			drill_out_runs += 1
		elif reason == "Timer expired.":
			timeout_runs += 1
	var final_data: Dictionary = campaign.get("final_data", {})
	return {
		"seed": int(campaign.get("seed", 0)),
		"use_search": bool(campaign.get("use_search", false)),
		"total_time_seconds": total_time,
		"total_runs": total_runs,
		"purchase_count": purchase_count,
		"upgrades_per_run": float(campaign.get("upgrades_per_run", 0.0)),
		"avg_run_seconds": avg_run_seconds,
		"min_run_seconds": 0.0 if min_run == INF else min_run,
		"max_run_seconds": max_run,
		"demo_time_seconds": _cumulative_time_for_runs(runs, TARGET_DEMO_PURCHASES),
		"drill_out_runs": drill_out_runs,
		"timeout_runs": timeout_runs,
		"final_depth_unlocked": int(final_data.get("deepest_level_unlocked", 1)),
		"final_player_level": int(final_data.get("player_level", 1)),
		"final_wallet": int(final_data.get("wallet", 0)),
		"final_upgrades": final_data.get("upgrades", {}).duplicate(true),
		"runs": runs,
	}

func _cumulative_time_for_runs(runs: Array, purchase_count: int) -> float:
	if runs.is_empty():
		return 0.0
	var purchases_seen := 0
	var total_time := 0.0
	for run_variant in runs:
		var run: Dictionary = run_variant
		total_time += float(run.get("simulated_seconds", 0.0))
		if not str(run.get("upgrade_bought", "")).is_empty():
			purchases_seen += 1
			if purchases_seen >= purchase_count:
				return total_time
	return total_time

func _pick_best_validation(validation_summaries: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = {}
	var best_fit := INF
	for summary in validation_summaries:
		var fit: float = abs(float(summary.get("total_time_seconds", 0.0)) - TARGET_FULL_SECONDS)
		fit += abs(float(summary.get("demo_time_seconds", 0.0)) - TARGET_DEMO_SECONDS) * 0.6
		fit += abs(float(summary.get("upgrades_per_run", 0.0)) - 1.0) * 900.0
		fit += max(0.0, 10.0 - float(summary.get("min_run_seconds", 10.0))) * 14.0
		fit += max(0.0, float(summary.get("max_run_seconds", 40.0)) - 40.0) * 18.0
		if fit < best_fit:
			best_fit = fit
			best = summary
	best["fit_score"] = best_fit
	return best

func _build_xp_table() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for level in range(1, MINING_BALANCE.MAX_DEPTH_LEVEL + 8):
		rows.append({
			"level": level,
			"xp_to_next": MINING_BALANCE.get_xp_to_next_level(level),
		})
	return rows

func _write_outputs(summary: Dictionary) -> void:
	var json_path: String = ProjectSettings.globalize_path(OUTPUT_DIR + "/mining_balance_campaign_summary.json")
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(JSON.stringify(summary, "\t"))
		json_file.close()

	var md: PackedStringArray = []
	md.append("# Mining Balance Campaign Summary")
	md.append("")
	md.append("Source: `MiningMain.tscn` live autoplay validation.")
	md.append("Date (UTC): %s" % str(summary.get("date_utc", "")))
	md.append("")
	md.append("## Target Fit")
	md.append("")
	md.append("- Demo target: %.0f sec" % TARGET_DEMO_SECONDS)
	md.append("- Full target: %.0f sec" % TARGET_FULL_SECONDS)
	md.append("- Average upgrades/run target: 1.0")
	md.append("- Average validation full time: %.1f sec" % float(summary.get("averages", {}).get("full_seconds", 0.0)))
	md.append("- Average validation demo time: %.1f sec" % float(summary.get("averages", {}).get("demo_seconds", 0.0)))
	md.append("- Average validation run time: %.2f sec" % float(summary.get("averages", {}).get("avg_run_seconds", 0.0)))
	md.append("- Average upgrades/run: %.3f" % float(summary.get("averages", {}).get("upgrades_per_run", 0.0)))
	md.append("")
	md.append("## Validation Seeds")
	md.append("")
	md.append("| Seed | Total Time (s) | Demo Time (s) | Runs | Purchases | Upgrades/Run | Avg Run (s) | Min Run | Max Run | Drill Outs | Timeouts | Final Depth | Final Level |")
	md.append("|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
	for metrics_variant in summary.get("validations", []):
		var metrics: Dictionary = metrics_variant
		md.append("| %d | %.1f | %.1f | %d | %d | %.3f | %.2f | %.2f | %.2f | %d | %d | %d | %d |" % [
			int(metrics.get("seed", 0)),
			float(metrics.get("total_time_seconds", 0.0)),
			float(metrics.get("demo_time_seconds", 0.0)),
			int(metrics.get("total_runs", 0)),
			int(metrics.get("purchase_count", 0)),
			float(metrics.get("upgrades_per_run", 0.0)),
			float(metrics.get("avg_run_seconds", 0.0)),
			float(metrics.get("min_run_seconds", 0.0)),
			float(metrics.get("max_run_seconds", 0.0)),
			int(metrics.get("drill_out_runs", 0)),
			int(metrics.get("timeout_runs", 0)),
			int(metrics.get("final_depth_unlocked", 1)),
			int(metrics.get("final_player_level", 1)),
		])
	md.append("")
	md.append("## Recommended Purchase Order")
	md.append("")
	md.append("| # | Upgrade | Level | Cost |")
	md.append("|---:|---|---:|---:|")
	var plan_index := 1
	for purchase_variant in summary.get("search_purchase_plan", []):
		var purchase: Dictionary = purchase_variant
		md.append("| %d | %s | %d | %d |" % [
			plan_index,
			str(purchase.get("label", purchase.get("id", ""))),
			int(purchase.get("level", 0)),
			int(purchase.get("cost", 0)),
		])
		plan_index += 1
	md.append("")
	md.append("## XP Curve")
	md.append("")
	md.append("| Level | XP To Next |")
	md.append("|---:|---:|")
	for row_variant in summary.get("xp_table", []):
		var row: Dictionary = row_variant
		md.append("| %d | %d |" % [int(row.get("level", 0)), int(row.get("xp_to_next", 0))])

	var md_path: String = ProjectSettings.globalize_path(OUTPUT_DIR + "/mining_balance_summary.md")
	var md_file: FileAccess = FileAccess.open(md_path, FileAccess.WRITE)
	if md_file != null:
		md_file.store_string("\n".join(md))
		md_file.close()

	var best_campaign: Dictionary = summary.get("recommended_validation", {})
	var timestamp: String = Time.get_datetime_string_from_system(true, false).replace(":", "-").replace(" ", "_")
	var run_path: String = ProjectSettings.globalize_path(OUTPUT_DIR + "/miningRunWithTimeAndDate_%s.md" % timestamp)
	var run_md: PackedStringArray = []
	run_md.append("# Mining Run With Time And Date")
	run_md.append("")
	run_md.append("Best validation seed: %d" % int(best_campaign.get("seed", 0)))
	run_md.append("Date (UTC): %s" % str(summary.get("date_utc", "")))
	run_md.append("Full campaign time: %.1f sec" % float(best_campaign.get("total_time_seconds", 0.0)))
	run_md.append("Demo slice (first %d purchases): %.1f sec" % [TARGET_DEMO_PURCHASES, float(best_campaign.get("demo_time_seconds", 0.0))])
	run_md.append("Average run: %.2f sec" % float(best_campaign.get("avg_run_seconds", 0.0)))
	run_md.append("Upgrades per run: %.3f" % float(best_campaign.get("upgrades_per_run", 0.0)))
	run_md.append("")
	run_md.append("## Upgrade Buys")
	run_md.append("")
	run_md.append("| Run | Upgrade | Level | Cost | Wallet After Spend |")
	run_md.append("|---:|---|---:|---:|---:|")
	for run_variant in best_campaign.get("runs", []):
		var run: Dictionary = run_variant
		var upgrade_id: String = str(run.get("upgrade_bought", ""))
		if upgrade_id.is_empty():
			continue
		run_md.append("| %d | %s | %d | %d | %d |" % [
			int(run.get("run_index", 0)),
			upgrade_id,
			int(run.get("upgrade_level", 0)),
			int(run.get("upgrade_cost", 0)),
			int(run.get("wallet_after_spend", 0)),
		])
	run_md.append("")
	run_md.append("## Run Breakdown")
	run_md.append("")
	run_md.append("| Run | Depth | Time (s) | Money | XP | Nodes | Bank Trips | Delivery Dumps | Reason | Upgrade | Level |")
	run_md.append("|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---:|")
	for run_variant in best_campaign.get("runs", []):
		var run: Dictionary = run_variant
		run_md.append("| %d | %d | %.2f | %d | %d | %d | %d | %d | %s | %s | %d |" % [
			int(run.get("run_index", 0)),
			int(run.get("depth_level", 1)),
			float(run.get("simulated_seconds", 0.0)),
			int(run.get("money", 0)),
			int(run.get("xp", 0)),
			int(run.get("nodes_broken", 0)),
			int(run.get("bank_trips", 0)),
			int(run.get("delivery_dumps", 0)),
			str(run.get("reason", "")),
			str(run.get("upgrade_bought", "")),
			int(run.get("upgrade_level", 0)),
		])
	var run_file: FileAccess = FileAccess.open(run_path, FileAccess.WRITE)
	if run_file != null:
		run_file.store_string("\n".join(run_md))
		run_file.close()

func _make_seed(base_seed: int, run_index: int, depth_level: int, salt: int) -> int:
	return int(base_seed * 100000 + run_index * 251 + depth_level * 19 + salt)
