extends Node
class_name ShowHideComponent

@export var base_node: Control
@export var show_duration: float = 0.5
@export var hide_duration: float = 0.25
@export var enable_horizontal: bool = false
@export var right_side_override: bool = false
@export var enable_vertical: bool = true
@export var bottom_side_override: bool = false
@export var additonal_x_pos: int = 0
@export var additonal_y_pos: int = 0


var is_shown = false

signal show_animation_finished
signal hide_animation_finished

func do_show_animation() -> void :
    if is_shown == true:
        return

    kill_tween()

    show_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

    if enable_horizontal:
        if right_side_override:
            show_tween.tween_property(base_node, "position:x", - base_node.size.x, show_duration)
        else:
            show_tween.tween_property(base_node, "position:x", 0, show_duration)
    if enable_vertical:
        if bottom_side_override:
            show_tween.tween_property(base_node, "position:y", -32, show_duration * 0.85)
            show_tween.tween_property(base_node, "position:y", 0, show_duration * 0.15)
        else:
            show_tween.tween_property(base_node, "position:y", 0, show_duration)

    is_shown = true
    show_tween.tween_callback( func(): show_animation_finished.emit())


var show_tween: Tween
func do_hide_animation():
    if is_shown == false:
        return

    kill_tween()

    show_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

    show_tween.set_parallel(true)
    if enable_horizontal:
        if right_side_override:
            show_tween.tween_property(base_node, "position:x", 0, hide_duration)
        else:
            show_tween.tween_property(base_node, "position:x", - base_node.size.x - additonal_x_pos, hide_duration)
    if enable_vertical:
        if bottom_side_override:
            show_tween.tween_property(base_node, "position:y", -16, show_duration * 0.1)
            show_tween.chain().tween_property(base_node, "position:y", base_node.size.y, hide_duration * 0.9)
        else:
            show_tween.tween_property(base_node, "position:y", - base_node.size.y - additonal_y_pos, hide_duration)
    show_tween.set_parallel(false)

    is_shown = false

    show_tween.tween_callback( func(): hide_animation_finished.emit())


func kill_tween():
    if show_tween and show_tween.is_running():
        show_tween.kill()
