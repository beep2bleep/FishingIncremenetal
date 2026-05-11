extends Control
class_name OpenPitEmpireSummaryVisual

enum VisualMode { GRAPH, HISTORY_MONEY, HISTORY_XP, NODE_CAPTURE, MAP_BEFORE, MAP_AFTER }

var mode: int = VisualMode.GRAPH
var summary_data: Dictionary = {}

const PLAYER_TRACE_COLOR := Color(0.42, 1.0, 0.88, 0.88)
const DRONE_TRACE_COLOR := Color(1.0, 0.62, 0.2, 0.88)
const BLOCK_COLOR := Color(0.28, 0.36, 0.44, 0.9)
const CORE_COLOR := Color(1.0, 0.28, 0.18, 0.95)
const ELECTRIC_COLOR := Color(0.24, 1.0, 0.48, 0.92)
const GOLD_COLOR := Color(1.0, 0.68, 0.22, 0.95)

func set_summary_data(data: Dictionary) -> void:
	summary_data = data.duplicate(true)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.025, 0.04, 0.07, 0.92), true)
	draw_rect(rect, Color(0.25, 0.72, 0.95, 0.55), false, 2.0)
	match mode:
		VisualMode.HISTORY_MONEY:
			_draw_history_chart(rect.grow(-10.0), "money_history", "MONEY, LAST 5 RUNS", "$")
		VisualMode.HISTORY_XP:
			_draw_history_chart(rect.grow(-10.0), "xp_history", "XP, LAST 5 RUNS", "")
		VisualMode.NODE_CAPTURE:
			_draw_node_capture_chart(rect.grow(-10.0))
		VisualMode.MAP_BEFORE:
			_draw_summary_map(rect.grow(-10.0), "FIREWALL BEFORE", false)
		VisualMode.MAP_AFTER:
			_draw_summary_map(rect.grow(-10.0), "FIREWALL AFTER", true)
		_:
			_draw_run_graph(rect.grow(-10.0))

func _draw_run_graph(rect: Rect2) -> void:
	var run_time: float = maxf(0.001, float(summary_data.get("run_time", 1.0)))
	var mining_time: float = clampf(float(summary_data.get("mining_time", 0.0)), 0.0, run_time)
	var cargo_ratio: float = clampf(float(summary_data.get("cargo_ratio", 0.0)), 0.0, 1.0)
	var fuel_ratio: float = clampf(float(summary_data.get("fuel_ratio", 0.0)), 0.0, 1.0)
	var clear_start_ratio: float = clampf(float(summary_data.get("clear_start_ratio", summary_data.get("clear_ratio", 0.0))), 0.0, 1.0)
	var clear_ratio: float = clampf(float(summary_data.get("clear_ratio", 0.0)), 0.0, 1.0)
	var bars := [
		{"label": "Fuel used", "value": 1.0 - fuel_ratio, "text": "%.1fs of %.1fs" % [mining_time, run_time], "color": Color(0.44, 0.78, 1.0, 0.95)},
		{"label": "Cargo filled", "value": cargo_ratio, "text": "%d / %d" % [int(summary_data.get("cargo_used", 0)), int(summary_data.get("cargo_capacity", 0))], "color": Color(0.34, 1.0, 0.66, 0.95)},
		{"label": "Run time", "value": mining_time / run_time, "text": "%.0f%%" % ((mining_time / run_time) * 100.0), "color": Color(1.0, 0.82, 0.38, 0.95)},
		{"label": "Breach", "value": clear_ratio, "start": clear_start_ratio, "text": "%.2f%% total  +%.2f%%" % [clear_ratio * 100.0, maxf(0.0, clear_ratio - clear_start_ratio) * 100.0], "color": Color(1.0, 0.44, 0.72, 0.95)},
	]
	var bar_h := maxf(16.0, rect.size.y / 6.0)
	for idx in range(bars.size()):
		var item: Dictionary = bars[idx]
		var y := rect.position.y + 26.0 + float(idx) * (bar_h + 10.0)
		var label_w := 96.0
		var value_w := 128.0
		var track := Rect2(rect.position.x + label_w, y, rect.size.x - label_w - value_w - 8.0, bar_h)
		draw_string(get_theme_default_font(), Vector2(rect.position.x, y + bar_h * 0.72), str(item.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, label_w - 6.0, 12, Color(0.78, 0.9, 1.0, 0.92))
		draw_rect(track, Color(0.08, 0.12, 0.18, 0.95), true)
		if item.has("start"):
			var start_ratio := clampf(float(item.get("start", 0.0)), 0.0, 1.0)
			var end_ratio := clampf(float(item.get("value", 0.0)), start_ratio, 1.0)
			if start_ratio > 0.0:
				draw_rect(Rect2(track.position, Vector2(track.size.x * start_ratio, track.size.y)), Color(0.35, 0.62, 0.95, 0.72), true)
			var mined_width := track.size.x * maxf(0.0, end_ratio - start_ratio)
			if mined_width > 0.0:
				draw_rect(Rect2(track.position + Vector2(track.size.x * start_ratio, 0.0), Vector2(mined_width, track.size.y)), Color(item.get("color", Color.WHITE)), true)
		else:
			var value_ratio := clampf(float(item.get("value", 0.0)), 0.0, 1.0)
			draw_rect(Rect2(track.position, Vector2(track.size.x * value_ratio, track.size.y)), Color(item.get("color", Color.WHITE)), true)
		draw_rect(track, Color(0.38, 0.62, 0.78, 0.5), false, 1.0)
		draw_string(get_theme_default_font(), Vector2(track.end.x + 6.0, y + bar_h * 0.72), str(item.get("text", "")), HORIZONTAL_ALIGNMENT_LEFT, value_w, 12, Color(0.94, 0.98, 1.0, 0.94))
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), "RUN SHAPE: fuel, cargo, time, breach progress", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 13, Color(0.88, 0.96, 1.0, 0.95))

