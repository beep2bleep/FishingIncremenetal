extends Node3D
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Audio = preload("res://Games/RowDivers/RowDiversAudio.gd")
var data: Dictionary
var camera: Camera3D
var player_position = Vector3(0, 0.9, 0)
var forward_speed = 1.3
var running = false
var health = 100.0
var armor = 0.0
var elapsed = 0.0
var row_timer = 0.0
var shot_timer = 0.0
var extra_timers = {"Dragon": 0.0, "Ghost": 0.0}
var auxiliary_fire_mode = "Click"
var dagger_timer = 0.0
var beam_timer = 0.0
var poison_timer = 0.0
var poison_ticks = 0
var poison_hits = 0
var section = 1
var next_section_trigger = 3.474
var group_index = 0
var fire_mode = "Click"
var ended = false
var suspended = false
var run_kills = 0
var distance = 0.0
var coins = [0.0, 0.0, 0.0]
var enemies: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var drops: Array[Dictionary] = []
var sections: Array[Node3D] = []
var abilities: Dictionary = {}
var hud: Label
var ability_hud: Label
var crosshair: Label
var overlay: ColorRect
var overlay_title: Label
var resume: Button
var retry: Button
var audio: Node
var bow: MeshInstance3D
var hit_flash = 0.0
var persist_results = true

func s(key: String) -> float:
	return Progress.stat(data, key)

func unlocked(key: String) -> bool:
	return bool(data.unlocks.get(key, false))

func active(key: String) -> bool:
	return abilities.has(key) and float(abilities[key].active) > 0

func _ready() -> void:
	data = Progress.load_data()
	data.achievements.FirstDive = true
	health = s("MaxHP")
	armor = s("Armor")
	forward_speed = float(Progress.design().settings.movement.forwardSpeed)
	fire_mode = "Auto" if unlocked("Auto") else ("Hold" if unlocked("Hold") else "Click")
	auxiliary_fire_mode = fire_mode
	Global.game_state = Util.GAME_STATES.PLAYING
	MusicPlayer.stop()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("13121b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c5b8b0")
	env.ambient_light_energy = 0.7
	environment.environment = env
	add_child(environment)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -20, 0)
	light.light_energy = 0.8
	add_child(light)
	camera = Camera3D.new()
	camera.fov = 65
	camera.far = 60
	add_child(camera)
	camera.position = player_position
	bow = _box(camera, Vector3(0, -0.34, -0.6), Vector3(0.42, 0.04, 0.04), Color("b78f65"))
	_box(camera, Vector3(0, -0.3, -0.64), Vector3(0.025, 0.025, 0.35), Color("e7d8a9"))
	for ability in Progress.design().settings.abilities:
		var key: String = str(Progress.design().enums.AbilityType[str(int(ability.abilityType))])
		abilities[key] = {"active": 0.0, "cooldown": 0.0, "duration": float(ability.abilityDuration), "wait": float(ability.cooldownDuration)}
	for number in range(1, 4):
		_build_section(number)
	_build_hud()
	audio = Audio.new()
	add_child(audio)
	audio.play_music(true)
	if not data.controls_seen:
		suspended = true
		overlay.show()
		overlay_title.text = "CONTROLS\n\nLeft / Right or A / D: move\nLeft mouse: fire\nShift: toggle running\nEscape: pause\n\nUnlock abilities and fire modes in Upgrades"
		resume.text = "CONTINUE"
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_hud()

