extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.get_node("Util").set_active_game_id("rowdivers")
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	Progress.free_aim_mode = true
	var catalog = Progress.design()
	checks.nodes = catalog.upgrades.size()==124
	var data = Progress.fresh()
	data.wallet = [1e9,1000.0,10.0]
	for p in range(1,4):
		var parent = {1:"6660",2:"6426",3:"6688"}[p]
		var branch = Progress.find_upgrade("flight_%d_0" % p)
		checks["crown_parent_%d" % p] = branch.parents==[parent] and int(Progress.find_upgrade(parent).cost.currencyType)==2
		data.max_prestige = p
		checks["needs_crown_%d" % p] = not Progress.can_buy(data,branch)
		data.levels[parent] = 1
		checks["crown_opens_%d" % p] = Progress.can_buy(data,branch)
		data.max_prestige = p-1
		checks["needs_prestige_%d" % p] = not Progress.can_buy(data,branch)
	checks.no_intro_controls = catalog.upgrades.all(func(n):return not n.id.begins_with("flight_0_"))
	var old = Progress.fresh()
	old.erase("crown_channels_v3")
	old.max_prestige = 1
	old.wallet = [0.0,0.0,0.0]
	old.spent = [462.0,0.0,0.0]
	old.levels["flight_0_0"] = 2 # 10+12 refunded.
	old.levels["flight_1_0"] = 2 # 200+240, crown not owned.
	old.stats.Fire_Wave_Control_0 = 20
	old.stats.Fire_Wave_Control_1 = 20
	var disk_legacy = old.duplicate(true)
	Progress.apply_crown_channel_repairs(old)
	checks.legacy_refund = old.wallet[0]==462 and old.spent[0]==0 and old.stats.Fire_Wave_Control_0==0 and old.stats.Fire_Wave_Control_1==0
	Progress.apply_crown_channel_repairs(old)
	checks.refund_once = old.wallet[0]==462
	var migration_path = "user://crown_channels_migration_test.json"
	Progress.save_data(disk_legacy,migration_path)
	var migrated = Progress.load_data(migration_path)
	checks.file_migration = migrated.wallet[0]==462 and migrated.crown_channels_v3
	Progress.save_data(migrated,migration_path)
	checks.file_migration_once = Progress.load_data(migration_path).wallet[0]==462
	DirAccess.remove_absolute(migration_path)
	var waves = load("res://Games/RowDivers/RowDiversFireWaves.gd").new()
	waves.setup(0,123,catalog.settings.fire_waves)
	waves.boss_defeated(5)
	var intro = waves.parameters(0).interval
	waves.setup(1,123,catalog.settings.fire_waves)
	waves.boss_defeated(5)
	checks.intro_bootstrap = intro > waves.parameters(0).interval
	checks.crown_control_helps = waves.parameters(80).interval > waves.parameters(0).interval
	data = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_process(false)
	battle.set_physics_process(false)
	battle.suspended = false
	battle.health = 1e6
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	battle._spawn_enemy(Vector3(.5,.65,-5),0)
	var enemy = battle.enemies.back()
	enemy.hp = 60
	var drop = Node3D.new()
	battle.add_child(drop)
	drop.position = battle.player_position + Vector3(1.1,0,-1.5)
	battle.drops.append({"node":drop,"currency":0,"value":7.0})
	battle.fire_waves.timer = 100
	battle.fire_waves.waves.append({"id":0,"z":battle.player_position.z-8,"gap_x":1.1,"gap_width":1.9,"speed":6,"stage":0})
	battle.set_debug_speed(4)
	battle.running = false
	checks.assist_on_4 = battle.editor_autopilot_enabled()
	for frame in range(90): battle._physics_process(1.0/60)
	checks.pilot_aims_shoots = battle.editor_pilot.shots>0 and battle.run_kills>0
	checks.pilot_standard_speed = not battle.running
	checks.crosshair_follows_pilot = battle._aim_pointer().distance_to(battle.camera.unproject_position(battle._aim_origin()+battle.aim_override*maxf(1,battle.s("Distance_Range")))) < .01
	checks.pilot_dodges = battle.fire_waves.dodged>0 and battle.fire_waves.hits==0
	checks.pilot_collects = battle.coins[0]>=7
	checks.no_arrow_immunity = not battle.fast_combat_assist_enabled()
	for speed in [64,128]:
		battle.set_debug_speed(speed)
		var before = battle.elapsed
		battle._physics_process(1.0/60)
		checks["speed_%d" % speed] = is_equal_approx(battle.elapsed-before,float(speed)/60) and battle.presentation.debug_speed_buttons.has(speed)
	if "--preview" in OS.get_cmdline_user_args():
		for frame in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/editor_autopilot_128.png")
	battle.set_debug_speed(2)
	battle.pointer_override = Vector2(400,300)
	checks.manual_cursor_restored = battle._aim_pointer()==Vector2(400,300)
	checks.manual_restored = not battle.editor_autopilot_enabled() and is_nan(battle.horizontal_override) and not battle.aim_override.is_finite() and not battle.fire_override
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	battle.set_debug_speed(128)
	checks.shipping_gate = battle.debug_speed==1 and not battle.editor_autopilot_enabled()
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",true)
	battle.free()
	for choice in ["LastStation","BeyondTheRails"]:
		var state = Progress.fresh()
		state.unlocks.GodTab = true
		state.god_panel_unlocked = true
		Progress.active_data_cache = state
		var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
		ending.persist_results = false
		root.add_child(ending)
		current_scene = ending
		checks["two_choices_"+choice] = ending.choices.get_child_count()==2
		if "--preview" in OS.get_cmdline_user_args() and choice=="LastStation":
			for frame in range(8): await process_frame
			ending.reveal.kill()
			ending.story.visible_ratio = 1
			await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/ending_two_choices.png")
		ending._choose("BenevolentGod")
		ending._choose("EvilGod")
		checks["old_endings_removed_"+choice] = not ending.choice_made
		ending._choose(choice)
		checks["ending_"+choice] = state.ending==choice and state.endings_seen.get(choice,false) and ending.illustration.visible and ending.illustration.texture != null and ending.continue_button.visible
		if "--preview" in OS.get_cmdline_user_args():
			for frame in range(8): await process_frame
			ending.reveal.kill()
			ending.story.visible_ratio = 1
			await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/ending_"+choice+".png")
		ending.free()
	var passed = checks.values().all(func(v):return v)
	print("CROWN PLAYTHROUGH: ",checks.size()," checks passed=",passed," ",checks)
	quit(0 if passed else 1)