func _draw_history_chart(rect: Rect2, key: String, title: String, prefix: String) -> void:
	var rows: Array = summary_data.get(key, [])
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 14, Color(0.88, 0.96, 1.0, 0.95))
	var chart_rect := Rect2(rect.position + Vector2(0.0, 24.0), rect.size - Vector2(0.0, 24.0))
	if rows.is_empty():
		draw_string(get_theme_default_font(), chart_rect.position + Vector2(8.0, chart_rect.size.y * 0.5), "No run history yet", HORIZONTAL_ALIGNMENT_LEFT, chart_rect.size.x, 14, Color(0.72, 0.82, 0.92, 0.8))
		return
	var max_value := 1.0
	for row_variant in rows:
		var row: Dictionary = row_variant
		max_value = maxf(max_value, float(row.get("value", 0.0)))
	var gap := 8.0
	var bar_w := (chart_rect.size.x - gap * float(rows.size() - 1)) / float(maxi(1, rows.size()))
	for idx in range(rows.size()):
		var row: Dictionary = rows[idx]
		var value := float(row.get("value", 0.0))
		var h := chart_rect.size.y * 0.62 * clampf(value / max_value, 0.0, 1.0)
		var x := chart_rect.position.x + float(idx) * (bar_w + gap)
		var base_y := chart_rect.end.y - 18.0
		var bar := Rect2(Vector2(x, base_y - h), Vector2(bar_w, h))
		draw_rect(bar, Color(0.36, 0.82, 1.0, 0.9), true)
		draw_rect(bar, Color(0.78, 0.95, 1.0, 0.48), false, 1.0)
		draw_string(get_theme_default_font(), Vector2(x, base_y - h - 4.0), "%s%s" % [prefix, _format_compact_int(int(round(value)))], HORIZONTAL_ALIGNMENT_CENTER, bar_w, 12, Color(0.92, 0.98, 1.0, 0.95))
		draw_string(get_theme_default_font(), Vector2(x, chart_rect.end.y - 2.0), "#%d" % int(row.get("flight", idx + 1)), HORIZONTAL_ALIGNMENT_CENTER, bar_w, 11, Color(0.76, 0.86, 0.96, 0.9))

func _draw_node_capture_chart(rect: Rect2) -> void:
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), "NODES MINED VS CAPTURED", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 14, Color(0.88, 0.96, 1.0, 0.95))
	var mined := float(summary_data.get("nodes_mined", 0))
	var captured := float(summary_data.get("captured_units", 0))
	var drone_captured := float(summary_data.get("drone_captured_units", 0))
	var max_value := maxf(1.0, maxf(mined, captured))
	var rows := [
		{"label": "Nodes mined", "value": mined, "color": Color(0.45, 0.84, 1.0, 0.95)},
		{"label": "Cargo captured", "value": captured, "color": Color(0.46, 1.0, 0.68, 0.95)},
		{"label": "Drone captured", "value": drone_captured, "color": DRONE_TRACE_COLOR},
	]
	var bar_h := 18.0
	for idx in range(rows.size()):
		var row: Dictionary = rows[idx]
		var y := rect.position.y + 32.0 + float(idx) * 32.0
		var track := Rect2(rect.position.x + 104.0, y, rect.size.x - 164.0, bar_h)
		draw_string(get_theme_default_font(), Vector2(rect.position.x, y + 13.0), str(row.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, 98.0, 12, Color(0.78, 0.9, 1.0, 0.92))
		draw_rect(track, Color(0.08, 0.12, 0.18, 0.95), true)
		draw_rect(Rect2(track.position, Vector2(track.size.x * clampf(float(row.get("value", 0.0)) / max_value, 0.0, 1.0), track.size.y)), Color(row.get("color", Color.WHITE)), true)
		draw_rect(track, Color(0.38, 0.62, 0.78, 0.5), false, 1.0)
		draw_string(get_theme_default_font(), Vector2(track.end.x + 6.0, y + 13.0), str(int(row.get("value", 0))), HORIZONTAL_ALIGNMENT_LEFT, 50.0, 12, Color(0.94, 0.98, 1.0, 0.94))
	var note := str(summary_data.get("node_note", ""))
	if note != "":
		draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 140.0), note, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 12, Color(1.0, 0.86, 0.45, 0.96))

