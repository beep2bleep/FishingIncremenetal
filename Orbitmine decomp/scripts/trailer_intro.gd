extends Node2D








const HOLD_TIME: = 1.5
const ZOOM_DURATION: = 3.5


const ZOOM_START: = 3.0
const ZOOM_END: = 0.06


const RENDER_SCALE: = 2


const ZONE_COLORS = {
    0: Color(0.4, 1.5, 2.0), 
    1: Color(1.4, 1.3, 0.5), 
    2: Color(1.7, 1.0, 0.3), 
    3: Color(0.4, 0.8, 2.0), 
    4: Color(2.0, 0.15, 0.05), 
}
const CORE_EDGE_C: = Color(2.5, 0.3, 0.08)
const CORE_FILL_C: = Color(0.8, 0.08, 0.04)
const BLOCK_FILL_C: = Color(0.02, 0.02, 0.035)
const EMPTY_C: = Color(0.008, 0.008, 0.02)

var camera: Camera2D
var planet_sprite: Sprite2D
var ship_visual: Node2D
var spawn_pos: Vector2
var gt: float = 0.0

func _ready():
    RenderingServer.set_default_clear_color(Color(0.01, 0.01, 0.03))

    if not Global.planet_data:
        Global.initialize_planet()


    var planet_tex = _prerender_planet()
    planet_sprite = Sprite2D.new()
    planet_sprite.texture = planet_tex
    planet_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var world_scale = float(PlanetData.BLOCK_SIZE) / float(RENDER_SCALE)
    planet_sprite.scale = Vector2(world_scale, world_scale)
    planet_sprite.global_position = Vector2.ZERO
    add_child(planet_sprite)


    var spawn_dist = (PlanetData.PLANET_RADIUS + 8) * PlanetData.BLOCK_SIZE
    spawn_pos = Vector2(0, - spawn_dist)

    ship_visual = Node2D.new()
    ship_visual.set_script(load("res://scripts/trailer_ship_visual.gd"))
    ship_visual.global_position = spawn_pos
    add_child(ship_visual)


    camera = Camera2D.new()
    camera.global_position = spawn_pos
    camera.zoom = Vector2(ZOOM_START, ZOOM_START)
    camera.position_smoothing_enabled = false
    camera.make_current()
    add_child(camera)


    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.01, 0.01, 0.03)
    env.glow_enabled = true
    env.set("glow_levels/1", 1.0)
    env.set("glow_levels/2", 0.6)
    env.set("glow_levels/3", 0.3)
    env.glow_strength = 1.2
    env.glow_bloom = 0.3
    env.glow_hdr_threshold = 0.8
    var we = WorldEnvironment.new()
    we.environment = env
    add_child(we)

func _process(delta):
    gt += delta

    var zoom_t = 0.0
    if gt > HOLD_TIME:
        zoom_t = clampf((gt - HOLD_TIME) / ZOOM_DURATION, 0.0, 1.0)
    var eased = 1.0 - pow(1.0 - zoom_t, 3.0)


    var current_zoom = exp(lerpf(log(ZOOM_START), log(ZOOM_END), eased))
    camera.zoom = Vector2(current_zoom, current_zoom)


    camera.global_position = spawn_pos

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")




