extends SceneTree
## Run externally against an exported PCK; it is deliberately excluded from exports.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	check(Progress.Demo.enabled(), "Export forces demo mode")
	check(OS.get_user_data_dir().ends_with("RailwayFuryDemo"), "Export isolates the full-game save directory")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	for free_aim in [false,true]:
		Progress.free_aim_mode = free_aim
		for style in [0,1,2]:
			load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(style)
			var data = Progress.fresh()
			data.controls_seen = true
			data.unlocks.Dagger = true
			Progress.active_data_cache = data
			var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
			battle.persist_results = false
			root.add_child(battle)
			battle.set_physics_process(false)
			battle.set_process(false)
			check(not battle.debug_speed_cheats_enabled(), "Cheats disabled")
			for enemy in battle.enemies: enemy.node.free()
			battle.enemies.clear()
			battle._spawn_enemy(battle.player_position+Vector3(0,0,-2),0)
			battle._dagger_hit(battle.enemies.back())
			battle._advance_daggers(0.1)
			check(battle.dagger_flights.size()==1, "Packed dagger assets load")
			battle._spawn_enemy(battle.player_position+Vector3(0,0,-3),6)
			var boss: Dictionary = battle.enemies.back()
			battle._hit(boss,boss.hp+1)
			check(data.max_prestige==0 and data.get("demo_completed",false), "Packed boss clear is capped")
			battle.free()
	print("DEMO PACK: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
