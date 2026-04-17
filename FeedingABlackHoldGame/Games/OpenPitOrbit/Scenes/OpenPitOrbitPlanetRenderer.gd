extends Node2D
class_name OpenPitOrbitPlanetRenderer

var scene_ref: OpenPitOrbitMain
var _force_redraw := true
var _last_cam_origin := Vector2.INF
var _fill_image: Image
var _fill_texture: ImageTexture
var _fill_grid_size := Vector2i.ZERO
var _stars: Array[Dictionary] = []

const SPACE_BG := Color(0.025, 0.025, 0.035, 1.0)
const HIT_GLOW := Color(2.3, 1.2, 0.4, 0.55)
const GOLD_GLOW := Color(2.6, 2.0, 0.4, 0.45)
const STAR_COUNT := 200
const STAR_AREA := 3000.0
const BLOCK_GAP := 1.5
const ZONE_SPRING := 0
const ZONE_SUMMER := 1
const ZONE_AUTUMN := 2
const ZONE_WINTER := 3
const ZONE_CENTER := 4
const ZONE_FILLS := {
    ZONE_SPRING: Color(0.01, 0.04, 0.015),
    ZONE_SUMMER: Color(0.04, 0.03, 0.005),
    ZONE_AUTUMN: Color(0.04, 0.015, 0.01),
    ZONE_WINTER: Color(0.01, 0.015, 0.045),
    ZONE_CENTER: Color(0.03, 0.01, 0.04),
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

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    _stars.clear()
    for _idx in range(STAR_COUNT):
        _stars.append({
            "pos": Vector2(rng.randf_range(-STAR_AREA, STAR_AREA), rng.randf_range(-STAR_AREA, STAR_AREA)),
            "size": rng.randf_range(0.5, 2.5),
            "alpha": rng.randf_range(0.2, 0.8),
            "twinkle_speed": rng.randf_range(0.5, 3.0),
            "twinkle_offset": rng.randf() * TAU,
        })

func mark_dirty() -> void:
    _force_redraw = true

func _process(_delta: float) -> void:
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
    draw_rect(get_viewport_rect(), SPACE_BG, true)
    _draw_background_stars()
    _draw_core_zones()

    var canvas_transform := get_canvas_transform()
    var viewport_size := get_viewport_rect().size
    var cam_scale := canvas_transform.get_scale()
    var top_left := -canvas_transform.origin / cam_scale
    var bottom_right := top_left + viewport_size / cam_scale
    var margin := scene_ref.BLOCK_SIZE * 2.0
    var grid_min := scene_ref.world_to_grid(top_left - Vector2(margin, margin))
    var grid_max := scene_ref.world_to_grid(bottom_right + Vector2(margin, margin))
    var grid_w: int = grid_max.x - grid_min.x + 1
    var grid_h: int = grid_max.y - grid_min.y + 1

    var radius_world: float = scene_ref.planet_radius_cells * scene_ref.BLOCK_SIZE
    draw_circle(scene_ref.planet_center, radius_world + 18.0, Color(0.02, 0.03, 0.05, 1.0))
    draw_circle(scene_ref.planet_center, radius_world + 6.0, Color(0.08, 0.11, 0.16, 0.35))

    if _fill_image == null or _fill_grid_size.x != grid_w or _fill_grid_size.y != grid_h:
        _fill_image = Image.create(grid_w, grid_h, false, Image.FORMAT_RGBA8)
        _fill_grid_size = Vector2i(grid_w, grid_h)
        _fill_texture = null
    else:
        _fill_image.fill(Color.TRANSPARENT)

    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            if scene_ref.is_grid_empty(grid):
                continue
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            var colors: Dictionary = _get_block_palette(block)
            _fill_image.set_pixel(x - grid_min.x, y - grid_min.y, colors.get("fill", Color.WHITE))

    if _fill_texture == null:
        _fill_texture = ImageTexture.create_from_image(_fill_image)
    else:
        _fill_texture.update(_fill_image)
    var tex_rect := Rect2(
        float(grid_min.x) * scene_ref.BLOCK_SIZE,
        float(grid_min.y) * scene_ref.BLOCK_SIZE,
        float(grid_w) * scene_ref.BLOCK_SIZE,
        float(grid_h) * scene_ref.BLOCK_SIZE
    )
    draw_texture_rect(_fill_texture, tex_rect, false)

    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            if scene_ref.is_grid_empty(grid):
                continue
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            var world := scene_ref.grid_to_world(grid)
            var rect := Rect2(
                world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
                Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
            )
            var colors: Dictionary = _get_block_palette(block)
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
                var gp := (sin(Time.get_ticks_msec() * 0.001 * 1.8 + grid.x * 1.3 + grid.y * 0.7) + 1.0) * 0.5
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
        var alpha: float = clampf(float(ring.get("alpha", 0.0)), 0.0, 1.0)
        draw_arc(
            scene_ref.ship_pos,
            float(ring.get("radius", 0.0)),
            0.0,
            TAU,
            64,
            Color(1.0, 0.85, 0.2, alpha),
            2.0
        )
    _draw_core_shields()

func _draw_background_stars() -> void:
    var t := Time.get_ticks_msec() * 0.001
    var canvas_transform := get_canvas_transform()
    var cam_scale := canvas_transform.get_scale()
    var cam_world := -canvas_transform.origin / cam_scale
    for star in _stars:
        var base_pos: Vector2 = star.get("pos", Vector2.ZERO)
        var screen_pos := base_pos - cam_world * 0.08
        var alpha := float(star.get("alpha", 0.5)) + 0.15 * sin(t * float(star.get("twinkle_speed", 1.0)) + float(star.get("twinkle_offset", 0.0)))
        alpha = clampf(alpha, 0.1, 1.0)
        draw_circle(screen_pos, float(star.get("size", 1.0)), Color(1.0, 1.0, 1.0, alpha))

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
    var fill: Color = ZONE_FILLS.get(zone, SPACE_BG)
    var edge: Color = ZONE_EDGE_COLORS.get(zone, Color(1.0, 1.0, 1.0, 1.0))
    match int(block.get("type", 0)):
        scene_ref.BlockType.CORE:
            fill = ZONE_FILLS.get(zone, Color(0.06, 0.01, 0.01, 1.0)).lightened(0.05)
            edge = ZONE_EDGE_COLORS.get(zone, Color(2.5, 0.3, 0.08, 1.0))
        scene_ref.BlockType.ELECTRIC:
            fill = Color(0.01, 0.06, 0.1, 1.0) if bool(scene_ref.runtime_stats.get("electric_enabled", false)) else fill.darkened(0.2)
            edge = Color(0.5, 1.8, 2.5, 1.0)
        scene_ref.BlockType.GOLD:
            fill = Color(0.05, 0.04, 0.01, 1.0) if bool(scene_ref.runtime_stats.get("gold_enabled", false)) else fill.darkened(0.15)
            edge = Color(2.0, 1.6, 0.3, 1.0)
        _:
            fill = fill
    return {"fill": fill, "edge": edge}

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
