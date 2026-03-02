extends SceneTree

const BATTLE_SCENE_PATH := "res://Fishing/BattleScene.tscn"
const UPGRADE_DATA_PATH := "res://Data/FishingUpgradeData.json"
const OUTPUT_DIR := "res://simulation/3_2_2026_20_Sims"

const MAX_BASELINE_RUN_TIME_S := 120.0

var upgrades: Array[Dictionary] = []
var upgrade_by_id: Dictionary = {}

func _init() -> void:
	call_deferred("_run_scan")

func _run_scan() -> void:
	await process_frame
	if _sh() == null:
		push_error("SaveHandler autoload not found at /root/SaveHandler")
		quit()
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_load_upgrade_data()

	var rows: Array[Dictionary] = []
	for entry_variant in upgrades:
		var entry: Dictionary = entry_variant
		var row: Dictionary = await _measure_single_upgrade(entry)
		rows.append(row)

	var summary: Dictionary = {
		"source": "upgrade_effectiveness_scan",
		"date_utc": Time.get_datetime_string_from_system(true, true),
		"upgrades": rows,
	}

	var json_out: String = JSON.stringify(summary, "\t")
	var json_path: String = ProjectSettings.globalize_path(OUTPUT_DIR + "/upgrade_effectiveness.json")
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(json_out)
		json_file.close()

	_write_markdown_report(summary)
	print("Upgrade effectiveness scan complete.")
	quit()

func _measure_single_upgrade(entry: Dictionary) -> Dictionary:
	var id: String = str(entry.get("id", ""))
	var key: String = str(entry.get("key", ""))
	var level: int = int(entry.get("level", 1))
	var repeatable: bool = bool(entry.get("repeatable", false))

	# Baseline: previous level of this key (or 0).
	_reset_fishing_save()
	_apply_prior_levels_for_key(key, level - 1, repeatable)
	var before: Dictionary = await _run_single_battle(id, key, level, false)

	# After: purchase this upgrade level and re-run.
	_reset_fishing_save()
	_apply_prior_levels_for_key(key, level - 1, repeatable)
	_force_unlock_level(key, level, repeatable)
	var after: Dictionary = await _run_single_battle(id, key, level, true)

	var kills_before: int = int(before.get("enemies_killed", 0))
	var kills_after: int = int(after.get("enemies_killed", 0))
	var coins_before: int = int(before.get("coins_gained", 0))
	var coins_after: int = int(after.get("coins_gained", 0))
	var run_time_before: float = float(before.get("run_time_s", 0.0))
	var run_time_after: float = float(after.get("run_time_s", 0.0))

	var kills_per_run_before: float = float(kills_before)
	var kills_per_run_after: float = float(kills_after)
	var coins_per_run_before: float = float(coins_before)
	var coins_per_run_after: float = float(coins_after)

	var dk: float = kills_per_run_after - kills_per_run_before
	var dc: float = coins_per_run_after - coins_per_run_before

	return {
		"id": id,
		"key": key,
		"level": level,
		"repeatable": repeatable,
		"baseline": before,
		"after": after,
		"delta_kills_per_run": dk,
		"delta_coins_per_run": dc,
		"run_time_before_s": run_time_before,
		"run_time_after_s": run_time_after,
		"run_index": int(after.get("run_index", 0)),
	}

func _run_single_battle(upgrade_id: String, key: String, level: int, after_purchase: bool) -> Dictionary:
	var packed: PackedScene = load(BATTLE_SCENE_PATH)
	var battle: Node = packed.instantiate()
	root.add_child(battle)
	await process_frame

	var label_prefix: String = "pre" if not after_purchase else "post"
	battle.call("_run_infinite_simulation")
	if not bool(battle.get("battle_completed")):
		battle.call("_end_battle", false)

	var summary: Dictionary = _sh().fishing_last_battle_summary.duplicate(true)
	var run_time_s: float = float(battle.get("last_sim_seconds"))
	var killed: int = int(summary.get("enemies_killed", 0))
	var segments: int = int(summary.get("boss_segments_broken", 0))
	var defeated: bool = bool(summary.get("victory", false))
	var coins: int = int(summary.get("coins_gained", 0))

	battle.queue_free()
	await process_frame

	return {
		"upgrade_id": upgrade_id,
		"upgrade_key": key,
		"upgrade_level": level,
		"phase": label_prefix,
		"run_time_s": run_time_s,
		"enemies_killed": killed,
		"boss_segments_broken": segments,
		"boss_defeated": defeated,
		"coins_gained": coins,
		"run_index": 1,
	}

func _apply_prior_levels_for_key(key: String, target_level: int, repeatable: bool) -> void:
	if key == "" or target_level <= 0:
		return
	var clamped_level: int = max(0, target_level)
	_sh().fishing_unlocked_upgrades = {}
	_sh().fishing_active_upgrades = {}
	if repeatable:
		_sh().fishing_unlocked_upgrades[key] = clamped_level
		_sh().fishing_active_upgrades[key] = true
	else:
		_sh().fishing_unlocked_upgrades[key] = clamped_level
		_sh().fishing_active_upgrades[key] = true
	_sh().save_fishing_progress()

func _force_unlock_level(key: String, level: int, repeatable: bool) -> void:
	if key == "":
		return
	_sh().unlock_fishing_upgrade(key, repeatable)
	_sh().save_fishing_progress()

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

func _reset_fishing_save() -> void:
	_sh().fishing_currency = 0
	_sh().fishing_lifetime_coins = 0
	_sh().fishing_unlocked_upgrades = {}
	_sh().fishing_active_upgrades = {}
	_sh().fishing_last_battle_summary = {}
	_sh().fishing_next_battle_level = 1
	_sh().fishing_max_unlocked_battle_level = 1
	_sh().save_fishing_progress()

func _write_markdown_report(summary: Dictionary) -> void:
	var md: PackedStringArray = []
	md.append("# Upgrade Effectiveness Scan")
	md.append("")
	md.append("Source: battle scene infinite sim, one-upgrade delta per key-level.")
	md.append("Date (UTC): %s" % str(summary.get("date_utc", "")))
	md.append("")
	md.append("| ID | Key | Level | Δ Kills/Run | Δ Coins/Run | Pre Time (s) | Post Time (s) |")
	md.append("|---|---|---:|---:|---:|---:|---:|")

	for row_variant in summary.get("upgrades", []):
		var row: Dictionary = row_variant
		md.append(
			"| %s | %s | %d | %+0.2f | %+0.1f | %0.1f | %0.1f |" % [
				str(row.get("id", "")),
				str(row.get("key", "")),
				int(row.get("level", 1)),
				float(row.get("delta_kills_per_run", 0.0)),
				float(row.get("delta_coins_per_run", 0.0)),
				float(row.get("run_time_before_s", 0.0)),
				float(row.get("run_time_after_s", 0.0)),
			]
		)

	var md_out: String = "\n".join(md)
	var md_path: String = ProjectSettings.globalize_path(OUTPUT_DIR + "/upgrade_effectiveness_report.md")
	var md_file: FileAccess = FileAccess.open(md_path, FileAccess.WRITE)
	if md_file != null:
		md_file.store_string(md_out)
		md_file.close()

func _sh() -> Node:
	return root.get_node_or_null("/root/SaveHandler")

