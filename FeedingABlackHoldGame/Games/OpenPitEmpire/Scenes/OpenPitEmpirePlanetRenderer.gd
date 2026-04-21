extends Node2D
class_name OpenPitEmpirePlanetRenderer

var scene_ref: OpenPitEmpireMain
var _force_redraw := true
var _last_cam_origin := Vector2.INF
var _fill_image: Image
var _fill_texture: ImageTexture
var _fill_prewarm_image: Image
var _edge_image: Image
var _edge_texture: ImageTexture
var _fill_grid_size := Vector2i.ZERO
var _fill_grid_origin := Vector2i(2147483647, 2147483647)
var _reduced_fill_cache_size := Vector2i.ZERO
var _fill_prewarm_grid_size := Vector2i.ZERO
var _fill_prewarm_grid_origin := Vector2i(2147483647, 2147483647)
var _fill_prewarm_next_row := 0
var _fill_prewarm_ready := false
var _edge_grid_size := Vector2i.ZERO
var _edge_grid_origin := Vector2i(2147483647, 2147483647)
var _draw_grid_min := Vector2i(2147483647, 2147483647)
var _draw_grid_max := Vector2i(-2147483647, -2147483647)
var _fill_dirty := true
var _edge_dirty := true
var _pending_fill_updates: Dictionary = {}
var _time_elapsed := 0.0
var _palette_cache: Dictionary = {}
var _screen_stars: Array[Dictionary] = []
var _last_visible_cell_budget := 0
var _last_effect_load := 0
var _last_reduce_detail := false
var _last_ultra_reduce_detail := false
var _last_fill_rebuild_reason := "-"
var _fill_rebuild_dirty_count := 0
var _fill_rebuild_origin_count := 0
var _fill_rebuild_size_count := 0
var _gold_effect_redraw_accum := 0.0
var _edge_rebuild_accum := 0.0
var _fill_upload_accum := 0.0

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
const DRAW_CACHE_PADDING_CELLS := 8
const FILL_CACHE_PADDING_CELLS := 14
const FILL_CACHE_ALIGN_CELLS := 8
const REDUCED_FILL_CACHE_ALIGN_CELLS := 16
const REDUCED_FILL_CACHE_EXTRA_ALIGN_STEPS := 2
const HEAVY_REDUCED_FILL_MIN_CELLS := 80
const ULTRA_REDUCED_FILL_MIN_CELLS := 72
const REDUCED_FILL_PREWARM_ROWS_PER_DRAW := 16
const REDUCED_FILL_PREWARM_TRIGGER_CELLS := 16
const HEAVY_OUTLINE_CACHE_PADDING_CELLS := 1
const ULTRA_OUTLINE_CACHE_PADDING_CELLS := 0
const OUTLINE_CACHE_ALIGN_CELLS := 4
const GOLD_EFFECT_REDRAW_INTERVAL := 0.05
const REDUCED_FILL_UPLOAD_INTERVAL := 0.08
const REDUCED_FILL_FORCE_UPLOAD_UPDATES := 48
const OUTLINE_REBUILD_INTERVAL := 0.2
const HEAVY_OUTLINE_WIDTH_PX := 2
const ULTRA_OUTLINE_WIDTH_PX := 2
const HEAVY_OUTLINE_ALPHA := 0.62
const ULTRA_OUTLINE_ALPHA := 0.5
const MASK_OUTLINE_CELL_PX := 4
const HEAVY_OUTLINE_CELL_PX := 24
const ULTRA_OUTLINE_CELL_PX := 16
const MAX_ULTRA_ACTIVE_HIT_EFFECTS := 24
const MAX_ULTRA_ACTIVE_GOLD_EFFECTS := 6
const HEAVY_VISIBLE_GRID_CELLS := 900
const HEAVY_EFFECT_LOAD := 24
const VERY_HEAVY_VISIBLE_GRID_CELLS := 1400
const VERY_HEAVY_EFFECT_LOAD := 40
const ZONE_SPRING := 0
const ZONE_SUMMER := 1
const ZONE_AUTUMN := 2
const ZONE_WINTER := 3
const ZONE_CENTER := 4
const ZONE_FILLS := {
    ZONE_SPRING: Color(0.07, 0.15, 0.09, 0.68),
    ZONE_SUMMER: Color(0.19, 0.15, 0.06, 0.68),
    ZONE_AUTUMN: Color(0.18, 0.08, 0.06, 0.68),
    ZONE_WINTER: Color(0.07, 0.09, 0.19, 0.68),
    ZONE_CENTER: Color(0.13, 0.08, 0.17, 0.68),
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
const THORN_FILL := Color(0.04, 0.01, 0.03, 0.7)
const THORN_EDGE := Color(2.0, 0.4, 1.5, 1.0)
const REGEN_FILL := Color(0.06, 0.015, 0.015, 0.7)
const REGEN_EDGE := Color(1.2, 0.2, 0.08, 1.0)
const ZONE_HP_VISUAL_RANGE := {
    ZONE_SPRING: {"min": 15.0, "max": 300.0},
    ZONE_SUMMER: {"min": 200.0, "max": 12000.0},
    ZONE_AUTUMN: {"min": 4000.0, "max": 220000.0},
    ZONE_WINTER: {"min": 120000.0, "max": 20000000.0},
    ZONE_CENTER: {"min": 5000000.0, "max": 120000000.0},
}

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _rebuild_screen_stars()

func mark_dirty(rebuild_fill: bool = true) -> void:
    _force_redraw = true
    _edge_dirty = true
    if rebuild_fill:
        _fill_dirty = true
        _pending_fill_updates.clear()
        _palette_cache.clear()
        _clear_fill_prewarm()

func queue_fill_update(grid: Vector2i) -> void:
    _pending_fill_updates[grid] = true
    _force_redraw = true
    _edge_dirty = true
    _clear_fill_prewarm()

func queue_fill_updates(positions: Array) -> void:
    for pos_variant in positions:
        _pending_fill_updates[Vector2i(pos_variant)] = true
    if not positions.is_empty():
        _force_redraw = true
        _edge_dirty = true
        _clear_fill_prewarm()

func _process(_delta: float) -> void:
    _time_elapsed += _delta
    _gold_effect_redraw_accum += _delta
    _edge_rebuild_accum += _delta
    _fill_upload_accum += _delta
    var needs_redraw := _force_redraw
    _force_redraw = false
    if _needs_camera_redraw():
        needs_redraw = true
    if not scene_ref.hit_timers.is_empty():
        needs_redraw = true
    elif not scene_ref.gold_convert_timers.is_empty() and _gold_effect_redraw_accum >= GOLD_EFFECT_REDRAW_INTERVAL:
        needs_redraw = true
        _gold_effect_redraw_accum = 0.0
    if not scene_ref.shockwave_rings.is_empty():
        needs_redraw = true
    if needs_redraw:
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    var perf_start_us := scene_ref.perf_probe_begin()
    for key in ["renderer_bg", "renderer_fill", "renderer_fill_resize", "renderer_fill_rebuild", "renderer_fill_upload", "renderer_edge", "renderer_blocks", "renderer_overlays"]:
        scene_ref.clear_perf_probe_sample(key)
    var canvas_transform := get_canvas_transform()
    var viewport_size := get_viewport_rect().size
    var cam_scale := canvas_transform.get_scale()
    var top_left := -canvas_transform.origin / cam_scale
    var bottom_right := top_left + viewport_size / cam_scale

    var base_margin := scene_ref.BLOCK_SIZE * 2.0
    var base_visible_grid_min := scene_ref.world_to_grid(top_left - Vector2(base_margin, base_margin))
    var base_visible_grid_max := scene_ref.world_to_grid(bottom_right + Vector2(base_margin, base_margin))
    var visible_grid_w: int = base_visible_grid_max.x - base_visible_grid_min.x + 1
    var visible_grid_h: int = base_visible_grid_max.y - base_visible_grid_min.y + 1
    var visible_cell_budget: int = visible_grid_w * visible_grid_h
    var effect_load: int = scene_ref.hit_timers.size() + scene_ref.electric_arcs.size() + scene_ref.chain_arcs.size() + scene_ref.drone_beams.size()
    var reduce_detail := visible_cell_budget >= HEAVY_VISIBLE_GRID_CELLS or effect_load >= HEAVY_EFFECT_LOAD or scene_ref.mega_timer > 0.0
    var ultra_reduce_detail := visible_cell_budget >= VERY_HEAVY_VISIBLE_GRID_CELLS or effect_load >= VERY_HEAVY_EFFECT_LOAD
    var margin := 0.0 if reduce_detail or ultra_reduce_detail else base_margin
    var visible_grid_min := scene_ref.world_to_grid(top_left - Vector2(margin, margin))
    var visible_grid_max := scene_ref.world_to_grid(bottom_right + Vector2(margin, margin))
    visible_grid_w = visible_grid_max.x - visible_grid_min.x + 1
    visible_grid_h = visible_grid_max.y - visible_grid_min.y + 1
    visible_cell_budget = visible_grid_w * visible_grid_h
    _last_visible_cell_budget = visible_cell_budget
    _last_effect_load = effect_load
    _last_reduce_detail = reduce_detail
    _last_ultra_reduce_detail = ultra_reduce_detail
    var fill_padding_cells := 0 if reduce_detail or ultra_reduce_detail else FILL_CACHE_PADDING_CELLS
    var fill_align_cells := REDUCED_FILL_CACHE_ALIGN_CELLS if reduce_detail or ultra_reduce_detail else FILL_CACHE_ALIGN_CELLS
    var padded_grid_min := visible_grid_min - Vector2i(fill_padding_cells, fill_padding_cells)
    var padded_grid_max := visible_grid_max + Vector2i(fill_padding_cells, fill_padding_cells)
    var desired_cache_grid_min := Vector2i(
        _floor_to_step(padded_grid_min.x, fill_align_cells),
        _floor_to_step(padded_grid_min.y, fill_align_cells)
    )
    var desired_cache_grid_max := Vector2i(
        _ceil_to_step_inclusive(padded_grid_max.x, fill_align_cells),
        _ceil_to_step_inclusive(padded_grid_max.y, fill_align_cells)
    )
    var desired_cache_grid_size := Vector2i(
        desired_cache_grid_max.x - desired_cache_grid_min.x + 1,
        desired_cache_grid_max.y - desired_cache_grid_min.y + 1
    )
    var cache_grid_min := desired_cache_grid_min
    var cache_grid_size := desired_cache_grid_size
    if reduce_detail or ultra_reduce_detail:
        var reduced_fill_min_cells := ULTRA_REDUCED_FILL_MIN_CELLS if ultra_reduce_detail else HEAVY_REDUCED_FILL_MIN_CELLS
        var reduced_fill_extra_cells := fill_align_cells * REDUCED_FILL_CACHE_EXTRA_ALIGN_STEPS
        desired_cache_grid_size.x = maxi(desired_cache_grid_size.x + reduced_fill_extra_cells, reduced_fill_min_cells)
        desired_cache_grid_size.y = maxi(desired_cache_grid_size.y + reduced_fill_extra_cells, reduced_fill_min_cells)
        _reduced_fill_cache_size.x = maxi(_reduced_fill_cache_size.x, desired_cache_grid_size.x)
        _reduced_fill_cache_size.y = maxi(_reduced_fill_cache_size.y, desired_cache_grid_size.y)
        cache_grid_size = _reduced_fill_cache_size
        var should_keep_fill_origin := false
        if _fill_grid_origin.x < 2147483647 and _fill_grid_size == _reduced_fill_cache_size:
            var current_cache_max := Vector2i(
                _fill_grid_origin.x + _reduced_fill_cache_size.x - 1,
                _fill_grid_origin.y + _reduced_fill_cache_size.y - 1
            )
            var can_keep_fill_origin := (
                desired_cache_grid_min.x >= _fill_grid_origin.x
                and desired_cache_grid_min.y >= _fill_grid_origin.y
                and desired_cache_grid_max.x <= current_cache_max.x
                and desired_cache_grid_max.y <= current_cache_max.y
            )
            if can_keep_fill_origin:
                should_keep_fill_origin = true
                cache_grid_min = _fill_grid_origin
    else:
        _reduced_fill_cache_size = Vector2i.ZERO
        _clear_fill_prewarm()
    if reduce_detail or ultra_reduce_detail:
        var prewarm_target_min := desired_cache_grid_min
        var prewarm_target_size := cache_grid_size
        var needs_fill_prewarm := false
        if _fill_grid_origin.x < 2147483647:
            if prewarm_target_min != cache_grid_min or _fill_grid_size != prewarm_target_size:
                needs_fill_prewarm = true
            elif should_keep_fill_origin:
                var current_cache_max := Vector2i(
                    _fill_grid_origin.x + cache_grid_size.x - 1,
                    _fill_grid_origin.y + cache_grid_size.y - 1
                )
                var distance_to_left := desired_cache_grid_min.x - _fill_grid_origin.x
                var distance_to_top := desired_cache_grid_min.y - _fill_grid_origin.y
                var distance_to_right := current_cache_max.x - desired_cache_grid_max.x
                var distance_to_bottom := current_cache_max.y - desired_cache_grid_max.y
                if distance_to_left <= REDUCED_FILL_PREWARM_TRIGGER_CELLS or distance_to_top <= REDUCED_FILL_PREWARM_TRIGGER_CELLS or distance_to_right <= REDUCED_FILL_PREWARM_TRIGGER_CELLS or distance_to_bottom <= REDUCED_FILL_PREWARM_TRIGGER_CELLS:
                    needs_fill_prewarm = true
        if needs_fill_prewarm and not _fill_dirty and _pending_fill_updates.is_empty():
            _ensure_fill_prewarm(prewarm_target_min, prewarm_target_size)
            _advance_fill_prewarm(REDUCED_FILL_PREWARM_ROWS_PER_DRAW)
        elif not needs_fill_prewarm:
            _clear_fill_prewarm()
    var cache_grid_max := Vector2i(
        cache_grid_min.x + cache_grid_size.x - 1,
        cache_grid_min.y + cache_grid_size.y - 1
    )
    var background_rect := Rect2(
        Vector2(float(cache_grid_min.x) * scene_ref.BLOCK_SIZE, float(cache_grid_min.y) * scene_ref.BLOCK_SIZE),
        Vector2(
            float(cache_grid_max.x - cache_grid_min.x + 1) * scene_ref.BLOCK_SIZE,
            float(cache_grid_max.y - cache_grid_min.y + 1) * scene_ref.BLOCK_SIZE
        )
    )
    var section_start_us := scene_ref.perf_probe_begin()
    draw_rect(background_rect, SPACE_BG, true)
    if ultra_reduce_detail:
        _draw_background_stars(true, true)
    elif not reduce_detail:
        _draw_background_stars()
        _draw_core_zones()
    else:
        _draw_background_stars(true)
    scene_ref.perf_probe_end("renderer_bg", section_start_us)
    var cache_grid_w: int = cache_grid_max.x - cache_grid_min.x + 1
    var cache_grid_h: int = cache_grid_max.y - cache_grid_min.y + 1
    var fill_rebuild_dirty := _fill_dirty
    var fill_rebuild_origin := _fill_grid_origin != cache_grid_min
    var fill_rebuild_size := _fill_grid_size != Vector2i(cache_grid_w, cache_grid_h)
    var fill_needs_rebuild := fill_rebuild_dirty or fill_rebuild_origin or fill_rebuild_size
    _draw_grid_min = cache_grid_min
    _draw_grid_max = cache_grid_max
    _last_cam_origin = canvas_transform.origin

    section_start_us = scene_ref.perf_probe_begin()
    if _fill_image == null or _fill_grid_size.x != cache_grid_w or _fill_grid_size.y != cache_grid_h:
        var fill_resize_start_us := scene_ref.perf_probe_begin()
        _fill_image = Image.create(cache_grid_w, cache_grid_h, false, Image.FORMAT_RGBA8)
        _fill_grid_size = Vector2i(cache_grid_w, cache_grid_h)
        _fill_grid_origin = cache_grid_min
        _fill_texture = null
        fill_rebuild_size = true
        fill_needs_rebuild = true
        scene_ref.perf_probe_end("renderer_fill_resize", fill_resize_start_us)
    if fill_needs_rebuild:
        var fill_reason_parts: Array[String] = []
        if fill_rebuild_dirty:
            fill_reason_parts.append("dirty")
            _fill_rebuild_dirty_count += 1
        if fill_rebuild_origin:
            fill_reason_parts.append("origin")
            _fill_rebuild_origin_count += 1
        if fill_rebuild_size:
            fill_reason_parts.append("size")
            _fill_rebuild_size_count += 1
        _last_fill_rebuild_reason = "+".join(fill_reason_parts) if not fill_reason_parts.is_empty() else "unknown"
        var fill_rebuild_start_us := scene_ref.perf_probe_begin()
        var old_fill_grid_origin := _fill_grid_origin
        if not fill_rebuild_dirty and _can_apply_fill_prewarm(cache_grid_min, Vector2i(cache_grid_w, cache_grid_h)):
            _apply_fill_prewarm()
        elif fill_rebuild_origin and not fill_rebuild_dirty and not fill_rebuild_size and _fill_image != null:
            _shift_fill_image_with_overlap(old_fill_grid_origin, cache_grid_min, Vector2i(cache_grid_w, cache_grid_h))
        else:
            _fill_grid_origin = cache_grid_min
            _fill_image.fill(Color.TRANSPARENT)
            _paint_fill_region(cache_grid_min, cache_grid_max)
        scene_ref.perf_probe_end("renderer_fill_rebuild", fill_rebuild_start_us)
        var fill_upload_start_us := scene_ref.perf_probe_begin()
        if _fill_texture == null:
            _fill_texture = ImageTexture.create_from_image(_fill_image)
        else:
            _fill_texture.update(_fill_image)
        scene_ref.perf_probe_end("renderer_fill_upload", fill_upload_start_us)
        _fill_dirty = false
        _pending_fill_updates.clear()
        _fill_upload_accum = 0.0
    else:
        _last_fill_rebuild_reason = "-"
        var should_upload_pending_fill := true
        if reduce_detail or ultra_reduce_detail:
            should_upload_pending_fill = _fill_upload_accum >= REDUCED_FILL_UPLOAD_INTERVAL or _pending_fill_updates.size() >= REDUCED_FILL_FORCE_UPLOAD_UPDATES
        if should_upload_pending_fill and _apply_pending_fill_updates(cache_grid_min, cache_grid_max):
            var fill_upload_start_us := scene_ref.perf_probe_begin()
            if _fill_texture == null:
                _fill_texture = ImageTexture.create_from_image(_fill_image)
            else:
                _fill_texture.update(_fill_image)
            scene_ref.perf_probe_end("renderer_fill_upload", fill_upload_start_us)
            _fill_upload_accum = 0.0
    var tex_rect := Rect2(
        float(cache_grid_min.x) * scene_ref.BLOCK_SIZE,
        float(cache_grid_min.y) * scene_ref.BLOCK_SIZE,
        float(cache_grid_w) * scene_ref.BLOCK_SIZE,
        float(cache_grid_h) * scene_ref.BLOCK_SIZE
    )
    if _fill_texture != null:
        draw_texture_rect(_fill_texture, tex_rect, false)
    scene_ref.perf_probe_end("renderer_fill", section_start_us)

    if int(scene_ref.planet_outline_mode) != int(scene_ref.OutlineMode.OFF) and (reduce_detail or ultra_reduce_detail):
        section_start_us = scene_ref.perf_probe_begin()
        var outline_radius_cells := maxi(1, int(scene_ref.planet_outline_radius_cells))
        var outline_center_grid := _get_outline_cache_center_grid()
        var outline_cache_padding_cells := ULTRA_OUTLINE_CACHE_PADDING_CELLS if ultra_reduce_detail else HEAVY_OUTLINE_CACHE_PADDING_CELLS
        var desired_edge_grid_min := Vector2i(
            outline_center_grid.x - outline_radius_cells - outline_cache_padding_cells,
            outline_center_grid.y - outline_radius_cells - outline_cache_padding_cells
        )
        var desired_edge_grid_max := Vector2i(
            outline_center_grid.x + outline_radius_cells + outline_cache_padding_cells,
            outline_center_grid.y + outline_radius_cells + outline_cache_padding_cells
        )
        var edge_grid_min := desired_edge_grid_min
        var edge_grid_max := desired_edge_grid_max
        if _edge_grid_origin.x < 2147483647 and _edge_grid_size.x > 0 and _edge_grid_size.y > 0:
            var current_edge_grid_max := Vector2i(
                _edge_grid_origin.x + _edge_grid_size.x - 1,
                _edge_grid_origin.y + _edge_grid_size.y - 1
            )
            var can_keep_edge_origin := (
                desired_edge_grid_min.x >= _edge_grid_origin.x
                and desired_edge_grid_min.y >= _edge_grid_origin.y
                and desired_edge_grid_max.x <= current_edge_grid_max.x
                and desired_edge_grid_max.y <= current_edge_grid_max.y
            )
            if can_keep_edge_origin:
                edge_grid_min = _edge_grid_origin
                edge_grid_max = current_edge_grid_max
        var edge_grid_size := Vector2i(edge_grid_max.x - edge_grid_min.x + 1, edge_grid_max.y - edge_grid_min.y + 1)
        var edge_cache_matches := _edge_grid_origin == edge_grid_min and _edge_grid_size == edge_grid_size
        if _edge_texture == null or not edge_cache_matches or (_edge_dirty and _edge_rebuild_accum >= OUTLINE_REBUILD_INTERVAL):
            _rebuild_edge_texture(edge_grid_min, edge_grid_max, ultra_reduce_detail, int(scene_ref.planet_outline_mode))
        if _edge_texture != null and _edge_grid_origin == edge_grid_min and _edge_grid_size == edge_grid_size:
            var edge_tex_rect := Rect2(
                float(edge_grid_min.x) * scene_ref.BLOCK_SIZE,
                float(edge_grid_min.y) * scene_ref.BLOCK_SIZE,
                float(edge_grid_size.x) * scene_ref.BLOCK_SIZE,
                float(edge_grid_size.y) * scene_ref.BLOCK_SIZE
            )
            draw_texture_rect(_edge_texture, edge_tex_rect, false)
        scene_ref.perf_probe_end("renderer_edge", section_start_us)

    var gold_pulse_t := Time.get_ticks_msec() * 0.001 * 1.8
    section_start_us = scene_ref.perf_probe_begin()
    if ultra_reduce_detail:
        _draw_active_block_effects(visible_grid_min, visible_grid_max)
    else:
        for x in range(visible_grid_min.x, visible_grid_max.x + 1):
            for y in range(visible_grid_min.y, visible_grid_max.y + 1):
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
                if not reduce_detail and scene_ref.exposed_edges.has(grid):
                    _draw_block_edges(grid, rect, colors.get("edge", Color.WHITE), int(scene_ref.exposed_edges.get(grid, 0)), 2.0)

                var health_ratio := 1.0
                if not reduce_detail or scene_ref.hit_timers.has(grid):
                    health_ratio = scene_ref.get_block_hp_ratio(grid)
                if not reduce_detail and health_ratio < 0.999:
                    draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2(rect.size.x - 6.0, 3.0)), Color(0.0, 0.0, 0.0, 0.55), true)
                    draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2((rect.size.x - 6.0) * health_ratio, 3.0)), Color(0.6, 1.8, 2.4, 0.9), true)

                var hit_timer: float = float(scene_ref.hit_timers.get(grid, 0.0))
                if hit_timer > 0.0:
                    draw_rect(rect.grow(-2.0), Color(HIT_GLOW.r, HIT_GLOW.g, HIT_GLOW.b, hit_timer / scene_ref.HIT_FLASH_DURATION), false, 2.0)
                var gold_timer: float = float(scene_ref.gold_convert_timers.get(grid, 0.0))
                if gold_timer > 0.0:
                    draw_rect(rect.grow(-2.0), Color(GOLD_GLOW.r, GOLD_GLOW.g, GOLD_GLOW.b, gold_timer / scene_ref.GOLD_CONVERT_DURATION), false, 2.0)
                if not reduce_detail and int(block.get("type", 0)) == scene_ref.BlockType.GOLD and bool(scene_ref.runtime_stats.get("gold_enabled", false)):
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
    scene_ref.perf_probe_end("renderer_blocks", section_start_us)

    section_start_us = scene_ref.perf_probe_begin()
    if not ultra_reduce_detail:
        var spawn_arc_points := 24 if reduce_detail else 64
        draw_arc(scene_ref.spawn_position, scene_ref.return_zone_radius, 0.0, TAU, spawn_arc_points, Color(0.3, 1.5, 0.5, 0.25), 2.0)
    if not ultra_reduce_detail:
        for ring in scene_ref.shockwave_rings:
            var radius: float = minf(float(ring.get("radius", 0.0)), LOCAL_SHOCKWAVE_VISUAL_RADIUS)
            if radius <= 0.0:
                continue
            var alpha: float = clampf(float(ring.get("alpha", 0.0)), 0.0, 1.0)
            if radius >= LOCAL_SHOCKWAVE_VISUAL_RADIUS:
                alpha *= 0.2
            var ring_points := 28 if reduce_detail else 48
            draw_arc(
                scene_ref.ship_pos,
                radius,
                0.0,
                TAU,
                ring_points,
                Color(1.0, 0.85, 0.2, alpha),
                2.0
            )

    _draw_summer_lasers(ultra_reduce_detail)
    if not ultra_reduce_detail:
        _draw_autumn_debris()
        _draw_winter_cross_lasers()
    if not reduce_detail:
        _draw_core_shields()
    scene_ref.perf_probe_end("renderer_overlays", section_start_us)
    scene_ref.perf_probe_end("renderer_draw", perf_start_us)

