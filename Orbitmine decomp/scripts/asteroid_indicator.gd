extends Control





var player: Node2D = null
var asteroids: Array = []
var glow_phase: float = 0.0
const MARGIN: = 40.0
const ARROW_SIZE: = 12.0
const INDICATOR_COLOR: = Color(0.4, 0.8, 1.0, 0.7)
const INDICATOR_CLOSE: = Color(0.3, 1.0, 0.5, 0.8)

func setup(p: Node2D, asts: Array):
    player = p
    asteroids = asts

func _process(delta):
    glow_phase += delta * 3.0
    queue_redraw()

func _draw():
    if not player or asteroids.size() == 0:
        return

    var viewport_size = get_viewport_rect().size
    var cam = get_viewport().get_camera_2d()
    if not cam:
        return

    for ast in asteroids:
        if not is_instance_valid(ast) or not ast.is_alive:
            continue


        var world_pos = ast.global_position
        var screen_pos = (world_pos - cam.global_position) * cam.zoom + viewport_size * 0.5


        var inside = screen_pos.x > MARGIN and screen_pos.x < viewport_size.x - MARGIN\
and screen_pos.y > MARGIN and screen_pos.y < viewport_size.y - MARGIN

        if inside:

            var pulse = 0.3 + 0.15 * sin(glow_phase)
            _draw_diamond(screen_pos, 4.0, Color(0.4, 0.8, 1.0, pulse))
            continue


        var center = viewport_size * 0.5
        var dir = (screen_pos - center).normalized()


        var edge_pos = _clamp_to_screen_edge(center, dir, viewport_size)


        var dist = player.global_position.distance_to(world_pos)
        var close_ratio = clampf(1.0 - dist / 2000.0, 0.0, 1.0)
        var color = INDICATOR_COLOR.lerp(INDICATOR_CLOSE, close_ratio)


        var alpha = 0.5 + 0.3 * sin(glow_phase + ast.orbit_angle)
        color.a = alpha


        _draw_arrow(edge_pos, dir, color)


        var dot_count = clampi(int(dist / 500.0), 1, 4)
        for i in range(dot_count):
            var dot_pos = edge_pos - dir * (20 + i * 8)
            draw_circle(dot_pos, 2.0, Color(color.r, color.g, color.b, alpha * 0.5))

func _draw_arrow(pos: Vector2, dir: Vector2, color: Color):

    var perp = Vector2( - dir.y, dir.x)
    var tip = pos
    var left = tip - dir * ARROW_SIZE + perp * ARROW_SIZE * 0.5
    var right = tip - dir * ARROW_SIZE - perp * ARROW_SIZE * 0.5
    draw_colored_polygon(PackedVector2Array([tip, left, right]), color)

    draw_polyline(PackedVector2Array([tip, left, right, tip]), Color(color.r, color.g, color.b, color.a * 0.5), 1.0)

func _draw_diamond(pos: Vector2, size: float, color: Color):
    var points = PackedVector2Array([
        pos + Vector2(0, - size), 
        pos + Vector2(size, 0), 
        pos + Vector2(0, size), 
        pos + Vector2( - size, 0), 
    ])
    draw_colored_polygon(points, color)

func _clamp_to_screen_edge(center: Vector2, dir: Vector2, size: Vector2) -> Vector2:
    var margin = MARGIN

    var t_min = 999999.0


    if dir.y < -0.001:
        var t = (margin - center.y) / dir.y
        if t > 0: t_min = minf(t_min, t)

    if dir.y > 0.001:
        var t = (size.y - margin - center.y) / dir.y
        if t > 0: t_min = minf(t_min, t)

    if dir.x < -0.001:
        var t = (margin - center.x) / dir.x
        if t > 0: t_min = minf(t_min, t)

    if dir.x > 0.001:
        var t = (size.x - margin - center.x) / dir.x
        if t > 0: t_min = minf(t_min, t)

    return center + dir * t_min
