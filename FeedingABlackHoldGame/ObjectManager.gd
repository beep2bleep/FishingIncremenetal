extends Node2D
class_name ObjectManager

@export var outer_radius = 500
@export var is_main_menu = false

var pool = {}

var max_asteroids = 0
var max_planets = 0
var max_stars = 0

var asteroids_to_prewarm = 200
var planets_to_prewarm = 150
var stars_to_prewarm = 50

var electric_asteroid_count = 0:
    set(new_value):
        electric_asteroid_count = max(0, new_value)
var max_electric_asteroids = 0

var radioactive_asteroid_count = 0:
    set(new_value):
        radioactive_asteroid_count = max(0, new_value)
var max_radioactive_asteroids = 0

var golden_asteroid_count = 0:
    set(new_value):
        golden_asteroid_count = max(0, new_value)
var max_golden_asteroids = 0

var moon_planet_count = 0:
    set(new_value):
        moon_planet_count = max(0, new_value)
var max_moon_planets = 0

var forzen_planet_count = 0:
    set(new_value):
        forzen_planet_count = max(0, new_value)
var max_frozen_planets = 0

var pinata_planet_count = 0:
    set(new_value):
        pinata_planet_count = max(0, new_value)
var max_pinata_planets = 0


var min_special_stars = 0
var max_special_stars = 0
var special_star_count = 0


var laser_star_count = 0:
    set(new_value):
        laser_star_count = max(0, new_value)
var max_laser_star_count = 0

var supernova_star_count = 0:
    set(new_value):
        supernova_star_count = max(0, new_value)
var max_supernova_star_count = 0

var fireball_star_count = 0:
    set(new_value):
        fireball_star_count = max(0, new_value)
var max_fireball_star_count = 0

var electric_star_count = 0:
    set(new_value):
        electric_star_count = max(0, new_value)
var max_electric_star_count = 0


var base_spawn_interval = 0.15
var base_spawn_amount = 8
var spawn_timer = 0.0
var spawn_queue = []


var cell_size = 64.0
var spatial_grid: Dictionary = {}


var boid_batch_size: int = 3
var boid_frame_counter: int = 0
var boid_batch_index: int = 0
var boid_strength = 2.5
var extra_space = 0.0
var accumulated_boid_forces: Dictionary = {}


var comet_shower_pitty_chacne = 0.0
var comet_show_session_cooldown = 0:
    set(new_value):
        comet_show_session_cooldown = max(0, new_value)
var comet_show_session_cooldown_amount = 5
var comet_pitty_chance = 0.0
var ufo_pitty_chance = 0.0


func _ready() -> void :
    for type in Util.OBJECT_TYPES.values():
        pool[type] = []

    comet_show_session_cooldown = SaveHandler.comet_show_session_cooldown

    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.black_hole_grew.connect(_on_black_hole_grew)
    SignalBus.game_state_changed.connect(_on_game_state_changed)

    asteroids_to_prewarm = Global.config.get_config(Util.CONFIG_TYPES.ASTEROIDS_TO_PREWARM)
    planets_to_prewarm = Global.config.get_config(Util.CONFIG_TYPES.PLANETS_TO_PREWARM)
    stars_to_prewarm = Global.config.get_config(Util.CONFIG_TYPES.STARS_TO_PREWARM)

    print(asteroids_to_prewarm)
    print(planets_to_prewarm)
    print(stars_to_prewarm)


    if is_main_menu == false:
        for timer in %Timers.get_children():
            timer.start()


func _physics_process(delta: float) -> void :
    spawn_timer -= delta
    if spawn_timer <= 0:
        spawn_timer += base_spawn_interval

        var dynamic_amount = base_spawn_amount + int(spawn_queue.size() / 20.0)
        dynamic_amount = clamp(dynamic_amount, base_spawn_amount, 30)

        var objects_to_spawn = []
        for i in range(min(dynamic_amount, spawn_queue.size())):
            objects_to_spawn.append(spawn_queue.pop_front())

        if not objects_to_spawn.is_empty():
            place_objects_in_donut(objects_to_spawn, Global.black_hole.gravity_radius, outer_radius, true)