func _draw_background_stars(compact: bool = false, ultra_compact: bool = false) -> void:
    var canvas_transform := get_canvas_transform()
    var cam_scale := canvas_transform.get_scale()
    var cam_world := -canvas_transform.origin / cam_scale
    var viewport_size := get_viewport_rect().size
    if _screen_stars.is_empty():
        _rebuild_screen_stars()
    var step := 4 if ultra_compact else (2 if compact else 1)
    var backdrop_alpha := 0.2 if ultra_compact else (0.32 if compact else 0.42)
    var backdrop_padding := scene_ref.BLOCK_SIZE * float(FILL_CACHE_PADDING_CELLS)
    draw_rect(
        Rect2(
            cam_world - Vector2.ONE * backdrop_padding,
            viewport_size / cam_scale + Vector2.ONE * (backdrop_padding * 2.0)
        ),
        Color(0.04, 0.06, 0.09, backdrop_alpha),
        true
    )
    for idx in range(0, _screen_stars.size(), step):
        var star: Dictionary = _screen_stars[idx]
        var uv: Vector2 = star.get("uv", Vector2.ZERO)
        var pos := cam_world + Vector2(uv.x * viewport_size.x, uv.y * viewport_size.y)
        var twinkle_seed: float = float(star.get("twinkle_seed", 0.0))
        var alpha_scale := 0.7 if ultra_compact else (0.82 if compact else 1.0)
        var alpha := float(star.get("alpha", 0.6)) * alpha_scale * (0.82 + 0.18 * sin(_time_elapsed * (0.7 + twinkle_seed * 1.2) + twinkle_seed * TAU))
        alpha = clampf(alpha, 0.12, 1.0)
        var color: Color = star.get("color", Color.WHITE)
        var size_px: float = float(star.get("size", 1.2))
        if ultra_compact:
            size_px = minf(size_px, 1.4)
        if not compact and not ultra_compact and size_px > 1.35:
            draw_circle(pos, size_px * 1.8, Color(color.r, color.g, color.b, alpha * 0.14))
        draw_circle(pos, size_px, Color(color.r, color.g, color.b, alpha))

