extends Area2D
class_name UfoBonus

signal collected(ufo: UfoBonus)

const HOVER_RADIUS := 34.0
const CURSOR_TRIGGER_RADIUS := 52.0

var reward_value: int = 0
var travel_duration: float = 10.0
var start_x: float = 0.0
var end_x: float = 0.0
var base_y: float = 140.0
var elapsed: float = 0.0
var direction_sign: float = 1.0
var collected_once: bool = false

var collision_shape: CollisionShape2D

func _ready() -> void:
    collision_shape = CollisionShape2D.new()
    add_child(collision_shape)
    input_pickable = true
    monitoring = true
    monitorable = true
    if collision_shape != null:
        var circle := CircleShape2D.new()
        circle.radius = HOVER_RADIUS
        collision_shape.shape = circle
    if not mouse_entered.is_connected(_on_mouse_entered):
        mouse_entered.connect(_on_mouse_entered)
    queue_redraw()

func configure(from_x: float, to_x: float, y: float, duration: float, reward: int) -> void:
    start_x = from_x
    end_x = to_x
    base_y = y
    travel_duration = max(0.1, duration)
    reward_value = max(1, reward)
    elapsed = 0.0
    direction_sign = 1.0 if end_x >= start_x else -1.0
    position = Vector2(start_x, base_y)

func _process(delta: float) -> void:
    if collected_once:
        return
    _check_cursor_proximity_collect()
    if collected_once:
        return
    elapsed += max(0.0, delta)
    var t: float = clamp(elapsed / travel_duration, 0.0, 1.0)
    var x: float = lerpf(start_x, end_x, t)
    var bob: float = sin(elapsed * TAU * 0.36) * 14.0
    position = Vector2(x, base_y + bob)
    rotation = deg_to_rad(sin(elapsed * TAU * 0.27) * 9.0) * direction_sign

    var glow_phase: float = 0.5 + 0.5 * sin(elapsed * TAU * 0.22)
    modulate = Color(1.0, 1.0, 1.0, 0.78 + 0.22 * glow_phase)
    queue_redraw()

    if t >= 1.0:
        queue_free()

func _draw() -> void:
    var pulse: float = 0.5 + 0.5 * sin(elapsed * TAU * 0.22)
    var glow: Color = Color(0.6, 0.95, 1.0, 0.12 + 0.16 * pulse)
    draw_circle(Vector2.ZERO, 28.0 + pulse * 4.0, glow)
    draw_circle(Vector2(0.0, -10.0), 12.0, Color(0.5, 0.86, 1.0, 0.9))
    draw_circle(Vector2(-10.0, -1.0), 11.0, Color(0.75, 0.82, 0.92, 0.96))
    draw_circle(Vector2(10.0, -1.0), 11.0, Color(0.75, 0.82, 0.92, 0.96))
    draw_circle(Vector2(0.0, 4.0), 14.0, Color(0.27, 0.32, 0.42, 0.92))

func _on_mouse_entered() -> void:
    _collect()

func _check_cursor_proximity_collect() -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    if global_position.distance_to(mouse_pos) <= CURSOR_TRIGGER_RADIUS:
        _collect()

func _collect() -> void:
    if collected_once:
        return
    collected_once = true
    monitoring = false
    monitorable = false
    input_pickable = false
    collected.emit(self)
    queue_free()
