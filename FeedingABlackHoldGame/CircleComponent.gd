extends Node2D
class_name CircleComponent

var radius = 0
var color = Color.WHITE

func _draw() -> void :
    draw_circle(Vector2.ZERO, radius, color)

func setup(_radius, _color = Color.WHITE):
    radius = _radius
    color = _color
