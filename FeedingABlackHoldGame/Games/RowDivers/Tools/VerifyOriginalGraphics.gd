extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var Graphics: GDScript
var save_handler: Node
var signal_bus: Node
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func state(battle: Node3D) -> Dictionary:
	var foes: Array = []
	for enemy in battle.enemies:
		foes.append([enemy.kind, enemy.hp, enemy.node.position, enemy.next_shot, enemy.contact])
	return {"hp": battle.health, "armor": battle.armor, "position": battle.player_position, "wallet": battle.data.wallet.duplicate(), "enemies": foes, "elapsed": battle.elapsed, "abilities": battle.abilities.duplicate(true)}

func simulate(original: bool) -> Dictionary:
	save_handler.row_divers_original_graphics = original
	seed(41250)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	var before := state(battle)
	var random_before = randf()
	seed(101)
	var expected_random := randf()
	seed(101)
	save_handler.row_divers_original_graphics = not original
	signal_bus.settings_updated.emit()
	check(state(battle) == before, "Live switch must preserve all combat state")
	check(randf() == expected_random, "Switching graphics must not consume gameplay randomness")
	save_handler.row_divers_original_graphics = original
	signal_bus.settings_updated.emit()
	for enemy in battle.enemies:
		check((enemy.actor.source_sprite != null) == original, "Actor matches selected graphics")
	for corridor in battle.sections:
		check(corridor.get_node("OriginalHallway").visible == original, "Corridor geometry follows the selected mode")
		check(corridor.get_node("ModernHallway").visible != original, "Replacement corridor is hidden in original mode")
	check(battle.original_weapons.visible == original, "Original weapon geometry follows the selected mode")
	check(is_equal_approx(battle.camera.position.y, 1.71 if original else 0.9), "Original camera eye height comes from the source hierarchy")
	if original:
		check(battle.audio.music.stream.resource_path.begins_with(Graphics.ROOT + "Audio/"), "Original music is selected")
		battle.audio.sound("shot")
		var shot_found := false
		for player in battle.audio.effects:
			if player.stream != null and player.stream.resource_path.ends_with("Shot.ogg"):
				shot_found = true
				check(is_equal_approx(player.volume_linear, 0.45 * 0.45) and player.pitch_scale == 1.0, "Original shot volume and fixed pitch")
		check(shot_found, "Original shot clip is used")
	battle.horizontal_axis = 0
	check(is_equal_approx(battle._advance_horizontal_axis(1, 0.1), 0.3), "Movement uses original input sensitivity")
	check(is_equal_approx(battle._advance_horizontal_axis(-1, 0.1), -0.3), "Reversing movement uses original snap")
	for frame in range(300):
		battle.horizontal_override = 0.2 if frame < 120 else -0.1
		battle._physics_process(1.0 / 60.0)
	var result := state(battle)
	result["next_random"] = randf()
	result["initial_random"] = random_before
	battle.free()
	return result

