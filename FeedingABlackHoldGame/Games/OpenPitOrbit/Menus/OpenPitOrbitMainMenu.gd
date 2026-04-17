extends "res://Main Menu.gd"

const SAVE_PATH := "user://open_pit_orbit_save_v1.json"

func get_main_title_translation_key() -> String:
    return "OPEN PIT ORBIT"

func _start_open_pit_flow(load_saved_run: bool) -> void:
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = load_saved_run
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_contiunue_old_game_pressed() -> void:
    _start_open_pit_flow(true)

func _on_play_pressed() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    _start_open_pit_flow(false)
