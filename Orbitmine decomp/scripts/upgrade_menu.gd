extends Control








const GRID: float = 90.0
const NODE_SIZE: float = 56.0
const HALF_NODE: float = 28.0


const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 1.6
const ZOOM_STEP: float = 0.1


const C_PURCHASED: = Color(0.2, 0.85, 0.35)
const C_INPROGRESS: = Color(0.4, 0.95, 1.0)
const C_AVAILABLE: = Color(1.0, 0.85, 0.15)
const C_LOCKED: = Color(0.3, 0.3, 0.35)
const C_MECHANIC: = Color(0.9, 0.4, 0.1)
const C_BG: = Color(0.02, 0.02, 0.06)
const C_LINE_DONE: = Color(0.2, 0.75, 0.3, 0.6)
const C_LINE_ON: = Color(0.85, 0.8, 0.2, 0.7)
const C_LINE_DIM: = Color(0.25, 0.25, 0.3, 0.3)


const ICON_MAP: Dictionary = {
    "start": "☆", 

    "dmg": "⚔", "range": "◎", "speed": "»", 
    "time": "⏱", "fire_rate": "⏩", "barrier": "◕", 
    "resource": "💎", "value": "💲", 
    "critical": "🎯", 

    "electric": "⚡", "multi": "⊞", "gold": "💰", 
    "charged": "🔥", 

    "drone": "🤖", "drone_proto": "🤖", "drone_dmg": "🤖", "drone_deploy": "🤖", "drone_speed": "🤖", "drone_pierce": "🤖", 
    "chain": "🔗", "resonance": "💠", 
    "magnet": "🧲", "pickup": "🧲", 

    "mega": "🔆", "shockwave": "🌀", "overdrive": "💢", 

    "core_breaker": "💥", "final": "💠", 
    "combo": "🔥", "minimap": "📍", "cargo": "📦", 
    "fuel": "⛽", "fuel_safe": "💫", 
    "overheat": "🌡️", 

    "core:core_detect": "🔍", "core:brake": "🛑", 
    "core:barrier_regen": "🛡️", "core:spawn_direction": "🧭", 
    "core:return_shortcut": "⏱️", "core:core_focus": "🎯", 
    "core:emergency_return": "♻️", "core:center_unlock": "🟣", 
    "core:planet_mastery": "🌑", 
}


const CORE_CONNECTIONS: Dictionary = {
    "core:core_detect": [], 
    "core:brake": ["core:core_detect"], 
    "core:barrier_regen": ["core:brake"], 
    "core:spawn_direction": ["core:barrier_regen"], 
    "core:return_shortcut": ["core:spawn_direction"], 
    "core:core_focus": ["core:return_shortcut"], 
    "core:emergency_return": ["core:core_focus"], 
    "core:center_unlock": ["core:emergency_return"], 
    "core:planet_mastery": ["core:center_unlock"], 
}


var unified_layout: Dictionary = {}


var node_buttons: Dictionary = {}
var node_level_labels: Dictionary = {}
var canvas_offset: Vector2 = Vector2.ZERO
var zoom_level: float = 0.8
var is_panning: bool = false
var pan_start: Vector2 = Vector2.ZERO
var hovered_node_id: String = ""



var _style_cache: Dictionary = {}

var _core_style_cache: Dictionary = {}


var _save_timer: Timer = null


var tree_canvas: Control
var tooltip_panel: PanelContainer
var tooltip_icon: Label
var tooltip_name: Label
var tooltip_desc: Label
var tooltip_cost: Label
var currency_label: Label
var core_label: Label
var start_button: Button
var is_embedded_in_base: bool = false
var new_planet_btn: Button = null
var stats_btn: Button = null

const CORE_PREFIX: = "core:"
const C_CORE: = Color(1.0, 0.35, 0.25)
const C_CORE_LINE: = Color(1.0, 0.3, 0.2, 0.5)


const CORE_ORDER: Array = [
    "core_detect", "brake", "barrier_regen", "spawn_direction", 
    "return_shortcut", "core_focus", "emergency_return", "center_unlock", 
    "planet_mastery"
]
const CORE_CIRCLE_CENTER: = Vector2(-4.0, 4.0)
const CORE_CIRCLE_RADIUS: float = 3.2





func _ready():
    _build_layout()
    _init_style_cache()
    _init_save_timer()

    var bg: = ColorRect.new()
    bg.color = C_BG
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    tree_canvas = preload("res://scripts/tree_canvas.gd").new()
    tree_canvas.name = "TreeCanvas"
    var canvas_size: = _calc_canvas_size()
    tree_canvas.custom_minimum_size = canvas_size
    tree_canvas.size = canvas_size
    add_child(tree_canvas)

    _create_top_bar()
    _create_tooltip()


    if Global.tree_view_saved:
        canvas_offset = Global.tree_view_offset
        zoom_level = Global.tree_view_zoom
        _apply_canvas_transform()
    else:
        _center_on_start()
    _rebuild_tree()
    _update_top_bar()

    _show_sortie_result_banner()


    if Global.sortie_count == 1:
        _show_node_tutorial()


    if Global.planet_mastery_unlocked and Global.epilogue_shown and not Global.mastery_popup_shown:
        Global.mastery_popup_shown = true
        Global.save_game()
        call_deferred("_show_planet_mastery_popup")


    if Global.IS_DEMO and not Global.demo_ending_shown:
        if _is_spring_boss_dead():
            Global.demo_ending_shown = true
            _show_demo_ending()


func _exit_tree():
    Global.tree_view_offset = canvas_offset
    Global.tree_view_zoom = zoom_level
    Global.tree_view_saved = true





func _make_style_set(bg: Color, border: Color) -> Dictionary:
    var normal: = StyleBoxFlat.new()
    normal.set_corner_radius_all(4)
    normal.set_border_width_all(3)
    normal.bg_color = bg
    normal.border_color = border
    var hover: = StyleBoxFlat.new()
    hover.set_corner_radius_all(4)
    hover.set_border_width_all(3)
    hover.bg_color = bg.lightened(0.2)
    hover.border_color = border.lightened(0.2)
    var pressed: = StyleBoxFlat.new()
    pressed.set_corner_radius_all(4)
    pressed.set_border_width_all(3)
    pressed.bg_color = bg.lightened(0.35)
    pressed.border_color = border
    return {
        "normal": normal, "hover": hover, "pressed": pressed, 
        "font_color": border.lightened(0.3)
    }

