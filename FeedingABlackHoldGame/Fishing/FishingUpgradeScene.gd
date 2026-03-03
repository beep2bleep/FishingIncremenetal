extends Control

const CELL_SIZE := Vector2(180, 180)
const NODE_SIZE := Vector2(76, 76)
const TREE_CENTER := Vector2(4600, 4600)
const PAN_SPEED := 1400.0
const STAR_COUNT := 150

const COLOR_BG := Color(0.03, 0.035, 0.05, 1.0)
const COLOR_PANEL := Color(0.04, 0.05, 0.09, 0.92)
const COLOR_TEXT := Color(0.94, 0.94, 0.98, 1.0)
const COLOR_LINE := Color(0.95, 0.95, 1.0, 0.92)
const COLOR_COMPLETE := Color(0.14, 0.96, 0.31, 1.0)
const COLOR_AVAILABLE := Color(0.99, 0.93, 0.18, 1.0)
const COLOR_AFFORDABLE_OFF := Color(0.9, 0.25, 0.25, 1.0)
const COLOR_LOCKED := Color(0.26, 0.26, 0.32, 1.0)

var db: FishingUpgradeDB = FishingUpgradeDB.new()
var button_by_id: Dictionary = {}
var scroll_container: ScrollContainer
var node_grid_pos: Dictionary = {}
var drag_panning := false

var currency_label: Label
var info_label: Label
var tree_layer: Control
var stars_layer: Control
var hover_card: PanelContainer
var hover_title: Label
var hover_meta: Label
var hover_desc: Label
var hover_cost: Label
var line_layer: Node2D
var hovered_node_id: String = ""
var editor_add_currency_button: Button
var editor_reset_progress_button: Button
var unlock_all_upgrades_button: Button
var editor_add_amount: int = 1000
var rng := RandomNumberGenerator.new()

var node_style_complete: StyleBoxFlat
var node_style_available: StyleBoxFlat
var node_style_not_affordable: StyleBoxFlat
var node_style_locked: StyleBoxFlat

func _ready() -> void:
    currency_label = get_node_or_null("%CurrencyLabel")
    if currency_label == null:
        currency_label = get_node_or_null("CurrencyLabel")

    info_label = get_node_or_null("%InfoLabel")
    if info_label == null:
        info_label = get_node_or_null("InfoLabel")

    tree_layer = get_node_or_null("%TreeLayer")
    if tree_layer == null:
        tree_layer = get_node_or_null("ScrollContainer/TreeLayer")
    scroll_container = get_node_or_null("ScrollContainer")
    stars_layer = get_node_or_null("%Stars")
    if stars_layer == null:
        stars_layer = get_node_or_null("Stars")
    hover_card = get_node_or_null("%HoverCard")
    if hover_card == null:
        hover_card = get_node_or_null("HoverCard")
    hover_title = get_node_or_null("%HoverTitle")
    if hover_title == null:
        hover_title = get_node_or_null("HoverCard/CardMargin/CardVBox/HoverTitle")
    hover_meta = get_node_or_null("%HoverMeta")
    if hover_meta == null:
        hover_meta = get_node_or_null("HoverCard/CardMargin/CardVBox/HoverMeta")
    hover_desc = get_node_or_null("%HoverDesc")
    if hover_desc == null:
        hover_desc = get_node_or_null("HoverCard/CardMargin/CardVBox/HoverDesc")
    hover_cost = get_node_or_null("%HoverCost")
    if hover_cost == null:
        hover_cost = get_node_or_null("HoverCard/CardMargin/CardVBox/HoverCost")
    editor_add_currency_button = get_node_or_null("EditorAddCurrency")
    if editor_add_currency_button == null:
        editor_add_currency_button = get_node_or_null("EditorRow/EditorAddCurrency")
    editor_reset_progress_button = get_node_or_null("EditorResetProgress")
    if editor_reset_progress_button == null:
        editor_reset_progress_button = get_node_or_null("EditorRow/EditorResetProgress")
    unlock_all_upgrades_button = get_node_or_null("UnlockAllUpgrades")
    if unlock_all_upgrades_button == null:
        unlock_all_upgrades_button = get_node_or_null("EditorRow/UnlockAllUpgrades")

    if currency_label == null or info_label == null or tree_layer == null or scroll_container == null or editor_add_currency_button == null or editor_reset_progress_button == null or unlock_all_upgrades_button == null or stars_layer == null or hover_card == null:
        # This script is also referenced from Main Menu background. In that context,
        # the upgrade-scene node tree is intentionally absent.
        set_process_unhandled_input(false)
        set_process(false)
        return

    _build_styles()
    _style_shell_ui()
    _refresh_starfield()
    _setup_editor_buttons()
    set_process_unhandled_input(true)
    set_process(true)
    _build_tree()
    call_deferred("_center_scroll")
    _refresh_ui()

