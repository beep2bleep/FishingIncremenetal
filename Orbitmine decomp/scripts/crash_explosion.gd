extends Node2D





var radius: float = 20.0
var max_radius: float = 100.0
var alpha: float = 1.0
var phase: float = 0.0
const DURATION: float = 0.4

func setup(center: Vector2, target_radius: float = 100.0):
    global_position = center
    max_radius = target_radius
    radius = 20.0
    alpha = 1.0
    phase = 0.0

func _process(delta):
    phase += delta
    var t = phase / DURATION
    if t >= 1.0:
        queue_free()
        return

    radius = lerp(20.0, max_radius, sqrt(t))
    alpha = 1.0 - t * t
    queue_redraw()

func _draw():

    draw_circle(Vector2.ZERO, radius * 1.3, 
        Color(1.0, 0.5, 0.15, alpha * 0.12))

    draw_circle(Vector2.ZERO, radius * 0.6, 
        Color(3.0, 2.0, 0.8, alpha * 0.45))

    draw_circle(Vector2.ZERO, radius * 0.2, 
        Color(4.0, 3.5, 2.5, alpha * 0.7))

    draw_arc(Vector2.ZERO, radius, 0, TAU, 48, 
        Color(2.0, 1.0, 0.3, alpha * 0.35), 2.5)

    draw_arc(Vector2.ZERO, radius * 0.7, 0, TAU, 32, 
        Color(0.5, 1.5, 2.0, alpha * 0.2), 1.5)