func _init_style_cache():

    _style_cache["maxed"] = _make_style_set(Color(0.05, 0.2, 0.08), C_PURCHASED)
    _style_cache["inprogress"] = _make_style_set(Color(0.06, 0.15, 0.2), C_INPROGRESS)
    _style_cache["purchased"] = _make_style_set(Color(0.03, 0.06, 0.1), Color(0.15, 0.45, 0.55))
    _style_cache["mechanic"] = _make_style_set(Color(0.15, 0.08, 0.02), C_MECHANIC)
    _style_cache["available"] = _make_style_set(Color(0.12, 0.1, 0.03), C_AVAILABLE)
    _style_cache["locked"] = _make_style_set(Color(0.04, 0.04, 0.06), C_LOCKED)

    _core_style_cache["purchased"] = _make_style_set(Color(0.15, 0.06, 0.05), C_PURCHASED)
    _core_style_cache["can_buy"] = _make_style_set(Color(0.15, 0.05, 0.03), C_CORE)
    _core_style_cache["locked"] = _make_style_set(Color(0.06, 0.04, 0.04), Color(0.4, 0.2, 0.2))





func _init_save_timer():
    _save_timer = Timer.new()
    _save_timer.wait_time = 2.0
    _save_timer.one_shot = true
    _save_timer.timeout.connect(Global.save_game)
    add_child(_save_timer)


func _request_save():
    _save_timer.start()





func _build_layout():
    unified_layout.clear()







    for phase in Global.PHASE_NODE_ORDER:
        var order = Global.PHASE_NODE_ORDER[phase]
        var offset = Global.PHASE_OFFSETS[phase]
        var cols = Global.PHASE_COLS
        for i in range(order.size()):
            var col = i % cols
            var row = i / cols
            unified_layout[order[i]] = offset + Vector2(col * 2, row * 2)


    var node_count = CORE_ORDER.size()
    for i in range(node_count):
        var angle = - PI * 0.5 + i * (TAU / node_count)
        var grid_pos = CORE_CIRCLE_CENTER + Vector2(cos(angle), sin(angle)) * CORE_CIRCLE_RADIUS
        unified_layout["core:" + CORE_ORDER[i]] = grid_pos





func _create_top_bar():
    var bar: = HBoxContainer.new()
    bar.name = "TopBar"
    bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
    bar.offset_left = 16
    bar.offset_top = 10
    bar.offset_right = -16
    bar.offset_bottom = 50
    bar.add_theme_constant_override("separation", 20)
    add_child(bar)

    currency_label = Label.new()
    currency_label.add_theme_font_size_override("font_size", 22)
    currency_label.add_theme_color_override("font_color", C_AVAILABLE)
    bar.add_child(currency_label)

    core_label = Label.new()
    core_label.add_theme_font_size_override("font_size", 18)
    core_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    core_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    core_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    bar.add_child(core_label)

    start_button = Button.new()
    if is_embedded_in_base:
        start_button.text = tr("❌ 닫기")
    else:
        start_button.text = tr("🚀 출항")
    start_button.custom_minimum_size = Vector2(140, 36)
    start_button.add_theme_font_size_override("font_size", 16)
    start_button.pressed.connect(_on_start_pressed)
    bar.add_child(start_button)


    new_planet_btn = Button.new()
    new_planet_btn.text = tr("🌍 자유 행성") if Global.free_planet_mode else tr("🌍 새 행성")
    new_planet_btn.custom_minimum_size = Vector2(120, 36)
    new_planet_btn.add_theme_font_size_override("font_size", 16)
    new_planet_btn.pressed.connect(_on_new_planet_pressed)
    new_planet_btn.visible = Global.planet_mastery_unlocked
    bar.add_child(new_planet_btn)


    stats_btn = Button.new()
    stats_btn.text = tr("📊 통계")
    stats_btn.custom_minimum_size = Vector2(100, 36)
    stats_btn.add_theme_font_size_override("font_size", 16)
    stats_btn.pressed.connect(_on_stats_pressed)
    bar.add_child(stats_btn)



    var bar_bg: = StyleBoxFlat.new()
    bar_bg.bg_color = Color(0.0, 0.0, 0.0, 0.6)
    bar_bg.corner_radius_bottom_left = 8
    bar_bg.corner_radius_bottom_right = 8
    var bar_panel: = PanelContainer.new()
    bar_panel.add_theme_stylebox_override("panel", bar_bg)
    bar_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
    bar_panel.offset_bottom = 56
    bar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bar_panel)
    bar_panel.move_to_front()
    bar.move_to_front()





func _create_tooltip():
    tooltip_panel = PanelContainer.new()
    tooltip_panel.name = "Tooltip"
    tooltip_panel.visible = false
    tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tooltip_panel.z_index = 100

    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.0, 0.0, 0.02, 0.92)
    style.border_color = C_AVAILABLE
    style.set_border_width_all(2)
    style.set_corner_radius_all(4)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    tooltip_panel.add_theme_stylebox_override("panel", style)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    tooltip_panel.add_child(vbox)

    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 8)
    vbox.add_child(hbox)

    tooltip_icon = Label.new()
    tooltip_icon.add_theme_font_size_override("font_size", 20)
    hbox.add_child(tooltip_icon)

    tooltip_name = Label.new()
    tooltip_name.add_theme_font_size_override("font_size", 16)
    tooltip_name.add_theme_color_override("font_color", Color.WHITE)
    hbox.add_child(tooltip_name)

    var sep: = HSeparator.new()
    vbox.add_child(sep)

    tooltip_desc = Label.new()
    tooltip_desc.add_theme_font_size_override("font_size", 14)
    tooltip_desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
    tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tooltip_desc.custom_minimum_size.x = 220
    vbox.add_child(tooltip_desc)

    tooltip_cost = Label.new()
    tooltip_cost.add_theme_font_size_override("font_size", 15)
    tooltip_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(tooltip_cost)

    add_child(tooltip_panel)





