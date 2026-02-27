extends Node2D
class_name TechTree

var min_x = 0
var max_x = 0
var min_y = 0
var max_y = 0

var padding = 128

var node_dict = {}
var cell_spacing = Vector2(96, 96)

var active_nodes = []

var _next_completed_index: int = 0
var next_completed_index: int:
    get:
        return _next_completed_index
    set(new_value):
        _next_completed_index = new_value


@onready var pivot: Node2D = %Pivot


var _selected_node: TechTreeNode = null
var selected_node: TechTreeNode:
    get:
        return _selected_node
    set(new_value):
        if _selected_node == new_value:
            return
        _selected_node = new_value
        selected_node_changed.emit(_selected_node)

signal selected_node_changed(new_selected_node: TechTreeNode)


var node_search_range = 20
var node_search_width = 5
var use_grid_adjacency: bool = true
var requirement_hint_node: TechTreeNode = null

func select_node_in_direction(dir_vec: Vector2):
    if selected_node == null:
        return


    for i in range(1, node_search_range):
        var check_cell = selected_node.cell + (dir_vec * i)
        if node_dict.has(check_cell):
            var found_node: TechTreeNode = node_dict[check_cell]
            if found_node.state != TechTreeNode.STATES.LOCKED:
                found_node.click_mask.grab_focus()
                selected_node = found_node
                return


    var perpendicular_dirs = []

    if dir_vec in [Vector2.LEFT, Vector2.RIGHT]:

        perpendicular_dirs = [Vector2.UP, Vector2.DOWN]
    elif dir_vec in [Vector2.UP, Vector2.DOWN]:

        perpendicular_dirs = [Vector2.LEFT, Vector2.RIGHT]


    for perp_dir in perpendicular_dirs:
        for i in range(1, node_search_width + 1):

            for j in range(1, node_search_range):
                var check_cell = selected_node.cell + (dir_vec * j) + (perp_dir * i)
                if node_dict.has(check_cell):
                    var found_node: TechTreeNode = node_dict[check_cell]
                    if found_node.state != TechTreeNode.STATES.LOCKED:
                        found_node.click_mask.grab_focus()
                        selected_node = found_node
                        return


func move_tech_tree(direction: Vector2):
    kill_tween()
    pivot.position += direction
    clamp_tech_tree_pos()


func set_tech_tree_pos(new_pos: Vector2):
    kill_tween()
    pivot.position = new_pos
    clamp_tech_tree_pos()


var move_tween: Tween

func kill_tween():
    if move_tween:
        move_tween.kill()

func tween_to_pos(new_pos: Vector2):
    kill_tween()

    move_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
    move_tween.tween_property(pivot, "position", new_pos, 0.5)
    move_tween.tween_callback( func(): clamp_tech_tree_pos())


func clamp_tech_tree_pos():
    var view_port_size = get_viewport_rect().size / 2.0

    pivot.position.x = clamp(pivot.position.x, - view_port_size.x - max_x + padding, view_port_size.x - min_x - padding)
    pivot.position.y = clamp(pivot.position.y, - view_port_size.y - max_y + padding, view_port_size.y - min_y - padding)


func get_nodes():
    return %"Tech Nodes".get_children()


func update_active():
    var node_cost = Global.current_game_mode_data.get_node_cost(next_completed_index)

    for node: TechTreeNode in active_nodes:
        if node.upgrade and node.upgrade.type == Util.NODE_TYPES.ROGUELIKE_DUMMY:
            node.upgrade.base_cost = node_cost

        node.update()


var forced_connections_to_from = {}

var center_node: TechTreeNode
func setup():
    use_grid_adjacency = not _is_simulation_upgrade_tree()
    center_node = Refs.packed_tech_tree_node.instantiate()
    %"Tech Nodes".add_child(center_node)
    center_node.is_center_node = true
    center_node.setup(null, self)
    center_node.cell = Vector2.ZERO
    center_node.position = Vector2.ZERO
    node_dict[Vector2.ZERO] = center_node



    if Global.current_game_mode_data != null and Global.current_game_mode_data.game_mode_type == Util.GAME_MODE_TYPE.ROGUELIKE:
        generate_nodes_procedurally()


    for upgrade: Upgrade in Global.game_mode_data_manager.upgrades.values():
        if upgrade.forced_cell != null:
            if forced_connections_to_from.has(upgrade.forced_cell) == false:
                forced_connections_to_from[upgrade.forced_cell] = []

            forced_connections_to_from[upgrade.forced_cell].append(upgrade.cell)


    setup_nodes_from_data()
    _refresh_states_after_full_build()
    update_active()














