extends Node2D







var orbit_dist: float = 0.0
var orbit_angle: float = 0.0
var orbit_speed: float = 0.0
var orbit_center: Vector2 = Vector2.ZERO


var hp: float = 20.0
var max_hp: float = 20.0
var radius: float = 40.0
var resource_amount: float = 5.0


var is_alive: bool = true
var respawn_timer: float = 0.0
const RESPAWN_TIME: float = 20.0


const BS: = 12
var block_grid: Dictionary = {}
var exposed: Dictionary = {}


const FILL_BASE: = Color(0.025, 0.025, 0.035)
const EDGE_COLOR: = Color(0.4, 1.5, 2.0)
const EDGE_HIT: = Color(2.0, 1.5, 0.3)


var hit_flash: float = 0.0
var glow_phase: float = 0.0

func _ready():
    add_to_group("asteroids")

func setup(center: Vector2, dist: float, angle: float, speed: float, size: float, hp_val: float, res_val: float):
    orbit_center = center
    orbit_dist = dist
    orbit_angle = angle
    orbit_speed = speed
    radius = size
    hp = hp_val
    max_hp = hp_val
    resource_amount = res_val
    _update_position()
    _generate_blocks()

func _generate_blocks():
    block_grid.clear()
    exposed.clear()
    var grid_r = int(radius / BS) + 1


    for x in range( - grid_r, grid_r + 1):
        for y in range( - grid_r, grid_r + 1):
            var world_pos = Vector2(x, y) * BS

            var dist = world_pos.length()
            var noise = radius * randf_range(0.8, 1.15)
            if dist <= noise:
                var pos = Vector2i(x, y)

                var depth = dist / radius
                var brightness = lerpf(0.04, 0.02, depth) + randf_range(-0.005, 0.005)
                block_grid[pos] = {
                    "fill": Color(brightness * 0.7, brightness, brightness * 1.2)
                }


    _rebuild_exposed()

func _rebuild_exposed():
    exposed.clear()
    for pos in block_grid:
        var mask = 0
        if not block_grid.has(pos + Vector2i(0, -1)): mask |= 1
        if not block_grid.has(pos + Vector2i(0, 1)): mask |= 2
        if not block_grid.has(pos + Vector2i(-1, 0)): mask |= 4
        if not block_grid.has(pos + Vector2i(1, 0)): mask |= 8
        if mask > 0:
            exposed[pos] = mask

func _process(delta):
    if is_alive:
        orbit_angle += orbit_speed * delta
        _update_position()
        hit_flash = maxf(0.0, hit_flash - delta * 5.0)
        glow_phase += delta * 2.0
    else:
        respawn_timer -= delta
        if respawn_timer <= 0:
            _respawn()
    queue_redraw()

func _update_position():
    global_position = orbit_center + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_dist

func take_damage(dmg: float):
    if not is_alive:
        return
    hp -= dmg
    hit_flash = 1.0

    if block_grid.size() > 3 and randf() < 0.5:

        var edge_blocks = exposed.keys()
        if edge_blocks.size() > 0:
            var remove_pos = edge_blocks[randi() % edge_blocks.size()]
            block_grid.erase(remove_pos)
            _rebuild_exposed()
    if hp <= 0:
        _destroy()

func _destroy():
    is_alive = false
    hp = 0
    visible = false
    respawn_timer = RESPAWN_TIME
    Global.gain_mining_resource(resource_amount)
    Global.record_block_destroyed(false)

func _respawn():
    is_alive = true
    hp = max_hp
    visible = true
    _generate_blocks()

func _draw():
    if not is_alive:
        return

    var half = BS * 0.5


    for pos in block_grid:
        var px = pos.x * BS
        var py = pos.y * BS
        var c = block_grid[pos].fill
        if hit_flash > 0:
            c = c.lerp(Color.WHITE, hit_flash * 0.3)
        draw_rect(Rect2(px - half, py - half, BS, BS), c)


    var edge_alpha = 0.7 + 0.2 * sin(glow_phase)
    var edge_col = EDGE_COLOR
    if hit_flash > 0:
        edge_col = EDGE_COLOR.lerp(EDGE_HIT, hit_flash)

    var draw_col = Color(edge_col.r, edge_col.g, edge_col.b, edge_alpha)

    for pos in exposed:
        var mask = exposed[pos]
        var x0 = pos.x * BS - half
        var y0 = pos.y * BS - half
        var x1 = x0 + BS
        var y1 = y0 + BS

        if mask & 1: draw_line(Vector2(x0, y0), Vector2(x1, y0), draw_col, 2.0)
        if mask & 2: draw_line(Vector2(x0, y1), Vector2(x1, y1), draw_col, 2.0)
        if mask & 4: draw_line(Vector2(x0, y0), Vector2(x0, y1), draw_col, 2.0)
        if mask & 8: draw_line(Vector2(x1, y0), Vector2(x1, y1), draw_col, 2.0)


    if hp < max_hp:
        var bar_w = radius * 1.5
        var bar_h = 3.0
        var bar_x = - bar_w * 0.5
        var bar_y = - radius - 14
        draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.05, 0.05, 0.08, 0.7))
        var fill_w = bar_w * (hp / max_hp)
        draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), Color(0.2, 0.85, 0.4, 0.9))
