extends Control







const CYAN: = Color(0.2, 0.85, 1.0)
const ORANGE: = Color(1.0, 0.55, 0.15)
const GREEN: = Color(0.3, 1.0, 0.5)
const WHITE: = Color(0.85, 0.88, 0.92)
const DIM: = Color(0.4, 0.45, 0.5)
const GLOW_CYAN: = Color(0.2, 0.85, 1.0, 0.15)
const GLOW_ORANGE: = Color(1.0, 0.55, 0.15, 0.15)
const GLOW_GREEN: = Color(0.3, 1.0, 0.5, 0.15)

var line_width: float = 2.0
var glow_width: float = 6.0

func _draw():
    var vp = get_viewport_rect().size
    var panel_w = 180.0
    var panel_h = 150.0
    var gap = 60.0
    var total_w = panel_w * 3 + gap * 2
    var start_x = (vp.x - total_w) / 2.0
    var start_y = 40.0


    var p1 = Vector2(start_x + panel_w * 0.5, start_y)
    _draw_move_panel(p1, panel_w, panel_h, CYAN, GLOW_CYAN)


    var p2 = Vector2(start_x + panel_w * 1.5 + gap, start_y)
    _draw_attack_panel(p2, panel_w, panel_h, ORANGE, GLOW_ORANGE)


    var p3 = Vector2(start_x + panel_w * 2.5 + gap * 2, start_y)
    _draw_return_panel(p3, panel_w, panel_h, GREEN, GLOW_GREEN)




func _draw_move_panel(center: Vector2, w: float, h: float, col: Color, glow: Color):
    var title_y = center.y + 5
    var draw_y = center.y + 35


    _draw_text_centered(center.x, title_y, "MOVE", 16, col)


    var cursor_pos = Vector2(center.x - 50, draw_y + 30)
    _draw_cursor(cursor_pos, col, glow)


    _draw_dashed_arrow(cursor_pos + Vector2(18, 0), Vector2(center.x + 20, draw_y + 30), col, glow)


    var ship_pos = Vector2(center.x + 40, draw_y + 30)
    _draw_ship(ship_pos, col, glow, 0.0)


    _draw_text_centered(center.x, draw_y + 75, "마우스로 조종", 12, DIM)




func _draw_attack_panel(center: Vector2, w: float, h: float, col: Color, glow: Color):
    var title_y = center.y + 5
    var draw_y = center.y + 35

    _draw_text_centered(center.x, title_y, "ATTACK", 16, col)


    var ship_pos = Vector2(center.x - 45, draw_y + 15)
    _draw_ship(ship_pos, col, glow, PI * 0.15)


    var laser_start = ship_pos + Vector2(12, 8)
    var laser_end = Vector2(center.x + 25, draw_y + 45)

    draw_line(laser_start, laser_end, glow, glow_width)

    draw_line(laser_start, laser_end, col, line_width)

    draw_circle(laser_end, 4, Color(col.r, col.g, col.b, 0.5))


    var planet_pos = Vector2(center.x + 30, draw_y + 50)
    _draw_planet(planet_pos, 22.0, col, glow)

    _draw_text_centered(center.x, draw_y + 75, "자동 공격", 12, DIM)




func _draw_return_panel(center: Vector2, w: float, h: float, col: Color, glow: Color):
    var title_y = center.y + 5
    var draw_y = center.y + 35

    _draw_text_centered(center.x, title_y, "RETURN", 16, col)


    var mouse_pos = Vector2(center.x - 35, draw_y + 35)
    _draw_mouse_right_click(mouse_pos, col, glow)


    var arrow_start = Vector2(center.x + 20, draw_y + 55)
    var arrow_end = Vector2(center.x + 20, draw_y + 10)
    draw_line(arrow_start, arrow_end, glow, glow_width)
    draw_line(arrow_start, arrow_end, col, line_width)

    draw_line(arrow_end, arrow_end + Vector2(-6, 10), col, line_width)
    draw_line(arrow_end, arrow_end + Vector2(6, 10), col, line_width)


    var ship_pos = Vector2(center.x + 40, draw_y + 15)
    _draw_ship(ship_pos, col, glow, - PI * 0.5)

    for i in range(3):
        var trail_y = ship_pos.y + 15 + i * 8
        var alpha = 0.6 - i * 0.2
        draw_circle(Vector2(ship_pos.x, trail_y), 2.0 - i * 0.4, Color(col.r, col.g, col.b, alpha))

    _draw_text_centered(center.x, draw_y + 75, "우클릭 귀환", 12, DIM)




