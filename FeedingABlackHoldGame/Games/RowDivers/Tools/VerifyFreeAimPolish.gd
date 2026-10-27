extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.get_node("Util").set_active_game_id("rowdivers")
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	Progress.free_aim_mode = false
	checks.classic_pickup_unchanged = is_equal_approx(Progress.fresh().stats.PickupRange, .6)
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	checks.new_pickup_range = is_equal_approx(data.stats.PickupRange, .84)
	var legacy = data.duplicate(true)
	legacy.erase("flight_pickup_v2")
	legacy.stats.PickupRange = 1.85 # Original .6 starter plus purchased 1.25.
	var test_path = "user://free_aim_polish_migration_test.json"
	Progress.save_data(legacy, test_path)
	var upgraded = Progress.load_data(test_path)
	checks.existing_bonuses_preserved = is_equal_approx(upgraded.stats.PickupRange, 2.09)
	Progress.save_data(upgraded, test_path)
	checks.migration_once = is_equal_approx(Progress.load_data(test_path).stats.PickupRange, 2.09)
	DirAccess.remove_absolute(test_path)
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	var debug_panel = battle.presentation.root_ui.get_node_or_null("TEMP_CHEATS_REMOVE_BEFORE_RELEASE")
	if debug_panel != null:
		debug_panel.mouse_exited.emit()
		checks.free_aim_only_reticle = root.get_node("VirtualCursor")._gameplay_pointer_hidden and not root.get_node("VirtualCursor")._cursor_sprite.visible
		checks.free_aim_speed_tooltip = "All damage still applies" in battle.presentation.debug_speed_buttons[4].tooltip_text
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	battle._spawn_enemy(Vector3(0,.65,-5),0)
	var ground = battle.enemies.back()
	var origin: Vector3 = ground.node.position
	checks.ground_wide = battle._free_aim_intersects(ground,origin+Vector3(.65,.15,2),origin+Vector3(.65,.15,-2))
	checks.ground_upper_body = battle._free_aim_intersects(ground,origin+Vector3(0,.95,2),origin+Vector3(0,.95,-2))
	checks.outside_still_misses = not battle._free_aim_intersects(ground,origin+Vector3(.85,.15,2),origin+Vector3(.85,.15,-2))
	checks.swept_fast_shot = battle._free_aim_intersects(ground,origin+Vector3(.6,.15,20),origin+Vector3(.6,.15,-20))
	ground.hp = 1000
	battle.pointer_override = battle.camera.unproject_position(origin+Vector3(.6,.15,0))
	checks.crosshair_agrees = not battle._target(10).is_empty()
	battle._shoot()
	var shot = battle.projectiles[0]
	checks.arrow_faces_flight = (-shot.node.global_basis.z).dot(shot.dir) > .999
	checks.ink_mesh = shot.node.get_node("FlightVisual").mesh.get_surface_count() == 2
	for frame in range(90): battle._update_projectiles(1.0/60)
	checks.actual_edge_shot_hits = ground.hp < 1000
	battle._spawn_enemy(Vector3(1,2,-7),7)
	var bat = battle.enemies.back()
	checks.bat_still_precise = not battle._free_aim_intersects(bat,bat.node.position+Vector3(.5,0,2),bat.node.position+Vector3(.5,0,-2))
	bat.next_shot = 0
	battle._update_enemies(.01)
	checks.bat_uses_ink_mesh = battle.projectiles.back().node.has_node("FlightVisual")
	battle._spawn_enemy(Vector3(-1,.65,-8),4,true)
	var boss = battle.enemies.back()
	boss.next_shot = 0
	battle._update_enemies(.01)
	checks.boss_uses_ink_mesh = battle.projectiles.back().node.has_node("FlightVisual")
	checks.hostile_faces_flight = (-battle.projectiles.back().node.global_basis.z).dot(battle.projectiles.back().dir) > .999
	battle.presentation.show_tutorial()
	checks.single_picture_screen = battle.presentation.tutorial_cards.visible and battle.presentation.tutorial_cards.get_child_count() == 2 and battle.resume.text == "PLAY" and not battle.presentation.overlay_detail.visible
	if "--preview" in OS.get_cmdline_user_args():
		for frame in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/free_aim_controls.png")
	battle._resume()
	checks.one_click_starts = not battle.suspended and not battle.overlay.visible and not battle.presentation.tutorial_cards.visible
	battle.presentation.pause()
	checks.pause_hides_pictures = not battle.presentation.tutorial_cards.visible and battle.presentation.overlay_detail.visible
	battle._resume()
	if "--preview" in OS.get_cmdline_user_args():
		battle.pointer_override = battle.get_viewport().get_visible_rect().size * .5
		battle.shot_timer = 0
		battle._shoot()
		for frame in range(16): battle._update_projectiles(1.0/60)
		for frame in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/free_aim_projectiles.png")
	var passed = checks.values().all(func(value): return value)
	print("FREE AIM POLISH: ",checks.size()," checks, passed=",passed," ",checks)
	battle.free()
	quit(0 if passed else 1)
