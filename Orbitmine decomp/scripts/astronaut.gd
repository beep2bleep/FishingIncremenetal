extends CharacterBody2D








const DEAD_ZONE: float = 30.0
const MAX_INPUT_DIST: float = 300.0


var attack_timer: float = 0.0
const ATTACK_RATE: float = 0.5
var target_asteroid = null
var has_target: bool = false


var visual_rotation: float = 0.0
var glow_phase: float = 0.0
var cargo_full_stop: bool = false


var renderer: Node2D = null


var drop_system = null
var sortie_stats: Dictionary = {
    "dmg_laser": 0.0, "dmg_chain": 0.0, "dmg_aoe": 0.0, 
    "dmg_mega": 0.0, "dmg_drone": 0.0, "dmg_charged_bonus": 0.0, 
    "dmg_crit_bonus": 0.0, "dmg_electric": 0.0, 
    "shots_fired": 0, "crits_landed": 0, "charged_shots": 0, 
    "kills_electric": 0, "kills_drone": 0, "kills_total": 0, 
    "shockwave_count": 0, "overdrive_count": 0, "combo_max": 0, 
}

signal return_requested

func _ready():

    renderer = Node2D.new()
    renderer.name = "AstroRenderer"
    renderer.set_script(load("res://scripts/astro_renderer.gd"))
    add_child(renderer)

func _physics_process(delta):
    _handle_movement(delta)
    _handle_attack(delta)
    glow_phase += delta * 2.0
    if renderer:
        renderer.queue_redraw()

func _handle_movement(delta):
    var viewport_size = get_viewport_rect().size
    var screen_center = viewport_size * 0.5
    var mouse_screen = get_viewport().get_mouse_position()
    var offset = mouse_screen - screen_center
    var distance = offset.length()

    var move_speed = Global.astro_speed

    if distance < DEAD_ZONE:
        velocity = velocity.move_toward(Vector2.ZERO, move_speed * 0.15)
    else:
        var speed_ratio = clampf((distance - DEAD_ZONE) / (MAX_INPUT_DIST - DEAD_ZONE), 0.0, 1.0)
        var target_speed = move_speed * speed_ratio
        velocity = offset.normalized() * target_speed

        var target_angle = offset.angle() + PI * 0.5
        visual_rotation = lerp_angle(visual_rotation, target_angle, 8.0 * delta)

    move_and_slide()

func _handle_attack(delta):
    if cargo_full_stop:
        has_target = false
        return


    var attack_range = Global.astro_range
    var asteroids = get_tree().get_nodes_in_group("asteroids")

    target_asteroid = null
    var closest_dist = attack_range * attack_range
    for ast in asteroids:
        if not is_instance_valid(ast) or ast.hp <= 0:
            continue
        var dist_sq = global_position.distance_squared_to(ast.global_position)
        if dist_sq < closest_dist:
            closest_dist = dist_sq
            target_asteroid = ast

    has_target = target_asteroid != null

    if has_target:
        attack_timer += delta
        if attack_timer >= ATTACK_RATE:
            attack_timer = 0.0
            _do_attack()

func _do_attack():
    if target_asteroid == null or not is_instance_valid(target_asteroid):
        return

    var dmg = Global.astro_damage
    target_asteroid.take_damage(dmg)
    sortie_stats.dmg_laser += dmg
    sortie_stats.shots_fired += 1


func get_visual_power() -> float:
    return 0.1
