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
var _last_extraction_visible := false
var _last_render_detail_mode := -1
var _last_fuel_ratio := -1.0
var _last_cargo_ratio := -1.0
var _last_power_ratio := -1.0
var _last_power_pulse := -1.0
var _last_power_active := false
var _last_forward_guide_active := false
var _last_forward_guide_range := -1.0

const SOFT_ARC_LOAD_LIMIT := 12
const HARD_ARC_LOAD_LIMIT := 20
const MAX_SOFT_ELECTRIC_ARCS_DRAWN := 8
const MAX_HARD_ELECTRIC_ARCS_DRAWN := 4
const MAX_SOFT_CHAIN_ARCS_DRAWN := 8
const MAX_HARD_CHAIN_ARCS_DRAWN := 4
var SHIP_POINTS: PackedVector2Array = PackedVector2Array([
    Vector2(-3.0, 15.0),
    Vector2(-3.0, 0.0),
    Vector2(-9.0, 0.0),
    Vector2(-9.0, -3.0),
    Vector2(-7.5, -3.0),
    Vector2(-7.5, -6.0),
    Vector2(-6.0, -6.0),
    Vector2(-6.0, -9.0),
    Vector2(-4.5, -9.0),
    Vector2(-4.5, -12.0),
    Vector2(-3.0, -12.0),
    Vector2(-3.0, -15.0),
    Vector2(-1.5, -15.0),
    Vector2(-1.5, -18.0),
    Vector2(3.0, -18.0),
    Vector2(1.5, -15.0),
    Vector2(3.0, -15.0),
    Vector2(3.0, -12.0),
    Vector2(4.5, -12.0),
    Vector2(4.5, -9.0),
    Vector2(6.0, -9.0),
    Vector2(6.0, -6.0),
    Vector2(7.5, -6.0),
    Vector2(7.5, -3.0),
    Vector2(9.0, -3.0),
    Vector2(9.0, 0.0),
    Vector2(3.0, 0.0),
    Vector2(3.0, 15.0),
])

