extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://Games/RowDivers/Docs/Previews/"

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	for frame in range(12): await process_frame
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT + name + ".png")

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	var save = root.get_node("SaveHandler")
	var saved_path: String = save.local_settings_file_path
	save.local_settings_file_path = "user://railway_branding_preview_settings.json"
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	var launcher = load("res://Core/Boot/GameLauncher.tscn").instantiate()
	root.add_child(launcher)
	current_scene = launcher
	await capture("railway-menu-illustrated")
	launcher.free()
	var global_state = root.get_node("Global")
	global_state.current_game_mode_data = null
	global_state.ensure_default_game_mode_data()
	global_state.new_game()
	global_state.start_in_upgrade_scene = true
	var data: Dictionary = Progress.fresh()
	data.unlocks.AchievementsTab = true
	data.unlocks.GodTab = true
	data.achievements.BeatTheGame = true
	data.wallet = [200000.0, 10.0, 4.0]
	Progress.active_data_cache = data
	var upgrades = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(upgrades)
	current_scene = upgrades
	upgrades.setup()
	upgrades.show_screen()
	await capture("railway-upgrades-green")
	var settings = load("res://Settings.tscn").instantiate()
	var settings_layer := CanvasLayer.new()
	settings_layer.layer = 100
	root.add_child(settings_layer)
	var panel := PanelContainer.new()
	settings_layer.add_child(panel)
	panel.position = Vector2(400, 80)
	panel.size = Vector2(1120, 920)
	panel.add_child(settings)
	settings.show_screen()
	settings._set_credits_visible(true)
	await capture("railway-credits")
	settings_layer.free()
	upgrades.free()
	data.god_panel_unlocked = true
	var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	current_scene = ending
	for choice in ["LastStation", "BeyondTheRails"]:
		ending.choice_made = false
		ending._choose(choice)
		ending.reveal.kill()
		ending.story.visible_ratio = 1
		await capture("railway-ending-" + choice.to_lower())
	ending.free()
	if FileAccess.file_exists(save.local_settings_file_path):
		DirAccess.remove_absolute(save.local_settings_file_path)
	save.local_settings_file_path = saved_path
	print("RAILWAY FURY BRANDING PREVIEWS COMPLETE")
	quit()