func _build_tree() -> void:
    for child in tree_layer.get_children():
        child.queue_free()
    button_by_id.clear()
    node_grid_pos.clear()
    line_layer = Node2D.new()
    line_layer.name = "Lines"
    tree_layer.add_child(line_layer)

    var spiral_state: Dictionary = {
        "x": 0,
        "y": 0,
        "step_size": 1,
        "step_progress": 0,
        "dir_index": 0,
        "legs_done": 0,
    }

    var max_abs: int = 1
    for index in range(db.nodes.size()):
        var node: Dictionary = db.nodes[index]
        var node_id: String = str(node.get("id", ""))
        var dep_id: String = str(node.get("dependency", ""))
        var grid: Vector2i

        if index == 0:
            grid = Vector2i.ZERO
        elif dep_id != "" and node_grid_pos.has(dep_id):
            var dep_pos: Vector2i = node_grid_pos[dep_id]
            if bool(node.get("is_level_node", false)):
                var level: int = int(node.get("level", 1))
                var group_pos: int = ((level - 2) % 5) + 1
                var dirs: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
                grid = dep_pos + dirs[(group_pos - 1) % 4]
            else:
                grid = _next_spiral(spiral_state)
        else:
            grid = _next_spiral(spiral_state)

        node_grid_pos[node_id] = grid
        max_abs = maxi(max_abs, maxi(abs(grid.x), abs(grid.y)))

    _build_connection_lines()

    for node in db.nodes:
        var button: Button = Button.new()
        var node_id: String = str(node.get("id", ""))
        var level: int = int(node.get("level", 1))
        var grid: Vector2i = node_grid_pos[node_id]
        var icon_tex: Texture2D = _resolve_node_icon_texture(node)
        var icon_fallback: String = _resolve_icon_text(node)

        button.text = icon_fallback if icon_tex == null else ""
        button.custom_minimum_size = NODE_SIZE
        button.size = NODE_SIZE
        button.position = TREE_CENTER + Vector2(grid) * CELL_SIZE - (NODE_SIZE * 0.5)
        button.pressed.connect(_on_upgrade_pressed.bind(node_id))
        button.mouse_entered.connect(_on_upgrade_hovered.bind(node_id))
        button.mouse_exited.connect(_on_upgrade_unhovered.bind(node_id))
        button.focus_entered.connect(_on_upgrade_hovered.bind(node_id))
        button.z_index = 2
        button.flat = false
        button.clip_text = true
        button.icon = icon_tex
        button.expand_icon = true
        button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
        button.alignment = HORIZONTAL_ALIGNMENT_CENTER
        button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
        button.focus_mode = Control.FOCUS_ALL
        button.add_theme_color_override("font_color", COLOR_TEXT)
        button.add_theme_color_override("font_focus_color", COLOR_TEXT)
        button.add_theme_color_override("font_hover_color", COLOR_TEXT)
        button.add_theme_font_size_override("font_size", 13)
        button.add_theme_constant_override("h_separation", 0)
        button.add_theme_constant_override("icon_max_width", 52)
        button.add_theme_stylebox_override("hover", _node_hover_style())
        button.add_theme_stylebox_override("pressed", _node_hover_style())

        if level > 1:
            var tier_label: Label = Label.new()
            tier_label.text = "L%d" % level
            tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
            tier_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
            tier_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
            tier_label.position = Vector2(6, 54)
            tier_label.size = Vector2(64, 16)
            tier_label.add_theme_color_override("font_color", Color(0.84, 0.88, 1.0, 0.9))
            tier_label.add_theme_font_size_override("font_size", 9)
            button.add_child(tier_label)

        tree_layer.add_child(button)
        button_by_id[node_id] = button
    tree_layer.custom_minimum_size = Vector2((max_abs * 2 + 16) * CELL_SIZE.x, (max_abs * 2 + 16) * CELL_SIZE.y)

