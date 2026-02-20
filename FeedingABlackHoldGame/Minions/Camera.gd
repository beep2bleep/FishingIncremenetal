extends Camera2D








@export var decay: float = 0.67
@export var max_offset: Vector2 = Vector2(100, 75)
@export var max_roll: float = 0.1
@export var follow_node: Node2D

var trauma: float = 0.0
var trauma_power: int = 1.8

var min_zoom: = 0.42
var max_zoom: = 1.0
var zoom_factor: = 0.075
var controll_zoom_factor: = 0.5
var zoom_duration = 0.2
var target_zoom = 1.0:
    set(new_value):
        target_zoom = clamp(new_value, min_zoom, max_zoom)
        zoom = Vector2.ONE * target_zoom

func _unhandled_input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.UPGRADES:
        if event.is_action_pressed("zoom in"):
            target_zoom += zoom_factor
        if event.is_action_pressed("zoom out"):
            target_zoom -= zoom_factor






func _ready() -> void :

    randomize()

func _process(delta: float) -> void :
    if follow_node:
        global_position = follow_node.global_position
    if trauma:
        trauma = max(trauma - decay * delta, 0)
        shake()


func add_trauma(amount: float) -> void :
    if SaveHandler.screen_shake == true:
        trauma = min(trauma + amount, 0.45)


func shake() -> void :
    if SaveHandler.screen_shake == true:

        var amount = pow(trauma, trauma_power)
        rotation = max_roll * amount * randf_range(-1, 1)
        offset.x = max_offset.x * amount * randf_range(-1, 1)
        offset.y = max_offset.y * amount * randf_range(-1, 1)
    else:
        rotation = 0
        offset = Vector2.ZERO
