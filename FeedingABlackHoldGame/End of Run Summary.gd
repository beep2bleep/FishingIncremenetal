extends ColorRect
class_name EndOfRunSummary

var fast_screen = false
var is_shown = false


func show_screen():
    set_process_input(true)

    is_shown = true

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        %Upgrades.grab_focus()


func _ready():
    set_process_input(false)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_shown == true:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %Upgrades.grab_focus()


func do_end_of_run():

    %Size.text = "{CURRENT}/{MAX}".format({
        "CURRENT": Global.black_hole.level_manager.level, 
        "MAX": Global.black_hole.level_manager.current_black_hole_tier_data.number_of_levels
    })

    fast_screen = false

    var total_earned = 0

    %"Moeny UI".modulate.a = 0.0

    var matter_gained = Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MATTER)
    %Asteroid.setup(Util.RESOURCE_TYPES.MATTER, matter_gained, Global.session_stats.asteroid_money)
    total_earned += Global.session_stats.asteroid_money

    var planet_gained = Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.PLANET)
    %Planet.setup(Util.RESOURCE_TYPES.PLANET, planet_gained, Global.session_stats.planet_money)
    total_earned += Global.session_stats.planet_money

    var star_gained = Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.STAR)
    %Star.setup(Util.RESOURCE_TYPES.STAR, star_gained, Global.session_stats.star_money)
    total_earned += Global.session_stats.star_money

    %Total.setup(Util.RESOURCE_TYPES.STAR, 0, total_earned)


    %"Black Hole Size".text = Global.black_hole.get_size_name(Global.black_hole.level_manager.level)
    %BlackHoleMassUI.max_value = Global.black_hole.level_manager.get_xp_for_next_level()
    %BlackHoleMassUI.value = 0




    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, total_earned)


    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MATTER)
    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.PLANET)

    update_stats()

    if total_earned == 0:
        fast_screen = true

    SaveHandler.save_player_last_run()







func update_stats():
    %"Time Added Hbox".setup(snappedf(Global.session_stats.time_added_during_session, 0.1), Refs.mod_textures[Util.MODS.RUN_TIMER_BASE], "TIME_ADDED_THIS_SESSION", false)
    %"Asteroids Destroyed Hbox".setup(int(Global.session_stats.asteroids_destroyed_during_session), Refs.mod_textures[Util.MODS.ASTEROID_DENSITY], "ASTEROIDS_DESTROYED_THIS_SESSION")
    %"Planets Destroyed Hbox2".setup(int(Global.session_stats.planets_destroyed_during_session), Refs.mod_textures[Util.MODS.PLANET_DENSITY], "PLANETS_DESTROYED_THIS_SESSION")
    %"Stars Destroyed Hbox3".setup(int(Global.session_stats.stars_destroyed_during_session), Refs.mod_textures[Util.MODS.STAR_DENSITY], "STARS_DESTROYED_THIS_SESSION")

    %"Moons Collected".setup(int(Global.session_stats.moons_collected), Refs.mod_textures[Util.MODS.SPECIAL_PLANET_MOON_SPAWN_CHANCE], "MOONS_COLLECTED_THIS_SESSION")
    %"Comets Collected".setup(int(Global.session_stats.comets_collected), Refs.mod_textures[Util.MODS.COMET_SPAWN_CHANCE], "COMETS_COLLECTED_THIS_SESSION")

    %"Breaker Damage Hbox".setup(int(Global.session_stats.breaker_damage), Refs.mod_textures[Util.MODS.BASE_DAMAGE_PER_CLICK], "BREAKER_DAMAGE_THIS_SESSION")
    %"Breaker Crit Damage".setup(int(Global.session_stats.breaker_crit_damage), Refs.mod_textures[Util.MODS.CLICKER_CRIT_BONUS], "BREAKER_CRIT_DAMAGE_THIS_SESSION")
    %"Electric Damage Hbox".setup(int(Global.session_stats.electric_damage), Refs.mod_textures[Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_ELECTRIC], "ELECTRIC_DAMAGE_THIS_SESSION")
    %"Money From Glolden Asteroids".setup(int(Global.session_stats.money_from_golden_asteroids), Refs.mod_textures[Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_GOLDEN], "MONEY_FROM_GOLDEN_ASTEROID_THIS_SESSION", true, true)


    %"Star Supernova Damage".setup(int(Global.session_stats.star_electric_damage), Refs.mod_textures[Util.MODS.SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC], "STAR_ELECTRIC_DAMAGE_THIS_SESSION")
    %"Star Laser Damage".setup(int(Global.session_stats.laser_damage), Refs.mod_textures[Util.MODS.SPECIAL_STAR_LASER_SPAWN_CHANCE], "LASER_DAMAGE_THIS_SESSION")
    %"Star Electric Damage".setup(int(Global.session_stats.super_nova_damage), Refs.mod_textures[Util.MODS.SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE], "SUPERNOVA_DAMAGE_THIS_SESSION")


    %"Breaker Clicks".setup(int(Global.session_stats.clicker_clicks), Refs.mod_textures[Util.MODS.CLICK_RATE], "BREAKER_CLICKS_THIS_SESSION")
    %"Manual Clicks".setup(int(Global.session_stats.manual_clicks), load("res://Art/left.png"), "MANUAL_CLICKS_THIS_SESSION", true, false, true)

















