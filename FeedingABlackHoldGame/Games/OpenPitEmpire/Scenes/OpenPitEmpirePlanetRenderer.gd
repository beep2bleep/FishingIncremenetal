extends Node2D
class_name OpenPitEmpirePlanetRenderer

var scene_ref: OpenPitEmpireMain
var _force_redraw := true
var _last_cam_origin := Vector2.INF
var _fill_image: Image
var _fill_shift_image: Image
var _fill_texture: ImageTexture
var _fill_prewarm_image: Image
var _edge_image: Image
var _edge_texture: ImageTexture
var _fill_grid_size := Vector2i.ZERO
var _fill_grid_origin := Vector2i(2147483647, 2147483647)
var _fill_cell_span := 1
var _reduced_fill_cache_size := Vector2i.ZERO
var _fill_prewarm_grid_size := Vector2i.ZERO
var _fill_prewarm_grid_origin := Vector2i(2147483647, 2147483647)
var _fill_prewarm_cell_span := 1
var _fill_prewarm_next_row := 0
var _fill_prewarm_ready := false
var _fill_prewarm_waiting_for_swap := false
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
var _sortie_detail_locked := false
var _sortie_reduce_detail := false
var _sortie_ultra_reduce_detail := false
var _auto_ultra_lock_timer := 0.0
var _last_fill_rebuild_reason := "-"
var _last_fill_dirty_source := "-"
var _fill_dirty_source_counts: Dictionary = {}
var _fill_rebuild_dirty_count := 0
var _fill_rebuild_origin_count := 0
var _fill_rebuild_size_count := 0
var _fill_prewarm_miss_count := 0
var _fill_prewarm_apply_count := 0
var _fill_prewarm_defer_count := 0
var _edge_rebuild_accum := 0.0
var _fill_upload_accum := 0.0
var _fill_scrub_accum := 0.0
var _fill_scrub_pending := false
var _fill_scrub_next_row := 0
var _fill_scrub_changed := false
var _fill_prewarm_thread: Thread
var _fill_prewarm_thread_active := false
var _fill_prewarm_job_id := 0
var _fill_prewarm_active_job_id := 0
var _fill_prewarm_active_origin := Vector2i(2147483647, 2147483647)
var _fill_prewarm_active_size := Vector2i.ZERO
var _fill_prewarm_active_cell_span := 1
var _fill_prewarm_completed_job_id := 0

const SPACE_BG := Color(0.025, 0.025, 0.035, 1.0)
const DEFAULT_EDGE := Color(1.2, 0.4, 2.0, 1.0)
const PIT_GLOW := Color(0.52, 0.08, 0.08, 0.72)
const PIT_WALL_FILL := Color(0.2, 0.04, 0.05, 0.96)
const PIT_WALL_EDGE := Color(1.0, 0.24, 0.2, 0.96)
const PIT_WALL_SHADOW := Color(0.14, 0.0, 0.0, 0.46)
const HIT_GLOW := Color(2.3, 1.2, 0.4, 0.55)
const HACKER_BLOCK_FILL := Color(0.08, 0.34, 0.16, 1.0)
const HACKER_BLOCK_EDGE := Color(0.25, 2.2, 0.65, 1.0)
const HACKER_BLOCK_DIM := Color(0.06, 0.16, 0.12, 1.0)
const TETROMINO_EDGE := Color(0.94, 0.98, 1.0, 0.95)
const STAR_COLORS := [
    Color(1.0, 0.96, 0.9, 1.0),
    Color(0.95, 0.98, 1.0, 1.0),
    Color(0.86, 0.96, 1.0, 1.0),
]
const SCREEN_STAR_COUNT := 90
const BLOCK_GAP := 1.5
const LOCAL_SHOCKWAVE_VISUAL_RADIUS := 96.0
const DRAW_CACHE_PADDING_CELLS := 14
const FILL_CACHE_PADDING_CELLS := 14
const FILL_CACHE_ALIGN_CELLS := 8
const REDUCED_FILL_CACHE_ALIGN_CELLS := 16
const HEAVY_REDUCED_FILL_MIN_CELLS := 80
const ULTRA_REDUCED_FILL_MIN_CELLS := 72
const REDUCED_FILL_PREWARM_ROWS_PER_DRAW := 4
const REDUCED_FILL_PREWARM_TRIGGER_CELLS := 20
const REDUCED_FILL_KEEP_EDGE_TOLERANCE_CELLS := 18
const REDUCED_FILL_RECENTER_MARGIN_CELLS := 12
const REDUCED_FILL_EXTRA_ALIGN_STEPS := 12
const HEAVY_FILL_CELL_SPAN := 1
const ULTRA_FILL_CELL_SPAN := 1
const HEAVY_OUTLINE_CACHE_PADDING_CELLS := 0
const ULTRA_OUTLINE_CACHE_PADDING_CELLS := 0
const HEAVY_OUTLINE_CACHE_ALIGN_CELLS := 8
const ULTRA_OUTLINE_CACHE_ALIGN_CELLS := 12
const FILL_SCRUB_INTERVAL := 1.0
const FILL_SCRUB_ROWS_PER_DRAW := 8
const REDUCED_FILL_UPLOAD_INTERVAL := 0.08
const REDUCED_FILL_FORCE_UPLOAD_UPDATES := 48
const USE_THREADED_FILL_PREWARM := false
const OUTLINE_REBUILD_INTERVAL := 0.7
const HEAVY_OUTLINE_WIDTH_PX := 4
const ULTRA_OUTLINE_WIDTH_PX := 4
const HEAVY_OUTLINE_ALPHA := 0.62
const ULTRA_OUTLINE_ALPHA := 0.5
const MASK_OUTLINE_CELL_PX := 4
const HEAVY_OUTLINE_CELL_PX := 20
const ULTRA_OUTLINE_CELL_PX := 12
const MAX_ULTRA_ACTIVE_HIT_EFFECTS := 12
const HEAVY_FOCAL_DETAIL_RADIUS_CELLS := 10
const ULTRA_FOCAL_DETAIL_RADIUS_CELLS := 7
const ULTRA_FOCAL_OUTLINE_RADIUS_CELLS := 8
const HEAVY_VISIBLE_GRID_CELLS := 900
const HEAVY_EFFECT_LOAD := 24
const VERY_HEAVY_VISIBLE_GRID_CELLS := 1400
const VERY_HEAVY_EFFECT_LOAD := 40
const AUTO_ULTRA_EXIT_VISIBLE_GRID_CELLS := 1100
const AUTO_ULTRA_EXIT_EFFECT_LOAD := 20
const AUTO_ULTRA_LOCK_SECONDS := 0.85
const ZONE_SPRING := 0
const ZONE_SUMMER := 1
const ZONE_AUTUMN := 2
const ZONE_WINTER := 3
const ZONE_CENTER := 4
const ZONE_FILLS := {
    ZONE_SPRING: Color(0.07, 0.09, 0.19, 0.68),
    ZONE_SUMMER: Color(0.07, 0.15, 0.09, 0.68),
    ZONE_AUTUMN: Color(0.19, 0.15, 0.06, 0.68),
    ZONE_WINTER: Color(0.18, 0.08, 0.06, 0.68),
    ZONE_CENTER: Color(0.13, 0.08, 0.17, 0.68),
}
const ZONE_EDGE_COLORS := {
    ZONE_SPRING: Color(0.5, 1.2, 2.2),
    ZONE_SUMMER: Color(0.3, 1.8, 0.5),
    ZONE_AUTUMN: Color(2.0, 1.8, 0.3),
    ZONE_WINTER: Color(2.0, 0.35, 0.1),
    ZONE_CENTER: Color(1.2, 0.4, 2.0),
}
const ZONE_RING_COLORS := {
    ZONE_SPRING: Color(0.3, 0.8, 2.0, 0.3),
    ZONE_SUMMER: Color(0.3, 1.5, 0.4, 0.3),
    ZONE_AUTUMN: Color(2.0, 1.5, 0.2, 0.3),
    ZONE_WINTER: Color(2.0, 0.3, 0.08, 0.3),
    ZONE_CENTER: Color(1.2, 0.25, 2.0, 0.3),
}
const THORN_FILL := Color(0.04, 0.01, 0.03, 0.7)
const THORN_EDGE := Color(2.0, 0.4, 1.5, 1.0)
const REGEN_FILL := Color(0.06, 0.015, 0.015, 0.7)
const REGEN_EDGE := Color(1.2, 0.2, 0.08, 1.0)
const CORE_REFILL_FILL := Color(0.22, 0.08, 0.32, 0.72)
const CORE_REFILL_EDGE := Color(0.92, 0.42, 1.45, 1.0)
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

func _exit_tree() -> void:
    _finish_fill_prewarm_thread()

func mark_dirty(rebuild_fill: bool = true, reason: String = "external") -> void:
    _force_redraw = true
    _edge_dirty = true
    if rebuild_fill:
        _mark_fill_dirty(reason)
        _pending_fill_updates.clear()
        _palette_cache.clear()
        _clear_fill_prewarm()

func _mark_fill_dirty(reason: String) -> void:
    _fill_dirty = true
    _last_fill_dirty_source = reason
    _fill_dirty_source_counts[reason] = int(_fill_dirty_source_counts.get(reason, 0)) + 1

func queue_fill_update(grid: Vector2i) -> void:
    _pending_fill_updates[grid] = true
    _force_redraw = true
    _edge_dirty = true

func queue_fill_updates(positions: Array) -> void:
    for pos_variant in positions:
        _pending_fill_updates[Vector2i(pos_variant)] = true
    if not positions.is_empty():
        _force_redraw = true
        _edge_dirty = true