func _draw_active_block_effects(grid_min: Vector2i, grid_max: Vector2i) -> void:
    var ship_world := scene_ref.ship_pos
    var hit_effects: Array[Dictionary] = []
    for grid_variant in scene_ref.hit_timers.keys():
        var grid: Vector2i = grid_variant
        if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
            continue
        if not scene_ref.blocks.has(grid):
            continue
        var hit_timer: float = float(scene_ref.hit_timers.get(grid, 0.0))
        if hit_timer <= 0.0:
            continue
        var world := scene_ref.grid_to_world(grid)
        _insert_effect_candidate(hit_effects, {"world": world, "timer": hit_timer, "dist_sq": ship_world.distance_squared_to(world)}, MAX_ULTRA_ACTIVE_HIT_EFFECTS)
    for effect in hit_effects:
        var world: Vector2 = effect.get("world", Vector2.ZERO)
        var grid := scene_ref.world_to_grid(world)
        var rect := Rect2(
            world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
            Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
        )
        var hit_timer: float = float(effect.get("timer", 0.0))
        var health_ratio := scene_ref.get_block_hp_ratio(grid)
        if health_ratio < 0.999:
            draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2(rect.size.x - 6.0, 2.0)), Color(0.0, 0.0, 0.0, 0.5), true)
            draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2((rect.size.x - 6.0) * health_ratio, 2.0)), Color(0.6, 1.8, 2.4, 0.88), true)
        draw_rect(rect.grow(-2.0), Color(HIT_GLOW.r, HIT_GLOW.g, HIT_GLOW.b, hit_timer / scene_ref.HIT_FLASH_DURATION), false, 2.0)
    if MAX_ULTRA_ACTIVE_GOLD_EFFECTS <= 0:
        return
    var gold_effects: Array[Dictionary] = []
    for grid_variant in scene_ref.gold_convert_timers.keys():
        var grid: Vector2i = grid_variant
        if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
            continue
        if not scene_ref.blocks.has(grid):
            continue
        var gold_timer: float = float(scene_ref.gold_convert_timers.get(grid, 0.0))
        if gold_timer <= 0.0:
            continue
        var world := scene_ref.grid_to_world(grid)
        _insert_effect_candidate(gold_effects, {"world": world, "timer": gold_timer, "dist_sq": ship_world.distance_squared_to(world)}, MAX_ULTRA_ACTIVE_GOLD_EFFECTS)
    for effect in gold_effects:
        var world: Vector2 = effect.get("world", Vector2.ZERO)
        var rect := Rect2(
            world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
            Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
        )
        var gold_timer: float = float(effect.get("timer", 0.0))
        draw_rect(rect.grow(-2.0), Color(GOLD_GLOW.r, GOLD_GLOW.g, GOLD_GLOW.b, gold_timer / scene_ref.GOLD_CONVERT_DURATION), false, 2.0)

