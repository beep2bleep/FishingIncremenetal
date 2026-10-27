extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var Battle
var failures = 0
var checks = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	root.size = Vector2i(1280, 720)
	root.get_node("Util").set_active_game_id("rowdivers")
	var save = root.get_node("SaveHandler")
	var saved_settings: String = save.local_settings_file_path
	save.local_settings_file_path = "user://free_aim_test_settings.json"
	for style in [0, 1, 2]:
		load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(style)
		for free_aim in [false, true]:
			Progress.free_aim_mode = free_aim
			Progress.active_data_cache = Progress.fresh()
			Progress.active_data_cache.controls_seen = true
			var battle = Battle.new()
			battle.persist_results = false
			root.add_child(battle)
			battle.set_physics_process(false)
			battle.set_process(false)
			check(battle.free_aim_mode == free_aim, "Mode choice reaches battle")
			check(is_equal_approx(battle.corridor_width, 1.4 if free_aim else 1.0), "Hallway width follows selected mode")
			check(battle.enemies.any(func(e): return e.kind == 7) == free_aim, "Bats spawn only in Free Aim")
			for enemy in battle.enemies: enemy.node.free()
			battle.enemies.clear()
			battle._spawn_enemy(battle.player_position + Vector3(1.1, 1.2, -5), 7 if free_aim else 0)
			var target: Dictionary = battle.enemies.back()
			target.hp = 1000.0
			var rest_bow_basis: Basis = battle.source_bow.basis if style != 0 else battle.bow.basis
			battle.pointer_override = battle.camera.unproject_position(target.node.position)
			if free_aim:
				check(not battle._target(10).is_empty(), "Cursor selects elevated target")
				battle._shoot()
				check(battle.projectiles[0].node.position.distance_to(battle._bow_muzzle()) < 0.001, "Arrow starts at the visible bow muzzle")
				check(not (battle.source_bow.basis if style != 0 else battle.bow.basis).is_equal_approx(rest_bow_basis), "Bow tilts toward off-center cursor")
				var aim_point: Vector3 = battle._aim_point()
				var arrow = battle.projectiles[0]
				var projected: Vector3 = arrow.node.position + arrow.dir * (aim_point - arrow.node.position).length()
				check(projected.distance_to(aim_point) < 0.001, "Muzzle trajectory converges on cursor aim point")
				check(target.actor.bat_material != null, "Bat uses painted sprite material")
				check(battle.projectiles[0].dir.y > 0 and battle.projectiles[0].dir.x > 0, "Cursor arrow travels upward and sideways")
				for i in range(90): battle._update_projectiles(1.0 / 60.0)
				check(target.hp < 1000.0, "Arrow hits elevated target in 3D")
				target.next_shot = 0
				battle._update_enemies(0.01)
				var bullet: Dictionary = battle.projectiles.back()
				check(bullet.hostile and bullet.dir.y < 0, "Bat shoots down toward player")
				var hit_point: Vector3 = bullet.node.position + bullet.dir * bullet.node.position.distance_to(battle.player_position)
				check(hit_point.distance_to(battle.player_position) < 0.001, "Bat projectile aims at player position")
			else:
				battle._shoot()
				check(battle.projectiles[0].dir == Vector3.FORWARD, "Classic arrows still shoot straight")
			if free_aim:
				battle._hit(target, target.hp + 1)
				check(absf(battle.drops.back().node.position.y - battle.player_position.y) < battle.s("PickupRange"), "Airborne kills leave collectible loot near the ground")
			for projectile in battle.projectiles: projectile.node.free()
			battle.projectiles.clear()
			if not free_aim: target.node.free()
			battle.enemies.clear()
			battle._spawn_enemy(battle.player_position + Vector3(1.0, -0.25, -2.1), 0)
			var ground: Dictionary = battle.enemies.back()
			battle._update_enemies(0.01)
			check(not ground.chasing, "No chase beyond base range threshold")
			ground.node.position.z += 0.2
			var before: Vector3 = ground.node.position
			battle._update_enemies(0.1)
			check(ground.chasing == free_aim, "Pursuit starts in nearest 20 percent only in Free Aim")
			if free_aim:
				check(ground.node.position.x < before.x and ground.node.position.z > before.z, "Pursuit closes sideways and forward gap")
				battle.health = 1000
				for i in range(100): battle._update_enemies(0.01)
				check(ground.contact and battle.health < 1000, "Ground pursuit causes contact damage")
			save.money_text = true
			battle._floating_text(battle.player_position, "+1 GOLD", Color.GOLD, true)
			var popup = battle.presentation.root_ui.get_child(-1)
			check(popup is Label and popup.position.y < battle.get_viewport().get_visible_rect().size.y * 0.7, "Gold popup stays above weapons")
			battle.free()
	var launcher = load("res://Core/Boot/GameLauncher.tscn").instantiate()
	root.add_child(launcher)
	current_scene = launcher
	for frame in range(5): await process_frame
	check(launcher.row_divers_button.visible and launcher.row_divers_free_aim_button.visible, "Both choices appear on menu")
	check(launcher.game_cards_grid.columns == 2, "Modes appear side by side")
	check(launcher.row_divers_free_aim_button.get_meta("card_title_label").text == "FREE AIM", "New mode is labeled")
	if "--preview" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../free_aim_menu.png")
	launcher.free()
	Progress.free_aim_mode = true
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var preview = Battle.new()
	preview.persist_results = false
	root.add_child(preview)
	current_scene = preview
	preview.set_physics_process(false)
	preview._spawn_enemy(Vector3(0, 2, -4), 7)
	preview.pointer_override = preview.camera.unproject_position(Vector3(1.4, 2.4, -5))
	preview._update_bow_aim()
	preview._floating_text(preview.player_position, "+1 GOLD", Color.GOLD, true)
	if "--preview" in OS.get_cmdline_user_args():
		for frame in range(3): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../free_aim_battle.png")
	preview.free()
	Progress.active_data_cache = {}
	Progress.free_aim_mode = false
	if FileAccess.file_exists(save.local_settings_file_path): DirAccess.remove_absolute(save.local_settings_file_path)
	save.local_settings_file_path = saved_settings
	print("FREE AIM: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
