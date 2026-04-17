extends Control
class_name OpenPitEmpireMiniMap

var scene_ref: Node
var redraw_timer := 0.0
var dirty := true

func _process(delta: float) -> void:
    redraw_timer -= delta
    if redraw_timer > 0.0 or not dirty:
        return
    redraw_timer = 0.45
    dirty = false
    queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    if not scene_ref.has_method("draw_minimap_into"):
        return
    scene_ref.draw_minimap_into(self)

func mark_dirty() -> void:
    dirty = true
    redraw_timer = 0.0
