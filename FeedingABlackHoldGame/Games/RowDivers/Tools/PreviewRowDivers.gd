extends SceneTree
## Render engine-owned viewports for layout QA; does not read or change reference saves.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 800))
	DisplayServer.window_set_position(Vector2i.ZERO)
	var directory = "res://Games/RowDivers/Docs/Previews"
	DirAccess.make_dir_recursive_absolute(directory)
	var upgrades = load("res://Games/RowDivers/Scenes/RowDiversUpgrades.tscn").instantiate()
	root.add_child(upgrades)
	current_scene = upgrades
	upgrades.data = Progress.fresh()
	upgrades._refresh()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/upgrades-fresh.png")
	upgrades.data.wallet = [1e30, 1e30, 1e30]
	var buying = true
	while buying:
		buying = false
		for node in Progress.design().upgrades:
			if Progress.buy(upgrades.data, node): buying = true
	upgrades.zoom = 0.32
	upgrades.pan = Vector2(620, 280)
	upgrades._update_transform()
	upgrades._refresh()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/upgrades-complete.png")
	root.remove_child(upgrades)
	upgrades.queue_free()
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.tscn").instantiate()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.data = Progress.fresh()
	battle.overlay.hide()
	battle.suspended = false
	for i in range(100): battle._physics_process(1.0 / 60.0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory + "/gameplay.png")
	print("ROW DIVERS PREVIEWS RENDERED")
	quit()