func _process(_delta: float) -> void:
    if scene_ref == null:
        return
    var attack_visible := scene_ref.attack_visible_timer > 0.0 and scene_ref.last_attack_target != Vector2.ZERO
    var mega_active := scene_ref.mega_timer > 0.0
    var overdrive_active := scene_ref.overdrive_timer > 0.0
    var invuln_active := scene_ref.shield_invuln_timer > 0.0
    var extraction_progress := scene_ref.get_return_zone_progress()
    var extraction_visible := _is_extraction_zone_visible()
    var render_detail_mode := int(scene_ref.render_detail_mode)
    var drones_active := not scene_ref.drone_positions.is_empty() or not scene_ref.drone_beams.is_empty() or not scene_ref.drone_missiles.is_empty() or not scene_ref.drone_mines.is_empty()
    var trail_active := not scene_ref.ship_trail.is_empty()
    var arcs_active := not scene_ref.electric_arcs.is_empty() or not scene_ref.chain_arcs.is_empty()
    var seismic_active := not scene_ref.seismic_charge_bursts.is_empty()
    var side_projectiles_active := not scene_ref.side_projectiles.is_empty()
    var side_attackers_active := not scene_ref.side_attackers.is_empty()
    var fuel_ratio := clampf(scene_ref.time_left / maxf(float(scene_ref.runtime_stats.get("run_time", 30.0)), 0.001), 0.0, 1.0)
    var cargo_ratio := float(scene_ref.cargo_units) / maxf(float(scene_ref.runtime_stats.get("cargo_capacity", 15)), 1.0)
    var power_ratio := scene_ref._get_power_ratio()
    var power_pulse := clampf(scene_ref.power_ring_overcharge, 0.0, 1.0)
    var power_active := scene_ref._is_power_active()
    var forward_guide_active := scene_ref.is_forward_shot_active()
    var forward_guide_range := scene_ref.get_forward_shot_range()
    var needs_redraw := false
    var render_rotation := scene_ref.get_ship_render_rotation()
    if render_rotation != _last_visual_rotation:
        _last_visual_rotation = render_rotation
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
    if extraction_visible != _last_extraction_visible:
        _last_extraction_visible = extraction_visible
        needs_redraw = true
    if render_detail_mode != _last_render_detail_mode:
        _last_render_detail_mode = render_detail_mode
        needs_redraw = true
    if absf(fuel_ratio - _last_fuel_ratio) > 0.003:
        _last_fuel_ratio = fuel_ratio
        needs_redraw = true
    if absf(cargo_ratio - _last_cargo_ratio) > 0.003:
        _last_cargo_ratio = cargo_ratio
        needs_redraw = true
    if absf(power_ratio - _last_power_ratio) > 0.003:
        _last_power_ratio = power_ratio
        needs_redraw = true
    if absf(power_pulse - _last_power_pulse) > 0.02:
        _last_power_pulse = power_pulse
        needs_redraw = true
    if power_active != _last_power_active:
        _last_power_active = power_active
        needs_redraw = true
    if forward_guide_active != _last_forward_guide_active:
        _last_forward_guide_active = forward_guide_active
        needs_redraw = true
    if absf(forward_guide_range - _last_forward_guide_range) > 0.5:
        _last_forward_guide_range = forward_guide_range
        needs_redraw = true
    if attack_visible or mega_active or overdrive_active or invuln_active or drones_active or trail_active or arcs_active or seismic_active or side_projectiles_active or side_attackers_active or forward_guide_active or extraction_progress > 0.0 or extraction_visible:
        needs_redraw = true
    if needs_redraw:
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    var perf_start_us := scene_ref.perf_probe_begin()
    var vp := scene_ref.get_visual_power()
    var ship_line: Color = _get_base_ship_color()
    var ship_fill := Color(0.02, 0.04, 0.06, 1.0)
    var fuel_ratio := clampf(scene_ref.time_left / maxf(float(scene_ref.runtime_stats.get("run_time", 30.0)), 0.001), 0.0, 1.0)
    if fuel_ratio <= 0.5:
        var low_fuel_t := 1.0 - clampf(fuel_ratio / 0.5, 0.0, 1.0)
        var flash_speed := lerpf(4.0, 14.0, low_fuel_t)
        var flash_mix := 0.35 + 0.65 * (0.5 + 0.5 * sin(scene_ref.ship_glow_phase * flash_speed))
        var fuel_warning := Color(1.0, 0.12, 0.08, 1.0)
        ship_line = ship_line.lerp(fuel_warning, clampf(low_fuel_t * flash_mix, 0.0, 1.0))
        ship_fill = ship_fill.lerp(Color(0.14, 0.02, 0.02, 1.0), clampf(low_fuel_t * 0.55, 0.0, 0.55))
    if scene_ref.shield_invuln_timer > 0.0:
        var blink_phase := sin((1.0 - scene_ref.shield_invuln_timer / maxf(scene_ref.SHIELD_HIT_INVULN_TIME, 0.001)) * TAU * 10.0)
        var blink_alpha := 0.25 if blink_phase > 0.0 else 1.0
        ship_line.a = blink_alpha
        ship_fill.a = blink_alpha

    if int(scene_ref.barriers_left) > 0:
        var barrier_alpha := 0.26
        draw_arc(Vector2.ZERO, scene_ref.SHIP_RADIUS + 6.0, 0.0, TAU, 32, Color(0.3, 1.5, 2.0, barrier_alpha), 2.0)

    if fuel_ratio <= 0.5:
        var fuel_alert_t := 1.0 - clampf(fuel_ratio / 0.5, 0.0, 1.0)
        var alert_speed := lerpf(4.0, 14.0, fuel_alert_t)
        var alert_pulse := 0.5 + 0.5 * sin(scene_ref.ship_glow_phase * alert_speed)
        draw_circle(Vector2.ZERO, 28.0, Color(1.2, 0.08, 0.06, 0.1 + fuel_alert_t * (0.08 + alert_pulse * 0.18)))

    _draw_forward_shot_guide()
    _draw_ship_trail(ship_line)
    _draw_extraction_zone()
    var rings_start_us := scene_ref.perf_probe_begin()
    _draw_power_rings(vp)
    scene_ref.perf_probe_end("ship_draw_rings", rings_start_us)

    draw_set_transform(Vector2.ZERO, scene_ref.get_ship_render_rotation())
    draw_colored_polygon(SHIP_POINTS, ship_fill)
    for idx in range(SHIP_POINTS.size()):
        draw_line(SHIP_POINTS[idx], SHIP_POINTS[(idx + 1) % SHIP_POINTS.size()], ship_line, 2.0)
    draw_line(Vector2(0.0, -12.0), Vector2(0.0, 9.0), ship_line, 2.0)
    draw_rect(Rect2(Vector2(-1.0, 4.0), Vector2(2.0, 7.0)), ship_line, false, 2.0)
    draw_set_transform(Vector2.ZERO, 0.0)

    if scene_ref.mega_timer > 0.0:
        _draw_mega_laser()
    if scene_ref.attack_visible_timer > 0.0 and scene_ref.last_attack_target != Vector2.ZERO:
        _draw_normal_laser(vp)

    _draw_electric_arcs(vp)
    _draw_chain_arcs(vp)
    _draw_seismic_charge_bursts()
    var drones_start_us := scene_ref.perf_probe_begin()
    _draw_drones(vp)
    scene_ref.perf_probe_end("ship_draw_drones", drones_start_us)
    _draw_side_attackers()
    _draw_side_projectiles()
    scene_ref.perf_probe_end("ship_draw", perf_start_us)

