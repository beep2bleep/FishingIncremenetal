extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var Battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	var battle = Battle.new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.data = Progress.fresh()
	battle.health = 100
	battle.armor = 0
	battle.suspended = false
	battle.next_section_trigger = 1000
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(is_equal_approx(battle.health, 95.0), "Row drains 5 HP every 2 seconds")
	check(absf(battle.distance - 2.6) < 0.001, "Forward movement is 1.3 units/s")
	var shift = InputEventKey.new()
	shift.keycode = KEY_SHIFT
	shift.pressed = true
	battle._unhandled_input(shift)
	check(battle.running, "Shift toggles running")
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(absf(battle.distance - 6.5) < 0.001, "Running uses 1.5 multiplier")
	check(is_equal_approx(battle.health, 87.5), "Running scales row damage")
	battle.running = false
	battle.row_timer = 0
	battle._spawn_enemy(battle.player_position + Vector3(0, -0.23, -3), 0)
	var enemy = battle.enemies.back()
	enemy.hp = 100
	battle._shoot()
	var count = battle.projectiles.size()
	battle._shoot()
	check(battle.projectiles.size() == count, "Bow rate limits repeated clicks")
	for i in range(45): battle._update_projectiles(1.0 / 60.0)
	check(is_equal_approx(enemy.hp, 84.0), "Arrow projectile deals base 16 damage")
	battle.data.unlocks.ArrowShield = true
	battle._activate("ArrowShield")
	check(battle.active("ArrowShield"), "Unlocked ability activates")
	for i in range(301): battle._physics_process(1.0 / 60.0)
	check(not battle.active("ArrowShield") and battle.abilities.ArrowShield.cooldown > 119, "Shield lasts 5 seconds then 120-second cooldown")
	battle._activate("ArrowShield")
	check(not battle.active("ArrowShield"), "Cooldown blocks repeat use")
	battle.data.stats.Armor_Against_Row = 50
	battle.armor = 20
	battle.row_timer = 0
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(is_equal_approx(battle.armor, 17.5), "Row armor reduction applied before shield damage")
	var before = battle.player_position
	battle.suspended = true
	battle._physics_process(10)
	check(battle.player_position == before, "Pause freezes movement and combat")
	battle._finish(false)
	check(battle.ended and battle.overlay.visible, "Death/retreat opens run summary")
	check(battle.data.runs == 1, "Run results applied exactly once")
	battle._finish(false)
	check(battle.data.runs == 1, "Repeated finish is idempotent")
	print("ROW DIVERS GAMEPLAY SMOKE %s: %d assertions, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	battle.queue_free()
	quit(0 if failures == 0 else 1)
