extends Node2D

func _ready():
    %Asteroid.setup()
    pass

func _on_rigid_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void :
    print("_on_rigid_body_2d_input_event")


func _on_rigid_body_2d_mouse_entered() -> void :
    print("_on_rigid_body_2d_mouse_entered")


func _on_rigid_body_2d_mouse_exited() -> void :
    print("_on_rigid_body_2d_mouse_exited")
