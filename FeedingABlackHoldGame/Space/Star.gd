extends SpaceObject
class_name Star

var time_to_add_when_breaks

var color_normal: Color
var color_highlight: Color

@export var base_texture: Texture2D
@export var laser_texture: Texture2D

var base_collision_radius = 500
@onready var tendril: Tendril = %Tendril


func on_special_type_update():
    if special_type != null:
        Global.main.object_manager.special_star_count += 1

        match special_type:
            Util.SPECIAL_TYPES.SUPERNOVA:
                Global.main.object_manager.supernova_star_count += 1
                %Label.text = ""
                %"Supernova Pivot".show()
                %"SF AnimationPlayer".play("SolarFlair")
                %"Supernova Effect".material.set_shader_parameter("color", Refs.pallet.supernova_color)
            Util.SPECIAL_TYPES.LASER:
                %"Background Effect".show()

                Global.main.object_manager.laser_star_count += 1

                %Label.text = ""
                $AnimationPlayer2.play("Laser Animation")

                %"Sprite2D Base".texture = laser_texture
                %"Sprite2D Base 2".texture = laser_texture
                %"Sprite2D Base2".texture = laser_texture
                %"Sprite2D Base3".texture = laser_texture
                %"Sprite2D Base4".texture = laser_texture
                %"Sprite2D Damage".texture = laser_texture
                %"Sprite2D Damage2".texture = laser_texture
                %"Sprite2D Damage3".texture = laser_texture
                %"Sprite2D Damage4".texture = laser_texture
                %"Special Overlay".show()

            Util.SPECIAL_TYPES.FIREBALL:
                Global.main.object_manager.fireball_star_count += 1
                %Label.text = "FIREBALL"
            Util.SPECIAL_TYPES.ELECTRIC:
                Global.main.object_manager.electric_star_count += 1
                %Label.text = ""

                tendril.show()
                tendril.clear_points()

                tendril.width = 200

                tendril.closed = true
                tendril.points = Util.get_evenly_spaced_points_on_a_circle(16, radius * 0.8)

func _ready():
    custom_tween_component = %CustomTweenComponent
    collision_art = %"Sprite2D Damage"

    object_type = Util.OBJECT_TYPES.STAR
    resource_type = Util.RESOURCE_TYPES.STAR

    SignalBus.pallet_updated.connect(_on_pallet_updated)


    base_health = Global.config.get_config(Util.CONFIG_TYPES.STAR_BASE_HEALTH)
    base_xp = Global.config.get_config(Util.CONFIG_TYPES.STAR_BASE_XP)
    expo_for_xp_teir = Global.config.get_config(Util.CONFIG_TYPES.STAR_EXPONENT_FOR_XP_TIER)

    %"Special Overlay".polygon = Util.get_evenly_spaced_points_on_a_circle(16, 570)

