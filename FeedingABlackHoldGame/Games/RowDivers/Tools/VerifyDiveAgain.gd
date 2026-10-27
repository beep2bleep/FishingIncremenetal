extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var Battle
var scene: PackedScene
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	# Scene reload creates the replacement internally. Disable persistence before
	# its _ready runs, so this fixture never writes to the player's progression.
	node_added.connect(func(node):
		if Battle != null and node.get_script() == Battle:
			node.persist_results = false
			node.set_physics_process(false)
			node.set_process(false))
	call_deferred("run")

func run() -> void:
	Battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	scene = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.tscn")
	root.get_node("Util").set_active_game_id("rowdivers")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	for style in [0, 1, 2]:
		graphics.select_mode(style)
		for free_aim in [false, true]:
			Progress.free_aim_mode = free_aim
			var data = Progress.fresh()
			data.controls_seen = true
			data.wallet = [123.0, 7.0, 0.0]
			Progress.active_data_cache = data
			var battle = scene.instantiate()
			root.add_child(battle)
			current_scene = battle
			for attempt in range(2):
				battle._spawn_enemy(Vector3(0, 0.65, -5), 6, true)
				var boss: Dictionary = battle.enemies.back()
				battle._hit(boss, boss.hp + 1)
				check(battle.ended and battle.victory and battle.retry.visible, "Boss win presents Dive Again")
				check(not battle.persist_results, "Fixture keeps progression isolated")
				var old_id: int = battle.get_instance_id()
				var feedback = battle.retry.get_node("RailwayButtonFeedback")
				# Emit the actual button signal, including its animation callback after
				# the reload callback has removed the old button from the scene tree.
				battle.retry.pressed.emit()
				check(not feedback.is_inside_tree(), "Retry removes the old button before feedback completes")
				check(is_equal_approx(feedback.motion.hover_effect_strength(), 1.0), "Detached button width calculation safely returns its default")
				feedback.motion.do_tween(0)
				for frame in range(3): await process_frame
				battle = current_scene
				check(is_instance_valid(battle) and battle.get_instance_id() != old_id, "Dive Again loads a replacement battle")
				if not is_instance_valid(battle):
					quit(1)
					return
				check(not battle.ended and not battle.suspended and battle.health == battle.s("MaxHP"), "Replayed dive starts healthy and playable")
				check(battle.free_aim_mode == free_aim and graphics.mode() == style, "Replay retains aiming and graphics mode")
				check(battle.data.wallet == [123.0, 7.0, 1.0] and battle.data.crowns_dropped.get("0", false), "Boss rewards survive retry without duplicate crowns")
				check(not battle.persist_results, "Replacement battle also keeps saves isolated")
				print("DIVE AGAIN: style %d, free aim %s, retry %d complete" % [style, str(free_aim), attempt + 1])
			battle.free()
	print("DIVE AGAIN %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
