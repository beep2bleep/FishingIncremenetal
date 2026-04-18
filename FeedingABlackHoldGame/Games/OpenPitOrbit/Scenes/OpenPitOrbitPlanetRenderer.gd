extends Node2D
class_name OpenPitOrbitPlanetRenderer

var scene_ref: OpenPitOrbitMain
var _force_redraw := true
var _last_cam_origin := Vector2.INF
var _fill_image: Image
var _fill_texture: ImageTexture
var _fill_grid_size := Vector2i.ZERO
var _fill_grid_origin := Vector2i(2147483647, 2147483647)
var _fill_dirty := true
var _time_elapsed := 0.0
var _palette_cache: Dictionary = {}
var _screen_stars: Array[Dictionary] = []

const SPACE_BG := Color(0.025, 0.025, 0.035, 1.0)
const HIT_GLOW := Color(2.3, 1.2, 0.4, 0.55)
const GOLD_GLOW := Color(2.6, 2.0, 0.4, 0.45)
const STAR_COLORS := [
    Color(1.0, 0.96, 0.9, 1.0),
    Color(0.95, 0.98, 1.0, 1.0),
    Color(0.86, 0.96, 1.0, 1.0),
]
const SCREEN_STAR_COUNT := 90
const BLOCK_GAP := 1.5
const LOCAL_SHOCKWAVE_VISUAL_RADIUS := 96.0
const ZONE_SPRING := 0
const ZONE_SUMMER := 1
const ZONE_AUTUMN := 2
const ZONE_WINTER := 3
const ZONE_CENTER := 4
const ZONE_FILLS := {
    ZONE_SPRING: Color(0.07, 0.15, 0.09, 1.0),
    ZONE_SUMMER: Color(0.19, 0.15, 0.06, 1.0),
    ZONE_AUTUMN: Color(0.18, 0.08, 0.06, 1.0),
    ZONE_WINTER: Color(0.07, 0.09, 0.19, 1.0),
    ZONE_CENTER: Color(0.13, 0.08, 0.17, 1.0),
}
const ZONE_EDGE_COLORS := {
    ZONE_SPRING: Color(0.3, 1.8, 0.5),
    ZONE_SUMMER: Color(2.0, 1.8, 0.3),
    ZONE_AUTUMN: Color(2.0, 0.35, 0.1),
    ZONE_WINTER: Color(0.5, 1.2, 2.2),
    ZONE_CENTER: Color(1.2, 0.4, 2.0),
}
const ZONE_RING_COLORS := {
    ZONE_SPRING: Color(0.3, 1.5, 0.4, 0.3),
    ZONE_SUMMER: Color(2.0, 1.5, 0.2, 0.3),
    ZONE_AUTUMN: Color(2.0, 0.3, 0.08, 0.3),
    ZONE_WINTER: Color(0.3, 0.8, 2.0, 0.3),
    ZONE_CENTER: Color(1.2, 0.25, 2.0, 0.3),
}
const THORN_FILL := Color(0.04, 0.01, 0.03, 1.0)
const THORN_EDGE := Color(2.0, 0.4, 1.5, 1.0)
const REGEN_FILL := Color(0.06, 0.015, 0.015, 1.0)
const REGEN_EDGE := Color(1.2, 0.2, 0.08, 1.0)

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _rebuild_screen_stars()

func mark_dirty() -> void:
    _force_redraw = true
    _fill_dirty = true
    _palette_cache.clear()

