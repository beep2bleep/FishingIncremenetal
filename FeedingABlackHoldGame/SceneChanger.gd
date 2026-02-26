extends CanvasLayer

var new_scene_path: String

var from_node: Node
var to_node: Node
var to_state

func _ready() -> void :
    $AnimationPlayer.speed_scale = 8.0 if OS.has_feature("editor") else 1.33


    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()

func _on_pallet_updated():
    update_color()

func update_color():
    %ColorRect.color = Refs.pallet.black_hole_dark

func change_to_new_scene(path, _to_state = null):
    new_scene_path = path
    to_state = _to_state
    $AudioStreamPlayer.play()
    $AnimationPlayer.play("Change Scene")


func do_transition(_from_node, _to_node):
    from_node = _from_node
    to_node = _to_node
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
    get_tree().call_deferred("change_scene_to_file", new_scene_path)
