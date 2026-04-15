extends RefCounted
class_name CrossGameBonuses

const SAVE_PATH := "user://cross_game_bonuses_v1.json"
const MAX_BONUS_TIER := 4
const BONUS_MULT_PER_TIER := 0.5
const CROSS_NODE_KEY_PREFIX := "cross_bonus_"
const CROSS_NODE_COSTS := [1, 2, 3, 4]
const UNIVERSAL_GEM_ID := "multi"
const CROSS_NODE_CELL_BY_TARGET := {
    Util.ACTIVE_GAME_VANGUARD: Vector2(0, -1),
    Util.ACTIVE_GAME_MINING: Vector2(0, -1),
    Util.ACTIVE_GAME_RED_SKY: Vector2(0, -1),
    Util.ACTIVE_GAME_TURKEY: Vector2(0, -1),
    Util.ACTIVE_GAME_REEL_INTO_DARKNESS: Vector2(0, -1),
}
const TARGET_GAME_IDS := [
    Util.ACTIVE_GAME_VANGUARD,
    Util.ACTIVE_GAME_MINING,
    Util.ACTIVE_GAME_RED_SKY,
    Util.ACTIVE_GAME_TURKEY,
    Util.ACTIVE_GAME_REEL_INTO_DARKNESS,
]
const CURRENCY_ORDER := [
    Util.ACTIVE_GAME_VANGUARD,
    Util.ACTIVE_GAME_MINING,
    Util.ACTIVE_GAME_RED_SKY,
    Util.ACTIVE_GAME_TURKEY,
    Util.ACTIVE_GAME_REEL_INTO_DARKNESS,
    UNIVERSAL_GEM_ID,
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
    UNIVERSAL_GEM_ID: {
        "code": "M",
        "name": "M Gems",
        "color": Color(0.56, 0.92, 0.88, 1.0),
        "dark": Color(0.08, 0.23, 0.23, 1.0),
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

static func reset_progress() -> Dictionary:
    var data: Dictionary = DEFAULT_DATA.duplicate(true)
    save_data(data)
    return _sanitize_data(data)

static func get_currency_count(currency_id: String) -> int:
    var data: Dictionary = load_data()
    var currencies: Dictionary = data.get("currencies", {})
    var resolved_id: String = currency_id if CURRENCY_DATA.has(currency_id) else UNIVERSAL_GEM_ID
    return int(currencies.get(resolved_id, 0))

static func get_all_currency_counts() -> Dictionary:
    return load_data().get("currencies", {}).duplicate(true)

static func grant_multi_gems(amount: int) -> void:
    if amount <= 0:
        return
    var data: Dictionary = load_data()
    var currencies: Dictionary = data.get("currencies", {}).duplicate(true)
    currencies[UNIVERSAL_GEM_ID] = max(0, int(currencies.get(UNIVERSAL_GEM_ID, 0)) + amount)
    data["currencies"] = currencies
    save_data(data)

static func grant_currency_if_new(currency_id: String, token: String) -> bool:
    if not TARGET_GAME_IDS.has(currency_id):
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

static func count_vanguard_level_rewards(level: int) -> int:
    return 1 if VANGUARD_LEVEL_MILESTONES.has(level) else 0

static func award_mining_depth(depth_level: int) -> int:
    var awarded := 0
    for milestone in MINING_LEVEL_MILESTONES:
        if depth_level >= milestone and grant_currency_if_new(Util.ACTIVE_GAME_MINING, "depth_%d" % milestone):
            awarded += 1
    return awarded

static func count_mining_depth_rewards_between(previous_depth_level: int, new_depth_level: int) -> int:
    var awarded := 0
    for milestone in MINING_LEVEL_MILESTONES:
        if previous_depth_level < milestone and new_depth_level >= milestone:
            awarded += 1
    return awarded

static func award_red_sky_wave(wave: int) -> int:
    var awarded := 0
    for milestone in RED_SKY_WAVE_MILESTONES:
        if wave >= milestone and grant_currency_if_new(Util.ACTIVE_GAME_RED_SKY, "wave_%d" % milestone):
            awarded += 1
    return awarded

static func count_red_sky_wave_rewards_between(previous_wave: int, new_wave: int) -> int:
    var awarded := 0
    for milestone in RED_SKY_WAVE_MILESTONES:
        if previous_wave < milestone and new_wave >= milestone:
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
    if not TARGET_GAME_IDS.has(target_game_id):
        return []
    var eligible: Array[String] = [UNIVERSAL_GEM_ID]
    for currency_id in TARGET_GAME_IDS:
        if currency_id != target_game_id:
            eligible.append(currency_id)
    return eligible

static func get_available_currency_total_for_target(target_game_id: String) -> int:
    if not TARGET_GAME_IDS.has(target_game_id):
        return 0
    var total := 0
    for currency_id in get_eligible_currency_ids_for_target(target_game_id):
        total += get_currency_count(currency_id)
    return total

static func can_afford_target_bonus(target_game_id: String, tier_index: int) -> bool:
    if tier_index < 0 or tier_index >= CROSS_NODE_COSTS.size():
        return false
    return get_available_currency_total_for_target(target_game_id) >= int(CROSS_NODE_COSTS[tier_index])

static func purchase_target_bonus(target_game_id: String) -> bool:
    if not Util.is_all_high_level_mode_active():
        return false
    if not TARGET_GAME_IDS.has(target_game_id):
        return false
    var data: Dictionary = load_data()
    var levels: Dictionary = data.get("target_bonus_tiers", {}).duplicate(true)
    var current_level: int = clampi(int(levels.get(target_game_id, 0)), 0, MAX_BONUS_TIER)
    if current_level >= MAX_BONUS_TIER:
        return false
    var cost: int = int(CROSS_NODE_COSTS[current_level])
    var currencies: Dictionary = data.get("currencies", {}).duplicate(true)
    var remaining_cost: int = cost
    for currency_id in get_eligible_currency_ids_for_target(target_game_id):
        var available: int = int(currencies.get(currency_id, 0))
        if available <= 0:
            continue
        var spend: int = min(available, remaining_cost)
        currencies[currency_id] = available - spend
        remaining_cost -= spend
        if remaining_cost <= 0:
            break
    if remaining_cost > 0:
        return false
    levels[target_game_id] = current_level + 1
    data["currencies"] = currencies
    data["target_bonus_tiers"] = levels
    save_data(data)
    return true

static func get_cross_bonus_node_definition(target_game_id: String) -> Dictionary:
    var game_name: String = _get_game_display_name(target_game_id)
    var effect_text: String = _get_effect_text_for_target(target_game_id)
    var source_codes: Array[String] = []
    for currency_id in get_eligible_currency_ids_for_target(target_game_id):
        var code: String = str(CURRENCY_DATA.get(currency_id, {}).get("code", ""))
        if code != "":
            source_codes.append(code)
    return {
        "id": get_cross_bonus_key_for_target(target_game_id),
        "key": get_cross_bonus_key_for_target(target_game_id),
        "label": TranslationServer.translate("MULTI_MODE_CROSS_BONUS_LABEL") % [game_name],
        "summary": "%s %s" % [effect_text, TranslationServer.translate("MULTI_MODE_CROSS_BONUS_COSTS_M_GEMS") % ["/".join(source_codes)]],
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
    var resolved_id: String = currency_id if CURRENCY_DATA.has(currency_id) else UNIVERSAL_GEM_ID
    return CURRENCY_DATA.get(resolved_id, {}).duplicate(true)

static func get_currency_display_text(currency_id: String) -> String:
    var info: Dictionary = get_currency_metadata(currency_id)
    return "%s %d" % [str(info.get("code", "?")), get_currency_count(currency_id)]

static func get_cost_text(amount: int) -> String:
    if amount == 1:
        return TranslationServer.translate("%d gem") % [amount]
    return TranslationServer.translate("%d gems") % [amount]

static func _get_cross_gem_name_translation_key(currency_id: String) -> String:
    match currency_id:
        Util.ACTIVE_GAME_VANGUARD:
            return "CROSS_GAME_GEM_NAME_VANGUARD"
        Util.ACTIVE_GAME_MINING:
            return "CROSS_GAME_GEM_NAME_MINING"
        Util.ACTIVE_GAME_RED_SKY:
            return "CROSS_GAME_GEM_NAME_RED_SKY"
        Util.ACTIVE_GAME_TURKEY:
            return "CROSS_GAME_GEM_NAME_TURKEY"
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return "CROSS_GAME_GEM_NAME_REEL_INTO_DARKNESS"
        UNIVERSAL_GEM_ID:
            return "CROSS_GAME_GEM_NAME_MULTI"
        _:
            return ""

static func get_reward_summary_line(currency_id: String, amount: int) -> String:
    if amount <= 0:
        return ""
    var info: Dictionary = get_currency_metadata(currency_id)
    var code: String = str(info.get("code", "?"))
    if currency_id == UNIVERSAL_GEM_ID:
        if amount == 1:
            return TranslationServer.translate("CROSS_GEM_REWARD_SINGULAR_M") % [code]
        return TranslationServer.translate("CROSS_GEM_REWARD_PLURAL_M") % [amount, code]
    var name_key: String = _get_cross_gem_name_translation_key(currency_id)
    var gem_name: String = TranslationServer.translate(name_key) if name_key != "" else str(info.get("name", currency_id))
    if amount == 1:
        return TranslationServer.translate("CROSS_GEM_REWARD_SINGULAR") % [gem_name, code]
    return TranslationServer.translate("CROSS_GEM_REWARD_PLURAL") % [amount, gem_name, code]

static func get_currency_icon_texture(currency_id: String, size: int = 72) -> Texture2D:
    var resolved_id: String = currency_id if CURRENCY_DATA.has(currency_id) else UNIVERSAL_GEM_ID
    var cache_key := "%s:%d" % [resolved_id, size]
    if _icon_cache.has(cache_key):
        return _icon_cache[cache_key]
    var info: Dictionary = CURRENCY_DATA.get(resolved_id, {})
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
        "M": [
            "#.....#..",
            "##...##..",
            "#.#.#.#..",
            "#..#..#..",
            "#.....#..",
            "#.....#..",
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
    var currencies_variant: Variant = safe_data.get("currencies", {})
    var currencies: Dictionary = currencies_variant.duplicate(true) if currencies_variant is Dictionary else {}
    var awarded_tokens: Dictionary = safe_data.get("awarded_tokens", {})
    var target_bonus_tiers: Dictionary = safe_data.get("target_bonus_tiers", {})
    for currency_id in CURRENCY_ORDER:
        currencies[currency_id] = max(0, int(currencies.get(currency_id, 0)))
    for source_game_id in TARGET_GAME_IDS:
        if not (awarded_tokens.get(source_game_id, {}) is Dictionary):
            awarded_tokens[source_game_id] = {}
        target_bonus_tiers[source_game_id] = clampi(int(target_bonus_tiers.get(source_game_id, 0)), 0, MAX_BONUS_TIER)
    safe_data["currencies"] = currencies
    safe_data["awarded_tokens"] = awarded_tokens
    safe_data["target_bonus_tiers"] = target_bonus_tiers
    return safe_data

static func _get_game_display_name(game_id: String) -> String:
    var key: String = _get_cross_gem_name_translation_key(game_id)
    if key != "":
        return TranslationServer.translate(key)
    return game_id.capitalize()

static func _get_effect_text_for_target(target_game_id: String) -> String:
    match target_game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_VANGUARD")
        Util.ACTIVE_GAME_MINING:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_MINING")
        Util.ACTIVE_GAME_RED_SKY:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_RED_SKY")
        Util.ACTIVE_GAME_TURKEY:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_TURKEY")
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_REEL_INTO_DARKNESS")
        _:
            return TranslationServer.translate("MULTI_MODE_CROSS_BONUS_EFFECT_DEFAULT")

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
