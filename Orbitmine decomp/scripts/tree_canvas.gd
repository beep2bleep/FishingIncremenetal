extends Control








func _draw():
    var menu = get_parent()
    if not menu or not menu.has_method("get_connection_lines"):
        return

    var lines: Array = menu.get_connection_lines()



    var bg_color: = Color(0.02, 0.02, 0.06, 1.0)
    for line_data in lines:
        var color: Color = line_data.color
        var width: float = line_data.width

        if line_data.get("type", "line") == "arc":

            var center: Vector2 = line_data.center
            var radius: float = line_data.radius
            var a_start: float = line_data.angle_start
            var a_end: float = line_data.angle_end
            var segments: int = 16
            draw_arc(center, radius, a_start, a_end, segments, bg_color, width + 2.0, true)
            draw_arc(center, radius, a_start, a_end, segments, color, width, true)
        else:

            var from: Vector2 = line_data.from
            var to: Vector2 = line_data.to
            draw_line(from, to, bg_color, width + 2.0, true)
            draw_line(from, to, color, width, true)