func _apply_pending_fill_updates(grid_min: Vector2i, grid_max: Vector2i) -> bool:
    if _pending_fill_updates.is_empty() or _fill_image == null:
        return false
    var changed := false
    var applied_positions: Array = []
    for grid_variant in _pending_fill_updates.keys():
        var grid: Vector2i = grid_variant
        applied_positions.append(grid)
        if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
            continue
        var local_x: int = grid.x - grid_min.x
        var local_y: int = grid.y - grid_min.y
        if local_x < 0 or local_x >= _fill_grid_size.x or local_y < 0 or local_y >= _fill_grid_size.y:
            continue
        if scene_ref.blocks.has(grid):
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            var colors: Dictionary = _get_block_palette(block)
            _fill_image.set_pixel(local_x, local_y, colors.get("fill", Color.WHITE))
        else:
            _fill_image.set_pixel(local_x, local_y, Color.TRANSPARENT)
        changed = true
    for grid_variant in applied_positions:
        _pending_fill_updates.erase(grid_variant)
    return changed

func _paint_fill_region(grid_min: Vector2i, grid_max: Vector2i) -> void:
    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var colors: Dictionary = _get_block_palette(block)
            _fill_image.set_pixel(x - _fill_grid_origin.x, y - _fill_grid_origin.y, colors.get("fill", Color.WHITE))

