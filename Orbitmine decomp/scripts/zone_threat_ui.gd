extends Control






var zone_threat: ZoneThreatSystem = null


var overheat_container: VBoxContainer = null
var overheat_bar: ProgressBar = null
var overheat_label: Label = null
var overheat_flash_timer: float = 0.0


var wind_warn_active: bool = false


var frost_label: Label = null
var current_cold_amount: float = 0.0

func setup(threat_system: ZoneThreatSystem):
    zone_threat = threat_system

    zone_threat.overheat_changed.connect(_on_overheat_changed)
    zone_threat.overheat_triggered.connect(_on_overheat_triggered)
    zone_threat.wind_warning.connect(_on_wind_warning)
    zone_threat.wind_gust.connect(_on_wind_gust)
    zone_threat.cold_slow_changed.connect(_on_cold_slow_changed)

    _build_ui()
    print("[ZoneThreatUI] 초기화 완료")

func _build_ui():
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _build_frost_label()





func _build_overheat_gauge():
    overheat_container = VBoxContainer.new()
    overheat_container.set_anchors_preset(Control.PRESET_CENTER_LEFT)
    overheat_container.offset_left = 16
    overheat_container.offset_top = -40
    overheat_container.offset_right = 200
    overheat_container.add_theme_constant_override("separation", 2)
    overheat_container.visible = false
    overheat_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(overheat_container)

    overheat_label = Label.new()
    overheat_label.text = "🌡️ 과열"
    overheat_label.add_theme_font_size_override("font_size", 14)
    overheat_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
    overheat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overheat_container.add_child(overheat_label)

    overheat_bar = ProgressBar.new()
    overheat_bar.custom_minimum_size = Vector2(170, 16)
    overheat_bar.max_value = 100.0
    overheat_bar.value = 0
    overheat_bar.show_percentage = false
    overheat_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

    var bg = StyleBoxFlat.new()
    bg.bg_color = Color(0.1, 0.05, 0.02, 0.85)
    bg.set_corner_radius_all(4)
    bg.border_color = Color(1.0, 0.5, 0.1, 0.5)
    bg.set_border_width_all(1)
    overheat_bar.add_theme_stylebox_override("background", bg)

    var fill = StyleBoxFlat.new()
    fill.bg_color = Color(1.0, 0.6, 0.1, 0.95)
    fill.set_corner_radius_all(4)
    overheat_bar.add_theme_stylebox_override("fill", fill)

    overheat_container.add_child(overheat_bar)

func _on_overheat_changed(_value: float, _max_value: float):
    pass

func _on_overheat_triggered():
    overheat_flash_timer = 0.5





func _on_wind_warning(_direction: Vector2, _time_left: float):
    wind_warn_active = true

func _on_wind_gust(_direction: Vector2, _force: float):
    wind_warn_active = false





func _build_frost_label():
    frost_label = Label.new()
    frost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    frost_label.add_theme_font_size_override("font_size", 16)
    frost_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
    frost_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    frost_label.offset_bottom = -80
    frost_label.offset_left = -100
    frost_label.offset_right = 100
    frost_label.visible = false
    frost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(frost_label)

func _on_cold_slow_changed(amount: float):
    current_cold_amount = amount
    if amount > 0.01:
        frost_label.visible = true
        frost_label.text = "❄️ 감속 -%d%%" % int(amount * 100)
    else:
        frost_label.visible = false





func _process(delta: float):

    var vp_size = get_viewport_rect().size
    if size != vp_size:
        position = Vector2.ZERO
        size = vp_size


    if overheat_flash_timer > 0:
        overheat_flash_timer -= delta
        queue_redraw()



func _draw():
    if overheat_flash_timer > 0:
        var flash_alpha = overheat_flash_timer * 0.3
        draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.2, 0.05, flash_alpha))
