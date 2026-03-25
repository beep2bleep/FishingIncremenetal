extends SceneTree

const MINING_SCENE_PATH := "res://Games/Mining/Scenes/MiningMain.tscn"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var args: Dictionary = _parse_args()
	var input_path: String = str(args.get("input", ProjectSettings.globalize_path("res://Games/Mining/Reports/mining_validation_input.json")))
	var output_path: String = str(args.get("output", ProjectSettings.globalize_path("res://Games/Mining/Reports/mining_validation_output.json")))
	var raw: String = FileAccess.get_file_as_string(input_path)
	var parsed = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		push_error("Validation input must be a JSON object.")
		quit()
		return
	var scenarios: Array = parsed.get("scenarios", [])
	var results: Array[Dictionary] = []
	for scenario_variant in scenarios:
		var scenario: Dictionary = scenario_variant
		results.append(await _run_single_scenario(scenario))
	var out: Dictionary = {
		"date_utc": Time.get_datetime_string_from_system(true, true),
		"results": results,
	}
	var file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(out, "\t"))
		file.close()
	print(JSON.stringify(out, "\t"))
	quit()

func _run_single_scenario(scenario: Dictionary) -> Dictionary:
	var packed: PackedScene = load(MINING_SCENE_PATH)
	var mining: Node = packed.instantiate()
	root.add_child(mining)
	await process_frame
	var result: Dictionary = mining.call("simulate_autoplay_run", {
		"save_data": scenario.get("save_data", {}),
		"depth_level": int(scenario.get("depth_level", 1)),
		"seed": int(scenario.get("seed", -1)),
		"autoplay": true,
		"commit_results": false,
		"fixed_delta": float(scenario.get("fixed_delta", 1.0 / 30.0)),
		"step_limit": int(scenario.get("step_limit", 2400)),
	})
	mining.queue_free()
	await process_frame
	result["scenario_id"] = str(scenario.get("id", ""))
	return result

func _parse_args() -> Dictionary:
	var args_out: Dictionary = {}
	for arg in OS.get_cmdline_user_args():
		if not String(arg).contains("="):
			continue
		var parts: PackedStringArray = String(arg).split("=", false, 1)
		if parts.size() != 2:
			continue
		var key: String = parts[0].trim_prefix("--")
		args_out[key] = parts[1]
	return args_out
