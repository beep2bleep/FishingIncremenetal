extends Control
class_name OpenPitOrbitMiniMap

const PLANET_RADIUS := 280
const BLOCK_TYPE_NORMAL := 0
const BLOCK_TYPE_CORE := 1
const BLOCK_TYPE_ELECTRIC := 2
const BLOCK_TYPE_GOLD := 3

var planet_data = null
var scene_ref: OpenPitOrbitMain = null
var cached_image: Image = null
var cached_texture: ImageTexture = null
var _texture_dirty := false
var _redraw_timer := 0.0

const MAP_SIZE := 200.0
const MAP_MARGIN := 12.0
const REDRAW_INTERVAL := 1.0
const BG_COLOR := Color(0.02, 0.02, 0.05, 0.85)
const BORDER_COLOR := Color(0.3, 1.0, 1.2, 0.4)
const PLAYER_COLOR := Color(0.5, 1.8, 2.0)
const CORE_ALIVE := Color(2.0, 0.3, 0.08)
const CORE_LOCKED := Color(0.4, 0.4, 0.45)
const CORE_DEAD := Color(0.15, 0.8, 1.0, 0.5)
const GOLD_COLOR := Color(1.0, 0.85, 0.2)
const ELECTRIC_COLOR := Color(0.3, 0.8, 1.0)
const BLOCK_COLOR := Color(0.15, 0.2, 0.25)
const RETURN_ZONE_COLOR := Color(0.3, 1.5, 0.5)

func _ready() -> void:
    set_anchors_preset(PRESET_BOTTOM_RIGHT)
    offset_right = -MAP_MARGIN
    offset_bottom = -MAP_MARGIN
    offset_left = -(MAP_MARGIN + MAP_SIZE)
    offset_top = -(MAP_MARGIN + MAP_SIZE)
    custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)

func setup(pd, orbit_scene: OpenPitOrbitMain) -> void:
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
    if _redraw_timer <= 0.0:
        _redraw_timer = REDRAW_INTERVAL
        queue_redraw()

func _on_block_erased(pos: Vector2i) -> void:
    if cached_image == null:
        return
    var px := int(round(float(pos.x) * _map_scale() + MAP_SIZE * 0.5))
    var py := int(round(float(pos.y) * _map_scale() + MAP_SIZE * 0.5))
    if px < 0 or px >= int(MAP_SIZE) or py < 0 or py >= int(MAP_SIZE):
        return
    cached_image.set_pixel(px, py, Color(0, 0, 0, 0))
    _texture_dirty = true

func _on_block_spawned(pos: Vector2i, block_type: int) -> void:
    if cached_image == null:
        return
    var px := int(round(float(pos.x) * _map_scale() + MAP_SIZE * 0.5))
    var py := int(round(float(pos.y) * _map_scale() + MAP_SIZE * 0.5))
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
            var grid := Vector2i(gx, gy)
            var block: Variant = planet_data.blocks.get(grid, null)
            if block == null:
                continue
            cached_image.set_pixel(px, py, _color_for_type(int(block.get("type", BLOCK_TYPE_NORMAL))))
    cached_texture = ImageTexture.create_from_image(cached_image)

func _draw() -> void:
    if planet_data == null or scene_ref == null:
        return
    var map_center := Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)
    draw_circle(map_center, MAP_SIZE * 0.5 + 2.0, BG_COLOR)
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
    var spawn_grid: Vector2i = planet_data.world_to_grid(scene_ref.spawn_position)
    var spawn_pos := Vector2(float(spawn_grid.x) * _map_scale() + map_center.x, float(spawn_grid.y) * _map_scale() + map_center.y)
    draw_arc(spawn_pos, 5.0, 0.0, TAU, 16, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.6), 1.5)
    draw_circle(spawn_pos, 2.5, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.7))
    var ship_grid: Vector2i = planet_data.world_to_grid(scene_ref.ship_pos)
    var ship_pos := Vector2(float(ship_grid.x) * _map_scale() + map_center.x, float(ship_grid.y) * _map_scale() + map_center.y)
    draw_circle(ship_pos, 3.0, PLAYER_COLOR)
    draw_circle(ship_pos, 5.0, Color(PLAYER_COLOR.r, PLAYER_COLOR.g, PLAYER_COLOR.b, 0.3))
    draw_arc(map_center, MAP_SIZE * 0.5, 0.0, TAU, 64, BORDER_COLOR, 1.5)

func _map_scale() -> float:
    return MAP_SIZE / float(PLANET_RADIUS * 2)

func _color_for_type(block_type: int) -> Color:
    match block_type:
        BLOCK_TYPE_CORE:
            return CORE_ALIVE
        BLOCK_TYPE_ELECTRIC:
            return ELECTRIC_COLOR if scene_ref != null and bool(scene_ref.runtime_stats.get("electric_enabled", false)) else BLOCK_COLOR
        BLOCK_TYPE_GOLD:
            return GOLD_COLOR if scene_ref != null and (bool(scene_ref.runtime_stats.get("gold_enabled", false)) or bool(scene_ref.runtime_stats.get("shockwave_enabled", false))) else BLOCK_COLOR
        _:
            return BLOCK_COLOR