func _process(_delta: float) -> void:
    _poll_fill_prewarm_thread()
    _time_elapsed += _delta
    _auto_ultra_lock_timer = maxf(0.0, _auto_ultra_lock_timer - _delta)
    _edge_rebuild_accum += _delta
    _fill_upload_accum += _delta
    _fill_scrub_accum += _delta
    if _fill_scrub_accum >= FILL_SCRUB_INTERVAL:
        _fill_scrub_accum = 0.0
        _fill_scrub_pending = true
        _fill_scrub_next_row = 0
        _fill_scrub_changed = false
        _force_redraw = true
    var needs_redraw := _force_redraw
    _force_redraw = false
    if _needs_camera_redraw():
        needs_redraw = true
    if not scene_ref.hit_timers.is_empty():
        needs_redraw = true
    if not scene_ref.lock_flash_timers.is_empty():
        needs_redraw = true
    if not scene_ref.tetromino_bursts.is_empty():
        needs_redraw = true
    if not scene_ref.roaming_powerups.is_empty():
        needs_redraw = true
    if not scene_ref.shockwave_rings.is_empty():
        needs_redraw = true
    if scene_ref.final_core_exposed:
        needs_redraw = true
    if _fill_prewarm_image != null and not _fill_prewarm_ready:
        needs_redraw = true
    if _fill_scrub_pending:
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
    var effect_load: int = scene_ref.hit_timers.size() + scene_ref.tetromino_bursts.size() + scene_ref.electric_arcs.size() + scene_ref.chain_arcs.size() + scene_ref.drone_beams.size() + scene_ref.drone_missiles.size() + scene_ref.drone_mines.size()
    var full_visible_grid_cells := int(scene_ref.get("full_detail_visible_grid_cells")) if scene_ref != null else 288
    var heavy_visible_grid_cells := int(scene_ref.get("heavy_detail_visible_grid_cells")) if scene_ref != null else HEAVY_VISIBLE_GRID_CELLS
    var ultra_visible_grid_cells := int(scene_ref.get("ultra_detail_visible_grid_cells")) if scene_ref != null else VERY_HEAVY_VISIBLE_GRID_CELLS
    heavy_visible_grid_cells = maxi(heavy_visible_grid_cells, full_visible_grid_cells + 1)
    ultra_visible_grid_cells = maxi(ultra_visible_grid_cells, heavy_visible_grid_cells + 1)
    var auto_force_heavy := effect_load >= HEAVY_EFFECT_LOAD or scene_ref.mega_timer > 0.0
    var reduce_detail := true
    var ultra_reduce_detail := visible_cell_budget >= ultra_visible_grid_cells or effect_load >= VERY_HEAVY_EFFECT_LOAD
    if int(scene_ref.render_detail_mode) == int(scene_ref.RenderDetailMode.AUTO):
        reduce_detail = true
        var should_enter_ultra := not auto_force_heavy and (
            visible_cell_budget >= ultra_visible_grid_cells
            or effect_load >= VERY_HEAVY_EFFECT_LOAD
        )
        if should_enter_ultra:
            _auto_ultra_lock_timer = AUTO_ULTRA_LOCK_SECONDS
        if _last_ultra_reduce_detail:
            ultra_reduce_detail = not auto_force_heavy and (
                _auto_ultra_lock_timer > 0.0
                or visible_cell_budget >= AUTO_ULTRA_EXIT_VISIBLE_GRID_CELLS
                or effect_load >= AUTO_ULTRA_EXIT_EFFECT_LOAD
            )
        else:
            ultra_reduce_detail = should_enter_ultra
    match int(scene_ref.render_detail_mode):
        int(scene_ref.RenderDetailMode.FULL):
            reduce_detail = false
            ultra_reduce_detail = false
        int(scene_ref.RenderDetailMode.HEAVY):
            reduce_detail = true
            ultra_reduce_detail = false
        int(scene_ref.RenderDetailMode.ULTRA):
            reduce_detail = true
            ultra_reduce_detail = true
    if int(scene_ref.render_detail_mode) == int(scene_ref.RenderDetailMode.AUTO) and not scene_ref.run_finished:
        if not _sortie_detail_locked:
            _sortie_reduce_detail = reduce_detail
            _sortie_ultra_reduce_detail = ultra_reduce_detail
            _sortie_detail_locked = true
        reduce_detail = _sortie_reduce_detail
        ultra_reduce_detail = _sortie_ultra_reduce_detail
    else:
        _sortie_detail_locked = false
    var reduce_detail_changed := reduce_detail != _last_reduce_detail or ultra_reduce_detail != _last_ultra_reduce_detail
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
    var fill_cell_span := _get_fill_cell_span(reduce_detail, ultra_reduce_detail)
    if reduce_detail_changed:
        _fill_upload_accum = REDUCED_FILL_UPLOAD_INTERVAL
        _palette_cache.clear()
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
    var should_keep_fill_origin := false
    if reduce_detail or ultra_reduce_detail:
        var reduced_fill_min_cells := ULTRA_REDUCED_FILL_MIN_CELLS if ultra_reduce_detail else HEAVY_REDUCED_FILL_MIN_CELLS
        var reduced_fill_extra_cells := fill_align_cells * REDUCED_FILL_EXTRA_ALIGN_STEPS
        desired_cache_grid_size.x = maxi(desired_cache_grid_size.x + reduced_fill_extra_cells, reduced_fill_min_cells)
        desired_cache_grid_size.y = maxi(desired_cache_grid_size.y + reduced_fill_extra_cells, reduced_fill_min_cells)
        _reduced_fill_cache_size.x = maxi(_reduced_fill_cache_size.x, desired_cache_grid_size.x)
        _reduced_fill_cache_size.y = maxi(_reduced_fill_cache_size.y, desired_cache_grid_size.y)
        cache_grid_size = _reduced_fill_cache_size
        if _fill_grid_origin.x < 2147483647 and _fill_grid_size == _reduced_fill_cache_size:
            var current_cache_max := Vector2i(
                _fill_grid_origin.x + _reduced_fill_cache_size.x - 1,
                _fill_grid_origin.y + _reduced_fill_cache_size.y - 1
            )
            var safe_cache_min := Vector2i(
                _fill_grid_origin.x + REDUCED_FILL_RECENTER_MARGIN_CELLS,
                _fill_grid_origin.y + REDUCED_FILL_RECENTER_MARGIN_CELLS
            )
            var safe_cache_max := Vector2i(
                current_cache_max.x - REDUCED_FILL_RECENTER_MARGIN_CELLS,
                current_cache_max.y - REDUCED_FILL_RECENTER_MARGIN_CELLS
            )
            var stays_within_safe_region := (
                safe_cache_min.x <= safe_cache_max.x
                and safe_cache_min.y <= safe_cache_max.y
                and desired_cache_grid_min.x >= safe_cache_min.x
                and desired_cache_grid_min.y >= safe_cache_min.y
                and desired_cache_grid_max.x <= safe_cache_max.x
                and desired_cache_grid_max.y <= safe_cache_max.y
            )
            var can_keep_fill_origin := (
                stays_within_safe_region
                or (
                    desired_cache_grid_min.x >= _fill_grid_origin.x - REDUCED_FILL_KEEP_EDGE_TOLERANCE_CELLS
                    and desired_cache_grid_min.y >= _fill_grid_origin.y - REDUCED_FILL_KEEP_EDGE_TOLERANCE_CELLS
                    and desired_cache_grid_max.x <= current_cache_max.x + REDUCED_FILL_KEEP_EDGE_TOLERANCE_CELLS
                    and desired_cache_grid_max.y <= current_cache_max.y + REDUCED_FILL_KEEP_EDGE_TOLERANCE_CELLS
                )
            )
            if can_keep_fill_origin:
                should_keep_fill_origin = true
                cache_grid_min = _fill_grid_origin
    else:
        _reduced_fill_cache_size = Vector2i.ZERO
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
    var viewport_background_margin := scene_ref.BLOCK_SIZE * 4.0
    var viewport_background_rect := Rect2(
        top_left - Vector2.ONE * viewport_background_margin,
        (bottom_right - top_left) + Vector2.ONE * viewport_background_margin * 2.0
    )
    var section_start_us := scene_ref.perf_probe_begin()
    draw_rect(viewport_background_rect, SPACE_BG, true)
    draw_rect(background_rect, SPACE_BG, true)
    _draw_pit_shell(visible_grid_min, visible_grid_max)
    if ultra_reduce_detail:
        _draw_background_stars(true, true)
    elif not reduce_detail:
        _draw_background_stars()
    else:
        _draw_background_stars(true)
    _draw_core_influence_rings(ultra_reduce_detail)
    _draw_core_health_bars(ultra_reduce_detail)
    scene_ref.perf_probe_end("renderer_bg", section_start_us)
    var cache_grid_w: int = cache_grid_max.x - cache_grid_min.x + 1
    var cache_grid_h: int = cache_grid_max.y - cache_grid_min.y + 1
    _draw_grid_min = cache_grid_min
    _draw_grid_max = cache_grid_max
    _last_cam_origin = canvas_transform.origin

    var target_cache_grid_size := Vector2i(cache_grid_w, cache_grid_h)
    var use_live_reduced_fill := reduce_detail or ultra_reduce_detail
    if use_live_reduced_fill:
        _clear_fill_prewarm()
        _fill_image = null
        _fill_texture = null
        _fill_grid_origin = Vector2i(2147483647, 2147483647)
        _fill_grid_size = Vector2i.ZERO
        _fill_dirty = false
        _pending_fill_updates.clear()
    elif reduce_detail or ultra_reduce_detail:
        _ensure_fill_prewarm(cache_grid_min, target_cache_grid_size, fill_cell_span)
        _apply_pending_fill_updates_to_prewarm()
        if _fill_prewarm_thread_active:
            _force_redraw = true
        else:
            _advance_fill_prewarm(REDUCED_FILL_PREWARM_ROWS_PER_DRAW)
    var fill_rebuild_dirty := false if use_live_reduced_fill else _fill_dirty
    var fill_rebuild_origin := false if use_live_reduced_fill else _fill_grid_origin != cache_grid_min
    var fill_rebuild_size := false if use_live_reduced_fill else _fill_grid_size != target_cache_grid_size
    var fill_rebuild_span := false if use_live_reduced_fill else _fill_cell_span != fill_cell_span
    var fill_needs_rebuild := fill_rebuild_dirty or fill_rebuild_origin or fill_rebuild_size
    if fill_rebuild_span:
        fill_needs_rebuild = true
    var fill_prewarm_ready_for_cache := _can_apply_fill_prewarm(cache_grid_min, target_cache_grid_size, fill_cell_span)
    var fill_prewarm_missed := false
    var fill_rebuild_deferred := false
    var draw_direct_visible_fill := use_live_reduced_fill

    section_start_us = scene_ref.perf_probe_begin()
    var target_fill_texture_size := _grid_size_to_fill_texture_size(target_cache_grid_size, fill_cell_span)
    if not use_live_reduced_fill and fill_needs_rebuild and (reduce_detail or ultra_reduce_detail) and not fill_prewarm_ready_for_cache and _fill_texture != null:
        fill_rebuild_deferred = true
        draw_direct_visible_fill = true
        _fill_prewarm_waiting_for_swap = true
        _fill_prewarm_defer_count += 1
        fill_needs_rebuild = false
    if not use_live_reduced_fill and not fill_rebuild_deferred and (_fill_image == null or _fill_grid_size.x != cache_grid_w or _fill_grid_size.y != cache_grid_h or _fill_cell_span != fill_cell_span or _fill_image.get_width() != target_fill_texture_size.x or _fill_image.get_height() != target_fill_texture_size.y):
        var fill_resize_start_us := scene_ref.perf_probe_begin()
        _fill_image = Image.create(target_fill_texture_size.x, target_fill_texture_size.y, false, Image.FORMAT_RGBA8)
        _fill_grid_size = Vector2i(cache_grid_w, cache_grid_h)
        _fill_grid_origin = cache_grid_min
        _fill_cell_span = fill_cell_span
        _fill_texture = null
        fill_rebuild_size = true
        fill_needs_rebuild = true
        _fill_scrub_pending = false
        _fill_scrub_next_row = 0
        _fill_scrub_changed = false
        scene_ref.perf_probe_end("renderer_fill_resize", fill_resize_start_us)
    if not use_live_reduced_fill and fill_needs_rebuild and (reduce_detail or ultra_reduce_detail) and not fill_prewarm_ready_for_cache and _fill_texture != null:
        fill_rebuild_deferred = true
        draw_direct_visible_fill = true
        _fill_prewarm_waiting_for_swap = true
        _fill_prewarm_defer_count += 1
        fill_needs_rebuild = false
    if use_live_reduced_fill:
        _last_fill_rebuild_reason = "live"
    elif fill_needs_rebuild:
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
        if fill_rebuild_span:
            fill_reason_parts.append("span")
        _last_fill_rebuild_reason = "+".join(fill_reason_parts) if not fill_reason_parts.is_empty() else "unknown"
        var fill_rebuild_start_us := scene_ref.perf_probe_begin()
        if fill_prewarm_ready_for_cache:
            _fill_prewarm_apply_count += 1
            _fill_prewarm_waiting_for_swap = false
            _apply_fill_prewarm()
        elif not fill_rebuild_dirty and fill_rebuild_origin and not fill_rebuild_size and _fill_image != null:
            _fill_prewarm_waiting_for_swap = false
            _shift_fill_image_with_overlap(_fill_grid_origin, cache_grid_min, target_cache_grid_size, fill_cell_span)
        else:
            fill_prewarm_missed = (reduce_detail or ultra_reduce_detail) and (_fill_grid_size.x > 0 and _fill_grid_size.y > 0) and (fill_rebuild_dirty or fill_rebuild_origin or fill_rebuild_size)
            _fill_prewarm_waiting_for_swap = false
            _fill_grid_origin = cache_grid_min
            _fill_cell_span = fill_cell_span
            _fill_image.fill(Color.TRANSPARENT)
            _paint_fill_region(cache_grid_min, cache_grid_max)
        if fill_prewarm_missed:
            _fill_prewarm_miss_count += 1
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
        _fill_scrub_pending = false
        _fill_scrub_next_row = 0
        _fill_scrub_changed = false
    else:
        _last_fill_rebuild_reason = "deferred" if fill_rebuild_deferred else "-"
        var should_upload_pending_fill := true
        var pending_bounds_min := _fill_grid_origin if fill_rebuild_deferred else cache_grid_min
        var pending_bounds_max := Vector2i(
            _fill_grid_origin.x + _fill_grid_size.x - 1,
            _fill_grid_origin.y + _fill_grid_size.y - 1
        ) if fill_rebuild_deferred else cache_grid_max
        if should_upload_pending_fill and _apply_pending_fill_updates(pending_bounds_min, pending_bounds_max):
            var fill_upload_start_us := scene_ref.perf_probe_begin()
            if _fill_texture == null:
                _fill_texture = ImageTexture.create_from_image(_fill_image)
            else:
                _fill_texture.update(_fill_image)
            scene_ref.perf_probe_end("renderer_fill_upload", fill_upload_start_us)
            _fill_upload_accum = 0.0
        elif _fill_scrub_pending:
            _fill_scrub_pending = false
            _fill_scrub_next_row = 0
            _fill_scrub_changed = false
    var texture_origin := cache_grid_min if not fill_rebuild_deferred else _fill_grid_origin
    var texture_size := Vector2i(cache_grid_w, cache_grid_h) if not fill_rebuild_deferred else _fill_grid_size
    var tex_rect := Rect2(
        float(texture_origin.x) * scene_ref.BLOCK_SIZE,
        float(texture_origin.y) * scene_ref.BLOCK_SIZE,
        float(texture_size.x) * scene_ref.BLOCK_SIZE,
        float(texture_size.y) * scene_ref.BLOCK_SIZE
    )
    if _fill_texture != null and not draw_direct_visible_fill:
        draw_texture_rect(_fill_texture, tex_rect, false)
    if draw_direct_visible_fill:
        _draw_direct_reduced_fill(visible_grid_min, visible_grid_max)
    scene_ref.perf_probe_end("renderer_fill", section_start_us)

    if reduce_detail:
        _edge_texture = null
        _edge_image = null
        _edge_grid_origin = Vector2i(2147483647, 2147483647)
        _edge_grid_size = Vector2i.ZERO
        _edge_dirty = false

    var gold_pulse_t := Time.get_ticks_msec() * 0.001 * 1.8
    var power_blocks_start_us := scene_ref.perf_probe_begin()
    section_start_us = scene_ref.perf_probe_begin()
    if ultra_reduce_detail:
        _draw_focal_live_outlines(visible_grid_min, visible_grid_max, _get_viewport_edge_outline_radius_cells(visible_grid_min, visible_grid_max), 1.5)
        _draw_active_block_effects(visible_grid_min, visible_grid_max)
    elif reduce_detail:
        _draw_focal_live_outlines(visible_grid_min, visible_grid_max, _get_viewport_edge_outline_radius_cells(visible_grid_min, visible_grid_max), 1.25)
    else:
        for x in range(visible_grid_min.x, visible_grid_max.x + 1):
            for y in range(visible_grid_min.y, visible_grid_max.y + 1):
                var grid := Vector2i(x, y)
                var block: Dictionary = scene_ref.blocks.get(grid, {})
                if block.is_empty():
                    continue
                var colors: Dictionary = _get_block_palette(block, grid)
                var world := scene_ref.grid_to_world(grid)
                var rect := Rect2(
                    world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
                    Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
                )
                if not reduce_detail and scene_ref.exposed_edges.has(grid):
                    _draw_block_edges(grid, rect, colors.get("edge", _get_block_edge_fallback(block)), int(scene_ref.exposed_edges.get(grid, 0)), 2.0)

                var health_ratio := 1.0
                if not reduce_detail or scene_ref.hit_timers.has(grid):
                    health_ratio = scene_ref.get_block_hp_ratio(grid)
                if not reduce_detail and health_ratio < 0.999:
                    draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2(rect.size.x - 6.0, 3.0)), Color(0.0, 0.0, 0.0, 0.55), true)
                    draw_rect(Rect2(rect.position + Vector2(3.0, 3.0), Vector2((rect.size.x - 6.0) * health_ratio, 3.0)), Color(0.6, 1.8, 2.4, 0.9), true)

                var hit_timer: float = float(scene_ref.hit_timers.get(grid, 0.0))
                if hit_timer > 0.0:
                    draw_rect(rect.grow(-2.0), Color(HIT_GLOW.r, HIT_GLOW.g, HIT_GLOW.b, hit_timer / scene_ref.HIT_FLASH_DURATION), false, 2.0)
                if not reduce_detail and int(block.get("type", 0)) == scene_ref.BlockType.ELECTRIC:
                    _draw_tetromino_block_glyph(grid, rect, bool(scene_ref.runtime_stats.get("electric_enabled", false)))
                if not reduce_detail and int(block.get("type", 0)) == scene_ref.BlockType.GOLD:
                    var gp := (sin(gold_pulse_t + grid.x * 1.3 + grid.y * 0.7) + 1.0) * 0.5
                    var ga := 0.1 + gp * 0.12
                    var gc := Color(1.0, 0.58, 0.18, ga)
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
    scene_ref.perf_probe_end("renderer_power_blocks", power_blocks_start_us)
    _draw_tetromino_bursts()
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

    _draw_cipher_lasers(ultra_reduce_detail)
    _draw_root_cross_lasers(ultra_reduce_detail)
    _draw_core_shields(ultra_reduce_detail)
    _draw_lock_flashes(visible_grid_min, visible_grid_max, ultra_reduce_detail)
    _draw_ghost_debris(ultra_reduce_detail)
    if not ultra_reduce_detail:
        _draw_roaming_powerups()
        _draw_final_funnel()
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

