extends SpaceObject
class_name UFO

var color_highlight: Color
var base_spawn_radius = 600



func _ready():
    width = 18
    bonus_speed = -13
    object_type = Util.OBJECT_TYPES.UFO
    is_misc_type = true


func custom_process(delta):
    var direction_to_center = global_position.normalized()
    var tangential_direction = Vector2( - direction_to_center.y, direction_to_center.x)

    %Pivot.look_at(position - tangential_direction)

    %"Line Trail".update_trail(global_position, Time.get_ticks_msec() / 1000.0)


func setup():
    var dynamic_spawn_radius = (base_spawn_radius + Global.rng.randi_range(-100, 300)) * Util.get_zoom_factor()
    global_position = Util.get_random_point_on_a_circle(dynamic_spawn_radius)

    color_highlight = Refs.pallet.ufo_color
    %Pivot.modulate = color_highlight

func die():

    if is_dying == false:
        is_dying = true
        set_process(false)



        Global.session_stats.ufos_destroyed += 1

        Global.main.clicker.electric_charges += Global.mods.get_mod(Util.MODS.UFO_ELECTRIC_CHARGES_TO_ADD)



    FlairManager.create_particles_on_object_destoryed( %Pivot.global_position, color_highlight, 1, 16)


    clean_up()


func clean_up():
    queue_free()