func _draw_summary_map(rect: Rect2, title: String, include_run: bool) -> void:
	draw_string(get_theme_default_font(), rect.position + Vector2(0.0, 14.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 14, Color(0.88, 0.96, 1.0, 0.95))
	var map_rect := Rect2(rect.position + Vector2(0.0, 22.0), rect.size - Vector2(0.0, 22.0))
	draw_rect(map_rect, Color(0.03, 0.06, 0.09, 0.96), true)
	var points: Array = summary_data.get("map_points", [])
	if points.is_empty():
		draw_string(get_theme_default_font(), map_rect.position + Vector2(8.0, map_rect.size.y * 0.5), "No map data", HORIZONTAL_ALIGNMENT_LEFT, map_rect.size.x, 14, Color(0.72, 0.82, 0.92, 0.8))
		return
	var bounds: Dictionary = summary_data.get("map_bounds", {})
	var min_x := float(bounds.get("min_x", -100.0))
	var min_y := float(bounds.get("min_y", -100.0))
	var span_x := maxf(1.0, float(bounds.get("span_x", 200.0)))
	var span_y := maxf(1.0, float(bounds.get("span_y", 200.0)))
	var scale := minf(map_rect.size.x / span_x, map_rect.size.y / span_y)
	var draw_size := Vector2(span_x * scale, span_y * scale)
	var draw_origin := map_rect.position + (map_rect.size - draw_size) * 0.5
	draw_rect(Rect2(draw_origin, draw_size), Color(0.045, 0.075, 0.11, 0.78), true)
	var cell_size := Vector2(maxf(1.0, ceilf(scale)), maxf(1.0, ceilf(scale)))
	for point_variant in points:
		var point: Dictionary = point_variant
		var source := str(point.get("source", "block"))
		var p := Vector2i(int(point.get("x", 0)), int(point.get("y", 0)))
		var x := draw_origin.x + (float(p.x) - min_x) * scale
		var y := draw_origin.y + (float(p.y) - min_y) * scale
		var color := _map_point_color(point) if include_run or source == "block" else BLOCK_COLOR
		draw_rect(Rect2(Vector2(x, y), cell_size), color, true)
	_draw_legend(map_rect)

func _map_point_color(point: Dictionary) -> Color:
	var source := str(point.get("source", "block"))
	if source == "player":
		return PLAYER_TRACE_COLOR
	if source == "drone":
		return DRONE_TRACE_COLOR
	match int(point.get("type", 0)):
		1:
			return CORE_COLOR
		2:
			return ELECTRIC_COLOR
		3:
			return GOLD_COLOR
		_:
			return BLOCK_COLOR

func _draw_legend(map_rect: Rect2) -> void:
	var y := map_rect.position.y + 2.0
	var x := map_rect.end.x - 82.0
	var entries := [
		{"label": "You", "color": PLAYER_TRACE_COLOR},
		{"label": "Drone", "color": DRONE_TRACE_COLOR},
	]
	for idx in range(entries.size()):
		var entry: Dictionary = entries[idx]
		var row_y := y + float(idx) * 16.0
		draw_rect(Rect2(Vector2(x, row_y - 8.0), Vector2(10.0, 10.0)), Color(entry.get("color", Color.WHITE)), true)
		draw_string(get_theme_default_font(), Vector2(x + 14.0, row_y), str(entry.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, 64.0, 11, Color(0.88, 0.96, 1.0, 0.92))

func _format_compact_int(value: int) -> String:
	if absi(value) >= 1000000:
		return "%.1fM" % (float(value) / 1000000.0)
	if absi(value) >= 1000:
		return "%.1fK" % (float(value) / 1000.0)
	return str(value)