func _draw_lock_flashes(grid_min: Vector2i, grid_max: Vector2i, compact: bool) -> void:
    if scene_ref.lock_flash_timers.is_empty():
        return
    for grid_variant in scene_ref.lock_flash_timers.keys():
        var grid: Vector2i = grid_variant
        if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
            continue
        if not scene_ref.blocks.has(grid):
            continue
        var timer := float(scene_ref.lock_flash_timers.get(grid, 0.0))
        if timer <= 0.0:
            continue
        var life_ratio := clampf(timer / scene_ref.LOCK_FLASH_DURATION, 0.0, 1.0)
        var pulse := 0.55 + 0.45 * absf(sin(_time_elapsed * 34.0))
        var alpha := life_ratio * pulse
        var center := scene_ref.grid_to_world(grid)
        var size := scene_ref.BLOCK_SIZE * (0.46 if compact else 0.58)
        var shackle_center := center + Vector2(0.0, -size * 0.06)
        var body_rect := Rect2(
            center + Vector2(-size * 0.34, -size * 0.02),
            Vector2(size * 0.68, size * 0.42)
        )
        var glow := Color(1.0, 0.12, 0.04, alpha * 0.22)
        draw_circle(center + Vector2(0.0, size * 0.12), size * 0.68, glow)
        var edge := Color(1.0, 0.86, 0.22, alpha)
        var fill := Color(0.12, 0.02, 0.02, alpha * 0.78)
        draw_arc(shackle_center, size * 0.24, PI, TAU, 12, edge, 2.6 if compact else 3.2)
        draw_line(shackle_center + Vector2(-size * 0.24, 0.0), shackle_center + Vector2(-size * 0.24, size * 0.12), edge, 2.4 if compact else 3.0)
        draw_line(shackle_center + Vector2(size * 0.24, 0.0), shackle_center + Vector2(size * 0.24, size * 0.12), edge, 2.4 if compact else 3.0)
        draw_rect(body_rect, fill, true)
        draw_rect(body_rect, edge, false, 2.2 if compact else 2.8)
        draw_circle(center + Vector2(0.0, size * 0.15), size * 0.055, edge)
        draw_line(center + Vector2(0.0, size * 0.19), center + Vector2(0.0, size * 0.29), edge, 1.8 if compact else 2.2)