func _process(delta: float) -> void :
    var objects = get_all_active_objects(true)
    var gravity_radius = Global.black_hole.gravity_radius if Global.black_hole else 128






    _rebuild_spatial_grid(objects)


    run_object_motion(objects, delta, gravity_radius)


    run_boids_batched(objects, delta)

    if is_main_menu:
        return


    if %Asteroids.get_child_count() < asteroids_to_prewarm:
        _create_asteroid()
    elif %Planets.get_child_count() < planets_to_prewarm:
        _create_planet()
    elif %Stars.get_child_count() < stars_to_prewarm:
        _create_star()


func _rebuild_spatial_grid(objects):
    if Global.main != null:
        cell_size = 128.0 * Util.get_zoom_factor()

    spatial_grid.clear()
    for object in objects:
        var cell = _get_grid_cell(object.global_position)
        if not spatial_grid.has(cell):
            spatial_grid[cell] = []
        spatial_grid[cell].append(object)


func _get_grid_cell(pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(pos.x / cell_size)), 
        int(floor(pos.y / cell_size))
    )


func get_objects_near(center: Vector2, radius: float, filter_special_types: bool = true, filter_misc_object: bool = true) -> Array:
    var results: Array = []
    var cells_to_check = int(ceil(radius / cell_size))
    var center_cell = _get_grid_cell(center)

    for x in range(center_cell.x - cells_to_check, center_cell.x + cells_to_check + 1):
        for y in range(center_cell.y - cells_to_check, center_cell.y + cells_to_check + 1):
            var cell_key = Vector2i(x, y)
            if spatial_grid.has(cell_key):
                for obj in spatial_grid[cell_key]:
                    if filter_special_types and obj.special_type != null:
                        continue

                    if filter_misc_object and obj.object_type in [Util.OBJECT_TYPES.UFO, Util.OBJECT_TYPES.COMET]:
                        continue

                    var combined_radius = radius + obj.radius
                    var combined_radius_sqrd = combined_radius * combined_radius
                    var dist_squared = obj.global_position.distance_squared_to(center)
                    if dist_squared <= combined_radius_sqrd:
                        results.append(obj)

    return results


func run_boids_batched(objects, delta):

    for object in objects:
        if object.is_misc_type:
            continue

        if accumulated_boid_forces.has(object):
            var force = accumulated_boid_forces[object]
            object.position += force * delta * boid_strength / boid_batch_size

    boid_frame_counter += 1


    if boid_frame_counter < boid_batch_size:
        return

    boid_frame_counter = 0
    accumulated_boid_forces.clear()

    var total_objects = objects.size()
    var batch_count = boid_batch_size
    var objects_per_batch = ceili(float(total_objects) / float(batch_count))

    var start_idx = boid_batch_index * objects_per_batch
    var end_idx = min(start_idx + objects_per_batch, total_objects)

    for i in range(start_idx, end_idx):
        var object: SpaceObject = objects[i]

        if object.is_misc_type:
            continue

        var cell = _get_grid_cell(object.global_position)
        var separation_force = Vector2.ZERO

        for x in range(cell.x - 1, cell.x + 2):
            for y in range(cell.y - 1, cell.y + 2):
                var c = Vector2i(x, y)
                if not spatial_grid.has(c):
                    continue

                for other in spatial_grid[c]:
                    if object == other or other.is_misc_type:
                        continue

                    var diff = object.global_position - other.global_position
                    var dist2 = diff.length_squared()
                    var desired = (object.radius + other.radius) + extra_space

                    if dist2 < desired * desired:
                        var dist = sqrt(dist2)


                        var mass_ratio = sqrt(other.health_component.max_health / max(object.health_component.max_health, 1.0))
                        separation_force += diff / dist * (desired - dist) * mass_ratio

        if separation_force.length_squared() > 0:
            accumulated_boid_forces[object] = separation_force

    boid_batch_index = (boid_batch_index + 1) % batch_count

