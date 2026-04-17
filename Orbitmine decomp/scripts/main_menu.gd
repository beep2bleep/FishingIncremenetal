extends Control






const NEON_CYAN: = Color(0.3, 1.5, 2.0)
const NEON_CYAN_DIM: = Color(0.1, 0.4, 0.6)
const NEON_WHITE: = Color(0.95, 0.97, 1.0)
const NEON_BG: = Color(0.04, 0.04, 0.1)

var _stars: Array = []
var _gt: float = 0.0

@onready var title_label = $VBoxContainer / TitleLabel
@onready var start_btn = $VBoxContainer / ButtonContainer / StartButton
@onready var continue_btn = $VBoxContainer / ButtonContainer / ContinueButton
@onready var settings_btn = $VBoxContainer / ButtonContainer / SettingsButton
@onready var quit_btn = $VBoxContainer / ButtonContainer / QuitButton

func _ready():
    print("=== 메인 메뉴 ===")

    title_label.visible = false
    $VBoxContainer / SubtitleLabel.visible = false

    $Background.color = Color(0.04, 0.04, 0.1, 0.0)
    _gen_stars()

    _apply_neon_button_style(start_btn)
    _apply_neon_button_style(continue_btn)
    _apply_neon_button_style(settings_btn)
    _apply_neon_button_style(quit_btn)
    _refresh_texts()

    start_btn.pressed.connect(_on_start_pressed)
    continue_btn.pressed.connect(_on_continue_pressed)
    settings_btn.pressed.connect(_on_settings_pressed)
    quit_btn.pressed.connect(_on_quit_pressed)
    update_continue_button()

    SettingsPopup.language_changed.connect(_refresh_texts)


func _refresh_texts():
    start_btn.text = tr("MENU_START")
    continue_btn.text = tr("MENU_CONTINUE")
    settings_btn.text = tr("MENU_SETTINGS")
    quit_btn.text = tr("MENU_QUIT")


func _apply_neon_button_style(btn: Button):

    var normal = StyleBoxFlat.new()
    normal.bg_color = Color(0.02, 0.04, 0.06, 0.85)
    normal.border_color = Color(NEON_CYAN.r * 0.4, NEON_CYAN.g * 0.4, NEON_CYAN.b * 0.4, 0.6)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(4)
    normal.content_margin_left = 20
    normal.content_margin_right = 20
    normal.content_margin_top = 10
    normal.content_margin_bottom = 10
    btn.add_theme_stylebox_override("normal", normal)


    var hover = normal.duplicate()
    hover.bg_color = Color(0.04, 0.08, 0.12, 0.9)
    hover.border_color = Color(NEON_CYAN.r * 0.7, NEON_CYAN.g * 0.7, NEON_CYAN.b * 0.7, 0.9)
    hover.set_border_width_all(2)
    btn.add_theme_stylebox_override("hover", hover)


    var pressed = normal.duplicate()
    pressed.bg_color = Color(0.06, 0.15, 0.22, 0.95)
    pressed.border_color = Color(NEON_CYAN.r, NEON_CYAN.g, NEON_CYAN.b, 1.0)
    pressed.set_border_width_all(2)
    btn.add_theme_stylebox_override("pressed", pressed)


    var disabled = normal.duplicate()
    disabled.bg_color = Color(0.02, 0.02, 0.04, 0.5)
    disabled.border_color = Color(0.15, 0.15, 0.2, 0.3)
    disabled.set_border_width_all(1)
    btn.add_theme_stylebox_override("disabled", disabled)


    btn.add_theme_color_override("font_color", Color(NEON_CYAN.r * 0.7, NEON_CYAN.g * 0.7, NEON_CYAN.b * 0.7))
    btn.add_theme_color_override("font_hover_color", NEON_WHITE)
    btn.add_theme_color_override("font_pressed_color", NEON_WHITE)
    btn.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.35))
    btn.add_theme_font_size_override("font_size", 20)

func update_continue_button():
    var save_exists = FileAccess.file_exists("user://savegame.save")
    if save_exists:
        continue_btn.disabled = false
    else:
        continue_btn.disabled = true


func _on_start_pressed():
    print("새 게임 시작!")
    start_btn.disabled = true
    continue_btn.disabled = true
    Global.initialize_game()

    var config: = ConfigFile.new()
    config.load("user://settings.cfg")
    config.set_value("game", "tutorial_completed", false)
    config.save("user://settings.cfg")

    ScreenFX.transition_to("res://scenes/loading_screen.tscn")


func _on_continue_pressed():
    print("이어하기!")
    start_btn.disabled = true
    continue_btn.disabled = true
    Global.load_game()
    if Global.planet_data == null:
        await Global.initialize_planet()
    elif Global.planet_data:
        await Global.planet_data.rebuild_caches_async(get_tree())
    ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")

