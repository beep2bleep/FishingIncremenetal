extends Node2D
class_name OpenPitOrbitDropRenderer

var scene_ref: OpenPitOrbitMain

func _process(_delta: float) -> void:
    if scene_ref == null:
        return
    if not scene_ref.pickups.is_empty():
        queue_redraw()

func _draw() -> void:
    if scene_ref == null:
        return
    for pickup in scene_ref.pickups:
        var pickup_pos: Vector2 = pickup.get("position", Vector2.ZERO)
        var pulse := 0.7 + 0.3 * sin(scene_ref.ship_glow_phase * 6.0 + pickup_pos.x * 0.02)
        draw_circle(pickup_pos, 6.0, Color(1.0, 0.82, 0.34, 0.16 * pulse))
        draw_circle(pickup_pos, 3.5, Color(1.0, 0.86, 0.36, 0.96))