func update_connected_nodes_available(from_cell: Vector2):
    for connected_cell in get_all_connected_cells(from_cell):
        var node: TechTreeNode
        if node_dict.has(connected_cell) == false:
            node = create_new_tech_tree_node(connected_cell)
        else:
            node = node_dict[connected_cell]

        if node != null and (node.state == TechTreeNode.STATES.LOCKED or node.state == TechTreeNode.STATES.SHADOW):
            node.state = TechTreeNode.STATES.AVAILABLE


func update_connected_nodes_shadow(from_cell: Vector2, depth: int = 1):
    var frontier: Array[Vector2] = [from_cell]
    var visited: Dictionary = {from_cell: true}
    var remaining_depth: int = max(1, depth)
    while remaining_depth > 0 and not frontier.is_empty():
        var next_frontier: Array[Vector2] = []
        for source_cell in frontier:
            for connected_cell in get_all_connected_cells(source_cell):
                if visited.has(connected_cell):
                    continue
                visited[connected_cell] = true

                var node: TechTreeNode
                if node_dict.has(connected_cell) == false:
                    node = create_new_tech_tree_node(connected_cell)
                else:
                    node = node_dict[connected_cell]

                if node != null and node.state == TechTreeNode.STATES.LOCKED:
                    node.state = TechTreeNode.STATES.SHADOW

                next_frontier.append(connected_cell)
        frontier = next_frontier
        remaining_depth -= 1



func create_new_tech_tree_node(cell) -> TechTreeNode:
    if node_dict.has(cell):
        return node_dict[cell]

    if Global.game_mode_data_manager.upgrades.has(cell):
        var upgrade: Upgrade = Global.game_mode_data_manager.upgrades[cell]



        var node: TechTreeNode = Refs.packed_tech_tree_node.instantiate()
        %"Tech Nodes".add_child(node)
        node.setup(upgrade, self)
        node.position = cell_spacing * upgrade.cell
        node_dict[upgrade.cell] = node
        node.state_changed.connect(_on_node_state_changed)

        create_lines(cell)

        return node

    return null


func create_lines(from_cell):
    if node_dict.has(from_cell):
        var from_node: TechTreeNode = node_dict[from_cell]

        var connected_cells = []
        if use_grid_adjacency:
            for vec in [Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1)]:
                if Global.game_mode_data_manager.upgrades.has(from_cell + vec):
                    connected_cells.append(from_cell + vec)

        if from_node.upgrade and from_node.upgrade.forced_cell:
            connected_cells.append(from_node.upgrade.forced_cell)

        for connected_cell in connected_cells:
            if node_dict.has(connected_cell):
                var new_line: TechTreeLine = Refs.packed_tech_tree_line.instantiate()

                new_line.from_node = node_dict[connected_cell]
                new_line.to_node = from_node

                %"Tech Lines".add_child(new_line)













func get_all_connected_cells(from_cell: Vector2):
    var connected_cells = []
    if use_grid_adjacency:
        for vec in [Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1)]:
            if Global.game_mode_data_manager.upgrades.has(from_cell + vec):
                connected_cells.append(from_cell + vec)

    if forced_connections_to_from.has(from_cell):
        connected_cells.append_array(forced_connections_to_from[from_cell])

    return connected_cells


func setup_nodes_from_data():
    var node_with_forced_connections = []

    for upgrade: Upgrade in Global.game_mode_data_manager.upgrades.values():
        var node: TechTreeNode = Refs.packed_tech_tree_node.instantiate()
        %"Tech Nodes".add_child(node)
        node.setup(upgrade, self)
        node.position = cell_spacing * upgrade.cell
        node_dict[upgrade.cell] = node
        node.state_changed.connect(_on_node_state_changed)

        if upgrade.forced_cell != null:
            node_with_forced_connections.append(node)

        if use_grid_adjacency:
            for vec in [Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1)]:
                if node_dict.has(node.cell + vec):
                    var new_line: TechTreeLine = Refs.packed_tech_tree_line.instantiate()

                    new_line.from_node = node
                    new_line.to_node = node_dict[node.cell + vec]

                    %"Tech Lines".add_child(new_line)

    center_node.state = TechTreeNode.STATES.COMPLETE
    selected_node = center_node

    for node: TechTreeNode in node_with_forced_connections:
        if node_dict.has(node.upgrade.forced_cell):
            var new_line: TechTreeLine = Refs.packed_tech_tree_line.instantiate()

            new_line.from_node = node
            new_line.to_node = node_dict[node.upgrade.forced_cell]

            %"Tech Lines".add_child(new_line)


