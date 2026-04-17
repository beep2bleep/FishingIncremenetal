extends Control






const BG_COLOR: = Color(0.01, 0.01, 0.03)
const TEXT_COLOR: = Color(0.85, 0.88, 0.92)
const DIM_COLOR: = Color(0.45, 0.45, 0.5)
const CYAN: = Color(0.2, 0.85, 1.0)


const BLOCK_FILL: = Color(0.025, 0.025, 0.035)
const GRID_LINE_C: = Color(0.08, 0.09, 0.12, 0.25)
const CORE_EDGE: = Color(2.5, 0.3, 0.08)
const CORE_FILL: = Color(0.06, 0.01, 0.01)
const SHIP_LINE: = Color(0.5, 1.8, 2.0)
const SHIP_FILL: = Color(0.02, 0.04, 0.06)
const ENGINE_C: = Color(0.5, 1.8, 2.0, 0.9)

const TIER = {
    1: Color(0.4, 1.5, 2.0), 
    3: Color(0.7, 1.4, 1.4), 
    5: Color(1.4, 1.3, 0.5), 
    6: Color(1.7, 1.0, 0.3), 
    8: Color(2.0, 0.6, 0.15), 
    10: Color(2.0, 0.15, 0.05), 
}


var pages_text: Array = [
    "행성은 산산조각이 났다.\n당신이 바라던 대로.", 
    "마침내 눈부신 빛은 사라졌다.\n고요한 어둠... 당신이 원하던 평화.", 
    "그런데 이상하다.\n가슴 한쪽이... 허전하다.", 
    "그리움? 후회?\n아니다. 분노가 아직 남아있다.\n한 번으로는 부족했다.", 
    "당신은 행성을 다시 만들기로 했다.\n부수기 위해.\n언제까지고, 끝없이.", 
]

var current_page: int = -1
var is_animating: bool = false
var page_time: float = 0.0
var gt: float = 0.0


var _stars: Array = []


var _debris: Array = []


var text_label: Label
var skip_btn: Button
var hint_label: Label

func _ready():
    RenderingServer.set_default_clear_color(BG_COLOR)
    _gen_stars()
    _gen_debris()
    _build_ui()
    _show_next_page()

func _gen_stars():
    var rng = RandomNumberGenerator.new()
    rng.seed = 54321
    for i in range(200):
        _stars.append(Vector4(
            rng.randf(), rng.randf(), 
            rng.randf_range(0.04, 0.25), 
            1.0 if rng.randf() > 0.08 else 2.0
        ))

func _gen_debris():
    var rng = RandomNumberGenerator.new()
    rng.seed = 11111
    for i in range(60):
        var angle = rng.randf_range(0, TAU)
        var speed = rng.randf_range(15, 80)

        var tier_keys = [1, 3, 5, 6, 8, 10]
        var tc = TIER[tier_keys[rng.randi() % tier_keys.size()]]
        _debris.append({
            "cx": 0.0, "cy": 0.0, 
            "vx": cos(angle) * speed, 
            "vy": sin(angle) * speed, 
            "size": rng.randf_range(4, 14), 
            "color": tc, 
            "rot": rng.randf_range(0, TAU), 
            "rot_speed": rng.randf_range(-3.0, 3.0), 
        })

func _process(delta):
    gt += delta
    page_time += delta
    queue_redraw()




func _draw():
    var vp = get_viewport_rect().size
    if vp.x < 10:
        return

    draw_rect(Rect2(0, 0, vp.x, vp.y), BG_COLOR)


    for s in _stars:
        var sx = s.x * vp.x
        var sy = s.y * vp.y
        var sb = s.z
        var col = Color(sb, sb, sb + 0.02)
        if s.w < 1.5:
            draw_rect(Rect2(sx, sy, 1, 1), col)
        else:
            draw_rect(Rect2(sx, sy, 2, 2), col)

    match current_page:
        0: _draw_page1(vp)
        1: _draw_page2(vp)
        2: _draw_page3(vp)
        3: _draw_page4(vp)
        4: _draw_page5(vp)




