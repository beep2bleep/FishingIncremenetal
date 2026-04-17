extends Node2D






var ship
var _vp: float = 0.0



const STAR_LAYERS = [
    {"parallax": 0.4, "cell": 1200.0, "count": 14, "sz_min": 0.4, "sz_max": 1.0, "a_min": 0.15, "a_max": 0.35}, 
    {"parallax": 0.7, "cell": 900.0, "count": 10, "sz_min": 0.8, "sz_max": 1.8, "a_min": 0.25, "a_max": 0.55}, 
]

const STAR_COLORS = [
    Color(1.0, 1.0, 1.0), 
    Color(0.7, 0.8, 1.0), 
    Color(0.85, 0.75, 1.0), 
    Color(1.0, 0.9, 0.7), 
]

func _ready():
    ship = get_parent()

func _draw():
    if ship.is_dead:
        return


    _vp = ship.get_visual_power()


    _draw_star_background()


    if ship.is_entering:
        var t = clampf(ship.entry_timer / ship.ENTRY_DURATION, 0.0, 1.0)
        var inv_t = 1.0 - t


        var glow_r = 15.0 + inv_t * 30.0
        var glow_a = 0.1 + inv_t * 0.5
        draw_circle(Vector2.ZERO, glow_r, 
            Color(ship.WARP_GLOW.r, ship.WARP_GLOW.g, ship.WARP_GLOW.b, glow_a))


        draw_set_transform(Vector2.ZERO, ship.visual_rotation)
        var ship_pts = PackedVector2Array([
            Vector2(0, -14), 
            Vector2(-10, 10), 
            Vector2(10, 10), 
        ])
        draw_colored_polygon(ship_pts, Color(0.02, 0.04, 0.06))
        var line_col = Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b)
        for i in range(ship_pts.size()):
            draw_line(ship_pts[i], ship_pts[(i + 1) % ship_pts.size()], line_col, 2.0)


        var eng_size = 2.5 + inv_t * 3.0
        var eng_a = 0.8 + inv_t * 0.2
        draw_circle(Vector2(-5, 9), eng_size, Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, eng_a))
        draw_circle(Vector2(5, 9), eng_size, Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, eng_a))
        draw_set_transform(Vector2.ZERO, 0.0)


        var entry_dir = (ship.entry_target_pos - ship.entry_start_pos).normalized()
        var tail_dir = - entry_dir
        var tail_len = inv_t * 200.0
        var tail_a = inv_t * 0.6
        draw_line(Vector2.ZERO, tail_dir * tail_len, 
            Color(ship.WARP_GLOW.r, ship.WARP_GLOW.g, ship.WARP_GLOW.b, tail_a * 0.4), 8.0)
        draw_line(Vector2.ZERO, tail_dir * tail_len, 
            Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, tail_a), 2.0)

        return


    if ship.is_warping:
        var t = clampf(ship.warp_timer / ship.WARP_DURATION, 0.0, 1.0)


        var glow_r = 15.0 + t * 30.0
        var glow_a = 0.1 + t * 0.5
        draw_circle(Vector2.ZERO, glow_r, 
            Color(ship.WARP_GLOW.r, ship.WARP_GLOW.g, ship.WARP_GLOW.b, glow_a))


        draw_set_transform(Vector2.ZERO, ship.visual_rotation)
        var ship_pts = PackedVector2Array([
            Vector2(0, -14), 
            Vector2(-10, 10), 
            Vector2(10, 10), 
        ])
        draw_colored_polygon(ship_pts, Color(0.02, 0.04, 0.06))
        var line_col = Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b)
        for i in range(ship_pts.size()):
            draw_line(ship_pts[i], ship_pts[(i + 1) % ship_pts.size()], line_col, 2.0)


        var eng_size = 2.5 + t * 3.0
        var eng_a = 0.8 + t * 0.2
        draw_circle(Vector2(-5, 9), eng_size, Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, eng_a))
        draw_circle(Vector2(5, 9), eng_size, Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, eng_a))
        draw_set_transform(Vector2.ZERO, 0.0)


        var tail_dir = - ship.warp_dir
        var tail_len = t * 200.0
        var tail_a = t * 0.6
        draw_line(Vector2.ZERO, tail_dir * tail_len, 
            Color(ship.WARP_GLOW.r, ship.WARP_GLOW.g, ship.WARP_GLOW.b, tail_a * 0.4), 8.0)
        draw_line(Vector2.ZERO, tail_dir * tail_len, 
            Color(ship.WARP_LINE.r, ship.WARP_LINE.g, ship.WARP_LINE.b, tail_a), 2.0)

        return


    if ship.collision_invincible_timer > 0:
        var inv_pulse = (sin(ship.ship_glow_phase * 16.0) + 1.0) * 0.5
        var inv_alpha = 0.15 + inv_pulse * 0.25
        draw_arc(Vector2.ZERO, ship.COLLISION_RADIUS + 10, 0, TAU, 32, 
            Color(2.0, 0.4, 0.1, inv_alpha), 2.5)


    if ship.spawn_protection_timer > 0:
        var sp_pulse = (sin(ship.ship_glow_phase * 10.0) + 1.0) * 0.5
        var sp_alpha = 0.2 + sp_pulse * 0.2
        draw_arc(Vector2.ZERO, ship.COLLISION_RADIUS + 8, 0, TAU, 32, 
            Color(0.3, 1.0, 1.2, sp_alpha), 2.0)


    if ship.is_braking:
        var brake_pulse = (sin(ship.ship_glow_phase * 8.0) + 1.0) * 0.5
        var brake_alpha = 0.2 + brake_pulse * 0.15
        draw_arc(Vector2.ZERO, ship.COLLISION_RADIUS + 10, 0, TAU, 32, 
            Color(1.0, 0.4, 0.1, brake_alpha), 2.5)
        draw_arc(Vector2.ZERO, ship.COLLISION_RADIUS + 14, 0, TAU, 24, 
            Color(1.0, 0.3, 0.05, brake_alpha * 0.4), 1.5)


    if ship.barrier_count > 0:
        var barrier_alpha = 0.2 + sin(ship.ship_glow_phase * 2.0) * 0.1
        draw_arc(Vector2.ZERO, ship.COLLISION_RADIUS + 6, 0, TAU, 32, 
            Color(ship.BARRIER_COLOR.r, ship.BARRIER_COLOR.g, ship.BARRIER_COLOR.b, barrier_alpha), 2.0)


    if ship.overdrive_system and ship.overdrive_system.active:
        var od_pulse = (sin(ship.ship_glow_phase * 6.0) + 1.0) * 0.5
        var od_alpha = 0.15 + od_pulse * 0.2
        draw_circle(Vector2.ZERO, 28, Color(ship.OVERDRIVE_GLOW.r, ship.OVERDRIVE_GLOW.g, ship.OVERDRIVE_GLOW.b, od_alpha))
        draw_arc(Vector2.ZERO, 22, 0, TAU, 32, 
            Color(ship.OVERDRIVE_COLOR.r, ship.OVERDRIVE_COLOR.g, ship.OVERDRIVE_COLOR.b, od_alpha * 0.6), 2.5)


    for trail in (ship.overdrive_system.trail if ship.overdrive_system else []):
        var local_pos = trail.pos - ship.global_position
        var a = clampf(trail.alpha, 0.0, 0.6)
        var ghost_pts = PackedVector2Array([
            Vector2(0, -14).rotated(trail.rot) + local_pos, 
            Vector2(-10, 10).rotated(trail.rot) + local_pos, 
            Vector2(10, 10).rotated(trail.rot) + local_pos, 
        ])
        for j in range(ghost_pts.size()):
            draw_line(ghost_pts[j], ghost_pts[(j + 1) % ghost_pts.size()], 
                Color(ship.OVERDRIVE_COLOR.r, ship.OVERDRIVE_COLOR.g, ship.OVERDRIVE_COLOR.b, a), 1.5)
        draw_circle(local_pos, 8, Color(ship.OVERDRIVE_GLOW.r, ship.OVERDRIVE_GLOW.g, ship.OVERDRIVE_GLOW.b, a * 0.4))


    draw_set_transform(Vector2.ZERO, ship.visual_rotation)
    var glow_alpha = 0.08 + sin(ship.ship_glow_phase) * 0.04
    draw_circle(Vector2.ZERO, 20, Color(ship.SHIP_GLOW.r, ship.SHIP_GLOW.g, ship.SHIP_GLOW.b, glow_alpha))


    var ship_points = PackedVector2Array([
        Vector2(0, -14), 
        Vector2(-10, 10), 
        Vector2(10, 10), 
    ])
    draw_colored_polygon(ship_points, Color(0.02, 0.04, 0.06))
    var _od = ship.overdrive_system and ship.overdrive_system.active
    var line_color = ship.OVERDRIVE_COLOR if _od else ship.SHIP_LINE
    for i in range(ship_points.size()):
        var from = ship_points[i]
        var to = ship_points[(i + 1) % ship_points.size()]
        draw_line(from, to, line_color, 2.0)


    var engine_color = ship.OVERDRIVE_COLOR if _od else ship.ENGINE_COLOR
    draw_circle(Vector2(-5, 9), 2.5, engine_color)
    draw_circle(Vector2(5, 9), 2.5, engine_color)
    draw_set_transform(Vector2.ZERO, 0.0)


    draw_arc(Vector2.ZERO, ship.laser_range, 0, TAU, 64, ship.RANGE_LINE, 1.0)


    if Global.combo_unlocked and Global.combo_count > 0:
        _draw_combo()



    if Global.shockwave_unlocked:
        var sw_radius = Global.shockwave_range * PlanetData.BLOCK_SIZE
        var sw_alpha = 0.04 + sin(ship.ship_glow_phase * 1.5) * 0.02
        draw_arc(Vector2.ZERO, sw_radius, 0, TAU, 48, 
            Color(1.0, 0.85, 0.2, sw_alpha), 1.0)


    for ring in ship.shockwave_rings:
        var a = clampf(ring.alpha, 0.0, 0.8)
        draw_arc(Vector2.ZERO, ring.radius, 0, TAU, 48, 
            Color(ship.SHOCKWAVE_RING_COLOR.r, ship.SHOCKWAVE_RING_COLOR.g, ship.SHOCKWAVE_RING_COLOR.b, a * 0.3), 
            4.0 + _vp * 4.0)
        draw_arc(Vector2.ZERO, ring.radius, 0, TAU, 48, 
            Color(ship.SHOCKWAVE_RING_COLOR.r, ship.SHOCKWAVE_RING_COLOR.g, ship.SHOCKWAVE_RING_COLOR.b, a * 0.8), 
            1.5 + _vp * 1.5)


    if ship.mega_system and ship.mega_system.active:
        _draw_mega_laser()
    if ship.has_target and ship.laser_visible_timer > 0:
        _draw_normal_laser()


    _draw_electric_arcs()


    _draw_chain_arcs()


    _draw_drones()


    _draw_overheat()






