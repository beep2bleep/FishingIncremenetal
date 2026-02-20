extends ColorRect

var is_shown = false

func _ready():


    visible = false

    %"Setting Pannel".hide()

    hide()

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_shown == true:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %Resume.grab_focus()


func _input(event: InputEvent) -> void :
    if event.is_action_pressed("escape") or (is_shown and event.is_action_pressed("back")):
        if is_showing_settings == true:
            _on_hide_settings_button_up()
        else:
            toggle_screen()


func toggle_screen():
    %PanelContainer.reset_size()

    if is_shown == false:
        show_screen()
    else:
        hide_screen()

func show_screen():

    if Global.current_game_mode_data.end_run_disabled == true:
        %"Go To Upgrades HBox".hide()
    else:
        %"Go To Upgrades HBox".visible = (Global.game_state == Util.GAME_STATES.PLAYING or Global.game_state == Util.GAME_STATES.START_OF_SESSION)

    is_shown = true
    show()
    get_tree().paused = true

    Global.update_mouse()

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        %Resume.grab_focus()

func hide_screen():
    is_shown = false
    hide()
    get_tree().paused = false
    Global.update_mouse()

func _on_wishlist_pressed() -> void :
    OS.shell_open("https://store.steampowered.com/app/3694480/A_Game_About_A_Black_Hole/")


func _on_resume_pressed() -> void :
    hide_screen()

func _on_music_h_slider_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    1, 
    linear_to_db(value * 3.0)
    )

func _on_sound_effects_h_slider_2_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    0, 
    linear_to_db(value * 3.0)
    )


func _on_quit_pressed() -> void :
    get_tree().quit()


func _on_go_to_upgrades_pressed() -> void :
    toggle_screen()
    Global.main.session_timer = 0


func _on_main_menu_pressed() -> void :
    Global.game_state = Util.GAME_STATES.MAIN_MENU
    SaveHandler.save_player_last_run()
    get_tree().paused = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN_MENU)


var is_showing_settings = false
func _on_hide_settings_button_up() -> void :
    is_showing_settings = false
    %"Setting Pannel".hide()
    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        %Settings.grab_focus()
    %"Main Pause Stuff".show()



func _on_settings_pressed() -> void :
    is_showing_settings = true
    %"Settings Vbox".show_screen()
    %"Setting Pannel".show()
    %"Main Pause Stuff".hide()