func _glow(center: Vector2, radius: float, color: Color, alpha: float = 1.0):
    for i in range(10):
        var t = float(i) / 10.0
        var r = radius * (1.0 - t * 0.6)
        var a = alpha * 0.1 * (1.0 - t)
        draw_circle(center, r, Color(color.r, color.g, color.b, a))

func _small_planet(cx: float, cy: float, r: float, alpha: float = 1.0):
    draw_circle(Vector2(cx, cy), r, Color(0.02, 0.04, 0.02, alpha))
    var bs = max(4.0, r * 0.2)
    var bx = cx - r + 2
    while bx < cx + r - 2:
        var by = cy - r + 2
        while by < cy + r - 2:
            var ddx = bx + bs * 0.5 - cx
            var ddy = by + bs * 0.5 - cy
            if ddx * ddx + ddy * ddy < (r - 3) * (r - 3):
                draw_rect(Rect2(bx, by, bs, bs), 
                    Color(0.04, 0.08, 0.04, alpha * 0.5), false, 0.5)
            by += bs
        bx += bs
    draw_arc(Vector2(cx, cy), r + 2, 0, TAU, 48, 
        Color(0.1, 0.3, 0.15, alpha * 0.4), 4.0)
    draw_arc(Vector2(cx, cy), r, 0, TAU, 48, 
        Color(0.2, 0.7, 0.3, alpha), 2.0)

func _house(cx: float, base_y: float, sc: float, alpha: float = 1.0):
    var hx = cx - 8.0 * sc
    var hy = base_y
    var hw = 16.0 * sc
    var hh = 12.0 * sc
    var lc = Color(SHIP_LINE.r, SHIP_LINE.g, SHIP_LINE.b, alpha)
    var fc = Color(SHIP_FILL, alpha)
    var gc = Color(1.5, 1.3, 0.3, alpha)
    var w = max(1.0, 1.5 * sc)

    draw_rect(Rect2(hx, hy, hw, hh), fc)
    draw_rect(Rect2(hx, hy, hw, hh), lc, false, w)
    var roof = PackedVector2Array([
        Vector2(hx - 2 * sc, hy), Vector2(cx, hy - 9 * sc), Vector2(hx + hw + 2 * sc, hy)])
    draw_colored_polygon(roof, fc)
    draw_line(roof[0], roof[1], lc, w)
    draw_line(roof[1], roof[2], lc, w)

    draw_rect(Rect2(hx + 4 * sc, hy + 3 * sc, 6 * sc, 5 * sc), Color(0.03, 0.03, 0.05, alpha))
    draw_rect(Rect2(hx + 4 * sc, hy + 3 * sc, 6 * sc, 5 * sc), 
        Color(0.2, 0.6, 0.8, alpha * 0.5), false, w * 0.8)

func _player(cx: float, cy: float, sc: float, alpha: float = 1.0, 
        angry: bool = false, sad: bool = false):
    var lc = Color(SHIP_LINE.r, SHIP_LINE.g, SHIP_LINE.b, alpha)
    var rc = Color(2.0, 0.3, 0.1, alpha)
    var w = max(1.0, 1.5 * sc)
    var half = 7.0 * sc

    var body = Rect2(cx - half, cy - half, half * 2, half * 2)
    draw_rect(body, Color(SHIP_FILL, alpha))
    draw_rect(body, lc, false, w)

    var eye_y = cy - 2.0 * sc
    if angry:
        draw_line(Vector2(cx - 4 * sc, eye_y - 2 * sc), Vector2(cx - 1.5 * sc, eye_y), rc, w)
        draw_line(Vector2(cx + 1.5 * sc, eye_y), Vector2(cx + 4 * sc, eye_y - 2 * sc), rc, w)
    elif sad:

        var sc2 = Color(0.3, 0.6, 0.8, alpha)
        draw_line(Vector2(cx - 4 * sc, eye_y), Vector2(cx - 1.5 * sc, eye_y - 1.5 * sc), sc2, w)
        draw_line(Vector2(cx + 1.5 * sc, eye_y - 1.5 * sc), Vector2(cx + 4 * sc, eye_y), sc2, w)
    else:
        draw_rect(Rect2(cx - 4 * sc, eye_y - 1 * sc, 2 * sc, 2 * sc), lc)
        draw_rect(Rect2(cx + 2 * sc, eye_y - 1 * sc, 2 * sc, 2 * sc), lc)