func _input(event: InputEvent):

    var debug_nodes = get_tree().get_nodes_in_group("debug_menu")
    for dm in debug_nodes:
        if dm.has_method("is_mouse_over_panel") and dm.is_mouse_over_panel():
            return
    if event is InputEventMouseButton:
        var mb: = event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
            _zoom_at(mb.position, ZOOM_STEP)
            get_viewport().set_input_as_handled()
        elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _zoom_at(mb.position, - ZOOM_STEP)
            get_viewport().set_input_as_handled()
        elif mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
            is_panning = mb.pressed
            if mb.pressed:
                pan_start = mb.position

    if event is InputEventMouseMotion:
        var mm: = event as InputEventMouseMotion
        if is_panning:
            canvas_offset += mm.relative
            _apply_canvas_transform()

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseButton:
        var mb: = event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
            _hide_tooltip()

func _zoom_at(mouse_pos: Vector2, delta: float):
    var old_zoom: = zoom_level
    zoom_level = clamp(zoom_level + delta, ZOOM_MIN, ZOOM_MAX)
    if zoom_level == old_zoom:
        return
    var zoom_ratio: = zoom_level / old_zoom
    canvas_offset = mouse_pos - (mouse_pos - canvas_offset) * zoom_ratio
    _apply_canvas_transform()

func _apply_canvas_transform():
    tree_canvas.position = canvas_offset
    tree_canvas.scale = Vector2(zoom_level, zoom_level)

func _center_on_start():
    var viewport_size: = get_viewport_rect().size
    var start_pos: = _grid_to_pixel(unified_layout["start"])
    canvas_offset = viewport_size * 0.5 - start_pos * zoom_level
    _apply_canvas_transform()





func _is_node_visible(node_id: String) -> bool:
    return Global.is_node_visible(node_id)





func _is_mechanic_node(node_id: String) -> bool:
    var mechanic_ids = [
        "critical_hit", "multi1", 
        "electric_unlock", "gold_unlock", "charged_shot", "drone_proto", 
        "drone_deploy", "chain_unlock", "multi2", "magnet1", "drone_pierce", 
        "resonance_unlock", "shockwave_unlock", "overdrive1", 
        "mega_laser_unlock", "multi3", "core_breaker", 
    ]
    return node_id in mechanic_ids





func _is_core_node(node_id: String) -> bool:
    return node_id.begins_with(CORE_PREFIX)

func _get_core_uid(node_id: String) -> String:
    return node_id.trim_prefix(CORE_PREFIX)


func _is_core_tree_visible() -> bool:
    return Global.total_cores_destroyed > 0 or Global.purchased_core_upgrades.size() > 0 or Global.core_currency > 0

func _is_core_node_purchased(node_id: String) -> bool:
    return _get_core_uid(node_id) in Global.purchased_core_upgrades


func _is_core_node_visible(node_id: String) -> bool:
    if _is_core_node_purchased(node_id):
        return true

    if node_id == "core:core_detect":
        return true

    if CORE_CONNECTIONS.has(node_id):
        for req in CORE_CONNECTIONS[node_id]:
            if _is_core_node_purchased(req):
                return true
    return false

func _can_purchase_core_node(node_id: String) -> bool:
    var uid = _get_core_uid(node_id)
    if uid in Global.purchased_core_upgrades:
        return false
    var upgrade = Global.core_upgrades.get(uid)
    if not upgrade:
        return false
    if Global.core_currency < upgrade.cost:
        return false

    if CORE_CONNECTIONS.has(node_id):
        for req in CORE_CONNECTIONS[node_id]:
            if not _is_core_node_purchased(req):
                return false

    if uid == "planet_mastery" and not Global.can_purchase_planet_mastery():
        return false
    return true





func _rebuild_tree():
    for child in tree_canvas.get_children():
        child.queue_free()
    node_buttons.clear()
    node_level_labels.clear()

    for node_id in unified_layout:
        if _is_core_node(node_id):
            continue
        if _is_node_visible(node_id):
            _create_node_button(node_id)


    if _is_core_tree_visible():

        var title_pos = _grid_to_pixel(CORE_CIRCLE_CENTER)
        var title_label = Label.new()
        title_label.text = tr("CORE_REWARD_TITLE")
        title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title_label.position = title_pos - Vector2(60, 14)
        title_label.size = Vector2(120, 24)
        title_label.add_theme_font_size_override("font_size", 16)
        title_label.add_theme_color_override("font_color", C_CORE)
        tree_canvas.add_child(title_label)

        for node_id in unified_layout:
            if _is_core_node(node_id) and _is_core_node_visible(node_id):
                _create_core_node_button(node_id)

    tree_canvas.queue_redraw()

func _create_node_button(node_id: String):
    var node_data: Dictionary = Global.nodes.get(node_id, {})
    if node_data.is_empty():
        return

    var grid_pos: Vector2 = unified_layout.get(node_id, Vector2.ZERO)
    var pixel_pos: Vector2 = _grid_to_pixel(grid_pos)

    var btn: = Button.new()
    btn.custom_minimum_size = Vector2(NODE_SIZE, NODE_SIZE)
    btn.size = Vector2(NODE_SIZE, NODE_SIZE)
    btn.position = pixel_pos - Vector2(HALF_NODE, HALF_NODE)
    btn.text = _get_node_icon(node_id)
    btn.clip_text = false

    _apply_node_style(btn, node_id)

    btn.pivot_offset = Vector2(HALF_NODE, HALF_NODE)
    btn.pressed.connect(_on_node_clicked.bind(node_id))
    btn.mouse_entered.connect(_on_node_hover.bind(node_id))
    btn.mouse_exited.connect(_on_node_unhover.bind(node_id))

    tree_canvas.add_child(btn)
    node_buttons[node_id] = btn


    var max_level: int = node_data.get("max_level", 1)
    if max_level > 1:
        var level_label: = Label.new()
        var current_level: int = Global.get_node_level(node_id)
        level_label.text = str(current_level) + "/" + str(max_level)
        level_label.add_theme_font_size_override("font_size", 10)
        level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        level_label.position = Vector2(pixel_pos.x - 14, pixel_pos.y + HALF_NODE - 2)
        level_label.size = Vector2(28, 14)
        if current_level >= max_level:
            level_label.add_theme_color_override("font_color", C_PURCHASED)
        elif current_level > 0:
            level_label.add_theme_color_override("font_color", C_INPROGRESS)
        else:
            level_label.add_theme_color_override("font_color", C_LOCKED)
        tree_canvas.add_child(level_label)
        node_level_labels[node_id] = level_label


