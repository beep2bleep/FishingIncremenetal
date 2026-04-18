extends Node2D
class_name OpenPitOrbitShipRenderer

var scene_ref: OpenPitOrbitMain

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    var vp := scene_ref.get_visual_power()
    var ship_line: Color = Color(2.5, 0.3, 0.2, 1.0) if scene_ref.overdrive_timer > 0.0 else Color(0.5, 1.8, 2.0, 1.0)

    if int(scene_ref.barriers_left) > 0:
        var barrier_alpha := 0.2 + sin(scene_ref.ship_glow_phase * 2.0) * 0.1
        draw_arc(Vector2.ZERO, scene_ref.SHIP_RADIUS + 6.0, 0.0, TAU, 32, Color(0.3, 1.5, 2.0, barrier_alpha), 2.0)

    if scene_ref.overdrive_timer > 0.0:
        var od_pulse := (sin(scene_ref.ship_glow_phase * 6.0) + 1.0) * 0.5
        draw_circle(Vector2.ZERO, 28.0, Color(1.5, 0.2, 0.1, 0.15 + od_pulse * 0.2))

    draw_set_transform(Vector2.ZERO, scene_ref.visual_rotation)
    var ship_points := PackedVector2Array([
        Vector2(0.0, -14.0),
        Vector2(-10.0, 10.0),
        Vector2(10.0, 10.0),
    ])
    draw_colored_polygon(ship_points, Color(0.02, 0.04, 0.06, 1.0))
    for idx in range(ship_points.size()):
        draw_line(ship_points[idx], ship_points[(idx + 1) % ship_points.size()], ship_line, 2.0)
    draw_circle(Vector2(-5.0, 9.0), 2.5, ship_line)
    draw_circle(Vector2(5.0, 9.0), 2.5, ship_line)
    draw_set_transform(Vector2.ZERO, 0.0)

    if scene_ref.mega_timer > 0.0:
        _draw_mega_laser()
    elif scene_ref.attack_visible_timer > 0.0 and scene_ref.last_attack_target != Vector2.ZERO:
        _draw_normal_laser(vp)

    _draw_electric_arcs(vp)
    _draw_chain_arcs(vp)
    _draw_drones(vp)

func _draw_normal_laser(vp: float) -> void:
    var local_target := scene_ref.last_attack_target - scene_ref.ship_pos
    var glow_width := lerpf(8.0, 14.0, vp)
    var beam_width := lerpf(1.5, 2.5, vp)
    if scene_ref.last_attack_is_crit:
        draw_line(Vector2.ZERO, local_target, Color(1.5, 1.5, 0.2, 0.35), glow_width * 1.2)
        draw_line(Vector2.ZERO, local_target, Color(2.0, 2.0, 0.4, 1.0), beam_width * 1.6)
    elif scene_ref.last_attack_is_charged:
        draw_line(Vector2.ZERO, local_target, Color(2.0, 1.0, 0.1, 0.4), glow_width * 1.2)
        draw_line(Vector2.ZERO, local_target, Color(2.5, 1.5, 0.2, 1.0), maxf(beam_width * 1.8, 4.0))
    else:
        var line_color := Color(3.0, 2.5, 2.0, 1.0) if scene_ref.overdrive_timer > 0.0 else Color(2.0, 0.7, 0.2, 1.0)
        var glow_color := Color(2.0, 1.5, 1.0, 0.4) if scene_ref.overdrive_timer > 0.0 else Color(1.5, 0.5, 0.15, 0.3)
        draw_line(Vector2.ZERO, local_target, glow_color, glow_width)
        draw_line(Vector2.ZERO, local_target, line_color, beam_width)
    for other_target in scene_ref.multi_targets:
        var local_other := other_target - scene_ref.ship_pos
        draw_line(Vector2.ZERO, local_other, Color(1.5, 0.5, 0.15, 0.22), glow_width * 0.8)
        draw_line(Vector2.ZERO, local_other, Color(2.0, 0.7, 0.2, 0.9), beam_width * 0.8)