func _draw_extraction_zone() -> void:
    if not _is_extraction_zone_visible():
        return
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

func _is_extraction_zone_visible() -> bool:
    return scene_ref.should_render_extraction_zone()

func _draw_forward_shot_guide() -> void:
    if not scene_ref.is_forward_shot_active():
        return
    var forward := scene_ref._get_forward_direction()
    if forward.length_squared() <= 0.001:
        return
    var start_dist := scene_ref.SHIP_RADIUS + 10.0
    var start := forward * start_dist
    var end := scene_ref.get_forward_shot_guide_end_world() - scene_ref.ship_pos
    if end.length() < start_dist + 12.0:
        end = forward * (start_dist + 12.0)
    var side := forward.orthogonal()
    var pulse := 0.5 + 0.5 * sin(scene_ref.ship_glow_phase * 3.0)
    var guide_line := Color(0.86, 0.88, 0.9, 0.26 + pulse * 0.1)
    var guide_core := Color(0.96, 0.98, 1.0, 0.56 + pulse * 0.18)
    draw_line(start, end, Color(0.9, 0.92, 0.94, 0.09 + pulse * 0.04), 8.0)
    draw_line(start, end, guide_line, 3.0)
    draw_line(start, end, guide_core, 1.2)
    draw_line(end - side * 7.0, end + side * 7.0, Color(0.96, 0.98, 1.0, 0.38 + pulse * 0.18), 1.4)

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
        var age := float(trail.get("age", 0.0))
        var cycle := clampf(age * 0.55, 0.0, 1.0)
        var trail_color := _get_base_ship_color().lerp(Color.from_hsv(fposmod(0.55 + cycle * 0.45, 1.0), 0.7, 1.0), clampf(cycle, 0.0, 1.0))
        var ghost_points := PackedVector2Array()
        ghost_points.resize(SHIP_POINTS.size())
        for point_idx in range(SHIP_POINTS.size()):
            ghost_points[point_idx] = SHIP_POINTS[point_idx].rotated(rot) + local_pos
        for idx in range(ghost_points.size()):
            draw_line(
                ghost_points[idx],
                ghost_points[(idx + 1) % ghost_points.size()],
                Color(trail_color.r, trail_color.g, trail_color.b, alpha),
                1.5
            )
        draw_circle(local_pos, 8.0, Color(trail_color.r, trail_color.g, trail_color.b, alpha * 0.25))

