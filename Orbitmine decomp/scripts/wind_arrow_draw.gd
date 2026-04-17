extends Control






var direction: Vector2 = Vector2.ZERO
var warn_time: float = 0.0

func _draw():
    if direction.length() < 0.1:
        return

    var center = size * 0.5
    var arrow_len = 45.0
    var arrow_end = center + direction * arrow_len
    var arrow_start = center - direction * arrow_len


    var urgency = 1.0 - clampf(warn_time, 0.0, 1.0)
    var color = Color(1.0, 1.0 - urgency * 0.7, 0.2 - urgency * 0.2, 0.9)


    draw_line(arrow_start, arrow_end, color, 4.0)


    var head_size = 16.0
    var perp = Vector2( - direction.y, direction.x)
    var tip = arrow_end
    var left = tip - direction * head_size + perp * head_size * 0.5
    var right = tip - direction * head_size - perp * head_size * 0.5
    draw_colored_polygon([tip, left, right], color)


    var font = ThemeDB.fallback_font
    if font:
        var text_pos = center + Vector2(-20, - arrow_len - 15)
        draw_string(font, text_pos, "💨 강풍!", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, color)
