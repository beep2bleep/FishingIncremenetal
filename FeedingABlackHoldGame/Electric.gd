extends Node2D
class_name Electric

var base_damage = 0
var max_chains = 0
var fork_chance = 0.0
var chain_distance = 32.0
var crit_chance = 0.0
var crit_bonus = 0.0
var enable = false
var damage = 0
var is_crit = false
var visited_targets: Array = []
var all_targets: Array = []
var unused_tendrils: Array = []
var color: Color
var from_object_type

var tendril_width_factor = 1.0


var chain_distance_squared: float = 0.0

func setup(_damage, _max_chains, _chain_distance, _fork_chance, _is_crit, _crit_bonus, _color, _object_type):
    show()
    enable = true

    for child in %Tendrils.get_children():
        child.hide()
        child.clear_points()

    visited_targets.clear()
    unused_tendrils = %Tendrils.get_children()

    from_object_type = _object_type
    base_damage = _damage
    damage = base_damage
    max_chains = _max_chains
    chain_distance = _chain_distance * Util.get_zoom_factor()
    chain_distance_squared = chain_distance * chain_distance
    fork_chance = _fork_chance
    is_crit = _is_crit
    crit_bonus = _crit_bonus
    color = _color

    if _object_type == Util.OBJECT_TYPES.ASTEROID:
        tendril_width_factor = 0.75
    elif _object_type == Util.OBJECT_TYPES.STAR:
        tendril_width_factor = 1.0
        Global.main.camera_2d.add_trauma(0.15 if is_crit else 0.1)




    if is_crit:
        damage *= crit_bonus






    _generate_and_draw_chains()

func _generate_and_draw_chains():
    var max_radius = max_chains * chain_distance



    var candidates = Global.main.object_manager.get_objects_near(global_position, max_radius, true, true)

    if candidates.is_empty():
        clean_up()
        return


    var num_forks = 1
    for i in range(5):
        if randf() < fork_chance:
            num_forks += 1


    var visited: = {}
    var tendril_targets: Array = []


    var candidate_map: Dictionary = {}
    for candidate in candidates:
        candidate_map[candidate] = candidate.global_position


    for fork_idx in range(num_forks):
        var chain: Array = []
        var current_pos = global_position

        for chain_idx in range(max_chains):


            var best_target = null
            var best_dist_squared = chain_distance_squared + 1.0

            for candidate in candidates:
                if visited.has(candidate):
                    continue


                var candidate_pos = candidate_map[candidate]
                var dist_squared = candidate_pos.distance_squared_to(current_pos)

                if dist_squared > chain_distance_squared:
                    continue

                if dist_squared < best_dist_squared:
                    best_target = candidate
                    best_dist_squared = dist_squared

            if best_target == null:
                break

            visited[best_target] = true
            chain.append(best_target)
            current_pos = candidate_map[best_target]

        if not chain.is_empty():
            tendril_targets.append(chain)


    _draw_tendrils(tendril_targets)

    %Timer.start()

func _draw_tendrils(tendril_targets: Array):

    var tendril_color = Refs.pallet.electric_crit_color if is_crit else color

    for tendril_chain in tendril_targets:
        if tendril_chain.is_empty():
            continue

        if unused_tendrils.is_empty():
            break

        var line: Tendril = unused_tendrils.pop_back()
        line.show()
        line.clear_points()
        line.material.set_shader_parameter("base_color", tendril_color)
        line.width = 100 * Util.get_zoom_factor() * tendril_width_factor


        line.add_point(to_local(global_position))
        for target in tendril_chain:
            line.add_point(to_local(target.global_position))
            chain_to_object(target)

        line.do_animation()



func chain_to_object(object):
    visited_targets.append(object)
    if object is SpaceObject:
        var damage_event: DamageEventData = object.take_damage(damage, object.global_position, is_crit)

        if from_object_type == Util.OBJECT_TYPES.ASTEROID:
            Global.session_stats.electric_damage += damage_event.damage
        elif from_object_type == Util.OBJECT_TYPES.STAR:
            Global.session_stats.star_electric_damage += damage_event.damage

func _on_timer_timeout() -> void :
    clean_up()

func clean_up():
    %Timer.stop()
    hide()
    if enable:
        enable = false
        FlairManager.electric_pool.append(self)
