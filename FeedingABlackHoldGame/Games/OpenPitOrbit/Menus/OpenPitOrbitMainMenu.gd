extends "res://Main Menu.gd"

const SAVE_PATH := "user://open_pit_orbit_save_v1.json"
const STARFIELD_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitStarfield.gd")

func _ready() -> void:
	super._ready()
	_install_open_pit_orbit_backdrop()

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

func _install_open_pit_orbit_backdrop() -> void:
	var background_layer := get_node_or_null("CanvasLayer2")
	if background_layer == null:
		return
	var color_rect := background_layer.get_node_or_null("ColorRect") as ColorRect
	if color_rect != null:
		color_rect.color = Color(0.02, 0.03, 0.055, 1.0)
	var starfield := STARFIELD_SCRIPT.new()
	starfield.name = "OpenPitOrbitStarfield"
	background_layer.add_child(starfield)
	background_layer.move_child(starfield, background_layer.get_child_count() - 1)
	var title := get_node_or_null("%MainTitle") as Label
	if title != null:
		title.add_theme_color_override("font_color", Color(0.86, 0.93, 1.0, 1.0))