func _draw_combo():
    var combo = Global.combo_count
    var combo_ratio = float(combo) / float(Global.COMBO_MAX)

    var combo_color: Color
    if combo < 10:
        combo_color = Color(1.0, 1.0, 1.0)
    elif combo < 20:
        combo_color = Color(1.0, 1.0, 0.3)
    elif combo < 30:
        combo_color = Color(1.0, 0.7, 0.15)
    else:
        combo_color = Color(1.0, 0.3, 0.1)

    var font_size = int(lerpf(10.0, 20.0, combo_ratio))
    var pulse = 1.0 + sin(ship.ship_glow_phase * (4.0 + combo_ratio * 6.0)) * combo_ratio * 0.15
    var bounce = ship.combo_popup_scale if ship.combo_popup_timer > 0 else 1.0
    var display_size = int(font_size * pulse * bounce)

    var font = ThemeDB.fallback_font
    var text = "×%d" % combo
    var combo_pos = Vector2(18, -20)

    if ship.combo_popup_timer > 0:
        var glow_a = (ship.combo_popup_timer / ship.COMBO_POPUP_DURATION) * 0.4
        var glow_size = display_size + 4
        draw_string(font, combo_pos + Vector2(-1, -1), text, 
            HORIZONTAL_ALIGNMENT_LEFT, -1, glow_size, 
            Color(combo_color.r, combo_color.g, combo_color.b, glow_a))

    draw_string(font, combo_pos + Vector2(1, 1), text, 
        HORIZONTAL_ALIGNMENT_LEFT, -1, display_size, 
        Color(0, 0, 0, 0.6))
    draw_string(font, combo_pos, text, 
        HORIZONTAL_ALIGNMENT_LEFT, -1, display_size, 
        Color(combo_color.r, combo_color.g, combo_color.b, 0.9))


    if ship.combo_popup_timer > 0 and ship.combo_popup_is_milestone:
        var ms_alpha = clampf(ship.combo_popup_timer / ship.COMBO_POPUP_DURATION, 0.0, 1.0)
        var ms_size = int(28 * ship.combo_popup_scale)
        var ms_text = "★ ×%d COMBO! ★" % ship.combo_popup_value
        var ms_w = font.get_string_size(ms_text, HORIZONTAL_ALIGNMENT_CENTER, -1, ms_size).x
        var ms_pos = Vector2( - ms_w * 0.5, -50)
        draw_string(font, ms_pos, ms_text, 
            HORIZONTAL_ALIGNMENT_LEFT, -1, ms_size + 2, 
            Color(combo_color.r, combo_color.g, combo_color.b, ms_alpha * 0.3))
        draw_string(font, ms_pos, ms_text, 
            HORIZONTAL_ALIGNMENT_LEFT, -1, ms_size, 
            Color(1.0, 0.95, 0.6, ms_alpha))


