extends Node
class_name CustomTweenComponent

var disable = false

var on_scale_tween: Tween
var rotation_tween: Tween

@export var base_node: Node
@export var duration = 0.3

@export var do_scale = false
@export var scale_amount = Vector2(1.1, 1.1)
@export var do_rotation = false
@export var rotation_amount = 15

func do_tween(not_used_anymore_was_scale_and_i_was_too_lazy_to_remove_this):
    if disable == true:
        return

    kill_tweens()

    if do_scale:
        on_scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

        on_scale_tween.tween_property(base_node, "scale", scale_amount, duration / 2.0)
        on_scale_tween.tween_property(base_node, "scale", Vector2(1.0, 1.0), duration / 2.0)

    if do_rotation:
        rotation_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

        rotation_tween.tween_property(base_node, "rotation_degrees", rotation_amount, duration / 3.0)
        rotation_tween.tween_property(base_node, "rotation_degrees", - rotation_amount, duration / 3.0)
        rotation_tween.tween_property(base_node, "rotation_degrees", 0, duration / 3.0)

func reset():
    if do_scale:
        base_node.scale = Vector2(1.0, 1.0)

    if do_rotation:
        base_node.rotation_degrees = 0

func kill_tweens():
    if on_scale_tween and on_scale_tween.is_running():
        on_scale_tween.kill()

    if rotation_tween and rotation_tween.is_running():
        rotation_tween.kill()
