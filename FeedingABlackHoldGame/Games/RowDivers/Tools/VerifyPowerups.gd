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

func reset_powers(battle) -> void:
	for state in battle.abilities.values():
		state.active = 0.0
		state.cooldown = 0.0
	battle.ended = false
	battle.suspended = false
	battle.next_powerup_index = 0

func press_space(battle, echo = false) -> void:
	var event = InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	event.echo = echo
	battle._unhandled_input(event)

func verify_battle(battle) -> void:
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	battle.next_section_trigger = 10000
	battle.data.unlocks = {"Bow": true}
	reset_powers(battle)
	check(battle.next_powerup().is_empty(), "No locked power enters the Space queue")
	battle.data.unlocks.Harvester = true
	check(battle.next_powerup() == "Harvester", "Queue skips unpurchased Shield")
	for key in battle.POWERUP_ORDER: battle.data.unlocks[key] = true
	for key in battle.POWERUP_ORDER:
		check(battle.next_powerup() == key, "Queue highlights " + key)
		battle.presentation.refresh()
		check(battle.presentation.ability_buttons[key].text.begins_with("[SPACE]"), "Next power has Space label")
		check(battle.presentation.ability_buttons[key].focus_mode == Control.FOCUS_NONE, "Clicked power cannot capture Space")
		press_space(battle)
		check(battle.active(key), "One Space press activates " + key)
	check(battle.abilities.values().all(func(state): return state.active == 10), "One press per power activates every power")
	check(battle.next_powerup().is_empty(), "Active powers leave the ready queue")
	press_space(battle)
	check(battle.abilities.values().all(func(state): return state.active == 10), "No-ready press does not reset active powers")
	reset_powers(battle)
	press_space(battle, true)
	check(not battle.active("ArrowShield"), "Held Space does not repeat activation")
	battle.suspended = true
	press_space(battle)
	check(not battle.active("ArrowShield"), "Pause blocks Space")
	reset_powers(battle)
	battle.abilities.ArrowShield.cooldown = 5
	check(battle.next_powerup() == "Harvester", "Queue skips cooling powers")
	reset_powers(battle)
	for key in battle.POWERUP_ORDER:
		reset_powers(battle)
		battle._activate(key)
		battle._update_powerups(9.9)
		check(battle.active(key), key + " remains active before ten seconds")
		battle._update_powerups(0.1)
		check(not battle.active(key) and is_equal_approx(battle.abilities[key].cooldown, 30), key + " begins a thirty-second cooldown")
		battle._update_powerups(29.9)
		check(battle.abilities[key].cooldown > 0, key + " remains unavailable before cooldown ends")
		battle._update_powerups(0.1)
		check(is_zero_approx(battle.abilities[key].cooldown), key + " becomes ready at forty seconds")
	reset_powers(battle)
	battle.data.stats.MaxHP = 1000.0
	battle.data.stats.Armor_Against_Projectiles = 0
	for source in ["the row", "enemy arrows", "poison", "fire waves", "enemy contact"]:
		for ignore_armor in [false, true]:
			battle.health = 1000
			battle.armor = 0
			battle.abilities.ArrowShield.active = 10
			battle._damage_player(40, ignore_armor, source)
			check(is_equal_approx(battle.health, 980), "Shield halves " + source)
		battle.health = 1000
		battle.armor = 100
		battle._damage_player(40, false, source)
		check(is_equal_approx(battle.armor, 80) and battle.health == 1000, "Shield reduces armor loss from " + source)
	reset_powers(battle)
	battle.armor = 0
	battle.data.prestige = 0
	battle.health = 1000
	battle.abilities.ArrowShield.active = 10
	var node = Node3D.new()
	battle.add_child(node)
	node.position = battle.player_position
	battle.projectiles.append({"node": node, "dir": Vector3.ZERO, "speed": 0.0, "type": "Poison", "life": 2.0, "hostile": true})
	battle._update_projectiles(0.001)
	check(battle.poison_ticks == 2 and is_equal_approx(battle.health, 990), "Shield halves a real poison projectile and its initial poison tick")
	battle.poison_ticks = 0
	for stage in range(4):
		reset_powers(battle)
		battle.data.prestige = stage
		battle.data.stats.MaxHP = [100.0, 500.0, 2500.0, 10000.0][stage]
		battle.health = battle.s("MaxHP") * 0.25
		var before: float = battle.health
		var walking_loss: float = battle.walking_damage() * 5
		battle._activate("SlowDown")
		for frame in range(600):
			battle._update_powerups(1.0 / 60.0)
			if (frame + 1) % 120 == 0: battle._damage_player(battle.walking_damage(), false, "the row")
		check(absf(battle.health - before - walking_loss * 0.5) < 0.01, "Regen heals 1.5x ten seconds of walking loss at level %d" % stage)
		print("REGEN level %d: %.4f%% max HP/s at %.0f HP, %.2f HP/s" % [stage + 1, battle.regen_percent_per_second(), battle.s("MaxHP"), battle.s("MaxHP") * battle.regen_percent_per_second() / 100.0])
	reset_powers(battle)
	battle.health = battle.s("MaxHP") - 0.01
	battle._activate("SlowDown")
	battle._update_powerups(1)
	check(battle.health == battle.s("MaxHP"), "Regen cannot exceed max health")
	var position_before: Vector3 = battle.player_position
	battle.row_timer = 0
	battle._physics_process(0.1)
	check(is_equal_approx(position_before.z - battle.player_position.z, battle.forward_speed * 0.1), "Regen does not slow movement")
	battle.suspended = true
	var health_before: float = battle.health
	var active_before: float = battle.abilities.SlowDown.active
	battle._physics_process(1)
	check(battle.health == health_before and battle.abilities.SlowDown.active == active_before, "Pause freezes healing and power timers")