func run() -> void:
	Graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	save_handler = root.get_node("SaveHandler")
	signal_bus = root.get_node("SignalBus")
	root.get_node("Util").set_active_game_id("rowdivers")
	var saved_mode: bool = save_handler.row_divers_original_graphics
	var saved_illustrated: bool = save_handler.row_divers_illustrated_graphics
	save_handler.row_divers_illustrated_graphics = false
	var saved_settings_path: String = save_handler.local_settings_file_path
	save_handler.local_settings_file_path = "user://original_graphics_verification.json"
	for asset in Graphics.catalog().files:
		check(Graphics.texture(asset.file) != null, "Texture loads: " + str(asset.file))
	check(Graphics.catalog().upgrades.size() == 112, "All 112 original upgrade icons resolve")
	var presentation = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	for layout in presentation.catalog().layouts:
		var scenery: Node3D = presentation.build(layout)
		check(scenery.find_children("*", "MeshInstance3D", true, false).size() > 0, "Original geometry loads: " + layout)
		if layout.begins_with("Section ") or layout == "Initial":
			check(scenery.find_child("Column", true, false) != null, "Original columns exist: " + layout)
		scenery.free()
	# Repeat dives select the crownless room after that prestige's crown is earned.
	# Scenery is built even in modern mode, so exercise all three style settings.
	check(presentation.catalog().layouts.has("Crownless Boss Section"), "Crownless boss room is imported")
	for mode in range(3):
		save_handler.row_divers_original_graphics = mode != 0
		save_handler.row_divers_illustrated_graphics = mode == 2
		for prestige in range(4):
			var repeat_data: Dictionary = Progress.fresh()
			repeat_data.prestige = prestige
			repeat_data.controls_seen = true
			repeat_data.crowns_dropped[str(prestige)] = true
			Progress.active_data_cache = repeat_data
			var repeat_battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
			repeat_battle.persist_results = false
			root.add_child(repeat_battle)
			repeat_battle.set_physics_process(false)
			repeat_battle._build_section(15)
			var hallway: Node3D = repeat_battle.sections.back().get_node("OriginalHallway")
			check(hallway.find_child("Crownless Boss Section", true, false) != null, "Repeat prestige %d in style %d builds crownless room" % [prestige, mode])
			check(hallway.find_children("*", "MeshInstance3D", true, false).size() > 0, "Repeat boss room contains scenery")
			check(repeat_battle.enemies.any(func(enemy): return enemy.kind == 6 and enemy.crown_dropped_on_spawn), "Repeat boss retains crown reward state")
			repeat_battle.free()
	save_handler.row_divers_illustrated_graphics = false
	for cue in presentation.catalog().audio:
		check(load(Graphics.ROOT + "Audio/" + str(presentation.catalog().audio[cue].file)) != null, "Original audio loads: " + cue)
	var gate: Node3D = presentation.build("MiniBoss1 Section")
	var entrance := gate.find_child("Room Entrance", true, false) as Node3D
	presentation.animate(entrance, "BossEntranceOpen", 0.8333333)
	check(is_equal_approx(entrance.get_node("Content").position.y, -0.4821723), "Original gate animation reaches the source endpoint")
	gate.free()
	var modern := simulate(false)
	var original := simulate(true)
	check(modern == original, "Identical inputs produce identical gameplay state with either art style")
	load("res://Games/RowDivers/RowDiversUpgradeTreeAdapter.gd").apply_simulation_upgrades()
	var manager = root.get_node("Global").game_mode_data_manager
	for upgrade in manager.upgrades.values():
		check(not upgrade.sim_icon.begins_with(Graphics.ROOT), "Modern upgrade icon retained in original mode: " + upgrade.sim_key)
	var settings = load("res://Settings.tscn").instantiate()
	root.add_child(settings)
	check(settings.find_child("OriginalRowDiversGraphics",true,false) == null, "Art style picker is removed")
	Graphics.select_mode(0)
	save_handler.save_local_settings()
	root.get_node("SignalBus").settings_updated.emit()
	var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_handler.local_settings_file_path))
	check(stored.row_divers_original_graphics == save_handler.row_divers_original_graphics, "Toggle persists local preference")
	for upgrade in manager.upgrades.values():
		check(not upgrade.sim_icon.begins_with(Graphics.ROOT), "Live settings switch restores modern upgrade icon")
	settings.free()
	save_handler.row_divers_original_graphics = true
	var ending_data: Dictionary = Progress.fresh()
	ending_data.unlocks.GodTab = true
	ending_data.god_panel_unlocked = true
	Progress.active_data_cache = ending_data
	var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	check(ending.choices.get_child_count() == 2, "Two illustrated final choices in Original mode")
	ending._choose("LastStation")
	check(ending.illustration.visible and ending.illustration.texture.resource_path.ends_with("last_station.png"), "Last Station ending artwork in Original mode")
	ending._choose("BeyondTheRails")
	check(ending_data.ending == "LastStation", "Ending choice cannot change after selection")
	ending.free()
	DirAccess.remove_absolute(save_handler.local_settings_file_path)
	save_handler.local_settings_file_path = saved_settings_path
	save_handler.row_divers_original_graphics = saved_mode
	save_handler.row_divers_illustrated_graphics = saved_illustrated
	print("ORIGINAL GRAPHICS: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
