extends Node2D
class_name OpenPitEmpirePlanetEdgeOverlay

var scene_ref: OpenPitEmpireMain
var _force_redraw := true
var _last_cam_origin := Vector2.INF
var _draw_grid_min := Vector2i(2147483647, 2147483647)
var _draw_grid_max := Vector2i(-2147483647, -2147483647)

const DRAW_CACHE_PADDING_CELLS := 4
const HEAVY_VISIBLE_GRID_CELLS := 900
const HEAVY_EFFECT_LOAD := 24
const VERY_HEAVY_VISIBLE_GRID_CELLS := 1400
const VERY_HEAVY_EFFECT_LOAD := 40
const HEAVY_EDGE_WIDTH := 8.0
const ULTRA_EDGE_WIDTH := 8.0
const HEAVY_EDGE_ALPHA := 0.62
const ULTRA_EDGE_ALPHA := 0.5

func mark_dirty() -> void:
    _force_redraw = true

func _process(_delta: float) -> void:
    if scene_ref == null:
        return
    visible = bool(scene_ref.planet_outlines_enabled)
    if not visible:
        return
    var needs_redraw := false
    if _needs_camera_redraw():
        needs_redraw = true
    if _force_redraw:
        needs_redraw = true
    if needs_redraw:
        _force_redraw = false
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    if not bool(scene_ref.planet_outlines_enabled):
        return
    var canvas_transform := get_canvas_transform()
    var viewport_size := get_viewport_rect().size
    var cam_scale := canvas_transform.get_scale()
    var top_left := -canvas_transform.origin / cam_scale
    var bottom_right := top_left + viewport_size / cam_scale
    var margin := scene_ref.BLOCK_SIZE * 2.0
    var visible_grid_min := scene_ref.world_to_grid(top_left - Vector2(margin, margin))
    var visible_grid_max := scene_ref.world_to_grid(bottom_right + Vector2(margin, margin))
    var visible_grid_w: int = visible_grid_max.x - visible_grid_min.x + 1
    var visible_grid_h: int = visible_grid_max.y - visible_grid_min.y + 1
    var visible_cell_budget: int = visible_grid_w * visible_grid_h
    var effect_load: int = scene_ref.hit_timers.size() + scene_ref.electric_arcs.size() + scene_ref.chain_arcs.size() + scene_ref.drone_beams.size()
    var reduce_detail := visible_cell_budget >= HEAVY_VISIBLE_GRID_CELLS or effect_load >= HEAVY_EFFECT_LOAD or scene_ref.mega_timer > 0.0
    var ultra_reduce_detail := visible_cell_budget >= VERY_HEAVY_VISIBLE_GRID_CELLS or effect_load >= VERY_HEAVY_EFFECT_LOAD
    if not reduce_detail and not ultra_reduce_detail:
        _draw_grid_min = visible_grid_min
        _draw_grid_max = visible_grid_max
        _last_cam_origin = canvas_transform.origin
        return
    _draw_grid_min = visible_grid_min
    _draw_grid_max = visible_grid_max
    _last_cam_origin = canvas_transform.origin
    var width := ULTRA_EDGE_WIDTH if ultra_reduce_detail else HEAVY_EDGE_WIDTH
    var alpha_scale := ULTRA_EDGE_ALPHA if ultra_reduce_detail else HEAVY_EDGE_ALPHA
    for x in range(visible_grid_min.x, visible_grid_max.x + 1):
        for y in range(visible_grid_min.y, visible_grid_max.y + 1):
            var grid := Vector2i(x, y)
            if not scene_ref.exposed_edges.has(grid):
                continue
            var block: Dictionary = scene_ref.blocks.get(grid, {})
            if block.is_empty():
                continue
            var world := scene_ref.grid_to_world(grid)
            var rect := Rect2(
                world - Vector2.ONE * scene_ref.BLOCK_SIZE * 0.5 + Vector2.ONE * 1.5,
                Vector2.ONE * (scene_ref.BLOCK_SIZE - 3.0)
            )
            var edge_color: Color = _get_lightened_edge_color(block, alpha_scale)
            _draw_block_edges(rect, edge_color, int(scene_ref.exposed_edges.get(grid, 0)), width)

func _needs_camera_redraw() -> bool:
    if scene_ref == null:
        return false
    if not bool(scene_ref.planet_outlines_enabled):
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

func _get_lightened_edge_color(block: Dictionary, alpha_scale: float) -> Color:
    var zone: int = int(block.get("zone", 2))
    var edge_color: Color = Color.WHITE
    match int(block.get("type", 0)):
        scene_ref.BlockType.CORE:
            edge_color = scene_ref.planet_renderer.ZONE_EDGE_COLORS.get(zone, Color.WHITE)
        scene_ref.BlockType.ELECTRIC:
            edge_color = Color(0.5, 1.8, 2.5, 1.0)
        scene_ref.BlockType.GOLD:
            edge_color = Color(2.0, 1.6, 0.3, 1.0)
        scene_ref.BlockType.THORN:
            edge_color = scene_ref.planet_renderer.THORN_EDGE
        _:
            if bool(block.get("regenerated", false)):
                edge_color = scene_ref.planet_renderer.REGEN_EDGE
            else:
                edge_color = scene_ref.planet_renderer.ZONE_EDGE_COLORS.get(zone, Color.WHITE)
    var lightened_edge := edge_color.lerp(Color.WHITE, 0.22)
    return Color(lightened_edge.r, lightened_edge.g, lightened_edge.b, alpha_scale)

func _draw_block_edges(rect: Rect2, color: Color, mask: int, width: float) -> void:
    if (mask & 1) != 0:
        draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), color, width)
    if (mask & 2) != 0:
        draw_line(rect.position + Vector2(0.0, rect.size.y), rect.position + rect.size, color, width)
    if (mask & 4) != 0:
        draw_line(rect.position, rect.position + Vector2(0.0, rect.size.y), color, width)
    if (mask & 8) != 0:
        draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + rect.size, color, width)
