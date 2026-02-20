extends Node2D
class_name MainMenu


enum STATES{MENU, SETTINGS, GAME_MODE}

var state: STATES = STATES.MENU:
    set(new_value):
        var old_value = state
        state = new_value

        %"Main Menu Stuff".hide()
        %"Setting Pannel".hide()
        %"Game Mode Screen".hide()

        match state:
            STATES.MENU:

                %"Main Menu Stuff".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Main Menu Stuff".modulate.a = 0.0

                do_tween_state_change(Vector2.ZERO, Vector2.ONE, %"Main Menu Stuff", true)

                update_input(ControllerIcons.get_last_input_type())

            STATES.SETTINGS:
                var zoom = 2.0
                %Logo.modulate.a = 0
                %"Setting Pannel".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Setting Pannel".modulate.a = 0.0
                do_tween_state_change(Vector2( - get_viewport_rect().size.x / (2 * zoom), 0), Vector2(zoom, zoom), %"Setting Pannel")
                %"Settings Comp".show_screen()

            STATES.GAME_MODE:
                var zoom = 1.5
                %Logo.modulate.a = 0
                %"Game Mode Screen".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Game Mode Screen".modulate.a = 0.0


                do_tween_state_change(Vector2(0, - get_viewport_rect().size.y / (2.0 * zoom)), Vector2(zoom, zoom), %"Game Mode Screen")


var tween_state_change: Tween
func do_tween_state_change(pivot_pos, zoom, to_stuff, show_logo = false):

    var duration = 1.0

    if tween_state_change:
        tween_state_change.kill()



    tween_state_change = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
    tween_state_change.tween_callback( func():
        if to_stuff.has_method("show_screen"):
            to_stuff.show_screen()
    )
    tween_state_change.tween_property( %Pivot, "global_position", pivot_pos, duration)

    tween_state_change.parallel().tween_property( %Camera2D, "zoom", zoom, duration)
    tween_state_change.parallel().tween_property(to_stuff, "modulate:a", 1.0, duration)
    if show_logo:
        tween_state_change.parallel().tween_property( %Logo, "modulate:a", 1.0, duration)



func _input(event: InputEvent) -> void :
    if event.is_action_pressed("back"):
        state = STATES.MENU

func _ready():


    ControllerIcons.input_type_changed.connect(_on_input_type_changed)

    state = STATES.MENU

    SaveHandler.update_first_time_load(true)



    Global.game_state = Util.GAME_STATES.MAIN_MENU




    %"Setting Pannel".hide()


    %"Black Hole Art".maw_texture.width = 512
    %"Black Hole Art".bh_texture.width = 512
    %"Black Hole Art".maw_texture.height = 512
    %"Black Hole Art".bh_texture.height = 512








    SaveHandler.update_has_shown_pick_locale_first_time(true)

    %ObjectManager.outer_radius = get_viewport_rect().size.y / 2.0
    %ObjectManager.create_specific_num_asteroids(64, 256)

    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input(input_type)

func update_input(input_type):
    if state == STATES.MENU:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %Play.grab_focus()
        else:
            pass


func _on_pallet_updated():
    update_color()

func update_color():
    %ColorRect.color = Refs.pallet.background

    %Logo.modulate = Refs.pallet.text_base_color
    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark










func _on_start_new_game_pressed() -> void :
    %"Main Menu Stuff".hide()
    %"Game Modes Pannel".show()


func _on_contiunue_old_game_pressed() -> void :
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)


func _on_quit_pressed() -> void :
    get_tree().quit()


func _on_wishlist_pressed() -> void :
    OS.shell_open("https://store.steampowered.com/app/3694480/A_Game_About_A_Black_Hole/")


func _on_discord_pressed() -> void :
    OS.shell_open("https://discord.gg/qSs4QAsmf9")


func _on_press_kit_pressed() -> void :
    OS.shell_open("https://drive.google.com/drive/folders/1onWePx7nawiXxfadZjMezKlE13q4gbkE?usp=sharing")


func _on_settings_pressed() -> void :
    state = STATES.SETTINGS


func _on_hide_settings_pressed() -> void :
    state = STATES.MENU










func _on_hide_game_modes_pressed() -> void :
    %"Main Menu Stuff".show()
    %"Game Modes Pannel".hide()















func _on_play_pressed() -> void :

    state = STATES.GAME_MODE


func _on_game_mode_screen_back() -> void :
    state = STATES.MENU


func _on_game_mode_screen_play_new_game_mode(game_mode_data: GameModeData) -> void :

    Global.current_game_mode_data = game_mode_data
    Global.new_game()

    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)


func _on_game_mode_screen_continue_game_mode(game_mode_data: GameModeData) -> void :
    Global.current_game_mode_data = game_mode_data
    Global.new_game()

    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)
