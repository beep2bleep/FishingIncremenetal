extends CanvasLayer





var vignette_control: Control = null

func _ready():
    layer = 90
    vignette_control = Control.new()
    vignette_control.set_anchors_preset(Control.PRESET_FULL_RECT)
    vignette_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vignette_control.set_script(load("res://scripts/fuel_vignette_draw.gd"))
    add_child(vignette_control)
