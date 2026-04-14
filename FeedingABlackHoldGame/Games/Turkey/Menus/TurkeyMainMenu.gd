extends "res://Main Menu.gd"

const SAVE_PATH := "user://turkey_mode_save_v1.json"

func get_main_title_translation_key() -> String:
	return "TURKEY: THREE-FRAME BOWLING"

func _start_turkey_flow(load_saved_run: bool) -> void:
	Global.ensure_default_game_mode_data()
	Global.new_game()
	Global.start_in_upgrade_scene = true
	Global.load_saved_run = load_saved_run
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_contiunue_old_game_pressed() -> void:
	_start_turkey_flow(true)

func _on_play_pressed() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	_start_turkey_flow(false)

func _on_game_mode_screen_play_new_game_mode(game_mode_data: GameModeData) -> void:
	Global.current_game_mode_data = game_mode_data
	Global.new_game()
	Global.start_in_upgrade_scene = true
	Global.load_saved_run = false
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_game_mode_screen_continue_game_mode(game_mode_data: GameModeData) -> void:
	Global.current_game_mode_data = game_mode_data
	Global.new_game()
	Global.start_in_upgrade_scene = true
	Global.load_saved_run = true
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)
