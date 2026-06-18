extends Node

func _ready() -> void:
    call_deferred("_open_configured_start_scene")

func _open_configured_start_scene() -> void:
    if not Util.is_all_high_level_mode_active():
        Util.set_active_game_id(Util.get_high_level_mode_id())
    SaveHandler.load_fishing_progress()
    Global.current_game_mode_data = null
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = Util.should_start_in_upgrade_scene_from_configuration()
    Global.load_saved_run = false
    get_tree().change_scene_to_file(Util.get_configured_start_scene_path())
