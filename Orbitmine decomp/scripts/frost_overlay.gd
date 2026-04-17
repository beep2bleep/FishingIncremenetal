extends CanvasLayer






var frost_control: Control = null
var current_intensity: float = 0.0
var frost_time: float = 0.0

func _ready():
    layer = 100


    frost_control = Control.new()
    frost_control.name = "FrostDraw"
    frost_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frost_control.visible = false
    frost_control.set_script(load("res://scripts/frost_draw.gd"))
    add_child(frost_control)

    print("[FrostOverlay] ❄️ 초기화 완료")

func _process(delta: float):
    if frost_control == null:
        return


    var vp_size = get_viewport().get_visible_rect().size
    if frost_control.size != vp_size:
        frost_control.position = Vector2.ZERO
        frost_control.size = vp_size


    if current_intensity > 0.01:
        frost_time += delta
        frost_control.visible = true
        frost_control.frost_intensity = current_intensity
        frost_control.frost_time = frost_time
        frost_control.queue_redraw()
    else:
        frost_control.visible = false


func set_cold_amount(amount: float):
    current_intensity = clampf(amount / 0.5, 0.0, 1.0)
