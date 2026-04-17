extends Node2D






const BUBBLE_RADIUS: = 16.0
const BODY_SIZE: = 11.0

func _draw():
    var ship = get_parent()
    if not ship:
        return


    draw_circle(Vector2.ZERO, BUBBLE_RADIUS, Color(0.2, 0.4, 0.7, 0.1))
    var glow = 0.3 + 0.1 * sin(ship.ship_glow_phase * 2.0)
    draw_arc(Vector2.ZERO, BUBBLE_RADIUS, 0, TAU, 24, Color(0.5, 0.8, 1.0, glow), 1.5)

    draw_arc(Vector2(-3, -3), BUBBLE_RADIUS * 0.5, - PI * 0.8, - PI * 0.3, 8, Color(0.8, 0.9, 1.0, 0.25), 1.0)


    var half = BODY_SIZE * 0.5
    draw_rect(Rect2( - half, - half, BODY_SIZE, BODY_SIZE), Color(0.9, 0.55, 0.15))
    draw_rect(Rect2( - half, - half, BODY_SIZE, BODY_SIZE), Color(1.0, 0.7, 0.3, 0.5), false, 0.8)


    draw_circle(Vector2(-3, -2), 2.0, Color.WHITE)
    draw_circle(Vector2(3, -2), 2.0, Color.WHITE)
    draw_circle(Vector2(-2.3, -2), 1.0, Color(0.1, 0.1, 0.15))
    draw_circle(Vector2(3.7, -2), 1.0, Color(0.1, 0.1, 0.15))


    if ship.velocity.length() > 10:
        var flame_dir = - ship.velocity.normalized()
        var flame_pos = flame_dir * (BUBBLE_RADIUS + 2)
        var flame_size = randf_range(3, 6)
        draw_circle(flame_pos, flame_size, Color(1.0, 0.5, 0.15, 0.5))
        draw_circle(flame_pos + flame_dir * 3, flame_size * 0.6, Color(1.0, 0.3, 0.1, 0.3))


    if ship.has_target and ship.has_meta("target_asteroid_pos"):
        var target_world = ship.get_meta("target_asteroid_pos")
        var target_local = target_world - ship.global_position
        var dir = target_local.normalized()
        var beam_start = dir * BUBBLE_RADIUS
        var beam_end = dir * minf(target_local.length(), Global.astro_range)
        var beam_alpha = 0.4 + 0.3 * sin(ship.ship_glow_phase * 8.0)
        draw_line(beam_start, beam_end, Color(0.8, 0.9, 1.0, beam_alpha), 2.0)
        draw_circle(beam_end, 3, Color(1.0, 0.8, 0.3, beam_alpha * 0.6))
