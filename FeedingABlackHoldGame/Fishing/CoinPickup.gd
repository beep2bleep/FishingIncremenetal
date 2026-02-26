extends Area2D
class_name CoinPickup

signal collected(coin: CoinPickup, by_cursor: bool)

@export var value := 10
@export var flight_gravity := 980.0
@export var flight_air_drag := 0.985
@export var flight_max_fall_speed := 900.0
@export var floor_y := 670.0

@onready var label: Label = $Label
@onready var collider: CollisionShape2D = $CollisionShape2D

var velocity := Vector2.ZERO
var settled := false

func _ready() -> void:
    label.hide()
    var circle := CircleShape2D.new()
    circle.radius = 10.0
    collider.shape = circle
    if not mouse_entered.is_connected(_on_mouse_entered):
        mouse_entered.connect(_on_mouse_entered)
    queue_redraw()

func launch(initial_velocity: Vector2, floor_level: float) -> void:
    velocity = initial_velocity
    floor_y = floor_level
    settled = false

func _physics_process(delta: float) -> void:
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
    collected.emit(self, false)

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
        if not SaveHandler.has_fishing_upgrade("cursor_pickup_unlock"):
            return
        collected.emit(self, true)

func _on_mouse_entered() -> void:
    if not SaveHandler.has_fishing_upgrade("cursor_pickup_unlock"):
        return
    collected.emit(self, true)
