extends Node2D
class_name OpenPitEmpireShipRenderer

var scene_ref: OpenPitEmpireMain
var _last_visual_rotation := INF
var _last_barriers_left := -1
var _last_drone_count := -1
var _last_trail_count := -1
var _last_attack_visible := false
var _last_mega_active := false
var _last_overdrive_active := false
var _last_invuln_active := false
var _last_extraction_progress := -1.0

const SOFT_ARC_LOAD_LIMIT := 12
const HARD_ARC_LOAD_LIMIT := 20
const MAX_SOFT_ELECTRIC_ARCS_DRAWN := 8
const MAX_HARD_ELECTRIC_ARCS_DRAWN := 4
const MAX_SOFT_CHAIN_ARCS_DRAWN := 8
const MAX_HARD_CHAIN_ARCS_DRAWN := 4

func _process(_delta: float) -> void:
    if scene_ref == null:
        return
    var attack_visible := scene_ref.attack_visible_timer > 0.0 and scene_ref.last_attack_target != Vector2.ZERO
    var mega_active := scene_ref.mega_timer > 0.0
    var overdrive_active := scene_ref.overdrive_timer > 0.0
    var invuln_active := scene_ref.shield_invuln_timer > 0.0
    var extraction_progress := scene_ref.get_return_zone_progress()
    var drones_active := not scene_ref.drone_positions.is_empty() or not scene_ref.drone_beams.is_empty()
    var trail_active := not scene_ref.ship_trail.is_empty()
    var arcs_active := not scene_ref.electric_arcs.is_empty() or not scene_ref.chain_arcs.is_empty()
    var needs_redraw := false
    if scene_ref.visual_rotation != _last_visual_rotation:
        _last_visual_rotation = scene_ref.visual_rotation
        needs_redraw = true
    if int(scene_ref.barriers_left) != _last_barriers_left:
        _last_barriers_left = int(scene_ref.barriers_left)
        needs_redraw = true
    if scene_ref.drone_positions.size() != _last_drone_count:
        _last_drone_count = scene_ref.drone_positions.size()
        needs_redraw = true
    if scene_ref.ship_trail.size() != _last_trail_count:
        _last_trail_count = scene_ref.ship_trail.size()
        needs_redraw = true
    if attack_visible != _last_attack_visible:
        _last_attack_visible = attack_visible
        needs_redraw = true
    if mega_active != _last_mega_active:
        _last_mega_active = mega_active
        needs_redraw = true
    if overdrive_active != _last_overdrive_active:
        _last_overdrive_active = overdrive_active
        needs_redraw = true
    if invuln_active != _last_invuln_active:
        _last_invuln_active = invuln_active
        needs_redraw = true
    if absf(extraction_progress - _last_extraction_progress) > 0.001:
        _last_extraction_progress = extraction_progress
        needs_redraw = true
    if attack_visible or mega_active or overdrive_active or invuln_active or drones_active or trail_active or arcs_active or extraction_progress > 0.0:
        needs_redraw = true
    if needs_redraw:
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    var perf_start_us := scene_ref.perf_probe_begin()
    var vp := scene_ref.get_visual_power()
    var ship_line: Color = Color(2.5, 0.3, 0.2, 1.0) if scene_ref.overdrive_timer > 0.0 else Color(0.5, 1.8, 2.0, 1.0)
    var ship_fill := Color(0.02, 0.04, 0.06, 1.0)
    if scene_ref.shield_invuln_timer > 0.0:
        var blink_phase := sin((1.0 - scene_ref.shield_invuln_timer / maxf(scene_ref.SHIELD_HIT_INVULN_TIME, 0.001)) * TAU * 10.0)
        var blink_alpha := 0.25 if blink_phase > 0.0 else 1.0
        ship_line.a = blink_alpha
        ship_fill.a = blink_alpha

    if int(scene_ref.barriers_left) > 0:
        var barrier_alpha := 0.26
        draw_arc(Vector2.ZERO, scene_ref.SHIP_RADIUS + 6.0, 0.0, TAU, 32, Color(0.3, 1.5, 2.0, barrier_alpha), 2.0)

    if scene_ref.overdrive_timer > 0.0:
        var od_pulse := (sin(scene_ref.ship_glow_phase * 6.0) + 1.0) * 0.5
        draw_circle(Vector2.ZERO, 28.0, Color(1.5, 0.2, 0.1, 0.15 + od_pulse * 0.2))

    _draw_ship_trail(ship_line)
    _draw_extraction_zone()

    draw_set_transform(Vector2.ZERO, scene_ref.visual_rotation)
    var ship_points := PackedVector2Array([
        Vector2(0.0, -14.0),
        Vector2(-10.0, 10.0),
        Vector2(10.0, 10.0),
    ])
    draw_colored_polygon(ship_points, ship_fill)
    for idx in range(ship_points.size()):
        draw_line(ship_points[idx], ship_points[(idx + 1) % ship_points.size()], ship_line, 2.0)
    draw_circle(Vector2(-5.0, 9.0), 2.5, ship_line)
    draw_circle(Vector2(5.0, 9.0), 2.5, ship_line)
    draw_set_transform(Vector2.ZERO, 0.0)

    if scene_ref.mega_timer > 0.0:
        _draw_mega_laser()
    if scene_ref.attack_visible_timer > 0.0 and scene_ref.last_attack_target != Vector2.ZERO:
        _draw_normal_laser(vp)

    _draw_electric_arcs(vp)
    _draw_chain_arcs(vp)
    _draw_drones(vp)
    scene_ref.perf_probe_end("ship_draw", perf_start_us)

