extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var graphics: GDScript
var art: GDScript
var source: GDScript
var audio_script: GDScript
var checks = 0
var failures = 0

func _initialize() -> void: call_deferred("run")
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func state(battle: Node3D) -> Dictionary:
	var enemies: Array = []
	for enemy in battle.enemies: enemies.append([enemy.kind, enemy.hp, enemy.node.position, enemy.next_shot])
	return {"hp": battle.health, "armor": battle.armor, "position": battle.player_position, "elapsed": battle.elapsed, "enemies": enemies, "wallet": battle.data.wallet.duplicate(), "abilities": battle.abilities.duplicate(true)}

func replay(mode: int) -> Dictionary:
	graphics.select_mode(mode)
	seed(54129)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	var before := state(battle)
	var combat_random := randf()
	seed(1729)
	var expected_draw := randf()
	seed(1729)
	for style in [0, 1, 2, mode]:
		graphics.select_mode(style)
		root.get_node("SignalBus").settings_updated.emit()
		check(state(battle) == before, "Changing style preserves the active run")
		check(battle.original_weapons.visible == (style != 0), "Weapon geometry follows style")
		check(battle.audio.music.stream.resource_path.begins_with(audio_script.ILLUSTRATED_ROOT) == (style == 2), "Music changes with style")
	check(randf() == expected_draw, "Style changes do not consume combat RNG")
	if mode == 2:
		for cue in audio_script.illustrated_catalog().effects:
			battle.audio.sound(cue)
		check(battle.audio.effects.any(func(player): return player.stream != null and player.stream.resource_path.ends_with("Illustrated/shot.wav")), "New bow shot is played")
	for frame in range(360):
		battle.horizontal_override = 0.2 if frame < 160 else -0.1
		battle._physics_process(1.0 / 60.0)
	var result := state(battle)
	result.next_draw = randf()
	result.initial_draw = combat_random
	battle.free()
	return result