func _draw_mega_laser():
    var mega_pulse = (sin(ship.ship_glow_phase * 6.0) + 1.0) * 0.5
    var ring_alpha = 0.25 + mega_pulse * 0.15
    draw_arc(Vector2.ZERO, 18, 0, TAU, 32, 
        Color(ship.MEGA_LASER_LINE.r, ship.MEGA_LASER_LINE.g, ship.MEGA_LASER_LINE.b, ring_alpha), 3.0)

    var beam_end = ship.mega_system.beam_end
    draw_line(Vector2.ZERO, beam_end, ship.MEGA_LASER_GLOW, ship.MEGA_GLOW_WIDTH)
    draw_line(Vector2.ZERO, beam_end, ship.MEGA_LASER_LINE, ship.MEGA_BEAM_WIDTH)
    draw_line(Vector2.ZERO, beam_end, Color(3.0, 2.0, 1.0, 0.8), ship.MEGA_CORE_WIDTH)

    var end_pulse = 3.0 + mega_pulse * 2.0
    draw_circle(beam_end, end_pulse, 
        Color(ship.MEGA_LASER_LINE.r, ship.MEGA_LASER_LINE.g, ship.MEGA_LASER_LINE.b, 0.6))

    for hit in ship.mega_system.beam_hits:
        var local_hit = hit.world - ship.global_position
        var hit_pulse = 1.5 + sin(ship.ship_glow_phase * 8.0 + local_hit.x * 0.1) * 0.8
        draw_circle(local_hit, hit_pulse, Color(3.0, 1.5, 0.5, 0.5))


    var mouse_local = ship.get_local_mouse_position()
    var cross_alpha = 0.5 + mega_pulse * 0.3
    var cross_col = Color(1, 1, 1, cross_alpha)
    draw_line(mouse_local + Vector2(-10, 0), mouse_local + Vector2(10, 0), cross_col, 1.5)
    draw_line(mouse_local + Vector2(0, -10), mouse_local + Vector2(0, 10), cross_col, 1.5)