func _draw_extraction_zone() -> void:
    var local_spawn := scene_ref.spawn_position - scene_ref.ship_pos
    var extraction_progress := scene_ref.get_return_zone_progress()
    var extraction_ring_radius := scene_ref.return_zone_radius + 18.0
    draw_circle(local_spawn, scene_ref.return_zone_radius, Color(0.22, 0.9, 0.45, 0.18))
    draw_arc(local_spawn, scene_ref.return_zone_radius, 0.0, TAU, 48, Color(0.45, 1.8, 0.8, 1.0), 5.0)
    draw_circle(local_spawn, maxf(18.0, scene_ref.return_zone_radius * 0.16), Color(0.8, 2.4, 1.2, 0.78))
    draw_arc(local_spawn, extraction_ring_radius, -PI * 0.5, TAU - PI * 0.5, 48, Color(0.2, 0.55, 0.3, 0.45), 10.0)
    if extraction_progress > 0.0:
        draw_arc(
            local_spawn,
            extraction_ring_radius,
            -PI * 0.5,
            -PI * 0.5 + TAU * extraction_progress,
            48,
            Color(0.7, 2.4, 1.1, 1.0),
            12.0
        )

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

func _draw_ship_trail(ship_line: Color) -> void:
    for trail in scene_ref.ship_trail:
        var local_pos := Vector2(trail.get("pos", Vector2.ZERO)) - scene_ref.ship_pos
        var alpha := clampf(float(trail.get("alpha", 0.0)), 0.0, 0.6)
        if alpha <= 0.0:
            continue
        var rot := float(trail.get("rot", 0.0))
        var ghost_points := PackedVector2Array([
            Vector2(0.0, -14.0).rotated(rot) + local_pos,
            Vector2(-10.0, 10.0).rotated(rot) + local_pos,
            Vector2(10.0, 10.0).rotated(rot) + local_pos,
        ])
        for idx in range(ghost_points.size()):
            draw_line(
                ghost_points[idx],
                ghost_points[(idx + 1) % ghost_points.size()],
                Color(ship_line.r, ship_line.g, ship_line.b, alpha),
                1.5
            )
        draw_circle(local_pos, 8.0, Color(ship_line.r, ship_line.g, ship_line.b, alpha * 0.25))

