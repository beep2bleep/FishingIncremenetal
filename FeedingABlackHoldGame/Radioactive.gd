extends Node2D
class_name Radioactive

var dot = 0.0
var duration = 0
var base_radius = 64
var actual_radius = base_radius
var enable = false



func _ready():

    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()





func _on_pallet_updated():
    update_color()

func update_color():
    %Sprite2D2.material.set_shader_parameter("color", Refs.pallet.radioactive_color)
    %Sprite2D.material.set_shader_parameter("color", Refs.pallet.radioactive_color)

func setup_dummy_effect(radius):
    %Pivot.scale = Vector2.ONE * radius / base_radius


func setup(_dot, _duration, _scale):
    enable = true
    %Pivot.rotation_degrees = Global.rng.randi_range(0, 360)
    show()
    dot = _dot
    duration = _duration

    actual_radius = base_radius * _scale

    %Timer.wait_time = _duration
    %Timer.start()
    $"DoT Timer".start()
    %Pivot.scale = Vector2.ONE * _scale



func _on_timer_timeout() -> void :
    clean_up()





func damage_objects():
    var found_object = false
    var objects = Global.main.object_manager.get_objects_near(global_position, actual_radius, true, true)
    for object: SpaceObject in objects:
        var damage_event_data = object.take_damage(dot, object.global_position, false)
        Global.session_stats.radio_active_damage += damage_event_data.damage
        found_object = true


    if found_object == true:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.RADIOACTIVE_DOT)



func _on_do_t_timer_timeout() -> void :
    damage_objects()

func clean_up():
    $"DoT Timer".stop()
    %Timer.stop()
    hide()

    if enable == true:
        enable = false
        FlairManager.radioactive_pool.append(self)
