extends ColorRect
class_name GameOverScreen

var is_shown = false


func _ready():
    ControllerIcons.input_type_changed.connect(_on_input_type_changed)


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_shown == true:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %"Main Menu".grab_focus()


func show_screen():
    is_shown = true

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        %"Main Menu".grab_focus()

func setup():

    var total_earned = 0
    total_earned += Global.session_stats.asteroid_money
    total_earned += Global.session_stats.planet_money
    total_earned += Global.session_stats.star_money

    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, total_earned)




    %"Start Epilogue HBox".hide()

    %"New Modes HBox".show()
    %"One More Time Hbox".show()
    %"Main Menu Hbox".show()

    if ProjectSettings.get_setting("global/Demo") == true:
        %"Game Over Demo Text".show()
        %"Start Epilogue".visible = false
        %"Buy the Game".show()

    elif Global.current_game_mode_data.game_mode == Util.GAME_MODES.MAIN:
        if Global.main.epilogue == true:
            pass
        else:
            %"Start Epilogue HBox".show()
    else:
        pass



    if Global.current_game_mode_data.on_more_time_disabled == true:
        %"One More Time Hbox".hide()


func _on_main_menu_pressed() -> void :
    is_shown = false

    %VBoxContainer.hide()
    Global.game_state = Util.GAME_STATES.MAIN_MENU
    SaveHandler.save_player_last_run()
    get_tree().paused = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN_MENU)

func _on_start_epilogue_pressed() -> void :
    is_shown = false

    Global.main.epilogue = true
    %VBoxContainer.hide()
    SignalBus.epilogue_started.emit()
    Global.black_hole.level_manager.on_epilogue_started()

    SaveHandler.save_player_last_run()

    Global.game_state = Util.GAME_STATES.UPGRADES
    SceneChanger.do_transition(null, Global.main.upgrade_screen)



func _on_buy_the_game_pressed() -> void :
    OS.shell_open("https://store.steampowered.com/app/3694480/A_Game_About_Feeding_A_Black_Hole/")


func _on_play_new_modes_pressed() -> void :
    SceneChanger.change_to_new_scene(Util.PATH_MAIN_MENU, MainMenu.STATES.GAME_MODE)