func _create_core_node_button(node_id: String):
    var uid = _get_core_uid(node_id)
    var upgrade = Global.core_upgrades.get(uid)
    if not upgrade:
        return



    var grid_pos = unified_layout.get(node_id, Vector2.ZERO)
    var pixel_pos = _grid_to_pixel(grid_pos)
    var purchased = _is_core_node_purchased(node_id)
    var can_buy = _can_purchase_core_node(node_id)

    var btn = Button.new()
    btn.custom_minimum_size = Vector2(NODE_SIZE, NODE_SIZE)
    btn.size = Vector2(NODE_SIZE, NODE_SIZE)
    btn.position = pixel_pos - Vector2(HALF_NODE, HALF_NODE)
    btn.text = ICON_MAP.get(node_id, "🔴")
    btn.clip_text = false


    var skey: String
    if purchased: skey = "purchased"
    elif can_buy: skey = "can_buy"
    else: skey = "locked"
    var s: Dictionary = _core_style_cache[skey]
    btn.add_theme_stylebox_override("normal", s["normal"])
    btn.add_theme_stylebox_override("hover", s["hover"])
    btn.add_theme_stylebox_override("pressed", s["pressed"])
    btn.add_theme_stylebox_override("disabled", s["normal"])
    btn.add_theme_stylebox_override("focus", s["normal"])
    btn.add_theme_font_size_override("font_size", 22)
    btn.add_theme_color_override("font_color", s["font_color"])

    btn.pivot_offset = Vector2(HALF_NODE, HALF_NODE)
    btn.pressed.connect(_on_node_clicked.bind(node_id))
    btn.mouse_entered.connect(_on_node_hover.bind(node_id))
    btn.mouse_exited.connect(_on_node_unhover.bind(node_id))

    tree_canvas.add_child(btn)
    node_buttons[node_id] = btn


    if not purchased:
        var cost_label = Label.new()
        cost_label.text = tr("CORE_COST_FMT") % upgrade.cost
        cost_label.add_theme_font_size_override("font_size", 9)
        cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        cost_label.position = Vector2(pixel_pos.x - 16, pixel_pos.y + HALF_NODE - 2)
        cost_label.size = Vector2(32, 12)
        cost_label.add_theme_color_override("font_color", C_CORE if can_buy else C_LOCKED)
        tree_canvas.add_child(cost_label)

func _get_node_icon(node_id: String) -> String:
    if node_id in ICON_MAP:
        return ICON_MAP[node_id]

    for key in ICON_MAP:
        if node_id.begins_with(key):
            return ICON_MAP[key]
    return "●"

func _apply_node_style(btn: Button, node_id: String):

    var key: String
    var is_purchased: = Global.is_node_purchased(node_id)
    var is_maxed: = Global.is_node_maxed(node_id)
    var is_available: = Global.can_purchase_node(node_id)
    if is_maxed:
        key = "maxed"
    elif is_purchased and is_available:
        key = "inprogress"
    elif is_purchased:
        key = "purchased"
    elif is_available:
        key = "mechanic" if _is_mechanic_node(node_id) else "available"
    else:
        key = "locked"

    var s: Dictionary = _style_cache[key]
    btn.add_theme_stylebox_override("normal", s["normal"])
    btn.add_theme_stylebox_override("hover", s["hover"])
    btn.add_theme_stylebox_override("pressed", s["pressed"])
    btn.add_theme_stylebox_override("disabled", s["normal"])
    btn.add_theme_stylebox_override("focus", s["normal"])
    btn.add_theme_font_size_override("font_size", 22)
    btn.add_theme_color_override("font_color", s["font_color"])





func get_connection_lines() -> Array:
    var lines: Array = []


    for phase in Global.PHASE_NODE_ORDER:
        if not Global.is_phase_unlocked(phase):
            continue
        var order = Global.PHASE_NODE_ORDER[phase]
        var cols = Global.PHASE_COLS
        var phase_color = Global.PHASE_COLORS.get(phase, Color.WHITE)

        for i in range(order.size()):
            var node_id = order[i]
            if not unified_layout.has(node_id):
                continue
            var col = i % cols
            var row = i / cols

            if col + 1 < cols:
                var ri = row * cols + (col + 1)
                if ri < order.size():
                    _add_adj_line(lines, node_id, order[ri], phase_color)

            var di = (row + 1) * cols + col
            if di < order.size():
                _add_adj_line(lines, node_id, order[di], phase_color)


    for phase in Global.PHASE_BRIDGES:
        var bridge = Global.PHASE_BRIDGES[phase]
        var gate_id = bridge.gate
        var entry_id = bridge.entry
        if not unified_layout.has(gate_id) or not unified_layout.has(entry_id):
            continue
        if not _is_node_visible(gate_id):
            continue
        var gate_pos = _grid_to_pixel(unified_layout[gate_id])
        var entry_pos = _grid_to_pixel(unified_layout[entry_id])
        var color: Color
        var width: float
        if Global.is_node_purchased(gate_id):
            color = C_LINE_ON
            width = 3.0
        else:
            color = C_LINE_DIM
            width = 1.5

        var mid_x: float
        if entry_pos.x < gate_pos.x:
            var gap = gate_pos.x - entry_pos.x
            if gap > GRID * 2:

                mid_x = (entry_pos.x + gate_pos.x) / 2.0
            else:

                mid_x = min(entry_pos.x, gate_pos.x) - GRID * 1.5
        else:
            mid_x = (gate_pos.x + entry_pos.x) / 2.0
        var mid1 = Vector2(mid_x, gate_pos.y)
        var mid2 = Vector2(mid_x, entry_pos.y)
        lines.append({"from": gate_pos, "to": mid1, "color": color, "width": width, "priority": 2})
        lines.append({"from": mid1, "to": mid2, "color": color, "width": width, "priority": 2})
        lines.append({"from": mid2, "to": entry_pos, "color": color, "width": width, "priority": 2})


    if _is_core_tree_visible():
        var center_px = _grid_to_pixel(CORE_CIRCLE_CENTER)
        var radius_px = CORE_CIRCLE_RADIUS * GRID
        var n = CORE_ORDER.size()
        for i in range(n - 1):
            var parent_id = "core:" + CORE_ORDER[i]
            var child_id = "core:" + CORE_ORDER[i + 1]
            if not unified_layout.has(parent_id) or not unified_layout.has(child_id):
                continue

            if not _is_core_node_visible(parent_id) or not _is_core_node_visible(child_id):
                continue
            var color: Color
            var width: float
            if _is_core_node_purchased(child_id):
                color = C_LINE_DONE
                width = 2.5
            elif _is_core_node_purchased(parent_id):
                color = C_CORE_LINE
                width = 2.0
            else:
                color = C_LINE_DIM
                width = 1.5

            var angle_from = - PI * 0.5 + i * (TAU / n)
            var angle_to = - PI * 0.5 + (i + 1) * (TAU / n)
            lines.append({
                "type": "arc", 
                "center": center_px, 
                "radius": radius_px, 
                "angle_start": angle_from, 
                "angle_end": angle_to, 
                "color": color, 
                "width": width, 
                "priority": 0, 
            })


        var last_id = "core:" + CORE_ORDER[n - 1]
        if _is_core_node_purchased(last_id):
            var angle_last = - PI * 0.5 + (n - 1) * (TAU / n)
            var angle_first = - PI * 0.5 + TAU
            lines.append({
                "type": "arc", 
                "center": center_px, 
                "radius": radius_px, 
                "angle_start": angle_last, 
                "angle_end": angle_first, 
                "color": C_LINE_DONE, 
                "width": 2.5, 
                "priority": 0, 
            })

    return lines