func _draw_mega_laser() -> void:
    var beam_end := scene_ref.mega_beam_end - scene_ref.ship_pos
    draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 32, Color(2.5, 1.2, 0.3, 0.35), 3.0)
    draw_line(Vector2.ZERO, beam_end, Color(2.0, 0.8, 0.2, 0.35), 20.0)
    draw_line(Vector2.ZERO, beam_end, Color(2.5, 1.2, 0.3, 1.0), 5.0)
    draw_line(Vector2.ZERO, beam_end, Color(3.0, 2.0, 1.0, 0.8), 2.0)

func _draw_electric_arcs(vp: float) -> void:
    for arc in scene_ref.electric_arcs:
        var alpha := clampf(float(arc.get("timer", 0.0)) / scene_ref.ARC_DURATION, 0.0, 1.0)
        var local_from := Vector2(arc.get("from", Vector2.ZERO)) - scene_ref.ship_pos
        var local_to := Vector2(arc.get("to", Vector2.ZERO)) - scene_ref.ship_pos
        var perp := (local_to - local_from).orthogonal().normalized()
        var prev := local_from
        for seg in range(4):
            var t_seg := float(seg + 1) / 4.0
            var next_pt := local_from.lerp(local_to, t_seg)
            if seg < 3:
                next_pt += perp * sin(scene_ref.ship_glow_phase * 20.0 + seg * 3.7) * (5.0 + vp * 8.0)
            draw_line(prev, next_pt, Color(0.6, 2.0, 3.0, alpha * 0.25), 6.0 + vp * 4.0)
            draw_line(prev, next_pt, Color(0.6, 2.0, 3.0, alpha), 1.5 + vp)
            prev = next_pt

func _draw_chain_arcs(vp: float) -> void:
    for arc in scene_ref.chain_arcs:
        var alpha := clampf(float(arc.get("timer", 0.0)) / scene_ref.CHAIN_ARC_DURATION, 0.0, 1.0)
        var local_from := Vector2(arc.get("from", Vector2.ZERO)) - scene_ref.ship_pos
        var local_to := Vector2(arc.get("to", Vector2.ZERO)) - scene_ref.ship_pos
        var perp := (local_to - local_from).orthogonal().normalized()
        var prev := local_from
        for seg in range(5):
            var t_seg := float(seg + 1) / 5.0
            var next_pt := local_from.lerp(local_to, t_seg)
            if seg < 4:
                next_pt += perp * sin(scene_ref.ship_glow_phase * 18.0 + seg * 4.3 + alpha * 8.0) * (6.0 + vp * 10.0)
            draw_line(prev, next_pt, Color(0.7, 0.5, 2.0, alpha * 0.3), 5.0 + vp * 5.0)
            draw_line(prev, next_pt, Color(1.0, 0.8, 2.5, alpha), 1.5 + vp)
            prev = next_pt

func _draw_drones(vp: float) -> void:
    for drone_pos in scene_ref.drone_positions:
        var local := drone_pos - scene_ref.ship_pos
        draw_circle(local, 7.0, Color(0.2, 1.5, 0.4, 0.15))
        draw_circle(local, 4.0, Color(0.3, 2.0, 0.5, 1.0))
    for beam in scene_ref.drone_beams:
        var alpha := clampf(float(beam.get("timer", 0.0)) / scene_ref.DRONE_BEAM_DURATION, 0.0, 1.0)
        draw_line(
            Vector2(beam.get("from", Vector2.ZERO)) - scene_ref.ship_pos,
            Vector2(beam.get("to", Vector2.ZERO)) - scene_ref.ship_pos,
            Color(0.2, 1.5, 0.4, alpha * 0.3),
            6.0 + vp * 3.0
        )
        draw_line(
            Vector2(beam.get("from", Vector2.ZERO)) - scene_ref.ship_pos,
            Vector2(beam.get("to", Vector2.ZERO)) - scene_ref.ship_pos,
            Color(0.3, 2.0, 0.6, alpha),
            1.4 + vp * 0.6
        )
