extends Node2D






var center_pos: Vector2 = Vector2.ZERO
var target_radius: float = 0.0
var current_radius: float = 0.0
var elapsed: float = 0.0
var duration: float = 0.4
var fade_time: float = 0.5
var is_active: bool = false


const RING_COLOR: = Color(2.0, 1.6, 0.3)
const INNER_COLOR: = Color(1.5, 1.2, 0.2, 0.08)

func setup(pos: Vector2, radius: float):
    center_pos = pos
    target_radius = radius
    current_radius = 0.0
    elapsed = 0.0
    is_active = true
    global_position = Vector2.ZERO

func _process(delta):
    if not is_active:
        return

    elapsed += delta

    if elapsed >= duration + fade_time:
        queue_free()
        return


    var t = clampf(elapsed / duration, 0.0, 1.0)
    var eased = 1.0 - pow(1.0 - t, 3.0)
    current_radius = target_radius * eased

    queue_redraw()

func _draw():
    if not is_active:
        return


    var fade = 1.0
    if elapsed > duration:
        fade = 1.0 - clampf((elapsed - duration) / fade_time, 0.0, 1.0)


    var outer_alpha = 0.7 * fade
    draw_arc(center_pos, current_radius, 0, TAU, 96, 
        Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, outer_alpha), 3.5)


    draw_arc(center_pos, current_radius, 0, TAU, 96, 
        Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, outer_alpha * 0.15), 14.0)


    var t = clampf(elapsed / duration, 0.0, 1.0)
    var inner_alpha = 0.06 * fade * (1.0 - t)
    if inner_alpha > 0.001:
        draw_circle(center_pos, current_radius, 
            Color(INNER_COLOR.r, INNER_COLOR.g, INNER_COLOR.b, inner_alpha))


    if elapsed < 0.15:
        var flash_alpha = (1.0 - elapsed / 0.15) * 0.4
        draw_circle(center_pos, 15 + elapsed * 200, 
            Color(2.0, 1.8, 1.5, flash_alpha))