func _draw_electric_arcs(vp: float) -> void:
    var arc_count := scene_ref.electric_arcs.size()
    var max_draw := arc_count
    var segments := 4
    if arc_count >= HARD_ARC_LOAD_LIMIT:
        max_draw = mini(arc_count, MAX_HARD_ELECTRIC_ARCS_DRAWN)
        segments = 2
    elif arc_count >= SOFT_ARC_LOAD_LIMIT:
        max_draw = mini(arc_count, MAX_SOFT_ELECTRIC_ARCS_DRAWN)
        segments = 3
    for arc_idx in range(max_draw):
        var arc: Dictionary = scene_ref.electric_arcs[arc_idx]
        var alpha := clampf(float(arc.get("timer", 0.0)) / scene_ref.ARC_DURATION, 0.0, 1.0)
        var local_from := Vector2(arc.get("from", Vector2.ZERO)) - scene_ref.ship_pos
        var local_to := Vector2(arc.get("to", Vector2.ZERO)) - scene_ref.ship_pos
        var perp := (local_to - local_from).orthogonal().normalized()
        var prev := local_from
        for seg in range(segments):
            var t_seg := float(seg + 1) / float(segments)
            var next_pt := local_from.lerp(local_to, t_seg)
            if seg < segments - 1:
                next_pt += perp * sin(scene_ref.ship_glow_phase * 20.0 + seg * 3.7) * (5.0 + vp * 8.0)
            draw_line(prev, next_pt, Color(0.6, 2.0, 3.0, alpha * 0.25), 6.0 + vp * 4.0)
            draw_line(prev, next_pt, Color(0.6, 2.0, 3.0, alpha), 1.5 + vp)
            prev = next_pt

func _draw_chain_arcs(vp: float) -> void:
    var arc_count := scene_ref.chain_arcs.size()
    var max_draw := arc_count
    var segments := 5
    if arc_count >= HARD_ARC_LOAD_LIMIT:
        max_draw = mini(arc_count, MAX_HARD_CHAIN_ARCS_DRAWN)
        segments = 3
    elif arc_count >= SOFT_ARC_LOAD_LIMIT:
        max_draw = mini(arc_count, MAX_SOFT_CHAIN_ARCS_DRAWN)
        segments = 4
    for arc_idx in range(max_draw):
        var arc: Dictionary = scene_ref.chain_arcs[arc_idx]
        var alpha := clampf(float(arc.get("timer", 0.0)) / scene_ref.CHAIN_ARC_DURATION, 0.0, 1.0)
        var local_from := Vector2(arc.get("from", Vector2.ZERO)) - scene_ref.ship_pos
        var local_to := Vector2(arc.get("to", Vector2.ZERO)) - scene_ref.ship_pos
        var perp := (local_to - local_from).orthogonal().normalized()
        var prev := local_from
        for seg in range(segments):
            var t_seg := float(seg + 1) / float(segments)
            var next_pt := local_from.lerp(local_to, t_seg)
            if seg < segments - 1:
                next_pt += perp * sin(scene_ref.ship_glow_phase * 18.0 + seg * 4.3 + alpha * 8.0) * (6.0 + vp * 10.0)
            draw_line(prev, next_pt, Color(0.7, 0.5, 2.0, alpha * 0.3), 5.0 + vp * 5.0)
            draw_line(prev, next_pt, Color(1.0, 0.8, 2.5, alpha), 1.5 + vp)
            prev = next_pt

func _draw_drones(vp: float) -> void:
    for idx in range(scene_ref.drone_positions.size()):
        var drone_pos := scene_ref.drone_positions[idx]
        var local := drone_pos - scene_ref.ship_pos
        var drone_rot := scene_ref.visual_rotation
        var drone_points := PackedVector2Array([
            local + Vector2(0.0, -6.0).rotated(drone_rot),
            local + Vector2(-4.0, 4.0).rotated(drone_rot),
            local + Vector2(4.0, 4.0).rotated(drone_rot),
        ])
        draw_colored_polygon(drone_points, Color(0.02, 0.04, 0.03, 0.95))
        for j in range(drone_points.size()):
            draw_line(drone_points[j], drone_points[(j + 1) % drone_points.size()], Color(0.3, 2.0, 0.6, 1.0), 1.5)
        var glow_alpha := 0.06 + (sin(scene_ref.ship_glow_phase + float(idx) * 2.0) + 1.0) * 0.03
        draw_circle(local, 9.0, Color(0.2, 1.5, 0.4, glow_alpha))
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
