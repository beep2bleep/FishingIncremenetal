extends Area2D
class_name FrozenShard

var enable = false
var damage = 0
var direction = Vector2(1, 0)
var speed = 167
var rot = 0

var base_timer = 0.75

var tween

func _ready() -> void :
    set_physics_process(false)

func setup(_damage, _distance_scale, _color):
    show()
    enable = true

    %BackgroundArt.modulate = _color
    %CollisionPolygon2D.disabled = false

    damage = _damage
    rot = Global.rng.randf_range(0, 360)
    direction = Vector2.ONE.rotated(deg_to_rad(rot))
    %Pivot.rotation_degrees = rot


    tween = create_tween()
    tween.tween_property(self, "global_position", global_position + direction * speed * _distance_scale, 0.5)
    tween.tween_callback(clean_up)

func clean_up():
    if enable == true:

        if tween:
            tween.kill()

        hide()
        enable = false

        %CollisionPolygon2D.set_deferred("disabled", true)

        FlairManager.frozen_shard_pool.append(self)

func _on_area_entered(area: Area2D) -> void :
    print_debug("NEED TO FIX THIS IF WE ARE GOING TO USE IT")
