extends Control
## Code-drawn controls stay crisp at any UI scale.
var shooting = false
const Style = preload("res://Games/RowDivers/RowDiversStyle.gd")

func _ready() -> void:
	custom_minimum_size = Vector2(310, 170)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _key(rect: Rect2, text: String) -> void:
	draw_style_box(Style.panel(Color("263443"), Style.GOLD), rect)
	var font = Style.HEADING
	draw_string(font, rect.position + Vector2((rect.size.x-font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,26).x)/2, 39), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("f3e3c8"))

func _draw() -> void:
	var center = size.x * .5
	var gold = Style.GOLD
	if shooting:
		var mouse = Rect2(center-38, 16, 76, 116)
		draw_style_box(Style.panel(Color("263443"), gold), mouse)
		draw_style_box(Style.panel(gold, gold), Rect2(center-34,20,31,43))
		draw_line(Vector2(center,20),Vector2(center,68),Color("f3e3c8"),2,true)
		draw_line(Vector2(center-34,68),Vector2(center+34,68),gold,2,true)
		draw_line(Vector2(center-20,37),Vector2(center-28,1),gold,3,true)
		draw_circle(Vector2(center-28,1),4,gold)
	else:
		_key(Rect2(center-123,34,74,62), "A")
		_key(Rect2(center+49,34,74,62), "D")
		for side in [-1,1]:
			var x = center + side*29
			draw_line(Vector2(center,65),Vector2(x,65),gold,4,true)
			draw_polyline(PackedVector2Array([Vector2(x-side*10,55),Vector2(x,65),Vector2(x-side*10,75)]),gold,4,true)
		# Draw alternate arrow controls as geometry: web fonts omit these glyphs.
		for side in [-1,1]:
			var x = center + side*87
			draw_line(Vector2(x-side*13,124),Vector2(x+side*13,124),gold,3,true)
			draw_polyline(PackedVector2Array([Vector2(x+side*4,115),Vector2(x+side*13,124),Vector2(x+side*4,133)]),gold,3,true)
