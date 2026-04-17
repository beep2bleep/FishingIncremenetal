extends Node2D








var planet_data: PlanetData = null
var zone_threat: ZoneThreatSystem = null


var hit_timers: Dictionary = {}
const HIT_GLOW_DURATION: float = 0.15


var gold_convert_timers: Dictionary = {}
const GOLD_CONVERT_DURATION: float = 0.5
const GOLD_CONVERT_COLOR: = Color(3.0, 2.2, 0.5)


var time_elapsed: float = 0.0


var _force_redraw: bool = true
var _last_cam_origin: Vector2 = Vector2.INF




var _fill_image: Image = null
var _fill_texture: ImageTexture = null
var _fill_grid_size: Vector2i = Vector2i.ZERO


var shockwave_effects: Array = []
const SHOCKWAVE_DURATION: float = 0.6
const SHOCKWAVE_COLOR: = Color(2.0, 0.4, 0.15)


var arena_flash_rings: Array = []
const ARENA_FLASH_DURATION: float = 0.35
const ARENA_FLASH_COLOR: = Color(3.0, 2.5, 2.0)


const EDGE_COLORS = {
    1: Color(0.4, 1.5, 2.0), 
    2: Color(0.5, 1.4, 1.8), 
    3: Color(0.7, 1.4, 1.4), 
    4: Color(1.0, 1.4, 1.0), 
    5: Color(1.4, 1.3, 0.5), 
    6: Color(1.7, 1.0, 0.3), 
    7: Color(1.9, 0.8, 0.2), 
    8: Color(2.0, 0.6, 0.15), 
    9: Color(2.0, 0.35, 0.1), 
    10: Color(2.0, 0.15, 0.05), 
}


const FILL_BASE: = Color(0.025, 0.025, 0.035)


const GRID_LINE_COLOR: = Color(0.08, 0.09, 0.12, 0.25)
const BLOCK_GAP: float = 1.5


const CORE_FILL: = Color(0.06, 0.01, 0.01)
const CORE_EDGE: = Color(2.5, 0.3, 0.08)
const CORE_INNER_GLOW: = Color(2.0, 0.4, 0.1, 0.25)
const CORE_PULSE_COLOR: = Color(1.5, 0.15, 0.05)
const PROXIMITY_PULSE: = Color(2.0, 0.2, 0.06)



const ZONE_CORE_COLORS = {

    PlanetData.Zone.SPRING: {
        "fill": Color(0.01, 0.06, 0.02), 
        "edge": Color(0.3, 2.2, 0.6), 
        "glow": Color(0.2, 1.8, 0.5, 0.25), 
        "pulse": Color(0.15, 1.2, 0.3), 
        "proximity": Color(0.2, 1.5, 0.4), 
        "zone_ring": Color(0.3, 1.5, 0.4, 0.3), 
        "zone_fill": Color(0.1, 0.6, 0.2, 0.04), 
    }, 

    PlanetData.Zone.SUMMER: {
        "fill": Color(0.06, 0.04, 0.01), 
        "edge": Color(2.2, 1.8, 0.2), 
        "glow": Color(1.8, 1.4, 0.15, 0.25), 
        "pulse": Color(1.5, 1.1, 0.1), 
        "proximity": Color(1.8, 1.3, 0.15), 
        "zone_ring": Color(2.0, 1.5, 0.2, 0.3), 
        "zone_fill": Color(0.6, 0.4, 0.05, 0.04), 
    }, 

    PlanetData.Zone.AUTUMN: {
        "fill": Color(0.06, 0.01, 0.01), 
        "edge": Color(2.5, 0.3, 0.08), 
        "glow": Color(2.0, 0.4, 0.1, 0.25), 
        "pulse": Color(1.5, 0.15, 0.05), 
        "proximity": Color(2.0, 0.2, 0.06), 
        "zone_ring": Color(2.0, 0.3, 0.08, 0.3), 
        "zone_fill": Color(1.0, 0.15, 0.04, 0.04), 
    }, 

    PlanetData.Zone.WINTER: {
        "fill": Color(0.01, 0.02, 0.07), 
        "edge": Color(0.4, 1.0, 2.5), 
        "glow": Color(0.3, 0.8, 2.0, 0.25), 
        "pulse": Color(0.2, 0.6, 1.5), 
        "proximity": Color(0.3, 0.8, 2.0), 
        "zone_ring": Color(0.3, 0.8, 2.0, 0.3), 
        "zone_fill": Color(0.1, 0.2, 0.6, 0.04), 
    }, 

    PlanetData.Zone.CENTER: {
        "fill": Color(0.04, 0.01, 0.06), 
        "edge": Color(1.5, 0.3, 2.5), 
        "glow": Color(1.2, 0.25, 2.0, 0.25), 
        "pulse": Color(1.0, 0.15, 1.5), 
        "proximity": Color(1.3, 0.2, 2.0), 
        "zone_ring": Color(1.2, 0.25, 2.0, 0.3), 
        "zone_fill": Color(0.4, 0.1, 0.5, 0.04), 
    }, 
}


func _get_core_zone_colors(zone: int) -> Dictionary:
    return ZONE_CORE_COLORS.get(zone, ZONE_CORE_COLORS[PlanetData.Zone.AUTUMN])


const DEAD_ZONE_RING: = Color(0.15, 0.8, 1.0, 0.12)


const ALIVE_ZONE_RING: = Color(2.0, 0.3, 0.08, 0.3)
const ALIVE_ZONE_FILL: = Color(1.0, 0.15, 0.04, 0.04)


const SHIELD_COLOR: = Color(0.3, 0.6, 1.0)
const SHIELD_DOME_COLOR: = Color(0.2, 0.5, 1.0, 0.08)


const HARD_BLOCK_THRESHOLD: int = 6




const ZONE_EDGE_COLORS = {

    PlanetData.Zone.SPRING: {
        1: Color(0.3, 1.8, 0.5), 
        2: Color(0.25, 1.6, 0.6), 
        3: Color(0.2, 1.5, 0.8), 
        4: Color(0.15, 1.4, 1.0), 
        5: Color(0.1, 1.3, 1.1), 
        6: Color(0.1, 1.2, 1.0), 
        7: Color(0.15, 1.0, 0.8), 
        8: Color(0.2, 0.8, 0.6), 
        9: Color(0.25, 0.6, 0.4), 
        10: Color(0.3, 0.4, 0.2), 
    }, 

    PlanetData.Zone.SUMMER: {
        1: Color(2.0, 2.0, 0.4), 
        2: Color(2.0, 1.8, 0.3), 
        3: Color(2.0, 1.6, 0.2), 
        4: Color(1.9, 1.4, 0.15), 
        5: Color(1.8, 1.2, 0.1), 
        6: Color(1.7, 1.0, 0.08), 
        7: Color(1.6, 0.85, 0.06), 
        8: Color(1.5, 0.7, 0.05), 
        9: Color(1.3, 0.55, 0.04), 
        10: Color(1.1, 0.4, 0.03), 
    }, 

    PlanetData.Zone.AUTUMN: {
        1: Color(2.0, 0.35, 0.1), 
        2: Color(1.9, 0.28, 0.1), 
        3: Color(1.8, 0.2, 0.1), 
        4: Color(1.6, 0.15, 0.1), 
        5: Color(1.4, 0.12, 0.12), 
        6: Color(1.2, 0.1, 0.12), 
        7: Color(1.0, 0.08, 0.14), 
        8: Color(0.85, 0.06, 0.14), 
        9: Color(0.7, 0.05, 0.12), 
        10: Color(0.55, 0.04, 0.1), 
    }, 

    PlanetData.Zone.WINTER: {
        1: Color(0.5, 1.2, 2.2), 
        2: Color(0.4, 1.0, 2.0), 
        3: Color(0.35, 0.8, 1.9), 
        4: Color(0.3, 0.6, 1.8), 
        5: Color(0.3, 0.45, 1.7), 
        6: Color(0.35, 0.35, 1.6), 
        7: Color(0.4, 0.25, 1.5), 
        8: Color(0.5, 0.18, 1.4), 
        9: Color(0.55, 0.12, 1.2), 
        10: Color(0.6, 0.08, 1.0), 
    }, 

    PlanetData.Zone.CENTER: {
        1: Color(1.2, 0.4, 2.0), 
        2: Color(1.3, 0.3, 1.8), 
        3: Color(1.4, 0.25, 1.6), 
        4: Color(1.5, 0.2, 1.4), 
        5: Color(1.5, 0.15, 1.2), 
        6: Color(1.4, 0.12, 1.0), 
        7: Color(1.3, 0.1, 0.8), 
        8: Color(1.2, 0.08, 0.7), 
        9: Color(1.0, 0.06, 0.6), 
        10: Color(0.8, 0.04, 0.5), 
    }, 
}