func _process(_delta: float) -> void:
    _time_elapsed += _delta
    var needs_redraw := _force_redraw
    _force_redraw = false
    var cam_origin := get_canvas_transform().origin
    if cam_origin != _last_cam_origin:
        _last_cam_origin = cam_origin
        needs_redraw = true
    if not scene_ref.hit_timers.is_empty() or not scene_ref.gold_convert_timers.is_empty():
        needs_redraw = true
    if not scene_ref.shockwave_rings.is_empty():
        needs_redraw = true
    if needs_redraw:
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    var canvas_transform := get_canvas_transform()
    var viewport_size := get_viewport_rect().size
    var cam_scale := canvas_transform.get_scale()
    var top_left := -canvas_transform.origin / cam_scale
    var bottom_right := top_left + viewport_size / cam_scale
    draw_rect(Rect2(top_left, viewport_size / cam_scale), SPACE_BG, true)
    _draw_background_stars()
    _draw_core_zones()

    var margin := scene_ref.BLOCK_SIZE * 2.0
    var grid_min := scene_ref.world_to_grid(top_left - Vector2(margin, margin))
    var grid_max := scene_ref.world_to_grid(bottom_right + Vector2(margin, margin))
    var grid_w: int = grid_max.x - grid_min.x + 1
    var grid_h: int = grid_max.y - grid_min.y + 1
    var fill_needs_rebuild := _fill_dirty or _fill_grid_origin != grid_min or _fill_grid_size != Vector2i(grid_w, grid_h)

    if _fill_image == null or _fill_grid_size.x != grid_w or _fill_grid_size.y != grid_h:
        _fill_image = Image.create(grid_w, grid_h, false, Image.FORMAT_RGBA8)
        _fill_grid_size = Vector2i(grid_w, grid_h)
        _fill_grid_origin = grid_min
        _fill_texture = null
        fill_needs_rebuild = true
    if fill_needs_rebuild:
        _fill_grid_origin = grid_min
        _fill_image.fill(Color.TRANSPARENT)
        for x in range(grid_min.x, grid_max.x + 1):
            for y in range(grid_min.y, grid_max.y + 1):
                var grid := Vector2i(x, y)
                var block: Dictionary = scene_ref.blocks.get(grid, {})
                if block.is_empty():
                    continue
                var colors: Dictionary = _get_block_palette(block)
                _fill_image.set_pixel(x - grid_min.x, y - grid_min.y, colors.get("fill", Color.WHITE))
        if _fill_texture == null:
            _fill_texture = ImageTexture.create_from_image(_fill_image)
        else:
            _fill_texture.update(_fill_image)
        _fill_dirty = false
    var tex_rect := Rect2(
        float(grid_min.x) * scene_ref.BLOCK_SIZE,
        float(grid_min.y) * scene_ref.BLOCK_SIZE,
        float(grid_w) * scene_ref.BLOCK_SIZE,
        float(grid_h) * scene_ref.BLOCK_SIZE
    )
    if _fill_texture != null:
        draw_texture_rect(_fill_texture, tex_rect, false)

    var gold_pulse_t := Time.get_ticks_msec() * 0.001 * 1.8
    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var colors: Dictionary = _get_block_palette(block)
            var world := scene_ref.grid_to_world(grid)
            var rect := Rect2(
                world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
                Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
            )
            if scene_ref.exposed_edges.has(grid):
                _draw_block_edges(grid, rect, colors.get("edge", Color.WHITE), int(scene_ref.exposed_edges.get(grid, 0)), 2.0)

            var health_ratio := scene_ref.get_block_hp_ratio(grid)
            if health_ratio < 0.999:
                draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2(rect.size.x - 6.0, 3.0)), Color(0.0, 0.0, 0.0, 0.55), true)
                draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2((rect.size.x - 6.0) * health_ratio, 3.0)), Color(0.6, 1.8, 2.4, 0.9), true)

            var hit_timer: float = float(scene_ref.hit_timers.get(grid, 0.0))
            if hit_timer > 0.0:
                draw_rect(rect.grow(-2.0), Color(HIT_GLOW.r, HIT_GLOW.g, HIT_GLOW.b, hit_timer / scene_ref.HIT_FLASH_DURATION), false, 2.0)
            var gold_timer: float = float(scene_ref.gold_convert_timers.get(grid, 0.0))
            if gold_timer > 0.0:
                draw_rect(rect.grow(-2.0), Color(GOLD_GLOW.r, GOLD_GLOW.g, GOLD_GLOW.b, gold_timer / scene_ref.GOLD_CONVERT_DURATION), false, 2.0)
            if int(block.get("type", 0)) == scene_ref.BlockType.GOLD and bool(scene_ref.runtime_stats.get("gold_enabled", false)):
                var gp := (sin(gold_pulse_t + grid.x * 1.3 + grid.y * 0.7) + 1.0) * 0.5
                var ga := 0.1 + gp * 0.12
                var gc := Color(1.0, 0.85, 0.3, ga)
                var m := scene_ref.BLOCK_SIZE * 0.25
                var rx := rect.position.x
                var ry := rect.position.y
                var rw := rect.size.x
                var rh := rect.size.y
                draw_line(Vector2(rx, ry), Vector2(rx + m, ry), gc, 1.0)
                draw_line(Vector2(rx, ry), Vector2(rx, ry + m), gc, 1.0)
                draw_line(Vector2(rx + rw, ry), Vector2(rx + rw - m, ry), gc, 1.0)
                draw_line(Vector2(rx + rw, ry), Vector2(rx + rw, ry + m), gc, 1.0)
                draw_line(Vector2(rx, ry + rh), Vector2(rx + m, ry + rh), gc, 1.0)
                draw_line(Vector2(rx, ry + rh), Vector2(rx, ry + rh - m), gc, 1.0)
                draw_line(Vector2(rx + rw, ry + rh), Vector2(rx + rw - m, ry + rh), gc, 1.0)
                draw_line(Vector2(rx + rw, ry + rh), Vector2(rx + rw, ry + rh - m), gc, 1.0)

    draw_arc(scene_ref.spawn_position, scene_ref.return_zone_radius, 0.0, TAU, 64, Color(0.3, 1.5, 0.5, 0.25), 2.0)
    for ring in scene_ref.shockwave_rings:
        var radius: float = minf(float(ring.get("radius", 0.0)), LOCAL_SHOCKWAVE_VISUAL_RADIUS)
        if radius <= 0.0:
            continue
        var alpha: float = clampf(float(ring.get("alpha", 0.0)), 0.0, 1.0)
        if radius >= LOCAL_SHOCKWAVE_VISUAL_RADIUS:
            alpha *= 0.2
        draw_arc(
            scene_ref.ship_pos,
            radius,
            0.0,
            TAU,
            48,
            Color(1.0, 0.85, 0.2, alpha),
            2.0
        )

    _draw_summer_lasers()
    _draw_autumn_debris()
    _draw_winter_cross_lasers()
    _draw_core_shields()

