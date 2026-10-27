extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Timing = preload("res://Games/RowDivers/RowDiversTiming.gd")
const Tracks = preload("res://Games/RowDivers/RowDiversTracks.gd")
var checks = {}
class Capture extends Node:
	var events = []
	func submit_row_divers_time(id: String, seconds: float): events.append([id,seconds])
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,720)
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = true
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	graphics.select_mode(2)
	var battle_script = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	battle_script.debug_speed = 1
	var cursor = root.get_node("VirtualCursor")
	var snapshots = []
	for boost in [false,true]:
		var data = Progress.fresh()
		data.controls_seen = true
		Progress.active_data_cache = data
		var battle = battle_script.new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.pointer_override = Vector2(640,360)
		for enemy in battle.enemies: enemy.node.free()
		battle.enemies.clear()
		battle.fire_waves.timer = 10000
		battle.shot_timer = 10
		battle.running = boost
		cursor.set_scene_enabled(true)
		cursor._refresh_cursor_display_mode()
		checks["only_reticle_"+str(boost)] = cursor._gameplay_pointer_hidden and not cursor._cursor_sprite.visible
		for i in range(60): battle._physics_process(1.0/60)
		snapshots.append({"elapsed":battle.elapsed,"z":battle.player_position.z,"shot":battle.shot_timer,"hp":battle.health,"clock":data.gameplay_seconds})
		battle.suspended = true
		battle.presentation.pause()
		cursor.set_gameplay_pointer_hidden(false)
		var before = float(data.gameplay_seconds)
		battle._physics_process(.1)
		checks["pause_clock_"+str(boost)] = data.gameplay_seconds==before and Input.mouse_mode==Input.MOUSE_MODE_VISIBLE
		battle._resume()
		checks["resume_hides_cursor_"+str(boost)] = cursor._gameplay_pointer_hidden
		battle._finish(false)
		battle._physics_process(.1)
		checks["finished_clock_"+str(boost)] = data.gameplay_seconds==before and not data.has("timed_milestones_submitted")
		if not boost:
			# Check live-exit persistence against a dedicated file, never player saves.
			battle.ended = false
			battle.persist_results = true
			battle.progress_save_path = ProjectSettings.globalize_path("user://railway_exit_clock_fixture.json")
		battle.free()
		if not boost:
			checks.exit_clock_checkpoint = is_equal_approx(float(Progress.load_data("user://railway_exit_clock_fixture.json").gameplay_seconds),before)
			DirAccess.remove_absolute("user://railway_exit_clock_fixture.json")
	checks.double_full_simulation = is_equal_approx(snapshots[1].elapsed,2*snapshots[0].elapsed) and is_equal_approx(snapshots[1].z,2*snapshots[0].z) and is_equal_approx(10-snapshots[1].shot,2*(10-snapshots[0].shot))
	checks.clock_counts_active_seconds = is_equal_approx(snapshots[0].clock,1) and is_equal_approx(snapshots[1].clock,1)
	checks.no_extra_run_damage = snapshots[0].hp==100 and snapshots[1].hp==95
	checks.cursor_restored_on_exit = Input.mouse_mode==Input.MOUSE_MODE_VISIBLE
	var data = Progress.fresh()
	var sink = Capture.new()
	for i in range(5):
		data.gameplay_seconds = (i+1)*100.25
		Timing.record(data,Timing.MILESTONES[i],false)
	data.gameplay_seconds = 9999
	Timing.record(data,"boss_0",false)
	checks.first_clear_snapshot = data.timed_milestones.boss_0==100.25 and data.timed_milestones.ending==501.25
	Timing.submit_pending(data,sink)
	checks.five_boards_cumulative = sink.events.size()==5 and sink.events[4][1]==501.25 and Timing.configs().size()==5
	data.leaderboards_assisted = true
	Timing.submit_pending(data,sink)
	checks.editor_scores_local_only = sink.events.size()==5
	var path = "user://railway_timing_fixture.json"
	Progress.save_data(data,path)
	checks.clock_survives_reload = Progress.load_data(path).gameplay_seconds==9999 and Progress.load_data(path).timed_milestones==data.timed_milestones
	var old = Progress.fresh()
	old.erase("gameplay_seconds")
	old.runs = 2
	Progress.save_data(old,path)
	old = Progress.load_data(path)
	checks.old_clock_not_fabricated = old.gameplay_seconds==0 and not Timing.eligible(old)
	DirAccess.remove_absolute(path)
	sink.free()
	var flying_board = Timing.board_id("boss_0")
	Progress.free_aim_mode = false
	var classic_board = Timing.board_id("boss_0")
	Progress.active_tree = "previous"
	checks.separate_mode_boards = flying_board!=classic_board and Timing.board_id("boss_0")!=classic_board
	Progress.active_tree = "rebalanced"
	Progress.free_aim_mode = true
	var steam = root.get_node("SteamHandler")
	steam.steam_enabled = false # Never create boards or upload fixture scores.
	Progress.active_data_cache = Progress.fresh()
	steam.submit_row_divers_time(flying_board,12.345)
	checks.millisecond_score = steam.get_cached_leaderboard_last_submitted_score(flying_board)==12345
	checks.steam_configs = steam.get_active_fishing_leaderboard_configs().size()==5 and steam.get_active_fishing_leaderboard_configs()[4].milestone=="ending"
	checks.tracks_no_combat_rng = _verify_tracks()
	_verify_pillars()
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	data = Progress.fresh()
	data.gameplay_seconds = 3723
	Progress.active_data_cache = data
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for i in range(8): await process_frame
	checks.upgrade_clock_visible = screen.row_divers_wallet_label.text.contains("01:02:03")
	checks.leaderboard_panel_available = screen.leaderboard_button!=null
	screen._on_leaderboard_button_pressed()
	checks.five_board_ui = screen.leaderboard_body_label.text.contains("LEVEL 1 CLEARED") and screen.leaderboard_body_label.text.contains("ENDING REACHED")
	if "--preview" in OS.get_cmdline_user_args():
		for i in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/timed_leaderboards.png")
	screen.free()
	if "--preview" in OS.get_cmdline_user_args(): await _preview_tracks(battle_script)
	var passed = checks.values().all(func(v):return v)
	print("TIMED RAILWAY RUNS: ",checks.size()," checks passed=",passed," ",checks)
	quit(0 if passed else 1)

