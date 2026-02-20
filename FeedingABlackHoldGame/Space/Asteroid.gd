extends SpaceObject
class_name Asteroid

var static_rotation = 0
var time_to_add_when_breaks

var height

var color_normal: Color
var color_highlight: Color

static var noise: FastNoiseLite

@onready var tendril: Tendril = %Tendril


func on_special_type_update():
    if special_type != null:
        %"Special Overlay".visible = true
        %"Special Overlay".texture_rotation = randi_range(0, 360)

        match special_type:
            Util.SPECIAL_TYPES.ELECTRIC:
                tendril.show()
                tendril.clear_points()

                tendril.width = min(30 * Util.get_zoom_factor(), 100)
                tendril.closed = true
                tendril.points = %Line2D.points

            Util.SPECIAL_TYPES.GOLDEN:
                %GoldenTexture.show()
                update_colors()
            Util.SPECIAL_TYPES.RADIOACTIVE:
                %Radioactive.show()
                %Radioactive.setup_dummy_effect(width)



func _ready():
    if noise == null:
        noise = FastNoiseLite.new()
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
        noise.seed = randi()

    %DamageOverlayPolygon2D.global_position = global_position
    %DamageLine2D.global_position = global_position

    custom_tween_component = %CustomTweenComponent

    object_type = Util.OBJECT_TYPES.ASTEROID
    resource_type = Util.RESOURCE_TYPES.MATTER

    SignalBus.pallet_updated.connect(_on_pallet_updated)


    collision_art = %DamageOverlayPolygon2D
    collision_line = %DamageLine2D

    base_health = Global.config.get_config(Util.CONFIG_TYPES.ASTEROID_BASE_HEALTH)
    base_xp = Global.config.get_config(Util.CONFIG_TYPES.ASTEROID_BASE_XP)
    expo_for_xp_teir = Global.config.get_config(Util.CONFIG_TYPES.ASTEROID_EXPONENT_FOR_XP_TIER)




func setup(load_on_setup, is_dummy = false, _disable_respawns = false, _forced_type = null) -> void :
    hide()
    tendril.hide()
    %GoldenTexture.hide()
    %Radioactive.hide()

    can_be_damaged = false
    is_dying = false
    is_cleaning_up = false

    disable_respawns = _disable_respawns
    respawn = false

    special_type = null
    special_type_crit = false

    %"Special Overlay".visible = false
    %Art.scale = Vector2.ZERO

    health_component.has_died = false

    var value = Global.rng.randf_range( - 0.99, 0.99) + (Global.mods.get_mod(Util.MODS.ASTEROID_DENSITY) - 1.0)
    tier = int(floor(clamp(value, 0, max_tier - 1)))

    var num_points
    var noise_strength
    var noise_scale

    size = randi_range(1, Global.mods.get_mod(Util.MODS.MAX_ASTEROID_SIZE) if is_dummy == false else 3)

    color_normal = colors[tier]
    var _mass = max(1.0, tier * 5.0)

    var health = base_health * (size * (tier + 1.0) + tier * 2.0)
    base_value = base_xp * pow(expo_for_xp_teir, tier) * size

    resources_to_spawn = size * (tier + 1.0)
    xp_per_resource = float(base_value) / float(resources_to_spawn)

    health_component.setup(health)

    noise_scale = randf_range(0.8, 1.2)
    noise_strength = randf_range(0.3, 0.4) + (tier * 0.05)
    num_points = randi_range(5, 8) + int(tier * 1.5)

    var asteroid_size = 8.0 + size * 6.0

    generate_asteroid_shape_with_noise(asteroid_size, num_points, noise_scale, noise_strength)
    update_colors()

    %DamageOverlayPolygon2D.global_position = global_position
    %DamageLine2D.global_position = global_position

    time_to_add_when_breaks = 0

    if _forced_type != null:
        special_type = _forced_type

    elif is_dummy == false:
        time_to_add_when_breaks = Global.mods.get_mod(Util.MODS.RUN_TIMER_AMOUNT_ON_ASTEROID_DESTROYED)

        if Global.main.object_manager.can_spawn_electric_asteriod() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_ELECTRIC):
            special_type = Util.SPECIAL_TYPES.ELECTRIC
            Global.main.object_manager.electric_asteroid_count += 1
        elif Global.main.object_manager.can_spawn_golden_asteriod() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_GOLDEN):
            special_type = Util.SPECIAL_TYPES.GOLDEN
            Global.main.object_manager.golden_asteroid_count += 1
        elif Global.main.object_manager.can_spawn_radioactive_asteriod() and Global.rng.randf() <= Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_RADIOACTIVE):
            special_type = Util.SPECIAL_TYPES.RADIOACTIVE
            Global.main.object_manager.radioactive_asteroid_count += 1

    if load_on_setup == true:
        do_load()

    is_active = true


func do_load():
    $AnimationPlayer.play("pop_in")
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

    %Line2D.self_modulate = color_normal_line
    %DamageLine2D.self_modulate = dark_color



    if special_type and special_type == Util.SPECIAL_TYPES.GOLDEN:
        color_highlight = Refs.pallet.golden_color
        %Polygon2D.self_modulate = Refs.pallet.golden_color
        %DamageOverlayPolygon2D.self_modulate = Refs.pallet.golden_light_color


    else:



        %Polygon2D.self_modulate = color_normal
        %DamageOverlayPolygon2D.self_modulate = dark_color

    var electric_color = Refs.pallet.electric_base_color
    electric_color.h = color_highlight.h
    %Tendril.material.set_shader_parameter("base_color", electric_color)



