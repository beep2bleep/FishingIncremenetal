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
@export var rotation_amount: float = 15.0
@export var scale_hover_to_width = false
@export var hover_size_node: Control

func hover_effect_strength() -> float:
    if not scale_hover_to_width:
        return 1.0
    var control := hover_size_node if hover_size_node != null else base_node as Control
    if not is_instance_valid(control) or not control.is_inside_tree():
        return 1.0
    var viewport := control.get_viewport()
    if viewport == null:
        return 1.0
    var screen_width := viewport.get_visible_rect().size.x
    if screen_width <= 0.0:
        return 1.0
    var transform := control.get_global_transform_with_canvas()
    var width_fraction := clampf((transform.x * control.size.x).length() / screen_width, 0.0, 1.0)
    # Interpolate rather than jumping at each size boundary. Small items can
    # reach 2x; 10%, 25%, 50%, and full-screen widths get 1x, .5x, .25x, and 0x.
    if width_fraction <= 0.10:
        return lerpf(2.0, 1.0, width_fraction / 0.10)
    if width_fraction <= 0.25:
        return lerpf(1.0, 0.5, (width_fraction - 0.10) / 0.15)
    if width_fraction <= 0.50:
        return lerpf(0.5, 0.25, (width_fraction - 0.25) / 0.25)
    return lerpf(0.25, 0.0, (width_fraction - 0.50) / 0.50)

func do_tween(not_used_anymore_was_scale_and_i_was_too_lazy_to_remove_this):
    # A pressed callback may already have changed scenes before feedback runs.
    if disable or not is_inside_tree() or not is_instance_valid(base_node) or not base_node.is_inside_tree():
        return

    kill_tweens()
    var strength := hover_effect_strength()

    if do_scale:
        var growth: Vector2 = Vector2.ONE + (scale_amount - Vector2.ONE) * strength
        on_scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

        on_scale_tween.tween_property(base_node, "scale", growth, duration / 2.0)
        on_scale_tween.tween_property(base_node, "scale", Vector2(1.0, 1.0), duration / 2.0)

    if do_rotation:
        var amount := rotation_amount * strength
        rotation_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

        rotation_tween.tween_property(base_node, "rotation_degrees", amount, duration / 3.0)
        rotation_tween.tween_property(base_node, "rotation_degrees", - amount, duration / 3.0)
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
