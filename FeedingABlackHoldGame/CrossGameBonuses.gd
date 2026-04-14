extends RefCounted
class_name CrossGameBonuses

const SAVE_PATH := "user://cross_game_bonuses_v1.json"
const MAX_BONUS_TIER := 3
const BONUS_MULT_PER_TIER := 0.5
const CROSS_NODE_KEY_PREFIX := "cross_bonus_"
const CROSS_NODE_COSTS := [1, 2, 3]
const CROSS_NODE_CELL_BY_TARGET := {
	Util.ACTIVE_GAME_VANGUARD: Vector2(0, -6),
	Util.ACTIVE_GAME_MINING: Vector2(4, -1),
	Util.ACTIVE_GAME_RED_SKY: Vector2(-2, 0),
	Util.ACTIVE_GAME_TURKEY: Vector2(-4, 4),
	Util.ACTIVE_GAME_REEL_INTO_DARKNESS: Vector2(4, -4),
}
const CURRENCY_ORDER := [
	Util.ACTIVE_GAME_VANGUARD,
	Util.ACTIVE_GAME_MINING,
	Util.ACTIVE_GAME_RED_SKY,
	Util.ACTIVE_GAME_TURKEY,
	Util.ACTIVE_GAME_REEL_INTO_DARKNESS,
]
const CURRENCY_DATA := {
	Util.ACTIVE_GAME_VANGUARD: {
		"code": "V",
		"name": "Vanguard",
		"color": Color(0.72, 0.42, 1.0, 1.0),
		"dark": Color(0.27, 0.11, 0.4, 1.0),
	},
	Util.ACTIVE_GAME_MINING: {
		"code": "D",
		"name": "Deepcore",
		"color": Color(0.28, 0.9, 0.42, 1.0),
		"dark": Color(0.07, 0.27, 0.12, 1.0),
	},
	Util.ACTIVE_GAME_RED_SKY: {
		"code": "R",
		"name": "Red Sky Defense",
		"color": Color(0.95, 0.28, 0.24, 1.0),
		"dark": Color(0.38, 0.08, 0.08, 1.0),
	},
	Util.ACTIVE_GAME_TURKEY: {
		"code": "T",
		"name": "Turkey",
		"color": Color(0.96, 0.8, 0.26, 1.0),
		"dark": Color(0.46, 0.31, 0.06, 1.0),
	},
	Util.ACTIVE_GAME_REEL_INTO_DARKNESS: {
		"code": "I",
		"name": "Reel Into Darkness",
		"color": Color(0.42, 0.44, 0.48, 1.0),
		"dark": Color(0.12, 0.13, 0.14, 1.0),
	},
}
const VANGUARD_LEVEL_MILESTONES := [7, 9, 11, 13, 15, 17]
const MINING_LEVEL_MILESTONES := [5, 10, 15, 20, 25, 30]
const RED_SKY_WAVE_MILESTONES := [5, 10, 15, 20, 25, 30]
const TURKEY_LEAGUE_PASS_MILESTONES := [1, 2, 3, 4, 5, 6]
const REEL_DEPTH_UPGRADE_MILESTONES := [
	"lead_sinkers",
	"deep_charts",
	"abyss_permits",
	"trench_winch",
	"hadal_licenses",
	"pressure_map",
]
const DEFAULT_DATA := {
	"currencies": {},
	"awarded_tokens": {},
	"target_bonus_tiers": {},
}

static var _icon_cache: Dictionary = {}

