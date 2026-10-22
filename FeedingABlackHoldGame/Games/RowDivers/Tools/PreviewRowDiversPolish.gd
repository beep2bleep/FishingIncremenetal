extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const DIRECTORY = "res://Games/RowDivers/Docs/Previews"

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	for frame in range(12): await process_frame
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(DIRECTORY + "/" + name + ".png")

func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	root.content_scale_size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	DirAccess.make_dir_recursive_absolute(DIRECTORY)
	var launcher: Node = load("res://Core/Boot/GameLauncher.tscn").instantiate()
	root.add_child(launcher)
	current_scene = launcher
	await capture("startup-polished")
	launcher.queue_free()
	await process_frame
	var global_state = root.get_node("Global")
	global_state.current_game_mode_data = null
	global_state.ensure_default_game_mode_data()
	global_state.new_game()
	global_state.start_in_upgrade_scene = true
	Progress.active_data_cache = Progress.fresh()
	var upgrades: Node = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(upgrades)
	current_scene = upgrades
	upgrades.setup()
	upgrades.show_screen()
	await capture("upgrades-polished")
	upgrades._show_row_divers_achievements()
	await capture("achievements-polished")
	upgrades._show_row_divers_bestiary()
	await capture("bestiary-polished")
	upgrades.queue_free()
	await process_frame
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	await capture("tutorial-polished")
	for step in range(4): battle._resume()
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	for index in range(7):
		battle._spawn_enemy(Vector3((index % 3 - 1) * 1.1, 0.65, -3.8 - (index / 3) * 3.0), index, index >= 4)
	for ability in battle.abilities:
		battle.data.unlocks[ability] = true
	battle._activate("ArrowShield")
	battle._physics_process(0)
	battle.presentation.toast("ARROW SHIELD ACTIVE")
	await capture("gameplay-polished")
	battle.presentation.hide()
	battle.shield_ring.hide()
	battle.bow.hide()
	battle.dagger.hide()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Games/RowDivers/Art/RailwayFuryTitle.png")
	battle.presentation.show()
	battle.bow.show()
	battle.presentation.pause()
	battle.presentation.show_settings()
	await capture("settings-polished")
	battle.queue_free()
	await process_frame
	Progress.active_data_cache.unlocks.GodTab = true
	Progress.active_data_cache.god_panel_unlocked = true
	var ending: Node = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	current_scene = ending
	await capture("ending-polished")
	ending.reveal.kill()
	ending.story.visible_ratio = 1
	await capture("ending-polished")
	print("RAILWAY FURY POLISH PREVIEWS RENDERED")
	quit()
