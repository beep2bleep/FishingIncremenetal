extends MultiMeshInstance2D
class_name ResourcePool

@export var base_scale = Vector2(1.0, 1.0)
@export var update_batch_size: int = 2
@export var max_particles_created_per_frame: int = 64
@export var duration_multiplier: float = 1.0
@export var enable_debug = false

@export_group("Density Suppression")
@export var enable_planet_suppression: bool = false
@export var planet_suppression_factor: float = 0.3
@export var enable_star_suppression: bool = false
@export var star_suppression_factor: float = 0.5
@export var enable_scale_compensation: bool = false
@export var max_scale_multiplier: float = 2.0


var particle_ids: PackedInt32Array = []
var start_angles: PackedFloat32Array = []
var start_radii: PackedFloat32Array = []
var start_rots: PackedFloat32Array = []
var durations: PackedFloat32Array = []
var elapsed_times: PackedFloat32Array = []
var xp_values: PackedFloat32Array = []
var particle_count: int = 0
var retired_ids = []


var update_index: int = 0


var creation_queue: Array = []


var pi_half = PI / 2.0
var pi = PI


var original_base_scale: Vector2

func _ready():

    original_base_scale = base_scale


    particle_ids.resize(2000)
    start_angles.resize(2000)
    start_radii.resize(2000)
    start_rots.resize(2000)
    durations.resize(2000)
    elapsed_times.resize(2000)
    xp_values.resize(2000)

    set_process(true)

func _process(delta: float) -> void :

    if not creation_queue.is_empty():
        var created_this_frame = 0
        while not creation_queue.is_empty() and created_this_frame < max_particles_created_per_frame:
            var queued = creation_queue.pop_front()
            _create_particle_immediate(queued.pos, queued.color, queued.xp)
            created_this_frame += 1

    if particle_count == 0:
        return


    var particles_to_update = ceili(float(particle_count) / float(update_batch_size))
    var start_idx = update_index * particles_to_update
    var end_idx = min(start_idx + particles_to_update, particle_count)


    var i = start_idx
    while i < end_idx:
        if i >= particle_count:
            break

        elapsed_times[i] += delta * update_batch_size
        var progress = elapsed_times[i] / durations[i]

        if progress >= 1.0:
            Global.black_hole.level_manager.add_xp(xp_values[i])
            _remove_particle_at_index(i)
            end_idx = min(end_idx, particle_count)
            continue

        progress = clamp(progress, 0.0, 1.0)
        var eased = 1.0 - cos(progress * pi_half)

        var radius = lerp(start_radii[i], 0.0, eased)
        var angle = start_angles[i] + pi * eased

        var cos_angle = cos(angle)
        var sin_angle = sin(angle)
        var pos = Vector2(cos_angle * radius, sin_angle * radius)
        var rot = start_rots[i] + pi * eased

        multimesh.set_instance_transform_2d(particle_ids[i], Transform2D(rot, base_scale, 0.0, pos))

        i += 1


    update_index = (update_index + 1) % update_batch_size

func _remove_particle_at_index(index: int):
    var id = particle_ids[index]
    multimesh.set_instance_color(id, Color.TRANSPARENT)
    retired_ids.append(id)


    var last_idx = particle_count - 1
    if index < last_idx:
        particle_ids[index] = particle_ids[last_idx]
        start_angles[index] = start_angles[last_idx]
        start_radii[index] = start_radii[last_idx]
        start_rots[index] = start_rots[last_idx]
        durations[index] = durations[last_idx]
        elapsed_times[index] = elapsed_times[last_idx]
        xp_values[index] = xp_values[last_idx]

    particle_count -= 1

func create_resource_changed(type, amount, from_node, color, spawn_radius, xp_to_add):

    if SaveHandler.black_hole_particles == false:
        Global.black_hole.level_manager.add_xp(xp_to_add * amount)
        return


    var suppression = 1.0

    if enable_planet_suppression and Global.mods.get_mod(Util.MODS.PLANET_DENSITY) > 1.0:
        var planet_density = Global.mods.get_mod(Util.MODS.PLANET_DENSITY)
        suppression /= (1.0 + (planet_density - 1.0) * planet_suppression_factor)

    if enable_star_suppression and Global.mods.get_mod(Util.MODS.STAR_DENSITY) > 1.0:
        var star_density = min(1.0, Global.mods.get_mod(Util.MODS.STAR_DENSITY))
        suppression /= (1.0 + (star_density - 1.0) * star_suppression_factor)


    var adjusted_amount = max(1, int(amount * suppression))


    var adjusted_xp = (xp_to_add * amount) / adjusted_amount


    if enable_scale_compensation:

        var scale_mult = max(1.0, lerp(1.0, max_scale_multiplier, 1.0 - suppression))
        base_scale = original_base_scale * scale_mult
    else:
        base_scale = original_base_scale


    if enable_debug:
        var scale_mult = base_scale.x / original_base_scale.x
        print("[ResourcePool] Original: amount=%d, xp_per=%.2f | Adjusted: amount=%d, xp_per=%.2f | Suppression=%.3f, Scale=%.2fx" % [
            amount, xp_to_add, adjusted_amount, adjusted_xp, suppression, scale_mult
        ])

    var center = from_node.global_position


    for i in adjusted_amount:
        var offset = Util.get_random_point_in_circle(spawn_radius)
        var pos = center + offset
        creation_queue.append({"pos": pos, "color": color, "xp": adjusted_xp})

func _create_particle_immediate(pos: Vector2, color: Color, xp_to_add: float):

    var required_size = particle_count + 1
    if required_size > particle_ids.size():
        var new_size = particle_ids.size() * 2
        particle_ids.resize(new_size)
        start_angles.resize(new_size)
        start_radii.resize(new_size)
        start_rots.resize(new_size)
        durations.resize(new_size)
        elapsed_times.resize(new_size)
        xp_values.resize(new_size)


    var id: int
    if not retired_ids.is_empty():
        id = retired_ids.pop_back()
    else:
        id = multimesh.visible_instance_count
        multimesh.visible_instance_count += 1


    var initial_rot = Global.rng.randf_range(0, TAU)
    multimesh.set_instance_transform_2d(id, Transform2D(initial_rot, base_scale, 0.0, pos))
    multimesh.set_instance_color(id, color)


    var idx = particle_count
    particle_ids[idx] = id

    var angle = pos.angle()
    var radius = pos.length()

    start_angles[idx] = angle
    start_radii[idx] = radius
    start_rots[idx] = initial_rot
    durations[idx] = (4.0 * min(radius / 1000.0, 1.0) + Global.rng.randf_range(0, 0.33)) * duration_multiplier
    elapsed_times[idx] = 0.0
    xp_values[idx] = xp_to_add

    particle_count += 1

func remove_instance_id(id: int):
    retired_ids.append(id)
    multimesh.set_instance_color(id, Color.TRANSPARENT)

func reset():

    for i in range(particle_count):
        var id = particle_ids[i]
        multimesh.set_instance_color(id, Color.TRANSPARENT)
        retired_ids.append(id)

    particle_count = 0
    update_index = 0
    creation_queue.clear()


    base_scale = original_base_scale
