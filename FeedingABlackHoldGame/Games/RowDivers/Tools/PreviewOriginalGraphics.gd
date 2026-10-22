extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var output: String
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name + ".png"))

func run() -> void:
	output = OS.get_environment("TEMP").path_join("RailwayFury-graphics-preview")
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	var settings_save = root.get_node("SaveHandler")
	var original_preference: bool = settings_save.row_divers_original_graphics
	var original_settings_path: String = settings_save.local_settings_file_path
	settings_save.local_settings_file_path = "user://original_graphics_preview_settings.json"
	settings_save.row_divers_original_graphics = true
	seed(5400)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	data.unlocks = {"Bow": true, "Dagger": true, "Auto": true, "ThirdEye": true, "Harvester": true, "ArrowShield": true, "Shuriken": true, "SlowDown": true}
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	battle._spawn_enemy(Vector3(-0.6, 0.65, -3.8), 0)
	battle._spawn_enemy(Vector3(0.7, 0.65, -6.8), 3)
	battle._spawn_enemy(Vector3(0, 0.65, -11), 6, true)
	await capture("original-gameplay")
	settings_save.row_divers_original_graphics = false
	root.get_node("SignalBus").settings_updated.emit()
	await capture("modern-gameplay")
	settings_save.row_divers_original_graphics = true
	root.get_node("SignalBus").settings_updated.emit()
	battle.presentation.show_settings()
	await capture("settings")
	battle.free()
	data.unlocks.GodTab = true
	data.god_panel_unlocked = true
	var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	current_scene = ending
	ending.reveal.kill()
	ending.story.visible_ratio = 1.0
	await capture("ending-choice")
	ending._choose("BenevolentGod")
	ending.reveal.kill()
	ending.story.visible_ratio = 1.0
	await capture("ending-benevolent")
	ending.free()
	settings_save.row_divers_original_graphics = original_preference
	DirAccess.remove_absolute(settings_save.local_settings_file_path)
	settings_save.local_settings_file_path = original_settings_path
	print("GRAPHICS PREVIEWS: ", output)
	quit()
