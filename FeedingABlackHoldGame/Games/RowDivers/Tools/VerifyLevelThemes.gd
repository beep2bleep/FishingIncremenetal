extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Themes = preload("res://Games/RowDivers/RowDiversLevelThemes.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = true
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	var catalog = Progress.design()
	for p in range(1,4):
		var crown = Progress.find_upgrade({1:"6660",2:"6426",3:"6688"}[p])
		var previous = Vector2(crown.position[0],crown.position[1])
		for rank in range(4):
			var node = Progress.find_upgrade("flight_%d_%d" % [p,rank])
			var point = Vector2(node.position[0],node.position[1])
			checks["branch_close_%d_%d" % [p,rank]] = point.distance_to(Vector2(crown.position[0],crown.position[1]))<17 and point.distance_to(previous)<11
			checks["branch_rules_%d_%d" % [p,rank]] = node.parents==[crown.id] and node.maxLevel==2 and node.effects[0].amount==10 and node.minPrestige==p
			checks["branch_no_overlap_%d_%d" % [p,rank]] = catalog.upgrades.all(func(other): return other.id==node.id or absf(other.position[0]-point.x)>=5.15 or absf(other.position[1]-point.y)>=5.15)
			previous = point
	var battle_script = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	battle_script.debug_speed = 1
	for level in range(4):
		graphics.select_mode(2)
		var data = Progress.fresh()
		data.controls_seen = true
		data.prestige = level
		data.max_prestige = level
		Progress.active_data_cache = data
		var battle = battle_script.new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.pointer_override = root.get_visible_rect().size*.5
		for enemy in battle.enemies: enemy.node.free()
		battle.enemies.clear()
		battle._spawn_enemy(Vector3(-.6,.65,-4.2),0)
		battle._spawn_enemy(Vector3(.7,.65,-7),3)
		battle._spawn_enemy(Vector3(.2,1.9,-10),7)
		battle._update_hud()
		battle._update_camera_presentation()
		battle.crosshair.position = battle._aim_pointer()-battle.crosshair.size*.5
		checks["level_label_%d" % level] = battle.ability_hud.text.contains("LEVEL %d" % (level+1)) and not battle.ability_hud.text.contains("PRESTIGE")
		var snapshot = [battle.health,battle.player_position,battle.elapsed,battle.enemies[0].hp,data.wallet.duplicate()]
		seed(5412)
		var expected = randf()
		seed(5412)
		battle._refresh_graphics()
		checks["theme_no_rng_%d" % level] = randf()==expected
		checks["theme_no_combat_change_%d" % level] = snapshot==[battle.health,battle.player_position,battle.elapsed,battle.enemies[0].hp,data.wallet]
		var actor = battle.enemies[0].actor
		var meshes = actor.rig.find_children("*","MeshInstance3D",true,false)
		checks["enemy_tint_%d" % level] = meshes.any(func(mesh): return mesh.material_override is ShaderMaterial and mesh.material_override.get_shader_parameter("tint_color").is_equal_approx(Themes.ENEMY_TINTS[level]))
		checks["bat_tint_%d" % level] = battle.enemies[2].actor.bat_material.get_shader_parameter("level_tint").is_equal_approx(Themes.ENEMY_TINTS[level])
		if level==2:
			checks.forest_is_open = not battle.sections[0].get_node("OriginalHallway").visible and battle.sections[0].get_node("LevelScenery").get_child_count()>=13
		if "--preview" in OS.get_cmdline_user_args():
			for i in range(8): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/level_%d.png" % (level+1))
		for tier in range(3):
			var color = Themes.fire_tint(level,tier)
			checks["fire_tier_%d_%d" % [level,tier]] = tier==0 or color!=Themes.fire_tint(level,tier-1)
			battle.fire_visual.sync([{"id":tier,"z":-11.0,"gap_x":0.0,"gap_width":1.8,"stage":tier}])
			var flame = battle.fire_visual.visuals[tier].get_child(0)
			checks["fire_shader_%d_%d" % [level,tier]] = flame.material_override.get_shader_parameter("level_tint").is_equal_approx(color)
		if level==3 and "--preview" in OS.get_cmdline_user_args():
			for i in range(8): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/level_4_fire.png")
		for style in [0,1,2]:
			graphics.select_mode(style)
			root.get_node("SignalBus").settings_updated.emit()
			checks["style_%d_%d" % [level,style]] = battle.enemies[0].actor.level_index==level and snapshot==[battle.health,battle.player_position,battle.elapsed,battle.enemies[0].hp,data.wallet]
		battle.free()
	if "--preview" in OS.get_cmdline_user_args(): await preview_tree()
	checks.four_distinct_names = Themes.NAMES.size()==4
	var passed = checks.values().all(func(v):return v)
	print("LEVEL THEMES: ",checks.size()," checks passed=",passed," ",checks)
	quit(0 if passed else 1)

func preview_tree():
	var data = Progress.fresh()
	data.max_prestige = 3
	data.prestige = 3
	for node in Progress.design().upgrades: data.levels[node.id] = int(node.maxLevel)
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for i in range(30): await process_frame
	checks.level_picker = screen.row_divers_prestige.get_item_text(0)=="Level 1" and screen.row_divers_prestige.get_item_text(3)=="Level 4"
	screen.tech_tree.set_zoom(.7)
	screen.tech_tree.set_tech_tree_pos(Vector2(27,-16)*20)
	for i in range(30): await process_frame
	checks.tree_all_nodes = screen.tech_tree.node_dict.size()==125
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/fire_control_clusters.png")
	screen.free()
