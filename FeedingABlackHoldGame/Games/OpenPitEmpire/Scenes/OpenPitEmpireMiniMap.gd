extends Control
class_name OpenPitEmpireMiniMap

const BLOCK_TYPE_NORMAL := 0
const BLOCK_TYPE_CORE := 1
const BLOCK_TYPE_ELECTRIC := 2
const BLOCK_TYPE_GOLD := 3

var planet_data = null
var scene_ref: OpenPitEmpireMain = null
var cached_image: Image = null
var cached_texture: ImageTexture = null
var _texture_dirty := false
var _redraw_timer := 0.0

const MAP_SIZE := 200.0
const MAP_MARGIN := 12.0
const REDRAW_INTERVAL := 1.0
const PLAYER_COLOR := Color(0.5, 1.8, 2.0)
const MINING_DRONE_COLOR := Color(0.45, 2.0, 1.1)
const CORE_ALIVE := Color(2.0, 0.3, 0.08)
const CORE_LOCKED := Color(0.4, 0.4, 0.45)
const CORE_DEAD := Color(0.15, 0.8, 1.0, 0.5)
const GOLD_COLOR := Color(1.0, 0.55, 0.18)
const ELECTRIC_COLOR := Color(0.25, 1.0, 0.45)
const BLOCK_COLOR := Color(0.15, 0.2, 0.25)
const RETURN_ZONE_COLOR := Color(0.3, 1.5, 0.5)

func _ready() -> void:
    set_anchors_preset(PRESET_BOTTOM_RIGHT)
    offset_right = -MAP_MARGIN
    offset_bottom = -MAP_MARGIN
    offset_left = -(MAP_MARGIN + MAP_SIZE)
    offset_top = -(MAP_MARGIN + MAP_SIZE)
    custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)

func setup(pd, orbit_scene: OpenPitEmpireMain) -> void:
    planet_data = pd
    scene_ref = orbit_scene
    _rebuild_map_image()
    if planet_data != null:
        if not planet_data.minimap_block_erased.is_connected(_on_block_erased):
            planet_data.minimap_block_erased.connect(_on_block_erased)
        if not planet_data.minimap_block_spawned.is_connected(_on_block_spawned):
            planet_data.minimap_block_spawned.connect(_on_block_spawned)

func _process(_delta: float) -> void:
    _redraw_timer -= _delta
    if _texture_dirty and cached_image != null and cached_texture != null:
        _texture_dirty = false
        cached_texture.update(cached_image)
    if scene_ref != null and (scene_ref.return_zone_timer > 0.0 or scene_ref.extracting):
        _redraw_timer = REDRAW_INTERVAL
        queue_redraw()
    elif _redraw_timer <= 0.0:
        _redraw_timer = REDRAW_INTERVAL
        queue_redraw()

func _on_block_erased(pos: Vector2i) -> void:
    if cached_image == null:
        return
    var map_pos := _grid_to_map(pos)
    var px := int(round(map_pos.x))
    var py := int(round(map_pos.y))
    if px < 0 or px >= int(MAP_SIZE) or py < 0 or py >= int(MAP_SIZE):
        return
    cached_image.set_pixel(px, py, Color(0, 0, 0, 0))
    _texture_dirty = true

func _on_block_spawned(pos: Vector2i, block_type: int) -> void:
    if cached_image == null:
        return
    var map_pos := _grid_to_map(pos)
    var px := int(round(map_pos.x))
    var py := int(round(map_pos.y))
    if px < 0 or px >= int(MAP_SIZE) or py < 0 or py >= int(MAP_SIZE):
        return
    cached_image.set_pixel(px, py, _color_for_type(block_type))
    _texture_dirty = true

func _rebuild_map_image() -> void:
    if planet_data == null:
        return
    var img_size := int(MAP_SIZE)
    cached_image = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
    cached_image.fill(Color(0, 0, 0, 0))
    for px in range(img_size):
        for py in range(img_size):
            var gx := int(round((float(px) - MAP_SIZE * 0.5) / _map_scale()))
            var gy := int(round((float(py) - MAP_SIZE * 0.5) / _map_scale()))
            var bounds: Rect2 = planet_data.get_map_bounds()
            var grid := Vector2i(
                int(round(float(bounds.position.x) + bounds.size.x * 0.5 + gx)),
                int(round(float(bounds.position.y) + bounds.size.y * 0.5 + gy))
            )
            var block: Variant = planet_data.blocks.get(grid, null)
            if block == null:
                continue
            cached_image.set_pixel(px, py, _color_for_type(int(block.get("type", BLOCK_TYPE_NORMAL))))
    cached_texture = ImageTexture.create_from_image(cached_image)

