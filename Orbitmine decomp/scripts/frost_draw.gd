extends Control






var frost_intensity: float = 0.0
var frost_time: float = 0.0


const MAX_SNOWFLAKES: int = 80
var snowflakes: Array = []
var _snow_initialized: bool = false

func _init_snowflakes():
    var rng = RandomNumberGenerator.new()
    rng.seed = 99999
    snowflakes.clear()
    for i in range(MAX_SNOWFLAKES):
        snowflakes.append({
            "x": rng.randf(), 
            "y": rng.randf(), 
            "size": rng.randf_range(1.5, 4.5), 
            "speed": rng.randf_range(0.02, 0.08), 
            "sway_offset": rng.randf() * TAU, 
            "sway_amount": rng.randf_range(0.005, 0.02), 
            "alpha": rng.randf_range(0.3, 0.8), 
        })
    _snow_initialized = true

func _draw():
    var w = size.x
    var h = size.y
    if w < 10 or h < 10 or frost_intensity < 0.01:
        return

    if not _snow_initialized:
        _init_snowflakes()

    var t = frost_intensity


    var pulse = (sin(frost_time * 2.0) + 1.0) * 0.5 * 0.12
    var alpha_base = t * (0.45 + pulse)


    var thickness = lerpf(50.0, 160.0, t)
    var col = Color(0.4, 0.75, 1.0)


    var steps: int = 20
    var step_h = thickness / float(steps)

    for i in range(steps):
        var ratio = float(i) / float(steps)
        var fade = (1.0 - ratio) * (1.0 - ratio)
        var fade_rev = ratio * ratio
        var a_top = alpha_base * fade * 0.9
        var a_bot = alpha_base * fade_rev * 0.9
        var d = step_h * float(i)

        if a_top >= 0.003:
            draw_rect(Rect2(0, d, w, step_h), Color(col.r, col.g, col.b, a_top))
        if a_bot >= 0.003:
            draw_rect(Rect2(0, h - thickness + d, w, step_h), Color(col.r, col.g, col.b, a_bot))


    var snow_col = Color(0.85, 0.92, 1.0)
    var active_count = int(lerpf(8, MAX_SNOWFLAKES, t))

    for i in range(active_count):
        var s = snowflakes[i]

        s["y"] += s["speed"] * 0.016
        s["x"] += sin(frost_time * 1.5 + s["sway_offset"]) * s["sway_amount"] * 0.016

        if s["y"] > 1.05:
            s["y"] = -0.05
            s["x"] = fmod(s["x"] + 0.3, 1.0)
        if s["x"] < -0.02:
            s["x"] += 1.04
        elif s["x"] > 1.02:
            s["x"] -= 1.04

        var px = s["x"] * w
        var py = s["y"] * h
        var sa = s["alpha"] * t


        draw_circle(Vector2(px, py), s["size"] * 1.8, 
            Color(snow_col.r, snow_col.g, snow_col.b, sa * 0.15))
        draw_circle(Vector2(px, py), s["size"], 
            Color(snow_col.r, snow_col.g, snow_col.b, sa))
