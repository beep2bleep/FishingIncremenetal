extends CanvasLayer









const CYAN: = Color(0.2, 0.85, 1.0)
const ORANGE: = Color(1.0, 0.5, 0.15)
const RED: = Color(1.0, 0.3, 0.15)
const GREEN: = Color(0.3, 0.9, 0.4)
const DIM: = Color(0.45, 0.45, 0.5)
const WHITE: = Color(0.9, 0.92, 0.95)
const BG_PANEL: = Color(0.02, 0.02, 0.06, 0.88)
const BORDER: = Color(0.3, 1.0, 1.2, 0.6)

var current_step: int = -1
var is_active: bool = false
var is_animating: bool = false
var gt: float = 0.0


var distance_moved: float = 0.0
var last_ship_pos: Vector2 = Vector2.ZERO
const MOVE_GOAL: float = 4000.0


var blocks_at_start: int = 0
const MINE_GOAL: int = 3


var overlay: ColorRect
var panel: PanelContainer
var title_label: Label
var desc_label: RichTextLabel
var hint_label: Label
var step_label: Label
var arrow_draw: Control


var mining_scene: Node2D = null


var _saved_fuel_rate: float = 1.0

func setup(scene: Node2D):
    mining_scene = scene

func _ready():
    layer = 80
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_ui()

    _saved_fuel_rate = Global.fuel_rate
    Global.fuel_rate = 0.0
    Global.tutorial_active = true

    await get_tree().process_frame
    await get_tree().process_frame
    start_tutorial()

func _process(delta):
    gt += delta
    if not is_active:
        return

    match current_step:
        0: _update_step_move(delta)
        1: _update_step_mine(delta)

    if arrow_draw:
        arrow_draw.queue_redraw()

func _unhandled_input(event: InputEvent):
    if not is_active or is_animating:
        return

    if current_step >= 2:
        var advance = false
        if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            advance = true
        elif event is InputEventKey and event.pressed:
            if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
                advance = true
        if advance:
            get_viewport().set_input_as_handled()
            _advance_step()





func _build_ui():
    overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.45)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.visible = false
    add_child(overlay)

    arrow_draw = Control.new()
    arrow_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
    arrow_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
    arrow_draw.draw.connect(_on_arrow_draw)
    add_child(arrow_draw)

    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
    panel.offset_top = 20
    panel.offset_left = -230
    panel.offset_right = 230
    panel.offset_bottom = 200

    var style: = StyleBoxFlat.new()
    style.bg_color = BG_PANEL
    style.border_color = BORDER
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 20
    style.content_margin_right = 20
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    panel.add_theme_stylebox_override("panel", style)
    add_child(panel)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    panel.add_child(vbox)

    step_label = Label.new()
    step_label.add_theme_font_size_override("font_size", 12)
    step_label.add_theme_color_override("font_color", DIM)
    vbox.add_child(step_label)

    title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 22)
    title_label.add_theme_color_override("font_color", CYAN)
    vbox.add_child(title_label)

    desc_label = RichTextLabel.new()
    desc_label.bbcode_enabled = true
    desc_label.add_theme_font_size_override("normal_font_size", 15)
    desc_label.add_theme_color_override("default_color", WHITE)
    desc_label.scroll_active = false
    desc_label.fit_content = true
    desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(desc_label)

    hint_label = Label.new()
    hint_label.add_theme_font_size_override("font_size", 13)
    hint_label.add_theme_color_override("font_color", DIM)
    vbox.add_child(hint_label)





func start_tutorial():
    is_active = true
    _show_step(0)

func _show_step(step: int):
    current_step = step
    is_animating = true

    panel.modulate = Color(1, 1, 1, 0)
    var tween = create_tween()
    tween.tween_property(panel, "modulate:a", 1.0, 0.35)
    tween.tween_callback( func(): is_animating = false)

    step_label.text = "%d / 4" % (step + 1)

    match step:
        0: _setup_step_move()
        1: _setup_step_mine()
        2: _setup_step_ui()
        3: _setup_step_core()

func _advance_step():
    if current_step < 3:
        is_animating = true
        var tween = create_tween()
        tween.tween_property(panel, "modulate:a", 0.0, 0.2)
        tween.tween_callback( func(): _show_step(current_step + 1))
    else:
        _complete_tutorial()

