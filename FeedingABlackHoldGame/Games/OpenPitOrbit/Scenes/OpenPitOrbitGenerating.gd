extends Control

const PROGRESS := preload("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitOrbit/OpenPitOrbitPlanetData.gd")
const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")

@onready var status_label: Label = %StatusLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var detail_label: Label = %DetailLabel

var _transition_started: bool = false

func _ready() -> void:
    progress_bar.value = 0.0
    detail_label.text = "0%"
    call_deferred("_begin_generation")

func _begin_generation() -> void:
    var progress_data: Dictionary = PROGRESS.load_data()
    var depth_level: int = clampi(int(progress_data.get("selected_depth_level", BALANCE.MIN_START_DEPTH_LEVEL)), BALANCE.MIN_START_DEPTH_LEVEL, BALANCE.MAX_DEPTH_LEVEL)
    if PROGRESS.load_runtime_planet_data(depth_level) != null:
        _go_to_battle()
        return
    status_label.text = "Generating Blocks"
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
    SceneChanger.change_to_new_scene(Util.PATH_OPEN_PIT_ORBIT_MAIN)