func _next_spiral(state: Dictionary) -> Vector2i:
    var dirs: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
    var dir: Vector2i = dirs[int(state["dir_index"])]
    state["x"] = int(state["x"]) + dir.x
    state["y"] = int(state["y"]) + dir.y
    state["step_progress"] = int(state["step_progress"]) + 1
    if int(state["step_progress"]) >= int(state["step_size"]):
        state["step_progress"] = 0
        state["dir_index"] = (int(state["dir_index"]) + 1) % 4
        state["legs_done"] = int(state["legs_done"]) + 1
        if int(state["legs_done"]) % 2 == 0:
            state["step_size"] = int(state["step_size"]) + 1
    return Vector2i(int(state["x"]), int(state["y"]))

func _refresh_ui() -> void:
    currency_label.text = "o %d" % SaveHandler.fishing_currency
    if editor_add_currency_button != null:
        editor_add_currency_button.text = "Add $%d (Editor)" % editor_add_amount
    var unlocked_count: int = SaveHandler.fishing_unlocked_upgrades.keys().size()
    var base_info: String = "Unlocked %d/%d  |  Drag middle mouse or use WASD/arrows" % [unlocked_count, db.nodes.size()]
    if hovered_node_id != "" and db.node_by_id.has(hovered_node_id):
        var hovered_node: Dictionary = db.node_by_id[hovered_node_id]
        var state_text: String = _get_node_state_text(hovered_node)
        info_label.text = "%s  |  %s (%s)" % [base_info, db.get_display_name(hovered_node), state_text]
    else:
        info_label.text = base_info

    for node in db.nodes:
        var node_id: String = str(node.get("id", ""))
        if not button_by_id.has(node_id):
            continue
        var button: Button = button_by_id[node_id]
        if db.is_owned(node):
            button.disabled = true
            button.add_theme_stylebox_override("normal", node_style_complete)
            button.add_theme_color_override("font_color", COLOR_COMPLETE)
        elif db.can_buy(node):
            button.disabled = false
            button.add_theme_stylebox_override("normal", node_style_available)
            button.add_theme_color_override("font_color", COLOR_AVAILABLE)
        elif db.is_dependency_met(node):
            button.disabled = true
            button.add_theme_stylebox_override("normal", node_style_not_affordable)
            button.add_theme_color_override("font_color", COLOR_AFFORDABLE_OFF)
        else:
            button.disabled = true
            button.add_theme_stylebox_override("normal", node_style_locked)
            button.add_theme_color_override("font_color", COLOR_LOCKED)

    _update_hover_card()

func _on_upgrade_pressed(node_id: String) -> void:
    if not db.node_by_id.has(node_id):
        return
    if db.buy(db.node_by_id[node_id]):
        _refresh_ui()

func _on_upgrade_hovered(node_id: String) -> void:
    hovered_node_id = node_id
    _refresh_ui()

func _on_upgrade_unhovered(node_id: String) -> void:
    if hovered_node_id == node_id:
        hovered_node_id = ""
        _refresh_ui()