func _box(parent: Node, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var shape = BoxMesh.new()
	shape.size = dimensions
	mesh.mesh = shape
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material_override = material
	parent.add_child(mesh)
	mesh.position = pos
	return mesh

func _build_section(number: int) -> void:
	var root = Node3D.new()
	root.name = "Section_" + str(number)
	add_child(root)
	root.position.z = -float((number - 1) * 20)
	sections.append(root)
	_box(root, Vector3(0, -0.18, -10), Vector3(3.6, 0.3, 20), Color("3b3540"))
	_box(root, Vector3(-1.95, 1.4, -10), Vector3(0.3, 3.2, 20), Color("53515e"))
	_box(root, Vector3(1.95, 1.4, -10), Vector3(0.3, 3.2, 20), Color("53515e"))
	_box(root, Vector3(0, 3, -10), Vector3(4.2, 0.2, 20), Color("282630"))
	for z in range(0, 20, 2):
		_box(root, Vector3(0, -0.01, -float(z)), Vector3(3.6, 0.02, 0.04), Color("1f1b25"))
		for x in [-1.78, 1.78]:
			_box(root, Vector3(x, 1.4, -float(z)), Vector3(0.04, 3, 0.07), Color("302b38"))
	if number in [5, 10, 15]:
		_spawn_enemy(Vector3(0, 0.65, root.position.z - 18.658), 4 if number == 5 else (5 if number == 10 else 6), true)
	var layouts: Dictionary = Progress.design().settings.sections
	var layout_key = "Section " + str(randi_range(1, 6))
	if number == 1: layout_key = "Initial"
	if number == 5: layout_key = "MiniBoss1 Section"
	if number == 10: layout_key = "MiniBoss2 Section"
	if number == 15: layout_key = "Boss Section"
	var layout: Array = layouts[layout_key]
	for i in range(mini(2, layout.size())):
			# Unity chooses distributed groups (round(i * group_count / 2)), then a random side.
		var group: Dictionary = layout[clampi(roundi(float(i) * layout.size() / 2.0), 0, layout.size() - 1)]
		var points: Array = group.left if randi_range(0, 1) == 0 else group.right
		group_index += 1
		var allowed: Array = [0, 1, 2, 3].filter(func(kind): return not group.banned.has(float(kind)) and not group.banned.has(kind))
		for j in range(2 if int(data.prestige) == 3 else 1):
			if j >= points.size() or allowed.is_empty(): continue
			var point: Array = points[j]
			_spawn_enemy(Vector3(float(point[0]) - 2.5, float(point[1]), root.position.z - (float(point[2]) + 28.474)), int(allowed.pick_random()))
	for old in sections.duplicate():
		if old.position.z > player_position.z + 30:
			sections.erase(old)
			old.queue_free()

func _spawn_enemy(pos: Vector3, kind: int, boss = false) -> void:
	var root = Node3D.new()
	add_child(root)
	root.position = pos
	var palette = [Color("99ad8a"), Color("d6a87a"), Color("b38ec5"), Color("b8b1a0"), Color("d17769"), Color("be79a5"), Color("dcb75e")]
	_box(root, Vector3.ZERO, Vector3(0.55, 0.9, 0.4) * (1.5 if boss else 1.0), palette[kind])
	_box(root, Vector3(0, 0.6, 0), Vector3(0.32, 0.3, 0.3), palette[kind].lightened(0.15))
	var label = Label3D.new()
	label.position.y = 1.15
	label.font_size = 42
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	var prestige_level = int(data.prestige)
	var health_multiplier = [1.0, 110.0, 100.0, 120.0][prestige_level]
	var base_hp = 80.0 if boss else 40.0
	var hp = floor(base_hp * pow(1.15, group_index) * pow(health_multiplier, prestige_level))
	if kind == 1: hp *= 1.2
	enemies.append({"node": root, "hp": hp, "base_hp": base_hp, "label": label, "kind": kind, "boss": boss, "next_shot": 1.0, "contact": false, "effect": "", "effect_time": 0.0, "tick": 0.0})
	label.text = str(int(hp))

func _build_hud() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui)
	hud = Label.new()
	hud.position = Vector2(32, 24)
	hud.add_theme_font_size_override("font_size", 26)
	ui.add_child(hud)
	ability_hud = Label.new()
	ability_hud.position = Vector2(32, -100)
	ability_hud.anchor_top = 1
	ability_hud.anchor_bottom = 1
	ability_hud.add_theme_font_size_override("font_size", 20)
	ui.add_child(ability_hud)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 28)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	ui.add_child(crosshair)
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.02, 0.03, 0.94)
	ui.add_child(overlay)
	var box = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.position -= Vector2(320, 240)
	box.size = Vector2(640, 480)
	box.add_theme_constant_override("separation", 22)
	overlay.add_child(box)
	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 26)
	box.add_child(overlay_title)
	resume = Button.new()
	resume.text = "RESUME"
	resume.custom_minimum_size.y = 60
	resume.pressed.connect(_resume)
	box.add_child(resume)
	retry = Button.new()
	retry.text = "RETRY"
	retry.custom_minimum_size.y = 60
	retry.pressed.connect(func(): get_tree().reload_current_scene())
	box.add_child(retry)
	retry.hide()
	var upgrades = Button.new()
	upgrades.text = "UPGRADES"
	upgrades.custom_minimum_size.y = 60
	upgrades.pressed.connect(func():
		if not ended: _finish(false)
		get_tree().change_scene_to_file("res://Games/RowDivers/Scenes/RowDiversUpgrades.tscn"))
	box.add_child(upgrades)
	overlay.hide()