func _paint_fill_region_into(image: Image, image_origin: Vector2i, grid_min: Vector2i, grid_max: Vector2i) -> void:
    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var colors: Dictionary = _get_block_palette(block)
            image.set_pixel(x - image_origin.x, y - image_origin.y, colors.get("fill", Color.WHITE))

func _shift_fill_image_with_overlap(old_origin: Vector2i, new_origin: Vector2i, grid_size: Vector2i) -> void:
    var new_image := Image.create(grid_size.x, grid_size.y, false, Image.FORMAT_RGBA8)
    new_image.fill(Color.TRANSPARENT)
    var old_max := Vector2i(old_origin.x + grid_size.x - 1, old_origin.y + grid_size.y - 1)
    var new_max := Vector2i(new_origin.x + grid_size.x - 1, new_origin.y + grid_size.y - 1)
    var overlap_min := Vector2i(maxi(old_origin.x, new_origin.x), maxi(old_origin.y, new_origin.y))
    var overlap_max := Vector2i(mini(old_max.x, new_max.x), mini(old_max.y, new_max.y))
    var has_overlap := overlap_min.x <= overlap_max.x and overlap_min.y <= overlap_max.y
    if has_overlap:
        var src_pos := Vector2i(overlap_min.x - old_origin.x, overlap_min.y - old_origin.y)
        var overlap_size := Vector2i(overlap_max.x - overlap_min.x + 1, overlap_max.y - overlap_min.y + 1)
        var dst_pos := Vector2i(overlap_min.x - new_origin.x, overlap_min.y - new_origin.y)
        new_image.blit_rect(_fill_image, Rect2i(src_pos, overlap_size), dst_pos)
    _fill_image = new_image
    _fill_grid_origin = new_origin
    _fill_grid_size = grid_size
    if not has_overlap:
        _paint_fill_region(new_origin, new_max)
        return
    if new_origin.y < overlap_min.y:
        _paint_fill_region(new_origin, Vector2i(new_max.x, overlap_min.y - 1))
    if overlap_max.y < new_max.y:
        _paint_fill_region(Vector2i(new_origin.x, overlap_max.y + 1), new_max)
    if new_origin.x < overlap_min.x:
        _paint_fill_region(Vector2i(new_origin.x, overlap_min.y), Vector2i(overlap_min.x - 1, overlap_max.y))
    if overlap_max.x < new_max.x:
        _paint_fill_region(Vector2i(overlap_max.x + 1, overlap_min.y), Vector2i(new_max.x, overlap_max.y))

