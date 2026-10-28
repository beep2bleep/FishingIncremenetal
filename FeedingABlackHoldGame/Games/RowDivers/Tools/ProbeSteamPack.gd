extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var failures = 0
var checks = 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	var demo = Progress.Demo.enabled()
	root.get_node("Util").set_active_game_id("rowdivers")
	var steam = root.get_node("SteamHandler")
	check(OS.has_feature("railway_steam"), "Steam feature is packed")
	check(Engine.has_singleton("Steam"), "Native Steam SDK loads from packaged DLLs")
	var app_icon = ProjectSettings.get_setting_with_override("application/config/icon")
	check(load(app_icon) is Texture2D and str(app_icon).ends_with("railway-icon.png"), "Railway Fury application icon is packed")
	check(steam._resolve_steam_app_id() == (5520330 if demo else 5520300), "Correct edition Steam app ID")
	check(steam.get_demo_wishlist_url() == "https://store.steampowered.com/app/5520300/Railway_Fury/", "Wishlist points to full Railway Fury")
	check(OS.get_user_data_dir().ends_with("RailwayFuryDemo" if demo else "RailwayFury"), "Edition save isolation")
	var packed_art = load("res://Games/RowDivers/Art/Powerups/ghost.svg") is Texture2D
	if not demo:
		for folder in ["Levels","Endings"]:
			var path = "res://Games/RowDivers/Art/"+folder+"/"
			var found = 0
			for filename in DirAccess.get_files_at(path):
				var asset = filename.trim_suffix(".remap").trim_suffix(".import")
				if asset.ends_with(".png"):
					found += 1
					packed_art = packed_art and load(path+asset) is Texture2D
			packed_art = packed_art and found>0
	check(packed_art, "Packed power icon, full-game level textures, and ending illustrations load")
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	data.controls_seen = true
	data.unlocks.Dagger = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	check(not battle.debug_speed_cheats_enabled(), "Release build hides editor cheats")
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	battle._spawn_enemy(battle.player_position+Vector3(0,0,-2),0)
	battle._dagger_hit(battle.enemies.back())
	battle._advance_daggers(0.1)
	check(battle.dagger_flights.size()==1, "Packed dagger art loads")
	battle._spawn_enemy(battle.player_position+Vector3(0,0,-3),6)
	var boss: Dictionary = battle.enemies.back()
	battle._hit(boss,boss.hp+1)
	check((data.max_prestige==0 and data.get("demo_completed",false)) if demo else data.max_prestige==1, "First boss edition progression gate")
	battle.free()
	check(load("res://Games/RowDivers/RowDiversTiming.gd").configs().size()==(1 if demo else 5), "Edition leaderboard count")
	print("STEAM PACK: ",checks," checks; ",failures," failures; demo=",demo)
	quit(1 if failures else 0)