func _resume() -> void:
	suspended = false
	data.controls_seen = true
	if persist_results: Progress.save_data(data)
	overlay.hide()
	resume.text = "RESUME"
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and not ended:
			if suspended:
				_resume()
			else:
				suspended = true
				overlay_title.text = "PAUSED"
				overlay.show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
		if suspended or ended: return
		if event.keycode == KEY_SHIFT: running = not running
		if unlocked("Auto"):
			if event.keycode in [KEY_1, KEY_KP_1]: fire_mode = "Hold"
			if event.keycode in [KEY_2, KEY_KP_2]: fire_mode = "Auto"
		var keys = {KEY_3: "ArrowShield", KEY_4: "Harvester", KEY_5: "Shuriken", KEY_6: "SlowDown", KEY_KP_3: "ArrowShield", KEY_KP_4: "Harvester", KEY_KP_5: "Shuriken", KEY_KP_6: "SlowDown"}
		if keys.has(event.keycode): _activate(keys[event.keycode])
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not ended and not suspended:
		if fire_mode in ["Click", "Hold"]: _shoot()
		for weapon in extra_timers:
			if unlocked(weapon) and auxiliary_fire_mode in ["Click", "Hold"]: _shoot(weapon)

func _activate(key: String) -> void:
	if unlocked(key) and abilities[key].cooldown <= 0 and abilities[key].active <= 0:
		abilities[key].active = abilities[key].duration
		audio.sound("ability")

func _physics_process(delta: float) -> void:
	if ended or suspended: return
	elapsed += delta
	row_timer += delta
	shot_timer = maxf(0, shot_timer - delta)
	for weapon in extra_timers: extra_timers[weapon] = maxf(0, extra_timers[weapon] - delta)
	dagger_timer = maxf(0, dagger_timer - delta)
	beam_timer = maxf(0, beam_timer - delta)
	for state in abilities.values():
		if state.active > 0:
			state.active -= delta
			if state.active <= 0: state.cooldown = state.wait
		else:
			state.cooldown = maxf(0, state.cooldown - delta)
	var horizontal = float(Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	var speed = (forward_speed - (0.5 if active("SlowDown") else 0.0)) * (1.5 if running else 1.0)
	var previous = player_position
	player_position.x = clampf(player_position.x + horizontal * s("Horizontal_Speed") * delta, -1.5, 1.5)
	player_position.z -= speed * delta
	for enemy in enemies:
		if enemy.boss and enemy.hp > 0:
			player_position.z = maxf(player_position.z, float(enemy.node.position.z) + 0.75)
	distance += player_position.distance_to(previous)
	camera.position = player_position
	bow.position.y = -0.34 + sin(elapsed * 9) * 0.008
	if -player_position.z >= next_section_trigger:
		section += 1
		next_section_trigger += 20.0
		forward_speed += 0.1333
		_build_section(section + 2)
	if row_timer >= 2.0 - 0.000001:
		row_timer -= 2.0
		var damage = [5.0, 30.0, 100.0, 300.0][int(data.prestige)]
		if armor > 0: damage *= maxf(0, 1.0 - s("Armor_Against_Row") / 100.0)
		_damage_player(damage * (1.5 if running else 1.0))
	var target = _target(s("Distance_Range"))
	crosshair.modulate = Color("8fe6a0") if not target.is_empty() else Color("eadbc5")
	if fire_mode == "Hold" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): _shoot()
	if fire_mode == "Auto" and not target.is_empty(): _shoot()
	for weapon in extra_timers:
		if not unlocked(weapon): continue
		if auxiliary_fire_mode == "Hold" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): _shoot(weapon)
		if auxiliary_fire_mode == "Auto" and not target.is_empty(): _shoot(weapon)
	if unlocked("Dagger") and dagger_timer <= 0:
		var near = _target(s("Melee_range"))
		if not near.is_empty():
			var amount = s("Dagger_Damage")
			if near.effect == "Cursed": amount *= s("Curse_Effect")
			if _roll("Bleed_Chance") and near.effect != "Bleeding":
				amount *= 3
				_effect(near, "Bleeding", s("Burn_Duration"))
			_hit(near, amount + (s("Damage_Against_Bosses") if near.boss else 0.0))
			dagger_timer = 1.0 / maxf(0.01, s("Dagger_Attack_Rate"))
			audio.sound("dagger")
	if unlocked("ThirdEye") and beam_timer <= 0:
		var eye_target = _target(maxf(0.1, s("Distance_Range") - 2.0), true)
		if not eye_target.is_empty():
			var amount = s("Beam_Damage") * (s("Curse_Effect") if eye_target.effect == "Cursed" else 1.0)
			if _roll("Beam_Critic_Chance"): amount += s("Beam_Critic_Multiplier")
			_hit(eye_target, amount)
			beam_timer = 1.0 / maxf(0.01, s("Beam_Fire_Rate"))
	_update_enemies(delta)
	_update_projectiles(delta)
	_update_drops(delta)
	if poison_ticks > 0:
		poison_timer -= delta
		if poison_timer <= 0:
			poison_timer = 1.0
			poison_ticks -= 1
			_damage_player(10.0, true)
	_update_hud()

