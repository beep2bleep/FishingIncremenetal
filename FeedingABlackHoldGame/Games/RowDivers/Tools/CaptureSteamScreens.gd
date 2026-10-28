extends SceneTree
## Render actual game scenes without touching campaign saves or submitting scores.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://StoreAssets_RailwayFury/steam/screenshots/"
func _initialize(): call_deferred("run")
func capture(path):
	for frame in range(12): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(OUTPUT+path+".png")
func run():
	root.size = Vector2i(1920,1080)
	root.content_scale_size = root.size
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("SaveHandler").local_settings_file_path = "user://railway_steam_capture_settings.json"
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	Progress.free_aim_mode = true
	for demo in [false,true]:
		ProjectSettings.set_setting("railway_fury/demo/enabled",demo)
		var folder = "demo/" if demo else "full/"
		DirAccess.make_dir_recursive_absolute(OUTPUT+folder)
		for shot in range(6):
			seed(282026+shot)
			var data = Progress.fresh()
			data.controls_seen = true
			data.prestige = 0 if demo else mini(shot,3)
			data.max_prestige = data.prestige
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
			var kind = shot%4
			battle._spawn_enemy(Vector3(-.65,.65,-5.0-shot*.2),kind)
			battle._spawn_enemy(Vector3(.95,.65,-9.0),3 if shot%2==0 else 2)
			battle._spawn_enemy(Vector3(.2,1.75,-13.5),7)
			if shot==4:
				battle._spawn_enemy(Vector3(0,.65,-11.0),4,true)
			if shot%2==1:
				battle.fire_visual.sync([{"id":1,"z":-7.0,"gap_x":-.6,"gap_width":1.9,"stage":0}])
			battle._update_camera_presentation()
			battle._update_hud()
			battle.crosshair.position = battle._aim_pointer()-battle.crosshair.size*.5
			await capture(folder+"%02d-gameplay"%(shot+1))
			battle.free()
	print("STEAM SCREENSHOTS: 12 actual rendered gameplay scenes")
	quit()