func _draw_normal_laser():
    var local_target = ship.target_world_pos - ship.global_position
    var bw = ship.get_beam_width()
    var bg = ship.get_beam_glow_width()
    var hr = ship.get_hit_flash_radius()


    var od_line = ship.LASER_LINE
    var od_glow = ship.LASER_GLOW
    var _od_laser = ship.overdrive_system and ship.overdrive_system.active
    if _od_laser:
        od_line = Color(3.0, 2.5, 2.0)
        od_glow = Color(2.0, 1.5, 1.0, 0.4)
        bw *= 1.3
        bg *= 1.2


    if ship.is_crit_shot:
        draw_line(Vector2.ZERO, local_target, ship.CRIT_GLOW, bg * 1.2)
        draw_line(Vector2.ZERO, local_target, ship.CRIT_LINE, bw * 1.6)
        if _vp > 0.3:
            draw_line(Vector2.ZERO, local_target, Color(3.0, 3.0, 1.5, 0.5), maxf(1.0, bw * 0.4))
        if ship.laser_flash_timer > 0:
            var t = ship.laser_flash_timer / 0.1
            draw_circle(local_target, hr * 1.5 + t * 6, Color(1.0, 1.0, 0.3, t * 0.7))
        draw_circle(local_target, hr * 0.8, ship.CRIT_LINE)
        for mt in ship.multi_targets:
            var lt = mt - ship.global_position
            draw_line(Vector2.ZERO, lt, ship.CRIT_GLOW, bg)
            draw_line(Vector2.ZERO, lt, ship.CRIT_LINE, bw * 1.3)
            draw_circle(lt, hr * 0.6, ship.CRIT_LINE)
    else:

        draw_line(Vector2.ZERO, local_target, od_glow, bg)
        draw_line(Vector2.ZERO, local_target, od_line, bw)
        if _vp > 0.4 or _od_laser:
            var core_col = Color(3.0, 2.5, 2.0, 0.5) if _od_laser else Color(3.0, 1.5, 0.8, 0.4)
            draw_line(Vector2.ZERO, local_target, core_col, maxf(1.0, bw * 0.3))
        if ship.laser_flash_timer > 0:
            var t = ship.laser_flash_timer / 0.1
            draw_circle(local_target, hr + t * 5, Color(ship.HIT_FLASH.r, ship.HIT_FLASH.g, ship.HIT_FLASH.b, t * 0.6))
        draw_circle(local_target, hr * 0.5, od_line)
        for mt in ship.multi_targets:
            var lt = mt - ship.global_position
            draw_line(Vector2.ZERO, lt, od_glow, bg * 0.8)
            draw_line(Vector2.ZERO, lt, od_line, bw * 0.8)
            draw_circle(lt, hr * 0.4, od_line)