func _draw_power_rings(vp: float) -> void:
    var max_time := maxf(float(scene_ref.runtime_stats.get("run_time", 30.0)), 0.001)
    var fuel_ratio := clampf(scene_ref.time_left / max_time, 0.0, 1.0)
    var cargo_ratio := float(scene_ref.cargo_units) / maxf(float(scene_ref.runtime_stats.get("cargo_capacity", 15)), 1.0)
    var power_ratio := scene_ref._get_power_ratio()
    var power_pulse := clampf(scene_ref.power_ring_overcharge, 0.0, 1.0)
    var power_color := _get_power_color()
    var fuel_color := Color(0.96, 0.98, 1.0, 0.9)
    if fuel_ratio <= 0.5:
        var low_fuel_t := 1.0 - clampf(fuel_ratio / 0.5, 0.0, 1.0)
        var flash_speed := lerpf(4.0, 14.0, low_fuel_t)
        var flash_mix := 0.4 + 0.6 * (0.5 + 0.5 * sin(scene_ref.ship_glow_phase * flash_speed))
        fuel_color = fuel_color.lerp(Color(1.0, 0.18, 0.12, 1.0), clampf(low_fuel_t * flash_mix, 0.0, 1.0))
    _draw_resource_ring(20.0, fuel_ratio, fuel_color, 0.18 + vp * 0.04, true)
    var cargo_color := Color(0.3, 1.0, 0.72, 0.92)
    var cargo_overfill := maxf(0.0, cargo_ratio - 1.0)
    if cargo_overfill > 0.0:
        var overfill_pulse := 0.5 + 0.5 * sin(scene_ref.ship_glow_phase * 5.0)
        cargo_color = cargo_color.lerp(Color(0.72, 1.0, 0.88, 1.0), minf(0.5, cargo_overfill * 1.6) * (0.6 + overfill_pulse * 0.4))
    _draw_resource_ring(26.0, cargo_ratio, cargo_color, 0.14 + vp * 0.04, false)
    if cargo_overfill > 0.0:
        var overflow_radius := 28.5 + sin(scene_ref.ship_glow_phase * 4.5) * 0.8
        draw_arc(Vector2.ZERO, overflow_radius, 0.0, TAU, 28, Color(cargo_color.r, cargo_color.g, cargo_color.b, 0.22 + minf(0.18, cargo_overfill * 0.2)), 1.4)
    var bar_width := 24.0 + power_pulse * 4.0
    var bar_height := 3.5 + power_pulse * 1.2
    var bar_pos := Vector2(-bar_width * 0.5, 21.0)
    draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(power_color.r * 0.25, power_color.g * 0.25, power_color.b * 0.25, 0.35), true)
    draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(power_color.r, power_color.g, power_color.b, 0.7 + power_pulse * 0.15), false, 1.1)
    if power_ratio > 0.0:
        draw_rect(Rect2(bar_pos, Vector2(bar_width * power_ratio, bar_height)), Color(power_color.r, power_color.g, power_color.b, 0.92), true)
    if scene_ref._is_power_ready():
        var pulse_width := bar_width + 4.0 + sin(scene_ref.ship_glow_phase * 8.0) * 2.0
        var pulse_pos := Vector2(-pulse_width * 0.5, 19.5)
        draw_rect(Rect2(pulse_pos, Vector2(pulse_width, bar_height + 3.0)), Color(power_color.r, power_color.g, power_color.b, 0.35 + power_pulse * 0.18), false, 1.2)

func _draw_resource_ring(radius: float, ratio: float, color: Color, glow_alpha: float, drain_mode: bool) -> void:
    var clamped_ratio := clampf(ratio, 0.0, 1.0)
    draw_arc(Vector2.ZERO, radius, -PI * 0.5, TAU - PI * 0.5, 36, Color(color.r, color.g, color.b, 0.14), 2.4)
    if clamped_ratio <= 0.0:
        return
    var filled_ratio := clamped_ratio if not drain_mode else clamped_ratio
    draw_arc(Vector2.ZERO, radius, -PI * 0.5, -PI * 0.5 + TAU * filled_ratio, 36, Color(color.r, color.g, color.b, glow_alpha), 4.4)
    draw_arc(Vector2.ZERO, radius, -PI * 0.5, -PI * 0.5 + TAU * filled_ratio, 36, color, 2.1)

