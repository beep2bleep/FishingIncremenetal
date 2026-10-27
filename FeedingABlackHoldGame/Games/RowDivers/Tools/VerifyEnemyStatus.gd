extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.get_node("Util").set_active_game_id("rowdivers")
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	var actor_script = load("res://Games/RowDivers/RowDiversActor.gd")
	for mode in [0, 1, 2]:
		graphics.select_mode(mode)
		for kind in [0, 6, 7]:
			var actor = actor_script.new()
			root.add_child(actor)
			actor.setup(kind, kind == 6)
			var status = actor.status_visual
			check(not status.burning.visible and not status.cursed.visible, "Enemy begins without status visuals")
			actor.set_effects({"Burning": true})
			check(status.burning.visible and not status.cursed.visible, "Burning shows only flames")
			actor.set_effects({"Cursed": true})
			check(status.cursed.visible and not status.burning.visible, "Curse shows only runes")
			actor.set_effects({"Burning": true, "Cursed": true})
			actor._process(0.1)
			check(status.burning.visible and status.cursed.visible and status.animation_time > 0, "Effects animate together")
			actor._refresh_graphics()
			check(status.burning.visible and status.cursed.visible, "Status visuals survive art refresh")
			actor.set_effects({})
			check(not status.burning.visible and not status.cursed.visible, "Clearing status hides both effects")
			actor.free()
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	var enemy: Dictionary = battle.enemies.front()
	battle._effect(enemy, "Burning", 0.1)
	battle._effect(enemy, "Cursed", 0.1)
	check(enemy.actor.status_visual.burning.visible and enemy.actor.status_visual.cursed.visible, "Combat application enables both visuals")
	battle._update_enemies(0.11)
	check(not enemy.actor.status_visual.burning.visible and not enemy.actor.status_visual.cursed.visible, "Combat expiration clears visuals")
	var before: int = battle.get_child_count()
	battle._beam_effect(Vector3(0, 1, -5))
	var beam = battle.get_child(before)
	var material: StandardMaterial3D = beam.material_override
	check(material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA and is_equal_approx(material.albedo_color.a, 0.75), "Laser is 75% opaque")
	check(material.albedo_color.r > material.albedo_color.b * 5 and material.albedo_color.r < 0.6, "Laser is dark red")
	# Step the actual pulse tween rather than relying on headless frame timing.
	var pulse: Tween = get_processed_tweens().back()
	pulse.custom_step(0.2)
	await process_frame
	check(not is_instance_valid(beam), "Laser pulse cleans itself up")
	battle.free()
	print("ENEMY STATUS %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
