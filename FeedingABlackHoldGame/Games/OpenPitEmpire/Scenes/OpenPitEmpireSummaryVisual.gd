extends Control
class_name OpenPitEmpireSummaryVisual

enum VisualMode { GRAPH, MINED_MAP }

var mode: int = VisualMode.GRAPH
var summary_data: Dictionary = {}

func set_summary_data(data: Dictionary) -> void:
	summary_data = data.duplicate(true)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.025, 0.04, 0.07, 0.92), true)
	draw_rect(rect, Color(0.25, 0.72, 0.95, 0.55), false, 2.0)
	if mode == VisualMode.MINED_MAP:
		_draw_mined_map(rect.grow(-10.0))
	else:
		_draw_run_graph(rect.grow(-10.0))

func _draw_run_graph(rect: Rect2) -> void:
	var run_time: float = maxf(0.001, float(summary_data.get("run_time", 1.0)))
	var mining_time: float = clampf(float(summary_data.get("mining_time", 0.0)), 0.0, run_time)
	var cargo_ratio: float = clampf(float(summary_data.get("cargo_ratio", 0.0)), 0.0, 1.0)
	var fuel_ratio: float = clampf(float(summary_data.get("fuel_ratio", 0.0)), 0.0, 1.0)
	var clear_start_ratio: float = clampf(float(summary_data.get("clear_start_ratio", summary_data.get("clear_ratio", 0.0))), 0.0, 1.0)
	var clear_ratio: float = clampf(float(summary_data.get("clear_ratio", 0.0)), 0.0, 1.0)
	var bars := [
		{"label": "Fuel", "value": 1.0 - fuel_ratio, "color": Color(0.44, 0.78, 1.0, 0.95)},
		{"label": "Cargo", "value": cargo_ratio, "color": Color(0.34, 1.0, 0.66, 0.95)},
		{"label": "Time", "value": mining_time / run_time, "color": Color(1.0, 0.82, 0.38, 0.95)},
		{"label": "Mined", "value": clear_ratio, "start": clear_start_ratio, "color": Color(1.0, 0.44, 0.72, 0.95)},
	]
	var bar_h := maxf(16.0, rect.size.y / 6.0)
	for idx in range(bars.size()):
		var item: Dictionary = bars[idx]
		var y := rect.position.y + 26.0 + float(idx) * (bar_h + 10.0)
		var track := Rect2(rect.position.x + 64.0, y, rect.size.x - 74.0, bar_h)
		draw_string(get_theme_default_font(), Vector2(rect.position.x, y + bar_h * 0.75), str(item.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, 58.0, 14, Color(0.78, 0.9, 1.0, 0.92))
		draw_rect(track, Color(0.08, 0.12, 0.18, 0.95), true)
		if item.has("start"):
			var start_ratio := clampf(float(item.get("start", 0.0)), 0.0, 1.0)
			var end_ratio := clampf(float(item.get("value", 0.0)), start_ratio, 1.0)
			if start_ratio > 0.0:
				draw_rect(Rect2(track.position, Vector2(track.size.x * start_ratio, track.size.y)), Color(0.35, 0.43, 0.52, 0.6), true)
			var mined_width := track.size.x * maxf(0.0, end_ratio - start_ratio)
			if mined_width > 0.0:
				draw_rect(Rect2(track.position + Vector2(track.size.x * start_ratio, 0.0), Vector2(mined_width, track.size.y)), Color(item.get("color", Color.WHITE)), true)
		else:
			draw_rect(Rect2(track.position, Vector2(track.size.x * float(item.get("value", 0.0)), track.size.y)), Color(item.get("color", Color.WHITE)), true)
		draw_rect(track, Color(0.38, 0.62, 0.78, 0.5), false, 1.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), "RUN SHAPE", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 14, Color(0.88, 0.96, 1.0, 0.95))

func _draw_mined_map(rect: Rect2) -> void:
	var points: Array = summary_data.get("mined_points", [])
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), "MINED TRACE", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 14, Color(0.88, 0.96, 1.0, 0.95))
	var map_rect := Rect2(rect.position + Vector2(0.0, 22.0), rect.size - Vector2(0.0, 22.0))
	draw_rect(map_rect, Color(0.03, 0.06, 0.09, 0.96), true)
	if points.is_empty():
		draw_string(get_theme_default_font(), map_rect.position + Vector2(8.0, map_rect.size.y * 0.5), "No mined cells", HORIZONTAL_ALIGNMENT_LEFT, map_rect.size.x, 14, Color(0.72, 0.82, 0.92, 0.8))
		return
	var min_x := 999999
	var max_x := -999999
	var min_y := 999999
	var max_y := -999999
	for point_variant in points:
		var p: Vector2i = point_variant
		min_x = mini(min_x, p.x)
		max_x = maxi(max_x, p.x)
		min_y = mini(min_y, p.y)
		max_y = maxi(max_y, p.y)
	var span_x := maxf(1.0, float(max_x - min_x + 1))
	var span_y := maxf(1.0, float(max_y - min_y + 1))
	for point_variant in points:
		var p: Vector2i = point_variant
		var x := map_rect.position.x + (float(p.x - min_x) / span_x) * map_rect.size.x
		var y := map_rect.position.y + (float(p.y - min_y) / span_y) * map_rect.size.y
		draw_rect(Rect2(Vector2(x, y), Vector2(3.0, 3.0)), Color(0.38, 1.0, 0.72, 0.8), true)
