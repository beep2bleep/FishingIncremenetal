extends Node2D
class_name ResourceChanged

var anim_duration = 0.67

var color: Color:
    set(new_value):
        color = new_value
        %Icon.modulate = color
        var outline_color = color
        outline_color.v *= 0.9
        %MatterBaseOutline.modulate = outline_color


var from_position
var from_node_origin
var resource_type

var is_active = false

var value


func get_actual_global_position():
    return %ArtPivot.global_position


signal sucked_up(resource_changed)


func setup(_resource_type, _from_position, _from_node, _color, _value):
    is_active = false
    rotation_degrees = 0
    getting_sucked_up = false
    resource_type = _resource_type
    value = _value


    color = _color


    anim_duration = 1.25 * Global.rng.randf_range(0.8, 1.2)

    from_node_origin = _from_node.get_canvas_transform().origin



    from_position = _from_position

    self.position = Vector2.ZERO
    %Pivot.global_position = from_position
    %Pivot.scale = Vector2.ONE

    modulate.a = 1
    visible = true


    is_active = true
    get_sucked_up()



func _ready():
    visible = false


var rotation_speed = 0
var rotation_acccel = 50

var direction = 1

var setup_tween: Tween
var move_radius: float = 200.0
var tween_duration: float = 0.33

func do_on_setup():
    var viewport_rect = get_viewport().get_visible_rect()
    var origin_position = %Pivot.global_position


    var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf() * move_radius
    var target_position = origin_position + offset


    target_position.x = clamp(target_position.x, - viewport_rect.size.x / 2.0, viewport_rect.size.x / 2.0)
    target_position.y = clamp(target_position.y, - viewport_rect.size.y / 2.0, viewport_rect.size.y / 2.0)

    setup_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
    setup_tween.tween_property( %Pivot, "global_position", target_position, tween_duration)
    setup_tween.tween_callback( func():


        is_active = true
        check_if_in_gravity_of_black_hole()

    )


var getting_sucked_up = false

func get_sucked_up():
    if getting_sucked_up == true or is_active == false:
        return


    getting_sucked_up = true
    is_active = false
    sucked_up.emit(self)

    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_RESOURCE_SUCKED_UP)





    %Pivot.scale = Vector2(1.0, 1.0)
    %Pivot.modulate.a = 1.0

    var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)




    tween.tween_property( %Pivot, "position", Vector2.ZERO, anim_duration).set_ease(Tween.EASE_IN_OUT)
    tween.parallel().tween_property( %Pivot, "scale", Vector2(0.5, 0.5), anim_duration).set_ease(Tween.EASE_IN)

    tween.parallel().tween_property(self, "rotation_degrees", rotation_degrees + 360.0, anim_duration)

    tween.tween_callback( func():
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MATTER, value)
        Global.black_hole.level_manager.add_xp(value)
        Global.main.resource_pool.return_resource_changed(self)
        set_process(false)
    )

var on_hit_scale_tween: Tween
var on_hit_rotation_tween: Tween
var on_hit_tween_duration = 0.3
func do_on_hover_tweens():
    if getting_sucked_up == true:
        return

    kill_on_hover_tweens()

    var animation_magnitude = 20

    on_hit_scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

    on_hit_scale_tween.tween_property( %ArtPivot, "scale", Vector2(1.3, 1.3), on_hit_tween_duration / 2.0)
    on_hit_scale_tween.tween_property( %ArtPivot, "scale", Vector2(1.0, 1.0), on_hit_tween_duration / 2.0)


    on_hit_rotation_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

    on_hit_rotation_tween.tween_property( %ArtPivot, "rotation_degrees", animation_magnitude, on_hit_tween_duration / 5.0)
    on_hit_rotation_tween.tween_property( %ArtPivot, "rotation_degrees", - animation_magnitude, on_hit_tween_duration / 5.0)
    on_hit_rotation_tween.tween_property( %ArtPivot, "rotation_degrees", animation_magnitude / 2.0, on_hit_tween_duration / 5.0)
    on_hit_rotation_tween.tween_property( %ArtPivot, "rotation_degrees", - animation_magnitude / 2.0, on_hit_tween_duration / 5.0)
    on_hit_rotation_tween.tween_property( %ArtPivot, "rotation_degrees", 0, on_hit_tween_duration / 5.0)


func kill_on_hover_tweens():
    if on_hit_scale_tween and on_hit_scale_tween.is_running():
        on_hit_scale_tween.kill()

    if on_hit_rotation_tween and on_hit_rotation_tween.is_running():
        on_hit_rotation_tween.kill()


func check_if_in_gravity_of_black_hole():
    if Global.black_hole.global_position.distance_squared_to( %Pivot.global_position) <= Global.black_hole.gravity_radius_squared:
        get_sucked_up()

    elif Global.player.global_position.distance_squared_to( %Pivot.global_position) <= 1764:
        get_sucked_up()











































func _on_resource_changed_area_2d_mouse_entered() -> void :
    pass


func _on_resource_changed_area_2d_mouse_exited() -> void :
    pass
