extends Control
class_name OpenPitEmpireStarfield

const BASE_BG := Color(0.015, 0.02, 0.04, 1.0)
const GLOW_BG := Color(0.03, 0.045, 0.08, 1.0)
const STAR_COLORS := [
	Color(1.0, 0.96, 0.9, 1.0),
	Color(0.95, 0.98, 1.0, 1.0),
	Color(0.86, 0.96, 1.0, 1.0),
	Color(1.0, 0.88, 0.76, 1.0),
]
const STAR_LAYERS := [
	{"parallax": 0.18, "cell": 230.0, "count": 2, "sz_min": 0.7, "sz_max": 1.5, "a_min": 0.2, "a_max": 0.45},
	{"parallax": 0.11, "cell": 150.0, "count": 2, "sz_min": 1.0, "sz_max": 2.1, "a_min": 0.35, "a_max": 0.7},
	{"parallax": 0.05, "cell": 90.0, "count": 1, "sz_min": 1.3, "sz_max": 2.8, "a_min": 0.5, "a_max": 0.95},
]

var scroll_offset := Vector2.ZERO
var elapsed := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), BASE_BG, true)
	draw_circle(size * Vector2(0.72, 0.18), max(size.x, size.y) * 0.42, Color(GLOW_BG.r, GLOW_BG.g, GLOW_BG.b, 0.32))
	draw_circle(size * Vector2(0.18, 0.82), max(size.x, size.y) * 0.3, Color(0.06, 0.08, 0.14, 0.22))
	_draw_stars(size)

func _draw_stars(size: Vector2) -> void:
	var half_w := size.x * 0.5 + 120.0
	var half_h := size.y * 0.5 + 120.0
	var center := size * 0.5
	for layer in STAR_LAYERS:
		var parallax: float = layer.parallax
		var cell_size: float = layer.cell
		var star_count: int = layer.count
		var offset_x := scroll_offset.x * parallax
		var offset_y := scroll_offset.y * parallax
		var cx_min := int(floor((offset_x - half_w) / cell_size))
		var cx_max := int(floor((offset_x + half_w) / cell_size))
		var cy_min := int(floor((offset_y - half_h) / cell_size))
		var cy_max := int(floor((offset_y + half_h) / cell_size))
		for cx in range(cx_min, cx_max + 1):
			for cy in range(cy_min, cy_max + 1):
				for i in range(star_count):
					var sx := cx * cell_size + _star_hash(cx, cy, i * 3) * cell_size
					var sy := cy * cell_size + _star_hash(cx, cy, i * 3 + 1) * cell_size
					var local_x := sx - offset_x
					var local_y := sy - offset_y
					if abs(local_x) > half_w or abs(local_y) > half_h:
						continue
					var star_seed := _star_hash(cx, cy, i * 3 + 2)
					var size_px := lerpf(layer.sz_min, layer.sz_max, star_seed)
					var alpha := lerpf(layer.a_min, layer.a_max, _star_hash(cy, cx, i))
					if star_seed > 0.55:
						alpha *= 0.72 + 0.28 * sin(elapsed * (1.2 + star_seed * 2.1) + float(cx * 11 + cy * 7))
					alpha = clampf(alpha, 0.12, 1.0)
					var color_idx := mini(int(floor(star_seed * float(STAR_COLORS.size()))), STAR_COLORS.size() - 1)
					var color: Color = STAR_COLORS[color_idx]
					var pos := Vector2(local_x, local_y) + center
					if size_px > 1.2:
						draw_circle(pos, size_px * 1.8, Color(color.r, color.g, color.b, alpha * 0.18))
					draw_circle(pos, size_px, Color(color.r, color.g, color.b, alpha))
					if size_px > 1.6 and star_seed > 0.68:
						var cross_alpha := alpha * 0.4
						draw_line(pos + Vector2(-size_px * 1.6, 0.0), pos + Vector2(size_px * 1.6, 0.0), Color(color.r, color.g, color.b, cross_alpha), 1.0)
						draw_line(pos + Vector2(0.0, -size_px * 1.6), pos + Vector2(0.0, size_px * 1.6), Color(color.r, color.g, color.b, cross_alpha), 1.0)

func _star_hash(cx: int, cy: int, idx: int) -> float:
	var n := sin(float(cx) * 127.1 + float(cy) * 311.7 + float(idx) * 74.7) * 43758.5453
	return n - floor(n)