const ZONE_FILLS = {
    PlanetData.Zone.SPRING: Color(0.01, 0.04, 0.015), 
    PlanetData.Zone.SUMMER: Color(0.04, 0.03, 0.005), 
    PlanetData.Zone.AUTUMN: Color(0.04, 0.015, 0.01), 
    PlanetData.Zone.WINTER: Color(0.01, 0.015, 0.045), 
    PlanetData.Zone.CENTER: Color(0.03, 0.01, 0.04), 
}


func _get_zone_edge_color(hp_index: int, zone: int) -> Color:
    var palette = ZONE_EDGE_COLORS.get(zone)
    if palette == null:
        palette = ZONE_EDGE_COLORS[PlanetData.Zone.SPRING]
    return palette.get(hp_index, palette[1])


func _get_zone_fill(zone: int) -> Color:
    return ZONE_FILLS.get(zone, FILL_BASE)


const REGEN_FILL: = Color(0.06, 0.015, 0.015)
const REGEN_EDGE: = Color(1.2, 0.2, 0.08)
const REGEN_INNER_GLOW: = Color(1.0, 0.15, 0.06, 0.2)
const REGEN_PULSE_COLOR: = Color(0.8, 0.12, 0.04)


const ELECTRIC_FILL: = Color(0.01, 0.06, 0.1)
const ELECTRIC_EDGE: = Color(0.5, 1.8, 2.5)
const ELECTRIC_INNER_GLOW: = Color(0.3, 1.5, 2.5, 0.3)
const ELECTRIC_BOLT: = Color(0.6, 2.0, 3.0)
const ELECTRIC_LOCKED_DIM: float = 0.25


const GOLD_FILL: = Color(0.05, 0.04, 0.01)
const GOLD_EDGE: = Color(2.0, 1.6, 0.3)
const GOLD_INNER_GLOW: = Color(1.5, 1.2, 0.2, 0.15)
const GOLD_LOCKED_DIM: float = 0.3


const THORN_FILL: = Color(0.04, 0.01, 0.03)
const THORN_EDGE: = Color(2.0, 0.4, 1.5)
const THORN_INNER_GLOW: = Color(1.5, 0.3, 1.2, 0.2)
const THORN_SPIKE: = Color(2.5, 0.5, 1.8)


const THORN_GROW_DURATION: float = 1.2
const THORN_VEIN_COLOR: = Color(1.8, 0.2, 1.0, 0.3)
const THORN_BIRTH_COLOR: = Color(0.3, 1.5, 0.4)


const LASER_WARN_COLOR: = Color(2.5, 0.3, 0.2, 0.6)
const LASER_FIRE_COLOR: = Color(3.0, 2.0, 0.5)
const LASER_CORE_CHARGE: = Color(2.5, 0.5, 0.2)


var _core_hp_cache: Dictionary = {}
var _core_hp_cache_timer: float = 0.0
const CORE_HP_CACHE_INTERVAL: float = 0.5


var _heartbeat_cache: Dictionary = {}


func _get_core_avg_hp(core: Dictionary) -> float:
    return _core_hp_cache.get(core.id, 1.0)


func _update_heartbeat_cache():
    _heartbeat_cache.clear()
    for core in planet_data.cores:
        if not core.alive:
            continue
        var core_hp = _core_hp_cache.get(core.id, 1.0)
        var core_damage = 1.0 - core_hp
        var hb_speed = 1.5 + core_damage * 6.5
        var hb_raw = abs(sin(time_elapsed * hb_speed * PI))
        var hb = hb_raw * hb_raw
        var hb_intensity = 0.08 + core_damage * 0.35
        _heartbeat_cache[core.id] = {
            "beat": hb, 
            "intensity": hb_intensity, 
            "damage": core_damage, 
        }


func _get_heartbeat(core_id: int) -> Dictionary:
    return _heartbeat_cache.get(core_id, {"beat": 0.0, "intensity": 0.08, "damage": 0.0})


func _update_core_hp_cache():
    _core_hp_cache.clear()
    for core in planet_data.cores:
        if not core.alive:
            _core_hp_cache[core.id] = 0.0
            continue
        var total_hp: = 0.0
        var total_max: = 0.0
        var half: int = core.size / 2
        for dx in range( - half, half + core.size % 2):
            for dy in range( - half, half + core.size % 2):
                var pos = Vector2i(core.center.x + dx, core.center.y + dy)
                var block = planet_data.blocks.get(pos)
                if block and block.core_id == core.id:
                    total_hp += block.hp
                    total_max += block.max_hp
        _core_hp_cache[core.id] = clampf(total_hp / total_max, 0.0, 1.0) if total_max > 0 else 0.0

func register_hit(pos: Vector2i):
    hit_timers[pos] = HIT_GLOW_DURATION


func register_gold_convert(pos: Vector2i):
    gold_convert_timers[pos] = GOLD_CONVERT_DURATION


func register_shockwave(world_center: Vector2, max_radius: float):
    shockwave_effects.append({
        "center": world_center, 
        "max_radius": max_radius, 
        "timer": SHOCKWAVE_DURATION, 
    })


func register_arena_ring_flash(positions: Array) -> void :
    if positions.is_empty():
        return
    arena_flash_rings.append({
        "positions": positions, 
        "timer": ARENA_FLASH_DURATION, 
    })


func mark_dirty():
    _force_redraw = true

func _ready():

    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta):
    time_elapsed += delta


    if planet_data:
        _core_hp_cache_timer += delta
        if _core_hp_cache_timer >= CORE_HP_CACHE_INTERVAL:
            _core_hp_cache_timer = 0.0
            _update_core_hp_cache()

        _update_heartbeat_cache()


    var expired = []
    for pos in hit_timers:
        hit_timers[pos] -= delta
        if hit_timers[pos] <= 0:
            expired.append(pos)
    for pos in expired:
        hit_timers.erase(pos)


    var gc_expired = []
    for pos in gold_convert_timers:
        gold_convert_timers[pos] -= delta
        if gold_convert_timers[pos] <= 0:
            gc_expired.append(pos)
    for pos in gc_expired:
        gold_convert_timers.erase(pos)


    var sw_alive: Array = []
    for sw in shockwave_effects:
        sw.timer -= delta
        if sw.timer > 0:
            sw_alive.append(sw)
    shockwave_effects = sw_alive


    var af_alive: Array = []
    for af in arena_flash_rings:
        af.timer -= delta
        if af.timer > 0:
            af_alive.append(af)
    arena_flash_rings = af_alive


    var needs_redraw = _force_redraw
    _force_redraw = false


    var cam_origin = get_canvas_transform().origin
    if cam_origin != _last_cam_origin:
        _last_cam_origin = cam_origin
        needs_redraw = true


    if not hit_timers.is_empty() or not gold_convert_timers.is_empty()\
or not shockwave_effects.is_empty()\
or not arena_flash_rings.is_empty():
        needs_redraw = true


    if zone_threat and zone_threat.has_active_effects():
        needs_redraw = true

    if needs_redraw:
        queue_redraw()









func _blend(base: Color, overlay_r: float, overlay_g: float, overlay_b: float, alpha: float) -> Color:
    return Color(
        base.r + (overlay_r - base.r) * alpha, 
        base.g + (overlay_g - base.g) * alpha, 
        base.b + (overlay_b - base.b) * alpha, 
        1.0
    )


func _calc_block_fill_color(block: Dictionary, pos: Vector2i) -> Color:
    var is_hit = hit_timers.has(pos)
    var hit_alpha = 0.0
    if is_hit:
        hit_alpha = hit_timers[pos] / HIT_GLOW_DURATION

    if block.type == PlanetData.BlockType.CORE:
        return _calc_core_fill(block, pos, is_hit, hit_alpha)
    elif block.type == PlanetData.BlockType.THORN:
        return _calc_thorn_fill(block, pos, is_hit, hit_alpha)
    elif block.get("regenerated", false):
        return _calc_regen_fill(block, pos, is_hit, hit_alpha)
    elif block.type == PlanetData.BlockType.ELECTRIC and Global.electric_unlocked:
        return _calc_electric_fill(block, pos, is_hit, hit_alpha)
    elif block.type == PlanetData.BlockType.GOLD and Global.gold_unlocked:
        return _calc_gold_fill(block, pos, is_hit, hit_alpha)
    else:
        return _calc_normal_fill(block, pos, is_hit, hit_alpha)


