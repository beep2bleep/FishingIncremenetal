extends "res://Main Menu.gd"

func _ready() -> void:
    Util.set_active_game_id(Util.ACTIVE_GAME_VANGUARD)
    super._ready()

func get_main_title_translation_key() -> String:
    return "VANGUARD: IDLE AUTO-BATTLER"

func _activate_vanguard() -> void:
    Util.set_active_game_id(Util.ACTIVE_GAME_VANGUARD)

func _start_upgrade_flow(load_saved_run: bool) -> void:
    _activate_vanguard()
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = load_saved_run
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)

func _on_contiunue_old_game_pressed() -> void:
    _start_upgrade_flow(true)

func _on_play_pressed() -> void:
    _start_upgrade_flow(false)

func _on_game_mode_screen_play_new_game_mode(game_mode_data: GameModeData) -> void:
    _activate_vanguard()
    Global.current_game_mode_data = game_mode_data
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)

func _on_game_mode_screen_continue_game_mode(game_mode_data: GameModeData) -> void:
    _activate_vanguard()
    Global.current_game_mode_data = game_mode_data
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)