func _draw_electric_arcs():
    for arc in ship.electric_arcs:
        var alpha = clampf(arc.timer / ship.ARC_DURATION, 0.0, 1.0)
        var local_from = arc.from - ship.global_position
        var local_to = arc.to - ship.global_position
        var seg_count = 4
        var perp = Vector2( - (local_to - local_from).y, (local_to - local_from).x).normalized()
        var prev = local_from
        for seg in range(seg_count):
            var t_seg = float(seg + 1) / float(seg_count)
            var next_pt = local_from.lerp(local_to, t_seg)
            if seg < seg_count - 1:
                var jitter = perp * sin(ship.ship_glow_phase * 20.0 + seg * 3.7) * (5.0 + _vp * 8.0)
                next_pt += jitter
            draw_line(prev, next_pt, Color(ship.ELECTRIC_ARC.r, ship.ELECTRIC_ARC.g, ship.ELECTRIC_ARC.b, alpha * 0.25), 6.0 + _vp * 4.0)
            draw_line(prev, next_pt, Color(ship.ELECTRIC_ARC.r, ship.ELECTRIC_ARC.g, ship.ELECTRIC_ARC.b, alpha * 0.9), 1.5 + _vp * 1.0)
            prev = next_pt
        var flash_r = (3.0 + _vp * 4.0) * alpha
        draw_circle(local_to, flash_r, Color(ship.ELECTRIC_ARC.r, ship.ELECTRIC_ARC.g, ship.ELECTRIC_ARC.b, alpha * 0.7))
        if _vp > 0.3:
            draw_circle(local_from, flash_r * 0.6, Color(ship.ELECTRIC_ARC.r, ship.ELECTRIC_ARC.g, ship.ELECTRIC_ARC.b, alpha * 0.4))

