extends Node2D






const SHIP_LINE: = Color(0.5, 1.8, 2.0)
const SHIP_FILL: = Color(0.02, 0.04, 0.06)
const ENGINE_C: = Color(0.5, 1.8, 2.0, 0.9)

var gt: float = 0.0

func _process(delta):
    gt += delta
    queue_redraw()

func _draw():

    var pts = PackedVector2Array([
        Vector2(0, -14), 
        Vector2(-10, 10), 
        Vector2(10, 10), 
    ])
    draw_colored_polygon(pts, SHIP_FILL)
    for i in range(3):
        draw_line(pts[i], pts[(i + 1) % 3], SHIP_LINE, 2.0)


    var pulse = 0.8 + sin(gt * 6.0) * 0.2
    var eng_a = 0.8 * pulse
    var eng_c = Color(ENGINE_C.r, ENGINE_C.g, ENGINE_C.b, eng_a)
    draw_circle(Vector2(-5, 9), 3.0, eng_c)
    draw_circle(Vector2(5, 9), 3.0, eng_c)


    for i in range(8):
        var t = float(i) / 8.0
        var r = 20.0 * (1.0 - t * 0.6)
        var a = 0.06 * (1.0 - t) * pulse
        draw_circle(Vector2.ZERO, r, 
            Color(SHIP_LINE.r, SHIP_LINE.g, SHIP_LINE.b, a))
