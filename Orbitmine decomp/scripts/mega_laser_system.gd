extends Node







const DAMAGE_INTERVAL: float = 0.08


var gauge: int = 0
var active: bool = false
var timer: float = 0.0
var beam_dir: Vector2 = Vector2(0, -1)
var beam_end: Vector2 = Vector2.ZERO
var beam_hits: Array = []
var damage_timer: float = 0.0


var ship: CharacterBody2D

func _ready():
    ship = get_parent()



func update(delta: float):
    if not active:
        return
    timer -= delta
    if timer <= 0:
        end_mega()
    else:

        _update_beam_dir()

        _trace_beam()

        damage_timer += delta
        if damage_timer >= DAMAGE_INTERVAL:
            damage_timer = 0.0
            _apply_damage()
            Global.request_shake(1.0, 0.05)



func on_block_destroyed():
    if not Global.mega_laser_unlocked or active:
        return
    gauge += 1
    if gauge >= Global.mega_laser_gauge_need:
        activate()



func activate():
    if ship._is_attack_disabled():
        return
    active = true
    timer = Global.mega_laser_duration
    gauge = 0
    damage_timer = 0.0
    ship.sortie_stats.mega_count += 1
    _update_beam_dir()
    _trace_beam()
    Global.request_shake(4.0, 0.4)
    SoundManager.play("mega_laser", 0.8)
    ScreenFX.mega_laser_activate()
    print("[Ship] ⚡ 메가 레이저 발동! %.1f초" % Global.mega_laser_duration)



func end_mega():
    active = false
    timer = 0.0
    beam_hits.clear()
    beam_end = Vector2.ZERO
    print("[Ship] ⚡ 메가 레이저 종료")



func _update_beam_dir():
    var viewport_size = ship.get_viewport_rect().size
    var screen_center = viewport_size * 0.5
    var mouse_screen = ship.get_viewport().get_mouse_position()
    var offset = mouse_screen - screen_center

    if offset.length() > 10.0:
        beam_dir = offset.normalized()



func _trace_beam():
    beam_hits.clear()
    var bs = PlanetData.BLOCK_SIZE
    var step_size = bs * 0.4
    var max_dist = ship.laser_range * 1.5
    var steps = int(max_dist / step_size)
    var visited: Dictionary = {}

    for i in range(steps):
        var check_world = ship.global_position + beam_dir * (step_size * (i + 1))
        var grid_pos = ship.planet_data.world_to_grid(check_world)


        if visited.has(grid_pos):
            continue
        visited[grid_pos] = true


        if ship.planet_data.has_block(grid_pos):
            var block_world = ship.planet_data.grid_to_world(grid_pos)
            beam_hits.append({"pos": grid_pos, "world": block_world})


    beam_end = beam_dir * max_dist



func _apply_damage():
    for hit in beam_hits:
        var pos = hit.pos
        if not ship.planet_data.has_block(pos):
            continue

        if ship.planet_renderer and ship.planet_renderer.has_method("register_hit"):
            ship.planet_renderer.register_hit(pos)

        var dmg = ship._get_resonance_damage(ship.laser_damage, pos)
        dmg = ship._apply_core_breaker(dmg, pos)
        ship.sortie_stats.dmg_mega += dmg
        var result = ship.planet_data.damage_block(pos, dmg, true)
        if result.destroyed:
            ship._on_block_destroyed(pos, result.type, result.resource)
        elif result.get("shielded", false):
            var shield_world = Vector2(pos) * PlanetData.BLOCK_SIZE
            ship.drop_system.on_shield_hit(shield_world)