func _calc_normal_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:


    if not is_hit\
and block.hp == block.max_hp\
and block.max_hp < 1000000.0\
and planet_data.get_core_proximity(pos) <= 0.0:
        return _get_zone_fill(block.get("zone", 0))

    var hp = _hp_to_color_index(block.max_hp)
    var zone = block.get("zone", 0)
    var edge_color = _get_zone_edge_color(hp, zone)
    var fill_base = _get_zone_fill(zone)
    var edge_clamped = Color(min(edge_color.r, 1.0), min(edge_color.g, 1.0), min(edge_color.b, 1.0))

    if is_hit:
        return fill_base.lerp(edge_clamped, hit_alpha * 0.6)

    var damage_ratio = 1.0 - clampf(block.hp / block.max_hp, 0.0, 1.0)
    var result = fill_base.lerp(edge_clamped, damage_ratio * 0.25)


    var proximity = planet_data.get_core_proximity(pos)
    if proximity > 0.0:
        var pulse_speed = 1.5 + proximity * 2.0
        var pulse = (sin(time_elapsed * pulse_speed) + 1.0) * 0.5
        var pulse_alpha = proximity * proximity * pulse * 0.15
        var prox_col = _get_core_zone_colors(zone).proximity
        result = _blend(result, prox_col.r, prox_col.g, prox_col.b, pulse_alpha)


    if hp >= HARD_BLOCK_THRESHOLD:
        var glow_strength = remap(hp, HARD_BLOCK_THRESHOLD, 10, 0.02, 0.08)
        result = _blend(result, edge_clamped.r, edge_clamped.g, edge_clamped.b, glow_strength)

    return result


func _calc_core_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:
    var hp_ratio = clampf(block.hp / block.max_hp, 0.0, 1.0)
    var zone = block.get("zone", PlanetData.Zone.AUTUMN)
    var zc = _get_core_zone_colors(zone)
    var c_fill: Color = zc.fill
    var c_edge: Color = zc.edge
    var c_glow: Color = zc.glow
    var edge_clamped = Color(min(c_edge.r, 1.0), min(c_edge.g, 1.0), min(c_edge.b, 1.0))

    if is_hit:
        return c_fill.lerp(edge_clamped, hit_alpha * 0.7)

    var use_hp_visual = Global.core_detect_unlocked
    var result = c_fill.lerp(edge_clamped, hp_ratio * 0.3) if use_hp_visual else c_fill


    var hb_data = _get_heartbeat(block.core_id if block else -1)
    var glow_alpha = hb_data.beat * hb_data.intensity
    result = _blend(result, c_glow.r, c_glow.g, c_glow.b, glow_alpha)


    if use_hp_visual and hp_ratio < 0.3:
        var flicker_speed = 12.0 + (0.3 - hp_ratio) * 40.0
        var flicker = abs(sin(time_elapsed * flicker_speed + pos.x * 7.3 + pos.y * 3.1))
        var flicker_alpha = (0.3 - hp_ratio) / 0.3 * flicker * 0.4
        result = _blend(result, 3.0, 1.0, 0.3, flicker_alpha)


    if planet_data.is_core_locked(block.core_id):
        var pulse = (sin(time_elapsed * 3.0) + 1.0) * 0.5
        var alpha = 0.12 + pulse * 0.08
        result = _blend(result, SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, alpha)

    return result


func _calc_electric_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:
    var brightness = 1.0 if Global.electric_unlocked else ELECTRIC_LOCKED_DIM
    var edge_col = Color(ELECTRIC_EDGE.r * brightness, ELECTRIC_EDGE.g * brightness, ELECTRIC_EDGE.b * brightness)

    if is_hit:
        return ELECTRIC_FILL.lerp(Color(0.3, 0.8, 1.0), hit_alpha * 0.8)

    var result = ELECTRIC_FILL


    var pulse = (sin(time_elapsed * 4.0 + pos.x * 0.7 + pos.y * 0.5) + 1.0) * 0.5
    var glow_a = (0.15 + pulse * 0.2) * brightness
    result = _blend(result, ELECTRIC_INNER_GLOW.r, ELECTRIC_INNER_GLOW.g, ELECTRIC_INNER_GLOW.b, glow_a)


    var dmg_ratio = 1.0 - clampf(block.hp / block.max_hp, 0.0, 1.0)
    if dmg_ratio > 0.0:
        var ec = Color(min(edge_col.r, 1.0), min(edge_col.g, 1.0), min(edge_col.b, 1.0))
        result = _blend(result, ec.r, ec.g, ec.b, dmg_ratio * 0.15)

    return result


func _calc_gold_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:
    var brightness = 1.0 if Global.gold_unlocked else GOLD_LOCKED_DIM
    var edge_col = Color(GOLD_EDGE.r * brightness, GOLD_EDGE.g * brightness, GOLD_EDGE.b * brightness)
    var edge_clamped = Color(min(edge_col.r, 1.0), min(edge_col.g, 1.0), min(edge_col.b, 1.0))


    var zone = block.get("zone", 0)
    var fill_base = _get_zone_fill(zone)

    if is_hit:
        return fill_base.lerp(edge_clamped, hit_alpha * 0.7)

    var result = fill_base


    var pulse = (sin(time_elapsed * 1.8 + pos.x * 1.1 + pos.y * 0.9) + 1.0) * 0.5
    var glow_a = (0.02 + pulse * 0.03) * brightness
    result = _blend(result, GOLD_INNER_GLOW.r, GOLD_INNER_GLOW.g, GOLD_INNER_GLOW.b, glow_a)


    var dmg_ratio = 1.0 - clampf(block.hp / block.max_hp, 0.0, 1.0)
    if dmg_ratio > 0.0:
        result = _blend(result, edge_clamped.r, edge_clamped.g, edge_clamped.b, dmg_ratio * 0.25)

    return result


func _calc_regen_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:
    var edge_clamped = Color(min(REGEN_EDGE.r, 1.0), min(REGEN_EDGE.g, 1.0), min(REGEN_EDGE.b, 1.0))

    if is_hit:
        return REGEN_FILL.lerp(edge_clamped, hit_alpha * 0.6)

    var result = REGEN_FILL


    var pulse = (sin(time_elapsed * 1.2 + pos.x * 0.5 + pos.y * 0.3) + 1.0) * 0.5
    var glow_a = 0.06 + pulse * 0.1
    result = _blend(result, REGEN_INNER_GLOW.r, REGEN_INNER_GLOW.g, REGEN_INNER_GLOW.b, glow_a)


    var dmg_ratio = 1.0 - clampf(block.hp / block.max_hp, 0.0, 1.0)
    if dmg_ratio > 0.0:
        result = _blend(result, edge_clamped.r, edge_clamped.g, edge_clamped.b, dmg_ratio * 0.2)

    return result


func _calc_thorn_fill(block: Dictionary, pos: Vector2i, is_hit: bool, hit_alpha: float) -> Color:
    var edge_clamped = Color(min(THORN_EDGE.r, 1.0), min(THORN_EDGE.g, 1.0), min(THORN_EDGE.b, 1.0))

    if is_hit:
        return THORN_FILL.lerp(edge_clamped, hit_alpha * 0.7)


    var grow_ratio = 1.0
    if block.has("birth_time"):
        var age = Time.get_ticks_msec() * 0.001 - block.birth_time
        if age < THORN_GROW_DURATION:
            var t = age / THORN_GROW_DURATION
            grow_ratio = 1.0 - (1.0 - t) * (1.0 - t)

    var fill_col = THORN_FILL
    if grow_ratio < 1.0:
        var birth_fill = Color(0.01, 0.06, 0.02)
        fill_col = birth_fill.lerp(THORN_FILL, grow_ratio)

    var result = fill_col


    var pulse_speed = 2.5 + (1.0 - grow_ratio) * 6.0
    var pulse = (sin(time_elapsed * pulse_speed + pos.x * 0.8 + pos.y * 0.6) + 1.0) * 0.5
    var glow_intensity = 0.06 + pulse * 0.18
    if grow_ratio < 1.0:
        glow_intensity = 0.15 + pulse * 0.35
    var glow_r = lerpf(THORN_BIRTH_COLOR.r, THORN_INNER_GLOW.r + pulse * 0.3, grow_ratio)
    var glow_g = lerpf(THORN_BIRTH_COLOR.g, THORN_INNER_GLOW.g + pulse * 0.15, grow_ratio)
    var glow_b = lerpf(0.1, THORN_INNER_GLOW.b, grow_ratio)
    result = _blend(result, glow_r, glow_g, glow_b, glow_intensity)


    var dmg_ratio = 1.0 - clampf(block.hp / block.max_hp, 0.0, 1.0)
    if dmg_ratio > 0.0:
        result = _blend(result, edge_clamped.r, edge_clamped.g, edge_clamped.b, dmg_ratio * 0.3)

    return result

