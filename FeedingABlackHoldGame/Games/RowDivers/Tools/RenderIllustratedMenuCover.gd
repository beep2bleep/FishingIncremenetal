extends SceneTree
## Capture real style-3 gameplay for the menu; retain the concept illustration as an alternative.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://Games/RowDivers/Art/Illustrated/RailwayFuryGameplayCover.png"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	var save = root.get_node("SaveHandler")
	var saved_path: String = save.local_settings_file_path
	save.local_settings_file_path = "user://illustrated_menu_cover_settings.json"
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	seed(5400)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	data.unlocks.Dagger = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	for corridor in battle.sections: corridor.free()
	battle.sections.clear()
	var scenery: Node3D = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd").build("Boss Section")
	battle.add_child(scenery)
	battle._spawn_enemy(Vector3(-0.85, 0.65, -4.6), 0)
	battle._spawn_enemy(Vector3(0.9, 0.65, -6.8), 3)
	battle._spawn_enemy(Vector3(0, 0.65, -10), 6, true)
	for enemy in battle.enemies:
		enemy.label.hide()
		enemy.actor.frozen = true
	battle.presentation.hide()
	for frame in range(12): await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(OUTPUT)
	battle.free()
	if FileAccess.file_exists(save.local_settings_file_path):
		DirAccess.remove_absolute(save.local_settings_file_path)
	save.local_settings_file_path = saved_path
	print("ILLUSTRATED GAMEPLAY MENU COVER: ", error_string(result))
	quit(0 if result == OK else 1)