func _target(reach: float, mouse = false) -> Dictionary:
	var closest: Dictionary = {}
	var best = reach
	for enemy in enemies:
		if enemy.hp <= 0: continue
		var offset: Vector3 = enemy.node.position - player_position
		var ahead = -offset.z
		var aligned = absf(offset.x) < (0.55 if enemy.boss else 0.3)
		if mouse:
			var screen = camera.unproject_position(enemy.node.position)
			aligned = screen.distance_to(get_viewport().get_mouse_position()) < 80
		if ahead > 0 and ahead <= best and aligned:
			closest = enemy
			best = ahead
	return closest

func _shoot(weapon = "Bow") -> void:
	if weapon == "Bow":
		if shot_timer > 0: return
		shot_timer = 1.0 / maxf(0.01, s("Bow_Fire_Rate"))
	else:
		if extra_timers[weapon] > 0: return
		extra_timers[weapon] = 1.0 / maxf(0.01, s("Dragon_Fire_Rate") if weapon == "Dragon" else s("Ghost_Fire_Rate"))
	var types: Array = []
	for i in range(maxi(1, int(s("Amount_Of_Arrows"))) if weapon == "Bow" else 1): types.append("Arrow" if weapon == "Bow" else ("Fire" if weapon == "Dragon" else "Cursed"))
	if unlocked("Dragon"): types.append("Fire")
	if unlocked("Ghost"): types.append("Cursed")
	if active("Shuriken"): types.append("Shuriken")
	types.shuffle()
	var spread = [0.0, 0.0, 2.0, 3.0, 4.0, 5.0, 5.0, 5.0][mini(types.size(), 7)]
	for i in range(types.size()):
		var angle = deg_to_rad(lerpf(-spread / 2.0, spread / 2.0, float(i) / maxf(1, types.size() - 1)))
		var node = _box(self, player_position + Vector3(0, -0.1, -0.4), Vector3(0.04, 0.04, 0.35), Color("f5d594") if types[i] == "Arrow" else Color("ad7fe3"))
		projectiles.append({"node": node, "dir": Vector3(sin(angle), 0, -cos(angle)), "speed": s("Arrow_Speed"), "type": types[i], "life": minf(10.0, s("Distance_Range") / maxf(0.1, s("Arrow_Speed"))), "hostile": false})
	audio.sound("shot")