func _verify_tracks() -> bool:
	seed(4567)
	var expected = randf()
	seed(4567)
	for width in [1.0,1.4]:
		for number in range(1,16):
			var tracks = Tracks.build(number,width)
			checks["track_gaps_%s_%d" % [str(width),number]] = (tracks.get_child_count()==0)==(number%7==0)
			for batch in tracks.get_children():
				for i in range(batch.multimesh.instance_count):
					var bounds: AABB = batch.multimesh.get_instance_transform(i)*batch.multimesh.mesh.get_aabb()
					if absf(bounds.position.x)>1.05*width or absf(bounds.end.x)>1.05*width: checks.tracks_keep_center_lane = false
			tracks.free()
	if not checks.has("tracks_keep_center_lane"): checks.tracks_keep_center_lane = true
	return randf()==expected

func _preview_tracks(battle_script):
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var battle = battle_script.new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.pointer_override = Vector2(640,360)
	for section in battle.sections: section.free()
	battle.sections.clear()
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	var source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	for variant in [1,2,5]:
		var hall = source.build("Section 5" if variant==5 else "Section 4",true,true)
		battle.add_child(hall)
		hall.scale.x = 1.4
		hall.position.x *= 1.4
		source.refresh_materials(hall)
		var tracks = Tracks.build(variant,1.4)
		tracks.position.y = .52
		battle.add_child(tracks)
		battle._update_camera_presentation()
		battle.pointer_override = root.get_visible_rect().size*.5
		battle._update_bow_aim()
		battle.running = true
		battle._update_hud()
		battle.crosshair.position = battle._aim_pointer() - battle.crosshair.size*.5
		for i in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/tracks_%d.png" % variant)
		hall.free()
		tracks.free()
	battle.free()

func _verify_pillars():
	var source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	for width in [1.0,1.4]:
		for layout in source.catalog().layouts:
			var hall = source.build(layout,true,true)
			root.add_child(hall)
			hall.scale.x = width
			hall.position.x *= width
			var pillars: Array[AABB] = []
			for node in hall.find_children("*","Node3D",true,false):
				if node.get_meta("row_source_name","")!="Column": continue
				for mesh in node.find_children("*","MeshInstance3D",true,false):
					pillars.append(mesh.global_transform*mesh.get_aabb())
			var clear = true
			for number in [1,2,4,5]:
				var tracks = Tracks.build(number,width)
				for batch in tracks.get_children():
					for i in range(batch.multimesh.instance_count):
						var bounds: AABB = batch.multimesh.get_instance_transform(i)*batch.multimesh.mesh.get_aabb()
						bounds.position.y += .52
						for pillar in pillars:
							if bounds.intersects(pillar): clear = false
				tracks.free()
			checks["pillar_clearance_"+str(width)+"_"+layout] = clear
			hall.free()
