extends Control
## Small illustrated epilogues drawn at the panel's native resolution.
var ending = "LastStation"
const INK = Color("171b24")
func _ready():
	custom_minimum_size.y = 150
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func _draw():
	var w = size.x
	var h = size.y
	draw_rect(Rect2(0,0,w,h), Color("263747"))
	draw_circle(Vector2(w*.7,h*.3),h*.21,Color("eec782"))
	draw_rect(Rect2(0,h*.67,w,h*.33),Color("716352"))
	if ending=="LastStation":
		for i in range(3):
			var x = w*(.18+.28*i)
			var box = Rect2(x,h*.4,w*.16,h*.4)
			draw_rect(box,INK)
			draw_rect(box.grow(-3),Color("a7835e"))
			var roof = PackedVector2Array([Vector2(x-8,h*.4),Vector2(x+w*.08,h*.2),Vector2(x+w*.16+8,h*.4)])
			draw_colored_polygon(roof,INK)
			draw_rect(Rect2(x+w*.04,h*.5,w*.045,h*.14),Color("f5d899"))
			draw_rect(Rect2(x+w*.11,h*.53,w*.025,h*.27),INK)
		for side in [-1,1]:
			draw_line(Vector2(w*.5+side*w*.08,h),Vector2(w*.5+side*w*.02,h*.76),INK,4,true)
	else:
		for side in [-1,1]:
			draw_line(Vector2(w*.5+side*w*.13,h),Vector2(w*.5+side*w*.07,h*.72),INK,5,true)
			draw_line(Vector2(w*.5+side*w*.07,h*.59),Vector2(w*.5+side*w*.01,h*.36),INK,3,true)
		for i in range(6):
			var y = h*(.78-i*.055)
			var x = w*(.52+i*.018)
			draw_line(Vector2(x,y),Vector2(x+7,y-3),Color("eec782"),3,true)
		for i in range(4):
			var x = w*(.18+i*.045)
			draw_polyline(PackedVector2Array([Vector2(x,h*.84),Vector2(x+5,h*.78),Vector2(x+9,h*.87)]),Color("c99556"),3,true)
