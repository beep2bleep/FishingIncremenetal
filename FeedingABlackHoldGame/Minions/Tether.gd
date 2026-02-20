extends Line2D
class_name Tether

var tether_length: float = 300.0
var direction: Vector2
var target_position
var base_width

var from_node: Node
var to_node: Node

func _ready() -> void :
    base_width = width
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    update_colors()

func _on_pallet_updated():
    update_colors()

func update_colors():
    default_color = Refs.pallet.player_tether

func _process(delta: float) -> void :
    clear_points()
    if from_node:
        add_point(Vector2.ZERO)
    if to_node:
        add_point(to_local(to_node.global_position))


func setup(_from_node: Node, _direction: Vector2):
    from_node = _from_node
    direction = _direction.normalized()
    target_position = direction * tether_length
    shoot_tether()

    return to_node


func shoot_tether():
    %RayCast2D.target_position = target_position

    clear_points()
    add_point(Vector2.ZERO)
    add_point(target_position)

    %RayCast2D.force_raycast_update()
    if %RayCast2D.is_colliding():
        var collideing_object = %RayCast2D.get_collider()
        if collideing_object is Asteroid:
            var successful = collideing_object.attach_tether(self)
            if successful:
                to_node = collideing_object
                return

    clean_up()


func clean_up():
    if to_node and is_instance_valid(to_node):
        to_node.tether = null
        to_node = null

    queue_free()


func is_tether_stretched() -> bool:
    return to_node and from_node and from_node.global_position.distance_to(to_node.global_position) >= tether_length
