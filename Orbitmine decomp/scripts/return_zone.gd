extends Node2D





var zone_radius: float = 150.0
var glow_phase: float = 0.0

func setup(pos: Vector2, radius: float):
    zone_radius = radius
    global_position = pos

func _process(delta):
    glow_phase += delta * 2.0
    queue_redraw()

func _draw():
    var alpha = 0.12 + 0.04 * sin(glow_phase)
    var color = Color(0.2, 0.7, 1.0, alpha)


    draw_arc(Vector2.ZERO, zone_radius, 0, TAU, 48, color, 1.5)


    draw_circle(Vector2.ZERO, zone_radius, Color(0.2, 0.7, 1.0, 0.02))


    var ca = 0.25 + 0.1 * sin(glow_phase * 1.5)
    draw_circle(Vector2.ZERO, 6, Color(0.3, 0.8, 1.0, ca))


    var scene = get_parent()
    if scene and scene.has_method("update_ui") and scene.is_in_return_zone:
        var ratio = clampf(scene.return_zone_timer / scene.RETURN_ZONE_DELAY, 0.0, 1.0)
        if ratio > 0.01:
            var gauge_color = Color(0.3, 0.9, 1.0, 0.6 + ratio * 0.4)
            var start = - PI * 0.5
            var end = start + TAU * ratio
            draw_arc(Vector2.ZERO, zone_radius + 6, start, end, int(48 * ratio) + 4, gauge_color, 4.0)