func _clear_fill_prewarm() -> void:
    _fill_prewarm_image = null
    _fill_prewarm_grid_origin = Vector2i(2147483647, 2147483647)
    _fill_prewarm_grid_size = Vector2i.ZERO
    _fill_prewarm_next_row = 0
    _fill_prewarm_ready = false

func _ensure_fill_prewarm(target_origin: Vector2i, target_size: Vector2i) -> void:
    if _fill_prewarm_image != null and _fill_prewarm_grid_origin == target_origin and _fill_prewarm_grid_size == target_size:
        return
    _fill_prewarm_image = Image.create(target_size.x, target_size.y, false, Image.FORMAT_RGBA8)
    _fill_prewarm_image.fill(Color.TRANSPARENT)
    _fill_prewarm_grid_origin = target_origin
    _fill_prewarm_grid_size = target_size
    _fill_prewarm_next_row = 0
    _fill_prewarm_ready = false

func _advance_fill_prewarm(row_count: int) -> void:
    if _fill_prewarm_image == null or _fill_prewarm_ready or row_count <= 0:
        return
    var end_row := mini(_fill_prewarm_grid_size.y, _fill_prewarm_next_row + row_count)
    if end_row <= _fill_prewarm_next_row:
        return
    var row_grid_min := Vector2i(_fill_prewarm_grid_origin.x, _fill_prewarm_grid_origin.y + _fill_prewarm_next_row)
    var row_grid_max := Vector2i(
        _fill_prewarm_grid_origin.x + _fill_prewarm_grid_size.x - 1,
        _fill_prewarm_grid_origin.y + end_row - 1
    )
    _paint_fill_region_into(_fill_prewarm_image, _fill_prewarm_grid_origin, row_grid_min, row_grid_max)
    _fill_prewarm_next_row = end_row
    _fill_prewarm_ready = _fill_prewarm_next_row >= _fill_prewarm_grid_size.y