func _draw_chain_arcs():
    for arc in ship.chain_arcs:
        var alpha = clampf(arc.timer / ship.CHAIN_ARC_DURATION, 0.0, 1.0)
        var local_from = arc.from - ship.global_position
        var local_to = arc.to - ship.global_position
        var perp = Vector2( - (local_to - local_from).y, (local_to - local_from).x).normalized()
        var seg_count = 5
        var jitter_amp = 6.0 + _vp * 10.0
        var glow_w = 5.0 + _vp * 5.0
        var core_w = 1.5 + _vp * 1.0
        var prev = local_from
        for seg in range(seg_count):
            var t_seg = float(seg + 1) / float(seg_count)
            var next_pt = local_from.lerp(local_to, t_seg)
            if seg < seg_count - 1:
                var jitter = perp * sin(ship.ship_glow_phase * 18.0 + seg * 4.3 + alpha * 8.0) * jitter_amp
                next_pt += jitter
            draw_line(prev, next_pt, Color(ship.CHAIN_GLOW_COLOR.r, ship.CHAIN_GLOW_COLOR.g, ship.CHAIN_GLOW_COLOR.b, alpha * 0.3), glow_w)
            draw_line(prev, next_pt, Color(ship.CHAIN_LIGHTNING_COLOR.r, ship.CHAIN_LIGHTNING_COLOR.g, ship.CHAIN_LIGHTNING_COLOR.b, alpha), core_w)
            prev = next_pt
        var flash_r = (2.5 + _vp * 4.0) * alpha
        draw_circle(local_to, flash_r, Color(ship.CHAIN_LIGHTNING_COLOR.r, ship.CHAIN_LIGHTNING_COLOR.g, ship.CHAIN_LIGHTNING_COLOR.b, alpha * 0.7))
        if _vp > 0.3:
            draw_circle(local_from, flash_r * 0.5, Color(ship.CHAIN_LIGHTNING_COLOR.r, ship.CHAIN_LIGHTNING_COLOR.g, ship.CHAIN_LIGHTNING_COLOR.b, alpha * 0.4))

func _draw_drones():
    if not ship.drone_system:
        return
    var rot = ship.visual_rotation
    for i in range(ship.drone_system.positions.size()):
        var dpos = ship.drone_system.positions[i]


        var drone_pts = PackedVector2Array([
            dpos + Vector2(0, -6).rotated(rot), 
            dpos + Vector2(-4, 4).rotated(rot), 
            dpos + Vector2(4, 4).rotated(rot), 
        ])
        draw_colored_polygon(drone_pts, Color(0.02, 0.04, 0.03))
        for j in range(drone_pts.size()):
            draw_line(drone_pts[j], drone_pts[(j + 1) % drone_pts.size()], ship.DRONE_LINE, 1.5)

        var d_glow_a = 0.08 + sin(ship.ship_glow_phase + i * 2.0) * 0.04
        draw_circle(dpos, 10, Color(ship.DRONE_GLOW.r, ship.DRONE_GLOW.g, ship.DRONE_GLOW.b, d_glow_a))

        if ship.drone_system.visible_timers[i] > 0:
            var dt = ship.drone_system.targets[i] - ship.global_position
            var d_glow_w = 4.0 + _vp * 4.0
            var d_beam_w = 1.0 + _vp * 1.0
            draw_line(dpos, dt, ship.DRONE_LASER_GLOW, d_glow_w)
            draw_line(dpos, dt, ship.DRONE_LASER, d_beam_w)
            draw_circle(dt, 1.5 + _vp * 1.5, ship.DRONE_LASER)

