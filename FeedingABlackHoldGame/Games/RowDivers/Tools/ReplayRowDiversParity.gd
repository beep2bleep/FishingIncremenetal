extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
func _initialize() -> void: call_deferred("run")

func progress_snapshot(data: Dictionary) -> Dictionary:
	var visible: Array = []
	var costs: Dictionary = {}
	for entry in Progress.design().upgrades:
		if Progress.visible(data, entry): visible.append(entry.id)
		costs[entry.id] = Progress.cost(data, entry)
	visible.sort()
	return {"god_panel_unlocked": data.get("god_panel_unlocked", false), "claimed": data.claimed.duplicate(true), "max_prestige": data.max_prestige, "crowns": data.crowns_dropped.keys(), "stats": data.stats.duplicate(true), "levels": data.levels.duplicate(true), "visible": visible, "unlocks": data.unlocks.duplicate(true), "achievements": data.achievements.duplicate(true), "wallet": data.wallet.duplicate(), "costs": costs}

func progress_case(case: Dictionary) -> Dictionary:
	var data: Dictionary = Progress.fresh()
	var snapshots: Array = []
	var results: Array = []
	for action in case.actions:
		match action.op:
			"grant":
				for i in range(3): data.wallet[i] += action.wallet[i]
			"buy": results.append(Progress.buy(data, Progress.find_upgrade(action.id)))
			"set_wallet": data.wallet = action.wallet.duplicate()
			"claim":
				for achievement in Progress.design().settings.achievements:
					if Progress.design().enums.AchievementType[str(int(achievement.achievementType))] == action.name:
						results.append(Progress.claim(data, achievement))
			"open_final": Progress.unlock_final_chamber(data)
			"ending":
				if data.get("god_panel_unlocked", false):
					Progress.active_data_cache = data
					var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
					ending.persist_results = false
					root.add_child(ending)
					ending._choose(action.name)
					ending.free()
			"win":
				data.prestige = int(action.prestige)
				data.controls_seen = true
				Progress.active_data_cache = data
				var battle = load("res://Games/RowDivers/Tools/ParityBattleProbe.gd").new()
				battle.persist_results = false
				root.add_child(battle)
				battle.set_physics_process(false)
				battle._spawn_enemy(Vector3(0, 0.65, -4), 4, true)
				var mini: Dictionary = battle.enemies.back()
				battle._hit(mini, mini.hp + 1)
				battle._spawn_enemy(Vector3(0, 0.65, -4), 6, true)
				var boss: Dictionary = battle.enemies.back()
				battle._hit(boss, boss.hp + 1)
				battle.free()
			"prestige3":
				data.achievements.Prestige3 = true
				Progress.check_achievements(data)
		snapshots.append(progress_snapshot(data))
	return {"id": case.id, "snapshots": snapshots, "results": results}

func combat_case(case: Dictionary) -> Dictionary:
	var data: Dictionary = Progress.fresh()
	data.stats.merge(case.get("stats", {}), true)
	data.prestige = int(case.get("prestige", 0))
	data.controls_seen = true
	for key in ["ArrowShield", "Harvester", "Shuriken", "SlowDown"]: data.unlocks[key] = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Tools/ParityBattleProbe.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.debug_speed = 1
	battle.health = float(case.get("hp", data.stats.MaxHP))
	battle.armor = float(case.get("armor", data.stats.get("Armor", 0)))
	battle.next_section_trigger = 100000
	var tracked: Dictionary = {}
	var pooled_states: Dictionary = {}
	var snapshots: Array = []
	for action in case.actions:
		match action.op:
			"spawn":
				battle.group_index = int(action.get("index", 0)) - (1 if int(action.kind) in [4, 5] else 0)
				battle._spawn_enemy(Vector3(0, 0.65, -10000), int(action.kind), int(action.kind) >= 4)
				var enemy: Dictionary = battle.enemies.back()
				if action.has("hp"): enemy.hp = float(action.hp)
				tracked[action.id] = enemy
			"expire": battle._update_enemies(100000.0)
			"effect": battle._effect(tracked[action.enemy], action.effect, float(action.get("duration", 5)))
			"hit":
				battle.random_tape = action.random.duplicate()
				var pool_key: String = action.get("pool", action.kind)
				if not pooled_states.has(pool_key): pooled_states[pool_key] = {}
				battle._projectile_hit(tracked[action.enemy], {"FireArrow": "Fire", "CursedArrow": "Cursed", "ShurikenProjectile": "Shuriken"}.get(action.kind, action.kind), pooled_states[pool_key])
			"dagger":
				battle.random_tape = [0.5]
				battle._dagger_hit(tracked[action.enemy])
			"beam":
				battle.random_tape = [0.5]
				battle._beam_hit(tracked[action.enemy])
			"loot": battle._award_loot(int(action.currency), float(action.amount) * (2.0 if battle.active("Harvester") and int(action.currency) != 2 else 1.0))
			"enemy_arrow":
				var token := Node3D.new()
				battle.add_child(token)
				token.position = battle.player_position
				battle.projectiles.append({"node": token, "dir": Vector3.ZERO, "speed": 0, "type": ["LifeSteal", "Poison", "Critical", "None"][int(action.get("kind", 3))], "life": 2.0, "hostile": true})
				battle._update_projectiles(0)
			"damage": battle._damage_player(float(action.amount), bool(action.get("ignore_armor", false)))
			"ability": battle._activate(action.name)
			"pause": battle.suspended = action.value
			"running": battle.running = not battle.running
			"tick":
				battle.horizontal_override = float(action.get("horizontal", 0))
				for frame in range(int(action.get("frames", 1))): battle._physics_process(1.0 / 60.0)
		var enemy_states: Dictionary = {}
		for key in tracked:
			var flags: Dictionary = {}
			for effect in ["Burning", "Cursed", "Bleeding"]: flags[effect] = tracked[key].get("effect_flags", {}).get(effect, tracked[key].effect == effect)
			enemy_states[key] = {"hp": tracked[key].hp, "effect": tracked[key].effect, "effects": flags}
		var ability_states: Dictionary = {}
		for key in battle.abilities:
			ability_states[key] = {"active": battle.abilities[key].active > 0, "cooldown": battle.abilities[key].cooldown > 0}
		snapshots.append({"max_prestige": data.max_prestige, "wallet": data.wallet.duplicate(), "hp": battle.health, "armor": battle.armor, "x": battle.player_position.x, "z": -battle.player_position.z, "running": battle.running, "abilities": ability_states, "enemies": enemy_states})
	battle.queue_free()
	await process_frame
	return {"id": case.id, "snapshots": snapshots}

func run() -> void:
	var args := OS.get_cmdline_user_args()
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var output: Array = []
	for case in cases:
		output.append(progress_case(case) if case.type == "progress" else await combat_case(case))
	var file := FileAccess.open(args[1], FileAccess.WRITE)
	file.store_string(JSON.stringify(output))
	file.close()
	print("PARITY REPLAY: ", output.size(), " cases")
	quit()
