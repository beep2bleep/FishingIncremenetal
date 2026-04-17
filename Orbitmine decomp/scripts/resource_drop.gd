extends Node2D







var raw_resource: float = 0.0
var drop_color: Color = Color(1.0, 0.8, 0.3)
var is_gold: bool = false
var is_core: bool = false


var timer: float = 0.0
var bob_phase: float = 0.0
var is_collected: bool = false
var collect_target: Node2D = null
var collect_speed: float = 0.0
var base_pos: Vector2 = Vector2.ZERO
var glow_size: float = 3.0


const LIFETIME: float = 10.0
const BLINK_START: float = 7.0
const BOB_SPEED: float = 3.0
const BOB_AMOUNT: float = 3.0
const COLLECT_ACCEL: float = 1200.0
const INITIAL_COLLECT_SPEED: float = 150.0


func setup(world_pos: Vector2, amount: float, color: Color = Color(1.0, 0.8, 0.3), gold: bool = false, core: bool = false):
    global_position = world_pos
    base_pos = world_pos
    raw_resource = amount
    drop_color = color
    is_gold = gold
    is_core = core
    bob_phase = randf() * TAU

    glow_size = clamp(2.0 + log(max(1.0, amount)) * 0.3, 2.0, 5.0)
    z_index = 50
    add_to_group("resource_drops")

func _process(delta: float):

    if is_collected:
        if collect_target and is_instance_valid(collect_target):
            collect_speed += COLLECT_ACCEL * delta
            var dir = (collect_target.global_position - global_position).normalized()
            global_position += dir * collect_speed * delta

            if global_position.distance_to(collect_target.global_position) < 15.0:
                queue_free()
        else:
            queue_free()
        queue_redraw()
        return


    timer += delta
    if timer >= LIFETIME:
        queue_free()
        return


    bob_phase += BOB_SPEED * delta
    global_position.y = base_pos.y + sin(bob_phase) * BOB_AMOUNT

    queue_redraw()


func collect(ship: Node2D) -> float:
    if is_collected:
        return 0.0
    is_collected = true
    collect_target = ship
    collect_speed = INITIAL_COLLECT_SPEED
    remove_from_group("resource_drops")
    return raw_resource

func _draw():

    if is_collected:
        var s = glow_size * 0.6
        draw_circle(Vector2.ZERO, s, Color(drop_color.r, drop_color.g, drop_color.b, 0.7))
        draw_circle(Vector2.ZERO, s * 0.4, Color(1, 1, 1, 0.6))
        return


    var alpha = 1.0
    if timer >= BLINK_START:
        alpha = 0.2 + 0.8 * abs(sin(timer * 8.0))


    var glow_alpha = alpha * 0.25
    draw_circle(Vector2.ZERO, glow_size * 2.5, Color(drop_color.r, drop_color.g, drop_color.b, glow_alpha))


    var core_alpha = alpha * 0.85
    draw_circle(Vector2.ZERO, glow_size, Color(drop_color.r, drop_color.g, drop_color.b, core_alpha))


    draw_circle(Vector2.ZERO, glow_size * 0.35, Color(1.0, 1.0, 1.0, alpha * 0.7))


    if is_gold:
        var sparkle = abs(sin(timer * 5.0)) * alpha * 0.5
        draw_circle(Vector2.ZERO, glow_size * 1.5, Color(1.0, 0.95, 0.5, sparkle))