func verify_ghost_and_boss_range(battle) -> void:
	reset_powers(battle)
	battle.data.unlocks.GhostPower = true
	battle.data.stats.Distance_Range = 24.0
	for enemy in battle.enemies: enemy.node.free()
	battle.enemies.clear()
	for projectile in battle.projectiles: projectile.node.free()
	battle.projectiles.clear()
	battle._spawn_enemy(battle.player_position + Vector3(0.8, 0, -1.0), 0)
	var melee: Dictionary = battle.enemies.back()
	melee.chasing = true
	battle._spawn_enemy(battle.player_position + Vector3(0, 1, -5), 7)
	var flier: Dictionary = battle.enemies.back()
	flier.next_shot = 0.0
	battle._spawn_enemy(battle.player_position + Vector3(0, 0, -23), 6, true)
	var boss: Dictionary = battle.enemies.back()
	boss.next_shot = 0.0
	var melee_position: Vector3 = melee.node.position
	battle._activate("GhostPower")
	battle.presentation.refresh()
	check(battle.presentation.ability_columns.GhostPower.visible, "Ghost has a purchased HUD card")
	battle._update_enemies(0.1)
	check(melee.node.position == melee_position and not melee.chasing, "Ghost stops existing melee pursuit")
	check(battle.projectiles.size() == 3, "Boss fires beyond old range while Ghost suppresses fliers")
	check(battle.projectiles.all(func(projectile): return projectile.life * projectile.speed >= 24), "Boss projectiles can travel the player's attack range")
	for projectile in battle.projectiles: projectile.node.free()
	battle.projectiles.clear()
	boss.node.position.z = battle.player_position.z - 24.1
	boss.next_shot = 0.0
	battle._update_enemies(0.1)
	check(battle.projectiles.is_empty(), "Boss cannot fire outside player range")
	battle.data.stats.Distance_Range = 5.0
	boss.node.position.z = battle.player_position.z - 5.1
	battle._update_enemies(0.1)
	check(battle.projectiles.is_empty(), "Boss range follows shorter player range")
	boss.node.position.z = battle.player_position.z - 5.0
	battle._update_enemies(0.1)
	check(battle.projectiles.size() == 3, "Boss fires at player range boundary")
	battle._update_powerups(10)
	for projectile in battle.projectiles: projectile.node.free()
	battle.projectiles.clear()
	flier.next_shot = 0.0
	battle._update_enemies(0.1)
	if battle.free_aim_mode:
		check(melee.chasing and melee.node.position != melee_position, "Melee resumes pursuit after Ghost expires")
		check(battle.projectiles.size() == 1 and battle.projectiles[0].type == "Bat", "Flier resumes shooting after Ghost expires")

func run() -> void:
	root.size = Vector2i(1280, 800)
	root.get_node("Util").set_active_game_id("rowdivers")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	for path in [Progress.DATA_PATH, Progress.PREVIOUS_DATA_PATH, Progress.FREE_AIM_DATA_PATH]:
		var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		check(catalog.settings.abilities.all(func(power): return power.abilityDuration == 10 and power.cooldownDuration == 30), "Timing agrees in " + path)
	for free_aim in [false, true]:
		Progress.free_aim_mode = free_aim
		Progress.active_data_cache = Progress.fresh()
		Progress.active_data_cache.controls_seen = true
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_physics_process(false)
		battle.set_process(false)
		verify_battle(battle)
		verify_ghost_and_boss_range(battle)
		if "--preview" in OS.get_cmdline_user_args() and free_aim:
			reset_powers(battle)
			battle.data.prestige = 0
			battle._activate("Harvester")
			battle._activate("SlowDown")
			battle.presentation.refresh()
			await create_timer(1.0).timeout
			await RenderingServer.frame_post_draw
			var path = OS.get_environment("TEMP") + "/railway-powerups-preview.png"
			root.get_texture().get_image().save_png(path)
			print("PREVIEW: ", path)
		battle.free()
	print("POWERUPS %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
