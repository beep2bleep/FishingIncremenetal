extends Area2D
class_name CoinPickup

signal collected(coin: CoinPickup, by_cursor: bool)
const CURSOR_PICKUP_RADIUS := 30.0

@export var value := 10
@export var flight_gravity := 980.0
@export var flight_air_drag := 0.985
@export var flight_max_fall_speed := 900.0
@export var floor_y := 670.0
@export var physics_radius := 9.0

@onready var label: Label = $Label
@onready var collider: CollisionShape2D = $CollisionShape2D

var velocity := Vector2.ZERO
var settled := false
var collected_once := false

func _ready() -> void:
    label.hide()
    var circle := CircleShape2D.new()
    circle.radius = CURSOR_PICKUP_RADIUS
    collider.shape = circle
    if not mouse_entered.is_connected(_on_mouse_entered):
        mouse_entered.connect(_on_mouse_entered)
    queue_redraw()
    _check_cursor_hover_collect()

func launch(initial_velocity: Vector2, floor_level: float) -> void:
    velocity = initial_velocity
    floor_y = floor_level
    settled = false

func _physics_process(delta: float) -> void:
    _check_cursor_hover_collect()

    if settled:
        return

    velocity.y = min(flight_max_fall_speed, velocity.y + flight_gravity * delta)
    velocity.x *= pow(flight_air_drag, delta * 60.0)
    position += velocity * delta

    if position.y >= floor_y:
        position.y = floor_y
        velocity = Vector2.ZERO
        settled = true

func _draw() -> void:
    draw_circle(Vector2.ZERO, 9.0, Color(0.95, 0.78, 0.16, 1.0))
    draw_circle(Vector2(-2.0, -2.0), 4.0, Color(1.0, 0.92, 0.45, 1.0))

func collect_by_hero() -> void:
    _collect(false)

func attract_to(target_pos: Vector2, strength: float, delta: float) -> void:
    var to_target: Vector2 = target_pos - position
    var dist: float = max(1.0, to_target.length())
    var dir: Vector2 = to_target / dist
    var accel: float = strength * clamp(520.0 / dist, 0.4, 1.6)
    velocity += dir * accel * delta
    position += velocity * delta
    velocity *= pow(0.96, delta * 60.0)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _collect_by_cursor()

func _on_mouse_entered() -> void:
    _collect_by_cursor()

func _collect_by_cursor() -> void:
    if not SaveHandler.has_fishing_upgrade("cursor_pickup_unlock"):
        return
    _collect(true)

func _collect(by_cursor: bool) -> void:
    if collected_once:
        return
    collected_once = true
    monitoring = false
    monitorable = false
    input_pickable = false
    collected.emit(self, by_cursor)

func _check_cursor_hover_collect() -> void:
    if collected_once:
        return
    if not SaveHandler.has_fishing_upgrade("cursor_pickup_unlock"):
        return
    var shape: Shape2D = collider.shape
    if shape == null:
        return
    var radius: float = CURSOR_PICKUP_RADIUS
    if shape is CircleShape2D:
        radius = float((shape as CircleShape2D).radius)
    var mouse_pos: Vector2 = get_global_mouse_position()
    if global_position.distance_to(mouse_pos) <= radius:
        _collect(true)
