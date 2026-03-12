extends Control
class_name HoldRingGlyph

var progress: float = 0.0:
    set(value):
        progress = clamp(value, 0.0, 1.0)
        queue_redraw()

var ring_color: Color = Color(0.95, 0.95, 0.98, 1.0):
    set(value):
        ring_color = value
        queue_redraw()

var track_color: Color = Color(0.35, 0.38, 0.42, 0.9):
    set(value):
        track_color = value
        queue_redraw()

var thickness: float = 4.0:
    set(value):
        thickness = value
        queue_redraw()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = false
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    var radius: float = max(0.0, min(size.x, size.y) * 0.5 - thickness)
    if radius <= 0.0:
        return
    draw_arc(center, radius, 0.0, TAU, 48, track_color, thickness, true)
    if progress <= 0.0:
        return
    draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, ring_color, thickness, true)
