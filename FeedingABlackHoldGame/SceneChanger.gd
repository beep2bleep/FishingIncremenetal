extends CanvasLayer

var new_scene_path: String

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

var _hold_wipe_until_load: bool = false

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
    to_state = _to_state
    _hold_wipe_until_load = false
    set_process(false)
    var req_err: Error = ResourceLoader.load_threaded_request(path, "", true)
    if req_err == ERR_INVALID_PARAMETER:
        push_warning("SceneChanger: invalid scene path for threaded load: %s" % path)
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



func _process(_delta: float) -> void :
    if not _hold_wipe_until_load or new_scene_path.is_empty():
        set_process(false)
        return

    var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(new_scene_path)
    if status == ResourceLoader.THREAD_LOAD_LOADED:
        _hold_wipe_until_load = false
        set_process(false)
        _apply_packed_scene_change(true)
    elif status == ResourceLoader.THREAD_LOAD_FAILED:
        _hold_wipe_until_load = false
        set_process(false)
        _apply_fallback_scene_change()
        _resume_transition_after_deferred_change()


func do_scene_change() -> void :
    set_state()

    if new_scene_path.is_empty():
        return

    var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(new_scene_path)
    if status == ResourceLoader.THREAD_LOAD_LOADED:
        _apply_packed_scene_change(false)
        return
    if status == ResourceLoader.THREAD_LOAD_FAILED:
        _apply_fallback_scene_change()
        return

    $AnimationPlayer.pause()
    _hold_wipe_until_load = true
    set_process(true)


func _apply_packed_scene_change(was_waiting: bool) -> void :
    var packed: PackedScene = ResourceLoader.load_threaded_get(new_scene_path) as PackedScene
    if packed == null:
        _apply_fallback_scene_change()
        if was_waiting:
            _resume_transition_after_deferred_change()
        return

    scene_change_started_msec = Time.get_ticks_msec()
    var previous_scene: Node = get_tree().current_scene
    get_tree().call_deferred("change_scene_to_packed", packed)
    _capture_scene_load_time(previous_scene)

    if was_waiting:
        _resume_transition_after_deferred_change()


func _apply_fallback_scene_change() -> void :
    scene_change_started_msec = Time.get_ticks_msec()
    var previous_scene: Node = get_tree().current_scene
    get_tree().call_deferred("change_scene_to_file", new_scene_path)
    _capture_scene_load_time(previous_scene)


func _resume_transition_after_deferred_change() -> void :
    await get_tree().process_frame
    $AnimationPlayer.play()

func _capture_scene_load_time(previous_scene: Node) -> void :
    await get_tree().process_frame

    # Wait until SceneTree swaps current_scene; this approximates blocking load duration.
    while get_tree().current_scene == previous_scene:
        await get_tree().process_frame

    if scene_change_started_msec <= 0:
        return

    var elapsed_seconds: float = float(Time.get_ticks_msec() - scene_change_started_msec) / 1000.0
    if elapsed_seconds <= 0.0:
        return

    estimated_scene_load_seconds = lerp(estimated_scene_load_seconds, elapsed_seconds, LOAD_TIME_SMOOTHING)

func _apply_transition_speed(duration_seconds: float) -> void :
    var speed: float = BASE_TRANSITION_ANIM_DURATION / max(duration_seconds, 0.01)
    speed *= max(0.1, transition_speed_multiplier)

    # Keep transitions snappy in-editor while preserving runtime tuning in builds.
    if OS.has_feature("editor"):
        speed *= 8.0

    $AnimationPlayer.speed_scale = speed

func _on_transition_animation_finished(animation_name: StringName) -> void:
    if animation_name == &"Change Scene" or animation_name == &"Do Transisiton":
        _set_web_transition_music_paused(false)

func _set_web_transition_music_paused(should_pause: bool) -> void:
    if not OS.has_feature("web"):
        return
    var music_player: AudioStreamPlayer = get_node_or_null("/root/MusicPlayer") as AudioStreamPlayer
    if music_player == null:
        return
    music_player.stream_paused = should_pause