func _update_projectiles(delta: float) -> void:
	for projectile in projectiles.duplicate():
		var previous: Vector3 = projectile.node.position
		projectile.node.position += projectile.dir * projectile.speed * delta
		projectile.life -= delta
		if projectile.hostile:
			if projectile.node.position.distance_to(player_position) < 0.3:
				if not active("ArrowShield"):
					_damage_player(float([10, 200, 500, 2000][int(data.prestige)]) * (2.0 if projectile.type == "Critical" else 1.0))
					if projectile.type == "LifeSteal": _damage_player(s("HP_Steal"))
					if projectile.type == "Poison":
						poison_hits += 1
						if poison_ticks == 0:
							poison_ticks = 3
							poison_timer = 0
				projectile.life = 0
		else:
			for enemy in enemies.duplicate():
				var pos: Vector3 = enemy.node.position
				if absf(pos.x - projectile.node.position.x) < (0.6 if enemy.boss else 0.3) and pos.z <= previous.z + 0.1 and pos.z >= projectile.node.position.z - 0.4 and enemy.hp > 0:
					_projectile_hit(enemy, projectile.type)
					projectile.life = 0
					break
		if projectile.life <= 0:
			projectiles.erase(projectile)
			projectile.node.queue_free()

func _projectile_hit(enemy: Dictionary, kind: String) -> void:
	var amount = s("Arrow_Damage")
	if kind == "Fire":
		amount = s("FireArrow_Damage")
		if _roll("Burn_Chance") and enemy.effect != "Burning":
			_effect(enemy, "Burning", s("Burn_Duration"))
			amount *= 2.5
	if kind == "Cursed":
		amount = s("CursedArrow_Damage")
		if _roll("Curse_Chance"): _effect(enemy, "Cursed", s("Curse_Duration"))
	if kind == "Shuriken":
		amount = s("FireArrow_Damage") * (3.0 if enemy.effect == "Bleeding" else 1.0)
	if enemy.effect == "Cursed": amount *= s("Curse_Effect")
	if enemy.boss: amount += s("Damage_Against_Bosses")
	if kind == "Arrow" and _roll("Critic_Chance"): amount *= s("Critic_Damage")
	if kind == "Arrow" and _roll("HP_Steal_Chance"):
		amount += s("HP_Steal")
		_heal(s("HP_Steal"))
	if kind == "Arrow" and armor <= 0 and _roll("HealOnHit_Chance"): _heal(s("HealOnHit_Amount"))
	_hit(enemy, amount)

func _effect(enemy: Dictionary, kind: String, duration: float) -> void:
	enemy.effect = kind
	enemy.effect_time = duration
	enemy.tick = 0.0

func _roll(key: String) -> bool:
	return randf() * 100.0 < s(key)

func _hit(enemy: Dictionary, amount: float) -> void:
	if enemy.hp <= 0: return
	enemy.hp -= amount
	enemy.label.text = str(maxi(0, int(ceil(enemy.hp))))
	audio.sound("hit")
	if enemy.hp <= 0:
		run_kills += 1
		var enemy_key = str(int(enemy.kind))
		data.bestiary[enemy_key] = int(data.bestiary.get(enemy_key, 0)) + 1
		if int(enemy.kind) in [4, 5]: data.achievements.FirstMiniBoss = true
		if armor <= 0 and _roll("HealOnKill_Chance"): _heal(s("HealOnKill_Amount"))
		if int(enemy.kind) == 6:
			data.achievements.FirstBoss = true
			data.achievements["RowDiver" if int(data.prestige) == 0 else "Prestige" + str(int(data.prestige))] = true
			if int(data.prestige) == 3:
				data.achievements.BossSlayer = true
				data.achievements.PrestigeMaster = true
			var key = str(int(data.prestige))
			if not data.crowns_dropped.get(key, false):
				coins[2] += 1
				data.crowns_dropped[key] = true
			data.max_prestige = mini(3, maxi(int(data.max_prestige), int(data.prestige) + 1))
			_finish(true)
		else:
			var currency = 1 if int(enemy.kind) in [3, 4, 5] else 0
			var value = 1.0
			if currency == 0: value = [1.0, 10.0, 100.0, 1000.0][int(data.prestige)]
			var node = _box(self, enemy.node.position, Vector3(0.16, 0.16, 0.16), Color("eeb34c") if currency == 0 else Color("ad8de8"))
			drops.append({"node": node, "currency": currency, "value": value})
		enemies.erase(enemy)
		enemy.node.queue_free()