func run_object_motion(objects, delta, gravity_radius):
    var zoom_factor = Util.get_zoom_factor()

    for object in objects:
        var pos = object.position
        var distance = pos.length()
        if distance == 0.0:
            continue

        if distance <= gravity_radius + object.width * 0.5:
            if is_main_menu == false:
                object.die()
                continue

        var direction_to_center = pos.normalized()
        var tangential_direction = Vector2( - direction_to_center.y, direction_to_center.x)
        var speed = sqrt(Global.G / distance) * (zoom_factor * zoom_factor)

        object.linear_velocity = object.linear_velocity.lerp(tangential_direction * speed, 0.3)
        object.position += object.linear_velocity * delta * object.bonus_speed
        object.rotation += object.angular_velocity * delta

        if object.collision_art:
            object.collision_art.global_position = object.global_position
        if object.collision_line:
            object.collision_line.global_position = object.global_position

        object.custom_process(delta)

func get_objects_in_laser(objects, start: Vector2, end: Vector2, width: float) -> Array:
    var hit_objects = []
    var laser_direction = (end - start).normalized()
    var perpendicular = Vector2( - laser_direction.y, laser_direction.x) * (width / 2.0)

    var corners = [
        start + perpendicular, 
        start - perpendicular, 
        end + perpendicular, 
        end - perpendicular
    ]

    for obj in objects:
        if is_point_in_rectangle(obj.global_position, start, end, width, obj.radius):
            hit_objects.append(obj)

    return hit_objects

func is_point_in_rectangle(point: Vector2, start_pos: Vector2, end_pos: Vector2, width: float, point_radius: float = 0.0) -> bool:
    var line_vec = end_pos - start_pos
    var line_length = line_vec.length()

    if line_length == 0:
        return point.distance_to(start_pos) <= (width / 2.0 + point_radius)

    var line_dir = line_vec.normalized()
    var start_to_point = point - start_pos
    var projection = start_to_point.dot(line_dir)

    if projection < - point_radius or projection > line_length + point_radius:
        return false

    var perpendicular_dist = abs(start_to_point.cross(line_dir))
    return perpendicular_dist <= (width / 2.0 + point_radius)

func get_all_active_objects(include_misc_objects = false):
    var active_objects = []
    active_objects.append_array(get_all_active_asteroids())
    active_objects.append_array(get_all_active_planets())
    active_objects.append_array(get_all_active_stars())

    if include_misc_objects:
        active_objects.append_array( %Comet.get_children())
        active_objects.append_array( %UFOs.get_children())

    return active_objects

func get_all_active_stars():
    var active_stars = []
    for star in %Stars.get_children():
        if star.is_active:
            active_stars.append(star)
    return active_stars

func get_all_active_planets():
    var active_planets = []
    for planet in %Planets.get_children():
        if planet.is_active:
            active_planets.append(planet)
    return active_planets

func get_all_active_asteroids():
    var active_asteroids = []
    for asteroid in %Asteroids.get_children():
        if asteroid.is_active:
            active_asteroids.append(asteroid)
    return active_asteroids

func _create_asteroid():
    if %Asteroids.get_child_count() < asteroids_to_prewarm:
        var asteroid: Asteroid = Refs.packed_asteroid.instantiate()
        %Asteroids.add_child(asteroid)
        asteroid.hide()
        return_space_object(asteroid)
        return asteroid

func _create_planet():
    if %Planets.get_child_count() < planets_to_prewarm:
        var planet: Planet = Refs.packed_planet.instantiate()
        %Planets.add_child(planet)
        planet.hide()
        return_space_object(planet)
        return planet

func _create_star():
    if %Stars.get_child_count() < stars_to_prewarm:
        var star: Star = Refs.packed_star.instantiate()
        %Stars.add_child(star)
        star.hide()
        return_space_object(star)
        return star

func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.START_OF_SESSION:
            set_process(true)
            comet_show_session_cooldown -= 1
        Util.GAME_STATES.PLAYING:
            set_process(true)
            for timer in %Timers.get_children():
                timer.start()
        Util.GAME_STATES.UPGRADES:
            set_process(false)
        Util.GAME_STATES.END_OF_SESSION, Util.GAME_STATES.END_OF_TEIR, Util.GAME_STATES.GAME_OVER:
            set_process(true)
            for timer in %Timers.get_children():
                timer.stop()

            for object in spawn_queue:
                return_space_object(object)

            spawn_queue = []

