extends Node







const FIRE_RATE: float = 0.6
const RANGE: float = 230.0
const FOLLOW_SPEED: float = 8.0
const SPACING: float = 20.0
const BEHIND_DIST: float = 25.0


var positions: Array = []
var timers: Array = []
var targets: Array = []
var visible_timers: Array = []


var ship: CharacterBody2D

func _ready():
    ship = get_parent()



func init_drones():
    if not Global.drone_unlocked:
        return
    var count = Global.drone_count
    positions.resize(count)
    timers.resize(count)
    targets.resize(count)
    visible_timers.resize(count)
    for i in range(count):
        positions[i] = Vector2(0, BEHIND_DIST)
        timers[i] = randf() * FIRE_RATE
        targets[i] = Vector2.ZERO
        visible_timers[i] = 0.0



func update(delta: float):
    var count = positions.size()
    if count == 0:
        return


    var behind_dir = - ship.last_move_dir

    var side_dir = Vector2( - behind_dir.y, behind_dir.x)


    var target_offsets: Array = []
    if count == 1:

        target_offsets.append(behind_dir * BEHIND_DIST)
    elif count == 2:

        target_offsets.append(behind_dir * BEHIND_DIST + side_dir * SPACING * 0.6)
        target_offsets.append(behind_dir * BEHIND_DIST - side_dir * SPACING * 0.6)
    else:

        for i in range(count):
            var row = 0
            var in_row_idx = i
            var row_start = 0
            var row_size = 1
            while in_row_idx >= row_size:
                in_row_idx -= row_size
                row_start += row_size
                row += 1
                row_size = row + 1

            var row_dist = BEHIND_DIST + row * SPACING * 0.8
            var spread = SPACING * 0.6 * (row + 1)
            var lateral = 0.0
            if row_size > 1:
                lateral = lerpf( - spread, spread, float(in_row_idx) / float(row_size - 1))

            target_offsets.append(behind_dir * row_dist + side_dir * lateral)


    for i in range(count):
        var target_local = target_offsets[i]
        positions[i] = positions[i].lerp(target_local, FOLLOW_SPEED * delta)


        visible_timers[i] = max(visible_timers[i] - delta, 0.0)


        timers[i] += delta

        var effective_rate = maxf(0.2, FIRE_RATE - Global.drone_fire_rate_bonus)
        if timers[i] >= effective_rate:
            timers[i] = 0.0
            fire(i)



func fire(drone_idx: int):
    if ship._is_attack_disabled():
        return
    if ship.planet_data == null:
        return
    var drone_world = ship.global_position + positions[drone_idx]
    var drone_grid = ship.planet_data.world_to_grid(drone_world)
    var search_range = int(ceil(RANGE / PlanetData.BLOCK_SIZE)) + 1


    var candidates: Array = []
    for dx in range( - search_range, search_range + 1):
        for dy in range( - search_range, search_range + 1):
            var check = Vector2i(drone_grid.x + dx, drone_grid.y + dy)
            if not ship.planet_data.has_block(check):
                continue
            var block_world = ship.planet_data.grid_to_world(check)
            var dist_sq = drone_world.distance_squared_to(block_world)
            if dist_sq < RANGE * RANGE:
                candidates.append({"pos": check, "dist_sq": dist_sq, "world": block_world})

    if candidates.is_empty():
        return

    candidates.sort_custom( func(a, b): return a.dist_sq < b.dist_sq)


    var hit_count = mini(Global.drone_pierce, candidates.size())
    var first_world = candidates[0].world

    for i in range(hit_count):
        var target = candidates[i]
        var pos = target.pos


        var drone_dmg = ship._get_resonance_damage(Global.get_effective_drone_damage(), pos)
        drone_dmg = ship._apply_core_breaker(drone_dmg, pos)


        if Global.drone_crit_unlocked and randf() < Global.drone_crit_chance:
            drone_dmg += Global.get_effective_drone_damage() * Global.drone_crit_bonus

        ship.sortie_stats.dmg_drone += drone_dmg

        if ship.planet_renderer and ship.planet_renderer.has_method("register_hit"):
            ship.planet_renderer.register_hit(pos)

        var result = ship.planet_data.damage_block(pos, drone_dmg, true)
        if result.destroyed:
            ship.sortie_stats.kills_drone += 1
            ship._on_block_destroyed(pos, result.type, result.resource)

            Global.on_combo_hit()
        elif result.get("shielded", false):
            ship.drop_system.on_shield_hit(target.world)


    targets[drone_idx] = first_world
    visible_timers[drone_idx] = ship.LASER_VISIBLE_DURATION