func _draw():
    if planet_data == null:
        return

    var canvas_transform = get_canvas_transform()
    var viewport_size = get_viewport_rect().size
    var cam_scale = canvas_transform.get_scale()

    var top_left = - canvas_transform.origin / cam_scale
    var bottom_right = top_left + viewport_size / cam_scale

    var margin = PlanetData.BLOCK_SIZE * 2
    var grid_min = planet_data.world_to_grid(top_left - Vector2(margin, margin))
    var grid_max = planet_data.world_to_grid(bottom_right + Vector2(margin, margin))

    var bs = PlanetData.BLOCK_SIZE


    _draw_dead_core_zones(bs)
    _draw_alive_core_zones(bs)


    _draw_core_outer_glow(bs, grid_min, grid_max)


    _draw_shield_domes(bs)


    var grid_w = grid_max.x - grid_min.x + 1
    var grid_h = grid_max.y - grid_min.y + 1


    if _fill_image == null or _fill_grid_size.x != grid_w or _fill_grid_size.y != grid_h:
        _fill_image = Image.create(grid_w, grid_h, false, Image.FORMAT_RGBA8)
        _fill_grid_size = Vector2i(grid_w, grid_h)
        _fill_texture = null
    else:
        _fill_image.fill(Color.TRANSPARENT)


    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var pos = Vector2i(x, y)
            if not planet_data.blocks.has(pos):
                continue
            var block = planet_data.blocks[pos]
            var fill_color = _calc_block_fill_color(block, pos)
            _fill_image.set_pixel(x - grid_min.x, y - grid_min.y, fill_color)


    if _fill_texture == null:
        _fill_texture = ImageTexture.create_from_image(_fill_image)
    else:
        _fill_texture.set_image(_fill_image)

    var tex_rect = Rect2(
        grid_min.x * bs, grid_min.y * bs, 
        grid_w * bs, grid_h * bs
    )
    draw_texture_rect(_fill_texture, tex_rect, false)


    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var pos = Vector2i(x, y)
            if not planet_data.blocks.has(pos):
                continue



            var _has_edges = planet_data.exposed_edges.get(pos, 0) != 0
            var _has_hit = hit_timers.has(pos)
            var _has_gold_fx = gold_convert_timers.has(pos)
            if not _has_edges and not _has_hit and not _has_gold_fx:
                var _btype = planet_data.blocks[pos].type
                if _btype == PlanetData.BlockType.NORMAL\
or _btype == PlanetData.BlockType.GOLD\
or (_btype == PlanetData.BlockType.ELECTRIC and not Global.electric_unlocked):
                    continue

            var block = planet_data.blocks[pos]
            var rect = Rect2(
                x * bs + BLOCK_GAP, y * bs + BLOCK_GAP, 
                bs - BLOCK_GAP * 2, bs - BLOCK_GAP * 2
            )


            var is_hit = _has_hit
            if is_hit:
                var hit_alpha = hit_timers[pos] / HIT_GLOW_DURATION
                var edge_col = _get_block_hit_edge(block, pos)
                draw_rect(rect, Color(edge_col.r, edge_col.g, edge_col.b, hit_alpha * 0.8), false, 3.0)


            if block.type == PlanetData.BlockType.CORE:
                _draw_core_overlay(rect, pos, block)
            elif block.type == PlanetData.BlockType.THORN:
                _draw_thorn_overlay(rect, pos, block)
            elif block.type == PlanetData.BlockType.ELECTRIC and Global.electric_unlocked:
                _draw_electric_overlay(rect, pos, block)
            else:

                var edge_color = _get_block_edge_for_type(block, pos)
                _draw_exposed_edges(rect, pos, edge_color)

                if block.type == PlanetData.BlockType.GOLD and Global.gold_unlocked:
                    var gp = (sin(time_elapsed * 1.8 + pos.x * 1.3 + pos.y * 0.7) + 1.0) * 0.5
                    var ga = 0.1 + gp * 0.12
                    var gc = Color(1.0, 0.85, 0.3, ga)
                    var m = bs * 0.25
                    var rx = rect.position.x
                    var ry = rect.position.y
                    var rw = rect.size.x
                    var rh = rect.size.y

                    draw_line(Vector2(rx, ry), Vector2(rx + m, ry), gc, 1.0)
                    draw_line(Vector2(rx, ry), Vector2(rx, ry + m), gc, 1.0)
                    draw_line(Vector2(rx + rw, ry), Vector2(rx + rw - m, ry), gc, 1.0)
                    draw_line(Vector2(rx + rw, ry), Vector2(rx + rw, ry + m), gc, 1.0)
                    draw_line(Vector2(rx, ry + rh), Vector2(rx + m, ry + rh), gc, 1.0)
                    draw_line(Vector2(rx, ry + rh), Vector2(rx, ry + rh - m), gc, 1.0)
                    draw_line(Vector2(rx + rw, ry + rh), Vector2(rx + rw - m, ry + rh), gc, 1.0)
                    draw_line(Vector2(rx + rw, ry + rh), Vector2(rx + rw, ry + rh - m), gc, 1.0)


            if _has_gold_fx:
                var gc_t = gold_convert_timers[pos] / GOLD_CONVERT_DURATION
                var fill_alpha = gc_t * 0.6
                draw_rect(rect, Color(GOLD_CONVERT_COLOR.r, GOLD_CONVERT_COLOR.g, GOLD_CONVERT_COLOR.b, fill_alpha))
                var expand = (1.0 - gc_t) * 4.0
                var glow_rect = rect.grow(expand)
                var edge_alpha = gc_t * 0.8
                draw_rect(glow_rect, Color(GOLD_CONVERT_COLOR.r, GOLD_CONVERT_COLOR.g, GOLD_CONVERT_COLOR.b, edge_alpha), false, 2.0)


    _draw_core_hp_bars(bs, grid_min, grid_max)


    _draw_shockwaves()


    _draw_arena_flash()


    _draw_lasers()


    _draw_autumn_debris()
    _draw_wind_leaves()


    _draw_cross_lasers()







func _get_block_hit_edge(block: Dictionary, pos: Vector2i) -> Color:
    if block.type == PlanetData.BlockType.CORE:
        var zone = block.get("zone", PlanetData.Zone.AUTUMN)
        return _get_core_zone_colors(zone).edge
    elif block.type == PlanetData.BlockType.ELECTRIC:
        var brightness = 1.0 if Global.electric_unlocked else ELECTRIC_LOCKED_DIM
        return Color(ELECTRIC_EDGE.r * brightness, ELECTRIC_EDGE.g * brightness, ELECTRIC_EDGE.b * brightness)
    elif block.type == PlanetData.BlockType.GOLD and Global.gold_unlocked:
        return GOLD_EDGE
    elif block.type == PlanetData.BlockType.GOLD:

        var hp = _hp_to_color_index(block.max_hp)
        var zone = block.get("zone", 0)
        return _get_zone_edge_color(hp, zone)
    elif block.type == PlanetData.BlockType.THORN:
        return THORN_EDGE
    elif block.get("regenerated", false):
        return REGEN_EDGE
    else:
        var hp = _hp_to_color_index(block.max_hp)
        var zone = block.get("zone", 0)
        return _get_zone_edge_color(hp, zone)


func _get_block_edge_for_type(block: Dictionary, pos: Vector2i) -> Color:
    if block.get("regenerated", false):
        return REGEN_EDGE
    elif block.type == PlanetData.BlockType.GOLD and Global.gold_unlocked:
        return GOLD_EDGE
    else:
        var hp = _hp_to_color_index(block.max_hp)
        var zone = block.get("zone", 0)
        return _get_zone_edge_color(hp, zone)