func _add_adj_line(lines: Array, id_a: String, id_b: String, phase_color: Color):

    if not _is_node_visible(id_a) or not _is_node_visible(id_b):
        return
    var a_pos = _grid_to_pixel(unified_layout[id_a])
    var b_pos = _grid_to_pixel(unified_layout[id_b])
    var a_bought = Global.is_node_purchased(id_a)
    var b_bought = Global.is_node_purchased(id_b)
    var color: Color
    var width: float
    if a_bought and b_bought:
        color = C_LINE_DONE
        width = 2.5
    elif a_bought or b_bought:
        color = phase_color * Color(1, 1, 1, 0.5)
        width = 2.0
    else:
        color = C_LINE_DIM
        width = 1.5
    lines.append({"from": a_pos, "to": b_pos, "color": color, "width": width, "priority": 0})

func _grid_to_pixel(grid_pos: Vector2) -> Vector2:
    return grid_pos * GRID + Vector2(HALF_NODE, HALF_NODE)

func _calc_canvas_size() -> Vector2:
    var max_x: float = 0
    var max_y: float = 0
    for pos in unified_layout.values():
        max_x = maxf(max_x, pos.x)
        max_y = maxf(max_y, pos.y)
    return Vector2((max_x + 4) * GRID, (max_y + 4) * GRID)




var _hover_tweens: Dictionary = {}

func _on_node_hover(node_id: String):
    hovered_node_id = node_id
    _show_tooltip(node_id)


    SoundManager.play("hover_tick")
    if node_buttons.has(node_id):
        var btn = node_buttons[node_id]

        if _hover_tweens.has(node_id) and _hover_tweens[node_id] != null:
            _hover_tweens[node_id].kill()
        var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        tw.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.12)
        _hover_tweens[node_id] = tw

func _on_node_unhover(node_id: String):
    if hovered_node_id == node_id:
        hovered_node_id = ""
        _hide_tooltip()


    if node_buttons.has(node_id):
        var btn = node_buttons[node_id]
        if _hover_tweens.has(node_id) and _hover_tweens[node_id] != null:
            _hover_tweens[node_id].kill()
        var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
        _hover_tweens[node_id] = tw

func _process(_delta: float):
    if tooltip_panel.visible:
        var mouse_pos: = get_global_mouse_position()
        var vp_size: = get_viewport_rect().size
        var tt_size: = tooltip_panel.size
        var pos: = mouse_pos + Vector2(16, 16)
        if pos.x + tt_size.x > vp_size.x - 10:
            pos.x = mouse_pos.x - tt_size.x - 16
        if pos.y + tt_size.y > vp_size.y - 10:
            pos.y = mouse_pos.y - tt_size.y - 16
        tooltip_panel.global_position = pos

