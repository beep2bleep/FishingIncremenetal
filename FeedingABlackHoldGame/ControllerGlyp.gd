extends TextureRect
class_name ControllerGlyph


@export var always_show = false:
    set(new_value):
        always_show = new_value
        update()


@export var enabled = true:
    set(new_value):
        enabled = new_value
        update()



func _ready():
    ControllerIcons.input_type_changed.connect(_on_input_type_changed)
    update()

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update()


func update():
    if always_show == true:
        show()
        return

    if enabled == false:
        hide()
        return

    match ControllerIcons.get_last_input_type():
        ControllerIcons.InputType.KEYBOARD_MOUSE:
            hide()
        ControllerIcons.InputType.CONTROLLER:
            show()