func verify_dagger_flight() -> void:
	for mode in range(3):
		graphics.select_mode(mode)
		var data: Dictionary = Progress.fresh()
		data.controls_seen = true
		data.unlocks.Dagger = true
		Progress.active_data_cache = data
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.horizontal_override = 0.0
		battle.forward_speed = 0.0
		for enemy in battle.enemies: enemy.node.queue_free()
		battle.enemies.clear()
		battle._spawn_enemy(battle.player_position + Vector3(0, 0, -2.5), 0)
		var enemy: Dictionary = battle.enemies.back()
		enemy.hp = 1000000.0
		var hp: float = enemy.hp
		var pivot: Node3D = battle.original_weapons.get_child(0).get_node("Dagger Pivot")
		battle._physics_process(0.01)
		check(enemy.hp < hp and battle.dagger_recoil == 1.0, "Automatic dagger attack triggers in style %d" % mode)
		var sound_path: String = "Audio/dagger.wav" if mode == 0 else "Art/Original/Audio/Dagger.ogg"
		check(battle.audio.effects.any(func(player): return player.playing and player.stream != null and player.stream.resource_path.ends_with(sound_path)), "Dagger swipe sound plays in style %d" % mode)
		check(battle.dagger_flights.size() == 1 and not pivot.visible and not battle.dagger.visible, "Throw leaves the hand in style %d" % mode)
		var flight: Node3D = battle.dagger_flights[0]
		var origin: Vector3 = flight.origin
		var strike: Vector3 = flight.strike
		enemy.hp = 0.0 # Target may disappear without invalidating its captured flight path.
		battle._advance_daggers(flight.duration * 0.25)
		var outbound: Vector3 = flight.position
		if "--preview" in OS.get_cmdline_user_args():
			battle.pointer_override = root.get_visible_rect().size * 0.5
			battle.crosshair.position = battle._aim_pointer() - battle.crosshair.size * 0.5
			for i in range(4): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/dagger_style_%d.png" % mode)
		check(not outbound.is_equal_approx(origin) and not outbound.is_equal_approx(strike), "Dagger travels through an outbound arc")
		battle.aim_override = Vector3.RIGHT
		root.get_node("SignalBus").settings_updated.emit()
		check(flight.position == outbound and flight.strike == strike and not pivot.visible, "Aim/style refresh cannot redirect or duplicate the throw")
		battle._advance_daggers(flight.duration * 0.25)
		check(flight.position.is_equal_approx(strike), "Dagger reaches the captured enemy position")
		battle.player_position.x += 0.4
		battle._update_camera_presentation()
		battle._advance_daggers(flight.duration * 0.25)
		check(not flight.position.is_equal_approx(outbound), "Return follows a separate arc toward the moving player")
		var paused_position: Vector3 = flight.position
		battle.suspended = true
		battle._physics_process(0.2)
		check(flight.position == paused_position, "Pause freezes the dagger flight")
		battle.suspended = false
		battle._advance_daggers(flight.duration * 0.25)
		check(flight.position.is_equal_approx(battle._dagger_hand()) and battle.dagger_flights.is_empty(), "Dagger catches up with the moving hand")
		battle._update_dagger_presentation()
		check(pivot.visible and battle.dagger.visible == (mode == 0), "Held dagger is restored after return")
		# Free aim dagger acquisition is autonomous, even when the bow points away.
		battle.free_aim_mode = true
		battle._spawn_enemy(battle.player_position + Vector3(0, 0, -0.5), 0)
		check(not battle._dagger_target().is_empty(), "Dagger selects a nearby enemy independently of bow aim")
		seed(391)
		var expected_draw := randf()
		seed(391)
		battle.dagger_timer = 0.01
		battle._launch_dagger(strike)
		battle._launch_dagger(strike)
		check(randf() == expected_draw and battle.dagger_flights.size() == 2, "Rapid throws can overlap without consuming combat RNG")
		battle._advance_daggers(0.2)
		check(battle.dagger_flights.is_empty(), "A large simulation step completes all rapid throws")
		for foe in battle.enemies: foe.hp = 0.0
		battle.dagger_timer = 10.0
		battle._launch_dagger(strike)
		var boosted: Node3D = battle.dagger_flights[0]
		battle.running = true
		battle._physics_process(0.01)
		check(is_equal_approx(boosted.age, 0.02), "Shift double speed advances dagger flight twice")
		battle.running = false
		battle.debug_speed = 8
		battle._physics_process(0.01)
		check(is_equal_approx(boosted.age, 0.1 if battle.debug_speed_cheats_enabled() else 0.03), "Editor speed advances dagger flight with combat")
		battle.debug_speed = 1
		battle.free()

func verify_menu_music_continuity() -> void:
	for mode in range(3):
		graphics.select_mode(mode)
		var menu_audio = audio_script.new()
		root.add_child(menu_audio)
		menu_audio.play_music(false)
		var player: AudioStreamPlayer = menu_audio.music
		var track: AudioStream = player.stream
		player.seek(12.0)
		await create_timer(0.05).timeout
		var position := player.get_playback_position()
		check(position >= 11.9, "Continuity check starts partway through the track")
		menu_audio.free()
		check(is_instance_valid(player) and player.playing, "Menu music survives the old scene being freed")
		# Both menu scenes stop the shared default playlist before creating their audio service.
		root.get_node("MusicPlayer").stop()
		var upgrade_audio = audio_script.new()
		root.add_child(upgrade_audio)
		upgrade_audio.play_music(false)
		check(upgrade_audio.music == player and player.stream == track, "Upgrade screen retains the same player and selected track")
		check(player.get_playback_position() >= position - 0.1, "Upgrade screen does not reset playback position")
		upgrade_audio.play_music(true)
		check(upgrade_audio.music.playing and upgrade_audio.music.stream != track, "Combat switches away from the menu track")
		var battle_track: AudioStream = upgrade_audio.music.stream
		upgrade_audio.music.seek(21.0)
		await create_timer(0.05).timeout
		var battle_position: float = upgrade_audio.music.get_playback_position()
		check(battle_position >= 20.9, "Battle bookmark starts partway through its track")
		upgrade_audio.free()
		var return_audio = audio_script.new()
		root.add_child(return_audio)
		return_audio.play_music(false)
		check(return_audio.music.stream == track, "Returning from combat keeps the selected menu track")
		check(absf(return_audio.music.get_playback_position() - position) < 0.3, "Returning from combat restores the paused menu offset")
		return_audio.play_music(true)
		check(return_audio.music.stream == battle_track, "Re-entering combat keeps its selected track")
		check(absf(return_audio.music.get_playback_position() - battle_position) < 0.3, "Re-entering combat restores its offset")
		return_audio.music.seek(battle_track.get_length() - 0.04)
		await create_timer(0.35).timeout
		check(return_audio.music.playing and return_audio.music.get_playback_position() < 1.0, "Resumed music loops across the end of the track")
		return_audio.free()