func _build_upgrade_tooltip(node: Dictionary) -> String:
    var dep_id: String = str(node.get("dependency", ""))
    if dep_id == "":
        dep_id = "None"
    var cost: int = int(round(float(node.get("cost", 0.0))))
    return "%s\n%s\n\nCost: $%d\nDependency: %s\nStatus: %s" % [
        db.get_display_name(node),
        db.get_description(node),
        cost,
        dep_id,
        _get_node_state_text(node),
    ]

func _get_node_state_text(node: Dictionary) -> String:
    if db.is_owned(node):
        return "Owned"
    if db.can_buy(node):
        return "Available"
    if db.is_dependency_met(node):
        return "Locked (insufficient currency)"
    return "Locked (dependency not met)"

func _on_start_battle_pressed() -> void:
    SceneChanger.change_to_new_scene("res://Fishing/BattleScene.tscn")

func _on_main_menu_pressed() -> void:
    SceneChanger.change_to_new_scene(Util.PATH_MAIN_MENU)

func _setup_editor_buttons() -> void:
    var editor_mode: bool = OS.has_feature("editor")
    editor_add_currency_button.visible = editor_mode
    editor_reset_progress_button.visible = true
    unlock_all_upgrades_button.visible = true
    editor_add_currency_button.disabled = not editor_mode
    editor_reset_progress_button.disabled = false
    unlock_all_upgrades_button.disabled = false
    editor_add_amount = 1000
    if editor_mode:
        editor_add_currency_button.text = "Add $%d (Editor)" % editor_add_amount
    if editor_reset_progress_button != null:
        editor_reset_progress_button.text = "Reset Save"

func _on_editor_add_currency_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    SaveHandler.fishing_currency += editor_add_amount
    SaveHandler.save_fishing_progress()
    editor_add_amount *= 2
    _refresh_ui()

func _on_editor_reset_progress_pressed() -> void:
    SaveHandler.reset_fishing_progress()
    SaveHandler.save_fishing_progress()
    editor_add_amount = 1000
    _refresh_ui()

func _on_unlock_all_upgrades_pressed() -> void:
    var max_level_by_key: Dictionary = {}
    for node_variant in db.nodes:
        var node: Dictionary = node_variant
        var key: String = str(node.get("key", ""))
        if key == "":
            continue
        var level: int = int(node.get("level", 1))
        if not max_level_by_key.has(key) or level > int(max_level_by_key[key]):
            max_level_by_key[key] = level

    SaveHandler.fishing_unlocked_upgrades = {}
    SaveHandler.fishing_active_upgrades = {}
    for key_variant in max_level_by_key.keys():
        var key: String = str(key_variant)
        var level: int = int(max_level_by_key[key_variant])
        SaveHandler.fishing_unlocked_upgrades[key] = level
        SaveHandler.fishing_active_upgrades[key] = true

    SaveHandler.save_fishing_progress()
    _refresh_ui()

func _center_scroll() -> void:
    var viewport_size: Vector2 = scroll_container.size
    scroll_container.scroll_horizontal = int(max(0.0, TREE_CENTER.x - viewport_size.x * 0.5))
    scroll_container.scroll_vertical = int(max(0.0, TREE_CENTER.y - viewport_size.y * 0.5))

func _process(delta: float) -> void:
    if scroll_container == null:
        return
    var input_vec: Vector2 = Vector2(
        Input.get_axis("left", "right"),
        Input.get_axis("up", "down")
    )
    if input_vec != Vector2.ZERO:
        scroll_container.scroll_horizontal = int(max(0, scroll_container.scroll_horizontal + input_vec.x * PAN_SPEED * delta))
        scroll_container.scroll_vertical = int(max(0, scroll_container.scroll_vertical + input_vec.y * PAN_SPEED * delta))

func _unhandled_input(event: InputEvent) -> void:
    if scroll_container == null:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
        drag_panning = event.pressed
    elif event is InputEventMouseMotion and drag_panning:
        scroll_container.scroll_horizontal = int(max(0, scroll_container.scroll_horizontal - event.relative.x))
        scroll_container.scroll_vertical = int(max(0, scroll_container.scroll_vertical - event.relative.y))

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _refresh_starfield()

