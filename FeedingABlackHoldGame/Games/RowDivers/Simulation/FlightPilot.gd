extends RefCounted
## Bounded observation-based player: no future layouts, RNG or projectile immunity.
var rng = RandomNumberGenerator.new()
var reaction = 0.18
var aim_error = 0.012
var timer = 0.0
var target_x = 0.0
var aim = Vector3.FORWARD
var desired_aim = Vector3.FORWARD
var target: Dictionary = {}
var previous_positions: Dictionary = {}
var decisions = 0
var shots = 0
var shot_clock = 0.0

func setup(initial_seed: int, options: Dictionary) -> void:
	rng.seed = initial_seed
	reaction = float(options.get("reaction", 0.18))
	aim_error = float(options.get("aim_error", 0.012))

func step(battle, delta: float) -> void:
	timer -= delta
	shot_clock -= delta
	if timer <= 0:
		timer += reaction
		decisions += 1
		plan(battle)
	var separation = target_x - battle.player_position.x
	var command = 0.0 if absf(separation) < 0.06 else signf(separation)
	battle.horizontal_override = battle._advance_horizontal_axis(command, delta)
	aim = aim.slerp(desired_aim, minf(1, 5.0 * delta / maxf(0.01, aim.angle_to(desired_aim)))).normalized()
	battle.aim_override = aim
	battle.fire_override = shot_clock <= 0
	if battle.fire_override:
		shot_clock = 1.0 / 6.0 # Six human clicks/sec; weapon cooldown still applies.
		shots += 1
	battle.auto_abilities_override = true

func plan(battle) -> void:
	var player: Vector3 = battle.player_position
	var speed: float = battle.s("Horizontal_Speed")
	var forward: float = maxf(0.1, battle.forward_speed)
	var candidates = [-1.5, -0.75, 0.0, 0.75, 1.5, target_x]
	for wave in battle.fire_waves.waves: candidates.append(wave.gap_x)
	var nearby: Array = []
	for enemy in battle.enemies:
		var offset: Vector3 = enemy.node.position - player
		if enemy.hp > 0 and offset.z < 1.0 and offset.z > -15.0: nearby.append(enemy)
	var incoming: Array = []
	for bullet in battle.projectiles:
		if bullet.hostile and bullet.node.position.z < player.z: incoming.append(bullet)
	var desired_drop: Dictionary = {}
	var closest_drop = 8.0
	for drop in battle.drops:
		var ahead = player.z - drop.node.position.z
		if ahead > -0.2 and ahead < closest_drop:
			closest_drop = ahead
			desired_drop = drop
	var best = INF
	for x in candidates:
		var score = absf(x - player.x) * 0.15
		for wave in battle.fire_waves.waves:
			var time = (player.z - wave.z) / (wave.speed + forward)
			if time < 0 or time > 3.2: continue
			var future = move_toward(player.x, x, speed * maxf(0, time - 0.20))
			var miss = maxf(0, absf(future - wave.gap_x) - (wave.gap_width * 0.5 - 0.31))
			score += (14.0 if miss > 0 else 0.0) / maxf(0.3, time) + miss * 5.0
		for bullet in incoming:
			var closing = bullet.dir.z * bullet.speed + forward
			if closing <= 0: continue
			var time = (player.z - bullet.node.position.z) / closing
			if time < 0 or time > 1.6: continue
			var y = bullet.node.position.y + bullet.dir.y * bullet.speed * time
			if absf(y - player.y) > 0.45: continue
			var bx = bullet.node.position.x + bullet.dir.x * bullet.speed * time
			var future = move_toward(player.x, x, speed * maxf(0, time - 0.2))
			score += maxf(0, 0.46 - absf(future - bx)) * 15.0 / maxf(0.3, time)
		for enemy in nearby:
			if enemy.kind == 7 or enemy.contact: continue
			var ahead = player.z - enemy.node.position.z
			if ahead > 3: continue
			score += maxf(0, 0.75 - absf(x - enemy.node.position.x)) * 3.0
		if not desired_drop.is_empty():
			score += minf(2, absf(x - desired_drop.node.position.x)) * (2.5 if desired_drop.currency == 1 else 1.5)
		elif not target.is_empty() and is_instance_valid(target.node):
			score += absf(x - target.node.position.x) * 0.30
		if score < best:
			best = score
			target_x = x
	var best_target = -INF
	var selected: Dictionary = {}
	for enemy in nearby:
		var offset: Vector3 = enemy.node.position - player
		if offset.length() > battle.s("Distance_Range"): continue
		var view: Vector3 = enemy.node.position - battle._aim_origin()
		if view.z >= -0.3 or absf(view.y) > -view.z * 0.63 or absf(view.x) > -view.z * 1.12: continue
		var priority = 15.0 / maxf(1, offset.length())
		if enemy.boss: priority += 1.5
		if enemy.kind == 7: priority += 0.6
		if enemy == target: priority += 1.0
		if priority > best_target:
			best_target = priority
			selected = enemy
	target = selected
	if not target.is_empty():
		var position: Vector3 = target.node.position
		var key = target.node.get_instance_id()
		var velocity: Vector3 = (position - previous_positions.get(key, position)) / reaction
		var travel = minf(0.5, position.distance_to(player) / maxf(1, battle.s("Arrow_Speed")))
		var point = position + velocity.limit_length(2) * travel
		desired_aim = (point - battle._aim_origin()).normalized()
		desired_aim = desired_aim.rotated(Vector3.UP, rng.randf_range(-aim_error, aim_error)).rotated(Vector3.RIGHT, rng.randf_range(-aim_error, aim_error))
		previous_positions[key] = position
	else: desired_aim = Vector3.FORWARD