func _planet(cx: float, cy: float, radius: float, bs: float, alpha: float = 1.0):
    var r2 = radius * radius
    var bx = cx - radius
    while bx < cx + radius:
        var by = cy - radius
        while by < cy + radius:
            var dx = bx + bs * 0.5 - cx
            var dy = by + bs * 0.5 - cy
            var d2 = dx * dx + dy * dy
            if d2 < r2:
                var depth = sqrt(d2) / radius
                var rect = Rect2(bx + 1, by + 1, bs - 2, bs - 2)
                draw_rect(rect, Color(BLOCK_FILL, alpha))
                draw_rect(rect, Color(GRID_LINE_C.r, GRID_LINE_C.g, GRID_LINE_C.b, 
                    GRID_LINE_C.a * alpha), false, 0.5)
                var tc: Color
                if depth < 0.15: tc = TIER[10]
                elif depth < 0.3: tc = TIER[8]
                elif depth < 0.5: tc = TIER[6]
                elif depth < 0.7: tc = TIER[5]
                elif depth < 0.85: tc = TIER[3]
                else: tc = TIER[1]
                if depth > 0.85:
                    var ea = alpha * clampf((depth - 0.85) / 0.15, 0.0, 1.0)
                    var ec = Color(tc.r, tc.g, tc.b, ea)
                    var norm = Vector2(dx, dy).normalized()
                    if abs(norm.x) > abs(norm.y):
                        var lx = bx + bs - 1 if norm.x > 0 else bx + 1
                        draw_line(Vector2(lx, by + 1), Vector2(lx, by + bs - 1), ec, 2.0)
                    else:
                        var ly = by + bs - 1 if norm.y > 0 else by + 1
                        draw_line(Vector2(bx + 1, ly), Vector2(bx + bs - 1, ly), ec, 2.0)
                if depth < 0.5:
                    var ga = (0.5 - depth) * 0.06 * alpha
                    draw_rect(rect, Color(tc.r * 0.12, tc.g * 0.12, tc.b * 0.12, ga))
            by += bs
        bx += bs

func _core(cx: float, cy: float, size: int, bs: float, alpha: float = 1.0):
    var half = size / 2
    for dx in range( - half, half):
        for dy in range( - half, half):
            var bx = cx + dx * bs - bs * 0.5
            var by = cy + dy * bs - bs * 0.5
            draw_rect(Rect2(bx + 1, by + 1, bs - 2, bs - 2), 
                Color(CORE_FILL, alpha))
            var beat = abs(sin(gt * 2.5 * PI))
            var beat_a = beat * beat * 0.15 * alpha
            draw_rect(Rect2(bx + 1, by + 1, bs - 2, bs - 2), 
                Color(CORE_EDGE.r * 0.15, CORE_EDGE.g * 0.15, CORE_EDGE.b * 0.15, beat_a))
            var edge_w = 2.0 + beat * 1.2
            draw_rect(Rect2(bx + 1, by + 1, bs - 2, bs - 2), 
                Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b, alpha), false, edge_w)




