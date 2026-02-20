extends Node2D
class_name Clicker


var base_radius: float = 17.0
var radius: float = 0

var base_cross_hair_scale = 0.0
var base_background_scale = 0.0

var follow_mouse = true
var speed = 750
var velocity: Vector2 = Vector2.ZERO

var loaded = false

@export var electric_charges: int = 0:
    set(new_value):
        electric_charges = max(0, new_value)
        %Tendril.visible = electric_charges > 0

        %Tendril.width = min(30 * Util.get_zoom_factor(), 100)



var controller_pos = Vector2(0, -200)

func _process(delta: float) -> void :
    if follow_mouse:
        global_position = get_global_mouse_position()

    else:
        var controller_input = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
        controller_pos += controller_input * delta * speed * Util.get_zoom_factor() * SaveHandler.controller_sensitivity


        var camera = Global.main.camera_2d
        var camera_center = camera.get_screen_center_position()
        var viewport_size = get_viewport_rect().size
        var zoom = camera.zoom
        var half_size = viewport_size / (zoom * 2.0)

        controller_pos.x = clamp(controller_pos.x, camera_center.x - half_size.x + radius, camera_center.x + half_size.x - radius)
        controller_pos.y = clamp(controller_pos.y, camera_center.y - half_size.y + radius, camera_center.y + half_size.y - radius)

        global_position = controller_pos

    %Pivot.global_position = Util.get_node2d_viewport_position(self, Global.main.camera_2d)
    %Moons.global_position = %Pivot.global_position

func _ready() -> void :
    ControllerIcons.input_type_changed.connect(_on_input_type_changed)

    base_cross_hair_scale = %Crosshair120.scale.x
    base_background_scale = %ClickSprite.scale.x

    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.game_state_changed.connect(_on_game_state_changed)


    update_input_stuff(ControllerIcons.get_last_input_type())

    SignalBus.pallet_updated.connect(_pallet_updated)
    update_color()

    setup()







func _input(event: InputEvent) -> void :
    if event.is_action_pressed("Grab"):
        if Global.game_state == Util.GAME_STATES.PLAYING:
            Global.session_stats.manual_clicks += 1


func _pallet_updated():
    update_color()


func update_color():
    %Smoke10.self_modulate = Refs.pallet.clicker_smoke
    %ClickSprite.self_modulate = Refs.pallet.clicker_shadow


    %Crosshair120.material.set_shader_parameter("color", Refs.pallet.clicked_base)

    %Smoke10.modulate.a = 0.0
    %ClickSprite.modulate.a = 0.0


func update_input_stuff(input_type: ControllerIcons.InputType):
    match input_type:
        ControllerIcons.InputType.KEYBOARD_MOUSE:
            follow_mouse = true
        ControllerIcons.InputType.CONTROLLER:
            follow_mouse = false




func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input_stuff(input_type)

func _on_timer_timeout() -> void :

    var is_cirt = damage_stuff()

    Global.session_stats.clicker_clicks += 1

    do_click_tween(is_cirt)

    if Global.game_state != Util.GAME_STATES.PLAYING:
        %Timer.stop()


func _on_mod_changed(type: Util.MODS, old_value, new_value):
    setup()


func add_object(obj):
    Util.orphan(obj)
    %Moons.add_child(obj)

    obj.show()

    obj.scale = Vector2.ONE * Util.get_zoom()
    set_object_positions()


func set_object_positions():
    var target_radius = (radius + 16) * Global.main.get_traget_camera_zoom().x if Global.main else 1.0
    var positions = Util.get_evenly_spaced_points_on_a_circle( %Moons.get_child_count(), target_radius)
    for i in range( %Moons.get_child_count()):
        %Moons.get_child(i).position = positions[i]





func reset():
    electric_charges = Global.mods.get_mod(Util.MODS.CLICKER_ELECTRIC_CLICKS_TO_START_WITH)

    Global.mods.set_mod(Util.MODS.CLICKER_CRIT_CHANCE_BUFF, 0.0)
    Global.mods.set_mod(Util.MODS.CLICKER_CRIT_BONUS_BUFF, 0.0)
    Global.mods.set_mod(Util.MODS.CLICK_RATE_BUFF, 0.0)
    Global.mods.set_mod(Util.MODS.CLICK_AOE_BUFF, 0.0)


func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.START_OF_SESSION:
            controller_pos = Vector2(0, -200 - Global.black_hole.gravity_radius if Global.black_hole else 0)

            reset()

            %Timer.stop()

            %CanvasLayer.show()
            show()
        Util.GAME_STATES.PLAYING:
            setup()
            %Timer.start( %Timer.wait_time)

            %CanvasLayer.show()
            show()
        Util.GAME_STATES.END_OF_TEIR:
            electric_charges = 0

            for moon in %Moons.get_children():
                moon.clean_up()

            if %Timer.time_left / %Timer.wait_time > 0.25:
                %Timer.stop()

            %CanvasLayer.hide()
            hide()
        Util.GAME_STATES.END_OF_SESSION:
            electric_charges = 0

            for moon in %Moons.get_children():
                moon.clean_up()

            if %Timer.time_left / %Timer.wait_time > 0.25:
                %Timer.stop()

            hide()
            %CanvasLayer.hide()
        Util.GAME_STATES.UPGRADES:
            electric_charges = 0
            %Timer.stop()

            hide()
            %CanvasLayer.hide()
        Util.GAME_STATES.GAME_OVER:
            electric_charges = 0
            %Timer.stop()

            hide()
            %CanvasLayer.hide()