func _prerender_planet() -> ImageTexture:
    var pd = Global.planet_data
    var radius = PlanetData.PLANET_RADIUS
    var img_size = radius * 2 * RENDER_SCALE + RENDER_SCALE
    var img = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))

    var center = img_size / 2
    var radius_sq = radius * radius


    for x in range(img_size):
        for y in range(img_size):
            var dx = (x - center) / RENDER_SCALE
            var dy = (y - center) / RENDER_SCALE
            if dx * dx + dy * dy <= radius_sq:
                img.set_pixel(x, y, EMPTY_C)


    for pos in pd.blocks:
        var bx = pos.x
        var by = pos.y
        if bx * bx + by * by > radius_sq:
            continue

        var block = pd.blocks[pos]
        var zone = PlanetData.get_zone(pos)
        var zone_c = ZONE_COLORS.get(zone, Color(0.5, 0.5, 0.5))
        var dist = sqrt(float(bx * bx + by * by))
        var depth = dist / float(radius)


        var base = BLOCK_FILL_C
        var zone_hint = 0.05 + depth * 0.08
        var color = base.lerp(Color(zone_c.r * 0.15, zone_c.g * 0.15, zone_c.b * 0.15, 1.0), zone_hint)


        if block.type == PlanetData.BlockType.CORE:
            color = CORE_FILL_C

        var px = center + bx * RENDER_SCALE
        var py = center + by * RENDER_SCALE
        for dx in range(RENDER_SCALE):
            for dy in range(RENDER_SCALE):
                var fx = px + dx
                var fy = py + dy
                if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                    img.set_pixel(fx, fy, color)


    for pos in pd.blocks:
        var bx = pos.x
        var by = pos.y
        if bx * bx + by * by > radius_sq:
            continue


        var dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
        var exposed_dirs: Array = []
        for dir in dirs:
            var neighbor = pos + dir
            var n_dist_sq = neighbor.x * neighbor.x + neighbor.y * neighbor.y
            if not pd.blocks.has(neighbor) or n_dist_sq > radius_sq:
                exposed_dirs.append(dir)

        if exposed_dirs.is_empty():
            continue


        var block = pd.blocks[pos]
        var zone_c: Color
        if block.type == PlanetData.BlockType.CORE:
            zone_c = CORE_EDGE_C
        else:
            var zone = PlanetData.get_zone(pos)
            zone_c = ZONE_COLORS.get(zone, Color(0.5, 0.5, 0.5))


        var dist = sqrt(float(bx * bx + by * by))
        var depth = dist / float(radius)
        var brightness = clampf(depth * 1.2, 0.3, 1.0)

        var edge_c = Color(
            zone_c.r * brightness, 
            zone_c.g * brightness, 
            zone_c.b * brightness
        )

        var px = center + bx * RENDER_SCALE
        var py = center + by * RENDER_SCALE


        for dir in exposed_dirs:
            if RENDER_SCALE >= 2:
                if dir == Vector2i(1, 0):
                    for dy in range(RENDER_SCALE):
                        var fx = px + RENDER_SCALE - 1
                        var fy = py + dy
                        if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                            img.set_pixel(fx, fy, edge_c)
                elif dir == Vector2i(-1, 0):
                    for dy in range(RENDER_SCALE):
                        var fx = px
                        var fy = py + dy
                        if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                            img.set_pixel(fx, fy, edge_c)
                elif dir == Vector2i(0, 1):
                    for dx in range(RENDER_SCALE):
                        var fx = px + dx
                        var fy = py + RENDER_SCALE - 1
                        if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                            img.set_pixel(fx, fy, edge_c)
                elif dir == Vector2i(0, -1):
                    for dx in range(RENDER_SCALE):
                        var fx = px + dx
                        var fy = py
                        if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                            img.set_pixel(fx, fy, edge_c)


    for core in pd.cores:
        if not core.alive:
            continue
        var ccx = core.center.x
        var ccy = core.center.y
        var glow_r = core.size * 3
        for gx in range( - glow_r, glow_r + 1):
            for gy in range( - glow_r, glow_r + 1):
                var wx = ccx + gx
                var wy = ccy + gy
                var d = sqrt(float(gx * gx + gy * gy))
                if d > glow_r or d < core.size * 0.5:
                    continue
                var glow_a = (1.0 - d / float(glow_r)) * 0.25
                var fpx = center + wx * RENDER_SCALE
                var fpy = center + wy * RENDER_SCALE
                for dx in range(RENDER_SCALE):
                    for dy in range(RENDER_SCALE):
                        var fx = fpx + dx
                        var fy = fpy + dy
                        if fx >= 0 and fx < img_size and fy >= 0 and fy < img_size:
                            var existing = img.get_pixel(fx, fy)
                            var glow_c = Color(CORE_EDGE_C.r * glow_a, CORE_EDGE_C.g * glow_a, CORE_EDGE_C.b * glow_a, 0.0)
                            img.set_pixel(fx, fy, Color(
                                existing.r + glow_c.r, 
                                existing.g + glow_c.g, 
                                existing.b + glow_c.b, 
                                existing.a
                            ))

    return ImageTexture.create_from_image(img)
