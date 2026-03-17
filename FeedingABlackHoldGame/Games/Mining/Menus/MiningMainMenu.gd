extends "res://Main Menu.gd"

const SAVE_PATH := "user://mining_mode_save_v1.json"

func _ready() -> void:
    super._ready()
    if has_node("%MainTitle"):
        %MainTitle.text = "MINING MODE"

func _start_mining_flow(load_saved_run: bool) -> void:
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = load_saved_run
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)

func _on_contiunue_old_game_pressed() -> void:
    _start_mining_flow(true)

func _on_play_pressed() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    _start_mining_flow(false)

func _on_game_mode_screen_play_new_game_mode(game_mode_data: GameModeData) -> void:
    Global.current_game_mode_data = game_mode_data
    Global.new_game()
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = false
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)

func _on_game_mode_screen_continue_game_mode(game_mode_data: GameModeData) -> void:
    Global.current_game_mode_data = game_mode_data
    Global.new_game()
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)