func _on_black_hole_grew():
    if Global.mods.get_mod(Util.MODS.ASTEROIDS_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW) > 0.0:
        var current_number_of_asteroids = get_all_active_asteroids().size()
        var target_asteroids_to_respawn = int(max_asteroids * Global.mods.get_mod(Util.MODS.ASTEROIDS_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW))
        var actual_asteroids_to_respawn = min(target_asteroids_to_respawn, max_asteroids - current_number_of_asteroids)
        var asteroids_to_respawn = get_objects_from_pool(actual_asteroids_to_respawn, Util.OBJECT_TYPES.ASTEROID)
        spawn_queue.append_array(asteroids_to_respawn)

    if Global.mods.get_mod(Util.MODS.PLANET_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW) > 0.0:
        var current_number_of_planets = get_all_active_planets().size()
        var target_planets_to_respawn = int(max_planets * Global.mods.get_mod(Util.MODS.PLANET_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW))
        var actual_planets_to_respawn = min(target_planets_to_respawn, max_planets - current_number_of_planets)
        var planets_to_respawn = get_objects_from_pool(actual_planets_to_respawn, Util.OBJECT_TYPES.PLANET)
        spawn_queue.append_array(planets_to_respawn)

    if Global.mods.get_mod(Util.MODS.STAR_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW) > 0.0:
        var current_number_of_stars = get_all_active_stars().size()
        var target_stars_to_respawn = int(max_stars * Global.mods.get_mod(Util.MODS.STAR_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW))
        var actual_stars_to_respawn = min(target_stars_to_respawn, max_stars - current_number_of_stars)
        var stars_to_respawn = get_objects_from_pool(actual_stars_to_respawn, Util.OBJECT_TYPES.STAR)
        spawn_queue.append_array(stars_to_respawn)

func _on_mod_changed(type: Util.MODS, old_value, new_value):
    update_mods()

func update_mods():
    max_stars = max(0, int(Global.mods.get_mod(Util.MODS.NUMBER_OF_PLANETS_INTO_STARS)))
    max_planets = max(0, int(Global.mods.get_mod(Util.MODS.NUMBER_OF_ASTEROIDS_INTO_PLANETS)) - max_stars)
    max_asteroids = max(0, int(Global.mods.get_mod(Util.MODS.ASTEROIDS_TO_SPAWN)) - max_planets - max_stars)

    max_stars += Global.mods.get_mod(Util.MODS.STARS_TO_SPAWN)
    max_planets += Global.mods.get_mod(Util.MODS.PLANETS_TO_SPAWN)

    max_electric_asteroids = int(max_asteroids * Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_ELECTRIC))
    max_radioactive_asteroids = int(max_asteroids * Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_RADIOACTIVE))
    max_golden_asteroids = int(max_asteroids * Global.mods.get_mod(Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_GOLDEN))

    max_moon_planets = int(max_planets * Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_SPAWN_CHANCE))
    max_frozen_planets = int(max_planets * Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_CHANCE_TO_SPAWN_FROZEN))
    max_pinata_planets = int(max_planets * Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_ASTEROID_PINATA_SPAWN_CHANCE))

    max_laser_star_count = int(max_stars * Global.mods.get_mod(Util.MODS.SPECIAL_STAR_LASER_SPAWN_CHANCE))
    max_supernova_star_count = int(max_stars * Global.mods.get_mod(Util.MODS.SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE))
    max_fireball_star_count = int(max_stars * Global.mods.get_mod(Util.MODS.SPECIAL_STAR_FIREBALL_SPAWN_CHANCE))
    max_electric_star_count = int(max_stars * Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC))

    min_special_stars = ceil(max_stars * Global.config.get_config(Util.CONFIG_TYPES.MIN_SPECIAL_STARS_PERCENT))
    max_special_stars = ceil(max_stars * Global.config.get_config(Util.CONFIG_TYPES.MAX_SPECIAL_STARS_PERCENT))

    comet_pitty_chance = Global.mods.get_mod(Util.MODS.COMET_SPAWN_CHANCE)
    comet_shower_pitty_chacne = Global.mods.get_mod(Util.MODS.COMET_CHANCE_FOR_COMET_SHOWER)

func can_spawn_electric_asteriod():
    return max_electric_asteroids > electric_asteroid_count

