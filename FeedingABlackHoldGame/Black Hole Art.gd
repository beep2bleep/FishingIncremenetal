extends Node2D
class_name BlackHoleArt

var maw_texture: GradientTexture2D
var bh_texture: GradientTexture2D
@onready var core: Sprite2D = %Core

var shake_tween: Tween

func _ready():
    maw_texture = %"Maw Art".texture
    bh_texture = %"Core".texture
    %Progress.material.set_shader_parameter("value", 0)

    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.game_state_changed.connect(_on_game_state_changed)

    update_progress(0)

    update_color()


func _on_game_state_changed():
    kill_tweens()

func _on_pallet_updated():
    update_color()

func update_color():
    %"Maw Art".material.set_shader_parameter("color", Refs.pallet.black_hole_maw)
    %"Progress".material.set_shader_parameter("primary_color", Refs.pallet.black_hole_progress_bar)
    %"Core".material.set_shader_parameter("hole_color", Refs.pallet.black_hole_dark)

    var bg_color = Refs.pallet.black_hole_dark
    bg_color.a = 0.0
    %"Progress".material.set_shader_parameter("bg_color", bg_color)

func update_progress(value):
    %Progress.material.set_shader_parameter("value", value)

    %Progress.visible = value > 0



func update(force_uodate = false):
    if grow_tween and grow_tween.is_running() and force_uodate == false:
        return

    visible = false
    scale = get_target_scale(Global.black_hole.gravity_radius * 3)

    visible = true




func get_target_scale(radius):
    return radius / maw_texture.width * Vector2.ONE


var grow_tween: Tween
func animate_grow(target_radius, duration = 0.5, do_pulse = true, reset_scale = true, ease = Tween.EASE_IN_OUT, trans = Tween.TRANS_BACK):

    kill_tweens(reset_scale)

    var new_scale = get_target_scale(target_radius * 3)

    if do_pulse == true:
        FlairManager.create_shockwave(1.3, null)
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BLACK_HOLE_GROW)

    grow_tween = create_tween().set_ease(ease).set_trans(trans)

    grow_tween.tween_property(self, "scale", new_scale, duration)


func lock_in_effect(tier = 0):


    var maw_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

    maw_tween.tween_callback( func(): %"Maw Art".material.set_shader_parameter("color", Refs.get_act_light_color(tier + 1)))

    maw_tween.tween_method(
        func(value):
            %"Maw Art".material.set_shader_parameter("radius", value)
            %"Maw Art".material.set_shader_parameter("thickness", value), 
        0.5, 
        0.2, 
        0.42
    )


    maw_tween.tween_method(
        func(value):
            %"Maw Art".material.set_shader_parameter("radius", value)
            %"Maw Art".material.set_shader_parameter("thickness", value), 
        0.2, 
        0.5, 
        0.5
    )

    maw_tween.parallel().tween_method(
        func(value):
                %"Maw Art".material.set_shader_parameter("color", value), 
            Refs.get_act_light_color(tier + 1), 
            Refs.pallet.black_hole_maw, 
            0.5
        )

func kill_tweens(do_reset_scale = true):
    if grow_tween and grow_tween.is_running():
        grow_tween.kill()

    if do_reset_scale == true and Global.black_hole:
        scale = get_target_scale(Global.black_hole.gravity_radius * 3)

    if shake_tween and shake_tween.is_running():
        shake_tween.kill()
        %Core.position = Vector2.ZERO

func start_shake(intensity: float = 8.0, shake_speed: float = 0.05, duration: float = 0.0, ramp_up_duration: float = 0.0, start_intensity: float = 0.0):
    if shake_tween and shake_tween.is_running():
        shake_tween.kill()





    if duration > 0:
        var shake_count = int(duration / (shake_speed * 2))


        var ramp_shake_count = 0
        if ramp_up_duration > 0:
            ramp_shake_count = int(ramp_up_duration / (shake_speed * 2))

        shake_tween = create_tween()


        for i in range(ramp_shake_count):
            var ramp_progress = float(i) / float(ramp_shake_count)
            var current_intensity = lerp(start_intensity, intensity, ease(ramp_progress, 2.0))

            shake_tween.tween_property( %Core, "position", 
                Vector2(randf_range( - current_intensity, current_intensity), randf_range( - current_intensity, current_intensity)), 
                shake_speed)
            shake_tween.tween_property( %Core, "position", 
                 Vector2(randf_range( - current_intensity, current_intensity), randf_range( - current_intensity, current_intensity)), 
                shake_speed)


        var remaining_shakes = shake_count - ramp_shake_count
        for i in range(remaining_shakes):
            shake_tween.tween_property( %Core, "position", 
                 Vector2(randf_range( - intensity, intensity), randf_range( - intensity, intensity)), 
                shake_speed)
            shake_tween.tween_property( %Core, "position", 
                 Vector2(randf_range( - intensity, intensity), randf_range( - intensity, intensity)), 
                shake_speed)


        shake_tween.tween_property( %Core, "position", Vector2.ZERO, 0.0)

    else:

        shake_tween = create_tween().set_loops()
        shake_tween.tween_property( %Core, "position", 
            Vector2(randf_range( - intensity, intensity), randf_range( - intensity, intensity)), 
            shake_speed)
        shake_tween.tween_property( %Core, "position", 
            Vector2(randf_range( - intensity, intensity), randf_range( - intensity, intensity)), 
            shake_speed)


func stop_shake():
    if shake_tween and shake_tween.is_running():
        shake_tween.kill()
    %Core.position = Vector2.ZERO





func flash_lock_in(flash_count: int = 3, flash_duration: float = 0.1, flash_color = Color.WHITE):
    var original_color = Refs.pallet.black_hole_maw
    var flash_tween = create_tween()

    for i in range(flash_count):

        flash_tween.tween_interval(flash_duration / flash_count)
        flash_tween.tween_callback( func(): %"Maw Art".material.set_shader_parameter("color", original_color))