func _draw_page1(vp: Vector2):
    var t = page_time
    var center_x = vp.x * 0.55
    var center_y = vp.y * 0.42


    if t < 0.8:
        var flash_a = clampf(1.0 - t / 0.8, 0.0, 1.0)
        var flash_r = 30.0 + t * 200.0
        _glow(Vector2(center_x, center_y), flash_r, 
            Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b), flash_a * 0.8)


    var spread = clampf(t / 0.5, 0.0, 1.0)
    var fade_start = 3.0

    for d in _debris:
        var dx = d.vx * t * spread
        var dy = d.vy * t * spread
        var px = center_x + dx
        var py = center_y + dy


        if px < -50 or px > vp.x + 50 or py < -50 or py > vp.y + 50:
            continue

        var alpha = 1.0
        if t > fade_start:
            alpha = clampf(1.0 - (t - fade_start) / 2.0, 0.0, 1.0)

        var rot = d.rot + d.rot_speed * t
        var half = d.size * 0.5


        var cos_r = cos(rot)
        var sin_r = sin(rot)
        var pts = PackedVector2Array()
        for corner in [Vector2( - half, - half), Vector2(half, - half), 
                       Vector2(half, half), Vector2( - half, half)]:
            pts.append(Vector2(
                corner.x * cos_r - corner.y * sin_r + px, 
                corner.x * sin_r + corner.y * cos_r + py))

        draw_colored_polygon(pts, Color(BLOCK_FILL.r, BLOCK_FILL.g, BLOCK_FILL.b, alpha))
        for i in range(4):
            draw_line(pts[i], pts[(i + 1) % 4], 
                Color(d.color.r, d.color.g, d.color.b, alpha), 1.5)


    if t < 5.0:
        var core_alpha = clampf(1.0 - t / 5.0, 0.0, 1.0)
        for i in range(4):
            var angle = TAU / 4.0 * i + 0.3
            var dist = t * 8.0
            var cx = center_x + cos(angle) * dist
            var cy = center_y + sin(angle) * dist
            var cs = 8.0
            draw_rect(Rect2(cx - cs / 2, cy - cs / 2, cs, cs), 
                Color(CORE_FILL.r, CORE_FILL.g, CORE_FILL.b, core_alpha))
            draw_rect(Rect2(cx - cs / 2, cy - cs / 2, cs, cs), 
                Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b, core_alpha), false, 2.0)


    if t < 2.0:
        var ring_r = t * 250.0
        var ring_a = clampf(1.0 - t / 2.0, 0.0, 1.0) * 0.5
        draw_arc(Vector2(center_x, center_y), ring_r, 0, TAU, 48, 
            Color(TIER[6].r, TIER[6].g, TIER[6].b, ring_a), 2.0)
        if t > 0.3:
            var ring2_r = (t - 0.3) * 200.0
            var ring2_a = clampf(1.0 - (t - 0.3) / 1.5, 0.0, 1.0) * 0.3
            draw_arc(Vector2(center_x, center_y), ring2_r, 0, TAU, 48, 
                Color(TIER[1].r, TIER[1].g, TIER[1].b, ring2_a), 1.5)

    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), Color(0.08, 0.3, 0.4, 0.5), false, 2.0)




func _draw_page2(vp: Vector2):
    var t = page_time


    var extra_alpha = clampf(t / 2.0, 0.0, 1.0)
    var rng = RandomNumberGenerator.new()
    rng.seed = 88888
    for i in range(80):
        var sx = rng.randf_range(0, vp.x)
        var sy = rng.randf_range(0, vp.y * 0.72)
        var sb = rng.randf_range(0.08, 0.35) * extra_alpha

        sb *= (1.0 + sin(gt * 2.0 + i * 1.7) * 0.3)
        draw_rect(Rect2(sx, sy, 2, 2), Color(sb, sb, sb + 0.03))


    var sm_cx = vp.x * 0.25
    var sm_cy = vp.y * 0.58
    _small_planet(sm_cx, sm_cy, 40.0)
    _house(sm_cx, sm_cy - 42, 1.2)


    var px = sm_cx + 28
    var py = sm_cy - 46
    _player(px, py, 1.0, 1.0, false, false)


    var ghost_cx = vp.x * 0.72
    var ghost_cy = vp.y * 0.42
    if t < 4.0:
        var dust_a = clampf(0.06 - t * 0.015, 0.0, 0.06)
        draw_circle(Vector2(ghost_cx, ghost_cy), 100, Color(0.3, 0.15, 0.05, dust_a))

    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), Color(0.08, 0.3, 0.4, 0.5), false, 2.0)