func _step_clear():
    is_animating = true
    hint_label.text = "✓"
    hint_label.add_theme_color_override("font_color", GREEN)
    var tween = create_tween()
    tween.tween_interval(0.5)
    tween.tween_property(panel, "modulate:a", 0.0, 0.25)
    tween.tween_callback( func():
        hint_label.add_theme_color_override("font_color", DIM)
        _show_step(current_step + 1)
    )

func _complete_tutorial():
    is_active = false


    Global.fuel_rate = _saved_fuel_rate
    Global.tutorial_active = false


    var config: = ConfigFile.new()
    config.load("user://settings.cfg")
    config.set_value("game", "tutorial_completed", true)
    config.save("user://settings.cfg")

    overlay.visible = false


    if mining_scene:
        mining_scene.is_active = false

        await Global.end_sortie_async(mining_scene.get_tree())
        ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")

    queue_free()





func _setup_step_move():
    overlay.visible = false
    title_label.text = tr("TUT_MOVE_TITLE")
    desc_label.text = tr("TUT_MOVE_DESC")
    hint_label.text = ""

    distance_moved = 0.0
    if mining_scene and mining_scene.player:
        last_ship_pos = mining_scene.player.global_position

func _update_step_move(_delta: float):
    if is_animating:
        return
    if mining_scene and mining_scene.player:
        var pos = mining_scene.player.global_position
        distance_moved += pos.distance_to(last_ship_pos)
        last_ship_pos = pos

        var pct = mini(int(distance_moved / MOVE_GOAL * 100), 100)
        hint_label.text = "%d%%" % pct

        if distance_moved >= MOVE_GOAL:
            _step_clear()





func _setup_step_mine():
    overlay.visible = false
    title_label.text = tr("TUT_MINE_TITLE")
    desc_label.text = tr("TUT_MINE_DESC")
    hint_label.text = ""

    blocks_at_start = Global.sortie_blocks_destroyed

func _update_step_mine(_delta: float):
    if is_animating:
        return
    var destroyed = Global.sortie_blocks_destroyed - blocks_at_start
    hint_label.text = "📦 %d / %d" % [destroyed, MINE_GOAL]

    if destroyed >= MINE_GOAL:
        _step_clear()





func _setup_step_ui():
    overlay.visible = true
    title_label.text = tr("TUT_DANGER_TITLE")
    desc_label.text = tr("TUT_DANGER_DESC")
    hint_label.text = tr("TUT_HINT")





func _setup_step_core():
    overlay.visible = true
    title_label.text = tr("TUT_CORE_TITLE")
    desc_label.text = tr("TUT_CORE_DESC")
    hint_label.text = tr("TUT_HINT_LAST")





func _draw_arrow(from: Vector2, to: Vector2, color: Color):
    arrow_draw.draw_line(from, to, color, 2.5)
    var dir = (to - from).normalized()
    var perp = Vector2( - dir.y, dir.x)
    arrow_draw.draw_line(to, to - dir * 12 + perp * 6, color, 2.5)
    arrow_draw.draw_line(to, to - dir * 12 - perp * 6, color, 2.5)

func _on_arrow_draw():
    pass

func _on_arrow_draw_disabled():
    if not is_active:
        return
    if current_step == 2:
        var vp = arrow_draw.get_viewport_rect().size
        var pulse = 0.6 + sin(gt * 3.0) * 0.3


        var fuel_pos = Vector2(70, vp.y - 70)
        var fuel_arrow_start = Vector2(fuel_pos.x + 90, fuel_pos.y - 50)
        var fuel_arrow_end = Vector2(fuel_pos.x + 15, fuel_pos.y - 5)
        var fuel_color = Color(RED.r, RED.g, RED.b, pulse)
        _draw_arrow(fuel_arrow_start, fuel_arrow_end, fuel_color)
        arrow_draw.draw_string(ThemeDB.fallback_font, fuel_arrow_start + Vector2(5, -10), 
            "⛽ " + tr("TUT_FUEL_LABEL"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, fuel_color)


        var cargo_arrow_start = Vector2(140, 55)
        var cargo_arrow_end = Vector2(50, 28)
        var cargo_color = Color(ORANGE.r, ORANGE.g, ORANGE.b, pulse)
        _draw_arrow(cargo_arrow_start, cargo_arrow_end, cargo_color)
        arrow_draw.draw_string(ThemeDB.fallback_font, cargo_arrow_start + Vector2(5, -10), 
            "📦 " + tr("TUT_CARGO_LABEL"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, cargo_color)
