extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var graphics: GDScript
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		quit(2)
		return
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	Progress.free_aim_mode = true
	for fast in [false,true]:
		Progress.active_data_cache = Progress.fresh()
		Progress.active_data_cache.controls_seen = true
		Progress.cache_profile_path = Progress.progress_path()
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.running = fast
		var before = battle.elapsed
		battle._physics_process(0.25)
		check(is_equal_approx(battle.elapsed-before,0.5 if fast else 0.25),"Combat retains selected speed")
		check(is_equal_approx(float(battle.data.gameplay_seconds),0.5 if fast else 0.25),"Track clock retains selected speed")
		for mode in [0,1,2,3]:
			graphics.select_mode(mode)
			for kind in [0,6,7]:
				var actor = load("res://Games/RowDivers/RowDiversActor.gd").new()
				root.add_child(actor)
				actor.setup(kind,kind==6)
				actor.set_process(false)
				var enemy = {"actor":actor}
				battle.enemies.append(enemy)
				battle._process(0.25)
				actor._process(0.25)
				check(is_equal_approx(actor.time,0.25),"Normal animation clock: style %d kind %d fast %s" % [mode,kind,fast])
				if actor.idle != null: check(is_equal_approx(actor.idle.speed_scale,1.0),"Skeletal animation stays at 1x")
				if kind==7: check(is_equal_approx(float(actor.bat_material.get_shader_parameter("wing_phase")),2.75),"Bat wings stay at 1x")
				battle.suspended = true
				battle._process(0.25)
				actor._process(0.25)
				check(is_equal_approx(actor.time,0.25),"Pause still freezes animation")
				battle.suspended = false
				battle.enemies.erase(enemy)
				actor.free()
		battle.free()
	print("ENEMY ANIMATION SPEED: %d checks; %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