func _build_styles() -> void:
    node_style_complete = _make_node_style(COLOR_COMPLETE, Color(0.01, 0.05, 0.02, 0.98))
    node_style_available = _make_node_style(COLOR_AVAILABLE, Color(0.08, 0.07, 0.01, 0.98))
    node_style_not_affordable = _make_node_style(COLOR_AFFORDABLE_OFF, Color(0.07, 0.015, 0.015, 0.98))
    node_style_locked = _make_node_style(COLOR_LOCKED, Color(0.03, 0.035, 0.05, 0.9))

func _make_node_style(border: Color, bg: Color) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.border_width_left = 4
    sb.border_width_top = 4
    sb.border_width_right = 4
    sb.border_width_bottom = 4
    sb.corner_radius_top_left = 2
    sb.corner_radius_top_right = 2
    sb.corner_radius_bottom_left = 2
    sb.corner_radius_bottom_right = 2
    return sb

func _node_hover_style() -> StyleBoxFlat:
    var sb: StyleBoxFlat = node_style_available.duplicate(true)
    sb.shadow_color = Color(1.0, 1.0, 0.5, 0.25)
    sb.shadow_size = 3
    return sb

func _style_shell_ui() -> void:
    var bg: ColorRect = get_node_or_null("Background")
    if bg != null:
        bg.color = COLOR_BG

    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = COLOR_PANEL
    panel_style.border_color = Color(0.8, 0.85, 1.0, 0.9)
    panel_style.border_width_left = 2
    panel_style.border_width_top = 2
    panel_style.border_width_right = 2
    panel_style.border_width_bottom = 2

    for panel_path in ["TopTabsPanel", "CurrencyPanel", "HoverCard"]:
        var panel := get_node_or_null(panel_path)
        if panel is PanelContainer:
            (panel as PanelContainer).add_theme_stylebox_override("panel", panel_style)

    var labels: Array = [
        get_node_or_null("%CurrencyLabel"),
        get_node_or_null("%InfoLabel"),
        get_node_or_null("%HoverTitle"),
        get_node_or_null("%HoverMeta"),
        get_node_or_null("%HoverDesc"),
        get_node_or_null("%HoverCost"),
    ]
    for label_variant in labels:
        if label_variant is Label:
            var label: Label = label_variant
            label.add_theme_color_override("font_color", COLOR_TEXT)

    for tab_path in [
        "TopTabsPanel/TopTabs/SkillTreeTab",
        "TopTabsPanel/TopTabs/MilestonesTab",
        "TopTabsPanel/TopTabs/PerksTab",
    ]:
        var btn := get_node_or_null(tab_path)
        if btn is Button:
            _style_header_button(btn as Button)

    for btn_path in [
        "TopActions/StartBattle",
        "TopActions/MainMenu",
        "EditorRow/EditorAddCurrency",
        "EditorRow/EditorResetProgress",
        "EditorRow/UnlockAllUpgrades",
    ]:
        var any_btn := get_node_or_null(btn_path)
        if any_btn is Button:
            _style_action_button(any_btn as Button)

func _style_header_button(button: Button) -> void:
    button.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 0.95))
    button.add_theme_font_size_override("font_size", 22)
    button.disabled = false
    button.focus_mode = Control.FOCUS_NONE
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.08, 0.18, 0.45, 0.95)
    normal.border_color = Color(0.86, 0.9, 1.0, 0.95)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", normal)
    button.add_theme_stylebox_override("pressed", normal)

func _style_action_button(button: Button) -> void:
    button.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0, 1))
    button.add_theme_font_size_override("font_size", 20)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.05, 0.14, 0.4, 0.96)
    normal.border_color = Color(0.89, 0.92, 0.99, 1.0)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    var hover := normal.duplicate(true)
    hover.bg_color = Color(0.08, 0.22, 0.55, 0.98)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)