func _get_base_ship_color() -> Color:
    return Color(0.98, 0.99, 1.0, 1.0)

func _get_power_color() -> Color:
    var pulse := 0.5 + 0.5 * sin(scene_ref.ship_glow_phase * 6.5)
    return Color(1.0, 0.45 + pulse * 0.15, 0.1 + pulse * 0.05, 1.0)

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
            draw_line(prev, next_pt, Color(0.1, 2.2, 0.7, alpha * 0.25), 6.0 + vp * 4.0)
            draw_line(prev, next_pt, Color(0.3, 2.8, 1.0, alpha), 1.5 + vp)
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
        var glow_alpha := 0.08 + (sin(scene_ref.ship_glow_phase * 1.7 + float(idx) * 1.8) + 1.0) * 0.04
        draw_circle(local, 7.5, Color(1.0, 0.88, 0.22, glow_alpha))
        draw_circle(local, 3.2, Color(1.0, 0.84, 0.16, 0.98))
        draw_circle(local + Vector2(1.0, -1.0), 1.1, Color(1.0, 0.97, 0.55, 1.0))
    for beam in scene_ref.drone_beams:
        var alpha := clampf(float(beam.get("timer", 0.0)) / scene_ref.DRONE_BEAM_DURATION, 0.0, 1.0)
        draw_line(
            Vector2(beam.get("from", Vector2.ZERO)) - scene_ref.ship_pos,
            Vector2(beam.get("to", Vector2.ZERO)) - scene_ref.ship_pos,
            Color(1.0, 0.85, 0.2, alpha * 0.3),
            6.0 + vp * 3.0
        )
        draw_line(
            Vector2(beam.get("from", Vector2.ZERO)) - scene_ref.ship_pos,
            Vector2(beam.get("to", Vector2.ZERO)) - scene_ref.ship_pos,
            Color(1.0, 0.92, 0.3, alpha),
            1.4 + vp * 0.6
        )
    for missile_variant in scene_ref.drone_missiles:
        var missile: Dictionary = missile_variant
        var local_missile := Vector2(missile.get("position", Vector2.ZERO)) - scene_ref.ship_pos
        var vel := Vector2(missile.get("velocity", Vector2.ZERO))
        draw_circle(local_missile, 8.0, Color(1.0, 0.35, 0.14, 0.12))
        if vel.length() > 0.01:
            var trail := vel.normalized()
            draw_line(local_missile, local_missile - trail * 16.0, Color(1.0, 0.58, 0.22, 0.92), 2.4)
            draw_line(local_missile, local_missile - trail * 8.0 + trail.orthogonal() * 3.0, Color(1.0, 0.86, 0.34, 0.85), 1.4)
            draw_line(local_missile, local_missile - trail * 8.0 - trail.orthogonal() * 3.0, Color(1.0, 0.86, 0.34, 0.85), 1.4)
        draw_circle(local_missile, 3.2, Color(1.0, 0.9, 0.55, 1.0))
    for mine_variant in scene_ref.drone_mines:
        var mine: Dictionary = mine_variant
        var local_mine := Vector2(mine.get("position", Vector2.ZERO)) - scene_ref.ship_pos
        var blink := 0.5 + 0.5 * sin(float(mine.get("blink", 0.0)))
        draw_circle(local_mine, 12.0, Color(1.0, 0.18, 0.12, 0.1 + blink * 0.08))
        draw_circle(local_mine, 7.0, Color(0.18, 0.03, 0.03, 0.96))
        draw_arc(local_mine, 8.0, 0.0, TAU, 18, Color(1.0, 0.42 + blink * 0.3, 0.24, 0.95), 2.0)
        draw_circle(local_mine, 2.0, Color(1.0, 0.92, 0.7, 0.8 + blink * 0.2))

