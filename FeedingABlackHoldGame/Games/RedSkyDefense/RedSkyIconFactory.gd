extends RefCounted
class_name RedSkyIconFactory

static var _cache: Dictionary = {}

static func get_icon(icon_id: String) -> Texture2D:
	if _cache.has(icon_id):
		return _cache[icon_id]

	var image := Image.create(80, 80, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var key: String = icon_id.replace("redsky://", "")
	var palette: Dictionary = _palette_for_key(key)
	var frame: Color = palette.get("frame", Color(0.92, 0.84, 0.66, 1.0))
	var fill: Color = palette.get("fill", Color(0.2, 0.12, 0.12, 1.0))
	var accent: Color = palette.get("accent", Color(1.0, 0.74, 0.44, 1.0))

	_draw_rect(image, Rect2i(8, 8, 64, 64), fill)
	_draw_border(image, Rect2i(8, 8, 64, 64), frame, 3)
	_draw_rect(image, Rect2i(16, 16, 48, 48), Color(fill.r * 0.82, fill.g * 0.82, fill.b * 0.82, 1.0))
	_draw_symbol(image, key, frame, accent)

	var texture := ImageTexture.create_from_image(image)
	_cache[icon_id] = texture
	return texture

static func _palette_for_key(key: String) -> Dictionary:
	if key in ["command_armor", "shield_array", "shield_relay", "emergency_bulkheads", "repair_crews", "tentacle_vat", "tentacle_spines", "tentacle_reach", "engineer_crew", "tactical_briefing", "overclock_protocol", "armor_patch", "shield_boost", "shield_relay_burst", "tentacle_pod", "serrated_tentacles", "grasping_reach", "reinforced_plating", "field_repairs", "shield_capacitors", "battery_loop", "brood_nest", "tendon_network"]:
		return {"frame": Color(0.94, 0.78, 0.63, 1.0), "fill": Color(0.19, 0.1, 0.1, 1.0), "accent": Color(0.92, 0.36, 0.28, 1.0)}
	if key in ["damage_uplink", "rapid_loader", "tracking_array", "capacitor_bank", "high_energy_cells", "focused_barrels", "cooling_jackets", "seeker_ammo", "piercing_rounds", "shrapnel_rounds", "capacitor_overdrive", "critical_mass", "command_overclock", "ammo_hoppers"]:
		return {"frame": Color(0.96, 0.88, 0.62, 1.0), "fill": Color(0.16, 0.12, 0.08, 1.0), "accent": Color(1.0, 0.76, 0.18, 1.0)}
	if key in ["reserve_nukes", "bigger_blasts", "fusion_payload", "piercing_rifling", "blast_chambers", "reserve_nuke_pick", "fusion_warhead", "blast_shells", "warhead_racks"]:
		return {"frame": Color(0.98, 0.82, 0.56, 1.0), "fill": Color(0.18, 0.1, 0.07, 1.0), "accent": Color(1.0, 0.48, 0.22, 1.0)}
	if key in ["tower_fabrication", "tower_targeting", "tower_cooling", "reflector_grid", "signal_decoder", "flak_turret", "tower_overclock", "tower_autoloader", "reflector_pylon", "drone_hangar", "drone_ai", "drone_flight_pack", "interceptor_drone", "drone_firmware", "drone_afterburners", "sweep_drones", "flak_wall", "tower_rangefinder", "drone_swarm", "hunter_link", "command_node"]:
		return {"frame": Color(0.8, 0.92, 1.0, 1.0), "fill": Color(0.08, 0.13, 0.16, 1.0), "accent": Color(0.36, 0.88, 0.98, 1.0)}
	if key in ["magnet_array", "salvage_bays", "scrap_ledgers", "contract_bounties", "recovery_barges", "salvage_markets", "profit_directive", "salvage_burst", "magnet_sweep", "bounty_contracts", "claim_adjusters", "recovery_net", "scavenger_grid", "salvage_convoys", "magnetic_funnels", "refinement_protocols"]:
		return {"frame": Color(0.99, 0.92, 0.68, 1.0), "fill": Color(0.15, 0.12, 0.07, 1.0), "accent": Color(0.98, 0.78, 0.26, 1.0)}
	return {"frame": Color(0.8, 0.92, 1.0, 1.0), "fill": Color(0.08, 0.13, 0.16, 1.0), "accent": Color(0.36, 0.88, 0.98, 1.0)}

static func _draw_symbol(image: Image, key: String, frame: Color, accent: Color) -> void:
	match key:
		"command_armor":
			_draw_shield(image, Vector2i(40, 40), 18, frame)
		"shield_array":
			_draw_ring(image, Vector2i(40, 40), 20, 4, accent)
		"shield_relay":
			_draw_arc_band(image, Vector2i(40, 40), 12, 20, -0.9, 0.9, accent)
			_draw_arc_band(image, Vector2i(40, 40), 20, 28, -0.9, 0.9, frame)
		"emergency_bulkheads":
			_draw_rect(image, Rect2i(22, 24, 36, 10), accent)
			_draw_rect(image, Rect2i(18, 40, 44, 14), frame)
		"repair_crews":
			_draw_rect(image, Rect2i(35, 22, 10, 36), accent)
			_draw_rect(image, Rect2i(22, 35, 36, 10), accent)
			_draw_circle(image, Vector2i(56, 24), 5, frame)
		"armor_patch":
			_draw_rect(image, Rect2i(35, 22, 10, 36), accent)
			_draw_rect(image, Rect2i(22, 35, 36, 10), accent)
		"damage_uplink":
			_draw_target(image, accent, frame)
		"focused_barrels":
			_draw_bullet(image, Vector2i(32, 50), accent)
			_draw_bullet(image, Vector2i(48, 34), frame)
		"rapid_loader":
			_draw_bullet(image, Vector2i(25, 50), accent)
			_draw_bullet(image, Vector2i(40, 40), frame)
			_draw_bullet(image, Vector2i(55, 30), accent)
		"cooling_jackets":
			_draw_fan(image, accent, frame)
		"seeker_ammo":
			_draw_target(image, frame, accent)
			_draw_bullet(image, Vector2i(50, 30), accent)
		"tracking_array":
			_draw_ring(image, Vector2i(40, 40), 18, 3, frame)
			_draw_line(image, Vector2i(40, 40), Vector2i(57, 27), accent, 3)
		"capacitor_bank":
			_draw_rect(image, Rect2i(22, 24, 28, 30), frame)
			_draw_rect(image, Rect2i(52, 32, 6, 14), frame)
			_draw_rect(image, Rect2i(26, 28, 8, 22), accent)
			_draw_rect(image, Rect2i(36, 28, 8, 22), accent)
		"high_energy_cells":
			_draw_lightning(image, accent)
		"capacitor_overdrive":
			_draw_rect(image, Rect2i(22, 24, 28, 30), frame)
			_draw_rect(image, Rect2i(52, 32, 6, 14), frame)
			_draw_lightning(image, accent)
		"critical_mass":
			_draw_ring(image, Vector2i(40, 40), 16, 3, accent)
			_draw_blast(image, frame, accent)
		"reserve_nukes":
			_draw_missile(image, accent, frame)
		"reserve_nuke_pick":
			_draw_missile(image, accent, frame)
		"bigger_blasts":
			_draw_blast(image, accent, frame)
		"blast_shells":
			_draw_blast(image, accent, frame)
		"fusion_payload":
			_draw_atom(image, accent, frame)
		"fusion_warhead":
			_draw_atom(image, accent, frame)
			_draw_missile(image, frame, accent)
		"piercing_rifling":
			_draw_spear(image, accent, frame)
		"piercing_rounds":
			_draw_spear(image, accent, frame)
		"blast_chambers":
			_draw_shell(image, accent, frame)
		"shrapnel_rounds":
			_draw_shell(image, accent, frame)
		"tower_fabrication", "tower_targeting":
			_draw_turret(image, accent, frame)
			if key == "tower_targeting":
				_draw_target(image, frame, accent)
		"flak_turret":
			_draw_turret(image, accent, frame)
		"tower_overclock":
			_draw_turret(image, accent, frame)
			_draw_lightning(image, frame)
		"tower_cooling":
			_draw_fan(image, accent, frame)
		"tower_autoloader":
			_draw_turret(image, accent, frame)
			_draw_fan(image, frame, accent)
		"reflector_grid":
			_draw_bounce(image, accent, frame)
		"reflector_pylon":
			_draw_bounce(image, accent, frame)
		"signal_decoder":
			_draw_radio(image, accent, frame)
		"drone_hangar", "drone_ai", "drone_flight_pack", "interceptor_drone", "drone_firmware", "drone_afterburners", "sweep_drones":
			_draw_drone(image, accent, frame)
			if key == "drone_ai" or key == "drone_firmware":
				_draw_circle(image, Vector2i(40, 40), 5, frame)
			elif key == "drone_flight_pack" or key == "drone_afterburners":
				_draw_line(image, Vector2i(24, 34), Vector2i(16, 24), frame, 3)
				_draw_line(image, Vector2i(56, 34), Vector2i(64, 24), frame, 3)
			elif key == "sweep_drones":
				_draw_crate(image, frame, accent)
		"magnet_array":
			_draw_magnet(image, accent, frame)
		"salvage_bays", "salvage_burst":
			_draw_crate(image, accent, frame)
		"scrap_ledgers":
			_draw_crate(image, accent, frame)
			_draw_line(image, Vector2i(24, 18), Vector2i(56, 18), frame, 2)
			_draw_line(image, Vector2i(24, 26), Vector2i(56, 26), frame, 2)
		"contract_bounties", "bounty_contracts":
			_draw_crate(image, accent, frame)
			_draw_clock(image, frame, accent)
		"recovery_barges", "claim_adjusters":
			_draw_crate(image, accent, frame)
			_draw_magnet(image, frame, accent)
		"salvage_markets", "recovery_net":
			_draw_crate(image, accent, frame)
			_draw_radio(image, frame, accent)
		"profit_directive", "scavenger_grid":
			_draw_crate(image, accent, frame)
			_draw_lightning(image, frame)
		"magnet_sweep":
			_draw_magnet(image, accent, frame)
		"tentacle_vat", "tentacle_spines", "tentacle_reach":
			_draw_tentacle(image, accent, frame)
			if key == "tentacle_spines":
				_draw_line(image, Vector2i(44, 44), Vector2i(56, 26), frame, 2)
			elif key == "tentacle_reach":
				_draw_circle(image, Vector2i(58, 22), 5, frame)
		"shield_boost":
			_draw_ring(image, Vector2i(40, 40), 20, 4, accent)
		"shield_relay_burst":
			_draw_arc_band(image, Vector2i(40, 40), 12, 20, -0.9, 0.9, accent)
			_draw_arc_band(image, Vector2i(40, 40), 20, 28, -0.9, 0.9, frame)
		"tentacle_pod":
			_draw_tentacle(image, accent, frame)
		"serrated_tentacles":
			_draw_tentacle(image, accent, frame)
			_draw_line(image, Vector2i(44, 44), Vector2i(56, 26), frame, 2)
		"grasping_reach":
			_draw_tentacle(image, accent, frame)
			_draw_circle(image, Vector2i(58, 22), 5, frame)
		"engineer_crew":
			_draw_tool(image, accent, frame)
		"tactical_briefing":
			_draw_radio(image, accent, frame)
			_draw_rect(image, Rect2i(22, 22, 10, 10), frame)
			_draw_rect(image, Rect2i(37, 22, 10, 10), accent)
			_draw_rect(image, Rect2i(52, 22, 10, 10), frame)
		"overclock_protocol":
			_draw_clock(image, accent, frame)
			_draw_lightning(image, frame)
		_:
			_draw_circle(image, Vector2i(40, 40), 16, accent)

static func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x, y, color)

