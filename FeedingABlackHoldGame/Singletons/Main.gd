extends Node2D
class_name Main

@onready var asteroid_resource_pool: ResourcePool = %"Asteroid Resource Pool"
@onready var planet_resource_pool: ResourcePool = %"Planet Resource Pool"
@onready var star_resource_pool: ResourcePool = %"Star Resource Pool"

@onready var end_session: MarginContainer = %"End Session"

@onready var object_manager: ObjectManager = %ObjectManager

@onready var clicker: Clicker = %Clicker

@onready var ui: CanvasLayer = %UI
@onready var camera_2d: Camera2D = %Camera2D
@onready var upgrade_screen: UpgradeScreen = %UpgradeScreen

var epilogue = false

@export var is_dev_mod = false
@export var is_demo = false

var session_timer = 6.0:
    set(new_value):

        if Global.current_game_mode_data.disable_session_timer == true:
            return

        var old_value = session_timer

        session_timer = max(0.0, new_value)
        %"Session Timer".text = str(snappedf(session_timer, 0.1))

        if session_timer <= 0 and Global.game_state == Util.GAME_STATES.PLAYING:
            Global.game_state = Util.GAME_STATES.END_OF_SESSION
            do_end_of_run()

        %"Session Timer".add_theme_color_override("font_color", Refs.pallet.text_base_color if session_timer > 5.0 else Refs.pallet.text_red)
        %"Hour Glass Icon".modulate = Refs.pallet.text_base_color if session_timer > 5.0 else Refs.pallet.text_red

        %"Timer MarginContainer3".pivot_offset = %"Timer MarginContainer3".size / 2.0

        if new_value < 5.0 and old_value >= 5.0:
            %CustomTweenComponent.do_tween(1.0)
        elif new_value < 4.0 and old_value >= 4.0:
            %CustomTweenComponent.do_tween(1.0)
        elif new_value < 3.0 and old_value >= 3.0:
            %CustomTweenComponent.do_tween(1.0)
        elif new_value < 2.0 and old_value >= 2.0:
            %CustomTweenComponent.do_tween(1.0)
        elif new_value < 1.0 and old_value >= 1.0:
            %CustomTweenComponent.do_tween(1.0)

var time_gain_cooldown = 0.0
var gain_decay_factor = 1.0

func add_time_from_asteroid_destroyed(amount):
    var gain = amount * gain_decay_factor
    if gain <= 0.001:
        return

    session_timer += gain
    time_gain_cooldown += min(0.1, gain * 10.0)
    gain_decay_factor *= 0.9

    Global.session_stats.time_added_during_session += gain


func hide_sceen():
    pass

func show_screen():
    pass


func _process(delta: float) -> void :
    if Global.game_state == Util.GAME_STATES.PLAYING:
        session_timer -= delta

        time_gain_cooldown = max(0, time_gain_cooldown - delta)
        if time_gain_cooldown <= 0:
            gain_decay_factor = lerp(gain_decay_factor, 1.0, delta * 2)




func _ready():
    Global.main = self

    %"Game Over Screen".hide()

    AudioManager.on_new_game()

    if Global.load_saved_run == true:
        SaveHandler.load_player_last_run()
        AudioManager.on_load_game()

        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, SaveHandler.money)
        Global.game_mode_data_manager.unlocked_upgrades = SaveHandler.upgrades_unlocked_upgrades
        epilogue = SaveHandler.epilogue
        if epilogue == true:
            SignalBus.epilogue_started.emit()

        Global.tier_stats.total_damage_this_tier = SaveHandler.tier_stats["total_damage_this_tier"]
        Global.tier_stats.total_objects_destoryed_this_tier = SaveHandler.tier_stats["total_objects_destoryed_this_tier"]
        Global.tier_stats.total_objects_destoryed_this_tier = SaveHandler.tier_stats["total_objects_destoryed_this_tier"]
        Global.tier_stats.session_this_tier = SaveHandler.tier_stats["session_this_tier"]
        Global.run_stats.run_time = SaveHandler.run_time


    Global.game_state = Util.GAME_STATES.START_OF_SESSION

    var black_hole: BlackHole = load("res://BlackHole.tscn").instantiate()
    add_child(black_hole)

    if Global.load_saved_run == true:
        Global.black_hole.level_manager.current_tier_index = SaveHandler.current_tier

    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.black_hole_grew.connect(_on_black_hole_grew)
    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.game_state_changed.connect(_on_game_state_changed)
    SignalBus.settings_updated.connect(_on_settings_updated)

    update_colors()

    _on_settings_updated()






    %MoneyPerSecond.setup()

    if Global.start_in_upgrade_scene:
        FishingUpgradeTreeAdapter.apply_simulation_upgrades()
        var current_money: float = Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY)
        if current_money != 0.0:
            Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, -current_money)
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, SaveHandler.fishing_currency)

    %UpgradeScreen.setup()
    object_manager.on_new_game()

    reset()

    %Clicker.loaded = true
    %Clicker.setup()

    if Global.start_in_upgrade_scene:
        Global.start_in_upgrade_scene = false
        Global.game_state = Util.GAME_STATES.UPGRADES
        %UpgradeScreen.show_screen()
    else:
        start_new_run()


