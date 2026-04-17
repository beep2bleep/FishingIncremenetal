extends Control






const FUEL_WARN_THRESHOLD: = 0.2
const LAYERS: = 20
const MAX_BORDER: = 180.0
var warn_timer: float = 0.0

func _process(delta):
    var fuel_ratio = Global.get_fuel_ratio()
    if fuel_ratio <= FUEL_WARN_THRESHOLD:
        warn_timer += delta
        queue_redraw()
    elif warn_timer > 0:
        warn_timer = 0.0
        queue_redraw()

func _draw():
    var fuel_ratio = Global.get_fuel_ratio()
    if fuel_ratio > FUEL_WARN_THRESHOLD:
        return


    var intensity = 1.0 - (fuel_ratio / FUEL_WARN_THRESHOLD)

    var pulse = 0.7 + 0.3 * sin(warn_timer * 3.5)
    var base_alpha = intensity * pulse * 0.7

    var vp = get_viewport_rect().size
    var border = MAX_BORDER * (0.5 + intensity * 0.5)


    for i in range(LAYERS):
        var t = float(i) / float(LAYERS)
        var inset = border * t

        var layer_alpha = base_alpha * pow(1.0 - t, 2.5)
        if layer_alpha < 0.005:
            continue

        var color = Color(0.9, 0.05, 0.02, layer_alpha)
        var rect = Rect2(inset, inset, vp.x - inset * 2, vp.y - inset * 2)

        draw_rect(rect, color, false, border / LAYERS + 1.0)
