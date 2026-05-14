extends Control

const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitEmpire/OpenPitEmpirePlanetData.gd")
const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const STARFIELD_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireStarfield.gd")

@onready var status_label: Label = get_node("Center/Panel/Margin/VBox/StatusLabel")
@onready var progress_bar: ProgressBar = get_node("Center/Panel/Margin/VBox/ProgressBar")
@onready var detail_label: Label = get_node("Center/Panel/Margin/VBox/DetailLabel")

var _transition_started: bool = false

func _ready() -> void:
    _build_visual_theme()
    progress_bar.value = 0.0
    detail_label.text = "0%"
    call_deferred("_begin_generation")

func _begin_generation() -> void:
    var progress_data: Dictionary = PROGRESS.load_data()
    var depth_level: int = clampi(int(progress_data.get("selected_depth_level", BALANCE.MIN_START_DEPTH_LEVEL)), BALANCE.MIN_START_DEPTH_LEVEL, BALANCE.MAX_DEPTH_LEVEL)
    if PROGRESS.load_runtime_planet_data(depth_level) != null:
        _go_to_battle()
        return
    var saved_planet_state: Dictionary = PROGRESS.load_planet_state(depth_level)
    if not saved_planet_state.is_empty():
        status_label.text = tr("OPEN_PIT_LOADING_SAVED_FIREWALL")
        var saved_planet = PLANET_DATA_SCRIPT.new()
        await saved_planet.load_save_data_async(get_tree(), saved_planet_state, Callable(self, "_on_generation_progress"))
        PROGRESS.save_runtime_planet_data(depth_level, saved_planet)
        _go_to_battle()
        return
    status_label.text = tr("OPEN_PIT_GENERATING_FIREWALL")
    var persistent_destroyed := {}
    for saved_variant in progress_data.get("destroyed_cells", []):
        if saved_variant is String:
            var parts: PackedStringArray = str(saved_variant).split(",")
            if parts.size() == 2:
                persistent_destroyed[Vector2i(int(parts[0]), int(parts[1]))] = true
        elif saved_variant is Vector2i:
            persistent_destroyed[saved_variant] = true
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    var planet_data = PLANET_DATA_SCRIPT.new()
    await planet_data.generate_async(get_tree(), depth_level, persistent_destroyed, BALANCE, rng, Callable(self, "_on_generation_progress"))
    PROGRESS.save_runtime_planet_data(depth_level, planet_data)
    _go_to_battle()

func _on_generation_progress(progress: float) -> void:
    var percent: int = int(round(progress * 100.0))
    progress_bar.value = progress * 100.0
    detail_label.text = "%d%%" % percent

func _go_to_battle() -> void:
    if _transition_started:
        return
    _transition_started = true
    SceneChanger.change_to_new_scene(Util.PATH_OPEN_PIT_MAIN)

func _build_visual_theme() -> void:
    var background := get_node_or_null("Background") as ColorRect
    if background != null:
        background.color = Color(0.02, 0.03, 0.055, 1.0)
    var starfield := STARFIELD_SCRIPT.new()
    starfield.name = "OrbitStarfield"
    add_child(starfield)
    move_child(starfield, 1)
    var panel := get_node_or_null("Center/Panel") as PanelContainer
    if panel != null:
        var panel_style := StyleBoxFlat.new()
        panel_style.bg_color = Color(0.03, 0.05, 0.085, 0.9)
        panel_style.border_color = Color(0.42, 0.74, 1.0, 0.6)
        panel_style.set_border_width_all(2)
        panel_style.set_corner_radius_all(12)
        panel.add_theme_stylebox_override("panel", panel_style)
    status_label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
    detail_label.add_theme_color_override("font_color", Color(0.76, 0.88, 1.0, 1.0))
    progress_bar.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
    progress_bar.add_theme_color_override("font_color_disabled", Color(0.9, 0.96, 1.0, 0.6))
    var fill_style := StyleBoxFlat.new()
    fill_style.bg_color = Color(0.42, 0.78, 1.0, 0.92)
    fill_style.set_corner_radius_all(8)
    var bg_style := StyleBoxFlat.new()
    bg_style.bg_color = Color(0.02, 0.03, 0.05, 0.92)
    bg_style.border_color = Color(0.25, 0.45, 0.74, 0.45)
    bg_style.set_border_width_all(2)
    bg_style.set_corner_radius_all(8)
    progress_bar.add_theme_stylebox_override("fill", fill_style)
    progress_bar.add_theme_stylebox_override("background", bg_style)
