extends CanvasLayer

var new_scene_path: String

var from_node: Node
var to_node: Node
var to_state

const BASE_TRANSITION_ANIM_DURATION: float = 1.0
const LOAD_TIME_SMOOTHING: float = 0.35

@export var scene_change_min_duration: float = 1.1
@export var scene_change_max_duration: float = 3.5
@export var node_transition_duration: float = 0.9

var estimated_scene_load_seconds: float = 0.35
var scene_change_started_msec: int = 0

func _ready() -> void :
    _apply_transition_speed(node_transition_duration)


    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()

func _on_pallet_updated():
    update_color()

func update_color():
    %ColorRect.color = Refs.pallet.black_hole_dark

func change_to_new_scene(path, _to_state = null):
    new_scene_path = path
    to_state = _to_state
    var estimated_total_duration: float = clamp(estimated_scene_load_seconds * 2.0, scene_change_min_duration, scene_change_max_duration)
    _apply_transition_speed(estimated_total_duration)
    $AudioStreamPlayer.play()
    $AnimationPlayer.play("Change Scene")


func do_transition(_from_node, _to_node):
    from_node = _from_node
    to_node = _to_node
    _apply_transition_speed(node_transition_duration)
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



func do_scene_change():
    scene_change_started_msec = Time.get_ticks_msec()
    var previous_scene: Node = get_tree().current_scene
    get_tree().call_deferred("change_scene_to_file", new_scene_path)
    _capture_scene_load_time(previous_scene)

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

    # Keep transitions snappy in-editor while preserving runtime tuning in builds.
    if OS.has_feature("editor"):
        speed *= 8.0

    $AnimationPlayer.speed_scale = speed