func _draw_page3(vp: Vector2):
    var t = page_time


    var sm_cx = vp.x * 0.3
    var sm_cy = vp.y * 0.55
    _small_planet(sm_cx, sm_cy, 45.0)
    _house(sm_cx, sm_cy - 47, 1.4)


    var sad_t = clampf((t - 1.0) / 1.5, 0.0, 1.0)
    var px = sm_cx + 32
    var py = sm_cy - 50
    _player(px, py, 1.1, 1.0, false, sad_t > 0.5)


    var look_a = clampf((t - 0.5) / 1.0, 0.0, 1.0) * 0.15
    var look_target = Vector2(vp.x * 0.72, vp.y * 0.42)

    var look_start = Vector2(px + 8, py)
    var dir = (look_target - look_start).normalized()
    var dash_len = 8.0
    var gap_len = 6.0
    var total_dist = look_start.distance_to(look_target)
    var pos = 0.0
    while pos < total_dist - 20:
        var p1 = look_start + dir * pos
        var p2 = look_start + dir * min(pos + dash_len, total_dist - 20)
        draw_line(p1, p2, Color(0.3, 0.5, 0.6, look_a), 1.0)
        pos += dash_len + gap_len


    if t > 2.0:
        var q_a = clampf((t - 2.0) / 1.0, 0.0, 1.0)
        var pulse = 1.0 + sin(gt * 2.0) * 0.1
        draw_arc(Vector2(vp.x * 0.72, vp.y * 0.42), 30 * pulse, 0, TAU, 32, 
            Color(0.15, 0.3, 0.4, q_a * 0.2), 1.0)

    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), Color(0.08, 0.3, 0.4, 0.5), false, 2.0)




func _draw_page4(vp: Vector2):
    var t = page_time


    var sm_cx = vp.x * 0.2
    var sm_cy = vp.y * 0.55
    _small_planet(sm_cx, sm_cy, 35.0)
    _house(sm_cx, sm_cy - 37, 1.0)


    var anger_t = clampf((t - 1.5) / 1.0, 0.0, 1.0)
    var px = sm_cx + 24
    var py = sm_cy - 42
    _player(px, py, 1.0, 1.0, anger_t > 0.5, anger_t < 0.5 and t > 0.5)


    if anger_t > 0.3:
        var aa = clampf((anger_t - 0.3) / 0.5, 0.0, 1.0)
        var pulse = 1.0 + sin(gt * 8.0) * 0.2 * aa
        var ax = px + 8
        var ay = py - 18
        var ss = 7.0 * pulse
        var ac = Color(2.0, 0.3, 0.1, aa)
        draw_line(Vector2(ax, ay), Vector2(ax + ss, ay - ss * 0.7), ac, 2.0)
        draw_line(Vector2(ax + ss, ay), Vector2(ax, ay - ss * 0.7), ac, 2.0)


    var ghost_cx = vp.x * 0.68
    var ghost_cy = vp.y * 0.42
    var ghost_r = 180.0
    var ghost_a = clampf((t - 1.0) / 1.0, 0.0, 1.0)
    if ghost_a > 0:

        var flicker = (sin(gt * 4.0) + 1.0) * 0.5
        var outline_a = ghost_a * flicker * 0.15
        draw_arc(Vector2(ghost_cx, ghost_cy), ghost_r, 0, TAU, 48, 
            Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b, outline_a), 1.5)

        var core_flicker = (sin(gt * 5.0 + 1.0) + 1.0) * 0.5
        var core_a = ghost_a * core_flicker * 0.2
        draw_arc(Vector2(ghost_cx, ghost_cy), 18, 0, TAU, 16, 
            Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b, core_a), 2.0)

    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), Color(0.08, 0.3, 0.4, 0.5), false, 2.0)




