extends Node2D
class_name Supernova


var base_scale = 6.0
var base_radius = 1500
var actual_radius

var enable = false

var percent_current_health = 0

var tween

func setup(_percent_current_health, _radius_scale, _start_radius):
    percent_current_health = _percent_current_health

    if tween:
        tween.kill()











    show()

    actual_radius = base_radius * _radius_scale



    enable = true





    var start_scale = _start_radius / base_radius * base_scale * Vector2.ONE
    var end_scale = actual_radius / base_radius * base_scale * Vector2.ONE


    %Circle.material.set_shader_parameter("color", Refs.pallet.supernova_color)
    %Circle.material.set_shader_parameter("scale_factor", 3.0)
    %Circle.scale = start_scale
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.SUPERNOVA)


    tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

    tween.tween_property( %Circle, "scale", start_scale * 0.5, 0.25).set_ease(Tween.EASE_OUT)

    tween.tween_interval(0.05)

    tween.tween_callback( func():



        $AnimationPlayer.play("Supernova")
        )
    tween.tween_property( %Circle, "scale", end_scale, 0.3).set_trans(Tween.TRANS_ELASTIC)
    tween.parallel().tween_property( %Circle.material, "shader_parameter/scale_factor", 6, 0.3).set_ease(Tween.TRANS_LINEAR)
    tween.tween_property( %Circle.material, "shader_parameter/color:a", 0, 2.0).set_ease(Tween.EASE_OUT)


    tween.tween_callback( func():

        clean_up()
        )



func deal_damage():
    Global.main.camera_2d.add_trauma(0.45)
    var objects = Global.main.object_manager.get_objects_near(global_position, actual_radius, true, true)
    for object: SpaceObject in objects:

        var damage_event_data = object.take_perecent_damage(percent_current_health, true, object.global_position)
        Global.session_stats.super_nova_damage += damage_event_data.damage



func clean_up():
    hide()
    if enable:
        enable = false
        FlairManager.supernova_pool.append(self)