func verify_upgrade_icons() -> void:
	var adapter = load("res://Games/RowDivers/RowDiversUpgradeTreeAdapter.gd")
	var modern: Dictionary = {}
	for mode in range(3):
		graphics.select_mode(mode)
		adapter.apply_simulation_upgrades()
		var icons: Dictionary = {}
		for upgrade in root.get_node("Global").game_mode_data_manager.upgrades.values():
			icons[upgrade.sim_key] = upgrade.sim_icon
		if mode == 0: modern = icons
		check(icons.size() == 112 and icons == modern, "All upgrade icons keep the modern style in presentation %d" % mode)

func run() -> void:
	graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	art = load("res://Games/RowDivers/RowDiversIllustrated.gd")
	source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	audio_script = load("res://Games/RowDivers/RowDiversAudio.gd")
	var save = root.get_node("SaveHandler")
	var saved_original: bool = save.row_divers_original_graphics
	var saved_illustrated: bool = save.row_divers_illustrated_graphics
	var saved_settings: String = save.local_settings_file_path
	save.local_settings_file_path = "user://illustrated_presentation_verification.json"
	root.get_node("Util").set_active_game_id("rowdivers")
	graphics.select_mode(2)
	check(art.catalog().files.size() == 41, "All 41 generated assets are installed")
	for file in art.catalog().files:
		check(load(art.ROOT + file.file) != null, "Generated image loads: " + file.name)
	for material in source.catalog().materials.values():
		if material.texture.is_empty(): continue
		check(not art.texture_path(material.texture).is_empty(), "Every combat source texture has a replacement: " + material.texture)
	var first_material: String = source.catalog().materials.keys()[0]
	var illustrated_material: Material = source.material(first_material)
	graphics.select_mode(1)
	check(source.material(first_material) != illustrated_material, "Original material cache remains independent")
	for collection in ["music", "effects"]:
		for entry in audio_script.illustrated_catalog()[collection].values():
			check(load(audio_script.ILLUSTRATED_ROOT + entry.file) != null, "New audio loads: " + entry.file)
	var modern := replay(0)
	var original := replay(1)
	var illustrated := replay(2)
	check(modern == original and original == illustrated, "Identical normalized inputs produce identical state in all three styles")
	await verify_dagger_flight()
	await verify_menu_music_continuity()
	verify_upgrade_icons()
	var settings = load("res://Settings.tscn").instantiate()
	root.add_child(settings)
	check(settings.row_divers_graphics_toggle.item_count == 3, "All three styles are selectable")
	for mode in range(3):
		settings.row_divers_graphics_toggle.select(mode)
		settings.row_divers_graphics_toggle.item_selected.emit(mode)
		check(graphics.mode() == mode, "Settings selects requested style")
		var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save.local_settings_file_path))
		check(bool(stored.row_divers_original_graphics) == (mode != 0) and bool(stored.row_divers_illustrated_graphics) == (mode == 2), "Style selection persists without deleting old choices")
	settings.free()
	DirAccess.remove_absolute(save.local_settings_file_path)
	save.local_settings_file_path = saved_settings
	save.row_divers_original_graphics = saved_original
	save.row_divers_illustrated_graphics = saved_illustrated
	print("ILLUSTRATED PRESENTATION: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