func _show_tooltip(node_id: String):

    if _is_core_node(node_id):
        var uid = _get_core_uid(node_id)
        var upgrade = Global.core_upgrades.get(uid)
        if not upgrade:
            return
        var purchased = _is_core_node_purchased(node_id)
        var can_buy = _can_purchase_core_node(node_id)

        tooltip_icon.text = ICON_MAP.get(node_id, "🔴")
        tooltip_name.text = tr(upgrade.name)
        tooltip_desc.text = tr(upgrade.desc)

        if purchased:
            tooltip_cost.text = tr("✓ 해금 완료")
            tooltip_cost.add_theme_color_override("font_color", C_PURCHASED)
            _set_tooltip_border(C_PURCHASED)
        elif can_buy:
            tooltip_cost.text = tr("CORE_BUY_FMT") % upgrade.cost
            tooltip_cost.add_theme_color_override("font_color", C_CORE)
            _set_tooltip_border(C_CORE)
        else:

            if uid == "planet_mastery" and not Global.can_purchase_planet_mastery():
                var conditions: Array = []
                if not Global.planet_cleared:
                    conditions.append(tr("CORE_COND_ALLCORE_NO"))
                else:
                    conditions.append(tr("CORE_COND_ALLCORE_YES"))
                if not Global.planet_fully_destroyed:
                    conditions.append(tr("CORE_COND_PLANET_NO"))
                else:
                    conditions.append(tr("CORE_COND_PLANET_YES"))
                tooltip_cost.text = tr("CORE_COST_COND_FMT") % [upgrade.cost, "\n".join(conditions)]
            else:
                tooltip_cost.text = tr("CORE_COST_INSUFFICIENT") % upgrade.cost
            tooltip_cost.add_theme_color_override("font_color", Color(0.5, 0.25, 0.2))
            _set_tooltip_border(Color(0.5, 0.25, 0.2))

        tooltip_panel.visible = true
        return


    var node_data: Dictionary = Global.nodes.get(node_id, {})
    if node_data.is_empty():
        return

    var current_level: int = Global.get_node_level(node_id)
    var max_level: int = node_data.get("max_level", 1)
    var is_maxed: bool = current_level >= max_level
    var is_available: bool = Global.can_purchase_node(node_id)
    var cost: float = Global.get_node_cost(node_id)

    tooltip_icon.text = _get_node_icon(node_id)

    if max_level > 1:
        tooltip_name.text = tr(node_data.name) + "  [%d/%d]" % [current_level, max_level]
    else:
        tooltip_name.text = tr(node_data.name)

    tooltip_desc.text = tr(node_data.description)


    var cc = node_data.get("core_cost", 0)

    if is_maxed:
        tooltip_cost.text = tr("✓ 최대 레벨")
        tooltip_cost.add_theme_color_override("font_color", Color(0.1, 0.95, 0.3))
        _set_tooltip_border(Color(0.1, 0.95, 0.3))
    elif is_available:
        tooltip_cost.text = "💰 " + Global.format_number(cost) + " " + tr("NODE_CLICK_BUY")
        tooltip_cost.add_theme_color_override("font_color", C_AVAILABLE)
        _set_tooltip_border(C_AVAILABLE)
    else:
        if cc > 0 and Global.total_cores_destroyed < cc:
            tooltip_cost.text = "💰 " + Global.format_number(cost) + "\n" + tr("NODE_NEED_CORE") % [Global.total_cores_destroyed, cc]
        elif Global.currency < cost and current_level < max_level:
            tooltip_cost.text = "💰 " + Global.format_number(cost) + " " + tr("NODE_NO_CURRENCY")
        else:
            tooltip_cost.text = "💰 " + Global.format_number(cost) + " " + tr("NODE_NEED_PREREQ")
        tooltip_cost.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
        _set_tooltip_border(Color(0.5, 0.45, 0.1))

    tooltip_panel.visible = true

func _set_tooltip_border(color: Color):
    var s: = tooltip_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
    s.border_color = color
    tooltip_panel.add_theme_stylebox_override("panel", s)

func _hide_tooltip():
    tooltip_panel.visible = false





func _on_node_clicked(node_id: String):

    if _is_core_node(node_id):
        if _is_core_node_purchased(node_id):
            return
        var uid = _get_core_uid(node_id)
        if Global.purchase_core_upgrade(uid):
            SoundManager.play("purchase")
            _animating_nodes.append(node_id)
            _shake_node_button(node_id)
            _targeted_refresh(node_id)
            _update_top_bar()
            if hovered_node_id == node_id:
                _show_tooltip(node_id)
            _request_save()

            if uid == "planet_mastery":
                SteamManager.unlock("ACH_FULL_CLEAR")
                Global.planet_fully_destroyed = true
                Global.save_game()
                ScreenFX.transition_to("res://scenes/sortie_result.tscn")
        else:
            SoundManager.play("ui_click")
        return


    if Global.is_node_maxed(node_id):
        return

    var success: bool = Global.purchase_node(node_id)
    if success:
        SoundManager.play("purchase")
        _animating_nodes.append(node_id)
        _shake_node_button(node_id)
        _targeted_refresh(node_id)
        _update_top_bar()
        if hovered_node_id == node_id:
            _show_tooltip(node_id)
        _request_save()

        if node_id == "minimap":
            _show_minimap_legend()
    else:
        SoundManager.play("ui_click")


var _animating_nodes: Array = []
var _purchase_tweens: Dictionary = {}




func _update_level_label(node_id: String):
    if not node_level_labels.has(node_id):
        return
    var label: Label = node_level_labels[node_id]
    if not is_instance_valid(label):
        return
    var node_data = Global.nodes.get(node_id, {})
    if node_data.is_empty():
        return
    var current_level = Global.get_node_level(node_id)
    var max_level = node_data.get("max_level", 1)
    label.text = str(current_level) + "/" + str(max_level)
    if current_level >= max_level:
        label.add_theme_color_override("font_color", C_PURCHASED)
    elif current_level > 0:
        label.add_theme_color_override("font_color", C_INPROGRESS)
    else:
        label.add_theme_color_override("font_color", C_LOCKED)


func _targeted_refresh(purchased_id: String):

    _update_level_label(purchased_id)

    if _is_core_node(purchased_id):

        for nid in CORE_CONNECTIONS:
            if purchased_id in CORE_CONNECTIONS[nid]:
                if nid in node_buttons and is_instance_valid(node_buttons[nid]):
                    _apply_core_node_style(node_buttons[nid], nid)
                elif nid not in node_buttons:
                    _create_core_node_button(nid)
    else:

        var node_data = Global.nodes.get(purchased_id, {})
        var phase = node_data.get("phase", 0)
        var order = Global.PHASE_NODE_ORDER.get(phase, [])
        var idx = order.find(purchased_id)
        if idx >= 0:
            var cols = Global.PHASE_COLS
            var col = idx % cols
            var row = idx / cols

            for dir in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
                var nc = col + int(dir.x)
                var nr = row + int(dir.y)
                if nc < 0 or nc >= cols or nr < 0: continue
                var ni = nr * cols + nc
                if ni < 0 or ni >= order.size(): continue
                var nid = order[ni]
                if nid in node_buttons and is_instance_valid(node_buttons[nid]):
                    _apply_node_style(node_buttons[nid], nid)
                elif _is_node_visible(nid) and nid not in node_buttons:
                    _create_node_button(nid)

        for p in Global.PHASE_BRIDGES:
            var bridge = Global.PHASE_BRIDGES[p]
            if bridge.gate == purchased_id:
                var entry_id = bridge.entry
                if entry_id in node_buttons and is_instance_valid(node_buttons[entry_id]):
                    _apply_node_style(node_buttons[entry_id], entry_id)
                elif _is_node_visible(entry_id) and entry_id not in node_buttons:
                    _create_node_button(entry_id)



    for nid in node_buttons:
        if nid == purchased_id or nid in _animating_nodes:
            continue
        if _is_core_node(nid):
            if not _is_core_node_purchased(nid) and is_instance_valid(node_buttons[nid]):
                _apply_core_node_style(node_buttons[nid], nid)
        else:
            if not Global.is_node_maxed(nid) and is_instance_valid(node_buttons[nid]):
                _apply_node_style(node_buttons[nid], nid)


    tree_canvas.queue_redraw()