func _can_apply_fill_prewarm(target_origin: Vector2i, target_size: Vector2i) -> bool:
    return _fill_prewarm_ready and _fill_prewarm_grid_origin == target_origin and _fill_prewarm_grid_size == target_size and _fill_prewarm_image != null

func _apply_fill_prewarm() -> void:
    _fill_image = _fill_prewarm_image
    _fill_grid_origin = _fill_prewarm_grid_origin
    _fill_grid_size = _fill_prewarm_grid_size
    _clear_fill_prewarm()

func _rebuild_edge_texture(grid_min: Vector2i, grid_max: Vector2i, ultra_reduce_detail: bool, outline_mode: int) -> void:
    var use_mask_outline := outline_mode == int(scene_ref.OutlineMode.ALL_BLOCKS_MASK)
    var use_exposed_mask := not use_mask_outline and outline_mode != int(scene_ref.OutlineMode.ALL_BLOCKS)
    var cell_px := MASK_OUTLINE_CELL_PX if use_mask_outline else (ULTRA_OUTLINE_CELL_PX if ultra_reduce_detail else HEAVY_OUTLINE_CELL_PX)
    var grid_w: int = grid_max.x - grid_min.x + 1
    var grid_h: int = grid_max.y - grid_min.y + 1
    var tex_w := maxi(1, grid_w * cell_px)
    var tex_h := maxi(1, grid_h * cell_px)
    if _edge_image == null or _edge_image.get_width() != tex_w or _edge_image.get_height() != tex_h:
        _edge_image = Image.create(tex_w, tex_h, false, Image.FORMAT_RGBA8)
        _edge_texture = null
    _edge_grid_origin = grid_min
    _edge_grid_size = Vector2i(grid_w, grid_h)
    _edge_image.fill(Color.TRANSPARENT)
    var outline_width := ULTRA_OUTLINE_WIDTH_PX if ultra_reduce_detail else HEAVY_OUTLINE_WIDTH_PX
    var outline_alpha := ULTRA_OUTLINE_ALPHA if ultra_reduce_detail else HEAVY_OUTLINE_ALPHA
    if use_mask_outline:
        outline_width = 1
        outline_alpha = 0.78 if ultra_reduce_detail else 0.84
    var outline_radius_cells := maxi(1, int(scene_ref.planet_outline_radius_cells))
    var outline_center_grid := _get_outline_cache_center_grid()
    var radius_sq := outline_radius_cells * outline_radius_cells
    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            var dx := grid.x - outline_center_grid.x
            var dy := grid.y - outline_center_grid.y
            if dx * dx + dy * dy > radius_sq:
                continue
            var mask := 15
            if use_exposed_mask:
                mask = int(scene_ref.exposed_edges.get(grid, 0))
                if mask == 0:
                    continue
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var colors: Dictionary = _get_block_palette(block)
            var edge_color: Color = colors.get("edge", Color.WHITE)
            var lightened_edge := edge_color.lerp(Color.WHITE, 0.08)
            var draw_color := Color(lightened_edge.r, lightened_edge.g, lightened_edge.b, outline_alpha)
            var px := (grid.x - grid_min.x) * cell_px
            var py := (grid.y - grid_min.y) * cell_px
            if (mask & 1) != 0:
                _edge_image.fill_rect(Rect2i(px, py, cell_px, outline_width), draw_color)
            if (mask & 2) != 0:
                _edge_image.fill_rect(Rect2i(px, py + cell_px - outline_width, cell_px, outline_width), draw_color)
            if (mask & 4) != 0:
                _edge_image.fill_rect(Rect2i(px, py, outline_width, cell_px), draw_color)
            if (mask & 8) != 0:
                _edge_image.fill_rect(Rect2i(px + cell_px - outline_width, py, outline_width, cell_px), draw_color)
    if _edge_texture == null:
        _edge_texture = ImageTexture.create_from_image(_edge_image)
    else:
        _edge_texture.update(_edge_image)
    _edge_dirty = false
    _edge_rebuild_accum = 0.0

func _get_outline_cache_center_grid() -> Vector2i:
    var center_grid := scene_ref.world_to_grid(scene_ref.camera_pos)
    return Vector2i(
        _floor_to_step(center_grid.x, OUTLINE_CACHE_ALIGN_CELLS),
        _floor_to_step(center_grid.y, OUTLINE_CACHE_ALIGN_CELLS)
    )

func _floor_to_step(value: int, step: int) -> int:
    if step <= 1:
        return value
    return int(floor(float(value) / float(step))) * step

func _ceil_to_step_inclusive(value: int, step: int) -> int:
    if step <= 1:
        return value
    return int(ceil(float(value + 1) / float(step))) * step - 1

func _insert_effect_candidate(items: Array[Dictionary], candidate: Dictionary, limit: int) -> void:
    if limit <= 0:
        return
    var dist_sq: float = float(candidate.get("dist_sq", INF))
    var insert_idx := items.size()
    while insert_idx > 0 and dist_sq < float(items[insert_idx - 1].get("dist_sq", INF)):
        insert_idx -= 1
    if insert_idx >= limit and items.size() >= limit:
        return
    items.insert(insert_idx, candidate)
    if items.size() > limit:
        items.resize(limit)

func _needs_camera_redraw() -> bool:
    if scene_ref == null:
        return false
    var canvas_transform := get_canvas_transform()
    var cam_origin := canvas_transform.origin
    if cam_origin == _last_cam_origin and _draw_grid_min.x <= _draw_grid_max.x:
        return false
    if _draw_grid_min.x > _draw_grid_max.x:
        return true
    var cam_scale := canvas_transform.get_scale()
    var viewport_size := get_viewport_rect().size
    var top_left := -cam_origin / cam_scale
    var bottom_right := top_left + viewport_size / cam_scale
    var margin := scene_ref.BLOCK_SIZE * 2.0
    var visible_grid_min := scene_ref.world_to_grid(top_left - Vector2(margin, margin))
    var visible_grid_max := scene_ref.world_to_grid(bottom_right + Vector2(margin, margin))
    return (
        visible_grid_min.x < _draw_grid_min.x + DRAW_CACHE_PADDING_CELLS
        or visible_grid_min.y < _draw_grid_min.y + DRAW_CACHE_PADDING_CELLS
        or visible_grid_max.x > _draw_grid_max.x - DRAW_CACHE_PADDING_CELLS
        or visible_grid_max.y > _draw_grid_max.y - DRAW_CACHE_PADDING_CELLS
    )