func _refresh_starfield() -> void:
    if stars_layer == null:
        return
    for child in stars_layer.get_children():
        child.queue_free()
    rng.randomize()
    var area: Vector2 = size
    for i in range(STAR_COUNT):
        var px: float = rng.randf_range(8.0, max(16.0, area.x - 8.0))
        var py: float = rng.randf_range(8.0, max(16.0, area.y - 8.0))
        var star := ColorRect.new()
        var dim: float = 1.0 if rng.randf() < 0.8 else 2.0
        star.color = Color(0.95, 1.0, 0.75, rng.randf_range(0.4, 0.95))
        star.position = Vector2(px, py)
        star.size = Vector2.ONE * dim
        star.mouse_filter = Control.MOUSE_FILTER_IGNORE
        stars_layer.add_child(star)

func _resolve_icon_text(node: Dictionary) -> String:
    var key: String = str(node.get("key", "")).to_lower()
    if key.find("recruit") >= 0:
        return "H+"
    if key.find("unlock") >= 0:
        return ">>"
    if key.find("boss") >= 0:
        return "!!"
    if key.find("damage") >= 0:
        return "x"
    if key.find("speed") >= 0 or key.find("march") >= 0 or key.find("sprint") >= 0:
        return ">>"
    if key.find("armor") >= 0 or key.find("guard") >= 0 or key.find("shield") >= 0:
        return "[]"
    if key.find("power") >= 0 or key.find("active") >= 0:
        return "P+"
    if key.find("drop") >= 0 or key.find("coin") >= 0 or key.find("market") >= 0 or key.find("salvage") >= 0:
        return "$"
    if key.find("density") >= 0 or key.find("horde") >= 0 or key.find("wave") >= 0:
        return "*"
    if key.find("mage") >= 0:
        return "M"
    if key.find("archer") >= 0:
        return "A"
    if key.find("guardian") >= 0:
        return "G"
    if key.find("knight") >= 0:
        return "K"
    return "+"

func _resolve_node_icon_texture(node: Dictionary) -> Texture2D:
    return null

func _build_connection_lines() -> void:
    if line_layer == null:
        return
    for node in db.nodes:
        var node_id: String = str(node.get("id", ""))
        var dep_id: String = str(node.get("dependency", ""))
        if dep_id == "" or not node_grid_pos.has(node_id) or not node_grid_pos.has(dep_id):
            continue
        var from_grid: Vector2i = node_grid_pos[dep_id]
        var to_grid: Vector2i = node_grid_pos[node_id]
        var from_pos: Vector2 = TREE_CENTER + Vector2(from_grid) * CELL_SIZE
        var to_pos: Vector2 = TREE_CENTER + Vector2(to_grid) * CELL_SIZE

        var line := Line2D.new()
        line.width = 4.0
        line.default_color = COLOR_LINE
        line.antialiased = false
        line.z_index = 0
        line.add_point(from_pos)
        line.add_point(to_pos)
        line_layer.add_child(line)

func _update_hover_card() -> void:
    if hover_card == null:
        return
    if hovered_node_id == "" or not db.node_by_id.has(hovered_node_id):
        hover_card.visible = false
        return

    var node: Dictionary = db.node_by_id[hovered_node_id]
    var name_text: String = db.get_display_name(node)
    var cost: int = int(round(float(node.get("cost", 0.0))))
    var state_text: String = _get_node_state_text(node)
    var dep_id: String = str(node.get("dependency", ""))
    if dep_id == "":
        dep_id = "None"

    hover_card.visible = true
    if hover_title != null:
        hover_title.text = name_text
    if hover_meta != null:
        hover_meta.text = "%s  |  Dependency: %s" % [state_text, dep_id]
    if hover_desc != null:
        hover_desc.text = db.get_description(node)
    if hover_cost != null:
        hover_cost.text = "Cost: $%d" % cost