func setup(load_on_setup, is_dummy = false) -> void :
    hide()

    %"Background Effect".hide()
    %"Special Overlay".hide()

    $AnimationPlayer2.play("RESET")
    %Label.text = ""
    %"Supernova Pivot".hide()
    %"SF AnimationPlayer".stop()

    tendril.hide()





    can_be_damaged = false
    is_dying = false
    is_cleaning_up = false
    respawn = false

    special_type = null

    special_type_crit = false


    %Art.scale = Vector2.ZERO

    health_component.has_died = false

    var value = Global.rng.randf_range( - 0.99, 0.99) + (Global.mods.get_mod(Util.MODS.STAR_DENSITY) - 1.0)
    tier = int(floor(clamp(value, 0, max_tier - 1)))

    time_to_add_when_breaks = Global.mods.get_mod(Util.MODS.RUN_TIMER_AMOUNT_ON_STAR_DESTROYED)

    color_normal = colors[tier]


    size = randi_range(1, Global.mods.get_mod(Util.MODS.MAX_STAR_SIZE) if is_dummy == false else 3)

    var factor = 0.2 + 0.1 * size

    %"Special Flair".scale = Vector2(factor, factor)
    %"Base Art".scale = Vector2(factor, factor)
    %"Damage Art".scale = Vector2(factor, factor)

    var health = base_health * (size * (tier + 1.0) + tier * 2.0)
    base_value = base_xp * pow(expo_for_xp_teir, tier) * size

    resources_to_spawn = size * (tier + 1.0)
    xp_per_resource = float(base_value) / float(resources_to_spawn)

    health_component.setup(health)

    width = base_collision_radius * factor * 2.0



    health_component.size = Vector2(width, width)
    health_component.position = - health_component.size / 2.0

    %"Damage Art".global_position = global_position

    update_colors()




    %"Sprite2D Base".rotation_degrees = Global.rng.randi_range(0, 360)
    %"Sprite2D Damage".rotation_degrees = %"Sprite2D Base".rotation_degrees

    %"Sprite2D Base2".rotation_degrees = Global.rng.randi_range(0, 360)
    %"Sprite2D Damage2".rotation_degrees = %"Sprite2D Base2".rotation_degrees

    %"Sprite2D Base3".rotation_degrees = Global.rng.randi_range(0, 360)
    %"Sprite2D Damage3".rotation_degrees = %"Sprite2D Base3".rotation_degrees

    %"Sprite2D Base4".rotation_degrees = Global.rng.randi_range(0, 360)
    %"Sprite2D Damage4".rotation_degrees = %"Sprite2D Base4".rotation_degrees

    if is_dummy == false:

        if Global.main.object_manager.can_spawn_special_star():
            if Global.main.object_manager.need_to_spawn_special_start():
                var types = []
                var weights = []

                if Global.mods.get_mod(Util.MODS.SPECIAL_STAR_LASER_SPAWN_CHANCE) > 0:
                    types.append(Util.SPECIAL_TYPES.LASER)
                    weights.append(Global.mods.get_mod(Util.MODS.SPECIAL_STAR_LASER_SPAWN_CHANCE))

                if Global.mods.get_mod(Util.MODS.SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE) > 0:
                    types.append(Util.SPECIAL_TYPES.SUPERNOVA)
                    weights.append(Global.mods.get_mod(Util.MODS.SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE))

                if Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC) > 0:
                    types.append(Util.SPECIAL_TYPES.ELECTRIC)
                    weights.append(Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC))






                if types.size() > 0:
                    special_type = types[Global.rng.rand_weighted(weights)]

            else:
                if Global.main.object_manager.can_spawn_supernova_star() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE):
                    special_type = Util.SPECIAL_TYPES.SUPERNOVA
                elif Global.main.object_manager.can_spawn_laser_star() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_STAR_LASER_SPAWN_CHANCE):
                    special_type = Util.SPECIAL_TYPES.LASER
                elif Global.main.object_manager.can_spawn_electric_star() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC):
                    special_type = Util.SPECIAL_TYPES.ELECTRIC



    if special_type == null or special_type != Util.SPECIAL_TYPES.LASER:
        %"Sprite2D Base".texture = base_texture
        %"Sprite2D Base 2".texture = base_texture
        %"Sprite2D Base2".texture = base_texture
        %"Sprite2D Base3".texture = base_texture
        %"Sprite2D Base4".texture = base_texture
        %"Sprite2D Damage".texture = base_texture
        %"Sprite2D Damage2".texture = base_texture
        %"Sprite2D Damage3".texture = base_texture
        %"Sprite2D Damage4".texture = base_texture



    if load_on_setup == true:
        do_load()

    is_active = true


func do_load():
    %AnimationPlayer.play("pop_in_planet")
    show()


func on_load():
    can_be_damaged = true
    angular_velocity = randf_range(deg_to_rad(5), deg_to_rad(20))


func _on_pallet_updated():
    update_colors()


func update_colors():
    var color_normal_line = color_normal
    color_normal_line.v *= 1.0

    color_highlight = color_normal
    color_highlight.v *= 1.25

    var dark_color = color_normal
    dark_color.v *= 1.2

    var color_damage_line = color_normal
    color_damage_line.v *= 0.95

    var base_1_color = color_normal
    var base_2_color = color_normal
    var base_3_color = color_normal
    var base_4_color = color_normal
    var background_color = color_normal

    background_color.v *= 1.3

    base_1_color.v *= 1.15
    base_2_color.v *= 1.1
    base_3_color.v *= 1.05
    base_4_color.v *= 1.0

    %"Background Effect".material.set_shader_parameter("color", background_color)

    %"Sprite2D Base".modulate = base_1_color
    %"Sprite2D Base2".modulate = base_2_color
    %"Sprite2D Base3".modulate = base_3_color
    %"Sprite2D Base4".modulate = base_4_color


    var damage_1_color = color_normal
    var damage_2_color = color_normal
    var damage_3_color = color_normal
    var damage_4_color = color_normal

    damage_1_color.v *= 1.3
    damage_2_color.v *= 1.25
    damage_3_color.v *= 1.2
    damage_4_color.v *= 1.15


    %"Sprite2D Damage".modulate = damage_1_color
    %"Sprite2D Damage2".modulate = damage_2_color
    %"Sprite2D Damage3".modulate = damage_3_color
    %"Sprite2D Damage4".modulate = damage_4_color

    var electric_color = Refs.pallet.electric_star_base_color
    electric_color.h = color_highlight.h
    %Tendril.material.set_shader_parameter("base_color", electric_color)





