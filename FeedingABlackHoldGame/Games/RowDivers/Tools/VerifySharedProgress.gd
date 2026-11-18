extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Shared = preload("res://Games/RowDivers/RowDiversSharedSave.gd")
var checks := 0
var failures := 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func write_json(path: String, data: Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
func run():
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		push_error("Shared-save fixture refuses player saves")
		quit(2)
		return
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = true
	var full = Progress.fresh()
	full.erase("shared_demo_migrated_v1")
	full.prestige = 3
	full.max_prestige = 3
	full.unlocks.GodTab = true
	full.god_panel_unlocked = true
	full.achievements.PrestigeMaster = true
	full.wallet = [120.0, 7.0, 4.0]
	var legacy = Progress.fresh()
	legacy.erase("shared_demo_migrated_v1")
	legacy.demo_completed = true
	legacy.achievements.FirstBoss = true
	legacy.claimed.FirstBoss = true
	legacy.wallet = [50.0, 10.0, 1.0]
	var node: Dictionary = Progress.design().upgrades.filter(func(entry): return entry.unlocks.is_empty() and entry.effects.size()>0 and int(entry.get("minPrestige",0))==0)[0]
	legacy.levels[node.id] = 1
	var path = "user://shared_fixture_" + str(Time.get_ticks_usec()) + ".json"
	var old_path = path + ".legacy"
	write_json(path, full)
	write_json(old_path, legacy)
	var originals = FileAccess.get_file_as_string(path)
	check(Shared.migrate(path, [old_path], Progress.design().upgrades), "Legacy demo migrates")
	var merged: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	check(merged.max_prestige==3 and merged.prestige==3, "Migration preserves later campaign")
	check(merged.unlocks.GodTab and merged.god_panel_unlocked, "Migration preserves endings")
	check(merged.achievements.FirstBoss and merged.achievements.PrestigeMaster, "Achievements union")
	check(merged.claimed.FirstBoss, "Claim retained without double reward")
	check(merged.wallet==[120.0,10.0,4.0], "Wallet maxima, never addition")
	check(merged.levels[node.id]==1, "Missing purchased rank carried over")
	check(merged.stats[node.effects[0].stat] != full.stats[node.effects[0].stat], "Missing upgrade effect applied")
	check(FileAccess.get_file_as_string(path+".pre_shared.bak")==originals, "Exact original backup")
	var first_result = FileAccess.get_file_as_string(path)
	check(not Shared.migrate(path,[old_path],Progress.design().upgrades), "Migration idempotent")
	check(first_result==FileAccess.get_file_as_string(path), "Second migration cannot duplicate rewards")
	for mode in [false,true]:
		ProjectSettings.set_setting("railway_fury/demo/enabled",mode)
		check(Progress.progress_path()=="user://row_divers_progress_flying_v1.json", "Shared filename in both modes")
		Progress.active_data_cache = merged.duplicate(true)
		Progress.active_data_cache.controls_seen = true
		Progress.cache_profile_path = Progress.progress_path()
		var before = Progress.active_data_cache.duplicate(true)
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_process(false)
		battle.set_physics_process(false)
		var demo = Progress.Demo.enabled()
		check(battle.campaign_level()==(0 if demo else 3), "Battle enforces edition level despite advanced save")
		check(battle.data.max_prestige==3 and battle.data.prestige==3, "Battle retains saved campaign")
		check(battle.fire_visual.level_index==(0 if demo else 3), "Level visuals enforce edition")
		check(not Progress.unlock_final_chamber(battle.data) if demo else true, "Demo cannot open final chamber")
		if demo:
			for entry in Progress.design().upgrades:
				if int(entry.get("minPrestige",0))>0: check(not Progress.visible(battle.data,entry), "Later upgrades unavailable in demo")
			battle._spawn_enemy(battle.player_position+Vector3(0,0,-3),6)
			var boss: Dictionary = battle.enemies.back()
			battle._hit(boss,boss.hp+1)
			check(battle.victory and battle.data.demo_completed, "Demo boss ends demo")
			check(battle.data.max_prestige==3 and battle.data.unlocks.GodTab, "Demo victory preserves full unlocks")
			check(battle.data.achievements.FirstBoss, "Demo earned achievement retained")
		battle.free()
	print("SHARED PROGRESS: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
