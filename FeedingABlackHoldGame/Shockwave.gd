extends CanvasLayer
class_name Shockwave

var shock_wave_tween: Tween
var duration = 1.3

func setup(duration = 1.0, glob_pos = null):
    var center = Vector2(0.5, 0.5)
    if glob_pos:
        var vp_size = Global.main.get_viewport_rect().size
        var x_fact = clamp(glob_pos.x / vp_size.x, 0, 1.0)
        var y_fact = clamp(glob_pos.y / vp_size.y, 0, 1.0)
        center = Vector2(x_fact, y_fact)



    show()

    %ColorRect.material.set_shader_parameter("center", center)
    %ColorRect.material.set_shader_parameter("radius", 0.0)
    %ColorRect.material.set_shader_parameter("strength", 0.0)

    if shock_wave_tween and shock_wave_tween.is_running():
        shock_wave_tween.kill()

    shock_wave_tween = create_tween()

    shock_wave_tween.tween_property( %ColorRect.material, "shader_parameter/radius", 1.0, duration).from(0.0)
    shock_wave_tween.parallel().tween_property( %ColorRect.material, "shader_parameter/strength", 0.08, duration * 0.2).from(0.0)

    shock_wave_tween.tween_callback( func(): clean_up())


func clean_up():
    hide()

    if shock_wave_tween and shock_wave_tween.is_running():
        shock_wave_tween.kill()

    %ColorRect.material.set_shader_parameter("radius", 0.0)

    FlairManager.shockwave_pool.append(self)