func _draw_ship(pos: Vector2, col: Color, glow: Color, angle: float):
    var ship_size = 12.0

    var points = PackedVector2Array([
        Vector2(0, - ship_size), 
        Vector2( - ship_size * 0.6, ship_size * 0.5), 
        Vector2(ship_size * 0.6, ship_size * 0.5), 
    ])


    var rotated = PackedVector2Array()
    for p in points:
        rotated.append(p.rotated(angle) + pos)


    var glow_points = rotated.duplicate()
    glow_points.append(rotated[0])
    draw_polyline(glow_points, glow, glow_width)


    var main_points = rotated.duplicate()
    main_points.append(rotated[0])
    draw_polyline(main_points, col, line_width)


    draw_circle(rotated[0], 2.5, col)




func _draw_cursor(pos: Vector2, col: Color, glow: Color):
    var cursor_points = PackedVector2Array([
        Vector2(0, 0), 
        Vector2(0, 20), 
        Vector2(5, 15), 
        Vector2(10, 22), 
        Vector2(12, 20), 
        Vector2(8, 13), 
        Vector2(14, 13), 
    ])

    var shifted = PackedVector2Array()
    for p in cursor_points:
        shifted.append(p + pos)


    var closed = shifted.duplicate()
    closed.append(shifted[0])
    draw_polyline(closed, glow, glow_width)
    draw_polyline(closed, col, line_width)




func _draw_mouse_right_click(pos: Vector2, col: Color, glow: Color):
    var w = 20.0
    var h = 30.0


    var rect = Rect2(pos.x - w / 2, pos.y - h / 2, w, h)

    draw_rect(rect, glow, false, glow_width)

    draw_rect(rect, col * 0.5, false, line_width)


    draw_line(
        Vector2(pos.x, pos.y - h / 2), 
        Vector2(pos.x, pos.y - h / 2 + h * 0.4), 
        col * 0.5, line_width
    )


    var right_rect = Rect2(pos.x + 1, pos.y - h / 2 + 1, w / 2 - 2, h * 0.4 - 1)
    draw_rect(right_rect, Color(col.r, col.g, col.b, 0.35), true)
    draw_rect(right_rect, col, false, line_width)


    _draw_text_centered(pos.x + w / 4, pos.y - h / 2 + h * 0.2 - 3, "R", 9, col)




func _draw_planet(pos: Vector2, radius: float, col: Color, glow: Color):

    draw_arc(pos, radius + 2, 0, TAU, 32, glow, glow_width)

    draw_arc(pos, radius, 0, TAU, 32, col * 0.6, line_width)

    draw_circle(pos, radius - 1, Color(col.r, col.g, col.b, 0.08))

    draw_arc(pos + Vector2(-6, -4), 4, 0, TAU, 12, col * 0.3, 1.0)
    draw_arc(pos + Vector2(7, 5), 3, 0, TAU, 12, col * 0.3, 1.0)
    draw_arc(pos + Vector2(-2, 8), 2.5, 0, TAU, 12, col * 0.3, 1.0)




func _draw_dashed_arrow(from: Vector2, to: Vector2, col: Color, glow: Color):
    var dir = (to - from).normalized()
    var length = from.distance_to(to)
    var dash_len = 6.0
    var gap_len = 4.0
    var d = 0.0

    while d < length - 10:
        var seg_start = from + dir * d
        var seg_end = from + dir * minf(d + dash_len, length - 10)
        draw_line(seg_start, seg_end, col * 0.7, line_width)
        d += dash_len + gap_len


    var tip = to
    var perp = dir.rotated(PI * 0.5)
    draw_line(tip, tip - dir * 8 + perp * 4, col, line_width)
    draw_line(tip, tip - dir * 8 - perp * 4, col, line_width)




func _draw_text_centered(x: float, y: float, text: String, font_size: int, col: Color):
    var font = ThemeDB.fallback_font
    var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
    draw_string(font, Vector2(x - text_size.x / 2, y + text_size.y / 2), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, col)
