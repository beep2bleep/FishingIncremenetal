extends "res://Games/RowDivers/Simulation/FlightPilot.gd"
## Trailer-only human-like input. No changes to normal gameplay controls.
var clock = 0.0
var smooth_aim = Vector3.FORWARD
var steering_reason = "cruise"
var fire_decisions = 0
var loot_decisions = 0
func step(battle, delta: float) -> void:
	clock += delta
	super.step(battle, delta)
	# Limited angular speed and lag persist across target changes.
	var angle = smooth_aim.angle_to(desired_aim)
	smooth_aim = smooth_aim.slerp(desired_aim, minf(1.0, 0.95 * delta / maxf(angle, 0.001))).normalized()
	battle.aim_override = smooth_aim.rotated(Vector3.UP, sin(clock * 3.1) * 0.018).rotated(Vector3.RIGHT, sin(clock * 2.3) * 0.009)
	battle.pointer_override = battle.camera.unproject_position(battle._aim_origin() + battle.aim_override * maxf(1, battle.s("Distance_Range")))
	# Follow the chosen safe gap/loot lane fully; decorative sway used to pull
	# the player back out of safe gaps and away from pickups.
	var separation = target_x - battle.player_position.x
	var command = clampf(separation * 3.0, -1.0, 1.0)
	if absf(separation) < 0.035: command = 0.0
	battle.horizontal_override = battle._advance_horizontal_axis(command, delta)
	battle.fire_override = battle.fire_override and not target.is_empty()

func plan(battle) -> void:
	super.plan(battle) # Retain reactive target selection and imperfect shooting.
	var player: Vector3 = battle.player_position
	var speed: float = battle.s("Horizontal_Speed")
	var forward: float = maxf(0.1, battle.forward_speed)
	var width: float = battle.corridor_width * preload("res://Games/RowDivers/RowDiversHallway.gd").width_scale(player.z)
	var limit = 1.22 * width
	var candidates: Array = [player.x, -limit, -limit*0.5, 0.0, limit*0.5, limit]
	var hazards: Array = []
	for wave in battle.fire_waves.waves:
		var arrival: float = (player.z-wave.z) / (wave.speed+forward)
		if arrival <= 0 or arrival > 3.4: continue
		hazards.append({"wave":wave,"arrival":arrival})
		candidates.append(clampf(wave.gap_x,-limit,limit))
		var margin: float = maxf(0.0, wave.gap_width*0.5-0.40)
		candidates.append(clampf(wave.gap_x-margin,-limit,limit))
		candidates.append(clampf(wave.gap_x+margin,-limit,limit))
	var loot: Array = []
	for drop in battle.drops:
		var ahead: float = player.z-drop.node.position.z
		if ahead < -0.4 or ahead > 8.0: continue
		loot.append(drop)
		candidates.append(clampf(drop.node.position.x,-limit,limit))
	var best = INF
	for x in candidates:
		var score: float = absf(x-player.x)*0.12
		for hazard in hazards:
			var wave: Dictionary = hazard.wave
			var future: float = move_toward(player.x,x,speed*maxf(0,hazard.arrival-0.30))
			var miss: float = maxf(0, absf(future-wave.gap_x)-(wave.gap_width*0.5-0.38))
			score += (80.0+miss*100.0)/maxf(0.35,hazard.arrival) if miss>0 else 0.0
		for bullet in battle.projectiles:
			if not bullet.hostile: continue
			var closing: float = bullet.dir.z*bullet.speed+forward
			if closing <= 0: continue
			var arrival: float = (player.z-bullet.node.position.z)/closing
			if arrival <= 0 or arrival > 1.8: continue
			var future: float = move_toward(player.x,x,speed*maxf(0,arrival-0.25))
			var bx: float = bullet.node.position.x+bullet.dir.x*bullet.speed*arrival
			score += maxf(0,0.5-absf(future-bx))*25.0/maxf(0.25,arrival)
		var attraction = 0.0
		for drop in loot:
			var ahead: float = maxf(0.1,player.z-drop.node.position.z)
			var future: float = move_toward(player.x,x,speed*maxf(0,ahead/forward-0.25))
			var proximity: float = maxf(0,1.0-absf(future-drop.node.position.x)/1.5)
			attraction = maxf(attraction,proximity*(5.0 if int(drop.currency)==0 else 6.0)/maxf(1.0,ahead*0.4))
		score -= attraction
		if score < best:
			best = score
			target_x = x
	steering_reason = "fire" if not hazards.is_empty() else ("loot" if not loot.is_empty() else "cruise")
	if steering_reason == "fire": fire_decisions += 1
	elif steering_reason == "loot": loot_decisions += 1
