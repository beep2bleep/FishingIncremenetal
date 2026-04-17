extends Control







const BG_COLOR: = Color(0.01, 0.01, 0.03)
const CYAN: = Color(0.2, 0.85, 1.0)
const WHITE: = Color(0.9, 0.9, 0.95)


const TEXT_APPEAR: = 1.5
const QUESTION_APPEAR: = 4.5
const BUTTON_APPEAR: = 6.0


var _stars: Array = []


var gt: float = 0.0


var thanks_label: Label
var end_label: Label
var continue_btn: Button

func _ready():
    RenderingServer.set_default_clear_color(BG_COLOR)
    _gen_stars()
    _build_ui()




func _gen_stars():
    var rng = RandomNumberGenerator.new()
    rng.seed = 77777
    for i in range(250):
        _stars.append(Vector4(
            rng.randf(), rng.randf(), 
            rng.randf_range(0.03, 0.3), 
            rng.randf_range(0.5, 3.0)
        ))




func _process(delta):
    gt += delta
    queue_redraw()




func _draw():
    var vp = get_viewport_rect().size
    if vp.x < 10:
        return

    draw_rect(Rect2(0, 0, vp.x, vp.y), BG_COLOR)
    _draw_stars(vp)


    var border_a = clampf(gt / 2.0, 0.0, 0.4)
    draw_rect(Rect2(2, 2, vp.x - 4, vp.y - 4), 
        Color(CYAN.r * 0.4, CYAN.g * 0.4, CYAN.b * 0.4, border_a), false, 2.0)




func _draw_stars(vp: Vector2):
    for s in _stars:
        var sx = s.x * vp.x
        var sy = s.y * vp.y
        var base_b = s.z
        var twinkle = (sin(gt * s.w + s.x * 100.0) + 1.0) * 0.5
        var b = base_b * (0.6 + twinkle * 0.4)

        b *= clampf(gt / 1.5, 0.0, 1.0)
        var col = Color(b, b, b + 0.02)
        if base_b > 0.2:
            draw_rect(Rect2(sx, sy, 2, 2), col)
        else:
            draw_rect(Rect2(sx, sy, 1, 1), col)




func _build_ui():

    thanks_label = Label.new()
    thanks_label.text = tr("ENDING_THANKS")
    thanks_label.add_theme_font_size_override("font_size", 30)
    thanks_label.add_theme_color_override("font_color", WHITE)
    thanks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    thanks_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    thanks_label.set_anchors_preset(Control.PRESET_CENTER)
    thanks_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
    thanks_label.grow_vertical = Control.GROW_DIRECTION_BOTH
    thanks_label.offset_left = -300
    thanks_label.offset_right = 300
    thanks_label.offset_top = -40
    thanks_label.offset_bottom = 40
    thanks_label.z_index = 10
    thanks_label.modulate = Color(1, 1, 1, 0)
    add_child(thanks_label)


    continue_btn = Button.new()
    continue_btn.text = tr("ENDING_CONTINUE")
    continue_btn.z_index = 10
    continue_btn.set_anchors_preset(Control.PRESET_CENTER)
    continue_btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
    continue_btn.grow_vertical = Control.GROW_DIRECTION_BOTH
    continue_btn.offset_left = -80
    continue_btn.offset_right = 80
    continue_btn.offset_top = 110
    continue_btn.offset_bottom = 155
    continue_btn.add_theme_font_size_override("font_size", 18)
    continue_btn.add_theme_color_override("font_color", CYAN)
    continue_btn.add_theme_color_override("font_hover_color", WHITE)

    var btn_style = StyleBoxFlat.new()
    btn_style.bg_color = Color(0.05, 0.12, 0.18, 0.9)
    btn_style.border_color = Color(CYAN.r * 0.6, CYAN.g * 0.6, CYAN.b * 0.6, 0.8)
    btn_style.set_border_width_all(2)
    btn_style.set_corner_radius_all(6)
    continue_btn.add_theme_stylebox_override("normal", btn_style)

    var btn_hover = btn_style.duplicate()
    btn_hover.bg_color = Color(0.08, 0.18, 0.25, 0.95)
    btn_hover.border_color = CYAN
    continue_btn.add_theme_stylebox_override("hover", btn_hover)

    var btn_pressed = btn_style.duplicate()
    btn_pressed.bg_color = Color(0.1, 0.25, 0.35, 0.95)
    continue_btn.add_theme_stylebox_override("pressed", btn_pressed)

    continue_btn.modulate = Color(1, 1, 1, 0)
    continue_btn.pressed.connect(_on_continue)
    add_child(continue_btn)


    end_label = Label.new()
    end_label.text = "Game End...?"
    end_label.add_theme_font_size_override("font_size", 22)
    end_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
    end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    end_label.set_anchors_preset(Control.PRESET_CENTER)
    end_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
    end_label.offset_left = -200
    end_label.offset_right = 200
    end_label.offset_top = 30
    end_label.offset_bottom = 70
    end_label.z_index = 10
    end_label.modulate = Color(1, 1, 1, 0)
    add_child(end_label)


    var tw = create_tween()
    tw.tween_property(thanks_label, "modulate:a", 1.0, 1.0).set_delay(TEXT_APPEAR)
    tw.tween_property(end_label, "modulate:a", 1.0, 1.5).set_delay(QUESTION_APPEAR - TEXT_APPEAR - 1.0)
    tw.tween_property(continue_btn, "modulate:a", 1.0, 0.6).set_delay(BUTTON_APPEAR - QUESTION_APPEAR - 1.5)




func _on_continue():
    Global.ending_shown = true
    Global.save_game()

    ScreenFX.transition_to("res://scenes/sortie_result.tscn")
