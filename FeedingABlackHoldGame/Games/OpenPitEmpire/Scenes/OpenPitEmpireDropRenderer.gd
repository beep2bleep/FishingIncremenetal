extends Node2D
class_name OpenPitEmpireDropRenderer

var scene_ref: OpenPitEmpireMain
var _last_pickup_count := -1

func _process(_delta: float) -> void:
    if scene_ref == null:
        return
    if scene_ref.pickups.size() != _last_pickup_count:
        _last_pickup_count = scene_ref.pickups.size()
        queue_redraw()
    elif not scene_ref.pickups.is_empty():
        queue_redraw()

func _draw() -> void:
    if scene_ref == null or scene_ref.pickups.is_empty():
        return
    var pulse_t := Time.get_ticks_msec() * 0.001
    for pickup in scene_ref.pickups:
        var local := Vector2(pickup.get("position", Vector2.ZERO))
        var money := int(pickup.get("money", 0))
        var cargo := maxi(1, int(pickup.get("cargo", 1)))
        var radius := 5.0 + minf(float(cargo), 5.0)
        var pulse := 0.75 + 0.25 * sin(pulse_t * 4.0 + local.x * 0.02 + local.y * 0.03)
        draw_circle(local, radius + 6.0, Color(1.0, 0.86, 0.18, 0.12 * pulse))
        draw_circle(local, radius, Color(0.98, 0.82, 0.16, 0.95))
        draw_circle(local, radius * 0.45, Color(1.0, 0.95, 0.55, 1.0))
        draw_line(local + Vector2(-2.0, -radius - 5.0), local + Vector2(2.0, -radius - 1.0), Color(0.85, 1.0, 0.94, 0.8), 1.2)
        if money >= 1000:
            draw_arc(local, radius + 3.0, -PI * 0.35, PI * 0.35, 10, Color(0.95, 1.0, 0.7, 0.65), 1.2)
