extends Node

func _ready() -> void:
    call_deferred("_open_configured_start_scene")

func _open_configured_start_scene() -> void:
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = Util.get_start_screen_id() == Util.START_SCREEN_UPGRADES
    Global.load_saved_run = false
    get_tree().change_scene_to_file(Util.get_configured_start_scene_path())