func _draw_core_overlay(rect: Rect2, pos: Vector2i, block: Dictionary):
    var hp_ratio = clampf(block.hp / block.max_hp, 0.0, 1.0)
    var damage_ratio = 1.0 - hp_ratio
    var zone = block.get("zone", PlanetData.Zone.AUTUMN)
    var zc = _get_core_zone_colors(zone)
    var c_edge = zc.edge
    var use_hp_visual = Global.core_detect_unlocked


    var hb_data = _get_heartbeat(block.core_id if block else -1)
    var edge = c_edge
    var edge_width = 2.0 + hb_data.beat * 1.5
    if use_hp_visual:
        edge = Color(
            c_edge.r + damage_ratio * 0.5, 
            c_edge.g + damage_ratio * 1.5, 
            c_edge.b + damage_ratio * 0.3
        )
    _draw_exposed_edges_width(rect, pos, edge, edge_width)


    if use_hp_visual and hp_ratio < 0.1:
        var crack_alpha = (0.1 - hp_ratio) / 0.1 * 0.8
        var crack_col = Color(3.0, 2.0, 0.5, crack_alpha)
        var cx = rect.position.x + rect.size.x * 0.5
        var cy = rect.position.y + rect.size.y * 0.5
        draw_line(Vector2(rect.position.x + 2, rect.position.y + 2), 
            Vector2(rect.end.x - 2, rect.end.y - 2), crack_col, 1.0)
        var jitter = sin(time_elapsed * 15.0 + pos.x * 5.0) * 3.0
        draw_line(Vector2(rect.end.x - 2, rect.position.y + 2), 
            Vector2(cx + jitter, cy), crack_col, 1.0)
        draw_line(Vector2(cx + jitter, cy), 
            Vector2(rect.position.x + 2, rect.end.y - 2), crack_col, 1.0)


    if planet_data.is_core_locked(block.core_id):
        var pulse = (sin(time_elapsed * 3.0) + 1.0) * 0.5
        var edge_alpha = 0.25 + pulse * 0.15
        draw_rect(rect, Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, edge_alpha), false, 1.5)


func _draw_electric_overlay(rect: Rect2, pos: Vector2i, block: Dictionary):
    var brightness = 1.0 if Global.electric_unlocked else ELECTRIC_LOCKED_DIM
    var edge_col = Color(ELECTRIC_EDGE.r * brightness, ELECTRIC_EDGE.g * brightness, ELECTRIC_EDGE.b * brightness)
    var pulse = (sin(time_elapsed * 4.0 + pos.x * 0.7 + pos.y * 0.5) + 1.0) * 0.5


    var bolt_a = (0.35 + pulse * 0.4) * brightness
    var bolt_col = Color(ELECTRIC_BOLT.r, ELECTRIC_BOLT.g, ELECTRIC_BOLT.b, bolt_a)
    var top_y = rect.position.y + rect.size.y * 0.15
    var bot_y = rect.position.y + rect.size.y * 0.85
    var cx = rect.position.x + rect.size.x * 0.5
    var w = rect.size.x * 0.3
    var seed_val = pos.x * 73 + pos.y * 137 + int(time_elapsed * 12.0)
    var jitter1 = (fmod(abs(sin(float(seed_val) * 0.7)), 1.0) - 0.5) * 2.0 * w
    var jitter2 = (fmod(abs(sin(float(seed_val) * 1.3)), 1.0) - 0.5) * 2.0 * w
    var mid_y = (top_y + bot_y) * 0.5
    var p0 = Vector2(cx, top_y)
    var p1 = Vector2(cx + jitter1, mid_y - rect.size.y * 0.1)
    var p2 = Vector2(cx + jitter2, mid_y + rect.size.y * 0.1)
    var p3 = Vector2(cx, bot_y)
    draw_line(p0, p1, bolt_col, 1.2)
    draw_line(p1, p2, bolt_col, 1.2)
    draw_line(p2, p3, bolt_col, 1.2)


    var border_a = (0.3 + pulse * 0.2) * brightness
    draw_rect(rect, Color(edge_col.r, edge_col.g, edge_col.b, border_a), false, 1.5)


    _draw_exposed_edges(rect, pos, edge_col)


func _draw_thorn_overlay(rect: Rect2, pos: Vector2i, block: Dictionary):

    var grow_ratio = 1.0
    var is_growing = false
    if block.has("birth_time"):
        var age = Time.get_ticks_msec() * 0.001 - block.birth_time
        if age < THORN_GROW_DURATION:
            is_growing = true
            var t = age / THORN_GROW_DURATION
            grow_ratio = 1.0 - (1.0 - t) * (1.0 - t)


    var draw_rect_area = rect
    if is_growing:
        var scale_f = 0.3 + grow_ratio * 0.7
        var center_v = rect.position + rect.size * 0.5
        var new_size = rect.size * scale_f
        draw_rect_area = Rect2(center_v - new_size * 0.5, new_size)

    var pulse_speed = 2.5 + (1.0 - grow_ratio) * 6.0
    var pulse = (sin(time_elapsed * pulse_speed + pos.x * 0.8 + pos.y * 0.6) + 1.0) * 0.5


    var x0 = draw_rect_area.position.x
    var y0 = draw_rect_area.position.y
    var x1 = draw_rect_area.end.x
    var y1 = draw_rect_area.end.y
    var cross_a = (0.15 + pulse * 0.15) * grow_ratio
    var cross_col = Color(THORN_SPIKE.r, THORN_SPIKE.g, THORN_SPIKE.b, cross_a)
    if grow_ratio > 0.4:
        draw_line(Vector2(x0 + 3, y0 + 3), Vector2(x1 - 3, y1 - 3), cross_col, 1.5)
        draw_line(Vector2(x1 - 3, y0 + 3), Vector2(x0 + 3, y1 - 3), cross_col, 1.5)


    var cx = draw_rect_area.position.x + draw_rect_area.size.x * 0.5
    var cy = draw_rect_area.position.y + draw_rect_area.size.y * 0.5
    var dot_base = 2.0 if not is_growing else 3.5
    var dot_size = dot_base + pulse * (1.5 if not is_growing else 3.0)
    var dot_a = 0.5 + pulse * 0.4
    var dot_col_r = lerpf(THORN_BIRTH_COLOR.r, THORN_SPIKE.r, grow_ratio)
    var dot_col_g = lerpf(THORN_BIRTH_COLOR.g, THORN_SPIKE.g, grow_ratio)
    var dot_col_b = lerpf(0.2, THORN_SPIKE.b, grow_ratio)
    var dot_col = Color(dot_col_r, dot_col_g, dot_col_b, dot_a)
    var dot_pts = PackedVector2Array([
        Vector2(cx, cy - dot_size), 
        Vector2(cx + dot_size, cy), 
        Vector2(cx, cy + dot_size), 
        Vector2(cx - dot_size, cy), 
    ])
    draw_colored_polygon(dot_pts, dot_col)


    var vein_a = 0.15 + pulse * 0.2
    if is_growing:
        vein_a = 0.3 + pulse * 0.35
    var vein_col = Color(THORN_VEIN_COLOR.r, THORN_VEIN_COLOR.g, THORN_VEIN_COLOR.b, vein_a)
    var tbs = draw_rect_area.size.x
    for dir in [Vector2i(1, 0), Vector2i(0, 1)]:
        var nb = pos + dir
        if planet_data.has_block(nb) and planet_data.get_block_type(nb) == PlanetData.BlockType.THORN:
            var nb_cx = cx + dir.x * tbs
            var nb_cy = cy + dir.y * tbs
            var mid_x = (cx + nb_cx) * 0.5 + sin(time_elapsed * 3.0 + pos.x + pos.y) * 2.5
            var mid_y = (cy + nb_cy) * 0.5 + cos(time_elapsed * 2.5 + pos.x * 0.7) * 2.5
            draw_line(Vector2(cx, cy), Vector2(mid_x, mid_y), vein_col, 1.2)
            draw_line(Vector2(mid_x, mid_y), Vector2(nb_cx, nb_cy), vein_col, 1.2)


    var hw = draw_rect_area.size.x * 0.5
    var hh = draw_rect_area.size.y * 0.5
    var spike_base = 5.0 + pulse * 2.5
    var spike_len = spike_base * (0.4 + grow_ratio * 0.6)
    var spike_w = 3.5 * (0.5 + grow_ratio * 0.5)
    var spike_a = 0.6 + pulse * 0.3
    var spike_r = lerpf(THORN_BIRTH_COLOR.r, THORN_SPIKE.r, grow_ratio)
    var spike_g = lerpf(THORN_BIRTH_COLOR.g * 0.5, THORN_SPIKE.g, grow_ratio)
    var spike_b = lerpf(0.15, THORN_SPIKE.b, grow_ratio)
    var spike_col = Color(spike_r, spike_g, spike_b, spike_a)
    var seed_val = pos.x * 53 + pos.y * 97

    if not planet_data.has_block(pos + Vector2i(0, -1)):
        var base_y = draw_rect_area.position.y
        _draw_spike_tri(Vector2(cx - hw * 0.5, base_y), Vector2(cx - hw * 0.5, base_y - spike_len), spike_w, spike_col)
        _draw_spike_tri(Vector2(cx + hw * 0.15, base_y), Vector2(cx + hw * 0.15, base_y - spike_len * 0.7), spike_w * 0.8, spike_col)
        if fmod(abs(float(seed_val)), 3.0) > 1.0:
            _draw_spike_tri(Vector2(cx + hw * 0.55, base_y), Vector2(cx + hw * 0.55, base_y - spike_len * 0.6), spike_w * 0.7, spike_col)
    if not planet_data.has_block(pos + Vector2i(0, 1)):
        var base_y = draw_rect_area.end.y
        _draw_spike_tri(Vector2(cx + hw * 0.4, base_y), Vector2(cx + hw * 0.4, base_y + spike_len), spike_w, spike_col)
        _draw_spike_tri(Vector2(cx - hw * 0.25, base_y), Vector2(cx - hw * 0.25, base_y + spike_len * 0.8), spike_w * 0.8, spike_col)
        if fmod(abs(float(seed_val)), 4.0) > 1.5:
            _draw_spike_tri(Vector2(cx - hw * 0.65, base_y), Vector2(cx - hw * 0.65, base_y + spike_len * 0.55), spike_w * 0.7, spike_col)
    if not planet_data.has_block(pos + Vector2i(-1, 0)):
        var base_x = draw_rect_area.position.x
        _draw_spike_tri(Vector2(base_x, cy - hh * 0.4), Vector2(base_x - spike_len, cy - hh * 0.4), spike_w, spike_col)
        _draw_spike_tri(Vector2(base_x, cy + hh * 0.3), Vector2(base_x - spike_len * 0.75, cy + hh * 0.3), spike_w * 0.8, spike_col)
    if not planet_data.has_block(pos + Vector2i(1, 0)):
        var base_x = draw_rect_area.end.x
        _draw_spike_tri(Vector2(base_x, cy + hh * 0.45), Vector2(base_x + spike_len, cy + hh * 0.45), spike_w, spike_col)
        _draw_spike_tri(Vector2(base_x, cy - hh * 0.2), Vector2(base_x + spike_len * 0.7, cy - hh * 0.2), spike_w * 0.8, spike_col)


    _draw_exposed_edges(draw_rect_area, pos, THORN_EDGE)