func _draw() -> void:
    if planet_data == null or scene_ref == null:
        return
    var map_center := Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)
    if cached_texture != null:
        draw_texture(cached_texture, Vector2.ZERO)
    for core in planet_data.cores:
        var cx := float(core.center.x) * _map_scale() + map_center.x
        var cy := float(core.center.y) * _map_scale() + map_center.y
        if bool(core.alive):
            var core_col := CORE_LOCKED if planet_data.is_core_locked(int(core.id), scene_ref._core_unlocks_center()) else CORE_ALIVE
            draw_circle(Vector2(cx, cy), 3.0, core_col)
        else:
            draw_arc(Vector2(cx, cy), 3.0, 0.0, TAU, 12, CORE_DEAD, 1.0)
    var spawn_pos := _world_to_map(scene_ref.spawn_position)
    var extraction_zone_radius := maxf(5.0, scene_ref.return_zone_radius / scene_ref.BLOCK_SIZE * _map_scale())
    var extraction_ring_radius := extraction_zone_radius + 4.0
    var extraction_progress := scene_ref.get_return_zone_progress()
    draw_circle(spawn_pos, extraction_zone_radius, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.18))
    draw_arc(spawn_pos, extraction_zone_radius, 0.0, TAU, 28, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.8), 2.0)
    draw_arc(spawn_pos, extraction_ring_radius, -PI * 0.5, TAU - PI * 0.5, 28, Color(0.2, 0.5, 0.24, 0.45), 3.0)
    if extraction_progress > 0.0:
        draw_arc(
            spawn_pos,
            extraction_ring_radius,
            -PI * 0.5,
            -PI * 0.5 + TAU * extraction_progress,
            28,
            Color(0.7, 2.2, 1.0, 1.0),
            4.0
        )
    draw_circle(spawn_pos, 2.5, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.8))
    for drone_variant in scene_ref.mining_drone_states:
        var drone: Dictionary = drone_variant
        var drone_pos := _world_to_map(Vector2(drone.get("position", scene_ref.spawn_position)))
        var cargo_capacity := maxf(float(scene_ref._get_mining_drone_cargo_capacity()), 1.0)
        var cargo_ratio := clampf(float(drone.get("cargo_units", 0)) / cargo_capacity, 0.0, 1.0)
        draw_circle(drone_pos, 2.4, MINING_DRONE_COLOR)
        draw_arc(drone_pos, 4.2, -PI * 0.5, -PI * 0.5 + TAU * cargo_ratio, 12, Color(MINING_DRONE_COLOR.r, MINING_DRONE_COLOR.g, MINING_DRONE_COLOR.b, 0.9), 1.4)
    var ship_pos := _world_to_map(scene_ref.ship_pos)
    draw_circle(ship_pos, 3.0, PLAYER_COLOR)
    draw_circle(ship_pos, 5.0, Color(PLAYER_COLOR.r, PLAYER_COLOR.g, PLAYER_COLOR.b, 0.3))

func _map_scale() -> float:
    if planet_data == null:
        return 1.0
    var bounds: Rect2 = planet_data.get_map_bounds()
    var max_dim := maxf(bounds.size.x, bounds.size.y)
    return (MAP_SIZE - 4.0) / maxf(max_dim, 1.0)

func _world_to_map(world_pos: Vector2) -> Vector2:
    var map_center := Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)
    var grid_pos := world_pos / maxf(scene_ref.BLOCK_SIZE, 0.001)
    var bounds: Rect2 = planet_data.get_map_bounds() if planet_data != null else Rect2(-100.0, -100.0, 200.0, 200.0)
    var centered := Vector2(grid_pos.x - bounds.position.x - bounds.size.x * 0.5, grid_pos.y - bounds.position.y - bounds.size.y * 0.5)
    return centered * _map_scale() + map_center

func _color_for_type(block_type: int) -> Color:
    match block_type:
        BLOCK_TYPE_CORE:
            return CORE_ALIVE
        BLOCK_TYPE_ELECTRIC:
            return ELECTRIC_COLOR if scene_ref != null and bool(scene_ref.runtime_stats.get("electric_enabled", false)) else BLOCK_COLOR
        BLOCK_TYPE_GOLD:
            return GOLD_COLOR
        _:
            return BLOCK_COLOR

func _grid_to_map(pos: Vector2i) -> Vector2:
    var map_center := Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)
    var bounds: Rect2 = planet_data.get_map_bounds() if planet_data != null else Rect2(-100.0, -100.0, 200.0, 200.0)
    var centered := Vector2(float(pos.x) - bounds.position.x - bounds.size.x * 0.5, float(pos.y) - bounds.position.y - bounds.size.y * 0.5)
    return centered * _map_scale() + map_center