func _draw_background_stars() -> void:
    var canvas_transform := get_canvas_transform()
    var cam_scale := canvas_transform.get_scale()
    var cam_world := -canvas_transform.origin / cam_scale
    var viewport_size := get_viewport_rect().size
    if _screen_stars.is_empty():
        _rebuild_screen_stars()
    for star in _screen_stars:
        var uv: Vector2 = star.get("uv", Vector2.ZERO)
        var pos := cam_world + Vector2(uv.x * viewport_size.x, uv.y * viewport_size.y)
        var twinkle_seed: float = float(star.get("twinkle_seed", 0.0))
        var alpha := float(star.get("alpha", 0.6)) * (0.82 + 0.18 * sin(_time_elapsed * (0.7 + twinkle_seed * 1.2) + twinkle_seed * TAU))
        alpha = clampf(alpha, 0.12, 1.0)
        var color: Color = star.get("color", Color.WHITE)
        var size_px: float = float(star.get("size", 1.2))
        if size_px > 1.35:
            draw_circle(pos, size_px * 1.8, Color(color.r, color.g, color.b, alpha * 0.14))
        draw_circle(pos, size_px, Color(color.r, color.g, color.b, alpha))

func _rebuild_screen_stars() -> void:
    _screen_stars.clear()
    for idx in range(SCREEN_STAR_COUNT):
        var seed := _star_hash_float(float(idx) * 3.17)
        var color_idx := mini(int(floor(_star_hash_float(float(idx) * 4.91) * float(STAR_COLORS.size()))), STAR_COLORS.size() - 1)
        _screen_stars.append({
            "uv": Vector2(_star_hash_float(float(idx) * 1.37), _star_hash_float(float(idx) * 2.71)),
            "size": lerpf(0.8, 2.2, seed),
            "alpha": lerpf(0.28, 0.85, _star_hash_float(float(idx) * 5.73)),
            "color": STAR_COLORS[color_idx],
            "twinkle_seed": _star_hash_float(float(idx) * 7.11),
        })