func _on_black_hole_grew():
    var send_data = false

    var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.GROW_BLACK_HOLE, false)
    if need_to_update == true:
        send_data = true






    if send_data == true:
        SteamHandler.store_steam_data()






func on_game_over(tier_index = 0):

    if epilogue == false:
        SaveHandler.register_player_win(Global.current_game_mode_data.game_mode, Global.run_stats.run_time)

    Global.game_state = Util.GAME_STATES.GAME_OVER

    %"Game Over Screen".modulate.a = 0.0
    %"Game Over Gong".play()
    %"Game Over Screen".setup()
    object_manager.break_all_objects()

    var game_over_tween = create_tween()
    game_over_tween.tween_interval(2.0)

    var base_radius = Global.black_hole.gravity_radius
    var scale_increment = 0.5
    var pulese_end_scale = base_radius * (2.5 + scale_increment * tier_index)
    var shrink_radius = 100


    for i in range(tier_index + 1):
        var duration = max(0.15, 0.5 - float(i) * 0.1)
        var pulse_scale = lerp(base_radius, pulese_end_scale, float(i + 1) / float(tier_index + 1))
        game_over_tween.tween_callback(
            func():
                Global.black_hole.black_hole_art.animate_grow(pulse_scale, duration, false, false)
                AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BLACK_HOLE_GROW_MILESTONE)
        )

        if i != tier_index + 1:
            game_over_tween.tween_interval(duration)














    game_over_tween.tween_callback( func():
        MusicPlayer.play_game_over_song()
        %"Game Over Audio".play()
        Global.black_hole.black_hole_art.animate_grow(shrink_radius, 0.5, false, false, Tween.EASE_IN, Tween.TRANS_CUBIC)
    )


    game_over_tween.tween_interval(1.0)


    game_over_tween.tween_callback( func():
        var radius = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * Util.get_zoom_factor() * 2.0
        Global.black_hole.black_hole_art.animate_grow(radius, 2.0, false, false, Tween.EASE_OUT, Tween.TRANS_CUBIC)
    )


    game_over_tween.tween_interval(1.0)


    game_over_tween.tween_callback(
        func():
            %"Game Over Screen".show_screen()
    )

    game_over_tween.tween_callback(

        func():
            check_game_over_achivements()

    )


    game_over_tween.tween_property( %"Game Over Screen", "visible", true, 0.0)
    game_over_tween.tween_property( %"Game Over Screen", "modulate:a", 1.0, 1.0).from(0.0)


func on_tier_finished(tier_index = 0):

    Global.game_state = Util.GAME_STATES.END_OF_TEIR
    %"Game Over Gong".play()



    Global.black_hole.on_tier_end()


    var tier_finished_tween = create_tween()

    object_manager.break_all_objects()

    update_steam_stats()

    Global.tier_stats.tally_session_stats()

    if Global.current_game_mode_data.game_mode == Util.GAME_MODES.MAIN:
        match tier_index:
            0:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_1, false)
            1:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_2, false)
            2:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_3, false)
            3:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_4, false)
            4:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_5, false)
            5:
                SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.COMPLETE_A_MILESTONE_6, false)

    check_session_end_achivements(false)

    SteamHandler.store_steam_data()

    %"Tier Summary".setup()

    var base_radius = Global.black_hole.gravity_radius
    var scale_increment = 0.15
    var pulese_end_scale = base_radius * (2.0 + scale_increment * tier_index)
    var final_radius_scale = 1.5


    tier_finished_tween.tween_interval(1.5)


    for i in range(tier_index + 1):
        var duration = max(0.15, 0.5 - float(i) * 0.1)
        var pulse_scale = lerp(base_radius, pulese_end_scale, float(i + 1) / float(tier_index + 1))
        tier_finished_tween.tween_callback(
            func():
                Global.black_hole.black_hole_art.animate_grow(pulse_scale, duration, false, false)
                AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BLACK_HOLE_GROW_MILESTONE)
        )

        if i != tier_index + 1:
            tier_finished_tween.tween_interval(duration)




    var shake_duration = 1.1
    var shake_intensity = 8.0
    tier_finished_tween.tween_callback( func():
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BLACK_HOLE_COLLAPSE)

        Global.black_hole.black_hole_art.start_shake(shake_intensity, 0.02, shake_duration, shake_duration * 0.67, shake_intensity * 0.25)
    )

    tier_finished_tween.tween_interval(shake_duration * 1.1)





    tier_finished_tween.tween_callback( func():
        Global.black_hole.black_hole_art.animate_grow(base_radius * final_radius_scale, 0.4, false, false)
    )


    tier_finished_tween.tween_callback( func():

        Global.black_hole.black_hole_art.lock_in_effect(tier_index)
    )
    tier_finished_tween.tween_interval(1.33)




    tier_finished_tween.tween_property( %"Tier Summary", "visible", true, 0.0)
    tier_finished_tween.tween_property( %"Tier Summary", "modulate:a", 1.0, 0.3).from(0.0)
    tier_finished_tween.tween_callback(
        func():
            %"Tier Summary".show_screen()
            %"Tier Summary".do_animations()
    )