func _draw_page5(vp: Vector2):
    var t = page_time


    var sm_cx = vp.x * 0.1
    var sm_cy = vp.y * 0.7
    _small_planet(sm_cx, sm_cy, 20.0)
    _house(sm_cx, sm_cy - 22, 0.7)


    var big_cx = vp.x * 0.55
    var big_cy = vp.y * 0.42
    var big_r = 200.0


    var regen_t = clampf(t / 3.0, 0.0, 1.0)
    var regen_ease = ease(regen_t, 0.3)


    if regen_ease > 0:
        var outline_a = clampf(regen_ease / 0.3, 0.0, 1.0)

        if regen_ease < 0.3:
            var segments = 32
            var arc_len = TAU / segments * outline_a
            for i in range(segments):
                var angle_start = (TAU / segments) * i + gt * 0.5
                draw_arc(Vector2(big_cx, big_cy), big_r, angle_start, angle_start + arc_len, 4, 
                    Color(TIER[6].r, TIER[6].g, TIER[6].b, outline_a * 0.6), 2.0)
        else:
            draw_arc(Vector2(big_cx, big_cy), big_r, 0, TAU, 64, 
                Color(TIER[6].r, TIER[6].g, TIER[6].b, min(1.0, outline_a)), 2.0)


    if regen_ease > 0.3:
        var fill_t = clampf((regen_ease - 0.3) / 0.6, 0.0, 1.0)

        var fill_depth = 1.0 - fill_t
        var r2 = big_r * big_r
        var bs = 9.0

        var half_count = int(big_r / bs)
        var start_x = big_cx - half_count * bs
        var start_y = big_cy - half_count * bs
        var bx = start_x
        while bx < big_cx + big_r:
            var by = start_y
            while by < big_cy + big_r:
                var dx = bx + bs * 0.5 - big_cx
                var dy = by + bs * 0.5 - big_cy
                var d2 = dx * dx + dy * dy
                if d2 < r2:
                    var depth = sqrt(d2) / big_r
                    if depth >= fill_depth:
                        var rect = Rect2(bx + 1, by + 1, bs - 2, bs - 2)

                        var new_glow = 0.0
                        var edge_depth = fill_depth + 0.05
                        if depth < edge_depth:
                            new_glow = (edge_depth - depth) / 0.05
                        draw_rect(rect, BLOCK_FILL)
                        if new_glow > 0:
                            draw_rect(rect, Color(0.1, 0.15, 0.2, new_glow * 0.3))
                        draw_rect(rect, GRID_LINE_C, false, 0.5)

                        var tc: Color
                        if depth < 0.15: tc = TIER[10]
                        elif depth < 0.3: tc = TIER[8]
                        elif depth < 0.5: tc = TIER[6]
                        elif depth < 0.7: tc = TIER[5]
                        elif depth < 0.85: tc = TIER[3]
                        else: tc = TIER[1]

                        if depth >= 0.15 and (depth > 0.85 or (depth >= fill_depth and depth < fill_depth + 0.08)):
                            var norm = Vector2(dx, dy).normalized()
                            var ea = 0.8
                            var ec = Color(tc.r, tc.g, tc.b, ea)
                            if abs(norm.x) > abs(norm.y):
                                var lx = bx + bs - 1 if norm.x > 0 else bx + 1
                                draw_line(Vector2(lx, by + 1), Vector2(lx, by + bs - 1), ec, 2.0)
                            else:
                                var ly = by + bs - 1 if norm.y > 0 else by + 1
                                draw_line(Vector2(bx + 1, ly), Vector2(bx + bs - 1, ly), ec, 2.0)
                by += bs
            bx += bs


    if regen_ease > 0.9:
        var core_a = clampf((regen_ease - 0.9) / 0.1, 0.0, 1.0)
        _core(big_cx, big_cy, 4, 9.0, core_a)
        _glow(Vector2(big_cx, big_cy), 50, 
            Color(CORE_EDGE.r, CORE_EDGE.g, CORE_EDGE.b), core_a * 0.5)


    if t > 3.5:
        var final_t = clampf((t - 3.5) / 1.0, 0.0, 1.0)
        var ship_x = lerpf(sm_cx + 30, vp.x * 0.25, ease(final_t, 0.2))
        var ship_y = vp.y * 0.55
        var rot = PI / 2
        var pts_raw = [Vector2(0, -14), Vector2(-10, 10), Vector2(10, 10)]
        var pts = PackedVector2Array()
        for p in pts_raw:
            var sp = p * 1.5
            pts.append(Vector2(sp.x * cos(rot) - sp.y * sin(rot) + ship_x, 
                sp.x * sin(rot) + sp.y * cos(rot) + ship_y))
        draw_colored_polygon(pts, Color(SHIP_FILL, final_t))
        for i in range(3):
            draw_line(pts[i], pts[(i + 1) % 3], 
                Color(SHIP_LINE.r, SHIP_LINE.g, SHIP_LINE.b, final_t), 2.0)

    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), Color(0.08, 0.3, 0.4, 0.5), false, 2.0)