func _star_hash_float(seed: float) -> float:
    var n := sin(seed * 127.1 + 311.7) * 43758.5453
    return n - floor(n)

func _draw_block_edges(_grid: Vector2i, rect: Rect2, color: Color, mask: int, width: float) -> void:
    if (mask & 1) != 0:
        draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), color, width)
    if (mask & 2) != 0:
        draw_line(rect.position + Vector2(0.0, rect.size.y), rect.position + rect.size, color, width)
    if (mask & 4) != 0:
        draw_line(rect.position, rect.position + Vector2(0.0, rect.size.y), color, width)
    if (mask & 8) != 0:
        draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + rect.size, color, width)

func _get_block_palette(block: Dictionary) -> Dictionary:
    var zone: int = int(block.get("zone", ZONE_AUTUMN))
    var block_type: int = int(block.get("type", 0))
    var regenerated: bool = bool(block.get("regenerated", false))
    var electric_enabled: bool = bool(scene_ref.runtime_stats.get("electric_enabled", false))
    var gold_enabled: bool = bool(scene_ref.runtime_stats.get("gold_enabled", false))
    var cache_key := "%d:%d:%d:%d:%d" % [zone, block_type, int(regenerated), int(electric_enabled), int(gold_enabled)]
    if _palette_cache.has(cache_key):
        return _palette_cache[cache_key]
    var fill: Color = ZONE_FILLS.get(zone, SPACE_BG)
    var edge: Color = ZONE_EDGE_COLORS.get(zone, Color.WHITE)
    match block_type:
        scene_ref.BlockType.CORE:
            fill = _mix_fill_with_edge(ZONE_FILLS.get(zone, Color(0.11, 0.07, 0.08, 1.0)), ZONE_EDGE_COLORS.get(zone, Color(1.0, 1.0, 1.0, 1.0)), 0.32)
            edge = ZONE_EDGE_COLORS.get(zone, Color(2.5, 0.3, 0.08, 1.0))
        scene_ref.BlockType.ELECTRIC:
            fill = Color(0.08, 0.17, 0.23, 1.0) if electric_enabled else _mix_fill_with_edge(fill, edge, 0.18).darkened(0.15)
            edge = Color(0.5, 1.8, 2.5, 1.0)
        scene_ref.BlockType.GOLD:
            fill = Color(0.24, 0.18, 0.07, 1.0) if gold_enabled else _mix_fill_with_edge(fill, edge, 0.22).darkened(0.08)
            edge = Color(2.0, 1.6, 0.3, 1.0)
        scene_ref.BlockType.THORN:
            fill = _mix_fill_with_edge(THORN_FILL, THORN_EDGE, 0.24)
            edge = THORN_EDGE
        _:
            if regenerated:
                fill = _mix_fill_with_edge(REGEN_FILL, REGEN_EDGE, 0.22)
                edge = REGEN_EDGE
            else:
                fill = _mix_fill_with_edge(fill, edge, 0.22)
    var palette := {"fill": fill, "edge": edge}
    _palette_cache[cache_key] = palette
    return palette

func _mix_fill_with_edge(fill: Color, edge: Color, amount: float) -> Color:
    var edge_clamped := Color(min(edge.r, 1.0), min(edge.g, 1.0), min(edge.b, 1.0), 1.0)
    return fill.lerp(edge_clamped, amount)

