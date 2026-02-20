extends Area2D
class_name Explosion

var damage = 0
var radius = 32

func setup(_radius, _damage):
    radius = _radius
    damage = _damage


    %CollisionShape2D.shape.radius = radius
    %Circle32.scale = Vector2.ONE * radius / 200.0


func damage_stuff():
    for object in get_overlapping_bodies():
        if object is Asteroid:
            object.take_damage(damage)
