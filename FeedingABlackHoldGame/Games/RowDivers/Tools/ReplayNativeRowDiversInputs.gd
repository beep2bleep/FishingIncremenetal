extends SceneTree
## Observational native control replay. Layout/RNG/physics are NOT synchronized.
## This deliberately reports differences; it is not an exact-parity certificate.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	var rows: Dictionary = {}
	for line in FileAccess.get_file_as_string(args[0]).split("\n", false):
		var event = JSON.parse_string(line)
		if not event is Dictionary or not event.has("run"): continue
		var index := int(event.run)
		if not rows.has(index): rows[index] = {"frames": []}
		if event.has("meta"): rows[index].meta = event
		elif event.has("frame"): rows[index].frames.append(event)
		elif event.has("result"): rows[index].result = event
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	data.wallet = [0.0, 0.0, 0.0]
	data.controls_seen = true
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	var reports: Array = []
	var key_map := {"LeftShift": KEY_SHIFT, "Alpha3": KEY_3, "Alpha4": KEY_4, "Alpha5": KEY_5, "Alpha6": KEY_6}
	for index in rows:
		var row: Dictionary = rows[index]
		if row.frames.is_empty(): continue
		var meta: Dictionary = row.get("meta", {"viewport": [640, 480], "level_time": 0.03333333, "origin": [2.5, 0.87, -28.474]})
		root.size = Vector2i(int(meta.viewport[0]), int(meta.viewport[1]))
		root.content_scale_size = root.size
		seed(5400 + int(index))
		var forced := int(data.max_prestige) < int(index)
		data.prestige = int(index)
		Progress.active_data_cache = data
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_physics_process(false)
		battle.set_process(false)
		var first: Dictionary = row.frames[0]
		# Native recording starts after two scene-warmup frames. Align the pose and
		# timer age explicitly; startup spawn scheduling still differs between engines.
		battle.player_position = Vector3(float(first.pos[0]) - float(meta.origin[0]), 0.9, -(float(first.pos[2]) - float(meta.origin[2])))
		battle.camera.position = battle.player_position
		battle.row_timer = float(meta.level_time)
		var first_vitals_difference: Dictionary = {}
		var max_position_delta := 0.0
		for frame in row.frames.slice(1):
			battle.horizontal_override = float(frame.axis)
			battle.pointer_override = Vector2(float(frame.mouse[0]), float(frame.mouse[1]))
			for key in frame.keys:
				if not key_map.has(key): continue
				var event := InputEventKey.new()
				event.pressed = true
				event.keycode = key_map[key]
				battle._unhandled_input(event)
			battle._physics_process(float(frame.dt))
			var expected_position := Vector3(float(frame.pos[0]) - float(meta.origin[0]), 0.9, -(float(frame.pos[2]) - float(meta.origin[2])))
			max_position_delta = maxf(max_position_delta, battle.player_position.distance_to(expected_position))
			if first_vitals_difference.is_empty() and (absf(battle.health - float(frame.hp)) > 0.001 or absf(battle.armor - float(frame.armor)) > 0.001):
				first_vitals_difference = {"frame": frame.frame, "time": frame.t, "reference_hp": frame.hp, "railway_hp": battle.health, "reference_armor": frame.armor, "railway_armor": battle.armor}
			if int(frame.frame) % 120 == 0: await process_frame
		reports.append({"prestige": index, "frames_replayed": row.frames.size() - 1, "native": row.get("result", {}), "railway": {"ended": battle.ended, "won": battle.overlay_title.text == "THE ROW IS YOURS", "hp": battle.health, "armor": battle.armor, "distance": battle.distance, "elapsed": battle.elapsed}, "first_vitals_difference": first_vitals_difference, "max_position_delta_m": max_position_delta, "forced_prestige_for_probe": forced})
		battle.queue_free()
		await process_frame
	var output := {"exact_end_to_end_certified": false, "description": "Recorded native axis/key/mouse controls replayed in our real runtime; not a synchronized-environment comparison", "confounds": ["Different section/spawn RNG algorithms and consumption", "Native fixed-update 50Hz versus Godot physics/update scheduling", "Scene warmup, collider/raycast and projectile-flight differences", "Prestige is forced only if our preceding replay did not unlock it"], "runs": reports}
	var file := FileAccess.open(args[2], FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t"))
	file.close()
	print("NATIVE CONTROL REPLAY RECORDED: ", reports.size(), " runs; not certified")
	quit()
