extends Line2D
class_name TechTreeLine

const MIN_PROGRESS_TO_DRAW: float = 0.001
var _from_node: TechTreeNode = null
var from_node: TechTreeNode:
    get:
        return _from_node
    set(new_value):
        if _from_node == new_value:
            return
        _from_node = new_value
        if _from_node != null:
            var state_changed_callable: Callable = Callable(self, "_on_node_state_changed")
            if not _from_node.state_changed.is_connected(state_changed_callable):
                _from_node.state_changed.connect(state_changed_callable)
        update_line()


var _to_node: TechTreeNode = null
var to_node: TechTreeNode:
    get:
        return _to_node
    set(new_value):
        if _to_node == new_value:
            return
        _to_node = new_value
        if _to_node != null:
            var state_changed_callable: Callable = Callable(self, "_on_node_state_changed")
            if not _to_node.state_changed.is_connected(state_changed_callable):
                _to_node.state_changed.connect(state_changed_callable)
        update_line()

var is_animating: bool = false


func _ready() -> void :
    hide()
    update()

    SignalBus.pallet_updated.connect(update_colors)
    update_colors()

func _on_pallet_updated():
    update_colors()

func update():
    update_colors()
    update_line()

func update_line():
    clear_points()

    position = Vector2.ZERO

    if from_node != null:
        add_point(from_node.position)

    if to_node != null:
        add_point(to_node.position)

    _update_over_line_visual()


func do_animate_show(line_2d: Line2D, start_pos: Vector2, end_pos: Vector2):
    line_2d.clear_points()
    line_2d.position = Vector2.ZERO
    line_2d.add_point(start_pos)
    line_2d.add_point(start_pos)

    line_2d.show()





    var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
    tween.tween_method( func(progress: float):
        var current_pos = start_pos.lerp(end_pos, progress)
        line_2d.set_point_position(1, current_pos)
    , 0.0, 1.0, 0.3)

    tween.finished.connect( func():
        update_line()
    )


func update_colors():
    if from_node == null or to_node == null:
        %"Over Line".hide()
        return

    if Global.main and Global.main.epilogue == false:
        if from_node.is_epilgue_node() or to_node.is_epilgue_node():
            hide()
            %"Over Line".hide()
            return
    match from_node.state:


        TechTreeNode.STATES.AVAILABLE, TechTreeNode.STATES.COMPLETE:
            default_color = Refs.pallet.tech_tree_line_base

            if visible == false:
                do_animate_show(self, from_node.position, to_node.position)
                show()



    match to_node.state:
        TechTreeNode.STATES.AVAILABLE, TechTreeNode.STATES.COMPLETE:
            default_color = Refs.pallet.tech_tree_line_base
            if visible == false:
                do_animate_show(self, to_node.position, from_node.position)
                show()
    _update_over_line_visual()


func _on_node_state_changed(node):
    update_colors()

func _update_over_line_visual() -> void:
    if from_node == null or to_node == null:
        %"Over Line".hide()
        return

    var start_node: TechTreeNode = _get_parent_node()
    var end_node: TechTreeNode = _get_child_node()
    var progress: float = 0.0

    if start_node == null or end_node == null:
        %"Over Line".hide()
        return

    progress = end_node.get_visual_progress_ratio()

    if start_node == null or end_node == null or progress <= MIN_PROGRESS_TO_DRAW:
        %"Over Line".hide()
        return

    var end_pos: Vector2 = start_node.position.lerp(end_node.position, clamp(progress, 0.0, 1.0))
    %"Over Line".clear_points()
    %"Over Line".position = Vector2.ZERO
    %"Over Line".add_point(start_node.position)
    %"Over Line".add_point(end_pos)
    %"Over Line".default_color = _get_progress_color(end_node)
    %"Over Line".show()

func _get_progress_color(target_node: TechTreeNode) -> Color:
    if target_node != null and target_node.upgrade != null:
        return Refs.get_act_light_color(target_node.upgrade.act)
    return Refs.get_act_light_color(1)

func _get_parent_node() -> TechTreeNode:
    var from_depth: int = _get_node_depth(from_node)
    var to_depth: int = _get_node_depth(to_node)

    if from_depth < to_depth:
        return from_node
    if to_depth < from_depth:
        return to_node

    if from_node.get_visual_progress_ratio() <= to_node.get_visual_progress_ratio():
        return from_node
    return to_node

func _get_child_node() -> TechTreeNode:
    var parent_node: TechTreeNode = _get_parent_node()
    if parent_node == from_node:
        return to_node
    return from_node

func _get_node_depth(node: TechTreeNode) -> int:
    if node == null or node.tech_tree == null:
        return 999999
    return node.tech_tree.get_cell_depth(node.cell)
