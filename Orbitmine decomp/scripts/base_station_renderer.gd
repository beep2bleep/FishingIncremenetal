extends Node2D





const RADIUS: = 90.0
const ATMOSPHERE_WIDTH: = 20.0
var glow_phase: float = 0.0


var craters: Array = []
var surface_dots: Array = []

func _ready():

    for i in range(8):
        var angle = randf() * TAU
        var dist = randf_range(20, RADIUS * 0.75)
        var size = randf_range(6, 18)
        craters.append({"pos": Vector2(cos(angle), sin(angle)) * dist, "size": size})


    for i in range(30):
        var angle = randf() * TAU
        var dist = randf_range(10, RADIUS * 0.85)
        surface_dots.append({"pos": Vector2(cos(angle), sin(angle)) * dist, "size": randf_range(2, 5)})

func _process(delta):
    glow_phase += delta * 1.5
    queue_redraw()

func _draw():

    for i in range(4):
        var r = RADIUS + ATMOSPHERE_WIDTH * (1.0 + i * 0.4)
        var alpha = 0.04 - i * 0.008
        alpha += 0.01 * sin(glow_phase + i)
        draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color(0.3, 0.6, 1.0, alpha), ATMOSPHERE_WIDTH * 0.5)



    draw_circle(Vector2.ZERO, RADIUS, Color(0.12, 0.18, 0.28))

    draw_circle(Vector2(-15, -15), RADIUS * 0.85, Color(0.15, 0.22, 0.35, 0.5))
    draw_circle(Vector2(-25, -25), RADIUS * 0.6, Color(0.18, 0.25, 0.38, 0.3))


    for dot in surface_dots:
        if dot.pos.length() < RADIUS - 3:
            draw_circle(dot.pos, dot.size, Color(0.1, 0.15, 0.25, 0.4))


    for crater in craters:
        if crater.pos.length() + crater.size < RADIUS:

            draw_circle(crater.pos, crater.size, Color(0.08, 0.1, 0.18, 0.6))

            draw_arc(crater.pos, crater.size, 0, TAU, 16, Color(0.2, 0.3, 0.45, 0.3), 1.0)


    draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 64, Color(0.3, 0.5, 0.8, 0.4), 1.5)


    var dock_y = - RADIUS - 8
    var dock_alpha = 0.5 + 0.3 * sin(glow_phase * 2.0)
    draw_circle(Vector2(0, dock_y), 5.0, Color(0.2, 0.9, 0.6, dock_alpha))
    draw_circle(Vector2(0, dock_y), 8.0, Color(0.2, 0.9, 0.6, dock_alpha * 0.3))


    var base_y = - RADIUS + 5

    draw_circle(Vector2(0, base_y), 10, Color(0.25, 0.35, 0.5, 0.7))
    draw_arc(Vector2(0, base_y), 10, PI, TAU, 12, Color(0.4, 0.6, 0.9, 0.5), 1.5)

    draw_circle(Vector2(-18, base_y + 4), 5, Color(0.2, 0.3, 0.45, 0.6))
    draw_circle(Vector2(18, base_y + 4), 5, Color(0.2, 0.3, 0.45, 0.6))

    draw_line(Vector2(0, base_y - 10), Vector2(0, base_y - 22), Color(0.5, 0.7, 1.0, 0.4), 1.0)
    var beacon_alpha = 0.4 + 0.3 * sin(glow_phase * 3.0)
    draw_circle(Vector2(0, base_y - 22), 2.5, Color(0.3, 1.0, 0.7, beacon_alpha))