func _hp_to_color_index(max_hp: float) -> int:
    if max_hp <= 10:
        return 1
    var log_val = log(max_hp) / log(10.0)
    return clampi(int(log_val), 1, 10)





func _draw_exposed_edges(rect: Rect2, pos: Vector2i, color: Color):
    _draw_exposed_edges_width(rect, pos, color, 2.0)


func _draw_exposed_edges_width(rect: Rect2, pos: Vector2i, color: Color, width: float):

    var mask = planet_data.exposed_edges.get(pos, 0)
    if mask == 0:
        return

    var tl = rect.position
    var tr = Vector2(rect.end.x, rect.position.y)
    var bl = Vector2(rect.position.x, rect.end.y)
    var br = rect.end

    if mask & 1: draw_line(tl, tr, color, width)
    if mask & 2: draw_line(bl, br, color, width)
    if mask & 4: draw_line(tl, bl, color, width)
    if mask & 8: draw_line(tr, br, color, width)


func _draw_spike_tri(base: Vector2, tip: Vector2, half_width: float, col: Color):
    var dir = (tip - base).normalized()
    var perp = Vector2( - dir.y, dir.x)
    var pts = PackedVector2Array([
        base + perp * half_width, 
        base - perp * half_width, 
        tip, 
    ])
    draw_colored_polygon(pts, col)





func _draw_core_outer_glow(bs: int, grid_min: Vector2i, grid_max: Vector2i):
    for core in planet_data.cores:
        if not core.alive:
            continue

        var center = core.center
        if center.x < grid_min.x - 10 or center.x > grid_max.x + 10:
            continue
        if center.y < grid_min.y - 10 or center.y > grid_max.y + 10:
            continue

        var world_cx = center.x * bs + bs * 0.5
        var world_cy = center.y * bs + bs * 0.5
        var world_center = Vector2(world_cx, world_cy)


        var hb_data = _get_heartbeat(core.id)
        var heartbeat = hb_data.beat
        var core_damage = hb_data.damage

        var core_size: float = float(core.get("size", 3))

        var base_radius = bs * core_size * 1.2
        var glow_radius = base_radius + heartbeat * bs * 2.0


        var intensity = 0.02 + core_damage * 0.03
        var glow_col = _get_core_zone_colors(core.zone).pulse
        for i in range(4):
            var r = glow_radius * (1.0 - i * 0.2)
            var a = intensity + i * 0.015 + heartbeat * (0.02 + core_damage * 0.04)
            draw_circle(world_center, r, Color(glow_col.r, glow_col.g, glow_col.b, a))





func _draw_core_hp_bars(bs: int, grid_min: Vector2i, grid_max: Vector2i):
    if not Global.core_detect_unlocked:
        return

    for core in planet_data.cores:
        if not core.alive:
            continue

        var center = core.center

        if center.x < grid_min.x - 10 or center.x > grid_max.x + 10:
            continue
        if center.y < grid_min.y - 10 or center.y > grid_max.y + 10:
            continue

        var hp_ratio = _get_core_avg_hp(core)
        if hp_ratio >= 1.0:
            continue

        var core_size: int = core.get("size", 3)
        var half: int = core_size / 2
        var damage = 1.0 - hp_ratio


        var world_cx = center.x * bs + bs * 0.5
        var world_bottom = (center.y + half + 1) * bs + 6.0


        var bar_w = core_size * bs * 1.0
        var bar_h = 4.0
        var bar_x = world_cx - bar_w * 0.5


        var bg_rect = Rect2(bar_x - 1, world_bottom - 1, bar_w + 2, bar_h + 2)
        draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.6))



        var bar_color = Color(
            2.0 + damage * 1.0, 
            0.2 + damage * 1.5, 
            0.05 + damage * 0.3, 
            0.9
        )
        var fill_rect = Rect2(bar_x, world_bottom, bar_w * hp_ratio, bar_h)
        draw_rect(fill_rect, bar_color)


        if hp_ratio < 0.3:
            var flicker = abs(sin(time_elapsed * 10.0 + core.id * 3.7))
            var flash_alpha = (0.3 - hp_ratio) / 0.3 * flicker * 0.5
            draw_rect(fill_rect, Color(3.0, 2.0, 0.5, flash_alpha))





func _draw_dead_core_zones(bs: int):
    for core in planet_data.cores:
        if core.alive:
            continue

        var center = core.center
        var radius = core.influence_radius


        var world_cx = center.x * bs + bs * 0.5
        var world_cy = center.y * bs + bs * 0.5
        var world_center = Vector2(world_cx, world_cy)
        var world_radius = radius * bs


        var pulse = (sin(time_elapsed * 0.8) + 1.0) * 0.5
        var ring_alpha = 0.08 + pulse * 0.06


        draw_arc(world_center, world_radius, 0, TAU, 64, 
            Color(DEAD_ZONE_RING.r, DEAD_ZONE_RING.g, DEAD_ZONE_RING.b, ring_alpha), 2.0)


        draw_circle(world_center, world_radius, 
            Color(DEAD_ZONE_RING.r, DEAD_ZONE_RING.g, DEAD_ZONE_RING.b, 0.015))





