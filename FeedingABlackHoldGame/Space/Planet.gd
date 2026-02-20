extends SpaceObject
class_name Planet

var static_rotation = 0

var time_to_add_when_breaks

var color_normal: Color
var color_highlight: Color

var base_collision_radius = 56


func on_special_type_update():
    if special_type != null:




        match special_type:
            Util.SPECIAL_TYPES.MOONS:
                %"Special Overlay".visible = true


                %"Sprite2D Clouds".hide()
                %"Sprite2D Clouds Damage".hide()
                for i in range(randi_range(1, Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_MAX_MOONS))):
                    var moon: Moon = FlairManager.get_moon()
                    if moon != null:
                        Util.orphan(moon)
                        %Moons.add_child(moon)
                        moon.on_added_to_planet()
                        moon.scale = Vector2(0.7, 0.7)
                        moon.position = Util.get_random_point_on_a_circle(width / 2.0 + 11)
            Util.SPECIAL_TYPES.FROZEN:
                %ForzenEffect.show()
            Util.SPECIAL_TYPES.PINATA:

                %"Pinata Effect".show()
                %PinataShader.material.set_shader_parameter("speed", Global.rng.randf_range(0.4, 0.5))



func _ready():
    custom_tween_component = %CustomTweenComponent
    collision_art = %"Sprite2D Damage"

    object_type = Util.OBJECT_TYPES.PLANET
    resource_type = Util.RESOURCE_TYPES.PLANET

    base_collision_radius = 56
    SignalBus.pallet_updated.connect(_on_pallet_updated)

    base_health = Global.config.get_config(Util.CONFIG_TYPES.PLANET_BASE_HEALTH)
    base_xp = Global.config.get_config(Util.CONFIG_TYPES.PLANET_BASE_XP)
    expo_for_xp_teir = Global.config.get_config(Util.CONFIG_TYPES.PLANET_EXPONENT_FOR_XP_TIER)

    %"Special Overlay".polygon = Util.get_evenly_spaced_points_on_a_circle(16, 64)


func setup(load_on_setup, is_dummy = false) -> void :
    hide()

    %ForzenEffect.hide()
    %"Pinata Effect".hide()

    %"Special Overlay".visible = false



    can_be_damaged = false
    is_dying = false
    is_cleaning_up = false
    respawn = false

    special_type = null
    special_type_crit = false

    %Art.scale = Vector2.ZERO

    health_component.has_died = false

    var value = Global.rng.randf_range( - 0.99, 0.99) + (Global.mods.get_mod(Util.MODS.PLANET_DENSITY) - 1.0)
    tier = int(floor(clamp(value, 0, max_tier - 1)))

    var random_cloud = Refs.cloud_textures[tier]
    %"Sprite2D Clouds".texture = random_cloud
    %"Sprite2D Clouds Damage".texture = random_cloud

    %"Sprite2D Clouds".show()
    %"Sprite2D Clouds Damage".show()

    time_to_add_when_breaks = Global.mods.get_mod(Util.MODS.RUN_TIMER_AMOUNT_ON_PLANET_DESTROYED)

    color_normal = colors[tier]
    var _mass = max(1.0, tier * 5.0) * base_health



    size = randi_range(1, Global.mods.get_mod(Util.MODS.MAX_PLANET_SIZE) if is_dummy == false else 3)

    var factor = 1.0 + 0.1 * size

    %"Special Flair".scale = Vector2(factor, factor)
    %"Sprite2D Base".scale = Vector2(factor, factor)
    %"Sprite2D Damage".scale = Vector2(factor, factor)


    var health = base_health * (size * (tier + 1.0) + tier * 2.0)
    base_value = base_xp * pow(expo_for_xp_teir, tier) * size

    resources_to_spawn = size * (tier + 1.0)


    xp_per_resource = float(base_value) / float(resources_to_spawn)

    health_component.setup(health)

    width = base_collision_radius * factor * 2.0
    health_component.size = Vector2(width, width)
    health_component.position = - health_component.size / 2.0



    %"Sprite2D Damage".global_position = global_position

    update_colors()

    if is_dummy == false:
        if Global.main.object_manager.can_spawn_moon_planet() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_SPAWN_CHANCE) and FlairManager.has_moons():
            special_type = Util.SPECIAL_TYPES.MOONS
            Global.main.object_manager.moon_planet_count += 1
        elif Global.main.object_manager.can_spawn_frozen_planet() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_CHANCE_TO_SPAWN_FROZEN):
            special_type = Util.SPECIAL_TYPES.FROZEN
            Global.main.object_manager.forzen_planet_count += 1
        elif Global.main.object_manager.can_spawn_pinata_planet() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_ASTEROID_PINATA_SPAWN_CHANCE):
            special_type = Util.SPECIAL_TYPES.PINATA
            Global.main.object_manager.pinata_planet_count += 1


    if load_on_setup == true:
        do_load()

    is_active = true


