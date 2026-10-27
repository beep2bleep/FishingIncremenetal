extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://StoreAssets_RailwayFury/screenshots/"
func _initialize(): call_deferred("run")
func capture(filename: String):
	for frame in range(60): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(OUTPUT+filename+".png")
func run():
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	ProjectSettings.set_setting("railway_fury/demo/enabled",true)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	var save = root.get_node("SaveHandler")
	save.local_settings_file_path = "user://railway_demo_capture_settings.json"
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	var launcher = load("res://Core/Boot/GameLauncher.tscn").instantiate()
	root.add_child(launcher)
	current_scene = launcher
	await capture("01-menu")
	TranslationServer.set_locale("es")
	await capture("qa-menu-es")
	launcher.free()
	TranslationServer.set_locale("en")
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	data.controls_seen = true
	data.wallet = [250.0,5.0,0.0]
	data.unlocks.Dagger = true
	data.stats.MaxHP = 600.0
	data.stats.Armor = 120.0
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.pointer_override = root.get_visible_rect().size*.5
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	battle._spawn_enemy(Vector3(-.5,.65,-4.5),0)
	battle._spawn_enemy(Vector3(.6,.65,-7.5),3)
	battle._update_camera_presentation()
	battle._update_hud()
	battle.crosshair.position = battle._aim_pointer()-battle.crosshair.size*.5
	await capture("02-combat")
	battle.fire_visual.sync([{"id":1,"z":-5.5,"gap_x":-.7,"gap_width":1.8,"stage":1}])
	await capture("03-fire-waves")
	TranslationServer.set_locale("de")
	battle._update_hud()
	await capture("qa-combat-de")
	TranslationServer.set_locale("ja")
	battle._update_hud()
	await capture("qa-combat-ja")
	TranslationServer.set_locale("en")
	battle._finish(true)
	await capture("05-demo-complete")
	battle.free()
	var global = root.get_node("Global")
	global.current_game_mode_data = null
	global.ensure_default_game_mode_data()
	global.new_game()
	global.start_in_upgrade_scene = true
	Progress.active_data_cache = data
	Progress.buy(data,Progress.find_upgrade("5932"))
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for frame in range(60): await process_frame
	screen.tech_tree.set_zoom(0.55)
	screen.tech_tree.recenter_on_core()
	for name in ["row_divers_auto_buy_button","row_divers_color_button","editor_exit_demo_button","editor_demo_toggle_button"]:
		var control = screen.get(name)
		if control is Control: control.hide()
	await capture("04-upgrades")
	print("CAPTURE TREE: ",screen.tech_tree.node_dict.size()," nodes; building=",screen.tech_tree.build_in_progress)
	TranslationServer.set_locale("fr")
	await capture("qa-upgrades-fr")
	screen.free()
	print("DEMO SCREENSHOTS COMPLETE")
	quit()