func _apply_core_node_style(btn: Button, node_id: String):
    var key: String
    if _is_core_node_purchased(node_id):
        key = "purchased"
    elif _can_purchase_core_node(node_id):
        key = "can_buy"
    else:
        key = "locked"

    var s: Dictionary = _core_style_cache[key]
    btn.add_theme_stylebox_override("normal", s["normal"])
    btn.add_theme_stylebox_override("hover", s["hover"])
    btn.add_theme_stylebox_override("pressed", s["pressed"])
    btn.add_theme_stylebox_override("disabled", s["normal"])
    btn.add_theme_stylebox_override("focus", s["normal"])
    btn.add_theme_color_override("font_color", s["font_color"])


func _shake_node_button(node_id: String):
    if not node_buttons.has(node_id):
        _animating_nodes.erase(node_id)
        return
    var btn: Button = node_buttons[node_id]
    if not is_instance_valid(btn):
        _animating_nodes.erase(node_id)
        return


    if _purchase_tweens.has(node_id):
        for tw in _purchase_tweens[node_id]:
            if tw and tw.is_valid():
                tw.kill()
    if _hover_tweens.has(node_id) and _hover_tweens[node_id] != null:
        _hover_tweens[node_id].kill()


    var grid_pos = unified_layout.get(node_id, Vector2.ZERO)
    var original_pos = _grid_to_pixel(grid_pos) - Vector2(HALF_NODE, HALF_NODE)


    if _is_core_node(node_id):
        _apply_core_node_style(btn, node_id)
    else:
        _apply_node_style(btn, node_id)


    btn.scale = Vector2(1.6, 1.6)
    var sc_tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    sc_tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.5)


    btn.position = original_pos + Vector2(0, -25)
    var pos_tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    pos_tw.tween_property(btn, "position", original_pos, 0.5)


    btn.modulate = Color(3.0, 3.0, 3.0, 1.0)
    var mod_tw = create_tween()
    mod_tw.tween_property(btn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)


    _purchase_tweens[node_id] = [sc_tw, pos_tw, mod_tw]


    sc_tw.finished.connect( func():
        _animating_nodes.erase(node_id)
        _purchase_tweens.erase(node_id)
        if node_buttons.has(node_id) and is_instance_valid(node_buttons[node_id]):
            if _is_core_node(node_id):
                _apply_core_node_style(node_buttons[node_id], node_id)
            else:
                _apply_node_style(node_buttons[node_id], node_id)
    )





func _show_sortie_result_banner():
    if Global.sortie_blocks_destroyed == 0 and Global.sortie_ore_count == 0:
        return

    var banner = Panel.new()
    banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
    banner.offset_left = -200
    banner.offset_right = 200
    banner.offset_top = 50
    banner.offset_bottom = 120

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.border_color = Color(0.2, 0.8, 1.0, 0.8)
    banner.add_theme_stylebox_override("panel", style)
    banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(banner)

    var vbox = VBoxContainer.new()
    vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vbox.add_theme_constant_override("separation", 4)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    banner.add_child(vbox)

    var title = Label.new()
    title.text = tr("SORTIE_COMPLETE_FMT") % Global.sortie_count
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(title)

    var detail = Label.new()
    var sell_earned = Global.sortie_resources * Global.ore_sell_rate
    var text = tr("SORTIE_INCOME_FMT") % [
        Global.format_number(sell_earned), 
        Global.sortie_blocks_destroyed
    ]
    if Global.sortie_cores_destroyed > 0:
        text += "  " + tr("SORTIE_CORES_FMT") % Global.sortie_cores_destroyed
    detail.text = text
    detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    detail.add_theme_font_size_override("font_size", 15)
    detail.add_theme_color_override("font_color", Color.WHITE)
    detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(detail)

    banner.modulate.a = 1.0
    var tween = create_tween()
    tween.tween_interval(3.0)
    tween.tween_property(banner, "modulate:a", 0.0, 0.4)
    tween.tween_callback(banner.queue_free)





func _update_top_bar():
    currency_label.text = tr("CURRENCY_FMT") % Global.format_number(Global.currency)
    if Global.total_cores_destroyed > 0 or Global.core_currency > 0:
        core_label.text = tr("CORE_CURRENCY_FMT") % Global.core_currency
    else:
        core_label.text = tr("SORTIE_NUM") % Global.sortie_count

    if new_planet_btn:
        new_planet_btn.visible = Global.planet_mastery_unlocked


func _on_start_pressed():
    SoundManager.play("ui_click")
    if _save_timer.time_left > 0:
        _save_timer.stop()
        Global.save_game()

    if is_embedded_in_base:

        visible = false
    else:
        ScreenFX.transition_to("res://scenes/mining_scene.tscn")


func _on_stats_pressed():
    SoundManager.play("ui_click")
    if _save_timer.time_left > 0:
        _save_timer.stop()
        Global.save_game()
    ScreenFX.transition_to("res://scenes/stats_page.tscn")



func _on_new_planet_pressed():

    var overlay = ColorRect.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.color = Color(0.01, 0.01, 0.03, 0.92)
    overlay.z_index = 90
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)
    var lbl = Label.new()
    lbl.text = tr("LOADING_PLANET")
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    lbl.set_anchors_preset(Control.PRESET_CENTER)
    lbl.offset_left = -200
    lbl.offset_right = 200
    lbl.offset_top = -20
    lbl.offset_bottom = 20
    lbl.add_theme_font_size_override("font_size", 22)
    lbl.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
    overlay.add_child(lbl)
    await get_tree().process_frame

    await Global.regenerate_planet()

    overlay.queue_free()
    _rebuild_tree()
    _update_top_bar()