func get_perf_state_text() -> String:
    return "Planet vis %d  load %d  detail %s/%s  fillQ %d  fillR %s  fillCnt d:%d o:%d s:%d" % [
        _last_visible_cell_budget,
        _last_effect_load,
        "heavy" if _last_reduce_detail else "full",
        "ultra" if _last_ultra_reduce_detail else "normal",
        _pending_fill_updates.size(),
        _last_fill_rebuild_reason,
        _fill_rebuild_dirty_count,
        _fill_rebuild_origin_count,
        _fill_rebuild_size_count,
    ]

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
    var hardness_tier: int = _get_visual_hardness_tier(block)
    var cache_key := "%d:%d:%d:%d:%d:%d" % [zone, block_type, int(regenerated), int(electric_enabled), int(gold_enabled), hardness_tier]
    if _palette_cache.has(cache_key):
        return _palette_cache[cache_key]
    var fill: Color = ZONE_FILLS.get(zone, SPACE_BG)
    var edge: Color = ZONE_EDGE_COLORS.get(zone, Color.WHITE)
    match block_type:
        scene_ref.BlockType.CORE:
            fill = _mix_fill_with_edge(ZONE_FILLS.get(zone, Color(0.11, 0.07, 0.08, 1.0)), ZONE_EDGE_COLORS.get(zone, Color(1.0, 1.0, 1.0, 1.0)), 0.32)
            edge = ZONE_EDGE_COLORS.get(zone, Color(2.5, 0.3, 0.08, 1.0))
        scene_ref.BlockType.ELECTRIC:
            fill = Color(0.08, 0.17, 0.23, 0.72) if electric_enabled else _mix_fill_with_edge(fill, edge, 0.18).darkened(0.15)
            edge = Color(0.5, 1.8, 2.5, 1.0)
        scene_ref.BlockType.GOLD:
            fill = Color(0.24, 0.18, 0.07, 0.72) if gold_enabled else _mix_fill_with_edge(fill, edge, 0.22).darkened(0.08)
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
    fill = _apply_hardness_tint(fill, hardness_tier)
    var palette := {"fill": fill, "edge": edge}
    _palette_cache[cache_key] = palette
    return palette

func _mix_fill_with_edge(fill: Color, edge: Color, amount: float) -> Color:
    var edge_clamped := Color(min(edge.r, 1.0), min(edge.g, 1.0), min(edge.b, 1.0), 1.0)
    return fill.lerp(edge_clamped, amount)

func _get_visual_hardness_tier(block: Dictionary) -> int:
    var block_type: int = int(block.get("type", 0))
    if block_type == scene_ref.BlockType.CORE:
        var core_id: int = int(block.get("core_id", -1))
        if scene_ref.planet_data != null:
            return clampi(scene_ref.planet_data.get_core_tier(core_id), 1, 3)
        return 1
    if block_type != scene_ref.BlockType.NORMAL:
        return 1
    var zone: int = int(block.get("zone", ZONE_AUTUMN))
    var hp_range: Dictionary = ZONE_HP_VISUAL_RANGE.get(zone, {"min": 1.0, "max": 1.0})
    var min_hp: float = maxf(float(hp_range.get("min", 1.0)), 1.0)
    var max_hp: float = maxf(float(hp_range.get("max", min_hp)), min_hp)
    var block_hp: float = clampf(float(block.get("max_hp", min_hp)), min_hp, max_hp)
    var ratio := inverse_lerp(min_hp, max_hp, block_hp)
    if ratio >= 0.72:
        return 3
    if ratio >= 0.4:
        return 2
    return 1

func _apply_hardness_tint(fill: Color, hardness_tier: int) -> Color:
    match hardness_tier:
        3:
            return fill.darkened(0.16)
        2:
            return fill.darkened(0.08)
        _:
            return fill

func _draw_core_zones() -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    for core in scene_ref.planet_data.cores:
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var world_radius := float(scene_ref.planet_data.get_effective_influence_radius(core)) * scene_ref.BLOCK_SIZE
        if bool(core.alive):
            var zone_col: Color = ZONE_RING_COLORS.get(int(core.zone), Color(1.0, 0.2, 0.1, 0.25))
            draw_circle(center, world_radius, Color(zone_col.r, zone_col.g, zone_col.b, zone_col.a * 0.14))
            draw_arc(center, world_radius, 0.0, TAU, 32, zone_col, 1.5)
        else:
            draw_circle(center, world_radius, Color(0.15, 0.8, 1.0, 0.06))
            draw_arc(center, world_radius, 0.0, TAU, 24, Color(0.15, 0.8, 1.0, 0.12), 1.0)

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
        draw_arc(center, dome_radius, 0.0, TAU, 24, Color(0.3, 0.6, 1.0, 0.65), 1.5)

func _draw_summer_lasers(compact: bool = false) -> void:
    for state_variant in scene_ref.summer_laser_states.values():
        var state: Dictionary = state_variant
        var origin: Vector2 = state.get("origin", Vector2.ZERO)
        var dir: Vector2 = Vector2(state.get("dir", Vector2.RIGHT)).normalized()
        if dir.length() < 0.01:
            continue
        var end := origin + dir * scene_ref.BLOCK_SIZE * 40.0
        var color := Color(2.2, 0.9, 0.2, 0.9)
        if compact:
            if str(state.get("state", "idle")) == "warning":
                var compact_pulse := 0.45 + 0.2 * (sin(_time_elapsed * 10.0) + 1.0) * 0.5
                draw_line(origin, end, Color(color.r, color.g, color.b, compact_pulse), 4.0)
            elif str(state.get("state", "idle")) == "firing":
                draw_line(origin, end, Color(1.0, 0.42, 0.12, 0.92), 7.0)
            continue
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
