extends Control






const BG_COLOR: = Color(0.01, 0.01, 0.03)
const CYAN: = Color(0.2, 0.85, 1.0)
const DIM: = Color(0.45, 0.45, 0.5)

var progress_bar: ProgressBar
var status_label: Label
var _stars: Array = []
var gt: float = 0.0


var next_scene: String = "res://scenes/mining_scene.tscn"

func _ready():
    RenderingServer.set_default_clear_color(BG_COLOR)
    _gen_stars()
    _build_ui()

    await get_tree().process_frame
    await get_tree().process_frame
    _start_loading()

func _process(delta):
    gt += delta
    queue_redraw()

func _draw():
    var vp = get_viewport_rect().size
    draw_rect(Rect2(0, 0, vp.x, vp.y), BG_COLOR)

    for s in _stars:
        var sx = s.x * vp.x
        var sy = s.y * vp.y
        var sb = s.z * (0.7 + sin(gt * 1.2 + s.x * 10.0) * 0.3)
        draw_rect(Rect2(sx, sy, 1, 1), Color(sb, sb, sb + 0.02))

func _gen_stars():
    var rng = RandomNumberGenerator.new()
    rng.seed = 77777
    for i in range(120):
        _stars.append(Vector3(rng.randf(), rng.randf(), rng.randf_range(0.05, 0.2)))

func _build_ui():
    var vp = get_viewport_rect().size


    status_label = Label.new()
    status_label.text = tr("LOADING_PLANET")
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.set_anchors_preset(Control.PRESET_CENTER)
    status_label.offset_top = -40
    status_label.offset_bottom = -10
    status_label.offset_left = -200
    status_label.offset_right = 200
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", CYAN)
    add_child(status_label)


    progress_bar = ProgressBar.new()
    progress_bar.set_anchors_preset(Control.PRESET_CENTER)
    progress_bar.offset_top = 0
    progress_bar.offset_bottom = 14
    progress_bar.offset_left = -150
    progress_bar.offset_right = 150
    progress_bar.max_value = 100
    progress_bar.value = 0
    progress_bar.show_percentage = false

    var bg_style = StyleBoxFlat.new()
    bg_style.bg_color = Color(0.05, 0.05, 0.08, 0.8)
    bg_style.set_corner_radius_all(4)
    bg_style.border_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.3)
    bg_style.set_border_width_all(1)
    progress_bar.add_theme_stylebox_override("background", bg_style)

    var fill_style = StyleBoxFlat.new()
    fill_style.bg_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.8)
    fill_style.set_corner_radius_all(4)
    progress_bar.add_theme_stylebox_override("fill", fill_style)

    add_child(progress_bar)

func _start_loading():

    status_label.text = tr("LOADING_PLANET")
    await Global.initialize_planet_with_progress(_update_progress)


    progress_bar.value = 100
    status_label.text = tr("LOADING_DONE")
    await get_tree().create_timer(0.3).timeout

    ScreenFX.transition_to(next_scene)

func _update_progress(percent: float, phase: String):
    progress_bar.value = percent
    status_label.text = phase
