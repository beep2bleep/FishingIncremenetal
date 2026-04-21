extends Control
class_name OpenPitOrbitPerfGraph

var scene_ref

const HISTORY_SIZE := 120
const FRAME_BUDGET_60 := 16.67
const FRAME_BUDGET_30 := 33.33
const BG_COLOR := Color(0.02, 0.04, 0.08, 0.88)
const BORDER_COLOR := Color(0.32, 0.7, 1.0, 0.65)
const FRAME_COLOR := Color(0.95, 0.95, 1.0, 0.95)
const CPU_COLOR := Color(0.45, 1.0, 0.55, 0.95)
const PHYSICS_COLOR := Color(1.0, 0.82, 0.3, 0.95)
const BUDGET_60_COLOR := Color(0.4, 1.0, 0.6, 0.22)
const BUDGET_30_COLOR := Color(1.0, 0.6, 0.3, 0.18)

var _frame_ms: Array[float] = []
var _cpu_ms: Array[float] = []
var _physics_ms: Array[float] = []
var _latest_hint := "Unknown"

func _ready() -> void:
    custom_minimum_size = Vector2(140.0, 96.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func push_sample(frame_ms: float, cpu_ms: float, physics_ms: float) -> void:
    _push_value(_frame_ms, frame_ms)
    _push_value(_cpu_ms, cpu_ms)
    _push_value(_physics_ms, physics_ms)
    _latest_hint = _estimate_limit(frame_ms, cpu_ms + physics_ms)
    queue_redraw()

func get_hint_text() -> String:
    return _latest_hint

func _push_value(buffer: Array[float], value: float) -> void:
    buffer.append(maxf(0.0, value))
    if buffer.size() > HISTORY_SIZE:
        buffer.remove_at(0)

func _estimate_limit(frame_ms: float, cpu_total_ms: float) -> String:
    if frame_ms <= 0.0:
        return "Unknown"
    var ratio := cpu_total_ms / frame_ms
    if ratio >= 0.78:
        return "CPU Limited"
    if ratio <= 0.5:
        return "GPU/Render Limited"
    return "Mixed"

func _draw() -> void:
    var perf_start_us: int = 0
    if scene_ref != null and scene_ref.has_method("perf_probe_begin"):
        perf_start_us = int(scene_ref.perf_probe_begin())
    var rect := Rect2(Vector2.ZERO, size)
    draw_rect(rect, BG_COLOR, true)
    draw_rect(rect, BORDER_COLOR, false, 2.0)
    if size.x < 8.0 or size.y < 8.0:
        if scene_ref != null and scene_ref.has_method("perf_probe_end"):
            scene_ref.perf_probe_end("perf_graph_draw", perf_start_us)
        return

    var max_ms := maxf(FRAME_BUDGET_30 * 1.2, _max_in_arrays())
    var plot_rect := rect.grow(-6.0)
    _draw_budget_line(plot_rect, FRAME_BUDGET_30, max_ms, BUDGET_30_COLOR)
    _draw_budget_line(plot_rect, FRAME_BUDGET_60, max_ms, BUDGET_60_COLOR)
    _draw_series(plot_rect, _frame_ms, max_ms, FRAME_COLOR, 2.0)
    _draw_series(plot_rect, _cpu_ms, max_ms, CPU_COLOR, 1.5)
    _draw_series(plot_rect, _physics_ms, max_ms, PHYSICS_COLOR, 1.0)
    if scene_ref != null and scene_ref.has_method("perf_probe_end"):
        scene_ref.perf_probe_end("perf_graph_draw", perf_start_us)

func _max_in_arrays() -> float:
    var max_value := 0.0
    for value in _frame_ms:
        max_value = maxf(max_value, value)
    for value in _cpu_ms:
        max_value = maxf(max_value, value)
    for value in _physics_ms:
        max_value = maxf(max_value, value)
    return max_value

func _draw_budget_line(plot_rect: Rect2, budget_ms: float, max_ms: float, color: Color) -> void:
    var y := plot_rect.position.y + plot_rect.size.y * (1.0 - clampf(budget_ms / max_ms, 0.0, 1.0))
    draw_line(Vector2(plot_rect.position.x, y), Vector2(plot_rect.end.x, y), color, 1.0)

func _draw_series(plot_rect: Rect2, samples: Array[float], max_ms: float, color: Color, width: float) -> void:
    if samples.size() < 2:
        return
    var points := PackedVector2Array()
    var denom := float(max(1, HISTORY_SIZE - 1))
    for idx in range(samples.size()):
        var x := plot_rect.position.x + plot_rect.size.x * (float(idx) / denom)
        var y := plot_rect.position.y + plot_rect.size.y * (1.0 - clampf(samples[idx] / max_ms, 0.0, 1.0))
        points.append(Vector2(x, y))
    for idx in range(points.size() - 1):
        draw_line(points[idx], points[idx + 1], color, width)
