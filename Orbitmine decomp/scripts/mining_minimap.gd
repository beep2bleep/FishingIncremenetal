extends Control






var planet_data: PlanetData = null
var player_node: CharacterBody2D = null


const MAP_SIZE: float = 200.0
const MAP_MARGIN: float = 12.0
const MAP_SCALE: float = MAP_SIZE / (PlanetData.PLANET_RADIUS * 2.0)


var map_center: Vector2 = Vector2.ZERO
var cached_image: Image = null
var cached_texture: ImageTexture = null
var _texture_dirty: bool = false
var spawn_world_pos: Vector2 = Vector2.ZERO



const BG_COLOR: = Color(0.02, 0.02, 0.05, 0.85)
const BORDER_COLOR: = Color(0.3, 1.0, 1.2, 0.4)
const PLAYER_COLOR: = Color(0.5, 1.8, 2.0)
const CORE_ALIVE: = Color(2.0, 0.3, 0.08)
const CORE_LOCKED: = Color(0.4, 0.4, 0.45)
const CORE_DEAD: = Color(0.15, 0.8, 1.0, 0.5)
const GOLD_COLOR: = Color(1.0, 0.85, 0.2)
const ELECTRIC_COLOR: = Color(0.3, 0.8, 1.0)
const BLOCK_COLOR: = Color(0.15, 0.2, 0.25)
const RETURN_ZONE_COLOR: = Color(0.3, 1.5, 0.5)

func _ready():

    set_anchors_preset(PRESET_BOTTOM_RIGHT)
    offset_right = - MAP_MARGIN
    offset_bottom = - MAP_MARGIN
    offset_left = - (MAP_MARGIN + MAP_SIZE)
    offset_top = - (MAP_MARGIN + MAP_SIZE)
    custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)
    map_center = Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)

func setup(pd: PlanetData, player: CharacterBody2D):
    planet_data = pd
    player_node = player
    _rebuild_map_image()

    planet_data.minimap_block_erased.connect(_on_block_erased)
    planet_data.minimap_block_spawned.connect(_on_block_spawned)

func _process(_delta):

    if _texture_dirty:
        _texture_dirty = false
        if cached_image and cached_texture:
            cached_texture.update(cached_image)
    queue_redraw()


func _on_block_erased(pos: Vector2i):
    if cached_image == null:
        return
    var px = int(round(float(pos.x) * MAP_SCALE + MAP_SIZE * 0.5))
    var py = int(round(float(pos.y) * MAP_SCALE + MAP_SIZE * 0.5))
    if px < 0 or px >= int(MAP_SIZE) or py < 0 or py >= int(MAP_SIZE):
        return
    cached_image.set_pixel(px, py, Color(0, 0, 0, 0))
    _texture_dirty = true


func _on_block_spawned(pos: Vector2i, type: int):
    if cached_image == null:
        return
    var px = int(round(float(pos.x) * MAP_SCALE + MAP_SIZE * 0.5))
    var py = int(round(float(pos.y) * MAP_SCALE + MAP_SIZE * 0.5))
    if px < 0 or px >= int(MAP_SIZE) or py < 0 or py >= int(MAP_SIZE):
        return
    var col: Color
    match type:
        PlanetData.BlockType.CORE:
            col = CORE_ALIVE
        PlanetData.BlockType.ELECTRIC:
            col = ELECTRIC_COLOR if Global.electric_unlocked else BLOCK_COLOR
        PlanetData.BlockType.GOLD:
            col = GOLD_COLOR if (Global.gold_unlocked or Global.shockwave_unlocked) else BLOCK_COLOR
        _:
            col = BLOCK_COLOR
    cached_image.set_pixel(px, py, col)
    _texture_dirty = true



func _rebuild_map_image():
    if planet_data == null:
        return

    var img_size = int(MAP_SIZE)
    cached_image = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
    cached_image.fill(Color(0, 0, 0, 0))

    var half = MAP_SIZE * 0.5
    var scale = MAP_SCALE
    var blocks = planet_data.blocks


    for px in range(img_size):
        for py in range(img_size):
            var gx = int(round((px - half) / scale))
            var gy = int(round((py - half) / scale))
            var grid_pos = Vector2i(gx, gy)

            var block = blocks.get(grid_pos)
            if block == null:
                continue

            var col: Color
            match block.type:
                PlanetData.BlockType.CORE:
                    col = CORE_ALIVE
                PlanetData.BlockType.ELECTRIC:
                    col = ELECTRIC_COLOR if Global.electric_unlocked else BLOCK_COLOR
                PlanetData.BlockType.GOLD:
                    col = GOLD_COLOR if (Global.gold_unlocked or Global.shockwave_unlocked) else BLOCK_COLOR
                _:
                    col = BLOCK_COLOR

            cached_image.set_pixel(px, py, col)

    cached_texture = ImageTexture.create_from_image(cached_image)

func _draw():
    if planet_data == null:
        return


    draw_circle(map_center, MAP_SIZE * 0.5 + 2, BG_COLOR)


    if cached_texture:
        draw_texture(cached_texture, Vector2.ZERO)


    for core in planet_data.cores:
        var cx = core.center.x * MAP_SCALE + map_center.x
        var cy = core.center.y * MAP_SCALE + map_center.y
        if core.alive:

            var core_col = CORE_LOCKED if planet_data.is_core_locked(core.id) else CORE_ALIVE
            draw_circle(Vector2(cx, cy), 3.0, core_col)
        else:

            draw_arc(Vector2(cx, cy), 3.0, 0, TAU, 12, CORE_DEAD, 1.0)


    if spawn_world_pos != Vector2.ZERO:
        var sgrid = planet_data.world_to_grid(spawn_world_pos)
        var spx = sgrid.x * MAP_SCALE + map_center.x
        var spy = sgrid.y * MAP_SCALE + map_center.y
        var pulse = (sin(Time.get_ticks_msec() * 0.003) + 1.0) * 0.5

        var ring_alpha = 0.3 + pulse * 0.3
        draw_arc(Vector2(spx, spy), 5.0 + pulse * 2.0, 0, TAU, 16, 
            Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, ring_alpha), 1.5)

        draw_circle(Vector2(spx, spy), 2.5, Color(RETURN_ZONE_COLOR.r, RETURN_ZONE_COLOR.g, RETURN_ZONE_COLOR.b, 0.7))


    if player_node:
        var pgrid = planet_data.world_to_grid(player_node.global_position)
        var ppx = pgrid.x * MAP_SCALE + map_center.x
        var ppy = pgrid.y * MAP_SCALE + map_center.y

        draw_circle(Vector2(ppx, ppy), 3.0, PLAYER_COLOR)
        draw_circle(Vector2(ppx, ppy), 5.0, Color(PLAYER_COLOR.r, PLAYER_COLOR.g, PLAYER_COLOR.b, 0.3))


    draw_arc(map_center, MAP_SIZE * 0.5, 0, TAU, 64, BORDER_COLOR, 1.5)
