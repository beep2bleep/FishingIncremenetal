extends SceneTree
## Behavioural fixtures use real runtime code and legal max-level purchases, never the user's save.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0
var reports: Array[String] = []

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func make_battle(data: Dictionary):
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	return battle

func run() -> void:
	seed(445817)
	root.get_node("Util").set_active_game_id("rowdivers")
	var fresh: Dictionary = Progress.fresh()
	var battle = make_battle(fresh)
	check(battle.suspended and battle.presentation.tutorial_page == 0, "Fresh run opens paused tutorial")
	var initial: Vector3 = battle.player_position
	battle._physics_process(2)
	check(battle.player_position == initial, "Tutorial freezes simulation")
	for step in range(3):
		battle._resume()
		check(battle.suspended and battle.presentation.tutorial_page == step + 1, "Tutorial page advances without starting combat")
	battle._resume()
	check(not battle.suspended and battle.data.controls_seen, "Last tutorial page starts the run")
	battle.presentation.show_settings()
	check(battle.suspended and battle.presentation.settings_content.get_script() == load("res://Settings.gd"), "Pause reuses main project's settings screen")
	check(battle.audio.music.bus == "Music" and battle.audio.effects[0].bus == "Effects", "Shared volume sliders control runtime audio buses")
	battle.presentation.settings_panel.hide()
	battle._resume()
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	for kind in [4, 5, 6]:
		battle._spawn_enemy(battle.player_position + Vector3(0, -0.25, -4), kind, true)
		var enemy: Dictionary = battle.enemies.back()
		check(enemy.actor.idle != null and enemy.actor.idle.is_playing(), "Enemy has a playing skeletal idle")
		enemy.actor.idle.seek(0.0, true)
		var bone: int = enemy.actor.skeleton.find_bone("Spine_01")
		var idle_start: Quaternion = enemy.actor.skeleton.get_bone_pose_rotation(bone)
		enemy.actor.idle.advance(0.8)
		check(not idle_start.is_equal_approx(enemy.actor.skeleton.get_bone_pose_rotation(bone)), "Idle animation moves the enemy skeleton")
		enemy.next_shot = 0
		battle._update_enemies(0.01)
		check(battle.projectiles.size() == 3, "Boss %d shoots three arrows" % kind)
		check(is_equal_approx(enemy.next_shot, 2.0), "Boss volley uses source 0.5 Hz cadence")
		var before: float = battle.health
		for frame in range(35): battle._update_projectiles(1.0 / 30.0)
		check(battle.health < before, "Boss %d arrows reach and damage player" % kind)
		battle.projectiles.clear()
		battle.enemies.clear()
		enemy.node.queue_free()
		battle.health = 100
		battle.ended = false
		battle.poison_ticks = 0
	battle.data.unlocks.ArrowShield = true
	battle._activate("ArrowShield")
	battle._spawn_enemy(battle.player_position + Vector3(0, -0.25, -2), 6, true)
	battle.enemies.back().next_shot = 0
	battle._update_enemies(0.01)
	var protected_hp: float = battle.health
	for frame in range(20): battle._update_projectiles(1.0 / 30.0)
	check(battle.health == protected_hp, "Arrow Shield blocks boss volleys")
	battle.data.unlocks.Harvester = true
	battle._activate("Harvester")
	for currency in range(3):
		var token := Node3D.new()
		battle.add_child(token)
		token.position = battle.player_position
		battle.drops.append({"node": token, "currency": currency, "value": 1.0})
	battle._update_drops(0.02)
	check(battle.coins == [2.0, 2.0, 1.0], "Harvester doubles gold/gems but not crowns")
	battle.data.unlocks.Shuriken = true
	battle._activate("Shuriken")
	battle.shot_timer = 0
	battle._shoot()
	check(battle.projectiles.any(func(projectile): return projectile.type == "Shuriken"), "Shuriken adds its special projectile")
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	battle.data.unlocks.SlowDown = true
	battle._activate("SlowDown")
	initial = battle.player_position
	battle.next_section_trigger = 10000
	battle._physics_process(1)
	check(absf(battle.player_position.z - initial.z + 0.8) < 0.001, "Slow Down subtracts 0.5 from forward speed")
	for key in battle.abilities:
		var state: Dictionary = battle.abilities[key]
		check(state.duration > 0 and state.wait > 0, "Ability %s imports duration and cooldown" % key)
		state.active = 0.01
		state.cooldown = 0
		battle._physics_process(0.02)
		check(state.active <= 0 and is_equal_approx(state.cooldown, state.wait), "Ability %s starts cooldown when effect expires" % key)
		state.cooldown = 0.01
		battle._physics_process(0.02)
		check(state.cooldown == 0, "Ability %s becomes ready after its cooldown" % key)
	battle.queue_free()
	await process_frame

	var loadout: Dictionary = Progress.fresh()
	loadout.wallet = [1e30, 1e30, 1e30]
	var purchases := 0
	var ordered: Array = Progress.design().upgrades.duplicate()
	for pass_index in range(400):
		# Purchase required parent tiers first; defer optional percentage tiers until
		# after flat additions. This is a legal player strategy, not edited stats.
		ordered.sort_custom(func(a, b): return purchase_priority(loadout, a) < purchase_priority(loadout, b))
		var bought := false
		for entry in ordered:
			if Progress.buy(loadout, entry):
				bought = true
				purchases += 1
				break
		if not bought: break
	print("MAX LOADOUT: hp=%s armor=%s arrow=%s beam=%s" % [str(loadout.stats.MaxHP), str(loadout.stats.Armor), str(loadout.stats.Arrow_Damage), str(loadout.stats.Beam_Damage)])
	check(purchases == 330, "Campaign loadout obtained through 330 legal purchases")
	check(not loadout.unlocks.get("GodTab", false), "Maxed upgrades alone do not unlock ending")
	loadout.controls_seen = true
	for prestige in range(4):
		var data: Dictionary = loadout.duplicate(true)
		data.prestige = prestige
		battle = make_battle(data)
		battle.running = true
		battle.horizontal_override = 0.0
		var frames := 0
		while not battle.ended and frames < 36000:
			var desired_x = 0.0
			var nearest_z = 1000.0
			var nearest: Dictionary = {}
			var boss_close := false
			for enemy in battle.enemies:
				var ahead: float = battle.player_position.z - enemy.node.position.z
				if enemy.boss and ahead > 0 and ahead < 7: boss_close = true
				if ahead > 0 and ahead < nearest_z:
					nearest_z = ahead
					desired_x = enemy.node.position.x
					nearest = enemy
			battle.running = not boss_close
			# Dodge the contact lane while the mouse-driven Third Eye handles targets.
			# This is ordinary steering/aiming, with no invulnerability or damage changes.
			if not nearest.is_empty() and nearest_z < (4.0 if nearest.boss else 1.0):
				desired_x = -1.5 if nearest.node.position.x >= 0 else 1.5
			battle.horizontal_override = clampf((desired_x - battle.player_position.x) * 12, -1, 1)
			if not nearest.is_empty():
				battle.pointer_override = battle.camera.unproject_position(nearest.node.position) if nearest.boss else Vector2(-10000, -10000)
			for key in battle.abilities:
				if key in ["ArrowShield", "Shuriken", "SlowDown"] and not boss_close: continue
				if battle.abilities[key].active <= 0 and battle.abilities[key].cooldown <= 0:
					battle._activate(key)
			battle._physics_process(1.0 / 30.0)
			frames += 1
			if frames % 120 == 0: await process_frame
		var won: bool = data.crowns_dropped.get(str(prestige), false)
		check(battle.ended and won, "Prestige %d traverses full row and defeats final boss" % prestige)
		check(battle.data.runs == 1, "Campaign banks exactly one run")
		reports.append("Prestige %d: %.1fs, %.1fm, %d kills, hp %.0f, won=%s" % [prestige, battle.elapsed, battle.distance, battle.run_kills, battle.health, str(won)])
		print(reports.back())
		if not won: print("DAMAGE SOURCES: ", battle.damage_sources)
		if prestige == 3:
			check(data.unlocks.get("GodTab", false) and data.achievements.get("BeatTheGame", false), "Prestige 3 plus maxed upgrades unlocks final ending")
			Progress.active_data_cache = data
		battle.queue_free()
		await process_frame
	var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	if ending.story != null:
		ending._choose("BenevolentGod")
		check(Progress.active_data_cache.achievements.get("BenevolentGod", false), "Benevolent ending persists achievement state")
		ending._choose("EvilGod")
		check(Progress.active_data_cache.achievements.get("EvilGod", false), "Evil ending persists achievement state")
	else:
		check(false, "Final choice scene opens after completion")
	ending.queue_free()
	print("ROW DIVERS CAMPAIGN %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)

func purchase_priority(data: Dictionary, entry: Dictionary) -> int:
	if not Progress.can_buy(data, entry): return 10000
	if not entry.effects.any(func(effect): return effect.percentage): return 0
	for child_id in entry.children:
		var child: Dictionary = Progress.find_upgrade(str(child_id))
		if not Progress.visible(data, child) and Progress.level(data, entry) < int(child.unlockAtParentLevel):
			return 10
	return 1000