func _draw_alive_core_zones(bs: int):
    for core in planet_data.cores:
        if not core.alive:
            continue

        var center = core.center
        var radius = planet_data.get_effective_influence_radius(core)

        var world_cx = center.x * bs + bs * 0.5
        var world_cy = center.y * bs + bs * 0.5
        var world_center = Vector2(world_cx, world_cy)
        var world_radius = radius * bs

        var pulse = (sin(time_elapsed * 1.5 + core.id * 0.7) + 1.0) * 0.5
        var zr = _get_core_zone_colors(core.zone)
        var ring_col = zr.zone_ring
        var fill_col = zr.zone_fill


        var fill_alpha = 0.025 + pulse * 0.015
        draw_circle(world_center, world_radius, 
            Color(fill_col.r, fill_col.g, fill_col.b, fill_alpha))


        var ring_alpha = 0.35 + pulse * 0.15
        draw_arc(world_center, world_radius, 0, TAU, 64, 
            Color(ring_col.r, ring_col.g, ring_col.b, ring_alpha), 3.0)


        var glow_alpha = 0.1 + pulse * 0.06
        draw_arc(world_center, world_radius + 4, 0, TAU, 64, 
            Color(ring_col.r, ring_col.g, ring_col.b, glow_alpha), 5.0)







func _draw_shield_domes(bs: int):
    if not planet_data:
        return

    for core in planet_data.cores:
        if not core.alive:
            continue
        if not planet_data.is_core_locked(core.id):
            continue

        var center = core.center
        var core_size: int = core.get("size", 3)

        var dome_radius = (core_size * 0.5 + 2.0) * bs
        var world_cx = center.x * bs + bs * 0.5
        var world_cy = center.y * bs + bs * 0.5
        var world_center = Vector2(world_cx, world_cy)


        var pulse = (sin(time_elapsed * 2.0 + core.id * 0.5) + 1.0) * 0.5
        var fill_alpha = 0.04 + pulse * 0.03
        draw_circle(world_center, dome_radius, Color(SHIELD_DOME_COLOR.r, SHIELD_DOME_COLOR.g, SHIELD_DOME_COLOR.b, fill_alpha))


        var ring_alpha = 0.15 + pulse * 0.1
        var segments = 32
        var arc_len = TAU / segments * 0.5
        for i in range(segments):
            var angle_start = (TAU / segments) * i + time_elapsed * 0.3
            draw_arc(world_center, dome_radius, angle_start, angle_start + arc_len, 6, 
                Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, ring_alpha), 2.0)





func _draw_shockwaves():
    for sw in shockwave_effects:
        var progress = 1.0 - (sw.timer / SHOCKWAVE_DURATION)
        var current_radius = sw.max_radius * progress
        var alpha = (1.0 - progress) * 0.6


        var ring_width = 4.0 + (1.0 - progress) * 3.0
        draw_arc(sw.center, current_radius, 0, TAU, 48, 
            Color(SHOCKWAVE_COLOR.r, SHOCKWAVE_COLOR.g, SHOCKWAVE_COLOR.b, alpha), ring_width)


        var inner_alpha = alpha * 0.3
        draw_arc(sw.center, current_radius * 0.7, 0, TAU, 32, 
            Color(SHOCKWAVE_COLOR.r * 0.7, SHOCKWAVE_COLOR.g * 0.7, SHOCKWAVE_COLOR.b * 0.7, inner_alpha), 2.0)


        if progress < 0.3:
            var core_glow = (0.3 - progress) / 0.3 * 0.4
            draw_circle(sw.center, 20.0, Color(SHOCKWAVE_COLOR.r, SHOCKWAVE_COLOR.g, SHOCKWAVE_COLOR.b, core_glow))





func _draw_arena_flash():
    if arena_flash_rings.is_empty():
        return
    var bs = PlanetData.BLOCK_SIZE
    for ring_data in arena_flash_rings:
        var t = ring_data.timer / ARENA_FLASH_DURATION

        var alpha = t * t * 0.7
        var expand = (1.0 - t) * 6.0
        var flash_col = Color(ARENA_FLASH_COLOR.r, ARENA_FLASH_COLOR.g, ARENA_FLASH_COLOR.b, alpha)
        for pos in ring_data.positions:
            var rect = Rect2(
                pos.x * bs - expand, pos.y * bs - expand, 
                bs + expand * 2, bs + expand * 2
            )
            draw_rect(rect, flash_col)





func _draw_lasers():
    if zone_threat == null:
        return

    for cid in zone_threat.laser_states:
        var ls = zone_threat.laser_states[cid]
        var origin = ls.origin
        var dir = ls.dir

        var laser_len = ls.get("influence_radius", 22) * PlanetData.BLOCK_SIZE
        var beam_end = origin + dir * laser_len

        match ls.state:
            "warning":
                _draw_laser_warning(origin, dir, beam_end, ls)
            "firing":
                _draw_laser_beam(origin, dir, beam_end, ls)


func _draw_laser_warning(origin: Vector2, dir: Vector2, beam_end: Vector2, ls: Dictionary):
    var warn_progress = ls.timer / ls.warn_time


    var dash_len = 12.0
    var gap_len = 8.0
    var total_len = origin.distance_to(beam_end)
    var traveled = 0.0

    var line_alpha = 0.3 + warn_progress * 0.5
    var line_width = 1.5 + warn_progress * 1.0
    var warn_col = Color(LASER_WARN_COLOR.r, LASER_WARN_COLOR.g, LASER_WARN_COLOR.b, line_alpha)

    while traveled < total_len:
        var seg_start = origin + dir * traveled
        var seg_end_dist = minf(traveled + dash_len, total_len)
        var seg_end = origin + dir * seg_end_dist
        draw_line(seg_start, seg_end, warn_col, line_width)
        traveled += dash_len + gap_len


    var charge_size = 15.0 + warn_progress * 20.0
    var charge_alpha = 0.3 + warn_progress * 0.5
    var pulse = (sin(time_elapsed * 12.0) + 1.0) * 0.5
    charge_size += pulse * 5.0
    var charge_col = Color(LASER_CORE_CHARGE.r, LASER_CORE_CHARGE.g, LASER_CORE_CHARGE.b, charge_alpha)
    draw_circle(origin, charge_size, charge_col)


    var core_dot_size = 3.0 + warn_progress * 4.0 + pulse * 2.0
    draw_circle(origin, core_dot_size, Color(1.0, 0.9, 0.7, charge_alpha * 0.8))


func _draw_laser_beam(origin: Vector2, dir: Vector2, beam_end: Vector2, ls: Dictionary):
    var fire_progress = ls.timer / ZoneThreatSystem.LASER_FIRE_DURATION

    var intensity = 1.0 - fire_progress * 0.5
    var beam_width = ZoneThreatSystem.LASER_WIDTH


    var outer_alpha = 0.15 * intensity
    var outer_col = Color(LASER_FIRE_COLOR.r * 0.6, LASER_FIRE_COLOR.g * 0.4, LASER_FIRE_COLOR.b * 0.2, outer_alpha)
    var perp = Vector2( - dir.y, dir.x)
    var outer_w = beam_width * 2.0
    var pts_outer = PackedVector2Array([
        origin + perp * outer_w * 0.5, 
        origin - perp * outer_w * 0.5, 
        beam_end - perp * outer_w * 0.5, 
        beam_end + perp * outer_w * 0.5, 
    ])
    draw_colored_polygon(pts_outer, outer_col)


    var pulse = (sin(time_elapsed * 25.0) + 1.0) * 0.5
    var main_alpha = (0.7 + pulse * 0.3) * intensity
    var main_col = Color(LASER_FIRE_COLOR.r, LASER_FIRE_COLOR.g, LASER_FIRE_COLOR.b, main_alpha)
    var pts_main = PackedVector2Array([
        origin + perp * beam_width * 0.5, 
        origin - perp * beam_width * 0.5, 
        beam_end - perp * beam_width * 0.5, 
        beam_end + perp * beam_width * 0.5, 
    ])
    draw_colored_polygon(pts_main, main_col)


    var core_alpha = (0.8 + pulse * 0.2) * intensity
    var core_col = Color(1.0, 0.95, 0.7, core_alpha)
    var core_width = beam_width * 0.3
    draw_line(origin, beam_end, core_col, core_width)


    var flash_size = 25.0 + pulse * 10.0
    var flash_alpha = 0.4 * intensity
    draw_circle(origin, flash_size, Color(LASER_FIRE_COLOR.r, LASER_FIRE_COLOR.g, LASER_FIRE_COLOR.b, flash_alpha))
    draw_circle(origin, flash_size * 0.4, Color(1.0, 0.95, 0.8, flash_alpha * 1.5))