static func load_data() -> Dictionary:
	var data: Dictionary = DEFAULT_DATA.duplicate(true)
	if not FileAccess.file_exists(SAVE_PATH):
		return _sanitize_data(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return _sanitize_data(data)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = data.merged(parsed, true)
	return _sanitize_data(data)

static func save_data(data: Dictionary) -> void:
	var safe_data: Dictionary = _sanitize_data(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(safe_data, "\t"))

static func get_currency_count(currency_id: String) -> int:
	var data: Dictionary = load_data()
	return int(data.get("currencies", {}).get(currency_id, 0))

static func get_all_currency_counts() -> Dictionary:
	return load_data().get("currencies", {}).duplicate(true)

static func grant_currency_if_new(currency_id: String, token: String) -> bool:
	if not CURRENCY_DATA.has(currency_id):
		return false
	var data: Dictionary = load_data()
	var awarded_tokens: Dictionary = data.get("awarded_tokens", {}).duplicate(true)
	var currency_tokens: Dictionary = awarded_tokens.get(currency_id, {}).duplicate(true)
	if bool(currency_tokens.get(token, false)):
		return false
	currency_tokens[token] = true
	awarded_tokens[currency_id] = currency_tokens
	data["awarded_tokens"] = awarded_tokens
	var currencies: Dictionary = data.get("currencies", {}).duplicate(true)
	currencies[currency_id] = int(currencies.get(currency_id, 0)) + 1
	data["currencies"] = currencies
	save_data(data)
	return true

static func award_vanguard_level_clear(level: int) -> bool:
	if not VANGUARD_LEVEL_MILESTONES.has(level):
		return false
	return grant_currency_if_new(Util.ACTIVE_GAME_VANGUARD, "level_%d" % level)

static func award_mining_depth(depth_level: int) -> int:
	var awarded := 0
	for milestone in MINING_LEVEL_MILESTONES:
		if depth_level >= milestone and grant_currency_if_new(Util.ACTIVE_GAME_MINING, "depth_%d" % milestone):
			awarded += 1
	return awarded

static func award_red_sky_wave(wave: int) -> int:
	var awarded := 0
	for milestone in RED_SKY_WAVE_MILESTONES:
		if wave >= milestone and grant_currency_if_new(Util.ACTIVE_GAME_RED_SKY, "wave_%d" % milestone):
			awarded += 1
	return awarded

static func award_turkey_league_pass_level(level: int) -> int:
	var awarded := 0
	for milestone in TURKEY_LEAGUE_PASS_MILESTONES:
		if level >= milestone and grant_currency_if_new(Util.ACTIVE_GAME_TURKEY, "league_pass_%d" % milestone):
			awarded += 1
	return awarded

static func award_reel_depth_unlocks(upgrades: Dictionary) -> int:
	var awarded := 0
	for key in REEL_DEPTH_UPGRADE_MILESTONES:
		if int(upgrades.get(key, 0)) > 0 and grant_currency_if_new(Util.ACTIVE_GAME_REEL_INTO_DARKNESS, "depth_unlock_%s" % key):
			awarded += 1
	return awarded

static func get_target_bonus_level(target_game_id: String) -> int:
	var data: Dictionary = load_data()
	return clampi(int(data.get("target_bonus_tiers", {}).get(target_game_id, 0)), 0, MAX_BONUS_TIER)

static func get_target_bonus_multiplier(target_game_id: String) -> float:
	return 1.0 + BONUS_MULT_PER_TIER * float(get_target_bonus_level(target_game_id))

static func is_cross_bonus_key(sim_key: String) -> bool:
	return str(sim_key).begins_with(CROSS_NODE_KEY_PREFIX)

static func get_cross_bonus_key_for_target(target_game_id: String) -> String:
	return "%s%s" % [CROSS_NODE_KEY_PREFIX, target_game_id]

static func get_target_from_cross_bonus_key(sim_key: String) -> String:
	var raw_key: String = str(sim_key)
	if not is_cross_bonus_key(raw_key):
		return ""
	return raw_key.trim_prefix(CROSS_NODE_KEY_PREFIX)

static func get_eligible_currency_ids_for_target(target_game_id: String) -> Array[String]:
	var eligible: Array[String] = []
	for currency_id in CURRENCY_ORDER:
		if currency_id != target_game_id:
			eligible.append(currency_id)
	return eligible

static func get_available_currency_total_for_target(target_game_id: String) -> int:
	var counts: Dictionary = get_all_currency_counts()
	var total := 0
	for currency_id in get_eligible_currency_ids_for_target(target_game_id):
		total += int(counts.get(currency_id, 0))
	return total

static func can_afford_target_bonus(target_game_id: String, tier_index: int) -> bool:
	if tier_index < 0 or tier_index >= CROSS_NODE_COSTS.size():
		return false
	return get_available_currency_total_for_target(target_game_id) >= int(CROSS_NODE_COSTS[tier_index])

static func purchase_target_bonus(target_game_id: String) -> bool:
	var data: Dictionary = load_data()
	var levels: Dictionary = data.get("target_bonus_tiers", {}).duplicate(true)
	var current_level: int = clampi(int(levels.get(target_game_id, 0)), 0, MAX_BONUS_TIER)
	if current_level >= MAX_BONUS_TIER:
		return false
	var cost: int = int(CROSS_NODE_COSTS[current_level])
	var currencies: Dictionary = data.get("currencies", {}).duplicate(true)
	var remaining: int = cost
	for currency_id in get_eligible_currency_ids_for_target(target_game_id):
		if remaining <= 0:
			break
		var available: int = int(currencies.get(currency_id, 0))
		if available <= 0:
			continue
		var spend: int = min(available, remaining)
		currencies[currency_id] = available - spend
		remaining -= spend
	if remaining > 0:
		return false
	levels[target_game_id] = current_level + 1
	data["currencies"] = currencies
	data["target_bonus_tiers"] = levels
	save_data(data)
	return true

static func get_cross_bonus_node_definition(target_game_id: String) -> Dictionary:
	var source_names: Array[String] = []
	for currency_id in get_eligible_currency_ids_for_target(target_game_id):
		source_names.append(str(CURRENCY_DATA.get(currency_id, {}).get("code", "?")))
	var game_name: String = _get_game_display_name(target_game_id)
	var effect_text: String = _get_effect_text_for_target(target_game_id)
	return {
		"id": get_cross_bonus_key_for_target(target_game_id),
		"key": get_cross_bonus_key_for_target(target_game_id),
		"label": "%s Cross Bonus" % game_name,
		"summary": "%s Costs foreign gems: %s." % [effect_text, "/".join(source_names)],
		"icon": "cross://%s" % target_game_id,
		"max_tier": MAX_BONUS_TIER,
		"base_cost": CROSS_NODE_COSTS[0],
		"tier_costs": CROSS_NODE_COSTS.duplicate(),
		"cost_scale": 0.0,
		"cell": Vector2(CROSS_NODE_CELL_BY_TARGET.get(target_game_id, Vector2(0, -5))),
		"dependency": "__CENTER__",
		"act": _get_target_act(target_game_id),
		"branch": 99,
		"step": 1,
		"group": 99,
		"level": 1,
	}

static func get_currency_metadata(currency_id: String) -> Dictionary:
	return CURRENCY_DATA.get(currency_id, {}).duplicate(true)

static func get_currency_display_text(currency_id: String) -> String:
	var info: Dictionary = CURRENCY_DATA.get(currency_id, {})
	return "%s %d" % [str(info.get("code", "?")), get_currency_count(currency_id)]

static func get_currency_icon_texture(currency_id: String, size: int = 72) -> Texture2D:
	var cache_key := "%s:%d" % [currency_id, size]
	if _icon_cache.has(cache_key):
		return _icon_cache[cache_key]
	var info: Dictionary = CURRENCY_DATA.get(currency_id, {})
	if info.is_empty():
		return null
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var outer: Color = Color(info.get("color", Color.WHITE))
	var inner: Color = Color(info.get("dark", Color(0.1, 0.1, 0.1, 1.0)))
	var center := Vector2(float(size) * 0.5, float(size) * 0.5)
	var outer_radius: float = float(size) * 0.42
	var inner_radius: float = float(size) * 0.32
	var glow_radius: float = float(size) * 0.47
	for y in range(size):
		for x in range(size):
			var px := float(x) + 0.5
			var py := float(y) + 0.5
			var delta := Vector2(px, py) - center
			var dist := delta.length()
			var angle: float = atan2(delta.y, delta.x)
			var ring_wave: float = 0.93 + 0.1 * sin(angle * 6.0)
			if dist <= glow_radius:
				var glow_t: float = clampf(1.0 - dist / glow_radius, 0.0, 1.0)
				if glow_t > 0.0:
					var glow_color := outer
					glow_color.a = 0.22 * glow_t
					image.set_pixel(x, y, glow_color)
			if dist <= outer_radius * ring_wave:
				var shade: float = clampf(1.1 - dist / max(outer_radius, 0.001), 0.0, 1.0)
				var fill: Color = inner.lerp(outer, 0.45 + 0.35 * shade)
				fill.a = 1.0
				image.set_pixel(x, y, fill)
			if dist <= inner_radius:
				var core: Color = inner.lerp(Color.WHITE, 0.08)
				core.a = 1.0
				image.set_pixel(x, y, core)
	_draw_glyph_letter(image, str(info.get("code", "?")), outer)
	var texture := ImageTexture.create_from_image(image)
	_icon_cache[cache_key] = texture
	return texture

static func _draw_glyph_letter(image: Image, text: String, color: Color) -> void:
	var patterns := {
		"V": [
			"..#...#..",
			"..#...#..",
			"...#.#...",
			"...#.#...",
			"....#....",
			"....#....",
		],
		"D": [
			"#####....",
			"#....#...",
			"#.....#..",
			"#.....#..",
			"#....#...",
			"#####....",
		],
		"R": [
			"#####....",
			"#....#...",
			"#####....",
			"#..#.....",
			"#...#....",
			"#....#...",
		],
		"T": [
			"#######..",
			"...#.....",
			"...#.....",
			"...#.....",
			"...#.....",
			"...#.....",
		],
		"I": [
			"#####....",
			"..#......",
			"..#......",
			"..#......",
			"..#......",
			"#####....",
		],
	}
	var pattern: Array = patterns.get(text, ["###", ".#.", ".#."])
	var rows: int = pattern.size()
	if rows <= 0:
		return
	var cols: int = String(pattern[0]).length()
	var pixel_size: int = max(3, int(floor(float(image.get_width()) / float(max(cols + 8, rows + 8)))))
	var start_x: int = int((image.get_width() - cols * pixel_size) / 2)
	var start_y: int = int((image.get_height() - rows * pixel_size) / 2)
	var letter_color := color.lerp(Color.WHITE, 0.35)
	for row in range(rows):
		var row_text: String = String(pattern[row])
		for col in range(row_text.length()):
			if row_text.unicode_at(col) != "#".unicode_at(0):
				continue
			for oy in range(pixel_size):
				for ox in range(pixel_size):
					var x := start_x + col * pixel_size + ox
					var y := start_y + row * pixel_size + oy
					if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
						continue
					image.set_pixel(x, y, letter_color)

static func _sanitize_data(data: Dictionary) -> Dictionary:
	var safe_data: Dictionary = DEFAULT_DATA.merged(data, true)
	var currencies: Dictionary = safe_data.get("currencies", {})
	var awarded_tokens: Dictionary = safe_data.get("awarded_tokens", {})
	var target_bonus_tiers: Dictionary = safe_data.get("target_bonus_tiers", {})
	for currency_id in CURRENCY_ORDER:
		currencies[currency_id] = max(0, int(currencies.get(currency_id, 0)))
		if not (awarded_tokens.get(currency_id, {}) is Dictionary):
			awarded_tokens[currency_id] = {}
		target_bonus_tiers[currency_id] = clampi(int(target_bonus_tiers.get(currency_id, 0)), 0, MAX_BONUS_TIER)
	safe_data["currencies"] = currencies
	safe_data["awarded_tokens"] = awarded_tokens
	safe_data["target_bonus_tiers"] = target_bonus_tiers
	return safe_data

static func _get_game_display_name(game_id: String) -> String:
	match game_id:
		Util.ACTIVE_GAME_VANGUARD:
			return "Vanguard"
		Util.ACTIVE_GAME_MINING:
			return "Deepcore"
		Util.ACTIVE_GAME_RED_SKY:
			return "Red Sky Defense"
		Util.ACTIVE_GAME_TURKEY:
			return "Turkey"
		Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
			return "Reel Into Darkness"
		_:
			return game_id.capitalize()

static func _get_effect_text_for_target(target_game_id: String) -> String:
	match target_game_id:
		Util.ACTIVE_GAME_VANGUARD:
			return "+50% all damage and +50% money per tier."
		Util.ACTIVE_GAME_MINING:
			return "+50% drill damage and +50% money per tier."
		Util.ACTIVE_GAME_RED_SKY:
			return "+50% all damage and +50% money per tier."
		Util.ACTIVE_GAME_TURKEY:
			return "+50% ball mass and +50% money per tier."
		Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
			return "+50% fish stamina damage and +50% money per tier."
		_:
			return "+50% power and +50% money per tier."

static func _get_target_act(target_game_id: String) -> int:
	match target_game_id:
		Util.ACTIVE_GAME_VANGUARD:
			return 5
		Util.ACTIVE_GAME_MINING:
			return 2
		Util.ACTIVE_GAME_RED_SKY:
			return 3
		Util.ACTIVE_GAME_TURKEY:
			return 5
		Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
			return 4
		_:
			return 1