func _draw_overheat():
    if ship.overheat_ratio > 0.01:
        draw_set_transform(Vector2.ZERO, 0.0)

        var bar_w = 40.0
        var bar_h = 6.0
        var bar_y = 22.0
        var bar_x = - bar_w * 0.5

        draw_rect(Rect2(bar_x - 1, bar_y - 1, bar_w + 2, bar_h + 2), 
            Color(0.0, 0.0, 0.0, 0.7))

        var fill_w = bar_w * ship.overheat_ratio
        var fill_col: Color
        if ship.overheat_ratio < 0.5:
            fill_col = Color(1.2, 0.7, 0.1, 0.9)
        elif ship.overheat_ratio < 0.8:
            var t = (ship.overheat_ratio - 0.5) / 0.3
            fill_col = Color(1.2, 0.7, 0.1).lerp(Color(1.5, 0.2, 0.05), t)
            fill_col.a = 0.9
        else:
            var pulse = (sin(ship.ship_glow_phase * 8.0) + 1.0) * 0.5
            fill_col = Color(1.8, 0.15, 0.05, 0.8 + pulse * 0.2)

        draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), fill_col)

        draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), 
            Color(1.0, 0.4, 0.1, 0.6), false, 1.5)


    var tint_strength = clampf((ship.overheat_ratio - 0.3) / 0.7, 0.0, 1.0)
    if tint_strength > 0:
        ship.self_modulate = Color(1.0, 1.0 - tint_strength * 0.5, 1.0 - tint_strength * 0.7)
    else:
        ship.self_modulate = Color(1.0, 1.0, 1.0)







func _star_hash(cx: int, cy: int, idx: int) -> float:
    var h = (cx * 374761 + cy * 668265 + idx * 1301081) & 2147483647
    h = ((h >> 16) ^ h) * 73244475
    h = ((h >> 16) ^ h) & 2147483647
    return float(h) / float(2147483647)

func _draw_star_background():

    var cam_2d = ship.get_viewport().get_camera_2d()
    var cam_global = cam_2d.global_position if cam_2d else ship.global_position
    var cam_pos = cam_global


    var draw_offset = cam_global - ship.global_position
    var vp_size = ship.get_viewport_rect().size

    var half_w = vp_size.x * 0.5 + 200.0
    var half_h = vp_size.y * 0.5 + 200.0
    var time = ship.ship_glow_phase

    for layer in STAR_LAYERS:
        var px: float = layer.parallax
        var cell_sz: float = layer.cell
        var star_count: int = layer.count


        var offset_x = cam_pos.x * px
        var offset_y = cam_pos.y * px


        var cx_min = int(floor((offset_x - half_w) / cell_sz))
        var cx_max = int(floor((offset_x + half_w) / cell_sz))
        var cy_min = int(floor((offset_y - half_h) / cell_sz))
        var cy_max = int(floor((offset_y + half_h) / cell_sz))

        for cx in range(cx_min, cx_max + 1):
            for cy in range(cy_min, cy_max + 1):
                for i in range(star_count):

                    var sx = cx * cell_sz + _star_hash(cx, cy, i * 3) * cell_sz
                    var sy = cy * cell_sz + _star_hash(cx, cy, i * 3 + 1) * cell_sz


                    var local_x = sx - offset_x
                    var local_y = sy - offset_y


                    if abs(local_x) > half_w or abs(local_y) > half_h:
                        continue


                    var h2 = _star_hash(cx, cy, i * 3 + 2)
                    var sz = lerpf(layer.sz_min, layer.sz_max, h2)
                    var base_a = lerpf(layer.a_min, layer.a_max, _star_hash(cy, cx, i))


                    var twinkle = 1.0
                    if h2 > 0.6:
                        twinkle = 0.7 + 0.3 * sin(time * (1.5 + h2 * 2.0) + float(cx * 7 + cy * 13))
                    var alpha = base_a * twinkle


                    var col_idx = int(h2 * 3.99)
                    var col = STAR_COLORS[col_idx]
                    col.a = alpha


                    var pos = Vector2(local_x, local_y) + draw_offset
                    if sz > 1.2:

                        draw_circle(pos, sz * 1.8, Color(col.r, col.g, col.b, alpha * 0.2))
                        draw_circle(pos, sz, col)
                    else:
                        draw_circle(pos, sz, col)
