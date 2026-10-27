extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.get_node("Util").set_active_game_id("rowdivers")
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	Progress.free_aim_mode = true
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.pointer_override = Vector2(640,360)
	battle._update_bow_aim()
	battle.fire_waves.stage = 1
	battle.fire_waves.waves.assign([{"id":0,"z":-5.0,"gap_x":0.4,"gap_width":1.7,"speed":8,"stage":1},
		{"id":1,"z":-12.0,"gap_x":-0.8,"gap_width":1.5,"speed":8,"stage":1}])
	battle.fire_visual.sync(battle.fire_waves.waves)
	battle._update_hud()
	for i in range(8): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://Games/RowDivers/Simulation/Flight/fire_wave_preview.png")
	quit()
