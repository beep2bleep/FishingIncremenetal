extends Line2D
class_name Tendril

var electric_parent: Electric
var remaining_chains: int
var current_position: Vector2
var all_targets


func setup(_electric_parent, start_pos: Vector2, targets: Array, max_chains: int):
    clear_points()
    show()
    electric_parent = _electric_parent
    current_position = start_pos
    all_targets = targets
    remaining_chains = max_chains

    width = 100 * Util.get_zoom_factor()

    material.set_shader_parameter("base_color", Refs.pallet.electric_crit_color if electric_parent.is_crit else Refs.pallet.electric_base_color)

    add_point(electric_parent.to_local(start_pos))
    chain_next()
    $AnimationPlayer.play("Animation")


func do_animation():
    $AnimationPlayer.play("Animation")

func chain_next():
    if remaining_chains <= 0:
        return

    var next_target = find_random_target_from_grid(Global.main.object_manager.grid, Global.main.object_manager.cell_size)
    if next_target == null:
        return


    electric_parent.chain_to_object(next_target)

    add_point(electric_parent.to_local(next_target.global_position))

    current_position = next_target.global_position
    remaining_chains -= 1

    if randf() < electric_parent.fork_chance:
        if electric_parent.unused_tendrils.size() > 0:
            var fork = electric_parent.unused_tendrils.pop_back()

            fork.setup(electric_parent, current_position, all_targets, remaining_chains)

    chain_next()

func find_random_target_from_grid(grid: Dictionary, cell_size: float) -> Node2D:
    var cell = Vector2i(floor(current_position.x / cell_size), floor(current_position.y / cell_size))
    var possible_targets: Array = []

    for x in range(cell.x - 1, cell.x + 2):
        for y in range(cell.y - 1, cell.y + 2):
            var c = Vector2i(x, y)
            if not grid.has(c):
                continue
            for obj in grid[c]:
                if obj in electric_parent.visited_targets or obj.special_type != null:
                    continue
                var dist2 = obj.global_position.distance_squared_to(current_position)
                if dist2 <= electric_parent.chain_distance * electric_parent.chain_distance:
                    possible_targets.append(obj)

    if possible_targets.is_empty():
        return null
    return possible_targets.pick_random()