func _draw_direct_reduced_fill(grid_min: Vector2i, grid_max: Vector2i) -> void:
    for x in range(grid_min.x, grid_max.x + 1):
        for y in range(grid_min.y, grid_max.y + 1):
            var grid := Vector2i(x, y)
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var colors: Dictionary = _get_block_palette(block)
            var world := scene_ref.grid_to_world(grid)
            draw_rect(
                Rect2(
                    world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5,
                    Vector2.ONE * scene_ref.BLOCK_SIZE
                ),
                colors.get("fill", SPACE_BG),
                true
            )

func _draw_focal_live_outlines(visible_grid_min: Vector2i, visible_grid_max: Vector2i, radius_cells: int, width: float) -> void:
    if radius_cells <= 0:
        return
    var center_grid := scene_ref.world_to_grid(scene_ref.camera_pos)
    var min_x := maxi(visible_grid_min.x, center_grid.x - radius_cells)
    var max_x := mini(visible_grid_max.x, center_grid.x + radius_cells)
    var min_y := maxi(visible_grid_min.y, center_grid.y - radius_cells)
    var max_y := mini(visible_grid_max.y, center_grid.y + radius_cells)
    for x in range(min_x, max_x + 1):
        for y in range(min_y, max_y + 1):
            var grid := Vector2i(x, y)
            if maxi(absi(grid.x - center_grid.x), absi(grid.y - center_grid.y)) > radius_cells:
                continue
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var exposed_mask := int(scene_ref.exposed_edges.get(grid, 0))
            if exposed_mask == 0:
                continue
            var colors: Dictionary = _get_block_palette(block)
            var world := scene_ref.grid_to_world(grid)
            var rect := Rect2(
                world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * BLOCK_GAP,
                Vector2.ONE * (scene_ref.BLOCK_SIZE - BLOCK_GAP * 2.0)
            )
            _draw_block_edges(grid, rect, colors.get("edge", _get_block_edge_fallback(block)), exposed_mask, width)

func _get_viewport_edge_outline_radius_cells(visible_grid_min: Vector2i, visible_grid_max: Vector2i) -> int:
    var center_grid := scene_ref.world_to_grid(scene_ref.camera_pos)
    return maxi(
        maxi(absi(visible_grid_min.x - center_grid.x), absi(visible_grid_max.x - center_grid.x)),
        maxi(absi(visible_grid_min.y - center_grid.y), absi(visible_grid_max.y - center_grid.y))
    )

func _apply_pending_fill_updates(grid_min: Vector2i, grid_max: Vector2i) -> bool:
    if _pending_fill_updates.is_empty() or _fill_image == null:
        return false
    var changed := false
    var applied_positions: Array = []
    if _fill_cell_span <= 1:
        for grid_variant in _pending_fill_updates.keys():
            var grid: Vector2i = grid_variant
            if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
                continue
            applied_positions.append(grid)
            if _set_fill_pixel_for_grid(_fill_image, _fill_grid_origin, _fill_grid_size, grid):
                changed = true
        for grid_variant in applied_positions:
            _pending_fill_updates.erase(grid_variant)
        return changed
    var dirty_buckets: Dictionary = {}
    for grid_variant in _pending_fill_updates.keys():
        var grid: Vector2i = grid_variant
        if grid.x < grid_min.x or grid.x > grid_max.x or grid.y < grid_min.y or grid.y > grid_max.y:
            continue
        applied_positions.append(grid)
        dirty_buckets[_get_fill_bucket_key(grid, _fill_grid_origin, _fill_cell_span)] = true
    for bucket_variant in dirty_buckets.keys():
        var bucket: Vector2i = bucket_variant
        if _paint_fill_bucket_into(_fill_image, _fill_grid_origin, _fill_grid_size, _fill_cell_span, bucket.x, bucket.y):
            changed = true
    for grid_variant in applied_positions:
        _pending_fill_updates.erase(grid_variant)
    return changed

func _advance_fill_scrub(grid_min: Vector2i, grid_max: Vector2i, row_count: int) -> bool:
    if _fill_image == null:
        return true
    if row_count <= 0:
        return false
    var total_rows := grid_max.y - grid_min.y + 1
    if total_rows <= 0:
        return true
    var start_row := clampi(_fill_scrub_next_row, 0, total_rows)
    var end_row := mini(total_rows, start_row + row_count)
    if end_row <= start_row:
        return true
    for x in range(grid_min.x, grid_max.x + 1):
        for row in range(start_row, end_row):
            var y := grid_min.y + row
            var grid := Vector2i(x, y)
            var local_x := x - _fill_grid_origin.x
            var local_y := y - _fill_grid_origin.y
            if local_x < 0 or local_x >= _fill_grid_size.x or local_y < 0 or local_y >= _fill_grid_size.y:
                continue
            var expected := Color.TRANSPARENT
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if not block.is_empty():
                var colors: Dictionary = _get_block_palette(block)
                expected = colors.get("fill", SPACE_BG)
            var current: Color = _fill_image.get_pixel(local_x, local_y)
            if current != expected:
                _fill_image.set_pixel(local_x, local_y, expected)
                _fill_scrub_changed = true
    _fill_scrub_next_row = end_row
    return _fill_scrub_next_row >= total_rows

func _paint_fill_region(grid_min: Vector2i, grid_max: Vector2i) -> void:
    _paint_fill_region_into(_fill_image, _fill_grid_origin, _fill_grid_size, _fill_cell_span, grid_min, grid_max)

func _paint_fill_region_into(image: Image, image_origin: Vector2i, image_grid_size: Vector2i, cell_span: int, grid_min: Vector2i, grid_max: Vector2i) -> void:
    if image == null:
        return
    if cell_span <= 1:
        var clipped_min := Vector2i(maxi(grid_min.x, image_origin.x), maxi(grid_min.y, image_origin.y))
        var image_max := Vector2i(image_origin.x + image_grid_size.x - 1, image_origin.y + image_grid_size.y - 1)
        var clipped_max := Vector2i(mini(grid_max.x, image_max.x), mini(grid_max.y, image_max.y))
        if clipped_min.x > clipped_max.x or clipped_min.y > clipped_max.y:
            return
        for x in range(clipped_min.x, clipped_max.x + 1):
            for y in range(clipped_min.y, clipped_max.y + 1):
                _set_fill_pixel_for_grid(image, image_origin, image_grid_size, Vector2i(x, y))
        return
    var span := maxi(1, cell_span)
    var bucket_min := _get_fill_bucket_key(grid_min, image_origin, span)
    var bucket_max := _get_fill_bucket_key(grid_max, image_origin, span)
    var max_bucket_x := _get_fill_texture_width(image_grid_size, span) - 1
    var max_bucket_y := _get_fill_texture_height(image_grid_size, span) - 1
    for bucket_x in range(maxi(0, bucket_min.x), mini(max_bucket_x, bucket_max.x) + 1):
        for bucket_y in range(maxi(0, bucket_min.y), mini(max_bucket_y, bucket_max.y) + 1):
            _paint_fill_bucket_into(image, image_origin, image_grid_size, span, bucket_x, bucket_y)

func _shift_fill_image_with_overlap(old_origin: Vector2i, new_origin: Vector2i, grid_size: Vector2i, cell_span: int) -> void:
    var new_image := _get_shift_fill_image(grid_size, cell_span)
    var old_max := Vector2i(old_origin.x + grid_size.x - 1, old_origin.y + grid_size.y - 1)
    var new_max := Vector2i(new_origin.x + grid_size.x - 1, new_origin.y + grid_size.y - 1)
    var overlap_min := Vector2i(maxi(old_origin.x, new_origin.x), maxi(old_origin.y, new_origin.y))
    var overlap_max := Vector2i(mini(old_max.x, new_max.x), mini(old_max.y, new_max.y))
    var has_overlap := overlap_min.x <= overlap_max.x and overlap_min.y <= overlap_max.y
    if has_overlap:
        var src_pos := _get_fill_bucket_key(overlap_min, old_origin, cell_span)
        var dst_pos := _get_fill_bucket_key(overlap_min, new_origin, cell_span)
        var overlap_size := Vector2i(
            _get_fill_bucket_key(overlap_max, old_origin, cell_span).x - src_pos.x + 1,
            _get_fill_bucket_key(overlap_max, old_origin, cell_span).y - src_pos.y + 1
        )
        new_image.blit_rect(_fill_image, Rect2i(src_pos, overlap_size), dst_pos)
    var old_fill_image := _fill_image
    _fill_image = new_image
    _fill_shift_image = old_fill_image
    _fill_grid_origin = new_origin
    _fill_grid_size = grid_size
    _fill_cell_span = cell_span
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

