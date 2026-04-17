extends CanvasLayer












var flash_rect: ColorRect = null
var flash_tween: Tween = null


var vignette_overlay: Control = null
var vignette_color: Color = Color.TRANSPARENT
var vignette_alpha: float = 0.0
var vignette_tween: Tween = null


var slowmo_tween: Tween = null

func _ready():

    layer = 100


    flash_rect = ColorRect.new()
    flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    flash_rect.color = Color.TRANSPARENT
    flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(flash_rect)


    vignette_overlay = Control.new()
    vignette_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    vignette_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vignette_overlay.connect("draw", _draw_vignette)
    add_child(vignette_overlay)


    _setup_fade()





func flash(color: Color = Color.WHITE, duration: float = 0.15, intensity: float = 0.4):
    if flash_tween and flash_tween.is_valid():
        flash_tween.kill()

    flash_rect.color = Color(color.r, color.g, color.b, intensity)

    flash_tween = create_tween()
    flash_tween.tween_property(flash_rect, "color:a", 0.0, duration)\
.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)





func vignette(color: Color = Color.ORANGE, duration: float = 2.0, intensity: float = 0.3):
    if vignette_tween and vignette_tween.is_valid():
        vignette_tween.kill()

    vignette_color = color
    vignette_alpha = intensity
    vignette_overlay.queue_redraw()

    vignette_tween = create_tween()
    vignette_tween.tween_method(_set_vignette_alpha, intensity, 0.0, duration)\
.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func _set_vignette_alpha(val: float):
    vignette_alpha = val
    vignette_overlay.queue_redraw()

func _draw_vignette():
    if vignette_alpha <= 0.01:
        return

    var size = vignette_overlay.get_viewport_rect().size
    var cx = size.x * 0.5
    var cy = size.y * 0.5
    var max_r = size.length() * 0.5


    var steps = 8
    for i in range(steps):
        var t = float(i) / steps
        var outer_r = max_r * (1.0 - t * 0.4)
        var alpha = vignette_alpha * (1.0 - t * t)

        if alpha < 0.005:
            continue

        var c = Color(vignette_color.r, vignette_color.g, vignette_color.b, alpha * 0.15)

        var thickness = max_r * 0.12
        var offset = thickness * t


        vignette_overlay.draw_rect(Rect2(0, offset, size.x, thickness), c)

        vignette_overlay.draw_rect(Rect2(0, size.y - offset - thickness, size.x, thickness), c)

        vignette_overlay.draw_rect(Rect2(offset, 0, thickness, size.y), c)

        vignette_overlay.draw_rect(Rect2(size.x - offset - thickness, 0, thickness, size.y), c)





func slowmo(time_scale: float = 0.3, duration: float = 0.1):
    if slowmo_tween and slowmo_tween.is_valid():
        slowmo_tween.kill()

    Engine.time_scale = time_scale


    slowmo_tween = create_tween()
    slowmo_tween.set_speed_scale(1.0 / time_scale)
    slowmo_tween.tween_property(Engine, "time_scale", 1.0, duration)\
.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)







func mega_laser_activate():
    flash(Color(0.6, 0.8, 1.0), 0.2, 0.35)
    slowmo(0.2, 0.08)


func overdrive_activate():
    flash(Color(1.0, 0.2, 0.05), 0.15, 0.3)
    vignette(Color(1.0, 0.3, 0.1), 2.0, 0.35)
    slowmo(0.3, 0.06)


func core_destroy():
    flash(Color(1.0, 0.4, 0.1), 0.25, 0.4)


func shockwave_activate():
    pass


func combo_milestone():
    flash(Color(1.0, 0.85, 0.2), 0.12, 0.2)





var fade_rect: ColorRect = null
var is_transitioning: bool = false
const FADE_DURATION: float = 0.3

func _setup_fade():

    fade_rect = ColorRect.new()
    fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    fade_rect.color = Color(0, 0, 0, 0)
    fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fade_rect.z_index = 10
    add_child(fade_rect)


func fade_in(duration: float = FADE_DURATION):
    if not fade_rect:
        return
    fade_rect.color = Color(0, 0, 0, 1)
    var tween = create_tween()
    tween.tween_property(fade_rect, "color:a", 0.0, duration)\
.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func fade_out(duration: float = FADE_DURATION):
    if not fade_rect:
        return
    fade_rect.color = Color(0, 0, 0, 0)
    var tween = create_tween()
    tween.tween_property(fade_rect, "color:a", 1.0, duration)\
.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
    return tween


func transition_to(scene_path: String, duration: float = FADE_DURATION):
    if is_transitioning:
        return
    is_transitioning = true


    var tween = fade_out(duration)
    if tween:
        await tween.finished


    get_tree().change_scene_to_file(scene_path)


    await get_tree().process_frame


    fade_in(duration)
    is_transitioning = false