func can_spawn_radioactive_asteriod():
    return max_radioactive_asteroids > radioactive_asteroid_count

func can_spawn_golden_asteriod():
    return max_golden_asteroids > golden_asteroid_count

func can_spawn_moon_planet():
    return FlairManager.moon_pool.size() > 0

func can_spawn_frozen_planet():
    return max_frozen_planets > forzen_planet_count

func can_spawn_pinata_planet():
    return max_pinata_planets > pinata_planet_count

func can_spawn_laser_star():
    return max_laser_star_count > laser_star_count


func can_spawn_special_star():
    return special_star_count < max_special_stars

func need_to_spawn_special_start():
    return special_star_count < min_special_stars

func can_spawn_supernova_star():

    if max_supernova_star_count > supernova_star_count:
        return supernova_star_count < Global.config.get_config(Util.CONFIG_TYPES.MAX_SUPERNOVA)

    return false


func can_spawn_electric_star():
    return max_electric_star_count > electric_star_count


func can_spawn_fireball_star():
    return max_fireball_star_count > fireball_star_count

func create_comet():
    var new_comet: Comet = Refs.packed_comet.instantiate()
    return new_comet

func get_objects_from_pool(amount: int, type: Util.OBJECT_TYPES):
    var objs = []
    for i in range(amount):
        if pool[type].size() > 0:
            objs.append(pool[type].pop_back())
        else:
            break
    return objs

func return_space_object(space_object: SpaceObject):
    space_object.disable()

    if space_object.respawn:
        space_object.respawn = false
        spawn_queue.append(space_object)
    else:
        pool[space_object.object_type].append(space_object)

    if Global.game_state == Util.GAME_STATES.PLAYING:
        if get_all_active_objects(false).size() <= 0:
            if Global.main != null:
                Global.main.end_session.visible = true
                var send_data = false

                var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.DESTROY_ALL_OBJECTS, false)
                if need_to_update == true:
                    send_data = true

                if send_data == true:
                    SteamHandler.store_steam_data()



func reset():
    for asteroid in get_all_active_asteroids():
        return_space_object(asteroid)

    for planet in get_all_active_planets():
        return_space_object(planet)

    for star in get_all_active_stars():
        return_space_object(star)

    for comet in %Comet.get_children():
        comet.clean_up()

    for ufo in %UFOs.get_children():
        ufo.clean_up()


    for object in spawn_queue:
        return_space_object(object)

    spawn_queue = []


    electric_asteroid_count = 0
    radioactive_asteroid_count = 0
    moon_planet_count = 0
    forzen_planet_count = 0
    pinata_planet_count = 0
    golden_asteroid_count = 0

    special_star_count = 0
    supernova_star_count = 0
    laser_star_count = 0
    fireball_star_count = 0
    electric_star_count = 0

    accumulated_boid_forces.clear()

func do_new_session_spawning(duration):
    var star_list = get_objects_from_pool(max_stars, Util.OBJECT_TYPES.STAR)
    place_objects_in_donut(star_list, Global.black_hole.gravity_radius, outer_radius, false)

    var planet_list = get_objects_from_pool(max_planets, Util.OBJECT_TYPES.PLANET)
    place_objects_in_donut(planet_list, Global.black_hole.gravity_radius, outer_radius, false)

    var asteroids = get_objects_from_pool(max_asteroids, Util.OBJECT_TYPES.ASTEROID)
    place_objects_in_donut(asteroids, Global.black_hole.gravity_radius, outer_radius, false)

    var wait_time = float(float(duration) / float(max_asteroids + max_planets))

    var objects = []
    objects.append_array(star_list)
    objects.append_array(planet_list)
    objects.append_array(asteroids)

    objects.sort_custom( func(a, b): return a.global_position.length() < b.global_position.length())

    var tween = create_tween()
    for object: SpaceObject in objects:
        tween.tween_callback( func(): object.do_load())
        tween.tween_interval(wait_time)

    _on_comet_timer_timeout()