func _get_shift_fill_image(grid_size: Vector2i, cell_span: int) -> Image:
    var image_w := _get_fill_texture_width(grid_size, cell_span)
    var image_h := _get_fill_texture_height(grid_size, cell_span)
    if _fill_shift_image == null or _fill_shift_image.get_width() != image_w or _fill_shift_image.get_height() != image_h:
        _fill_shift_image = Image.create(image_w, image_h, false, Image.FORMAT_RGBA8)
    _fill_shift_image.fill(Color.TRANSPARENT)
    return _fill_shift_image

func _clear_fill_prewarm() -> void:
    _fill_prewarm_image = null
    _fill_prewarm_grid_origin = Vector2i(2147483647, 2147483647)
    _fill_prewarm_grid_size = Vector2i.ZERO
    _fill_prewarm_cell_span = 1
    _fill_prewarm_next_row = 0
    _fill_prewarm_ready = false
    _fill_prewarm_waiting_for_swap = false
    _fill_prewarm_completed_job_id = 0
    if _fill_prewarm_thread_active:
        _fill_prewarm_active_job_id = -1

func _ensure_fill_prewarm(target_origin: Vector2i, target_size: Vector2i, cell_span: int) -> void:
    if _fill_prewarm_image != null and _fill_prewarm_grid_origin == target_origin and _fill_prewarm_grid_size == target_size and _fill_prewarm_cell_span == cell_span:
        return
    if _fill_texture == null and _fill_prewarm_image != null:
        return
    if _fill_prewarm_thread_active:
        if _fill_prewarm_active_origin == target_origin and _fill_prewarm_active_size == target_size and _fill_prewarm_active_cell_span == cell_span:
            return
        return
    if USE_THREADED_FILL_PREWARM:
        _start_fill_prewarm_thread(target_origin, target_size, cell_span)
    else:
        _start_fill_prewarm_incremental(target_origin, target_size, cell_span)

func _start_fill_prewarm_incremental(target_origin: Vector2i, target_size: Vector2i, cell_span: int) -> void:
    if scene_ref == null or target_size.x <= 0 or target_size.y <= 0:
        return
    var texture_size := _grid_size_to_fill_texture_size(target_size, cell_span)
    _fill_prewarm_job_id += 1
    _fill_prewarm_active_job_id = _fill_prewarm_job_id
    _fill_prewarm_active_origin = target_origin
    _fill_prewarm_active_size = target_size
    _fill_prewarm_active_cell_span = cell_span
    _fill_prewarm_image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
    _fill_prewarm_image.fill(Color.TRANSPARENT)
    _fill_prewarm_grid_origin = target_origin
    _fill_prewarm_grid_size = target_size
    _fill_prewarm_cell_span = cell_span
    _fill_prewarm_next_row = 0
    _fill_prewarm_ready = false
    _fill_prewarm_waiting_for_swap = false
    _fill_prewarm_completed_job_id = _fill_prewarm_active_job_id
    _force_redraw = true

func _start_fill_prewarm_thread(target_origin: Vector2i, target_size: Vector2i, cell_span: int) -> void:
    if scene_ref == null or target_size.x <= 0 or target_size.y <= 0:
        return
    var snapshot := {}
    var target_max := Vector2i(target_origin.x + target_size.x - 1, target_origin.y + target_size.y - 1)
    for x in range(target_origin.x, target_max.x + 1):
        for y in range(target_origin.y, target_max.y + 1):
            var grid := Vector2i(x, y)
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if not block.is_empty():
                snapshot[grid] = block.duplicate(false)
    _fill_prewarm_job_id += 1
    _fill_prewarm_active_job_id = _fill_prewarm_job_id
    _fill_prewarm_active_origin = target_origin
    _fill_prewarm_active_size = target_size
    _fill_prewarm_active_cell_span = cell_span
    _fill_prewarm_image = null
    _fill_prewarm_grid_origin = target_origin
    _fill_prewarm_grid_size = target_size
    _fill_prewarm_cell_span = cell_span
    _fill_prewarm_next_row = 0
    _fill_prewarm_ready = false
    var request := {
        "job_id": _fill_prewarm_active_job_id,
        "origin": target_origin,
        "size": target_size,
        "cell_span": cell_span,
        "blocks": snapshot,
        "electric_enabled": bool(scene_ref.runtime_stats.get("electric_enabled", false)),
    }
    _fill_prewarm_thread = Thread.new()
    var err := _fill_prewarm_thread.start(Callable(self, "_build_fill_prewarm_image_thread").bind(request))
    if err == OK:
        _fill_prewarm_thread_active = true
    else:
        _fill_prewarm_thread = null
        _fill_prewarm_thread_active = false

func _poll_fill_prewarm_thread() -> void:
    if not _fill_prewarm_thread_active or _fill_prewarm_thread == null or _fill_prewarm_thread.is_alive():
        return
    var result: Variant = _fill_prewarm_thread.wait_to_finish()
    _fill_prewarm_thread = null
    _fill_prewarm_thread_active = false
    if not (result is Dictionary):
        return
    var job_id := int(result.get("job_id", -1))
    if job_id != _fill_prewarm_active_job_id or job_id <= _fill_prewarm_completed_job_id:
        return
    _fill_prewarm_completed_job_id = job_id
    _fill_prewarm_image = result.get("image", null)
    _fill_prewarm_grid_origin = Vector2i(result.get("origin", _fill_prewarm_active_origin))
    _fill_prewarm_grid_size = Vector2i(result.get("size", _fill_prewarm_active_size))
    _fill_prewarm_cell_span = int(result.get("cell_span", _fill_prewarm_active_cell_span))
    _fill_prewarm_next_row = _fill_prewarm_grid_size.y
    _fill_prewarm_ready = _fill_prewarm_image != null
    if _fill_prewarm_ready:
        _force_redraw = true

func _finish_fill_prewarm_thread() -> void:
    if _fill_prewarm_thread_active and _fill_prewarm_thread != null:
        _fill_prewarm_thread.wait_to_finish()
    _fill_prewarm_thread = null
    _fill_prewarm_thread_active = false

func _build_fill_prewarm_image_thread(request: Dictionary) -> Dictionary:
    var origin := Vector2i(request.get("origin", Vector2i.ZERO))
    var grid_size := Vector2i(request.get("size", Vector2i.ZERO))
    var cell_span := maxi(1, int(request.get("cell_span", 1)))
    var texture_size := _grid_size_to_fill_texture_size(grid_size, cell_span)
    var image := Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    var blocks_snapshot: Dictionary = request.get("blocks", {})
    var palette_cache := {}
    if cell_span <= 1:
        for grid_variant in blocks_snapshot.keys():
            var grid: Vector2i = grid_variant
            var local_x := grid.x - origin.x
            var local_y := grid.y - origin.y
            if local_x < 0 or local_x >= grid_size.x or local_y < 0 or local_y >= grid_size.y:
                continue
            var block: Dictionary = blocks_snapshot.get(grid, {})
            image.set_pixel(local_x, local_y, _get_worker_block_fill(block, bool(request.get("electric_enabled", false)), palette_cache))
    else:
        var texture_w := _get_fill_texture_width(grid_size, cell_span)
        var texture_h := _get_fill_texture_height(grid_size, cell_span)
        for bucket_x in range(texture_w):
            for bucket_y in range(texture_h):
                image.set_pixel(bucket_x, bucket_y, _resolve_worker_fill_bucket_color(blocks_snapshot, origin, grid_size, cell_span, bucket_x, bucket_y, bool(request.get("electric_enabled", false)), palette_cache))
    return {
        "job_id": int(request.get("job_id", -1)),
        "origin": origin,
        "size": grid_size,
        "cell_span": cell_span,
        "image": image,
    }

func _resolve_worker_fill_bucket_color(blocks_snapshot: Dictionary, image_origin: Vector2i, image_grid_size: Vector2i, cell_span: int, bucket_x: int, bucket_y: int, electric_enabled: bool, palette_cache: Dictionary) -> Color:
    var span := maxi(1, cell_span)
    var start_x := image_origin.x + bucket_x * span
    var start_y := image_origin.y + bucket_y * span
    var end_x := mini(start_x + span - 1, image_origin.x + image_grid_size.x - 1)
    var end_y := mini(start_y + span - 1, image_origin.y + image_grid_size.y - 1)
    var fallback_fill := Color.TRANSPARENT
    var fallback_score := -1
    for x in range(start_x, end_x + 1):
        for y in range(start_y, end_y + 1):
            var block: Dictionary = blocks_snapshot.get(Vector2i(x, y), {})
            if block.is_empty():
                continue
            var score := 1
            if bool(block.get("core_refill", false)):
                score += 3
            if bool(block.get("regenerated", false)):
                score += 1
            score += int(block.get("type", 0))
            if score > fallback_score:
                fallback_fill = _get_worker_block_fill(block, electric_enabled, palette_cache)
                fallback_score = score
    return fallback_fill

func _get_zone_edge_color(zone: int) -> Color:
    return ZONE_EDGE_COLORS.get(zone, DEFAULT_EDGE)

func _get_block_edge_fallback(block: Dictionary) -> Color:
    return _get_zone_edge_color(int(block.get("zone", ZONE_AUTUMN)))

func _get_draw_edge_color(edge_color: Color, alpha := 1.0) -> Color:
    var max_channel := maxf(maxf(edge_color.r, edge_color.g), maxf(edge_color.b, 1.0))
    return Color(
        edge_color.r / max_channel,
        edge_color.g / max_channel,
        edge_color.b / max_channel,
        alpha
    )

