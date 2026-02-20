extends CharacterBody2D
class_name CollectorMinion

var direction = Vector2.ZERO
var speed = 200
var acceleration = 400
var deceleration = 700
var mass = 5.0

var damage = 1.0
var gun_loaded = true


var target_resource: ResourceChanged:
    set(new_value):
        if target_resource != new_value and target_resource != null:
            target_resource.sucked_up.disconnect(_on_target_resource_sucked_up)

        target_resource = new_value

        if target_resource != null:
            target_resource.sucked_up.connect(_on_target_resource_sucked_up)


var dist_squared_from_target = INF

func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    update_colors()

func _on_pallet_updated():
    update_colors()

func update_colors():
    pass

func _physics_process(delta):
    if target_resource == null:
        target_nearby_asteroid()

    if target_resource == null:
        var distance = global_position.length()
        if distance == 0.0:
            return

        var direction_to_center = global_position.normalized()
        var tangential_direction = Vector2( - direction_to_center.y, direction_to_center.x)

        velocity = tangential_direction * sqrt(Global.G / distance) * 3.0

    else:

        direction = (target_resource.get_actual_global_position() - global_position).normalized()
        dist_squared_from_target = global_position.distance_squared_to(target_resource.get_actual_global_position())
        var target_velocity = direction * speed
        velocity = velocity.move_toward(target_velocity, acceleration * delta)

    %GPUParticles2D.emitting = velocity.length() > 0

    move_and_slide()

    if dist_squared_from_target < 256 and gun_loaded == true and target_resource != null:
        target_resource.get_sucked_up()
        gun_loaded = false
        %Timer.start()


    %"Art Pivot".look_at(global_position + velocity)


var amount_to_check = 3
func target_nearby_asteroid():
    var min_distance = INF
    var closest_object = null


    var resources = Global.main.resource_pool.get_all_active_resource_changed()
    resources.shuffle()

    for i in range(min(amount_to_check, resources.size())):
        var resource_changed = resources[i]
        var distance = global_position.distance_squared_to(resource_changed.get_actual_global_position())
        if distance < min_distance or closest_object == null:
            min_distance = distance
            closest_object = resource_changed

    target_resource = closest_object


func _on_timer_timeout() -> void :
    gun_loaded = true

func _on_target_resource_sucked_up(object):
    if object == target_resource:
        target_resource = null
