extends Control
## A wall-clock countdown, independent of gameplay speed or pause state.
signal finished
var deadline_msec := 0
var remaining := 0.0
var duration := 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(64, 64)
	hide()
	set_process(false)

func start(seconds := 1.0) -> void:
	duration = maxf(seconds, 0.001)
	deadline_msec = Time.get_ticks_msec() + ceili(duration * 1000.0)
	remaining = 1.0
	show()
	set_process(true)
	queue_redraw()

func _process(_delta: float) -> void:
	remaining = clampf((deadline_msec - Time.get_ticks_msec()) / (duration * 1000.0), 0.0, 1.0)
	queue_redraw()
	if remaining <= 0.0:
		hide()
		set_process(false)
		finished.emit()

func _draw() -> void:
	var center := size * 0.5
	draw_arc(center, 24, 0, TAU, 64, Color(1, 1, 1, 0.15), 4, true)
	draw_arc(center, 24, -PI * 0.5, -PI * 0.5 + TAU * remaining, 64, Color(0.93, 0.78, 0.51, remaining), 4, true)
	var font := ThemeDB.fallback_font
	var text := str(maxi(1, ceili(remaining * duration)))
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	draw_string(font, center + Vector2(-text_size.x * 0.5, 8), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 1, 1, remaining))