func _build_ui():
    var text_panel = PanelContainer.new()
    text_panel.z_index = 10
    text_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    text_panel.anchor_top = 0.74
    var ps = StyleBoxFlat.new()
    ps.bg_color = Color(0.0, 0.0, 0.0, 0.75)
    text_panel.add_theme_stylebox_override("panel", ps)
    add_child(text_panel)

    var tm = MarginContainer.new()
    tm.add_theme_constant_override("margin_top", 20)
    tm.add_theme_constant_override("margin_bottom", 36)
    tm.add_theme_constant_override("margin_left", 60)
    tm.add_theme_constant_override("margin_right", 60)
    text_panel.add_child(tm)

    text_label = Label.new()
    text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    text_label.add_theme_font_size_override("font_size", 22)
    text_label.add_theme_color_override("font_color", TEXT_COLOR)
    text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tm.add_child(text_label)

    hint_label = Label.new()
    hint_label.text = "클릭하여 계속..."
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.z_index = 10
    hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    hint_label.anchor_top = 0.95
    hint_label.add_theme_font_size_override("font_size", 13)
    hint_label.add_theme_color_override("font_color", DIM_COLOR)
    add_child(hint_label)

    skip_btn = Button.new()
    skip_btn.text = "SKIP ▶"
    skip_btn.z_index = 10
    skip_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    skip_btn.offset_left = -100
    skip_btn.offset_right = -16
    skip_btn.offset_top = 16
    skip_btn.offset_bottom = 50
    skip_btn.add_theme_font_size_override("font_size", 13)
    skip_btn.add_theme_color_override("font_color", DIM_COLOR)
    skip_btn.add_theme_color_override("font_hover_color", CYAN)
    var ss = StyleBoxFlat.new()
    ss.bg_color = Color(0, 0, 0, 0.3)
    ss.set_corner_radius_all(4)
    skip_btn.add_theme_stylebox_override("normal", ss)
    var sh = ss.duplicate()
    sh.bg_color = Color(0.1, 0.1, 0.15, 0.5)
    skip_btn.add_theme_stylebox_override("hover", sh)
    skip_btn.pressed.connect(_skip)
    add_child(skip_btn)

func _show_next_page():
    current_page += 1
    if current_page >= pages_text.size():
        _end()
        return
    is_animating = true
    page_time = 0.0
    text_label.text = pages_text[current_page]
    text_label.modulate = Color(1, 1, 1, 0)
    hint_label.modulate = Color(1, 1, 1, 0)
    var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    tw.tween_property(text_label, "modulate:a", 1.0, 0.6)
    tw.tween_property(hint_label, "modulate:a", 1.0, 0.4).set_delay(1.0)
    tw.tween_callback( func(): is_animating = false)

func _input(event):
    if is_animating:
        return
    var advance = false
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if skip_btn and skip_btn.get_global_rect().has_point(event.position):
            return
        advance = true
    elif event is InputEventKey and event.pressed:
        if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
            advance = true
    if advance:
        get_viewport().set_input_as_handled()
        _show_next_page()

func _skip():
    _end()

func _end():

    ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")
