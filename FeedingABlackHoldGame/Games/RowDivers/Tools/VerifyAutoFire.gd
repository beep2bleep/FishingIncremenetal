extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		quit(2)
		return
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	root.get_node("ControllerIcons")._set_last_input_type(0,-1)
	root.get_node("SaveHandler").local_settings_file_path = "user://autofire_qa_settings.json"
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	TranslationServer.set_locale("en")
	for profile in ["previous","rebalanced","flying"]:
		Progress.free_aim_mode = profile=="flying"
		Progress.active_tree = "previous" if profile=="previous" else "rebalanced"
		Progress.tree_selected = true
		Progress.catalog = {}
		var catalog = Progress.design()
		check(catalog.upgrades.all(func(u):return u.id not in ["5853","6469"]),profile+" removes both upgrades")
		check(catalog.upgrades.all(func(u):return not u.parents.has("5853") and not u.parents.has("6469") and not u.children.has("5853") and not u.children.has("6469")),profile+" has no retired graph references")
		var data = Progress.fresh()
		check(data.unlocks.get("Auto",false),profile+" starts with auto-fire")
		data.levels["5853"] = 1
		data.levels["6469"] = 1
		data.wallet = [125.0,2.0,1.0]
		data.spent = [45.0,8.0,0.0]
		data.unlocks.Hold = true
		Progress.apply_auto_fire_migration(data)
		check(data.wallet==[125.0,10.0,1.0] and data.spent==[45.0,0.0,0.0],profile+" refunds exact gem costs only")
		Progress.apply_auto_fire_migration(data)
		check(data.wallet[1]==10.0 and not data.levels.has("5853") and not data.levels.has("6469"),profile+" migration is idempotent")
		check(not data.unlocks.has("Hold") and data.unlocks.Auto,profile+" replaces manual mode")
		var save_path = "user://autofire_"+profile+".json"
		Progress.save_data(data,save_path)
		var restored = Progress.load_data(save_path)
		check(restored.wallet[1]==10.0 and restored.unlocks.Auto,profile+" refund survives saved profile reload")
		check(not restored.levels.has("5853") and not restored.levels.has("6469"),profile+" reload cannot refund retired purchases again")
		data.controls_seen = true
		Progress.active_data_cache = data
		Progress.cache_profile_path = Progress.progress_path()
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		for enemy in battle.enemies: enemy.node.free()
		battle.enemies.clear()
		battle._spawn_enemy(battle.player_position+Vector3(0,0,-4),0)
		var enemy = battle.enemies.back()
		enemy.hp = 100000.0
		battle.pointer_override = battle.camera.unproject_position(enemy.node.position)
		check(not battle._target(battle.s("Distance_Range")).is_empty(),profile+" test target is aimed and in range")
		battle._simulate_step(0.016)
		check(battle.projectiles.size()>0 and battle.shot_timer>0,profile+" fires without click or trigger")
		var shots = battle.projectiles.size()
		battle._simulate_step(0.016)
		check(battle.projectiles.size()==shots,profile+" respects fire-rate cooldown")
		battle.data.unlocks.Dragon = true
		battle.data.unlocks.Ghost = true
		battle._simulate_step(0.016)
		check(battle.projectiles.size()>shots,profile+" auxiliary weapons also fire without input")
		shots = battle.projectiles.size()
		for key in [KEY_1,KEY_2]:
			var event = InputEventKey.new()
			event.keycode = key
			event.pressed = true
			battle._unhandled_input(event)
		battle._controller_action("fire_mode")
		check(battle.fire_mode=="Auto" and battle.auxiliary_fire_mode=="Auto",profile+" cannot switch back to manual fire")
		battle.suspended = true
		battle._simulate_step(0.5)
		check(battle.projectiles.size()==shots,profile+" pause prevents firing")
		battle.suspended = false
		battle.shot_timer = 0
		battle.ended = true
		battle._simulate_step(0.5)
		check(battle.projectiles.size()==shots,profile+" results prevent firing")
		battle.presentation.show_tutorial()
		check(battle.presentation.tutorial_captions[1].text=="AIM WITH THE MOUSE — AUTO FIRE",profile+" tutorial teaches aim instead of click")
		root.get_node("ControllerIcons")._set_last_input_type(1,0)
		check(battle.presentation.tutorial_captions[1].text=="RIGHT STICK TO AIM — AUTO FIRE",profile+" controller tutorial teaches aim instead of trigger")
		root.get_node("ControllerIcons")._set_last_input_type(0,-1)
		if profile=="flying" and "--capture" in OS.get_cmdline_user_args():
			for picker in root.find_children("EditorArtStyle","OptionButton",true,false): picker.get_parent().hide()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("C:/Godot Projects/RailwayFury/FeedingABlackHoldGame/Games/RowDivers/Docs/Previews/release-0.12-auto-fire-tutorial.png")
		battle.free()
	print("AUTO FIRE: %d checks; %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
