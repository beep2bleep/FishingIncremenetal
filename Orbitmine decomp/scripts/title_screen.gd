extends Control






const BG_COLOR: = Color(0.01, 0.01, 0.03)
const CYAN: = Color(0.3, 1.5, 2.0)
const CYAN_DIM: = Color(0.1, 0.4, 0.6)
const WHITE: = Color(0.95, 0.97, 1.0)

var gt: float = 0.0


var _stars: Array = []

func _ready():
    RenderingServer.set_default_clear_color(BG_COLOR)
    _gen_stars()

func _gen_stars():
    var rng = RandomNumberGenerator.new()
    rng.seed = 12321
    for i in range(200):
        _stars.append({
            "x": rng.randf(), 
            "y": rng.randf(), 
            "b": rng.randf_range(0.03, 0.25), 
            "sz": 1.0 if rng.randf() > 0.25 else 2.0, 
            "tw": rng.randf_range(0.5, 3.0), 
        })

func _process(delta):
    gt += delta
    queue_redraw()

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")

func _draw():
    var vp = get_viewport_rect().size
    if vp.x < 10:
        return

    draw_rect(Rect2(0, 0, vp.x, vp.y), BG_COLOR)


    for s in _stars:
        var twinkle = (sin(gt * s.tw + s.x * 80.0) + 1.0) * 0.5
        var b = s.b * (0.5 + twinkle * 0.5)
        draw_rect(Rect2(s.x * vp.x, s.y * vp.y, s.sz, s.sz), Color(b, b, b + 0.02))


    var cx = vp.x * 0.5
    var cy = vp.y * 0.45


    var title_alpha = clampf(gt / 1.5, 0.0, 1.0)


    var block_size = 6.0
    var letter_gap = 4.0


    var font = _get_pixel_font()
    var title = "ORBITMINE"


    var total_width = 0.0
    for ch in title:
        var glyph = font.get(ch, font["?"])
        total_width += glyph[0].length() * block_size + letter_gap * block_size
    total_width -= letter_gap * block_size

    var start_x = cx - total_width * 0.5
    var draw_x = start_x

    for i in range(title.length()):
        var ch = title[i]
        var glyph = font.get(ch, font["?"])
        var char_w = glyph[0].length()


        var char_delay = i * 0.08
        var char_alpha = clampf((gt - char_delay) / 0.8, 0.0, 1.0) * title_alpha


        var pulse = 0.85 + sin(gt * 2.5 + i * 0.7) * 0.15

        _draw_neon_char(glyph, draw_x, cy, block_size, char_alpha * pulse, i)

        draw_x += (char_w + letter_gap) * block_size


    if gt > 2.0:
        var sub_alpha = clampf((gt - 2.0) / 1.0, 0.0, 1.0) * 0.6

        var sub_text = "SPACE MINING INCREMENTAL"
        var sub_block = 2.0
        var sub_gap = 2.0
        var sub_font = _get_pixel_font()
        var sub_total = 0.0
        for ch in sub_text:
            var g = sub_font.get(ch, sub_font.get("?", []))
            if g.size() > 0:
                sub_total += g[0].length() * sub_block + sub_gap * sub_block
        sub_total -= sub_gap * sub_block
        var sub_x = cx - sub_total * 0.5
        var sub_y = cy + 7 * block_size + 30
        for ch_idx in range(sub_text.length()):
            var ch = sub_text[ch_idx]
            var g = sub_font.get(ch, sub_font.get("?", []))
            if g.size() == 0:
                sub_x += (3 + sub_gap) * sub_block
                continue
            var cw = g[0].length()
            _draw_char_simple(g, sub_x, sub_y, sub_block, sub_alpha)
            sub_x += (cw + sub_gap) * sub_block


    var border_a = clampf(gt / 2.0, 0.0, 0.3)
    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), 
        Color(CYAN.r * 0.3, CYAN.g * 0.3, CYAN.b * 0.3, border_a), false, 2.0)




