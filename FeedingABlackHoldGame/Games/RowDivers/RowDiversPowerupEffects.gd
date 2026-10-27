extends Control
## A lower-screen glow and a small, bounded number of rising motes.
var battle: Node3D
var clock = 0.0
var gold_strength = 0.0
var red_strength = 0.0
var blue_strength = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	if not is_instance_valid(battle): return
	var playing: bool = not battle.suspended and not battle.ended
	gold_strength = move_toward(gold_strength, 1.0 if playing and battle.active("Harvester") else 0.0, delta * 3.0)
	red_strength = move_toward(red_strength, 1.0 if playing and battle.active("SlowDown") else 0.0, delta * 3.0)
	blue_strength = move_toward(blue_strength, 1.0 if playing and battle.active("GhostPower") else 0.0, delta * 3.0)
	if playing: clock += delta
	queue_redraw()

func _draw() -> void:
	_draw_power(Color("eabe56"), gold_strength, 0.0)
	_draw_power(Color("ed6666"), red_strength, 0.47)
	_draw_power(Color("8dcfff"), blue_strength, 0.23, 0.12)

func _draw_power(color: Color, strength: float, phase: float, glow_alpha: float = 0.18) -> void:
	if strength <= 0.001: return
	var height = size.y * 0.48
	for band in range(24):
		var fraction = float(band) / 24.0
		var tint = color
		tint.a = strength * glow_alpha * fraction * fraction
		draw_rect(Rect2(0, size.y - height + fraction * height, size.x, height / 24.0 + 1), tint)
	for index in range(16):
		var progress = fposmod(clock * (0.18 + (index % 3) * 0.025) + index * 0.618 + phase, 1.0)
		var x = fposmod(index * 0.618 + phase, 1.0) * size.x
		x += sin(clock * 0.8 + index * 2.4) * 13.0
		var pos = Vector2(x, size.y + 8 - progress * height)
		var tint = color.lightened(0.2)
		tint.a = strength * 0.62 * sin(progress * PI)
		draw_circle(pos, 1.1 + (index % 3) * 0.45, tint)
