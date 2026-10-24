extends Control
## A separate transform keeps the reminder independent of button hover feedback.
var pulse: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_center_pivot)
	_center_pivot()

func _center_pivot() -> void:
	pivot_offset = size * 0.5

func set_claimable(claimable: bool) -> void:
	if claimable:
		if pulse != null and pulse.is_valid(): return
		pulse = create_tween().set_loops()
		pulse.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		for color in [Color("ffd36a"), Color.WHITE, Color("ff7770"), Color.WHITE]:
			pulse.tween_property(self, "modulate", color, 1.5)
			pulse.parallel().tween_property(self, "scale", Vector2.ONE if color == Color.WHITE else Vector2.ONE * 1.06, 1.5)
	else:
		if pulse != null:
			pulse.kill()
			pulse = null
		modulate = Color.WHITE
		scale = Vector2.ONE