func _draw_neon_char(glyph: Array, ox: float, oy: float, bs: float, alpha: float, char_idx: int):

    var h = glyph.size()
    var oy_centered = oy - h * bs * 0.5


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] == "#":
                var bx = ox + col * bs
                var by = oy_centered + row * bs

                for gi in range(3):
                    var gr = bs * (2.5 - gi * 0.6)
                    var ga = alpha * 0.04 * (1.0 - float(gi) / 3.0)
                    draw_circle(Vector2(bx + bs * 0.5, by + bs * 0.5), gr, 
                        Color(CYAN.r, CYAN.g, CYAN.b, ga))


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] == "#":
                var bx = ox + col * bs
                var by = oy_centered + row * bs
                var rect = Rect2(bx + 1, by + 1, bs - 2, bs - 2)

                draw_rect(rect, Color(0.02, 0.04, 0.06, alpha))

                draw_rect(rect, Color(CYAN.r, CYAN.g, CYAN.b, alpha * 0.8), false, 1.5)


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] != "#":
                continue
            var bx = ox + col * bs
            var by = oy_centered + row * bs


            if row == 0 or glyph[row - 1][col] != "#":
                draw_line(Vector2(bx + 1, by + 1), Vector2(bx + bs - 1, by + 1), 
                    Color(WHITE.r, WHITE.g, WHITE.b, alpha * 0.6), 1.0)

            if row == h - 1 or glyph[row + 1][col] != "#":
                draw_line(Vector2(bx + 1, by + bs - 1), Vector2(bx + bs - 1, by + bs - 1), 
                    Color(CYAN.r * 0.6, CYAN.g * 0.6, CYAN.b * 0.6, alpha * 0.4), 1.0)

            if col == 0 or line[col - 1] != "#":
                draw_line(Vector2(bx + 1, by + 1), Vector2(bx + 1, by + bs - 1), 
                    Color(WHITE.r, WHITE.g, WHITE.b, alpha * 0.4), 1.0)




func _draw_char_simple(glyph: Array, ox: float, oy: float, bs: float, alpha: float):
    for row in range(glyph.size()):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] == "#":
                var bx = ox + col * bs
                var by = oy + row * bs
                draw_rect(Rect2(bx, by, bs, bs), 
                    Color(CYAN_DIM.r, CYAN_DIM.g, CYAN_DIM.b, alpha))




func _get_pixel_font() -> Dictionary:
    return {
        "O": [
            ".###.", 
            "#...#", 
            "#...#", 
            "#...#", 
            "#...#", 
            "#...#", 
            ".###.", 
        ], 
        "R": [
            "####.", 
            "#...#", 
            "#...#", 
            "####.", 
            "#.#..", 
            "#..#.", 
            "#...#", 
        ], 
        "B": [
            "####.", 
            "#...#", 
            "#...#", 
            "####.", 
            "#...#", 
            "#...#", 
            "####.", 
        ], 
        "I": [
            "#####", 
            "..#..", 
            "..#..", 
            "..#..", 
            "..#..", 
            "..#..", 
            "#####", 
        ], 
        "T": [
            "#####", 
            "..#..", 
            "..#..", 
            "..#..", 
            "..#..", 
            "..#..", 
            "..#..", 
        ], 
        "M": [
            "#...#", 
            "##.##", 
            "#.#.#", 
            "#.#.#", 
            "#...#", 
            "#...#", 
            "#...#", 
        ], 
        "N": [
            "#...#", 
            "##..#", 
            "#.#.#", 
            "#.#.#", 
            "#..##", 
            "#...#", 
            "#...#", 
        ], 
        "E": [
            "#####", 
            "#....", 
            "#....", 
            "####.", 
            "#....", 
            "#....", 
            "#####", 
        ], 
        "S": [
            ".####", 
            "#....", 
            "#....", 
            ".###.", 
            "....#", 
            "....#", 
            "####.", 
        ], 
        "P": [
            "####.", 
            "#...#", 
            "#...#", 
            "####.", 
            "#....", 
            "#....", 
            "#....", 
        ], 
        "A": [
            ".###.", 
            "#...#", 
            "#...#", 
            "#####", 
            "#...#", 
            "#...#", 
            "#...#", 
        ], 
        "C": [
            ".####", 
            "#....", 
            "#....", 
            "#....", 
            "#....", 
            "#....", 
            ".####", 
        ], 
        "G": [
            ".####", 
            "#....", 
            "#....", 
            "#.###", 
            "#...#", 
            "#...#", 
            ".###.", 
        ], 
        "L": [
            "#....", 
            "#....", 
            "#....", 
            "#....", 
            "#....", 
            "#....", 
            "#####", 
        ], 
        "D": [
            "####.", 
            "#...#", 
            "#...#", 
            "#...#", 
            "#...#", 
            "#...#", 
            "####.", 
        ], 
        " ": [
            "...", 
            "...", 
            "...", 
            "...", 
            "...", 
            "...", 
            "...", 
        ], 
        "?": [
            ".###.", 
            "#...#", 
            "....#", 
            "..##.", 
            "..#..", 
            ".....", 
            "..#..", 
        ], 
    }
