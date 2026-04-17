extends CanvasLayer







var flash_control: Control = null

func _ready():
    layer = 99

    flash_control = Control.new()
    flash_control.name = "FlashDraw"
    flash_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    flash_control.visible = false
    add_child(flash_control)

var _flash_timer: float = 0.0
var _flash_duration: float = 0.0
var _flash_color: Color = Color.WHITE

func _process(delta: float):
    if flash_control == null:
        return


    var vp_size = get_viewport().get_visible_rect().size
    if flash_control.size != vp_size:
        flash_control.position = Vector2.ZERO
        flash_control.size = vp_size

    if _flash_timer > 0:
        _flash_timer -= delta
        flash_control.visible = true
        flash_control.queue_redraw()
    else:
        flash_control.visible = false


func flash(color: Color = Color.WHITE, duration: float = 0.25):
    _flash_color = color
    _flash_duration = duration
    _flash_timer = duration

    if not flash_control.draw.is_connected(_on_draw):
        flash_control.draw.connect(_on_draw)

func _on_draw():
    var t = _flash_timer / _flash_duration if _flash_duration > 0 else 0.0

    var alpha = t * t * 0.85
    var c = Color(_flash_color.r, _flash_color.g, _flash_color.b, alpha)
    flash_control.draw_rect(Rect2(Vector2.ZERO, flash_control.size), c)
