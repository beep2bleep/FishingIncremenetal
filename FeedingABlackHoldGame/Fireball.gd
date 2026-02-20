extends Node2D
class_name FireBall

var enable = false
var damage = 0
var speed = 1500
var max_chains = 3
var chains = 4:
    set(new_value):
        chains = new_value
        if chains <= 0:
            clean_up()

var chain_distance_base = 300
var chain_distance = chain_distance_base
var target: SpaceObject
var direction = Vector2.ZERO


var hit_targets: Dictionary = {}


var potential_targets: Array = []
var target_search_index: int = 0





func _ready() -> void :
    set_process(false)

func _process(delta: float) -> void :
    if not enable:
        return








    %"Line Trail".update_trail(global_position, Time.get_ticks_msec() / 1000.0)


    if target and is_instance_valid(target) and target.is_active:

        var dist_squared = global_position.distance_squared_to(target.global_position)
        if dist_squared <= target.radius_sqrd:


            hit_targets[target] = true
            target.take_damage(damage, global_position, false)
            chains -= 1
            target = null


            if chains > 0:
                find_new_target()
            else:
                clean_up()
        else:

            direction = global_position.direction_to(target.global_position)
            global_position += direction * speed * delta
    else:

        if chains > 0:
            find_new_target()
        else:
            clean_up()

func find_new_target():



    if potential_targets.is_empty() or target_search_index >= potential_targets.size():

        potential_targets = Global.main.object_manager.get_objects_near(
            global_position, 
            chain_distance, 
            true, 
            true
        )
        target_search_index = 0


        if potential_targets.is_empty():
            clean_up()
            return


        potential_targets.shuffle()


    while target_search_index < potential_targets.size():
        var obj = potential_targets[target_search_index]
        target_search_index += 1


        if not is_instance_valid(obj):
            continue

        if not obj.is_active:
            continue


        if hit_targets.has(obj):
            continue


        target = obj

        return


    clean_up()

var tween: Tween

func setup(_scaled_damage, _fireball_max_chains, _fireball_chain_distance_scale, delay = 0):
    if tween:
        tween.kill()

    %"Line Trail".reset()

    damage = _scaled_damage
    chain_distance = chain_distance_base * Util.get_zoom_factor()

    max_chains = _fireball_max_chains
    chains = _fireball_max_chains


    hit_targets.clear()
    potential_targets.clear()
    target_search_index = 0
    target = null





    enable = true

    if delay > 0:
        tween = create_tween()
        tween.tween_interval(delay)
        tween.tween_callback( func(): start_fireball())
    else:
        start_fireball()

func start_fireball():
    show()
    find_new_target()
    set_process(true)

func clean_up():

    enable = false
    %"Line Trail".reset()
    set_process(false)
    hide()

    if enable:
        FlairManager.fireball_pool.append(self)
