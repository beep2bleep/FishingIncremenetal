extends Line2D
class_name TechTreeLine
var from_node: TechTreeNode:
    set(new_value):
        from_node = new_value
        from_node.state_changed.connect(_on_node_state_changed)
        update_line()


var to_node: TechTreeNode:
    set(new_value):
        to_node = new_value
        to_node.state_changed.connect(_on_node_state_changed)
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
    if Global.main and Global.main.epilogue == false:
        if from_node.is_epilgue_node() or to_node.is_epilgue_node():
            hide()
            return
    match from_node.state:


        TechTreeNode.STATES.AVAILABLE, TechTreeNode.STATES.COMPLETE:
            default_color = Refs.pallet.tech_tree_line_base

            if visible == false:
                do_animate_show(self, from_node.position, to_node.position)
                show()

            if from_node.is_center_node or (from_node.upgrade and from_node.upgrade.current_tier >= 1):

                if to_node.state == TechTreeNode.STATES.LOCKED or to_node.state == TechTreeNode.STATES.SHADOW:
                    to_node.state = TechTreeNode.STATES.AVAILABLE


            elif to_node.state == TechTreeNode.STATES.LOCKED:
                to_node.state = TechTreeNode.STATES.SHADOW



    match to_node.state:
        TechTreeNode.STATES.AVAILABLE, TechTreeNode.STATES.COMPLETE:
            default_color = Refs.pallet.tech_tree_line_base
            if visible == false:
                do_animate_show(self, to_node.position, from_node.position)
                show()

            if to_node.is_center_node or (to_node.upgrade and to_node.upgrade.current_tier >= 1):

                if from_node.state == TechTreeNode.STATES.LOCKED or from_node.state == TechTreeNode.STATES.SHADOW:
                    from_node.state = TechTreeNode.STATES.AVAILABLE

            elif from_node.state == TechTreeNode.STATES.LOCKED:
                from_node.state = TechTreeNode.STATES.SHADOW

    if from_node.state == TechTreeNode.STATES.COMPLETE and to_node.state == TechTreeNode.STATES.COMPLETE:

        if from_node.completed_index < to_node.completed_index:
            do_animate_show( %"Over Line", from_node.position, to_node.position)
        else:
            do_animate_show( %"Over Line", to_node.position, from_node.position)

        if to_node.upgrade:
            %"Over Line".default_color = Refs.get_act_light_color(to_node.upgrade.act)
        else:
            %"Over Line".default_color = Refs.get_act_light_color(1)


func _on_node_state_changed(node):
    update_colors()
