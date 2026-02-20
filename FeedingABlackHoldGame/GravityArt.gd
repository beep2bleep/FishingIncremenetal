extends Node2D
class_name GravityArt

var radius

func _draw() -> void :
    draw_circle(Vector2.ZERO, radius, Refs.pallet.black_hole_light)