func setup():
    if loaded == false:
        return

    var rate_mods = Global.mods.get_mod(Util.MODS.CLICK_RATE) + min(Global.mods.get_mod(Util.MODS.CLICK_RATE_BUFF), 5.0)
    %Timer.wait_time = max(0.15, 1.0 / rate_mods * 0.75)

    var aoe_scale = Global.mods.get_mod(Util.MODS.CLICK_AOE) + min(Global.mods.get_mod(Util.MODS.CLICK_AOE_BUFF), 10.0)
    radius = base_radius * aoe_scale


    var camera_zoom = Global.main.get_traget_camera_zoom().x if Global.main else 1.0
    %"Art Pivot".scale = Vector2.ONE * aoe_scale * camera_zoom






    base_damage_per_click = Global.mods.get_mod(Util.MODS.BASE_DAMAGE_PER_CLICK)
    clicker_crit_chance = Global.mods.get_mod(Util.MODS.CLICKER_CRIT_CHANCE) + Global.mods.get_mod(Util.MODS.CLICKER_CRIT_CHANCE_BUFF)
    clicker_crit_bonus = Global.mods.get_mod(Util.MODS.CLICKER_CRIT_BONUS) + Global.mods.get_mod(Util.MODS.CLICKER_CRIT_BONUS_BUFF)

    clicker_bonus_damage_to_planets = Global.mods.get_mod(Util.MODS.CLICKER_BONUS_DAMAGE_TO_PLANETS)
    clicker_bonus_damage_to_stars = Global.mods.get_mod(Util.MODS.CLICKER_BONUS_DAMAGE_TO_STAR)

    %Tendril.clear_points()
    %Tendril.points = Util.get_evenly_spaced_points_on_a_circle(32, radius * 0.9)

    global_position = get_global_mouse_position()

    set_object_positions()

func get_aoe_value(aoe_percent):
    var max_linear_aoe = 5.0
    var aoe_scale = 0.0

    if aoe_percent <= max_linear_aoe:
        aoe_scale = aoe_percent
    else:
        var overflow = aoe_percent - max_linear_aoe
        aoe_scale = max_linear_aoe + sqrt((100.0 + overflow * 100.0) / 100.0) - 1.0

    return aoe_scale


func get_click_rate(rate_percent):
    var max_linear_rate = 2.5
    var rate_scale = 0.0

    if rate_percent <= max_linear_rate:
        rate_scale = rate_percent
    else:
        var overflow = rate_percent - max_linear_rate
        rate_scale = max_linear_rate + pow(overflow, 0.5)

    return rate_scale


var base_damage_per_click = 1
var clicker_crit_chance = 0.0:
    set(new_value):
        clicker_crit_chance = new_value
        %"Auto Crit Effcet".visible = clicker_crit_chance >= 1.0

var clicker_crit_bonus = 0.0
var clicker_bonus_damage_to_planets = 0.0
var clicker_bonus_damage_to_stars = 0.0






var cached_objects_in_range: Array = []
var cache_frame: int = -1
var cache_position: Vector2 = Vector2.ZERO

func get_objects_in_clicker_range() -> Array:
    var current_frame = Engine.get_process_frames()




    if cache_frame == current_frame and global_position.is_equal_approx(cache_position):
        return cached_objects_in_range


    cached_objects_in_range = Global.main.object_manager.get_objects_near(global_position, radius, false, false)
    cache_frame = current_frame
    cache_position = global_position

    return cached_objects_in_range