func _update_enemies(delta: float) -> void:
	for enemy in enemies.duplicate():
		if enemy.hp <= 0: continue
		if enemy.effect_time > 0:
			enemy.effect_time -= delta
			enemy.tick += delta
			if enemy.effect_time <= 0: enemy.effect = ""
		var offset: Vector3 = enemy.node.position - player_position
		if int(enemy.kind) == 3:
			enemy.node.position.z += 0.5 * delta
		if enemy.boss:
			enemy.next_shot -= delta
			if enemy.next_shot <= 0 and offset.z < 0 and offset.z > -20:
				enemy.next_shot = 2.0
				for angle in [-7.5, 0.0, 7.5] if enemy.boss else [0.0]:
					var node = _box(self, enemy.node.position, Vector3(0.07, 0.07, 0.25), Color("dd617b"))
					projectiles.append({"node": node, "dir": Vector3(sin(deg_to_rad(angle)), 0, cos(deg_to_rad(angle))), "speed": 4.0, "type": "Poison" if int(enemy.kind) == 4 else ("LifeSteal" if int(enemy.kind) == 5 else "Critical"), "life": 2.0, "hostile": true})
		if not enemy.contact and absf(offset.z) < 0.4 and absf(offset.x) < 0.5:
			enemy.contact = true
			var reflected = float(enemy.base_hp) * s("Porcupine_Damage") / 100.0
			if enemy.hp <= reflected:
				_hit(enemy, reflected)
				continue
			var damage = float([50, 500, 1000, 3000][int(data.prestige)]) * (2.0 if int(enemy.kind) == 2 else 1.0)
			if enemy.boss: damage = 100000.0
			_damage_player(maxf(0, damage * (1 - s("Impact_Armor") / 100.0)))
		if offset.z > 15:
			enemies.erase(enemy)
			enemy.node.queue_free()

func _update_drops(delta: float) -> void:
	for drop in drops.duplicate():
		var gap = drop.node.position.distance_to(player_position)
		if gap <= s("PickupRange"):
			drop.node.position = drop.node.position.lerp(player_position, minf(1, delta * 5.0))
			if gap < 0.15:
				coins[drop.currency] += float(drop.value) * (2.0 if active("Harvester") and drop.currency != 2 else 1.0)
				audio.sound("coin")
				drop.node.queue_free()
				drops.erase(drop)
		elif drop.node.position.z > player_position.z + 15:
			drop.node.queue_free()
			drops.erase(drop)

func _damage_player(amount: float, ignore_armor = false) -> void:
	if ended: return
	if not ignore_armor and armor > 0:
		var absorbed = minf(armor, amount)
		armor -= absorbed
		amount -= absorbed
	health = maxf(0, health - amount)
	if health <= 0: _finish(false)

func _heal(amount: float) -> void:
	health = minf(s("MaxHP"), health + amount)

func _finish(won: bool) -> void:
	if ended: return
	ended = true
	data.runs += 1
	data.kills += run_kills
	data.best_distance = maxf(float(data.best_distance), distance)
	for i in range(3): data.wallet[i] += coins[i]
	if persist_results: Progress.save_data(data)
	overlay_title.text = ("ROW CLEARED" if won else "RUN ENDED") + "\n\nDistance %.1f m  •  Kills %d\nGold %s  •  Gems %s  •  Crowns %s" % [distance, run_kills, str(coins[0]), str(coins[1]), str(coins[2])]
	resume.hide()
	retry.show()
	overlay.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _update_hud() -> void:
	hud.text = "HP %.0f / %.0f    Armor %.0f\n%.1f m  •  Section %d  •  %s\nGold %s   Gems %s   %s" % [health, s("MaxHP"), armor, distance, section, "RUNNING" if running else "WALKING", str(coins[0]), str(coins[1]), fire_mode]
	var text = ""
	var key = 3
	for name in ["ArrowShield", "Harvester", "Shuriken", "SlowDown"]:
		if unlocked(name):
			var state = abilities[name]
			text += "%d %s: %s   " % [key, name, ("Active %.1f" % state.active) if state.active > 0 else (("%.0fs" % state.cooldown) if state.cooldown > 0 else "Ready")]
		key += 1
	ability_hud.text = text
