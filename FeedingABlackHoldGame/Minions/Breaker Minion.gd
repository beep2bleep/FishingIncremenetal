extends CharacterBody2D
class_name BreakerMinion

var direction = Vector2.ZERO

const BASE_SPEED = 200
var speed = BASE_SPEED
var acceleration = 400
var deceleration = 700
var mass = 5.0

var damage = 1.0
var gun_loaded = true


var target_object: Node2D:
    set(new_value):
        if target_object != new_value and target_object != null:
            target_object.destroyed.disconnect(_on_target_object_destroyed)

        target_object = new_value

        if target_object != null:
            target_object.destroyed.connect(_on_target_object_destroyed)


var dist_squared_from_target = INF

func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.game_state_changed.connect(_game_state_changed)
    update_colors()

func _game_state_changed():
    if Global.game_state == Util.GAME_STATES.PLAYING:
        set_physics_process(true)
    else:
        set_physics_process(false)


func _on_mod_changed(type: Util.MODS, old_value, new_value):
    return







func _on_pallet_updated():
    update_colors()

func update_colors():
    pass

func _physics_process(delta):
    if target_object == null:
        target_nearby_asteroid()

    if target_object == null:
        var distance = global_position.length()
        if distance == 0.0:
            return

        var direction_to_center = global_position.normalized()
        var tangential_direction = Vector2( - direction_to_center.y, direction_to_center.x)
        var calc_speed = sqrt(Global.G / distance)
        velocity = tangential_direction * calc_speed * 3.0

    else:
        direction = (target_object.global_position - global_position).normalized()
        dist_squared_from_target = global_position.distance_squared_to(target_object.global_position)
        var target_velocity = direction * speed
        velocity = velocity.move_toward(target_velocity, acceleration * delta)

    %GPUParticles2D.emitting = velocity.length() > 0

    move_and_slide()

    if dist_squared_from_target < 256 and gun_loaded == true and target_object != null:
        target_object.take_damage(damage)
        gun_loaded = false
        %Timer.start()


    %"Art Pivot".look_at(global_position + velocity)


var amount_to_check = 3
func target_nearby_asteroid():
    var min_distance = INF
    var closest_object = null


    var asteroids = Global.main.object_manager.get_all_damageable_asteroids()
    asteroids.shuffle()

    for i in range(min(amount_to_check, asteroids.size())):
        var asteroid = asteroids[i]
        var distance = global_position.distance_squared_to(asteroid.global_position)
        if distance < min_distance or closest_object == null:
            min_distance = distance
            closest_object = asteroid

    target_object = closest_object


func _on_timer_timeout() -> void :
    gun_loaded = true

func _on_target_object_destroyed(object):
    if object == target_object:
        target_object = null