func _draw_core_zones() -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    for core in scene_ref.planet_data.cores:
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var world_radius := float(scene_ref.planet_data.get_effective_influence_radius(core)) * scene_ref.BLOCK_SIZE
        if bool(core.alive):
            var zone_col: Color = ZONE_RING_COLORS.get(int(core.zone), Color(1.0, 0.2, 0.1, 0.25))
            draw_circle(center, world_radius, Color(zone_col.r, zone_col.g, zone_col.b, zone_col.a * 0.14))
            draw_arc(center, world_radius, 0.0, TAU, 64, zone_col, 1.5)
        else:
            draw_circle(center, world_radius, Color(0.15, 0.8, 1.0, 0.06))
            draw_arc(center, world_radius, 0.0, TAU, 64, Color(0.15, 0.8, 1.0, 0.12), 1.0)

func _draw_core_shields() -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    for core in scene_ref.planet_data.cores:
        if not bool(core.alive):
            continue
        if not scene_ref.planet_data.is_core_locked(int(core.id), scene_ref._core_unlocks_center()):
            continue
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var dome_radius := (float(int(core.get("size", 3))) * 0.5 + 2.0) * scene_ref.BLOCK_SIZE
        draw_circle(center, dome_radius, Color(0.2, 0.5, 1.0, 0.08))
        draw_arc(center, dome_radius, 0.0, TAU, 40, Color(0.3, 0.6, 1.0, 0.65), 1.5)

func _draw_summer_lasers() -> void:
    for state_variant in scene_ref.summer_laser_states.values():
        var state: Dictionary = state_variant
        var origin: Vector2 = state.get("origin", Vector2.ZERO)
        var dir: Vector2 = Vector2(state.get("dir", Vector2.RIGHT)).normalized()
        if dir.length() < 0.01:
            continue
        var end := origin + dir * scene_ref.BLOCK_SIZE * 40.0
        var color := Color(2.2, 0.9, 0.2, 0.9)
        if str(state.get("state", "idle")) == "warning":
            var pulse := 0.35 + 0.25 * (sin(_time_elapsed * 10.0) + 1.0) * 0.5
            draw_line(origin, end, Color(color.r, color.g, color.b, pulse), 3.0)
        elif str(state.get("state", "idle")) == "firing":
            draw_line(origin, end, Color(color.r, color.g, color.b, 0.2), 12.0)
            draw_line(origin, end, color, 3.0)

func _draw_autumn_debris() -> void:
    for debris_variant in scene_ref.autumn_debris:
        var debris: Dictionary = debris_variant
        var pos: Vector2 = debris.get("pos", Vector2.ZERO)
        draw_circle(pos, 8.0, Color(1.0, 0.35, 0.12, 0.12))
        draw_circle(pos, 4.0, Color(1.0, 0.45, 0.18, 0.95))

func _draw_winter_cross_lasers() -> void:
    for state_variant in scene_ref.winter_cross_lasers.values():
        var state: Dictionary = state_variant
        var origin: Vector2 = state.get("origin", Vector2.ZERO)
        var length: float = float(state.get("length", 0.0))
        var gaps: Array = state.get("gaps", [])
        var edge_ratio: float = float(state.get("core_edge_ratio", 0.1))
        for arm_i in range(4):
            var angle: float = float(state.get("angle", 0.0)) + float(arm_i) * PI * 0.5
            var dir := Vector2.from_angle(angle)
            var gap_center: float = 0.5
            if arm_i < gaps.size():
                gap_center = float(Dictionary(gaps[arm_i]).get("pos", 0.5))
            var gap_half := scene_ref.WINTER_CROSS_LASER_GAP_SIZE * 0.5
            var segments := [
                [edge_ratio, max(edge_ratio, gap_center - gap_half)],
                [min(gap_center + gap_half, 1.0), 1.0],
            ]
            for segment in segments:
                var start_t: float = segment[0]
                var end_t: float = segment[1]
                if end_t <= start_t:
                    continue
                var start := origin + dir * (length * start_t)
                var finish := origin + dir * (length * end_t)
                draw_line(start, finish, Color(0.3, 0.8, 2.0, 0.18), 10.0)
                draw_line(start, finish, Color(0.4, 1.0, 2.5, 0.85), 2.0)