func _on_game_state_changed():

    if Global.current_game_mode_data.disable_session_timer == false:
        %"Timer MarginContainer3".show()
    match Global.game_state:
        Util.GAME_STATES.START_OF_SESSION:
            set_process(false)
            for child in %"Resource Pools".get_children():
                if child is ResourcePool:
                    child.reset()
            %"End Session".hide()
        Util.GAME_STATES.PLAYING:
            set_process(true)
            %"End Session".hide()
        Util.GAME_STATES.END_OF_SESSION:
            set_process(false)
            %"End Session".hide()
        Util.GAME_STATES.UPGRADES:
            set_process(false)
            %"End Session".hide()
        Util.GAME_STATES.END_OF_TEIR:

            %"Timer MarginContainer3".hide()
            set_process(false)
            %"End Session".hide()
        Util.GAME_STATES.GAME_OVER:

            set_process(false)
            %"Timer MarginContainer3".hide()
            %"End Session".hide()

func _input(event: InputEvent) -> void :
    if end_session.visible == true and event.is_action_pressed("upgrades"):
        _on_end_session_button_pressed()




func reset():



    Global.session_stats.reset()

    %"End of Run Summary".hide()
    %"Tier Summary".hide()
    %"Game Over Screen".hide()

    Global.black_hole.reset()
    if Global.current_game_mode_data.disable_session_timer == true:
        session_timer = 10.0
        %"Timer MarginContainer3".hide()
    else:
        session_timer = Global.mods.get_mod(Util.MODS.RUN_TIMER_BASE)
        %"Timer MarginContainer3".show()

    object_manager.reset()

    time_gain_cooldown = 0.0
    gain_decay_factor = 1.0

    camera_2d.zoom = get_run_start_camera_zoom()








func get_traget_camera_zoom():





    return Global.black_hole.level_manager.current_black_hole_tier_data.zoom * Vector2.ONE if Global.black_hole else Vector2.ONE



func get_run_start_camera_zoom():
    return Vector2(2.0, 2.0) * Util.get_zoom()

func start_new_run():
    var duration = 2.0

    Global.game_state = Util.GAME_STATES.START_OF_SESSION

    var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


    tween.tween_property( %Camera2D, "zoom", get_traget_camera_zoom(), duration * 0.8).from(get_run_start_camera_zoom())

    object_manager.do_new_session_spawning(duration)
    do_start_of_run(duration / 2.0)

    tween.tween_callback(
        func(): check_session_start_achivements()
    )

func do_start_of_run(duration):
    %"Start Run".modulate.a = 0

    var tween = create_tween()
    tween.tween_interval(duration * 0.5)
    tween.tween_property( %"Start Run", "visible", true, 0.0)
    tween.tween_property( %"Start Run", "modulate:a", 1.0, duration * 0.5).from(0.0)
    tween.tween_interval(duration * 0.67)
    tween.tween_property( %"Start Run", "modulate:a", 0.0, duration * 0.25).from(1.0)
    tween.tween_property( %"Start Run", "visible", false, 0.0)

    tween.tween_callback( func(): Global.game_state = Util.GAME_STATES.PLAYING)