func _on_health_component_death_event() -> void :
    die()


func special_die():
    is_active = false
    can_be_damaged = false
    respawn = false

    FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, size, width / 2.0)

    special_type = null

    clean_up()


func custom_process(delta):
    %"Sprite2D Base".rotation_degrees += 10 * delta
    %"Sprite2D Damage".rotation_degrees += 10 * delta

    %"Sprite2D Base2".rotation_degrees += 21 * delta
    %"Sprite2D Damage2".rotation_degrees += 21 * delta

    %"Sprite2D Base3".rotation_degrees += 24 * delta
    %"Sprite2D Damage3".rotation_degrees += 24 * delta

    %"Sprite2D Base4".rotation_degrees += 35 * delta
    %"Sprite2D Damage4".rotation_degrees += 35 * delta



    pass


func die():
    is_active = false
    can_be_damaged = false
    is_dying = true

    if is_cleaning_up == false:
        Global.session_stats.stars_destroyed_during_session += 1

        FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, 8.0, width / 1.95)

        var matter_gained = base_value * (1.0 + Global.mods.get_mod(Util.MODS.BONUS_MONEY_SCALE))
        var money_from_matter = matter_gained * Global.mods.get_mod(Util.MODS.MONEY_PER_MATTER)
        Global.session_stats.star_money += money_from_matter
        FlairManager.create_new_floating_text(global_position, int(money_from_matter), Util.FLOATING_TEXT_TYPES.MONEY, object_type)
        Global.global_resoruce_manager.change_resource_by_type(resource_type, matter_gained)

        Global.main.star_resource_pool.create_resource_changed(resource_type, resources_to_spawn, self, color_highlight, width / 2.0, xp_per_resource)

        var respawn_roll = Global.rng.randf()
        if respawn_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_RESPAWN_STAR_ON_BREAK):
            respawn = true

        var add_to_timer_roll = Global.rng.randf()
        if Global.game_state == Util.GAME_STATES.PLAYING and add_to_timer_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_ADD_TIME_ON_STAR_DESTROYED):
            Global.main.add_time_from_asteroid_destroyed(time_to_add_when_breaks)

        if special_type != null:
            Global.main.object_manager.special_star_count -= 1

            match special_type:
                Util.SPECIAL_TYPES.SUPERNOVA:
                    Global.main.object_manager.supernova_star_count -= 1
                    FlairManager.create_supernova(global_position, radius)

                Util.SPECIAL_TYPES.LASER:
                    Global.main.object_manager.laser_star_count -= 1
                    FlairManager.create_laser(global_position, get_tier_size_damage_scale(), color_highlight)

                Util.SPECIAL_TYPES.FIREBALL:
                    for i in range(Global.mods.get_mod(Util.MODS.SPECIAL_STAR_MAX_FIREBALLS)):

                        FlairManager.create_fireball(global_position, get_tier_size_damage_scale())
                    Global.main.object_manager.fireball_star_count -= 1

                Util.SPECIAL_TYPES.ELECTRIC:

                    if Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_STAR_ELECTRIC_CRIT_CHANCE):
                        special_type_crit = true

                    var electric_color = Refs.pallet.electric_star_base_color
                    electric_color.h = color_highlight.h

                    FlairManager.create_electric(global_position, get_tier_size_damage_scale(), object_type, special_type_crit, electric_color)
                    Global.main.object_manager.electric_star_count -= 1

        special_type = null

        clean_up()



var is_cleaning_up = false
func clean_up():
    destroyed.emit(self)
    if is_cleaning_up:
        return

    custom_tween_component.kill_tweens()
    is_cleaning_up = true
    linear_velocity = Vector2.ZERO
    angular_velocity = 0

    Global.main.object_manager.return_space_object(self)