func _get_worker_block_fill(block: Dictionary, electric_enabled: bool, palette_cache: Dictionary) -> Color:
    if block.is_empty():
        return Color.TRANSPARENT
    var zone: int = int(block.get("zone", ZONE_AUTUMN))
    var block_type: int = int(block.get("type", 0))
    var regenerated: bool = bool(block.get("regenerated", false))
    var core_refill: bool = bool(block.get("core_refill", false))
    var unbreakable: bool = bool(block.get("unbreakable", false))
    var hardness_tier := 1
    var cache_key := "%d:%d:%d:%d:%d:%d:%d" % [zone, block_type, int(regenerated), int(core_refill), int(electric_enabled), hardness_tier, int(unbreakable)]
    if palette_cache.has(cache_key):
        return Color(palette_cache[cache_key])
    var fill: Color = ZONE_FILLS.get(zone, SPACE_BG)
    var edge: Color = _get_zone_edge_color(zone)
    if unbreakable:
        palette_cache[cache_key] = PIT_WALL_FILL
        return PIT_WALL_FILL
    match block_type:
        1:
            fill = _mix_fill_with_edge(ZONE_FILLS.get(zone, Color(0.11, 0.07, 0.08, 1.0)), _get_zone_edge_color(zone), 0.32)
        2:
            var expected_fill := _mix_fill_with_edge(fill, edge, 0.22)
            fill = expected_fill.lerp(HACKER_BLOCK_FILL, 0.28) if electric_enabled else expected_fill.lerp(HACKER_BLOCK_DIM, 0.12)
        3:
            var base_fill := _mix_fill_with_edge(fill, edge, 0.16)
            fill = base_fill.lightened(0.08)
        4:
            fill = _mix_fill_with_edge(THORN_FILL, THORN_EDGE, 0.24)
        _:
            if core_refill:
                fill = CORE_REFILL_FILL
            elif regenerated:
                fill = _mix_fill_with_edge(REGEN_FILL, REGEN_EDGE, 0.22)
            else:
                fill = _mix_fill_with_edge(fill, edge, 0.22)
    if not core_refill:
        fill = _apply_hardness_tint(fill, hardness_tier)
    fill = Color(fill.r, fill.g, fill.b, 1.0)
    palette_cache[cache_key] = fill
    return fill

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
    _paint_fill_region_into(_fill_prewarm_image, _fill_prewarm_grid_origin, _fill_prewarm_grid_size, _fill_prewarm_cell_span, row_grid_min, row_grid_max)
    _fill_prewarm_next_row = end_row
    _fill_prewarm_ready = _fill_prewarm_next_row >= _fill_prewarm_grid_size.y

func _can_apply_fill_prewarm(target_origin: Vector2i, target_size: Vector2i, cell_span: int) -> bool:
    return _fill_prewarm_ready and _fill_prewarm_grid_origin == target_origin and _fill_prewarm_grid_size == target_size and _fill_prewarm_cell_span == cell_span and _fill_prewarm_image != null

func _apply_fill_prewarm() -> void:
    _fill_image = _fill_prewarm_image
    _fill_grid_origin = _fill_prewarm_grid_origin
    _fill_grid_size = _fill_prewarm_grid_size
    _fill_cell_span = _fill_prewarm_cell_span
    _clear_fill_prewarm()

func _apply_pending_fill_updates_to_prewarm() -> void:
    if _fill_prewarm_image == null or _pending_fill_updates.is_empty():
        return
    if _fill_prewarm_cell_span <= 1:
        for grid_variant in _pending_fill_updates.keys():
            var grid: Vector2i = grid_variant
            if grid.x < _fill_prewarm_grid_origin.x or grid.y < _fill_prewarm_grid_origin.y:
                continue
            if grid.x >= _fill_prewarm_grid_origin.x + _fill_prewarm_grid_size.x or grid.y >= _fill_prewarm_grid_origin.y + _fill_prewarm_grid_size.y:
                continue
            _set_fill_pixel_for_grid(_fill_prewarm_image, _fill_prewarm_grid_origin, _fill_prewarm_grid_size, grid)
        return
    var dirty_buckets: Dictionary = {}
    for grid_variant in _pending_fill_updates.keys():
        var grid: Vector2i = grid_variant
        if grid.x < _fill_prewarm_grid_origin.x or grid.y < _fill_prewarm_grid_origin.y:
            continue
        if grid.x >= _fill_prewarm_grid_origin.x + _fill_prewarm_grid_size.x or grid.y >= _fill_prewarm_grid_origin.y + _fill_prewarm_grid_size.y:
            continue
        dirty_buckets[_get_fill_bucket_key(grid, _fill_prewarm_grid_origin, _fill_prewarm_cell_span)] = true
    for bucket_variant in dirty_buckets.keys():
        var bucket: Vector2i = bucket_variant
        _paint_fill_bucket_into(_fill_prewarm_image, _fill_prewarm_grid_origin, _fill_prewarm_grid_size, _fill_prewarm_cell_span, bucket.x, bucket.y)

func _get_fill_cell_span(reduce_detail: bool, ultra_reduce_detail: bool) -> int:
    if ultra_reduce_detail:
        return ULTRA_FILL_CELL_SPAN
    if reduce_detail:
        return HEAVY_FILL_CELL_SPAN
    return 1

func _grid_size_to_fill_texture_size(grid_size: Vector2i, cell_span: int) -> Vector2i:
    return Vector2i(_get_fill_texture_width(grid_size, cell_span), _get_fill_texture_height(grid_size, cell_span))

func _get_fill_texture_width(grid_size: Vector2i, cell_span: int) -> int:
    var span := maxi(1, cell_span)
    return maxi(1, int(ceili(float(grid_size.x) / float(span))))

func _get_fill_texture_height(grid_size: Vector2i, cell_span: int) -> int:
    var span := maxi(1, cell_span)
    return maxi(1, int(ceili(float(grid_size.y) / float(span))))

func _get_fill_bucket_key(grid: Vector2i, origin: Vector2i, cell_span: int) -> Vector2i:
    var span := maxi(1, cell_span)
    return Vector2i(
        int(floor(float(grid.x - origin.x) / float(span))),
        int(floor(float(grid.y - origin.y) / float(span)))
    )

func _set_fill_pixel_for_grid(image: Image, image_origin: Vector2i, image_grid_size: Vector2i, grid: Vector2i) -> bool:
    if image == null:
        return false
    var local_x := grid.x - image_origin.x
    var local_y := grid.y - image_origin.y
    if local_x < 0 or local_x >= image_grid_size.x or local_y < 0 or local_y >= image_grid_size.y:
        return false
    var expected := Color.TRANSPARENT
    if scene_ref.blocks.has(grid):
        var block: Dictionary = scene_ref.blocks.get(grid, {})
        if not block.is_empty():
            var colors: Dictionary = _get_block_palette(block)
            expected = colors.get("fill", SPACE_BG)
    if image.get_pixel(local_x, local_y) == expected:
        return false
    image.set_pixel(local_x, local_y, expected)
    return true

func _paint_fill_bucket_into(image: Image, image_origin: Vector2i, image_grid_size: Vector2i, cell_span: int, bucket_x: int, bucket_y: int) -> bool:
    if image == null:
        return false
    var texture_w := _get_fill_texture_width(image_grid_size, cell_span)
    var texture_h := _get_fill_texture_height(image_grid_size, cell_span)
    if bucket_x < 0 or bucket_y < 0 or bucket_x >= texture_w or bucket_y >= texture_h:
        return false
    var color := _resolve_fill_bucket_color(image_origin, image_grid_size, cell_span, bucket_x, bucket_y)
    if image.get_pixel(bucket_x, bucket_y) == color:
        return false
    image.set_pixel(bucket_x, bucket_y, color)
    return true

func _resolve_fill_bucket_color(image_origin: Vector2i, image_grid_size: Vector2i, cell_span: int, bucket_x: int, bucket_y: int) -> Color:
    var span := maxi(1, cell_span)
    var start_x := image_origin.x + bucket_x * span
    var start_y := image_origin.y + bucket_y * span
    var end_x := mini(start_x + span - 1, image_origin.x + image_grid_size.x - 1)
    var end_y := mini(start_y + span - 1, image_origin.y + image_grid_size.y - 1)
    var fallback_fill := Color.TRANSPARENT
    var fallback_score := -1
    for x in range(start_x, end_x + 1):
        for y in range(start_y, end_y + 1):
            var block: Dictionary = scene_ref.blocks.get(Vector2i(x, y), {})
            if block.is_empty():
                continue
            var score := 1
            if scene_ref.exposed_edges.has(Vector2i(x, y)):
                score += 4
            if bool(block.get("core_refill", false)):
                score += 3
            if bool(block.get("regenerated", false)):
                score += 1
            score += int(block.get("type", 0))
            if score > fallback_score:
                var colors: Dictionary = _get_block_palette(block)
                fallback_fill = colors.get("fill", SPACE_BG)
                fallback_score = score
    return fallback_fill

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
            var edge_color: Color = colors.get("edge", _get_block_edge_fallback(block))
            var draw_color := _get_draw_edge_color(edge_color, outline_alpha)
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
    var align_cells := ULTRA_OUTLINE_CACHE_ALIGN_CELLS if _last_ultra_reduce_detail else HEAVY_OUTLINE_CACHE_ALIGN_CELLS
    return Vector2i(
        _floor_to_step(center_grid.x, align_cells),
        _floor_to_step(center_grid.y, align_cells)
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
    return "Firewall vis %d  load %d  detail %s/%s  fillQ %d  fillR %s  fillD %s(%d)  fillCnt d:%d o:%d s:%d  fillMiss %d  fillSwap a:%d d:%d  fillWorker %s" % [
        _last_visible_cell_budget,
        _last_effect_load,
        "heavy" if _last_reduce_detail else "full",
        "ultra" if _last_ultra_reduce_detail else "normal",
        _pending_fill_updates.size(),
        _last_fill_rebuild_reason,
        _last_fill_dirty_source,
        int(_fill_dirty_source_counts.get(_last_fill_dirty_source, 0)),
        _fill_rebuild_dirty_count,
        _fill_rebuild_origin_count,
        _fill_rebuild_size_count,
        _fill_prewarm_miss_count,
        _fill_prewarm_apply_count,
        _fill_prewarm_defer_count,
        "busy" if _fill_prewarm_thread_active else ("ready" if _fill_prewarm_ready else "-"),
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
    color = _get_draw_edge_color(color, color.a)
    if (mask & 1) != 0:
        draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), color, width)
    if (mask & 2) != 0:
        draw_line(rect.position + Vector2(0.0, rect.size.y), rect.position + rect.size, color, width)
    if (mask & 4) != 0:
        draw_line(rect.position, rect.position + Vector2(0.0, rect.size.y), color, width)
    if (mask & 8) != 0:
        draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + rect.size, color, width)

