extends MarginContainer
class_name Controls


func _ready() -> void :
    set_process_input(false)


func show_controls():
    $AnimationPlayer.play("Fade IN")


func _input(event: InputEvent) -> void :

    if event.is_action_pressed("Grab"):
        $AnimationPlayer.play("Fade Out")
        set_process_input(false)
