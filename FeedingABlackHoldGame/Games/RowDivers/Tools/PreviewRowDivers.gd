extends SceneTree
## Render the main project's shared upgrade screen and Row Divers battle scene without changing the save.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 800))
	var util = root.get_node("Util")
	var global_state = root.get_node("Global")
	util.set_active_game_id("rowdivers")
	global_state.current_game_mode_data = null
	global_state.ensure_default_game_mode_data()
	global_state.new_game()
	global_state.start_in_upgrade_scene = true
	Progress.active_data_cache = Progress.fresh()
	var directory := "res://Games/RowDivers/Docs/Previews"
	DirAccess.make_dir_recursive_absolute(directory)
	var upgrades: Node = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(upgrades)
	current_scene = upgrades
	upgrades.setup()
	upgrades.show_screen()
	for _frame in range(18):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/upgrades-fresh.png")
	var tech_tree: Node = upgrades.get_node("CanvasLayer/Tech Tree")
	for upgrade in global_state.game_mode_data_manager.upgrades.values():
		upgrade.current_tier = upgrade.max_tier
	for node in tech_tree.node_dict.values():
		node.update()
	tech_tree._refresh_states_after_full_build()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/upgrades-complete.png")
	root.remove_child(upgrades)
	upgrades.free()
	var battle: Node = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.tscn").instantiate()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.data = Progress.fresh()
	battle.overlay.hide()
	battle.suspended = false
	for _frame in range(100):
		battle._physics_process(1.0 / 60.0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/gameplay.png")
	print("ROW DIVERS PREVIEWS RENDERED USING THE SHARED UPGRADE SCREEN")
	quit()