func _draw_tetromino_block_glyph(grid: Vector2i, rect: Rect2, active: bool) -> void:
    var pulse := (sin(_time_elapsed * 5.2 + float(grid.x) * 0.73 + float(grid.y) * 0.41) + 1.0) * 0.5
    var definition := scene_ref.get_tetromino_definition(grid)
    var color: Color = definition.get("color", Color(0.0, 1.0, 1.0, 1.0))
    var offsets: Array = definition.get("offsets", [Vector2i.ZERO])
    var alpha := (0.72 + pulse * 0.2) if active else 0.34
    var min_x := 999
    var max_x := -999
    var min_y := 999
    var max_y := -999
    for offset_variant in offsets:
        var offset := Vector2i(offset_variant)
        min_x = mini(min_x, offset.x)
        max_x = maxi(max_x, offset.x)
        min_y = mini(min_y, offset.y)
        max_y = maxi(max_y, offset.y)
    var cols := maxi(1, max_x - min_x + 1)
    var rows := maxi(1, max_y - min_y + 1)
    var square_size := minf((rect.size.x - 8.0) / float(cols), (rect.size.y - 8.0) / float(rows))
    var shape_size := Vector2(float(cols) * square_size, float(rows) * square_size)
    var origin := rect.position + (rect.size - shape_size) * 0.5
    for offset_variant in offsets:
        var offset := Vector2i(offset_variant)
        var cell_pos := origin + Vector2(float(offset.x - min_x), float(offset.y - min_y)) * square_size
        var cell_rect := Rect2(cell_pos + Vector2.ONE, Vector2.ONE * maxf(2.0, square_size - 2.0))
        draw_rect(cell_rect, Color(color.r, color.g, color.b, alpha), true)
        draw_rect(cell_rect, Color(TETROMINO_EDGE.r, TETROMINO_EDGE.g, TETROMINO_EDGE.b, alpha * 0.72), false, 1.0)

func _draw_tetromino_bursts() -> void:
    for burst_variant in scene_ref.tetromino_bursts:
        var burst: Dictionary = burst_variant
        var duration := maxf(float(burst.get("duration", scene_ref.TETROMINO_EFFECT_DURATION)), 0.001)
        var life_ratio := clampf(float(burst.get("timer", 0.0)) / duration, 0.0, 1.0)
        var scale := 0.82 + life_ratio * 0.18
        var color: Color = burst.get("color", Color(0.0, 1.0, 1.0, 1.0))
        var fill := Color(color.r, color.g, color.b, 0.28 * life_ratio)
        var edge := Color(TETROMINO_EDGE.r, TETROMINO_EDGE.g, TETROMINO_EDGE.b, 0.9 * life_ratio)
        for cell_variant in burst.get("cells", []):
            var cell := Vector2i(cell_variant)
            var center := scene_ref.grid_to_world(cell)
            var size := scene_ref.BLOCK_SIZE * scale
            var rect := Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size)
            draw_rect(rect, fill, true)
            draw_rect(rect, Color(color.r, color.g, color.b, 0.82 * life_ratio), false, 2.0)
            draw_rect(rect.grow(-3.0 * scale), edge, false, 1.0)

func _get_block_palette(block: Dictionary, grid: Vector2i = Vector2i(2147483647, 2147483647)) -> Dictionary:
    var zone: int = int(block.get("zone", ZONE_AUTUMN))
    var block_type: int = int(block.get("type", 0))
    var regenerated: bool = bool(block.get("regenerated", false))
    var core_refill: bool = bool(block.get("core_refill", false))
    var unbreakable: bool = bool(block.get("unbreakable", false))
    var electric_enabled: bool = bool(scene_ref.runtime_stats.get("electric_enabled", false))
    var gold_enabled: bool = true
    var hardness_tier: int = _get_visual_hardness_tier(block)
    var grid_cache_key := "%d:%d" % [grid.x, grid.y] if block_type == scene_ref.BlockType.ELECTRIC and grid.x < 2147483647 else "-"
    var cache_key := "%d:%d:%d:%d:%d:%d:%d:%d:%s" % [zone, block_type, int(regenerated), int(core_refill), int(electric_enabled), int(gold_enabled), hardness_tier, int(unbreakable), grid_cache_key]
    if _palette_cache.has(cache_key):
        return _palette_cache[cache_key]
    var fill: Color = ZONE_FILLS.get(zone, SPACE_BG)
    var edge: Color = _get_zone_edge_color(zone)
    if unbreakable:
        fill = PIT_WALL_FILL
        edge = PIT_WALL_EDGE
        var wall_palette := {"fill": fill, "edge": edge}
        _palette_cache[cache_key] = wall_palette
        return wall_palette
    match block_type:
        scene_ref.BlockType.CORE:
            fill = _mix_fill_with_edge(ZONE_FILLS.get(zone, Color(0.11, 0.07, 0.08, 1.0)), _get_zone_edge_color(zone), 0.32)
            edge = _get_zone_edge_color(zone)
        scene_ref.BlockType.ELECTRIC:
            var expected_fill := _mix_fill_with_edge(fill, edge, 0.22)
            if grid.x < 2147483647:
                var tetromino_color: Color = scene_ref.get_tetromino_definition(grid).get("color", Color(0.0, 1.0, 1.0, 1.0))
                fill = expected_fill.lerp(Color(tetromino_color.r, tetromino_color.g, tetromino_color.b, 1.0), 0.46 if electric_enabled else 0.22)
                edge = edge.lerp(Color(tetromino_color.r, tetromino_color.g, tetromino_color.b, 1.0), 0.62 if electric_enabled else 0.3)
            else:
                fill = expected_fill.lerp(HACKER_BLOCK_FILL, 0.28) if electric_enabled else expected_fill.lerp(HACKER_BLOCK_DIM, 0.12)
                edge = edge.lerp(HACKER_BLOCK_EDGE, 0.42) if electric_enabled else edge.lerp(HACKER_BLOCK_DIM, 0.22)
        scene_ref.BlockType.GOLD:
            var base_fill := _mix_fill_with_edge(fill, edge, 0.16)
            fill = base_fill.lightened(0.08) if gold_enabled else base_fill
            edge = Color(
                minf(edge.r * 1.06 + 0.04, 1.0),
                minf(edge.g * 1.06 + 0.04, 1.0),
                minf(edge.b * 1.06 + 0.04, 1.0),
                1.0
            )
        scene_ref.BlockType.THORN:
            fill = _mix_fill_with_edge(THORN_FILL, THORN_EDGE, 0.24)
            edge = THORN_EDGE
        _:
            if core_refill:
                fill = CORE_REFILL_FILL
                edge = CORE_REFILL_EDGE
            elif regenerated:
                fill = _mix_fill_with_edge(REGEN_FILL, REGEN_EDGE, 0.22)
                edge = REGEN_EDGE
            else:
                fill = _mix_fill_with_edge(fill, edge, 0.22)
    if not core_refill:
        fill = _apply_hardness_tint(fill, hardness_tier)
    fill = Color(fill.r, fill.g, fill.b, 1.0)
    var palette := {"fill": fill, "edge": edge}
    _palette_cache[cache_key] = palette
    return palette

func _mix_fill_with_edge(fill: Color, edge: Color, amount: float) -> Color:
    var edge_clamped := Color(min(edge.r, 1.0), min(edge.g, 1.0), min(edge.b, 1.0), 1.0)
    return fill.lerp(edge_clamped, amount)

func _get_visual_hardness_tier(block: Dictionary) -> int:
    return 1

func _apply_hardness_tint(fill: Color, hardness_tier: int) -> Color:
    match hardness_tier:
        3:
            return fill.darkened(0.16)
        2:
            return fill.darkened(0.08)
        _:
            return fill

func _draw_core_influence_rings(ultra_compact: bool = false) -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    for core in scene_ref.planet_data.cores:
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var world_radius := float(scene_ref.planet_data.get_effective_influence_radius(core)) * scene_ref.BLOCK_SIZE
        if bool(core.alive):
            var zone_col: Color = ZONE_RING_COLORS.get(int(core.zone), Color(1.0, 0.2, 0.1, 0.25))
            draw_arc(center, world_radius, 0.0, TAU, 28 if ultra_compact else 40, Color(zone_col.r, zone_col.g, zone_col.b, 0.65 if ultra_compact else 0.8), 2.0 if ultra_compact else 2.5)
        else:
            draw_arc(center, world_radius, 0.0, TAU, 24 if ultra_compact else 32, Color(0.15, 0.8, 1.0, 0.2), 1.2 if ultra_compact else 1.6)

func _draw_core_health_bars(ultra_compact: bool = false) -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    var canvas_transform := get_canvas_transform()
    var cam_scale := canvas_transform.get_scale()
    var viewport_size := get_viewport_rect().size
    var viewport_rect := Rect2(-canvas_transform.origin / cam_scale, viewport_size / cam_scale)
    for core_variant in scene_ref.planet_data.cores:
        var core: Dictionary = core_variant
        if not bool(core.get("alive", false)):
            continue
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var core_size := float(int(core.get("size", 3)))
        var cull_radius := (core_size * 0.6 + 2.5) * scene_ref.BLOCK_SIZE
        if not viewport_rect.grow(cull_radius).has_point(center):
            continue
        var hp_ratio := clampf(scene_ref.planet_data.get_core_hp_ratio(core), 0.0, 1.0)
        var is_boss := str(core.get("role", "")) == "boss" or str(core.get("role", "")) == "final"
        var bar_width := (56.0 if ultra_compact else 72.0) + core_size * (6.0 if ultra_compact else 8.0)
        if is_boss:
            bar_width += 20.0 if ultra_compact else 28.0
        var bar_height := 4.0 if ultra_compact else 6.0
        var y_offset := (core_size * 0.5 + 1.8) * scene_ref.BLOCK_SIZE
        var bar_rect := Rect2(
            center + Vector2(-bar_width * 0.5, -y_offset),
            Vector2(bar_width, bar_height)
        )
        var fill_color := Color(0.6, 1.8, 2.4, 0.95)
        if is_boss:
            fill_color = Color(1.0, 0.42, 0.24, 0.98)
        draw_rect(bar_rect.grow(1.5 if ultra_compact else 2.0), Color(0.0, 0.0, 0.0, 0.6), true)
        draw_rect(bar_rect, Color(0.12, 0.14, 0.18, 0.92), true)
        draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * hp_ratio, bar_rect.size.y)), fill_color, true)
        if hp_ratio < 0.999:
            draw_rect(bar_rect, Color(fill_color.r, fill_color.g, fill_color.b, 0.9), false, 1.0)