func generate_asteroid_shape_with_noise(asteroid_size: float, point_count: int, noise_scale: float = 1.0, noise_strength: float = 0.3):

    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 1.0 / point_count * noise_scale

    var points: PackedVector2Array = []

    for i in range(point_count):
        var angle = TAU * i / point_count
        var base_radius = asteroid_size
        var offset = noise.get_noise_1d((Global.rng.randi_range(-1000, 1000)) + i * noise_scale) * noise_strength * asteroid_size
        var radius = base_radius + offset
        points.append(Vector2(cos(angle), sin(angle)) * radius)

    var min_x = INF
    var min_y = INF

    var max_x = - INF
    var max_y = - INF

    var centroid = Vector2.ZERO
    for p in points:
        centroid += p

        if p.x < min_x:
            min_x = p.x
        if p.x > max_x:
            max_x = p.x

        if p.x < min_y:
            min_y = p.y
        if p.y > max_y:
            max_y = p.y

    centroid /= points.size()

    for i in range(points.size()):
        points[i] -= centroid


    width = max_x - min_x
    height = max_y - min_y

    health_component.size = Vector2(width + 10, height + 20)
    health_component.position = - health_component.size / 2.0


    %Polygon2D.polygon = points
    %DamageOverlayPolygon2D.polygon = points
    %"Special Overlay".polygon = points

    %Line2D.clear_points()
    %Line2D.points = points
    %DamageLine2D.clear_points()
    %DamageLine2D.points = points

    %GoldenTexture.polygon = points


func _on_health_component_death_event() -> void :
    die()


func special_die():
    is_active = false
    can_be_damaged = false
    respawn = false

    FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, 1.0, width / 2.0)
    Global.main.asteroid_resource_pool.create_resource_changed(resource_type, resources_to_spawn, self, color_highlight, max(width, height) / 2.0, xp_per_resource)

    special_type = null

    clean_up()



func die():
    is_active = false
    can_be_damaged = false
    is_dying = true

    if is_cleaning_up == false:
        Global.session_stats.asteroids_destroyed_during_session += 1
        FlairManager.create_particles_on_object_destoryed(global_position, color_highlight, 1.0, width / 2.0)

        var matter_gained = base_value * (1.0 + Global.mods.get_mod(Util.MODS.BONUS_MONEY_SCALE))
        var money_from_matter = matter_gained * Global.mods.get_mod(Util.MODS.MONEY_PER_MATTER)
        var text_type = Util.FLOATING_TEXT_TYPES.MONEY

        if special_type != null and special_type == Util.SPECIAL_TYPES.GOLDEN:
            var golden_bonus_scale = 1.0
            golden_bonus_scale += Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_GOLDEN_BONUS_MONEY_SCALE)
            if Global.rng.randf() <= Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_GOLDEN_CRIT_CHANCE):
                golden_bonus_scale += Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_GOLDEN_CRIT_BONUS_MONEY_SCALE)
                special_type_crit = true

            money_from_matter *= golden_bonus_scale
            text_type = Util.FLOATING_TEXT_TYPES.GOLDEN_MONEY


            Global.session_stats.money_from_golden_asteroids += money_from_matter

        Global.session_stats.asteroid_money += money_from_matter
        FlairManager.create_new_floating_text(global_position, int(money_from_matter), text_type, object_type)
        Global.global_resoruce_manager.change_resource_by_type(resource_type, matter_gained)

        Global.main.asteroid_resource_pool.create_resource_changed(resource_type, resources_to_spawn, self, color_highlight, max(width, height), xp_per_resource)

        var respawn_roll = Global.rng.randf()
        if respawn_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_RESPAWN_ASTEROID_ON_BREAK):
            respawn = true

        var add_to_timer_roll = Global.rng.randf()
        if Global.game_state == Util.GAME_STATES.PLAYING and add_to_timer_roll <= Global.mods.get_mod(Util.MODS.CHANCE_TO_ADD_TIME_ON_ASTEROID_DESTROYED):
            Global.main.add_time_from_asteroid_destroyed(time_to_add_when_breaks)

        if special_type != null:
            match special_type:
                Util.SPECIAL_TYPES.ELECTRIC:

                    if Global.rng.randf() <= Global.mods.get_mod(Util.MODS.ELECTRIC_CRIT_CHANCE):
                        special_type_crit = true

                    Global.main.object_manager.electric_asteroid_count -= 1

                    var electric_color = Refs.pallet.electric_base_color
                    electric_color.h = color_highlight.h

                    FlairManager.create_electric(global_position, get_tier_size_damage_scale(), object_type, special_type_crit, electric_color)

                Util.SPECIAL_TYPES.GOLDEN:
                    Global.main.object_manager.golden_asteroid_count -= 1
                Util.SPECIAL_TYPES.RADIOACTIVE:
                    Global.main.object_manager.radioactive_asteroid_count -= 1
                    FlairManager.create_radioactive(global_position, get_tier_size_damage_scale())

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
func _on_health_component_health_changed() -> void :
    if special_type != null and special_type == Util.SPECIAL_TYPES.GOLDEN:
        var color = Color.WHITE
        color.a = 1.0 if health_component.get_health_percent() >= 1.0 else 0.33

        %GoldenTexture.material.set_shader_parameter("tint_color", color)