const LEAF_COLORS: Array = [
    Color(3.5, 1.0, 0.15), 
    Color(3.0, 0.5, 0.1), 
    Color(3.5, 1.5, 0.2), 
    Color(3.0, 0.3, 0.08), 
]

func _draw_autumn_debris():
    if zone_threat == null:
        return
    if zone_threat.debris_list.is_empty():
        return

    for d in zone_threat.debris_list:
        var pos: Vector2 = d.pos
        var rot: float = d.rot
        var sz: float = d.size
        var lifetime: float = d.lifetime


        var fade = 1.0
        if lifetime < 1.0:
            fade = lifetime


        var col_idx = d.core_id % LEAF_COLORS.size()
        var leaf_col = LEAF_COLORS[col_idx]


        if d.trail.size() >= 2:
            for ti in range(d.trail.size() - 1):
                var t_alpha = float(ti) / d.trail.size() * 0.25 * fade
                var t_width = sz * 3.0 * (float(ti) / d.trail.size())
                draw_line(d.trail[ti], d.trail[ti + 1], 
                    Color(leaf_col.r, leaf_col.g, leaf_col.b, t_alpha), t_width)


        var pulse = (sin(time_elapsed * 8.0 + d.rot) + 1.0) * 0.5
        var warn_radius = sz * 12.0 + pulse * 5.0

        draw_circle(pos, warn_radius, 
            Color(1.0, 0.85, 0.3, 0.25 * fade))

        draw_circle(pos, warn_radius * 0.6, 
            Color(1.0, 0.7, 0.15, 0.35 * fade))

        draw_circle(pos, sz * 4.0 + pulse * 2.0, 
            Color(1.0, 0.95, 0.7, 0.7 * fade))


        var leaf_points = _make_leaf_polygon(pos, rot, sz * 14.0)
        var body_alpha = 0.9 * fade
        draw_colored_polygon(leaf_points, 
            Color(0.8, 0.25, 0.05, body_alpha))


        var edge_alpha = 0.95 * fade
        var edge_col = Color(1.0, 0.7, 0.15, edge_alpha)
        for pi in range(leaf_points.size()):
            var p1 = leaf_points[pi]
            var p2 = leaf_points[(pi + 1) % leaf_points.size()]
            draw_line(p1, p2, edge_col, 2.5)


func _make_leaf_polygon(center: Vector2, rotation: float, size: float) -> PackedVector2Array:

    var pts: Array = []
    var s = size

    pts.append(Vector2(0, - s))
    pts.append(Vector2(s * 0.45, - s * 0.5))
    pts.append(Vector2(s * 0.5, 0))
    pts.append(Vector2(s * 0.3, s * 0.5))
    pts.append(Vector2(0, s * 0.8))
    pts.append(Vector2( - s * 0.3, s * 0.5))
    pts.append(Vector2( - s * 0.5, 0))
    pts.append(Vector2( - s * 0.45, - s * 0.5))


    var result = PackedVector2Array()
    for p in pts:
        var rotated = p.rotated(rotation)
        result.append(center + rotated)

    return result






const WIND_LEAF_COLORS: Array = [
    Color(1.0, 0.5, 0.15), 
    Color(0.9, 0.35, 0.1), 
    Color(1.1, 0.6, 0.2), 
    Color(0.8, 0.3, 0.08), 
]

func _draw_wind_leaves():
    if zone_threat == null:
        return
    if zone_threat.wind_leaves.is_empty():
        return

    for leaf in zone_threat.wind_leaves:
        var pos: Vector2 = leaf.pos
        var rot: float = leaf.rot
        var sz: float = leaf.size
        var lifetime: float = leaf.lifetime
        var max_lt: float = leaf.max_lifetime


        var fade = 1.0
        var age = max_lt - lifetime
        if age < 0.3:
            fade = age / 0.3
        elif lifetime < 0.5:
            fade = lifetime / 0.5


        var col_idx = int(leaf.sway_phase * 10.0) % WIND_LEAF_COLORS.size()
        var col = WIND_LEAF_COLORS[col_idx]


        var leaf_pts = _make_leaf_polygon(pos, rot, sz)
        var body_alpha = 0.5 * fade
        draw_colored_polygon(leaf_pts, 
            Color(col.r * 0.25, col.g * 0.15, col.b * 0.08, body_alpha))


        var edge_alpha = 0.6 * fade
        var edge_col = Color(col.r, col.g, col.b, edge_alpha)
        for pi in range(leaf_pts.size()):
            var p1 = leaf_pts[pi]
            var p2 = leaf_pts[(pi + 1) % leaf_pts.size()]
            draw_line(p1, p2, edge_col, 1.0)






const CROSS_LASER_OUTER_COLOR: Color = Color(0.3, 1.5, 2.5)
const CROSS_LASER_INNER_COLOR: Color = Color(0.8, 2.0, 2.8)
const CROSS_LASER_CORE_COLOR: Color = Color(1.0, 1.0, 1.0)

func _draw_cross_lasers():
    if zone_threat == null:
        return
    if zone_threat.cross_laser_states.is_empty():
        return

    for cid in zone_threat.cross_laser_states:
        var ls = zone_threat.cross_laser_states[cid]
        var origin: Vector2 = ls.origin
        var length: float = ls.length
        var angle: float = ls.angle
        var speed: float = ls.speed


        var intensity = remap(speed, 0.5, 1.6, 0.6, 1.0)
        intensity = clampf(intensity, 0.6, 1.0)


        var pulse = (sin(time_elapsed * 4.0 + angle) + 1.0) * 0.5


        var core_edge = ls.get("core_edge_ratio", 0.15)
        var gaps = ls.get("gaps", [])


        for arm_i in range(4):
            var arm_angle = angle + arm_i * (PI * 0.5)
            var arm_dir = Vector2.from_angle(arm_angle)


            var gap_pos: float = 0.5
            var gap_half: float = 0.06
            if arm_i < gaps.size():
                gap_pos = gaps[arm_i].pos
                gap_half = zone_threat.CROSS_LASER_GAP_SIZE * 0.5

            var gap_start_t = clampf(gap_pos - gap_half, core_edge, 1.0)
            var gap_end_t = clampf(gap_pos + gap_half, core_edge, 1.0)


            var seg_a_start = origin + arm_dir * length * core_edge
            var seg_a_end = origin + arm_dir * length * gap_start_t

            var seg_b_start = origin + arm_dir * length * gap_end_t
            var seg_b_end = origin + arm_dir * length


            var glow_width = 28.0 + pulse * 6.0
            var glow_alpha = 0.15 * intensity
            var glow_col = Color(CROSS_LASER_OUTER_COLOR.r, CROSS_LASER_OUTER_COLOR.g, CROSS_LASER_OUTER_COLOR.b, glow_alpha)

            var beam_width = 12.0 + pulse * 3.0
            var beam_alpha = 0.5 * intensity
            var beam_col = Color(CROSS_LASER_INNER_COLOR.r, CROSS_LASER_INNER_COLOR.g, CROSS_LASER_INNER_COLOR.b, beam_alpha)

            var core_width = 3.0 + pulse * 1.5
            var core_alpha = 0.7 * intensity
            var core_col = Color(CROSS_LASER_CORE_COLOR.r, CROSS_LASER_CORE_COLOR.g, CROSS_LASER_CORE_COLOR.b, core_alpha)


            if seg_a_start.distance_to(seg_a_end) > 2.0:
                draw_line(seg_a_start, seg_a_end, glow_col, glow_width)
                draw_line(seg_a_start, seg_a_end, beam_col, beam_width)
                draw_line(seg_a_start, seg_a_end, core_col, core_width)


            if seg_b_start.distance_to(seg_b_end) > 2.0:
                draw_line(seg_b_start, seg_b_end, glow_col, glow_width)
                draw_line(seg_b_start, seg_b_end, beam_col, beam_width)
                draw_line(seg_b_start, seg_b_end, core_col, core_width)


        var flash_size = 20.0 + pulse * 8.0
        var flash_alpha = 0.3 * intensity
        draw_circle(origin, flash_size, 
            Color(CROSS_LASER_OUTER_COLOR.r, CROSS_LASER_OUTER_COLOR.g, CROSS_LASER_OUTER_COLOR.b, flash_alpha))
        draw_circle(origin, flash_size * 0.35, 
            Color(CROSS_LASER_CORE_COLOR.r, CROSS_LASER_CORE_COLOR.g, CROSS_LASER_CORE_COLOR.b, flash_alpha * 1.5))