func _show_node_tutorial():
    var overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.5)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -200
    panel.offset_right = 200
    panel.offset_top = -90
    panel.offset_bottom = 90

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.02, 0.02, 0.06, 0.92)
    style.border_color = Color(0.3, 1.0, 1.2, 0.6)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 24
    style.content_margin_right = 24
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = tr("TUT_NODE_TITLE")
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color(0.5, 1.8, 2.0))
    vbox.add_child(title)

    var desc = RichTextLabel.new()
    desc.bbcode_enabled = true
    desc.text = tr("TUT_NODE_DESC")
    desc.add_theme_font_size_override("normal_font_size", 15)
    desc.add_theme_color_override("default_color", Color(0.9, 0.92, 0.95))
    desc.scroll_active = false
    desc.fit_content = true
    desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(desc)

    var hint = Label.new()
    hint.text = tr("TUT_HINT")
    hint.add_theme_font_size_override("font_size", 13)
    hint.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
    vbox.add_child(hint)


    overlay.gui_input.connect( func(event):
        if event is InputEventMouseButton and event.pressed:
            overlay.queue_free()
    )


func _show_planet_mastery_popup():
    var overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.5)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -220
    panel.offset_right = 220
    panel.offset_top = -90
    panel.offset_bottom = 90

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.02, 0.02, 0.06, 0.92)
    style.border_color = Color(1.0, 0.85, 0.2, 0.6)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 28
    style.content_margin_right = 28
    style.content_margin_top = 20
    style.content_margin_bottom = 20
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12)
    panel.add_child(vbox)


    var title = Label.new()
    title.text = "🌑 " + tr("MASTERY_POPUP_TITLE")
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)


    var desc = Label.new()
    desc.text = tr("MASTERY_POPUP_DESC")
    desc.add_theme_font_size_override("font_size", 15)
    desc.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.custom_minimum_size = Vector2(380, 0)
    vbox.add_child(desc)


    var hint = Label.new()
    hint.text = tr("TUT_HINT")
    hint.add_theme_font_size_override("font_size", 13)
    hint.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(hint)

    overlay.gui_input.connect( func(event):
        if event is InputEventMouseButton and event.pressed:
            overlay.queue_free()
    )





func _is_spring_boss_dead() -> bool:
    if not Global.planet_data:
        return false
    for core in Global.planet_data.cores:
        if core.id == Global.DEMO_BOSS_CORE_ID:
            return not core.alive
    return false

func _show_demo_ending():
    var overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.6)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -200
    panel.offset_right = 200
    panel.offset_top = -80
    panel.offset_bottom = 80

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.02, 0.02, 0.06, 0.95)
    style.border_color = Color(0.2, 0.85, 1.0, 0.6)
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    style.content_margin_left = 30
    style.content_margin_right = 30
    style.content_margin_top = 24
    style.content_margin_bottom = 24
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 14)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = tr("DEMO_END_TITLE")
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
    vbox.add_child(title)

    var msg = Label.new()
    msg.text = tr("DEMO_END_MSG")
    msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    msg.autowrap_mode = TextServer.AUTOWRAP_WORD
    msg.add_theme_font_size_override("font_size", 16)
    msg.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
    vbox.add_child(msg)

    var steam_btn = Button.new()
    steam_btn.text = tr("DEMO_END_WISHLIST")
    steam_btn.add_theme_font_size_override("font_size", 16)
    var steam_style = StyleBoxFlat.new()
    steam_style.bg_color = Color(0.05, 0.25, 0.45, 0.9)
    steam_style.set_border_width_all(1)
    steam_style.border_color = Color(0.2, 0.85, 1.0, 0.5)
    steam_style.set_corner_radius_all(6)
    steam_btn.add_theme_stylebox_override("normal", steam_style)
    var steam_hover = steam_style.duplicate()
    steam_hover.bg_color = Color(0.08, 0.35, 0.6, 0.95)
    steam_btn.add_theme_stylebox_override("hover", steam_hover)
    steam_btn.pressed.connect( func():
        OS.shell_open("https://store.steampowered.com/app/4489770")
    )
    vbox.add_child(steam_btn)

    var btn = Button.new()
    btn.text = tr("DEMO_END_MENU")
    btn.add_theme_font_size_override("font_size", 16)
    btn.pressed.connect( func():
        ScreenFX.transition_to("res://scenes/main_menu.tscn")
    )
    vbox.add_child(btn)





func _show_minimap_legend():
    var overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.5)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = -180
    panel.offset_right = 180
    panel.offset_top = -80
    panel.offset_bottom = 80

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.02, 0.02, 0.06, 0.92)
    style.border_color = Color(0.3, 1.0, 1.2, 0.6)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 24
    style.content_margin_right = 24
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = tr("MINIMAP_LEGEND_TITLE")
    title.add_theme_font_size_override("font_size", 20)
    title.add_theme_color_override("font_color", Color(0.5, 1.8, 2.0))
    vbox.add_child(title)


    var legends = [
        {"color": Color(2.0, 0.3, 0.08), "text": tr("MINIMAP_CORE_ALIVE")}, 
        {"color": Color(0.4, 0.4, 0.45), "text": tr("MINIMAP_CORE_LOCKED")}, 
        {"color": Color(0.15, 0.8, 1.0), "text": tr("MINIMAP_CORE_DEAD")}, 
    ]
    for entry in legends:
        var hbox = HBoxContainer.new()
        hbox.add_theme_constant_override("separation", 10)
        var dot = ColorRect.new()
        dot.custom_minimum_size = Vector2(14, 14)
        dot.color = entry.color
        hbox.add_child(dot)
        var lbl = Label.new()
        lbl.text = entry.text
        lbl.add_theme_font_size_override("font_size", 15)
        lbl.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
        hbox.add_child(lbl)
        vbox.add_child(hbox)

    var hint = Label.new()
    hint.text = tr("TUT_HINT")
    hint.add_theme_font_size_override("font_size", 13)
    hint.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
    vbox.add_child(hint)

    overlay.gui_input.connect( func(event):
        if event is InputEventMouseButton and event.pressed:
            overlay.queue_free()
    )
