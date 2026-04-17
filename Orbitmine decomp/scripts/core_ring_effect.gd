extends Node2D






var center_pos: Vector2 = Vector2.ZERO
var target_radius: float = 0.0
var current_radius: float = 0.0
var elapsed: float = 0.0
var duration: float = 1.2
var is_active: bool = false


const RING_COLOR: = Color(0.3, 1.5, 2.0)
const RING_INNER: = Color(2.0, 0.4, 0.1)

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

    if elapsed >= duration + 1.0:
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
        fade = 1.0 - clampf((elapsed - duration) / 1.0, 0.0, 1.0)


    var outer_alpha = 0.6 * fade
    draw_arc(center_pos, current_radius, 0, TAU, 96, 
        Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, outer_alpha), 3.0)


    draw_arc(center_pos, current_radius, 0, TAU, 96, 
        Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, outer_alpha * 0.2), 12.0)


    var t = clampf(elapsed / duration, 0.0, 1.0)
    var inner_color = RING_INNER.lerp(RING_COLOR, t)
    var inner_alpha = 0.08 * fade * (1.0 - t * 0.5)
    draw_circle(center_pos, current_radius, 
        Color(inner_color.r, inner_color.g, inner_color.b, inner_alpha))


    if elapsed < 0.3:
        var flash_alpha = (1.0 - elapsed / 0.3) * 0.5
        draw_circle(center_pos, 20 + elapsed * 100, 
            Color(2.0, 1.5, 1.0, flash_alpha))