func _draw_pit_shell(visible_grid_min: Vector2i, visible_grid_max: Vector2i) -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    var start_y := maxi(visible_grid_min.y - 4, scene_ref.planet_data.get_upper_wall_top_y())
    var end_y := mini(visible_grid_max.y + 4, scene_ref.planet_data.PIT_BOTTOM_Y)
    if end_y < start_y:
        return
    var left_points := PackedVector2Array()
    var right_points := PackedVector2Array()
    for y in range(start_y, end_y + 1):
        var left_x: int = scene_ref.planet_data.get_left_wall_x(y)
        var right_x: int = scene_ref.planet_data.get_right_wall_x(y)
        left_points.append(scene_ref.grid_to_world(Vector2i(left_x, y)))
        right_points.append(scene_ref.grid_to_world(Vector2i(right_x, y)))
    if left_points.size() >= 2:
        for idx in range(left_points.size() - 1):
            var a := left_points[idx]
            var b := left_points[idx + 1]
            draw_line(a + Vector2(-64.0, 0.0), a, PIT_WALL_SHADOW, 42.0)
            draw_line(a, b, PIT_WALL_EDGE, 12.0)
            draw_line(a + Vector2(-28.0, 0.0), b + Vector2(-28.0, 0.0), Color(PIT_GLOW.r, PIT_GLOW.g, PIT_GLOW.b, 0.42), 24.0)
    if right_points.size() >= 2:
        for idx in range(right_points.size() - 1):
            var a := right_points[idx]
            var b := right_points[idx + 1]
            draw_line(a + Vector2(64.0, 0.0), a, PIT_WALL_SHADOW, 42.0)
            draw_line(a, b, PIT_WALL_EDGE, 12.0)
            draw_line(a + Vector2(28.0, 0.0), b + Vector2(28.0, 0.0), Color(PIT_GLOW.r, PIT_GLOW.g, PIT_GLOW.b, 0.42), 24.0)

func _draw_core_shields(ultra_compact: bool = false) -> void:
    if scene_ref == null or scene_ref.planet_data == null:
        return
    for core in scene_ref.planet_data.cores:
        if not bool(core.alive):
            continue
        if not scene_ref.planet_data.is_core_locked(int(core.id), scene_ref._core_unlocks_center()):
            continue
        var center := scene_ref.grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var dome_radius := (float(int(core.get("size", 3))) * 0.5 + 2.0) * scene_ref.BLOCK_SIZE
        draw_arc(center, dome_radius, 0.0, TAU, 20 if ultra_compact else 24, Color(0.3, 0.6, 1.0, 0.65), 1.2 if ultra_compact else 1.5)

func _draw_ghost_debris(ultra_compact: bool = false) -> void:
    for debris_variant in scene_ref.ghost_debris:
        var debris: Dictionary = debris_variant
        var pos: Vector2 = debris.get("pos", Vector2.ZERO)
        var life_ratio := clampf(float(debris.get("life", 0.0)) / scene_ref.AUTUMN_DEBRIS_LIFETIME, 0.0, 1.0)
        var pulse_seed := float(int(debris.get("core_id", 0)) * 13 + int(round(pos.x * 0.02)) + int(round(pos.y * 0.02)))
        var pulse_t := _time_elapsed * 7.5 + pulse_seed
        var pulse := 0.5 + 0.5 * sin(pulse_t)
        var base_color := Color(1.0, 0.12, 0.16, 0.95)
        var pulse_color := Color(1.0, 0.3, 0.72, 0.98)
        var shot_color := base_color.lerp(pulse_color, pulse)
        var glow_alpha := (0.18 if ultra_compact else 0.14) + 0.1 * pulse
        var outer_radius := (10.0 if ultra_compact else 9.0) + 3.5 * pulse
        var inner_radius := (5.5 if ultra_compact else 4.5) + 2.0 * pulse
        var ring_radius := outer_radius + (4.0 if ultra_compact else 3.0) + 2.0 * pulse
        var trail_dir := Vector2(debris.get("vel", Vector2.ZERO)).normalized()
        if trail_dir.length_squared() <= 0.001:
            trail_dir = Vector2.UP
        var tail_pos := pos - trail_dir * ((12.0 if ultra_compact else 10.0) + pulse * 6.0)
        draw_circle(pos, ring_radius, Color(shot_color.r, shot_color.g, shot_color.b, glow_alpha * maxf(0.4, life_ratio)))
        draw_line(tail_pos, pos, Color(shot_color.r, shot_color.g, shot_color.b, 0.45 + pulse * 0.2), (4.0 if ultra_compact else 3.0) + pulse * 1.5)
        draw_circle(pos, outer_radius, Color(shot_color.r, shot_color.g, shot_color.b, 0.24 + pulse * 0.12))
        draw_circle(pos, inner_radius, shot_color)

func _draw_root_cross_lasers(ultra_compact: bool = false) -> void:
    for state_variant in scene_ref.root_cross_lasers.values():
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
                draw_line(start, finish, Color(0.3, 0.8, 2.0, 0.18), 7.0 if ultra_compact else 10.0)
                draw_line(start, finish, Color(0.4, 1.0, 2.5, 0.85), 1.6 if ultra_compact else 2.0)

func _draw_cipher_lasers(ultra_compact: bool = false) -> void:
    for state_variant in scene_ref.cipher_laser_states.values():
        var state: Dictionary = state_variant
        var laser_state := str(state.get("state", "idle"))
        if laser_state != "warning" and laser_state != "firing":
            continue
        var origin: Vector2 = state.get("origin", Vector2.ZERO)
        var dir: Vector2 = Vector2(state.get("dir", Vector2.RIGHT)).normalized()
        if dir.length_squared() <= 0.001:
            continue
        var length := scene_ref.BLOCK_SIZE * 40.0
        var end := origin + dir * length
        if laser_state == "warning":
            draw_line(origin, end, Color(1.0, 0.48, 0.18, 0.22), 5.0 if ultra_compact else 7.0)
            draw_line(origin, end, Color(1.0, 0.82, 0.36, 0.85), 1.4 if ultra_compact else 2.0)
        else:
            draw_line(origin, end, Color(1.0, 0.32, 0.12, 0.3), 14.0 if ultra_compact else 18.0)
            draw_line(origin, end, Color(1.0, 0.56, 0.18, 0.95), 4.0 if ultra_compact else 5.0)

func _draw_roaming_powerups() -> void:
    for powerup_variant in scene_ref.roaming_powerups:
        var powerup: Dictionary = powerup_variant
        var pos: Vector2 = powerup.get("position", Vector2.ZERO)
        var powerup_type := str(powerup.get("type", "haste"))
        var color := Color(0.7, 1.0, 0.82, 0.95)
        match powerup_type:
            "haste":
                color = Color(1.0, 0.7, 0.24, 0.95)
            "magnet":
                color = Color(0.35, 1.0, 0.95, 0.95)
            "seismic_charge":
                color = Color(1.0, 0.58, 0.16, 0.95)
        var pulse := 0.7 + 0.3 * (sin(_time_elapsed * 6.0 + float(powerup.get("phase", 0.0))) + 1.0) * 0.5
        draw_circle(pos, 12.0, Color(color.r, color.g, color.b, 0.12 * pulse))
        draw_arc(pos, 10.0, 0.0, TAU, 22, Color(color.r, color.g, color.b, 0.78), 2.0)
        draw_circle(pos, 4.0, Color(color.r, color.g, color.b, 1.0))

func _draw_final_funnel() -> void:
    if not scene_ref.final_core_exposed or scene_ref.planet_data == null:
        return
    var anchor_grid := scene_ref.world_to_grid(scene_ref.bottom_cutscene_anchor)
    var start_y: int = maxi(scene_ref.PLANET_DATA_SCRIPT.PIT_TOP_Y + 120, anchor_grid.y - 92)
    var end_y: int = mini(scene_ref.PLANET_DATA_SCRIPT.PIT_BOTTOM_Y, anchor_grid.y + 10)
    if end_y <= start_y:
        return
    var left_points := PackedVector2Array()
    var right_points := PackedVector2Array()
    for y in range(start_y, end_y + 1, 8):
        left_points.append(
            scene_ref.grid_to_world(
                Vector2i(scene_ref.planet_data.get_left_wall_x(y) + scene_ref.PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS, y)
            )
        )
        right_points.append(
            scene_ref.grid_to_world(
                Vector2i(scene_ref.planet_data.get_right_wall_x(y) - scene_ref.PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS, y)
            )
        )
    if left_points.size() < 2 or right_points.size() < 2:
        return
    var fill_points := PackedVector2Array()
    for point in left_points:
        fill_points.append(point)
    for idx in range(right_points.size() - 1, -1, -1):
        fill_points.append(right_points[idx])
    var pulse := 0.55 + 0.45 * sin(_time_elapsed * 3.2)
    draw_colored_polygon(fill_points, Color(0.18, 0.05, 0.02, 0.14 + pulse * 0.05))
    for idx in range(left_points.size() - 1):
        draw_line(left_points[idx], left_points[idx + 1], Color(1.0, 0.2, 0.12, 0.78), 3.0)
        draw_line(right_points[idx], right_points[idx + 1], Color(1.0, 0.2, 0.12, 0.78), 3.0)
    draw_line(left_points[0], right_points[0], Color(1.0, 0.32, 0.16, 0.36), 5.0)
    draw_circle(scene_ref.bottom_cutscene_anchor, 28.0 + pulse * 6.0, Color(1.0, 0.2, 0.14, 0.08))
    draw_arc(scene_ref.bottom_cutscene_anchor, 20.0 + pulse * 4.0, 0.0, TAU, 28, Color(1.0, 0.5, 0.22, 0.92), 2.4)