func do_load():
    %AnimationPlayer.play("pop_in_planet")
    show()


func on_load():
    can_be_damaged = true
    angular_velocity = randf_range(deg_to_rad(15), deg_to_rad(30)) * [-1, 1].pick_random()


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

    %"Sprite2D Base".modulate = color_normal
    %"Sprite2D Damage".modulate = dark_color


func _on_health_component_death_event() -> void :
    die()


func special_die():
    is_active = false
    can_be_damaged = false
    respawn = false

    FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, size, width / 2.0)

    special_type = null

    clean_up()


func die():
    is_active = false
    can_be_damaged = false
    is_dying = true

    if is_cleaning_up == false:
        Global.session_stats.planets_destroyed_during_session += 1

        FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, 2.0, width / 2.0)

        var matter_gained = base_value * (1.0 + Global.mods.get_mod(Util.MODS.BONUS_MONEY_SCALE))
        var money_from_matter = matter_gained * Global.mods.get_mod(Util.MODS.MONEY_PER_MATTER)
        Global.session_stats.planet_money += money_from_matter
        FlairManager.create_new_floating_text(global_position, int(money_from_matter), Util.FLOATING_TEXT_TYPES.MONEY, object_type)
        Global.global_resoruce_manager.change_resource_by_type(resource_type, matter_gained)

        Global.main.planet_resource_pool.create_resource_changed(resource_type, resources_to_spawn, self, color_highlight, width / 2.0, xp_per_resource)

        var respawn_roll = Global.rng.randf()
        if respawn_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_RESPAWN_PLANET_ON_BREAK):
            respawn = true

        var add_to_timer_roll = Global.rng.randf()
        if Global.game_state == Util.GAME_STATES.PLAYING and add_to_timer_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_ADD_TIME_ON_PLANET_DESTROYED):
            Global.main.add_time_from_asteroid_destroyed(time_to_add_when_breaks)


        if special_type != null:
            match special_type:
                Util.SPECIAL_TYPES.MOONS:
                    for moon in %Moons.get_children():
                        FlairManager.add_moon_to_clicker(moon)
                    Global.main.object_manager.moon_planet_count -= 1
                Util.SPECIAL_TYPES.FROZEN:
                    FlairManager.create_frozen_shards(global_position, get_tier_size_damage_scale(), color_highlight)
                    Global.main.object_manager.forzen_planet_count -= 1

                    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.FROZEN_PLANET_BREAK)
                Util.SPECIAL_TYPES.PINATA:
                    var asteroids = Global.main.object_manager.get_objects_from_pool(Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_ASTEROID_PINATA_AMOUNT_OF_ASTEROID), Util.OBJECT_TYPES.ASTEROID)
                    for asteroid: Asteroid in asteroids:
                        asteroid.setup(true, false, true, Util.SPECIAL_TYPES.GOLDEN)
                        asteroid.global_position = global_position + Util.get_random_point_in_circle(width / 2.0)

                        asteroid.tween_animate(global_position + Util.get_random_point_in_circle(width / 2.0 * 4.0))

                    Global.main.object_manager.pinata_planet_count -= 1

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