func place_objects_in_donut(objects, inner_radius: float, _outer_radius: float, do_load = false, center = Vector2.ZERO):
    var dynamic_outer_radius = outer_radius * Util.get_zoom_factor()

    for space_object: SpaceObject in objects:
        var radius_radomness = 0
        match space_object.object_type:
            Util.OBJECT_TYPES.PLANET:
                radius_radomness = Global.rng.randi_range(50, 100)
            Util.OBJECT_TYPES.STAR:
                radius_radomness = Global.rng.randi_range(100, 200)

        space_object.setup(do_load)
        var angle = Global.rng.randf() * TAU
        var radius = Global.rng.randf_range(inner_radius + space_object.width + radius_radomness, dynamic_outer_radius)
        var spawn_pos = Vector2(cos(angle), sin(angle)) * radius
        space_object.global_position = spawn_pos + center

func break_all_objects():

    for object in get_all_active_objects():
        object.special_die()

    for comet in %Comet.get_children():
        comet.clean_up()

    for ufo in %UFOs.get_children():
        ufo.clean_up()


func on_new_game():
    update_mods()

    if max_asteroids > %Asteroids.get_child_count():
        for i in range(max_asteroids - %Asteroids.get_child_count()):
            _create_asteroid()

    if max_planets > %Planets.get_child_count():
        for i in range(max_planets - %Planets.get_child_count()):
            _create_planet()

    if max_stars > %Stars.get_child_count():
        for i in range(max_stars - %Stars.get_child_count()):
            _create_star()

func create_specific_num_asteroids(amount, radius):
    for i in range(amount):
        var asteroid: Asteroid = Refs.packed_asteroid.instantiate()
        %Asteroids.add_child(asteroid)
        pool[Util.OBJECT_TYPES.ASTEROID].append(asteroid)

        var angle = Global.rng.randf() * TAU
        var rand_radius = Global.rng.randf_range(radius, outer_radius)
        var spawn_pos = Vector2(cos(angle), sin(angle)) * rand_radius
        asteroid.global_position = spawn_pos
        asteroid.setup(true, true)

func spawn_comet():
    var new_comet: Comet = create_comet()
    %Comet.add_child(new_comet)
    place_objects_in_donut([new_comet], Global.black_hole.gravity_radius * 3.0, outer_radius, false)
    new_comet.setup(Util.COMET_TYPE.CLICKER_CRIT_CHANCE_BUFF)

func _on_comet_timer_timeout() -> void :
    if comet_pitty_chance > 0.0:
        if Global.rng.randf() < comet_pitty_chance:
            var comets_to_spawn = Global.rng.randf_range(1, Global.mods.get_mod(Util.MODS.COMET_MAX_NUMBER_TO_SPAWN))

            if comet_show_session_cooldown <= 0:
                if Global.rng.randf() < comet_shower_pitty_chacne:
                    comet_shower_pitty_chacne = Global.mods.get_mod(Util.MODS.COMET_CHANCE_FOR_COMET_SHOWER)
                    comet_show_session_cooldown = comet_show_session_cooldown_amount
                    comets_to_spawn = Global.mods.get_mod(Util.MODS.COMET_SHOWER_SIZE)
                else:
                    comet_shower_pitty_chacne += Global.mods.get_mod(Util.MODS.COMET_CHANCE_FOR_COMET_SHOWER)

            var tween: Tween = create_tween()
            for i in range(comets_to_spawn):
                tween.tween_callback(spawn_comet)
                tween.tween_interval(Global.rng.randf_range(0.0, 0.075))
            return

    comet_pitty_chance += Global.mods.get_mod(Util.MODS.COMET_SPAWN_CHANCE)

func spawn_ufo():
    var new_ufo: UFO = Refs.packed_ufo.instantiate()
    %UFOs.add_child(new_ufo)
    new_ufo.setup()

func _on_ufo_timer_timeout() -> void :
    if ufo_pitty_chance > 0.0:
        if Global.rng.randf() < ufo_pitty_chance:
            var ufo_to_spawn = Global.rng.randf_range(1, Global.mods.get_mod(Util.MODS.UFO_MAX_NUMBER_TO_SPAWN))

            var tween: Tween = create_tween()
            for i in range(ufo_to_spawn):
                tween.tween_callback(spawn_ufo)
                tween.tween_interval(Global.rng.randf_range(0.0, 0.075))
            return

    ufo_pitty_chance += Global.mods.get_mod(Util.MODS.UFO_SPAWN_CHANCE)
