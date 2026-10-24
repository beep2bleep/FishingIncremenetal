extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://Games/RowDivers/Docs/Previews/"

func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT + name + ".png")

func run() -> void:
	root.size = Vector2i(1440, 900)
	root.content_scale_size = Vector2i(1920, 1200)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	var save = root.get_node("SaveHandler")
	var saved_original: bool = save.row_divers_original_graphics
	var saved_illustrated: bool = save.row_divers_illustrated_graphics
	var saved_path: String = save.local_settings_file_path
	save.local_settings_file_path = "user://illustrated_preview_settings.json"
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	graphics.select_mode(2)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	seed(5400)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	data.unlocks = {"Bow": true, "Dagger": true, "Dragon": true, "Ghost": true, "Auto": true, "ThirdEye": true, "Harvester": true, "ArrowShield": true, "Shuriken": true, "SlowDown": true}
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	battle._spawn_enemy(Vector3(-0.68, 0.67, -3.9), 0)
	battle._spawn_enemy(Vector3(0.65, 0.67, -6), 1)
	battle._spawn_enemy(Vector3(-0.1, 0.67, -9), 3)
	battle.presentation.refresh()
	await capture("illustrated-gameplay")
	for mode in [1, 0, 2]:
		graphics.select_mode(mode)
		root.get_node("SignalBus").settings_updated.emit()
		await capture(["style-modern", "style-original", "style-illustrated"][mode])
	battle.presentation.show_settings()
	await capture("illustrated-settings")
	battle.presentation.settings_panel.hide()
	battle.overlay.hide()
	# The same live battle, viewed in each imported special-room layout.
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	for corridor in battle.sections: corridor.queue_free()
	battle.sections.clear()
	var source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	var gallery: Node3D = source.build("Boss Section")
	battle.add_child(gallery)
	battle._spawn_enemy(Vector3(0, 0.65, -5.2), 6, true)
	await capture("illustrated-boss-room")
	battle.free()
	save.row_divers_original_graphics = saved_original
	save.row_divers_illustrated_graphics = saved_illustrated
	DirAccess.remove_absolute(save.local_settings_file_path)
	save.local_settings_file_path = saved_path
	print("ILLUSTRATED PREVIEWS: ", ProjectSettings.globalize_path(OUTPUT))
	quit()