func damage_stuff():
    var damage = base_damage_per_click


    var is_crit = Global.rng.randf() <= clicker_crit_chance




    var hit_data = {
        "asteroids_died": 0, 
        "planets_died": 0, 
        "stars_died": 0, 
        "golden_asteroid_died": false, 
        "pinata_died": false, 
        "golden_asteroid_crit": false, 
        "elctric_asteroid_died": false, 
        "elctric_asteroid_crit": false, 
        "elctric_star_died": false, 
        "elctric_star_crit": false, 
        "asteroid_hit": false, 
        "planet_hit": false, 
        "object_hit": false, 
        "comet_hit": false, 
        "star_hit": false, 

    }


    var objects_in_range = get_objects_in_clicker_range()


    for object: SpaceObject in objects_in_range:

        if object.is_dying == true or object.can_be_damaged == false:
            continue


        if object is Comet or object is UFO:
            hit_data.object_hit = true
            hit_data.comet_hit = true
            object.die()
            continue


        if object is SpaceObject:
            hit_data.object_hit = true


            var per_object_damage = damage


            if object is Star:
                hit_data.star_hit = true
                per_object_damage += clicker_bonus_damage_to_stars
            elif object is Planet:
                hit_data.planet_hit = true
                per_object_damage += clicker_bonus_damage_to_planets
            elif object is Asteroid:
                hit_data.asteroid_hit = true


            if is_crit:
                per_object_damage *= clicker_crit_bonus


            var damage_event_data: DamageEventData = object.take_damage(per_object_damage, global_position, is_crit)
            Global.session_stats.breaker_damage += damage_event_data.damage

            if is_crit == true:
                Global.session_stats.breaker_crit_damage += damage_event_data.damage


            if damage_event_data.died:
                match damage_event_data.object_type:
                    Util.OBJECT_TYPES.STAR:
                        hit_data.stars_died += 1

                        if damage_event_data.special_effect_type == Util.SPECIAL_TYPES.ELECTRIC:
                            hit_data.elctric_star_died = true
                            if damage_event_data.special_effect_crit:
                                hit_data.elctric_star_crit = true

                    Util.OBJECT_TYPES.PLANET:
                        hit_data.planets_died += 1

                        if damage_event_data.special_effect_type == Util.SPECIAL_TYPES.PINATA:
                            hit_data.pinata_died = true

                    Util.OBJECT_TYPES.ASTEROID:
                        hit_data.asteroids_died += 1

                        if damage_event_data.special_effect_type == Util.SPECIAL_TYPES.GOLDEN:
                            hit_data.golden_asteroid_died = true
                            if damage_event_data.special_effect_crit:
                                hit_data.golden_asteroid_crit = true

                        if damage_event_data.special_effect_type == Util.SPECIAL_TYPES.ELECTRIC:
                            hit_data.elctric_asteroid_died = true
                            if damage_event_data.special_effect_crit:
                                hit_data.elctric_asteroid_crit = true



    if hit_data.stars_died > 0:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.STAR_DESTROYED)
    elif hit_data.planets_died > 0:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_BREAK)
    elif hit_data.asteroids_died > 0:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_ASTEROID_DESTORY)

    if hit_data.golden_asteroid_died:
        if hit_data.golden_asteroid_crit:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_GOLDEN_BREAK_CRIT)
        else:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_GOLDEN_BREAK)

    if hit_data.elctric_asteroid_died:
        if hit_data.elctric_asteroid_crit:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC_CRIT)
        else:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC)

    if hit_data.elctric_star_died:
        if hit_data.elctric_star_crit:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC_STAR_CRIT)
        else:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC_STAR)

    if hit_data.pinata_died:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PINATA_BREAK)

    if is_crit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_CLICKER_CRIT)

    if hit_data.star_hit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.STAR_HIT)
    elif hit_data.planet_hit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_HIT)
    elif hit_data.asteroid_hit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_ASTEROID_CLICKED)
    else:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.CLICK_HIT_NOTHING)


    if hit_data.comet_hit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.COMET)


    if hit_data.object_hit and electric_charges > 0:
        FlairManager.create_electric(global_position, 1.0, Util.OBJECT_TYPES.ASTEROID, false, Color.WHITE)
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC)
        electric_charges -= 1

    check_achivements(hit_data)

    return is_crit


func check_achivements(hit_data):
    var send_data = false

    if Global.current_game_mode_data.game_mode != Util.GAME_MODES.MAIN:
        return


    if hit_data.asteroids_died >= 2:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.DESTROY_2_ASTEROIDS_AT_ONCE, false)
        if need_to_update == true:
            send_data = true

    if hit_data.planets_died > 0:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.DESTROY_A_PLANET, false)
        if need_to_update == true:
            send_data = true

    if hit_data.stars_died > 0:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.DESTROY_A_STAR, false)
        if need_to_update == true:
            send_data = true

    if send_data == true:
        SteamHandler.store_steam_data()


var click_tween: Tween
var color_tween: Tween
func do_click_tween(is_crit = false):
    if click_tween:
        click_tween.kill()

    if color_tween:
        color_tween.kill()

    %ClickSprite.modulate.a = 1.0
    %Pivot.scale = Vector2(1.4, 1.4) if is_crit else Vector2(1.25, 1.25)

    %Crosshair120.material.set_shader_parameter("color", Refs.pallet.damage_crit_color if is_crit else Refs.pallet.clicked_base)
    %Smoke10.scale = Vector2.ZERO
    %Smoke10.modulate.a = 1.0

    click_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

    click_tween.tween_property( %ClickSprite, "modulate:a", 0.0, 0.33)

    click_tween.parallel().tween_property( %Smoke10, "scale", Vector2(0.15, 0.15), 0.33)
    click_tween.parallel().tween_property( %Smoke10, "modulate:a", 0.0, 0.33)
    click_tween.parallel().tween_property( %Pivot, "scale", Vector2.ONE, 0.33)

    color_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    color_tween.tween_interval(0.1)
    color_tween.tween_callback( func(): %Crosshair120.material.set_shader_parameter("color", Refs.pallet.clicked_base))