func _refresh_states_after_full_build() -> void:
    update_connected_nodes_available(Vector2.ZERO)

    for cell_variant: Variant in Global.game_mode_data_manager.unlocked_upgrades.keys():
        if not (cell_variant is Vector2):
            continue
        var cell: Vector2 = cell_variant
        if not node_dict.has(cell):
            continue

        var node: TechTreeNode = node_dict[cell]
        var saved_variant: Variant = Global.game_mode_data_manager.unlocked_upgrades[cell]
        if saved_variant is Dictionary:
            var saved_data: Dictionary = saved_variant
            if Global.current_game_mode_data.game_mode_type == Util.GAME_MODE_TYPE.ROGUELIKE:
                node.upgrade.from_dict(cell, saved_data)
            elif saved_data.has("teir"):
                node.unlock_node(int(saved_data["teir"]))

        if node.upgrade != null and node.upgrade.is_at_max():
            node.state = TechTreeNode.STATES.COMPLETE

        update_connected_nodes_available(cell)


func generate_nodes_procedurally():
    var id = 0


    var half_x = int(Global.current_game_mode_data.upgrade_tree_grid_size.x / 2.0)
    var half_y = int(Global.current_game_mode_data.upgrade_tree_grid_size.y / 2.0)

    for x in range( - half_x, half_x + 1):
        for y in range( - half_y, half_y + 1):

            if Vector2i(x, y) == Vector2i.ZERO:
                continue

            var upgrade = Upgrade.new()

            upgrade.id = id
            id += 1
            upgrade.cell = Vector2(x, y)
            upgrade.mod = 1
            upgrade.value = randf_range(0.1, 0.5)
            upgrade.max_tier = 1
            upgrade.base_cost = 1
            upgrade.cost_scale = 0
            upgrade.forced_cell = null
            upgrade.demo_locked = 0
            upgrade.section = 0
            upgrade.act = 1
            upgrade.current_tier = 0
            upgrade.type = Util.NODE_TYPES.ROGUELIKE_DUMMY

            Global.game_mode_data_manager.upgrades[Vector2(x, y)] = upgrade




func _on_node_state_changed(node: TechTreeNode):
    update_active()
    update_min_max_for_visible_nodes()

func get_unlock_requirement_node(target_cell: Vector2) -> TechTreeNode:
    if not node_dict.has(target_cell):
        return null
    var target_node: TechTreeNode = node_dict[target_cell]
    if target_node == null:
        return null
    if target_node.upgrade != null and target_node.upgrade.forced_cell != null:
        var forced_cell: Vector2 = target_node.upgrade.forced_cell
        if node_dict.has(forced_cell):
            var forced_node: TechTreeNode = node_dict[forced_cell]
            if forced_node != null and forced_node.state != TechTreeNode.STATES.COMPLETE:
                return forced_node
    for connected_cell in get_all_connected_cells(target_cell):
        if not node_dict.has(connected_cell):
            continue
        var candidate: TechTreeNode = node_dict[connected_cell]
        if candidate != null and candidate.state != TechTreeNode.STATES.COMPLETE:
            return candidate
    return null

func set_requirement_hint_for(source_node: TechTreeNode, enabled: bool) -> void:
    if requirement_hint_node != null and is_instance_valid(requirement_hint_node):
        requirement_hint_node.set_locked_requirement_highlight(false)
    requirement_hint_node = null

    if not enabled or source_node == null:
        return
    var required_node: TechTreeNode = get_unlock_requirement_node(source_node.cell)
    if required_node == null or not is_instance_valid(required_node):
        return
    if required_node == source_node:
        return
    requirement_hint_node = required_node
    requirement_hint_node.set_locked_requirement_highlight(true)

func _is_simulation_upgrade_tree() -> bool:
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if not (upgrade_variant is Upgrade):
            continue
        var upgrade: Upgrade = upgrade_variant
        if upgrade.sim_name != "":
            return true
    return false

func _on_node_selected(node: TechTreeNode):
    selected_node = node

    set_tech_tree_pos(node.position)


func update_min_max_for_visible_nodes():
    min_x = 0
    max_x = 0
    min_y = 0
    max_y = 0

    for node: TechTreeNode in node_dict.values():
        if node.state == TechTreeNode.STATES.LOCKED:
            continue

        if node.position.x < min_x:
            min_x = node.position.x

        if node.position.x > max_x:
            max_x = node.position.x

        if node.position.y < min_y:
            min_y = node.position.y

        if node.position.y > max_y:
            max_y = node.position.y
