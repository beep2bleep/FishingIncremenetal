extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://StoreAssets_RailwayFury/itchio/upgrades-0.1.png"
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("SaveHandler").local_settings_file_path = "user://railway_store_capture_settings.json"
	ProjectSettings.set_setting("railway_fury/demo/enabled",true)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	data.controls_seen = true
	data.wallet = [1e9,1e9,0.0]
	for pass_index in range(80):
		if data.levels.size() >= 60: break
		for entry in Progress.design().upgrades:
			if Progress.can_buy(data,entry): Progress.buy(data,entry)
	data.wallet = [1850.0,24.0,0.0]
	data.gameplay_seconds = 3723.0
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.current_game_mode_data = null
	global.ensure_default_game_mode_data()
	global.new_game()
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for frame in range(80): await process_frame
	for name in ["row_divers_auto_buy_button","row_divers_color_button","editor_exit_demo_button","editor_demo_toggle_button"]:
		var control = screen.get(name)
		if control is Control: control.hide()
	var tree = screen.tech_tree
	var bounds = Rect2()
	var started = false
	for node in tree.node_dict.values():
		if node.upgrade == null: continue
		if node.upgrade.current_tier <= 0 and node.state != node.STATES.AVAILABLE: continue
		if not started:
			bounds = Rect2(node.position,Vector2.ZERO)
			started = true
		else: bounds = bounds.expand(node.position)
	bounds = bounds.grow(85)
	var zoom = minf(0.8,minf(1450.0 / bounds.size.x,780.0 / bounds.size.y))
	tree.set_zoom(zoom)
	tree.set_debug_center_offset(Vector2(150,-35))
	tree.set_tech_tree_pos(-bounds.get_center())
	for frame in range(20): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(OUTPUT)
	print("STORE UPGRADES: ",data.levels.size()," purchased nodes; zoom=",zoom,"; bounds=",bounds,"; output=",OUTPUT)
	screen.free()
	quit()