func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.END_OF_SESSION:
        if event.is_action_pressed("upgrades"):
            _on_upgrades_pressed()

        elif event.is_action_pressed("go again"):
            _on_go_again_pressed()




var anim_tween: Tween
var audio_tween: Tween
func do_animations():
    kill_tweens()


    var duration = 0.0 if fast_screen else 1.0

    %Asteroid.do_animation(duration)
    %Planet.do_animation(duration)
    %Star.do_animation(duration)
    %Total.do_animation(duration)

    audio_tween = create_tween()
    audio_tween.tween_property( %AudioStreamPlayer, "pitch_scale", 1.2, duration).from(0.8)

    anim_tween = create_tween()

    %Size.text = "{CURRENT}/{MAX}".format({
        "CURRENT": 1, 
        "MAX": int(Global.mods.get_mod(Util.MODS.BLACK_HOLE_MAX_SIZE)) + 1
    })


    var progress_bar_duration = duration / (Global.black_hole.level_manager.level + 1.0 - Global.black_hole.level_manager.current_black_hole_tier_data.starting_level)
    for i in range(Global.black_hole.level_manager.current_black_hole_tier_data.starting_level, Global.black_hole.level_manager.level + 1):
        anim_tween.tween_callback( func():
            %"Black Hole Size".text = Global.black_hole.get_size_name(i)

            %Size.text = "{CURRENT}/{MAX}".format({
                "CURRENT": i, 
                "MAX": Global.black_hole.level_manager.current_black_hole_tier_data.max_level + 1
            })
        )

        if i == Global.black_hole.level_manager.level:
            anim_tween.tween_property( %BlackHoleMassUI, "value", Global.black_hole.level_manager.current_xp, progress_bar_duration).from(0.0).set_ease(Tween.EASE_IN)
        else:
            anim_tween.tween_property( %BlackHoleMassUI, "value", %BlackHoleMassUI.max_value, progress_bar_duration).from(0.0).set_ease(Tween.EASE_IN)

    anim_tween.tween_callback( func():
        %"Moeny UI".modulate.a = 1.0
        %"Moeny UI".animate()
        %"TaDa Audio".play()
    )


func kill_tweens():
    if anim_tween != null and anim_tween.is_running():
        anim_tween.kill()

    if audio_tween != null and audio_tween.is_running():
        audio_tween.kill()



func _on_go_again_pressed() -> void :
    set_process_input(false)
    is_shown = false

    SceneChanger.do_transition(null, Global.main)

func _on_upgrades_pressed() -> void :
    set_process_input(false)

    is_shown = false
    kill_tweens()

    %AudioStreamPlayer.stop()

    %"Black Hole Size".text = Global.black_hole.get_size_name(Global.black_hole.level_manager.level)


    %Size.text = "{CURRENT}/{MAX}".format({
        "CURRENT": Global.black_hole.level_manager.level, 
        "MAX": Global.black_hole.level_manager.current_black_hole_tier_data.max_level + 1
    })


    %BlackHoleMassUI.value = Global.black_hole.level_manager.current_xp


    Global.game_state = Util.GAME_STATES.UPGRADES
    SceneChanger.do_transition(null, Global.main.upgrade_screen)