static func _draw_border(image: Image, rect: Rect2i, color: Color, thickness: int) -> void:
	for offset in range(thickness):
		_draw_rect(image, Rect2i(rect.position.x + offset, rect.position.y + offset, rect.size.x - offset * 2, 1), color)
		_draw_rect(image, Rect2i(rect.position.x + offset, rect.position.y + rect.size.y - 1 - offset, rect.size.x - offset * 2, 1), color)
		_draw_rect(image, Rect2i(rect.position.x + offset, rect.position.y + offset, 1, rect.size.y - offset * 2), color)
		_draw_rect(image, Rect2i(rect.position.x + rect.size.x - 1 - offset, rect.position.y + offset, 1, rect.size.y - offset * 2), color)

static func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var dx: int = x - center.x
			var dy: int = y - center.y
			if dx * dx + dy * dy <= radius * radius and x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x, y, color)

static func _draw_ring(image: Image, center: Vector2i, radius: int, thickness: int, color: Color) -> void:
	var outer_sq: int = radius * radius
	var inner: int = max(radius - thickness, 0)
	var inner_sq: int = inner * inner
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var dx: int = x - center.x
			var dy: int = y - center.y
			var dist_sq: int = dx * dx + dy * dy
			if dist_sq <= outer_sq and dist_sq >= inner_sq and x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x, y, color)

