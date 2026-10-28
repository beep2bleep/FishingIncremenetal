extends SceneTree
## Record with --write-movie <ignored-build-folder>/gameplay.avi --fixed-fps 30.
## Uses real simulation inputs and upgrade snapshots; never saves campaign results.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Pilot = preload("res://Games/RowDivers/Simulation/FlightPilot.gd")
func _initialize(): call_deferred("run")
func run():
	var demo = "--demo" in OS.get_cmdline_user_args()
	root.size = Vector2i(1920,1080)
	root.content_scale_size = root.size
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("SaveHandler").local_settings_file_path = "user://railway_trailer_capture_settings.json"
	ProjectSettings.set_setting("railway_fury/demo/enabled",demo)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	Progress.free_aim_mode = true
	var snapshots = JSON.parse_string(FileAccess.get_file_as_string("res://StoreAssets_RailwayFury/steam/capture-loadouts.json"))
	for level in range(1 if demo else 4):
		var snapshot: Dictionary = snapshots[level]
		var data = Progress.fresh()
		data.controls_seen = true
		data.prestige = level
		data.max_prestige = level
		data.wallet = [1e20,1e20,1e20]
		data.unlocks.GodTab = level>0
		for pass_index in range(200):
			var changed = false
			for entry in Progress.design().upgrades:
				if Progress.level(data,entry)<int(snapshot.upgrade_levels.get(entry.id,0)) and Progress.can_buy(data,entry):
					Progress.buy(data,entry)
					changed = true
			if not changed: break
		data.wallet = snapshot.wallet_before.duplicate()
		Progress.active_data_cache = data
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		var pilot = Pilot.new()
		pilot.setup(2401026+level,{})
		for frame in range(1080 if demo else 270):
			pilot.step(battle,1.0/30.0)
			battle._physics_process(1.0/30.0)
			await process_frame
		battle.free()
	print("STEAM TRAILER: 36 seconds of actual game simulation; demo=",demo)
	quit()