func _draw_seismic_charge_bursts() -> void:
    for burst_variant in scene_ref.seismic_charge_bursts:
        var burst: Dictionary = burst_variant
        var duration := scene_ref.ARC_DURATION if bool(burst.get("packet_burst", false)) else scene_ref.SEISMIC_CHARGE_VISUAL_DURATION
        var life_ratio := clampf(float(burst.get("timer", 0.0)) / duration, 0.0, 1.0)
        var local := Vector2(burst.get("position", Vector2.ZERO)) - scene_ref.ship_pos
        var radius := float(burst.get("radius", 32.0)) * (1.0 + (1.0 - life_ratio) * 0.45)
        if bool(burst.get("packet_burst", false)):
            draw_circle(local, radius, Color(0.1, 1.8, 0.55, 0.04 + (1.0 - life_ratio) * 0.05))
            draw_arc(local, radius * 0.68, 0.0, TAU, 18, Color(0.25, 2.4, 0.8, 0.72 * life_ratio), 2.0)
            draw_arc(local, radius * 0.34, 0.0, TAU, 12, Color(0.75, 1.0, 0.82, 0.86 * life_ratio), 1.6)
            continue
        if bool(burst.get("rage_tracer", false)):
            var elapsed := scene_ref.SEISMIC_CHARGE_VISUAL_DURATION - float(burst.get("timer", 0.0))
            if elapsed <= scene_ref.SEISMIC_CHARGE_TRACER_DURATION:
                var tracer_alpha := 0.85 * (1.0 - clampf(elapsed / maxf(scene_ref.SEISMIC_CHARGE_TRACER_DURATION, 0.001), 0.0, 1.0))
                draw_line(Vector2.ZERO, local, Color(0.95, 0.97, 1.0, tracer_alpha * 0.28), 3.0)
                draw_line(Vector2.ZERO, local, Color(0.9, 0.93, 0.96, tracer_alpha), 1.65)
        draw_circle(local, radius, Color(1.0, 0.5, 0.12, 0.05 + (1.0 - life_ratio) * 0.05))
        draw_arc(local, radius * 0.75, 0.0, TAU, 24, Color(1.0, 0.76, 0.28, 0.75 * life_ratio), 2.0)
        draw_arc(local, radius * 0.42, 0.0, TAU, 18, Color(1.0, 0.92, 0.56, 0.9 * life_ratio), 2.4)

func _draw_side_projectiles() -> void:
    for projectile_variant in scene_ref.side_projectiles:
        var projectile: Dictionary = projectile_variant
        var local := Vector2(projectile.get("position", Vector2.ZERO)) - scene_ref.ship_pos
        var vel := Vector2(projectile.get("velocity", Vector2.ZERO))
        draw_circle(local, 7.0, Color(1.0, 0.25, 0.15, 0.14))
        if vel.length() > 0.01:
            draw_line(local, local - vel.normalized() * 14.0, Color(1.0, 0.55, 0.2, 0.95), 2.0)
        draw_circle(local, 3.0, Color(1.0, 0.82, 0.42, 1.0))

func _draw_side_attackers() -> void:
    for attacker_variant in scene_ref.side_attackers:
        var attacker: Dictionary = attacker_variant
        var local := Vector2(attacker.get("position", Vector2.ZERO)) - scene_ref.ship_pos
        var side: float = float(attacker.get("side", -1))
        draw_circle(local, 18.0, Color(1.0, 0.18, 0.15, 0.08))
        draw_circle(local, 10.5, Color(0.22, 0.03, 0.03, 0.95))
        draw_arc(local, 11.5, PI * 0.1, PI * 1.9, 24, Color(1.0, 0.28, 0.22, 0.95), 2.2)
        draw_line(local + Vector2(-4.0, -2.0), local + Vector2(4.0, -2.0), Color(1.0, 0.86, 0.52, 0.95), 1.6)
        draw_line(local, local + Vector2(side * 14.0, 0.0), Color(1.0, 0.42, 0.2, 0.8), 2.0)
        draw_line(local + Vector2(0.0, 7.0), local + Vector2(side * 10.0, 12.0), Color(1.0, 0.28, 0.18, 0.8), 1.4)
