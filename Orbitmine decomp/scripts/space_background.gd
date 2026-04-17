extends Node2D





var stars: Array = []
const STAR_COUNT: = 200
const STAR_AREA: = 3000.0

func _ready():
    for i in range(STAR_COUNT):
        stars.append({
            "pos": Vector2(
                randf_range( - STAR_AREA, STAR_AREA), 
                randf_range( - STAR_AREA, STAR_AREA)
            ), 
            "size": randf_range(0.5, 2.5), 
            "alpha": randf_range(0.2, 0.8), 
            "twinkle_speed": randf_range(0.5, 3.0), 
            "twinkle_offset": randf() * TAU, 
        })

func _process(_delta):
    queue_redraw()

func _draw():
    var t = Time.get_ticks_msec() * 0.001
    for star in stars:
        var alpha = star.alpha + 0.15 * sin(t * star.twinkle_speed + star.twinkle_offset)
        alpha = clampf(alpha, 0.1, 1.0)
        draw_circle(star.pos, star.size, Color(1, 1, 1, alpha))