func do_end_of_run():
    %"Out of Time".modulate.a = 0
    %"End of Run Summary".modulate.a = 0
    %"Game Over Screen".modulate.a = 0
    %"Tier Summary".modulate.a = 0

    Global.tier_stats.tally_session_stats()



    SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.FINISH_A_SESSION, false)

    SteamHandler.store_steam_data()


    %"End of Run Summary".do_end_of_run()

    var tween = create_tween()
    tween.tween_property( %"Out of Time", "visible", true, 0.0)
    tween.tween_property( %"Out of Time", "modulate:a", 1.0, 0.3).from(0.0)
    tween.tween_interval(1.0)
    tween.tween_property( %"Out of Time", "modulate:a", 0.0, 0.2).from(1.0)
    tween.tween_property( %"Out of Time", "visible", false, 0.0)

    tween.tween_property( %"End of Run Summary", "visible", true, 0.0)
    tween.tween_property( %"End of Run Summary", "modulate:a", 1.0, 0.3).from(0.0)
    tween.tween_callback(
        func():
            check_session_end_achivements()

            %"End of Run Summary".show_screen()
            %"End of Run Summary".do_animations()
    )


func update_steam_stats():
    pass





func _on_mod_changed(type: Util.MODS, old_value, new_value):
    pass


func _on_pallet_updated():
    update_colors()

func update_colors():
    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark

    %"Background Color Rect".color = Refs.pallet.background

    %"Session Timer".add_theme_color_override("font_color", Refs.pallet.text_base_color)
    %"Hour Glass Icon".modulate = Refs.pallet.text_base_color

    %"Run Timer".add_theme_color_override("font_color", Refs.pallet.text_base_color)







func _on_wishlist_pressed() -> void :
    OS.shell_open("https://store.steampowered.com/app/3694480/A_Game_About_A_Black_Hole/")


func _on_menu_pressed() -> void :
    %"Pause Screen".toggle_screen()


func _on_restart_pressed() -> void :
    get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void :
    Global.game_state = Util.GAME_STATES.MAIN_MENU
    SaveHandler.save_player_last_run()
    get_tree().paused = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN_MENU)

func check_session_end_achivements(allow_send_data = true):
    var send_data = false

    if Global.session_stats.manual_clicks >= 100:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.TOO_MANY_CLICKS, false)
        if need_to_update == true:
            send_data = true


    var total_earned = 0
    total_earned += Global.session_stats.asteroid_money
    total_earned += Global.session_stats.planet_money
    total_earned += Global.session_stats.star_money

    if total_earned >= 10:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_0, false)
        if need_to_update == true:
            send_data = true
    if total_earned >= 100:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_1, false)
        if need_to_update == true:
            send_data = true
    if total_earned >= 1000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_2, false)
        if need_to_update == true:
            send_data = true
    if total_earned >= 10000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_3, false)
        if need_to_update == true:
            send_data = true
    if total_earned >= 100000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_4, false)
        if need_to_update == true:
            send_data = true
    if total_earned >= 1000000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_5, false)
        if need_to_update == true:
            send_data = true

    if total_earned >= 1000000000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_6, false)
        if need_to_update == true:
            send_data = true

    if total_earned >= 1000000000000:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.MONEY_BAGS_7, false)
        if need_to_update == true:
            send_data = true


    if send_data == true and allow_send_data == true:
        SteamHandler.store_steam_data()


func check_game_over_achivements():
        if Global.current_game_mode_data.game_mode != Util.GAME_MODES.MAIN:
            SteamHandler.set_achievement(Util.GAME_MODES.find_key(Global.current_game_mode_data.game_mode))
            return

        var send_data = false

        if epilogue == true:
            var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.BEAT_THE_EPILOGUE, false)
            if need_to_update == true:
                send_data = true
        else:
            var need_to_update = SteamHandler.set_achievement(Util.GAME_MODES.find_key(Global.current_game_mode_data.game_mode), false)
            if need_to_update == true:
                send_data = true













        if send_data == true:
            SteamHandler.store_steam_data()

func _on_settings_updated():
    %"Run Timer Cont".visible = SaveHandler.run_timer


func check_session_start_achivements(allow_send_data = true):
    var send_data = false

    if Global.mods.get_mod(Util.MODS.ASTEROIDS_TO_SPAWN) >= 50:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.START_RUN_WITH_50_ASTEROIDS, false)
        if need_to_update == true:
            send_data = true

    if send_data == true and allow_send_data == true:
        SteamHandler.store_steam_data()


func _on_end_session_button_pressed() -> void :
    Global.main.session_timer = 0
