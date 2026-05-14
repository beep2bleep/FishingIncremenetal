extends CanvasLayer

var new_scene_path: String

## Path used for the *current* wipe. Do not read `new_scene_path` mid-transition for loads — it can be overwritten if another change is requested.
var _sealed_transition_path: String = ""

var from_node: Node
var to_node: Node
var to_state

const BASE_TRANSITION_ANIM_DURATION: float = 1.0
const LOAD_TIME_SMOOTHING: float = 0.35

@export var scene_change_min_duration: float = 0.55
@export var scene_change_max_duration: float = 1.6
@export var node_transition_duration: float = 0.65
@export var transition_speed_multiplier: float = 1.2

var estimated_scene_load_seconds: float = 0.22
var scene_change_started_msec: int = 0

const MAX_SCENE_SWAP_WAIT_FRAMES: int = 600

func _ready() -> void :
    set_process(false)
    _apply_transition_speed(node_transition_duration)
    $AnimationPlayer.animation_finished.connect(_on_transition_animation_finished)


    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()

func _on_pallet_updated():
    update_color()

func update_color():
    %ColorRect.color = Refs.pallet.black_hole_dark

func change_to_new_scene(path, _to_state = null, duration_override: float = -1.0):
    new_scene_path = path
    _sealed_transition_path = path
    to_state = _to_state
    if _should_profile_open_pit_upgrade_scene(path):
        Global.open_pit_upgrade_startup_started_msec = Time.get_ticks_msec()
        Global.open_pit_upgrade_scene_resource_load_msec = 0
        Global.open_pit_upgrade_scene_swap_msec = 0
        print("[OpenPitUpgradeStartup] scene_change_requested path=%s" % path)
    set_process(false)
    var estimated_total_duration: float = duration_override
    if estimated_total_duration <= 0.0:
        estimated_total_duration = clamp(
            estimated_scene_load_seconds * 1.2 + 0.12,
            scene_change_min_duration,
            scene_change_max_duration
        )
    _apply_transition_speed(estimated_total_duration)
    _set_web_transition_music_paused(true)
    $AudioStreamPlayer.play()
    $AnimationPlayer.play("Change Scene")


func do_transition(_from_node, _to_node):
    from_node = _from_node
    to_node = _to_node
    _apply_transition_speed(node_transition_duration)
    _set_web_transition_music_paused(true)
    $AudioStreamPlayer.play()
    $AnimationPlayer.play("Do Transisiton")


func handle_nodes():
    if from_node:
        if from_node is Main:
            pass
        if from_node is UpgradeScreen:
            from_node.hide()

    if to_node:
        if to_node is Main:
            to_node.reset()
        if to_node is UpgradeScreen:
            to_node.show_screen()





func finished():
    if to_node is Main:
        to_node.start_new_run()


func set_state():
    if to_state:
        print("set state")

        var current_scene = get_tree().current_scene
        if current_scene is MainMenu:
            current_scene.state = to_state

        to_state = null



func do_scene_change() -> void :
    set_state()

    var path_to_load: String = _sealed_transition_path
    if path_to_load.is_empty():
        path_to_load = new_scene_path
    if path_to_load.is_empty():
        return

    # Single synchronous load — avoids threaded + sync races that produced wrong PackedScene / wrong scene.
    var load_started_msec: int = Time.get_ticks_msec()
    var packed: PackedScene = ResourceLoader.load(path_to_load, "", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
    var load_elapsed_s: float = float(Time.get_ticks_msec() - load_started_msec) / 1000.0
    if _should_profile_open_pit_upgrade_scene(path_to_load):
        Global.open_pit_upgrade_scene_resource_load_msec = Time.get_ticks_msec() - load_started_msec
        print("[OpenPitUpgradeStartup] scene_resource_load %.3fms" % float(Global.open_pit_upgrade_scene_resource_load_msec))
    if load_elapsed_s > 0.0:
        estimated_scene_load_seconds = lerp(estimated_scene_load_seconds, load_elapsed_s, LOAD_TIME_SMOOTHING)

    if packed == null:
        push_warning("SceneChanger: failed to load scene resource: %s — trying change_scene_to_file" % path_to_load)
        scene_change_started_msec = Time.get_ticks_msec()
        var previous_scene: Node = get_tree().current_scene
        get_tree().call_deferred("change_scene_to_file", path_to_load)
        _capture_scene_load_time(previous_scene)
        return

    scene_change_started_msec = Time.get_ticks_msec()
    var previous_scene: Node = get_tree().current_scene
    get_tree().call_deferred("change_scene_to_packed", packed)
    _capture_scene_load_time(previous_scene)


func _capture_scene_load_time(previous_scene: Node) -> void :
    await get_tree().process_frame

    # Wait until SceneTree swaps current_scene; this approximates blocking load duration.
    var safety_frames: int = 0
    while get_tree().current_scene == previous_scene and safety_frames < MAX_SCENE_SWAP_WAIT_FRAMES:
        await get_tree().process_frame
        safety_frames += 1
    if safety_frames >= MAX_SCENE_SWAP_WAIT_FRAMES:
        push_warning("SceneChanger: current_scene did not change after scene swap (stuck on %s)" % previous_scene)

    if scene_change_started_msec <= 0:
        return

    var elapsed_seconds: float = float(Time.get_ticks_msec() - scene_change_started_msec) / 1000.0
    if elapsed_seconds <= 0.0:
        return

    estimated_scene_load_seconds = lerp(estimated_scene_load_seconds, elapsed_seconds, LOAD_TIME_SMOOTHING)
    if _should_profile_open_pit_upgrade_scene(_sealed_transition_path if not _sealed_transition_path.is_empty() else new_scene_path):
        Global.open_pit_upgrade_scene_swap_msec = Time.get_ticks_msec() - scene_change_started_msec
        print("[OpenPitUpgradeStartup] scene_swap %.3fms frames=%d" % [float(Global.open_pit_upgrade_scene_swap_msec), safety_frames + 1])

func _should_profile_open_pit_upgrade_scene(path: String) -> bool:
    return Util.is_open_pit_game_active() and path == Util.get_upgrade_scene_path()

func _apply_transition_speed(duration_seconds: float) -> void :
    var speed: float = BASE_TRANSITION_ANIM_DURATION / max(duration_seconds, 0.01)
    speed *= max(0.1, transition_speed_multiplier)

    # Keep transitions snappy in-editor while preserving runtime tuning in builds.
    if OS.has_feature("editor"):
        speed *= 8.0

    $AnimationPlayer.speed_scale = speed

func _on_transition_animation_finished(animation_name: StringName) -> void:
    if animation_name == &"Change Scene":
        _sealed_transition_path = ""
    if animation_name == &"Change Scene" or animation_name == &"Do Transisiton":
        _set_web_transition_music_paused(false)

func _set_web_transition_music_paused(should_pause: bool) -> void:
    pass
