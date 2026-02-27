extends Control

const CELL_SIZE := Vector2(240, 240)
const NODE_SIZE := Vector2(180, 180)
const TREE_CENTER := Vector2(6400, 6400)
const PAN_SPEED := 1400.0

var db: FishingUpgradeDB = FishingUpgradeDB.new()
var button_by_id: Dictionary = {}
var scroll_container: ScrollContainer
var node_grid_pos: Dictionary = {}
var drag_panning := false

var currency_label: Label
var info_label: Label
var tree_layer: Control
var hovered_node_id: String = ""
var editor_add_currency_button: Button
var editor_reset_progress_button: Button
var unlock_all_upgrades_button: Button
var editor_add_amount: int = 1000

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
    editor_add_currency_button = get_node_or_null("EditorAddCurrency")
    editor_reset_progress_button = get_node_or_null("EditorResetProgress")
    unlock_all_upgrades_button = get_node_or_null("UnlockAllUpgrades")

    if currency_label == null or info_label == null or tree_layer == null or scroll_container == null or editor_add_currency_button == null or editor_reset_progress_button == null or unlock_all_upgrades_button == null:
        push_error("FishingUpgradeScene is missing required UI nodes.")
        return

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
    for node in db.nodes:
        var button: Button = Button.new()
        var node_id: String = str(node.get("id", ""))
        var key: String = str(node.get("key", ""))
        var level: int = int(node.get("level", 1))
        var icon: String = str(node.get("icon", "?"))
        var grid: Vector2i = node_grid_pos[node_id]

        button.text = icon if level == 1 else "%s%d" % [icon, level]
        button.custom_minimum_size = NODE_SIZE
        button.size = NODE_SIZE
        button.position = TREE_CENTER + Vector2(grid) * CELL_SIZE - (NODE_SIZE * 0.5)
        button.tooltip_text = _build_upgrade_tooltip(node)
        button.pressed.connect(_on_upgrade_pressed.bind(node_id))
        button.mouse_entered.connect(_on_upgrade_hovered.bind(node_id))
        button.mouse_exited.connect(_on_upgrade_unhovered.bind(node_id))
        button.focus_entered.connect(_on_upgrade_hovered.bind(node_id))
        tree_layer.add_child(button)
        button_by_id[node_id] = button
    tree_layer.custom_minimum_size = Vector2((max_abs * 2 + 12) * CELL_SIZE.x, (max_abs * 2 + 12) * CELL_SIZE.y)

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
    currency_label.text = "Currency: %d" % SaveHandler.fishing_currency
    if editor_add_currency_button != null:
        editor_add_currency_button.text = "Add $%d (Editor)" % editor_add_amount
    var unlocked_count: int = SaveHandler.fishing_unlocked_upgrades.keys().size()
    var base_info: String = "Unlocked: %d / %d  |  Tree expands from center in 4 directions (drag/WASD/arrows)." % [unlocked_count, db.nodes.size()]
    if hovered_node_id != "" and db.node_by_id.has(hovered_node_id):
        var hovered_node: Dictionary = db.node_by_id[hovered_node_id]
        var state_text: String = _get_node_state_text(hovered_node)
        info_label.text = "%s\n%s (%s): %s" % [base_info, db.get_display_name(hovered_node), state_text, db.get_description(hovered_node)]
    else:
        info_label.text = base_info

    for node in db.nodes:
        var node_id: String = str(node.get("id", ""))
        if not button_by_id.has(node_id):
            continue
        var button: Button = button_by_id[node_id]
        button.tooltip_text = _build_upgrade_tooltip(node)

        if db.is_owned(node):
            button.disabled = true
            button.modulate = Color(0.45, 0.9, 0.45)
        elif db.can_buy(node):
            button.disabled = false
            button.modulate = Color(1.0, 0.86, 0.2)
        elif db.is_dependency_met(node):
            button.disabled = true
            button.modulate = Color(0.6, 0.6, 0.6)
        else:
            button.disabled = true
            button.modulate = Color(0.35, 0.35, 0.35)

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