static func _draw_line(image: Image, from: Vector2i, to: Vector2i, color: Color, thickness: int = 1) -> void:
	var steps: int = maxi(abs(to.x - from.x), abs(to.y - from.y))
	if steps <= 0:
		_draw_circle(image, from, thickness, color)
		return
	for i in range(steps + 1):
		var t: float = float(i) / float(steps)
		var pos := Vector2i(
			int(round(lerpf(float(from.x), float(to.x), t))),
			int(round(lerpf(float(from.y), float(to.y), t)))
		)
		_draw_circle(image, pos, max(1, thickness), color)

static func _draw_triangle(image: Image, a: Vector2i, b: Vector2i, c: Vector2i, color: Color) -> void:
	var min_x: int = mini(a.x, mini(b.x, c.x))
	var max_x: int = maxi(a.x, maxi(b.x, c.x))
	var min_y: int = mini(a.y, mini(b.y, c.y))
	var max_y: int = maxi(a.y, maxi(b.y, c.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if _point_in_triangle(Vector2(float(x), float(y)), Vector2(a), Vector2(b), Vector2(c)):
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

static func _point_in_triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var area: float = absf((b - a).cross(c - a))
	var area1: float = absf((a - p).cross(b - p))
	var area2: float = absf((b - p).cross(c - p))
	var area3: float = absf((c - p).cross(a - p))
	return absf(area - (area1 + area2 + area3)) <= 0.5

static func _draw_shield(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	_draw_triangle(image, center + Vector2i(-radius, -radius / 2), center + Vector2i(radius, -radius / 2), center + Vector2i(0, radius + 6), color)
	_draw_circle(image, center + Vector2i(0, -2), radius - 5, Color(0, 0, 0, 0))

static func _draw_arc_band(image: Image, center: Vector2i, inner_radius: int, outer_radius: int, start_angle: float, end_angle: float, color: Color) -> void:
	for x in range(center.x - outer_radius, center.x + outer_radius + 1):
		for y in range(center.y - outer_radius, center.y + outer_radius + 1):
			var px: float = float(x - center.x)
			var py: float = float(y - center.y)
			var angle: float = atan2(py, px)
			var dist_sq: float = px * px + py * py
			if angle >= start_angle and angle <= end_angle and dist_sq >= float(inner_radius * inner_radius) and dist_sq <= float(outer_radius * outer_radius):
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

static func _draw_target(image: Image, accent: Color, frame: Color) -> void:
	_draw_ring(image, Vector2i(40, 40), 16, 2, accent)
	_draw_line(image, Vector2i(40, 18), Vector2i(40, 62), frame, 2)
	_draw_line(image, Vector2i(18, 40), Vector2i(62, 40), frame, 2)

static func _draw_bullet(image: Image, center: Vector2i, color: Color) -> void:
	_draw_rect(image, Rect2i(center.x - 3, center.y - 8, 6, 14), color)
	_draw_triangle(image, center + Vector2i(-4, -8), center + Vector2i(4, -8), center + Vector2i(0, -16), color)

static func _draw_lightning(image: Image, color: Color) -> void:
	_draw_triangle(image, Vector2i(34, 18), Vector2i(50, 18), Vector2i(40, 38), color)
	_draw_triangle(image, Vector2i(30, 42), Vector2i(44, 42), Vector2i(34, 62), color)
	_draw_rect(image, Rect2i(36, 28, 8, 20), color)

static func _draw_missile(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(34, 18, 12, 34), accent)
	_draw_triangle(image, Vector2i(34, 18), Vector2i(46, 18), Vector2i(40, 8), frame)
	_draw_triangle(image, Vector2i(34, 44), Vector2i(26, 54), Vector2i(34, 54), frame)
	_draw_triangle(image, Vector2i(46, 44), Vector2i(54, 54), Vector2i(46, 54), frame)

static func _draw_blast(image: Image, accent: Color, frame: Color) -> void:
	_draw_circle(image, Vector2i(40, 40), 10, accent)
	for point in [Vector2i(40, 16), Vector2i(56, 24), Vector2i(62, 40), Vector2i(56, 56), Vector2i(40, 64), Vector2i(24, 56), Vector2i(18, 40), Vector2i(24, 24)]:
		_draw_line(image, Vector2i(40, 40), point, frame, 2)

static func _draw_atom(image: Image, accent: Color, frame: Color) -> void:
	_draw_ring(image, Vector2i(40, 40), 7, 5, accent)
	_draw_arc_band(image, Vector2i(40, 40), 18, 20, -1.1, 2.1, frame)
	_draw_arc_band(image, Vector2i(40, 40), 18, 20, 2.2, 5.3, frame)
	_draw_arc_band(image, Vector2i(40, 40), 22, 24, -0.2, 3.0, frame)

static func _draw_spear(image: Image, accent: Color, frame: Color) -> void:
	_draw_line(image, Vector2i(22, 56), Vector2i(56, 22), frame, 2)
	_draw_triangle(image, Vector2i(54, 18), Vector2i(62, 26), Vector2i(48, 32), accent)

static func _draw_shell(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(30, 20, 20, 28), accent)
	_draw_triangle(image, Vector2i(30, 20), Vector2i(50, 20), Vector2i(40, 8), frame)
	_draw_blast(image, frame, accent)

static func _draw_turret(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(24, 44, 32, 12), accent)
	_draw_rect(image, Rect2i(32, 30, 16, 14), frame)
	_draw_line(image, Vector2i(40, 34), Vector2i(58, 24), frame, 2)

static func _draw_fan(image: Image, accent: Color, frame: Color) -> void:
	_draw_circle(image, Vector2i(40, 40), 5, frame)
	_draw_triangle(image, Vector2i(40, 24), Vector2i(46, 38), Vector2i(34, 38), accent)
	_draw_triangle(image, Vector2i(56, 40), Vector2i(42, 46), Vector2i(42, 34), accent)
	_draw_triangle(image, Vector2i(40, 56), Vector2i(34, 42), Vector2i(46, 42), accent)

static func _draw_bounce(image: Image, accent: Color, frame: Color) -> void:
	_draw_line(image, Vector2i(20, 54), Vector2i(34, 40), frame, 3)
	_draw_line(image, Vector2i(34, 40), Vector2i(56, 40), accent, 3)
	_draw_line(image, Vector2i(56, 40), Vector2i(46, 24), frame, 3)

static func _draw_radio(image: Image, accent: Color, frame: Color) -> void:
	_draw_line(image, Vector2i(24, 48), Vector2i(56, 48), accent, 3)
	_draw_arc_band(image, Vector2i(40, 48), 10, 12, -2.4, -0.8, frame)
	_draw_arc_band(image, Vector2i(40, 48), 18, 20, -2.45, -0.75, frame)

static func _draw_drone(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(30, 34, 20, 12), accent)
	_draw_line(image, Vector2i(18, 30), Vector2i(30, 38), frame, 2)
	_draw_line(image, Vector2i(62, 30), Vector2i(50, 38), frame, 2)
	_draw_circle(image, Vector2i(18, 30), 4, frame)
	_draw_circle(image, Vector2i(62, 30), 4, frame)

static func _draw_magnet(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(24, 18, 12, 36), accent)
	_draw_rect(image, Rect2i(44, 18, 12, 36), accent)
	_draw_rect(image, Rect2i(24, 18, 32, 10), frame)

static func _draw_crate(image: Image, accent: Color, frame: Color) -> void:
	_draw_rect(image, Rect2i(22, 22, 36, 36), accent)
	_draw_border(image, Rect2i(22, 22, 36, 36), frame, 2)
	_draw_line(image, Vector2i(22, 22), Vector2i(58, 58), frame, 2)
	_draw_line(image, Vector2i(58, 22), Vector2i(22, 58), frame, 2)

static func _draw_tentacle(image: Image, accent: Color, frame: Color) -> void:
	_draw_line(image, Vector2i(24, 54), Vector2i(32, 42), accent, 3)
	_draw_line(image, Vector2i(32, 42), Vector2i(40, 38), accent, 3)
	_draw_line(image, Vector2i(40, 38), Vector2i(52, 26), frame, 3)
	_draw_circle(image, Vector2i(56, 22), 4, frame)

static func _draw_tool(image: Image, accent: Color, frame: Color) -> void:
	_draw_line(image, Vector2i(24, 54), Vector2i(52, 26), accent, 3)
	_draw_circle(image, Vector2i(22, 56), 5, frame)
	_draw_rect(image, Rect2i(48, 20, 12, 10), frame)

static func _draw_clock(image: Image, accent: Color, frame: Color) -> void:
	_draw_ring(image, Vector2i(40, 40), 18, 3, accent)
	_draw_line(image, Vector2i(40, 40), Vector2i(40, 26), frame, 2)
	_draw_line(image, Vector2i(40, 40), Vector2i(50, 46), frame, 2)
