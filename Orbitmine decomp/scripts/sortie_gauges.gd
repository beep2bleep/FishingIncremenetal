extends Control







const FUEL_CENTER: = Vector2(75, -195)
const CARGO_CENTER: = Vector2(75, -70)
const RADIUS: = 57.0
const THICKNESS: = 10.0
const BG_ALPHA: = 0.15
const ICON_SIZE: = 20


const FUEL_COLOR: = Color(0.2, 0.85, 0.3)
const FUEL_WARN: = Color(1.0, 0.8, 0.2)
const FUEL_DANGER: = Color(1.0, 0.2, 0.1)
const CARGO_COLOR: = Color(0.2, 0.7, 1.0)
const CARGO_WARN: = Color(1.0, 0.8, 0.2)
const CARGO_FULL: = Color(1.0, 0.2, 0.1)


var warning_timer: float = 0.0

func _process(delta):
    warning_timer += delta * 6.0
    queue_redraw()

func _draw():

    var vp_size = get_viewport_rect().size
    var base = Vector2(0, vp_size.y)

    _draw_fuel_gauge(base + FUEL_CENTER)
    _draw_cargo_gauge(base + CARGO_CENTER)

func _draw_fuel_gauge(center: Vector2):
    var ratio = Global.get_fuel_ratio()


    var color: Color
    if ratio <= 0.1:
        var blink = 0.5 + 0.5 * sin(warning_timer)
        color = FUEL_DANGER
        color.a = 0.5 + blink * 0.5
    elif ratio <= 0.3:
        color = FUEL_DANGER
    elif ratio <= 0.5:
        color = FUEL_WARN
    else:
        color = FUEL_COLOR


    draw_arc(center, RADIUS, 0, TAU, 48, Color(FUEL_COLOR, BG_ALPHA), THICKNESS)


    if ratio > 0.001:
        var start_angle = - PI * 0.5
        var end_angle = start_angle + TAU * ratio
        draw_arc(center, RADIUS, start_angle, end_angle, int(48 * ratio) + 4, color, THICKNESS)


    _draw_text(center + Vector2(0, 6), "⛽", 18, color)


    var effective_rate = Global.fuel_rate * Global.fuel_efficiency
    var real_secs = Global.fuel_current / maxf(effective_rate, 0.001)
    _draw_text(center + Vector2(RADIUS + 14, 5), "%.0f" % real_secs, 14, Color(0.7, 0.7, 0.7))

func _draw_cargo_gauge(center: Vector2):
    var ratio = 0.0
    if Global.cargo_capacity > 0:
        ratio = clampf(float(Global.sortie_ore_count) / Global.cargo_capacity, 0.0, 1.0)


    var color: Color
    if ratio >= 1.0:
        color = CARGO_FULL
    elif ratio >= 0.8:
        color = CARGO_WARN
    else:
        color = CARGO_COLOR


    draw_arc(center, RADIUS, 0, TAU, 48, Color(CARGO_COLOR, BG_ALPHA), THICKNESS)


    if ratio > 0.001:
        var start_angle = - PI * 0.5
        var end_angle = start_angle + TAU * ratio
        draw_arc(center, RADIUS, start_angle, end_angle, int(48 * ratio) + 4, color, THICKNESS)


    _draw_text(center + Vector2(0, 6), "📦", 18, color)


    var ore_text = "%d/%d" % [Global.sortie_ore_count, int(Global.cargo_capacity)]
    var sell_val = Global.sortie_resources * Global.ore_sell_rate
    _draw_text(center + Vector2(RADIUS + 14, -1), ore_text, 13, Color(0.7, 0.7, 0.7))
    _draw_text(center + Vector2(RADIUS + 14, 15), "💰 " + Global.format_number(sell_val), 11, Color(1.0, 0.8, 0.3, 0.7))

func _draw_text(pos: Vector2, text: String, size: int, color: Color):
    var font = ThemeDB.fallback_font
    if font:
        draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