func _on_settings_pressed():
    SettingsPopup._open()

func _on_quit_pressed():
    print("게임 종료")
    get_tree().quit()





func _gen_stars():
    var rng = RandomNumberGenerator.new()
    rng.seed = 54321
    for i in range(180):
        _stars.append({
            "x": rng.randf(), "y": rng.randf(), 
            "b": rng.randf_range(0.03, 0.25), 
            "sz": 1.0 if rng.randf() > 0.25 else 2.0, 
            "tw": rng.randf_range(0.5, 3.0), 
        })

func _process(delta):
    _gt += delta
    queue_redraw()

func _draw():
    var vp = get_viewport_rect().size
    if vp.x < 10:
        return


    draw_rect(Rect2(0, 0, vp.x, vp.y), NEON_BG)


    for s in _stars:
        var twinkle = (sin(_gt * s.tw + s.x * 80.0) + 1.0) * 0.5
        var b = s.b * (0.5 + twinkle * 0.5)
        draw_rect(Rect2(s.x * vp.x, s.y * vp.y, s.sz, s.sz), Color(b, b, b + 0.02))


    var cx = vp.x * 0.5
    var cy = vp.y * 0.28

    var block_size = 5.0
    var letter_gap = 3.0
    var font = _get_pixel_font()
    var title = "ORBITMINE"


    var total_width = 0.0
    for ch in title:
        var glyph = font.get(ch, font["?"])
        total_width += glyph[0].length() * block_size + letter_gap * block_size
    total_width -= letter_gap * block_size

    var draw_x = cx - total_width * 0.5

    for i in range(title.length()):
        var ch = title[i]
        var glyph = font.get(ch, font["?"])
        var char_w = glyph[0].length()
        var char_delay = i * 0.08
        var char_alpha = clampf((_gt - char_delay) / 0.8, 0.0, 1.0)
        var pulse = 0.85 + sin(_gt * 2.5 + i * 0.7) * 0.15
        _draw_neon_char(glyph, draw_x, cy, block_size, char_alpha * pulse)
        draw_x += (char_w + letter_gap) * block_size

func _draw_neon_char(glyph: Array, ox: float, oy: float, bs: float, alpha: float):
    var h = glyph.size()
    var oy_c = oy - h * bs * 0.5


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] == "#":
                var bx = ox + col * bs
                var by = oy_c + row * bs
                for gi in range(3):
                    var gr = bs * (2.5 - gi * 0.6)
                    var ga = alpha * 0.04 * (1.0 - float(gi) / 3.0)
                    draw_circle(Vector2(bx + bs * 0.5, by + bs * 0.5), gr, 
                        Color(NEON_CYAN.r, NEON_CYAN.g, NEON_CYAN.b, ga))


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] == "#":
                var bx = ox + col * bs
                var by = oy_c + row * bs
                var rect = Rect2(bx + 1, by + 1, bs - 2, bs - 2)
                draw_rect(rect, Color(0.02, 0.04, 0.06, alpha))
                draw_rect(rect, Color(NEON_CYAN.r, NEON_CYAN.g, NEON_CYAN.b, alpha * 0.8), false, 1.5)


    for row in range(h):
        var line = glyph[row]
        for col in range(line.length()):
            if line[col] != "#":
                continue
            var bx = ox + col * bs
            var by = oy_c + row * bs
            if row == 0 or glyph[row - 1][col] != "#":
                draw_line(Vector2(bx + 1, by + 1), Vector2(bx + bs - 1, by + 1), 
                    Color(NEON_WHITE.r, NEON_WHITE.g, NEON_WHITE.b, alpha * 0.6), 1.0)
            if row == h - 1 or glyph[row + 1][col] != "#":
                draw_line(Vector2(bx + 1, by + bs - 1), Vector2(bx + bs - 1, by + bs - 1), 
                    Color(NEON_CYAN.r * 0.6, NEON_CYAN.g * 0.6, NEON_CYAN.b * 0.6, alpha * 0.4), 1.0)
            if col == 0 or line[col - 1] != "#":
                draw_line(Vector2(bx + 1, by + 1), Vector2(bx + 1, by + bs - 1), 
                    Color(NEON_WHITE.r, NEON_WHITE.g, NEON_WHITE.b, alpha * 0.4), 1.0)

func _get_pixel_font() -> Dictionary:
    return {
        "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."], 
        "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"], 
        "B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."], 
        "I": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "#####"], 
        "T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."], 
        "M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"], 
        "N": ["#...#", "##..#", "#.#.#", "#.#.#", "#..##", "#...#", "#...#"], 
        "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"], 
        "?": [".###.", "#...#", "....#", "..##.", "..#..", ".....", "..#.."], 
    }
