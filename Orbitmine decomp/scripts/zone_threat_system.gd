extends Node
class_name ZoneThreatSystem








var planet_data: PlanetData = null
var player: CharacterBody2D = null
var planet_renderer: Node2D = null


var current_zone: int = PlanetData.Zone.SPRING
var current_zone_name: String = ""


var is_active: bool = false




const SPRING_REGEN_INTERVAL_OUTER: float = 10.0
const SPRING_REGEN_INTERVAL_BOSS: float = 6.0
const SPRING_REGEN_COUNT_OUTER: int = 2
const SPRING_REGEN_COUNT_BOSS: int = 3

const SPRING_ATTACKED_INTERVAL_OUTER: float = 5.0
const SPRING_ATTACKED_INTERVAL_BOSS: float = 3.0
const SPRING_ATTACKED_COUNT_OUTER: int = 4
const SPRING_ATTACKED_COUNT_BOSS: int = 6
const SPRING_BOSS_BURST_HP: float = 0.5

const THORN_KNOCKBACK_FORCE: float = 450.0
const THORN_KNOCKBACK_INVINCIBLE: float = 0.3
var thorn_knockback_cooldown: float = 0.0
var spring_regen_timers: Dictionary = {}
var spring_core_hp_cache: Dictionary = {}
var spring_boss_burst_done: Dictionary = {}

const THORN_WAVE_INTERVAL: float = 0.15
const THORN_WAVE_STEP: int = 3
var thorn_wave_active: Dictionary = {}
var thorn_wave_timer: float = 0.0





const OVERHEAT_GAIN_RATE: float = 8.0
const OVERHEAT_DECAY_RATE: float = 15.0
const OVERHEAT_MAX: float = 100.0
const OVERHEAT_PENALTY_RESET: float = 50.0
const OVERHEAT_KNOCKBACK: float = 500.0
var overheat_gauge: float = 0.0
var is_overheated: bool = false


const LASER_INTERVAL_OUTER: float = 5.5
const LASER_INTERVAL_BOSS: float = 4.5
const LASER_INTERVAL_BOSS_LOW: float = 2.0
const LASER_WARN_OUTER: float = 1.5
const LASER_WARN_BOSS: float = 1.5
const LASER_FIRE_DURATION: float = 0.3
const LASER_WIDTH: float = 24.0
const LASER_LENGTH: float = 1200.0
const LASER_KNOCKBACK: float = 500.0
const LASER_BOSS_TRACK_SPEED: float = 0.3
const LASER_BOSS_HP_THRESHOLD: float = 0.5

var laser_states: Dictionary = {}





const WIND_INTERVAL_OUTER: float = 5.0
const WIND_INTERVAL_BOSS: float = 3.0
const WIND_WARN_TIME: float = 1.0
const WIND_FORCE: float = 600.0
const WIND_FORCE_BOSS_LOW: float = 800.0
var wind_timer: float = 0.0
var wind_warning_active: bool = false
var wind_direction: Vector2 = Vector2.ZERO
var wind_warn_timer: float = 0.0


const WIND_LEAF_COUNT: int = 18
const WIND_LEAF_DRIFT_SPEED: float = 60.0
const WIND_LEAF_GUST_SPEED: float = 600.0
const WIND_LEAF_LIFETIME: float = 2.0
const WIND_LEAF_SIZE: float = 4.0
var wind_leaves: Array = []


const DEBRIS_INTERVAL_OUTER: float = 4.5
const DEBRIS_INTERVAL_BOSS: float = 2.5
const DEBRIS_INTERVAL_BOSS_LOW: float = 1.5
const DEBRIS_COUNT_OUTER: int = 2
const DEBRIS_COUNT_BOSS: int = 3
const DEBRIS_COUNT_BOSS_LOW: int = 5
const DEBRIS_SPEED: float = 175.0
const DEBRIS_HOMING_STRENGTH: float = 1.8
const DEBRIS_LIFETIME: float = 5.0
const DEBRIS_HIT_RADIUS: float = 16.0
const DEBRIS_KNOCKBACK: float = 400.0
const DEBRIS_BOSS_HP_THRESHOLD: float = 0.5
const DEBRIS_MAX_ACTIVE: int = 20
var debris_list: Array = []
var debris_timers: Dictionary = {}




const COLD_SLOW_OUTER: float = 0.25
const COLD_SLOW_BOSS: float = 0.4
const COLD_SLOW_MAX: float = 0.5
var cold_slow_amount: float = 0.0


const CROSS_LASER_SPEED_BASE: float = 0.4
const CROSS_LASER_SPEED_ATTACKED: float = 0.6
const CROSS_LASER_SPEED_BOSS_LOW: float = 1.0
const CROSS_LASER_WIDTH: float = 20.0
const CROSS_LASER_KNOCKBACK: float = 450.0
const CROSS_LASER_BOSS_HP_THRESHOLD: float = 0.5
const CROSS_LASER_HIT_COOLDOWN: float = 0.5
const CROSS_LASER_GAP_SIZE: float = 0.18
const CROSS_LASER_GAP_SLIDE_SPEED: float = 0.15
const CROSS_LASER_GAP_MAX: float = 0.85


var cross_laser_states: Dictionary = {}




signal zone_changed(zone: int, zone_name: String)
signal overheat_changed(value: float, max_value: float)
signal overheat_triggered()
signal wind_warning(direction: Vector2, time_left: float)
signal wind_gust(direction: Vector2, force: float)
signal cold_slow_changed(amount: float)
signal thorn_burst(core_id: int, count: int)
signal laser_warning(core_id: int, origin: Vector2, direction: Vector2, warn_time: float)
signal laser_fired(core_id: int, origin: Vector2, direction: Vector2)
signal laser_ended(core_id: int)
signal debris_spawned(core_id: int, count: int)
signal cross_laser_hit(core_id: int)
signal center_boss_started()
signal center_phase_changed(phase: int, phase_name: String)
signal center_boss_defeated()
signal arena_ring_erased(ring_index: int, positions: Array)
const CENTER_ARENA_RADIUS: int = 25
const ARENA_WAVE_INTERVAL: float = 0.22
const ARENA_RING_STEP: int = 3
const CENTER_PHASE_TRANSITION_TIME: float = 1.5
const CENTER_PHASE_NAMES: Array = ["대기", "🌸 봄", "☀️ 여름", "🍂 가을", "❄️ 겨울"]

const CENTER_PHASE_COLORS: Dictionary = {
    1: Color(0.6, 1.0, 0.6), 
    2: Color(1.0, 0.5, 0.1), 
    3: Color(0.9, 0.6, 0.2), 
    4: Color(0.4, 0.7, 1.0), 
}

var center_boss_active: bool = false
var center_phase: int = 0
var center_transitioning: bool = false
var center_transition_timer: float = 0.0


var arena_wave_rings: Array = []
var arena_wave_index: int = 0
var arena_wave_timer: float = 0.0
var arena_wave_active: bool = false
var _arena_wave_test_only: bool = false





func setup(p_planet_data: PlanetData, p_player: CharacterBody2D, p_renderer: Node2D):
    planet_data = p_planet_data
    player = p_player
    planet_renderer = p_renderer
    is_active = true
    _reset_all()

    if not planet_data.final_core_phase_depleted.is_connected(_on_final_core_phase_depleted):
        planet_data.final_core_phase_depleted.connect(_on_final_core_phase_depleted)
    print("[ZoneThreat] 시스템 초기화 완료")

func _reset_all():
    current_zone = PlanetData.Zone.SPRING
    spring_regen_timers.clear()
    spring_core_hp_cache.clear()
    spring_boss_burst_done.clear()
    thorn_knockback_cooldown = 0.0
    thorn_wave_active.clear()
    thorn_wave_timer = 0.0
    overheat_gauge = 0.0
    is_overheated = false
    laser_states.clear()
    wind_timer = 0.0
    wind_warning_active = false
    wind_leaves.clear()
    debris_list.clear()
    debris_timers.clear()
    cold_slow_amount = 0.0
    cross_laser_states.clear()
    center_boss_active = false
    center_phase = 0
    center_transitioning = false
    center_transition_timer = 0.0
    arena_wave_rings.clear()
    arena_wave_index = 0
    arena_wave_timer = 0.0
    arena_wave_active = false
    _arena_wave_test_only = false





func update(delta: float):
    if not is_active or planet_data == null or player == null:
        return
    if player.get("is_dead"):
        return


    if thorn_knockback_cooldown > 0:
        thorn_knockback_cooldown -= delta


    var player_grid = planet_data.world_to_grid(player.global_position)
    var new_zone = PlanetData.get_zone(player_grid)

    if new_zone != current_zone:
        current_zone = new_zone
        current_zone_name = PlanetData.get_zone_name(new_zone)
        zone_changed.emit(current_zone, current_zone_name)
        print("[ZoneThreat] 구역 변경: %s" % current_zone_name)


    _update_spring(delta)


    _update_autumn_debris(delta)
    _update_wind_leaves(delta)


    _update_cross_lasers(delta)


    match current_zone:
        PlanetData.Zone.SPRING:
            _decay_other_gauges(delta)
        PlanetData.Zone.SUMMER:
            _update_summer(delta)
        PlanetData.Zone.AUTUMN:
            _update_autumn(delta)
            _decay_other_gauges(delta)
        PlanetData.Zone.WINTER:
            _update_winter(delta)
            _decay_other_gauges(delta)
        PlanetData.Zone.CENTER:
            _update_center(delta)


func _decay_other_gauges(delta: float):

    if overheat_gauge > 0:
        overheat_gauge = maxf(0.0, overheat_gauge - OVERHEAT_DECAY_RATE * delta)
        overheat_changed.emit(overheat_gauge, OVERHEAT_MAX)

    if not laser_states.is_empty():
        for cid in laser_states:
            if laser_states[cid].state == "firing":
                laser_ended.emit(cid)
        laser_states.clear()

    if cold_slow_amount > 0 and current_zone != PlanetData.Zone.WINTER:
        cold_slow_amount = maxf(0.0, cold_slow_amount - 0.167 * delta)
        cold_slow_changed.emit(cold_slow_amount)

func _decay_spring_timer(_delta: float):
    pass





func _update_spring(delta: float):

    for core in planet_data.cores:
        if not core.alive or core.zone != PlanetData.Zone.SPRING:
            continue

        var cid = core.id
        if cid not in spring_regen_timers:
            spring_regen_timers[cid] = 0.0

        spring_regen_timers[cid] += delta


        var hp_ratio = _get_core_hp_ratio(core)
        var is_attacked = hp_ratio < 1.0


        if core.role == "boss" and is_attacked:
            if hp_ratio <= SPRING_BOSS_BURST_HP and not spring_boss_burst_done.get(cid, false):
                spring_boss_burst_done[cid] = true

                thorn_wave_active[cid] = {
                    "core": core, 
                    "current_ring": 0, 
                    "max_ring": core.influence_radius, 
                    "total_spawned": 0, 
                }
                thorn_wave_timer = 0.0
                SoundManager.play("block_destroy")
                Global.request_shake(6.0, 0.4)
                print("[ZoneThreat] 🌸💥 봄 보스 코어#%d 가시 폭발 웨이브 시작!" % cid)


        var interval: float
        var max_count: int
        if is_attacked:

            interval = SPRING_ATTACKED_INTERVAL_BOSS if core.role == "boss" else SPRING_ATTACKED_INTERVAL_OUTER
            max_count = SPRING_ATTACKED_COUNT_BOSS if core.role == "boss" else SPRING_ATTACKED_COUNT_OUTER
        else:

            interval = SPRING_REGEN_INTERVAL_BOSS if core.role == "boss" else SPRING_REGEN_INTERVAL_OUTER
            max_count = SPRING_REGEN_COUNT_BOSS if core.role == "boss" else SPRING_REGEN_COUNT_OUTER

        if spring_regen_timers[cid] >= interval:
            spring_regen_timers[cid] = 0.0
            var count = randi_range(1, max_count)


            _save_player_grid()
            var actual = planet_data.spawn_thorn_blocks(core, count)
            if actual > 0:
                _check_thorn_knockback(core)
                if is_attacked:
                    print("[ZoneThreat] 🌸🌿 코어#%d 피격 → 가시 블록 %d개 생성" % [cid, actual])
                else:
                    print("[ZoneThreat] 🌸 코어#%d 가시 블록 %d개 재생" % [cid, actual])


    _update_thorn_waves(delta)


func _update_thorn_waves(delta: float):
    if thorn_wave_active.is_empty():
        return

    thorn_wave_timer += delta
    if thorn_wave_timer < THORN_WAVE_INTERVAL:
        return
    thorn_wave_timer = 0.0


    var finished_ids: Array = []

    for cid in thorn_wave_active:
        var wave = thorn_wave_active[cid]
        var core = wave.core
        var ring_start: int = wave.current_ring
        var ring_end: int = mini(ring_start + THORN_WAVE_STEP, wave.max_ring)


        _save_player_grid()


        var spawned = planet_data.spawn_thorn_ring(core, ring_start, ring_end)
        wave.total_spawned += spawned
        wave.current_ring = ring_end


        if spawned > 0:
            _check_thorn_knockback(core)


        if spawned > 0:
            Global.request_shake(1.5, 0.05)


        if wave.current_ring >= wave.max_ring:
            thorn_burst.emit(cid, wave.total_spawned)
            print("[ZoneThreat] 🌸💥 코어#%d 가시 폭발 완료! 총 %d블록" % [cid, wave.total_spawned])
            finished_ids.append(cid)

    for cid in finished_ids:
        thorn_wave_active.erase(cid)


func _get_spring_core_hp(core: Dictionary) -> float:
    var total_hp: = 0.0
    var total_max: = 0.0
    var half: int = core.size / 2
    for dx in range( - half, half + core.size % 2):
        for dy in range( - half, half + core.size % 2):
            var pos = Vector2i(core.center.x + dx, core.center.y + dy)
            var block = planet_data.blocks.get(pos)
            if block and block.core_id == core.id:
                total_hp += block.hp
                total_max += block.max_hp
    if total_max <= 0:
        return 0.0
    return clampf(total_hp / total_max, 0.0, 1.0)


var _pre_spawn_empty: Array = []


func _save_player_grid():
    _pre_spawn_empty.clear()
    if player == null:
        return
    var pg = planet_data.world_to_grid(player.global_position)
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var pos = pg + Vector2i(dx, dy)
            if not planet_data.blocks.has(pos):
                _pre_spawn_empty.append(pos)


func _check_thorn_knockback(core: Dictionary):
    if player == null or player.get("is_dead"):
        return
    if thorn_knockback_cooldown > 0:
        return


    var overlapped = false
    for pos in _pre_spawn_empty:
        var block = planet_data.blocks.get(pos)
        if block and block.type == PlanetData.BlockType.THORN:
            overlapped = true
            break

    if not overlapped:
        return


    var core_world = planet_data.grid_to_world(core.center)
    var push_dir = (player.global_position - core_world).normalized()
    if push_dir.length() < 0.1:
        push_dir = Vector2(0, -1)


    var force = THORN_KNOCKBACK_FORCE * (1.0 - Global.thorn_knockback_resist)
    if player.has_method("apply_knockback"):
        player.apply_knockback(push_dir * force)
        player.knockback_stun_timer = 0.1

    thorn_knockback_cooldown = THORN_KNOCKBACK_INVINCIBLE
    Global.request_shake(2.0, 0.1)
    print("[ZoneThreat] 🌸 가시 블록 겨침! 넉백 (내성: %.0f%%)" % (Global.thorn_knockback_resist * 100))


func _regen_blocks_around_core(core: Dictionary, count: int) -> int:
    var center = core.center
    var radius = core.influence_radius
    var radius_sq = radius * radius
    var planet_r_sq = PlanetData.PLANET_RADIUS * PlanetData.PLANET_RADIUS


    var empty_spots: Array = []
    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            var pos = Vector2i(x, y)
            var dx = x - center.x
            var dy = y - center.y
            if dx * dx + dy * dy <= radius_sq\
and pos.x * pos.x + pos.y * pos.y <= planet_r_sq\
and not planet_data.blocks.has(pos):

                if not planet_data.is_in_dead_core_zone(pos):
                    empty_spots.append(pos)

    if empty_spots.is_empty():
        return 0


    empty_spots.shuffle()
    var actual_count = mini(count, empty_spots.size())

    for i in range(actual_count):
        var pos = empty_spots[i]
        var dist = sqrt(float(pos.x * pos.x + pos.y * pos.y))
        var hp = planet_data._calc_block_hp(dist)
        var res = planet_data._calc_block_resource(dist)


        var influence_mult = planet_data._get_influence_hp_mult(pos, true)
        if influence_mult > 1.0:
            hp *= influence_mult

        var zone = PlanetData.get_zone(pos)
        planet_data.blocks[pos] = {
            "type": PlanetData.BlockType.NORMAL, 
            "hp": hp, 
            "max_hp": hp, 
            "resource": res, 
            "core_id": -1, 
            "zone": zone, 
            "regenerated": true, 
        }
        planet_data.minimap_block_spawned.emit(pos, PlanetData.BlockType.NORMAL)

    return actual_count





func _update_summer(delta: float):

    var in_influence = _is_player_in_zone_influence(PlanetData.Zone.SUMMER)


    var is_mining = player.get("has_target") == true

    var gain_mult = 1.0 - Global.overheat_resist
    var decay_mult = 1.0 + Global.overheat_resist
    if in_influence and is_mining:
        overheat_gauge += OVERHEAT_GAIN_RATE * gain_mult * delta
    else:
        overheat_gauge -= OVERHEAT_DECAY_RATE * decay_mult * delta

    overheat_gauge = clampf(overheat_gauge, 0.0, OVERHEAT_MAX)
    overheat_changed.emit(overheat_gauge, OVERHEAT_MAX)

    if overheat_gauge >= OVERHEAT_MAX and not is_overheated:
        is_overheated = true
        _trigger_overheat()

    if is_overheated and overheat_gauge < OVERHEAT_MAX * 0.8:
        is_overheated = false


    _update_summer_lasers(delta)

func _trigger_overheat():
    overheat_gauge = OVERHEAT_PENALTY_RESET
    overheat_changed.emit(overheat_gauge, OVERHEAT_MAX)
    overheat_triggered.emit()


    if player.has_method("apply_knockback"):
        var push_dir = player.velocity.normalized() * -1
        if push_dir.length() < 0.1:
            push_dir = Vector2(0, -1)
        player.apply_knockback(push_dir * OVERHEAT_KNOCKBACK)


    if player.barrier_count > 0:
        player.barrier_count -= 1
        player.collision_invincible_timer = player.KNOCKBACK_INVINCIBLE
        player.knockback_stun_timer = player.KNOCKBACK_STUN
        SoundManager.play("barrier_hit")
        Global.request_shake(4.0, 0.2)
        print("[ZoneThreat] ☀️ 과열! 배리어 소모, 남은: %d" % player.barrier_count)
    else:

        var debug = player.get_tree().get_first_node_in_group("debug_menu")
        if debug and debug.godmode:
            print("[ZoneThreat] ☀️ 과열 → 무적으로 생존")
            return
        player.is_dead = true
        player.visible = false
        SoundManager.play("barrier_break")
        Global.request_shake(5.0, 0.4)
        print("[ZoneThreat] ☀️ 과열 즉사!")
        var scene = player.get_parent()
        if scene.has_method("on_ship_crashed"):
            scene.on_ship_crashed()


func _update_summer_lasers(delta: float):
    var player_grid = planet_data.world_to_grid(player.global_position)
    for core in planet_data.cores:
        if not core.alive:
            continue

        if core.zone != PlanetData.Zone.SUMMER and not _is_center_boss_core(core, 2):
            continue
        var cid = core.id
        var is_boss = core.role == "boss" or core.role == "final"


        var dx = player_grid.x - core.center.x
        var dy = player_grid.y - core.center.y
        var in_range = (dx * dx + dy * dy) <= core.influence_radius * core.influence_radius


        if _is_center_boss_core(core, 2):
            in_range = true


        if not in_range:
            if laser_states.has(cid):
                if laser_states[cid].state == "firing":
                    laser_ended.emit(cid)
                laser_states.erase(cid)
            continue


        var hp_ratio = _get_core_hp_ratio(core)


        if not laser_states.has(cid):
            var interval = LASER_INTERVAL_OUTER
            if is_boss:
                interval = LASER_INTERVAL_BOSS_LOW if hp_ratio <= LASER_BOSS_HP_THRESHOLD else LASER_INTERVAL_BOSS
            laser_states[cid] = {
                "state": "idle", 
                "timer": 0.0, 
                "dir": Vector2.ZERO, 
                "origin": Vector2.ZERO, 
                "warn_time": LASER_WARN_BOSS if is_boss else LASER_WARN_OUTER, 
                "interval": interval, 
                "is_boss": is_boss, 
                "core_ref": core, 
                "influence_radius": core.influence_radius, 
            }

        var ls = laser_states[cid]


        if is_boss:
            ls.interval = LASER_INTERVAL_BOSS_LOW if hp_ratio <= LASER_BOSS_HP_THRESHOLD else LASER_INTERVAL_BOSS

        ls.timer += delta


        match ls.state:
            "idle":

                if ls.timer >= ls.interval:
                    ls.state = "warning"
                    ls.timer = 0.0

                    ls.origin = planet_data.grid_to_world(core.center)

                    ls.dir = (player.global_position - ls.origin).normalized()
                    laser_warning.emit(cid, ls.origin, ls.dir, ls.warn_time)
                    SoundManager.play("electric_chain", 0.6)
                    print("[ZoneThreat] ☀️ 레이저 경고! 코어#%d (%s)" % [cid, "boss" if is_boss else "outer"])

            "warning":

                if is_boss:
                    var target_dir = (player.global_position - ls.origin).normalized()
                    var angle_diff = ls.dir.angle_to(target_dir)
                    var max_rotate = LASER_BOSS_TRACK_SPEED * delta
                    var rotate_amount = clampf(angle_diff, - max_rotate, max_rotate)
                    ls.dir = ls.dir.rotated(rotate_amount)


                if ls.timer >= ls.warn_time:
                    ls.state = "firing"
                    ls.timer = 0.0
                    laser_fired.emit(cid, ls.origin, ls.dir)
                    Global.request_shake(3.0, 0.15)
                    SoundManager.play("chain_lightning", 0.5)
                    print("[ZoneThreat] ☀️ 레이저 발사! 코어#%d" % cid)

                    _check_laser_hit(ls)

            "firing":

                _check_laser_hit(ls)

                if ls.timer >= LASER_FIRE_DURATION:
                    ls.state = "idle"
                    ls.timer = 0.0
                    laser_ended.emit(cid)


func _check_laser_hit(ls: Dictionary):
    if player == null or player.get("is_dead"):
        return

    var invincible_t = player.get("collision_invincible_timer")
    if invincible_t != null and invincible_t > 0:
        return


    var p = player.global_position
    var a = ls.origin
    var laser_len = ls.get("influence_radius", 22) * PlanetData.BLOCK_SIZE
    var b = ls.origin + ls.dir * laser_len
    var ab = b - a
    var ap = p - a
    var t = clampf(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
    var closest = a + ab * t
    var dist = p.distance_to(closest)

    if dist > LASER_WIDTH * 0.5:
        return


    var push_dir = (p - closest).normalized()
    if push_dir.length() < 0.1:
        push_dir = ls.dir.rotated(PI * 0.5)

    if player.barrier_count > 0:
        player.barrier_count -= 1
        player.collision_invincible_timer = 0.5
        player.knockback_stun_timer = 0.2
        if player.has_method("apply_knockback"):
            player.apply_knockback(push_dir * LASER_KNOCKBACK)
        SoundManager.play("barrier_hit")
        Global.request_shake(4.0, 0.2)
        print("[ZoneThreat] ☀️ 레이저 피격! 배리어 소모, 남은: %d" % player.barrier_count)
    else:

        var debug = player.get_tree().get_first_node_in_group("debug_menu")
        if debug and debug.godmode:
            print("[ZoneThreat] ☀️ 레이저 → 무적으로 생존")
            return
        player.is_dead = true
        player.visible = false
        SoundManager.play("barrier_break")
        Global.request_shake(5.0, 0.4)
        print("[ZoneThreat] ☀️ 레이저 즉사!")
        var scene = player.get_parent()
        if scene.has_method("on_ship_crashed"):
            scene.on_ship_crashed()


func _get_core_hp_ratio(core: Dictionary) -> float:
    var total_hp: = 0.0
    var total_max: = 0.0
    var half: int = core.size / 2
    for dx in range( - half, half + core.size % 2):
        for dy in range( - half, half + core.size % 2):
            var pos = Vector2i(core.center.x + dx, core.center.y + dy)
            var block = planet_data.blocks.get(pos)
            if block and block.core_id == core.id:
                total_hp += block.hp
                total_max += block.max_hp
    if total_max <= 0:
        return 0.0
    return clampf(total_hp / total_max, 0.0, 1.0)





func _update_autumn(delta: float):

    _update_autumn_debris_spawn(delta)


    if not _is_player_in_zone_influence(PlanetData.Zone.AUTUMN):
        wind_warning_active = false
        wind_timer = 0.0
        return

    var in_boss = _is_player_in_boss_influence(PlanetData.Zone.AUTUMN)
    var interval = WIND_INTERVAL_BOSS if in_boss else WIND_INTERVAL_OUTER

    wind_timer += delta


    if not wind_warning_active and wind_timer >= interval - WIND_WARN_TIME:
        wind_warning_active = true
        wind_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
        wind_warning.emit(wind_direction, WIND_WARN_TIME)
        _spawn_wind_leaves(wind_direction)
        if SoundManager.has_method("play"):
            SoundManager.play("wind_warn")


    if wind_warning_active:
        var time_left = interval - wind_timer
        wind_warning.emit(wind_direction, maxf(0, time_left))


    if wind_timer >= interval:
        wind_timer = 0.0
        wind_warning_active = false
        _accelerate_wind_leaves(wind_direction)

        var force = WIND_FORCE
        if in_boss and _is_autumn_boss_low_hp():
            force = WIND_FORCE_BOSS_LOW
        _apply_wind_gust(wind_direction, force)

func _apply_wind_gust(direction: Vector2, force: float):
    wind_gust.emit(direction, force)


    var actual_force = force * (1.0 - Global.wind_resist)
    if player.has_method("apply_knockback"):
        player.apply_knockback(direction * actual_force)

        player.knockback_stun_timer = 0.15
        Global.request_shake(2.5, 0.15)
        print("[ZoneThreat] 🍂 강풍! 힘: %.0f (내성: %.0f%%)" % [actual_force, Global.wind_resist * 100])






func _spawn_wind_leaves(direction: Vector2):
    if player == null:
        return
    var cam_center = player.global_position
    var perp = direction.rotated(PI * 0.5)

    for i in range(WIND_LEAF_COUNT):

        var offset_along = randf_range(-250, 250) * perp
        var offset_back = direction * randf_range(-350, -80)
        var spawn_pos = cam_center + offset_along + offset_back


        var drift_vel = direction * WIND_LEAF_DRIFT_SPEED
        drift_vel += perp * randf_range(-20, 20)

        wind_leaves.append({
            "pos": spawn_pos, 
            "vel": drift_vel, 
            "lifetime": WIND_LEAF_LIFETIME + randf_range(-0.3, 0.3), 
            "max_lifetime": WIND_LEAF_LIFETIME, 
            "rot": randf() * TAU, 
            "spin": randf_range(2.0, 5.0) * (1.0 if randf() > 0.5 else -1.0), 
            "size": WIND_LEAF_SIZE * randf_range(0.6, 1.3), 
            "sway_phase": randf() * TAU, 
        })


func _accelerate_wind_leaves(direction: Vector2):
    for leaf in wind_leaves:
        leaf.vel = direction * WIND_LEAF_GUST_SPEED

        var perp = direction.rotated(PI * 0.5)
        leaf.vel += perp * randf_range(-80, 80)
        leaf.spin *= 2.5


func _update_wind_leaves(delta: float):
    if wind_leaves.is_empty():
        return

    var to_remove: Array = []
    for i in range(wind_leaves.size()):
        var leaf = wind_leaves[i]

        leaf.lifetime -= delta
        if leaf.lifetime <= 0:
            to_remove.append(i)
            continue


        var current_speed = leaf.vel.length()
        if current_speed < WIND_LEAF_GUST_SPEED * 0.5:
            var sway = sin(leaf.sway_phase + leaf.lifetime * 3.0) * 25.0
            var perp = leaf.vel.normalized().rotated(PI * 0.5)
            leaf.pos += perp * sway * delta


        leaf.pos += leaf.vel * delta
        leaf.rot += leaf.spin * delta


    to_remove.sort()
    to_remove.reverse()
    for idx in to_remove:
        if idx < wind_leaves.size():
            wind_leaves.remove_at(idx)






func _update_autumn_debris_spawn(delta: float):
    for core in planet_data.cores:
        if not core.alive:
            continue

        if core.zone != PlanetData.Zone.AUTUMN and not _is_center_boss_core(core, 3):
            continue
        var cid = core.id
        var hp_ratio = _get_core_hp_ratio(core)
        var is_attacked = hp_ratio < 1.0


        if _is_center_boss_core(core, 3):
            is_attacked = true


        if not is_attacked:
            debris_timers.erase(cid)
            continue

        if cid not in debris_timers:
            debris_timers[cid] = 0.0
        debris_timers[cid] += delta


        var is_boss = core.role == "boss" or core.role == "final"
        var interval: float
        if is_boss:
            interval = DEBRIS_INTERVAL_BOSS_LOW if hp_ratio <= DEBRIS_BOSS_HP_THRESHOLD else DEBRIS_INTERVAL_BOSS
        else:
            interval = DEBRIS_INTERVAL_OUTER

        if debris_timers[cid] >= interval:
            debris_timers[cid] = 0.0

            var max_count: int
            if is_boss:
                max_count = DEBRIS_COUNT_BOSS_LOW if hp_ratio <= DEBRIS_BOSS_HP_THRESHOLD else DEBRIS_COUNT_BOSS
            else:
                max_count = DEBRIS_COUNT_OUTER
            var count = randi_range(1, max_count)

            if debris_list.size() + count > DEBRIS_MAX_ACTIVE:
                count = maxi(0, DEBRIS_MAX_ACTIVE - debris_list.size())
            if count > 0:
                _spawn_autumn_debris(core, count)


func _spawn_autumn_debris(core: Dictionary, count: int):
    var origin = planet_data.grid_to_world(core.center)
    var to_player = (player.global_position - origin).normalized()

    for i in range(count):

        var side = 1.0 if randf() > 0.5 else -1.0
        var perp = to_player.rotated(PI * 0.5) * side

        var init_vel = (perp * 0.8 + to_player * 0.4).normalized() * DEBRIS_SPEED

        debris_list.append({
            "pos": origin + perp * 20.0, 
            "vel": init_vel, 
            "lifetime": DEBRIS_LIFETIME, 
            "rot": randf() * TAU, 
            "spin": randf_range(3.0, 8.0) * side, 
            "core_id": core.id, 
            "trail": [], 
            "size": randf_range(0.8, 1.2), 
        })

    debris_spawned.emit(core.id, count)
    SoundManager.play("block_destroy")
    print("[ZoneThreat] 🍂 코어#%d 유도 파편 %d개 발사!" % [core.id, count])


func _update_autumn_debris(delta: float):
    if debris_list.is_empty():
        return

    var to_remove: Array = []

    for i in range(debris_list.size()):
        var d = debris_list[i]


        d.lifetime -= delta
        if d.lifetime <= 0:
            to_remove.append(i)
            continue


        d.trail.append(d.pos)
        if d.trail.size() > 6:
            d.trail.pop_front()



        var speed_mult = 1.0 - (Global.wind_resist * 0.5)
        var actual_speed = DEBRIS_SPEED * speed_mult
        if player and not player.get("is_dead"):
            var to_player = (player.global_position - d.pos).normalized()
            var desired_vel = to_player * actual_speed
            d.vel = d.vel.lerp(desired_vel, DEBRIS_HOMING_STRENGTH * delta)
            d.vel = d.vel.normalized() * actual_speed


        d.pos += d.vel * delta


        d.rot += d.spin * delta


        if _check_debris_player_hit(d):
            to_remove.append(i)
            continue


    to_remove.sort()
    to_remove.reverse()
    for idx in to_remove:
        if idx < debris_list.size():
            debris_list.remove_at(idx)


func _check_debris_player_hit(d: Dictionary) -> bool:
    if player == null or player.get("is_dead"):
        return false

    var invincible_t = player.get("collision_invincible_timer")
    if invincible_t != null and invincible_t > 0:
        return false

    var dist = player.global_position.distance_to(d.pos)
    if dist > DEBRIS_HIT_RADIUS + 12.0:
        return false


    var push_dir = d.vel.normalized()
    if push_dir.length() < 0.1:
        push_dir = (player.global_position - d.pos).normalized()

    if player.barrier_count > 0:
        player.barrier_count -= 1
        player.collision_invincible_timer = 0.5
        player.knockback_stun_timer = 0.2
        if player.has_method("apply_knockback"):
            player.apply_knockback(push_dir * DEBRIS_KNOCKBACK)
        SoundManager.play("barrier_hit")
        Global.request_shake(3.0, 0.15)
        print("[ZoneThreat] 🍂 파편 피격! 배리어 소모, 남은: %d" % player.barrier_count)
    else:

        var debug = player.get_tree().get_first_node_in_group("debug_menu")
        if debug and debug.godmode:
            print("[ZoneThreat] 🍂 파편 → 무적으로 생존")
            return true
        player.is_dead = true
        player.visible = false
        SoundManager.play("barrier_break")
        Global.request_shake(5.0, 0.4)
        print("[ZoneThreat] 🍂 파편 즉사!")
        var scene = player.get_parent()
        if scene.has_method("on_ship_crashed"):
            scene.on_ship_crashed()

    return true





func _update_winter(delta: float):

    var in_influence = _is_player_in_zone_influence(PlanetData.Zone.WINTER)

    if in_influence:
        var in_boss = _is_player_in_boss_influence(PlanetData.Zone.WINTER)
        var target_slow = COLD_SLOW_BOSS if in_boss else COLD_SLOW_OUTER

        var max_slow = COLD_SLOW_MAX * (1.0 - Global.cold_resist)
        target_slow = minf(target_slow, max_slow)

        var rise_rate = target_slow * 0.1
        cold_slow_amount = minf(cold_slow_amount + rise_rate * delta, target_slow)
    else:

        cold_slow_amount = maxf(0.0, cold_slow_amount - 0.167 * delta)

    cold_slow_changed.emit(cold_slow_amount)
    _apply_cold_slow()

func _apply_cold_slow():
    if cold_slow_amount > 0:
        var base_speed = Global.get_effective_speed()
        player.move_speed = base_speed * (1.0 - cold_slow_amount)
    else:
        player.move_speed = Global.get_effective_speed()






func _init_cross_laser_states():
    for core in planet_data.cores:
        if not core.alive:

            if cross_laser_states.has(core.id):
                cross_laser_states.erase(core.id)
            continue

        if core.zone != PlanetData.Zone.WINTER and not _is_center_boss_core(core, 4):
            continue

        var cid = core.id
        var hp_ratio = _get_core_hp_ratio(core)
        var is_boss = core.role == "boss" or core.role == "final"
        var is_attacked = hp_ratio < 1.0

        if _is_center_boss_core(core, 4):
            is_attacked = true


        var speed: float = CROSS_LASER_SPEED_BASE
        if is_attacked:
            if is_boss and hp_ratio <= CROSS_LASER_BOSS_HP_THRESHOLD:
                speed = CROSS_LASER_SPEED_BOSS_LOW
            else:
                speed = CROSS_LASER_SPEED_ATTACKED

        if not cross_laser_states.has(cid):

            var beam_length = core.influence_radius * PlanetData.BLOCK_SIZE
            var core_pixel_radius = float(core.size) * 0.5 * PlanetData.BLOCK_SIZE
            var core_edge_ratio = clampf(core_pixel_radius / beam_length + 0.05, 0.1, 0.4)


            var gaps: Array = []
            for arm_i in range(4):
                gaps.append({
                    "pos": randf_range(core_edge_ratio, CROSS_LASER_GAP_MAX), 
                    "dir": 1.0 if randf() > 0.5 else -1.0, 
                })
            cross_laser_states[cid] = {
                "angle": randf() * TAU, 
                "origin": planet_data.grid_to_world(core.center), 
                "length": beam_length, 
                "speed": speed, 
                "hit_timer": 0.0, 
                "is_boss": is_boss, 
                "core_ref": core, 
                "gaps": gaps, 
                "core_edge_ratio": core_edge_ratio, 
            }
        else:

            var ls = cross_laser_states[cid]
            ls.speed = lerpf(ls.speed, speed, 0.05)


func _update_cross_lasers(delta: float):

    _init_cross_laser_states()

    if cross_laser_states.is_empty():
        return

    for cid in cross_laser_states:
        var ls = cross_laser_states[cid]


        ls.angle += ls.speed * delta
        if ls.angle > TAU:
            ls.angle -= TAU


        if ls.hit_timer > 0:
            ls.hit_timer -= delta


        var gap_min = ls.core_edge_ratio
        for gap in ls.gaps:
            gap.pos += gap.dir * CROSS_LASER_GAP_SLIDE_SPEED * delta

            if gap.pos >= CROSS_LASER_GAP_MAX:
                gap.pos = CROSS_LASER_GAP_MAX
                gap.dir = -1.0
            elif gap.pos <= gap_min:
                gap.pos = gap_min
                gap.dir = 1.0


        _check_cross_laser_player_hit(cid, ls)


func _check_cross_laser_player_hit(cid: int, ls: Dictionary):
    if player == null or player.get("is_dead"):
        return

    if ls.hit_timer > 0:
        return

    var invincible_t = player.get("collision_invincible_timer")
    if invincible_t != null and invincible_t > 0:
        return

    var origin = ls.origin
    var length = ls.length
    var p = player.global_position


    for arm_i in range(4):
        var arm_angle = ls.angle + arm_i * (PI * 0.5)
        var arm_dir = Vector2.from_angle(arm_angle)
        var arm_end = origin + arm_dir * length


        var ab = arm_end - origin
        var ap = p - origin
        var t = clampf(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
        var closest = origin + ab * t
        var dist = p.distance_to(closest)

        if dist > CROSS_LASER_WIDTH * 0.5 + 12.0:
            continue


        if t < ls.core_edge_ratio:
            continue


        var gap = ls.gaps[arm_i]
        var gap_start = gap.pos - CROSS_LASER_GAP_SIZE * 0.5
        var gap_end = gap.pos + CROSS_LASER_GAP_SIZE * 0.5
        if t >= gap_start and t <= gap_end:
            continue


        var push_dir = (p - origin).normalized()
        if push_dir.length() < 0.1:
            push_dir = arm_dir.rotated(PI * 0.5)

        ls.hit_timer = CROSS_LASER_HIT_COOLDOWN
        cross_laser_hit.emit(cid)

        if player.barrier_count > 0:
            player.barrier_count -= 1
            player.collision_invincible_timer = 0.5
            player.knockback_stun_timer = 0.2
            if player.has_method("apply_knockback"):
                player.apply_knockback(push_dir * CROSS_LASER_KNOCKBACK)
            SoundManager.play("barrier_hit")
            Global.request_shake(3.5, 0.15)
            print("[ZoneThreat] ❄️ 회전 레이저 피격! 배리어 소모, 남은: %d" % player.barrier_count)
        else:
            var debug = player.get_tree().get_first_node_in_group("debug_menu")
            if debug and debug.godmode:
                print("[ZoneThreat] ❄️ 회전 레이저 → 무적으로 생존")
                return
            player.is_dead = true
            player.visible = false
            SoundManager.play("barrier_break")
            Global.request_shake(5.0, 0.4)
            print("[ZoneThreat] ❄️ 회전 레이저 즉사!")
            var scene = player.get_parent()
            if scene.has_method("on_ship_crashed"):
                scene.on_ship_crashed()
        return






func _is_player_in_zone_influence(zone: int) -> bool:
    var player_grid = planet_data.world_to_grid(player.global_position)
    for core in planet_data.cores:
        if not core.alive or core.zone != zone:
            continue
        var dx = player_grid.x - core.center.x
        var dy = player_grid.y - core.center.y
        if dx * dx + dy * dy <= core.influence_radius * core.influence_radius:
            return true
    return false


func _is_player_in_boss_influence(zone: int) -> bool:
    var player_grid = planet_data.world_to_grid(player.global_position)
    for core in planet_data.cores:
        if not core.alive or core.zone != zone or core.role != "boss":
            continue
        var dx = player_grid.x - core.center.x
        var dy = player_grid.y - core.center.y
        if dx * dx + dy * dy <= core.influence_radius * core.influence_radius:
            return true
    return false


func _is_autumn_boss_low_hp() -> bool:
    for core in planet_data.cores:
        if core.zone != PlanetData.Zone.AUTUMN or not core.alive or core.role != "boss":
            continue
        if _get_core_hp_ratio(core) <= 0.5:
            return true
    return false


func is_current_zone_unlocked() -> bool:
    return planet_data.is_zone_unlocked(current_zone)


func has_active_effects() -> bool:
    return not laser_states.is_empty()\
or not wind_leaves.is_empty()\
or not debris_list.is_empty()\
or not cross_laser_states.is_empty()\
or not thorn_wave_active.is_empty()\
or arena_wave_active\
or center_boss_active






func start_center_boss():
    if center_boss_active:
        return
    center_boss_active = true
    planet_data.final_boss_active = true


    arena_wave_rings = planet_data.get_arena_rings(CENTER_ARENA_RADIUS, ARENA_RING_STEP)
    arena_wave_index = 0
    arena_wave_timer = 0.0
    arena_wave_active = true

    center_boss_started.emit()
    print("[ZoneThreat] 💀 아레나 웨이브 시작! %d링, 반경 %d" % [arena_wave_rings.size(), CENTER_ARENA_RADIUS])


func start_arena_wave_only():
    if arena_wave_active:
        return

    center_boss_active = true
    planet_data.final_boss_active = true
    _arena_wave_test_only = true

    arena_wave_rings = planet_data.get_arena_rings(CENTER_ARENA_RADIUS, ARENA_RING_STEP)
    arena_wave_index = 0
    arena_wave_timer = 0.0
    arena_wave_active = true
    print("[ZoneThreat] 💠 아레나 웨이브 테스트! %d링, 반경 %d" % [arena_wave_rings.size(), CENTER_ARENA_RADIUS])


func _update_center(delta: float):
    if not center_boss_active:
        _decay_other_gauges(delta)
        return


    if arena_wave_active:
        _update_arena_wave(delta)
        return


    if center_transitioning:
        center_transition_timer -= delta
        if center_transition_timer <= 0:
            center_transitioning = false
            _advance_center_phase()
        return



    _update_center_spring(delta)

    if center_phase >= 2:
        _update_summer_lasers(delta)

    if overheat_gauge > 0:
        overheat_gauge = maxf(0.0, overheat_gauge - OVERHEAT_DECAY_RATE * delta)
        overheat_changed.emit(overheat_gauge, OVERHEAT_MAX)

    if center_phase >= 3:
        _update_center_wind(delta)
        _update_autumn_debris_spawn(delta)

    if center_phase >= 4:
        _update_center_cold(delta)
    else:
        if cold_slow_amount > 0:
            cold_slow_amount = maxf(0.0, cold_slow_amount - 0.167 * delta)
            cold_slow_changed.emit(cold_slow_amount)


func _update_arena_wave(delta: float):
    arena_wave_timer += delta
    if arena_wave_timer < ARENA_WAVE_INTERVAL:
        return
    arena_wave_timer = 0.0


    if arena_wave_index < arena_wave_rings.size():
        var ring = arena_wave_rings[arena_wave_index]
        if ring.size() > 0:
            planet_data.erase_arena_ring(ring)
            arena_ring_erased.emit(arena_wave_index, ring)

            var progress = float(arena_wave_index) / maxf(1.0, float(arena_wave_rings.size() - 1))
            var shake_str = lerpf(0.5, 2.5, progress)
            Global.request_shake(shake_str, 0.04)
            print("[ZoneThreat] 💀 아레나 링 %d/%d 제거 (%d블록)" % [
                arena_wave_index + 1, arena_wave_rings.size(), ring.size()])
        arena_wave_index += 1


    if arena_wave_index >= arena_wave_rings.size():
        arena_wave_active = false
        arena_wave_rings.clear()
        Global.request_shake(5.0, 0.3)
        SoundManager.play("barrier_hit")


        if _arena_wave_test_only:
            _arena_wave_test_only = false
            center_boss_active = false
            planet_data.final_boss_active = false
            print("[ZoneThreat] 💠 아레나 웨이브 테스트 완료!")
        else:

            _advance_center_phase()
            print("[ZoneThreat] 💀 아레나 완료! 페이즈 1 돌입")


func _on_final_core_phase_depleted(phase: int):
    if not center_boss_active or phase != center_phase:
        return
    if center_transitioning:
        return
    if center_phase >= 4:
        return


    center_transitioning = true
    center_transition_timer = CENTER_PHASE_TRANSITION_TIME
    print("[ZoneThreat] 💀 페이즈 %d HP 소진 → %.1f초 예고 후 전환" % [phase, CENTER_PHASE_TRANSITION_TIME])


func _advance_center_phase():
    center_phase += 1
    planet_data.final_core_phase = center_phase

    if center_phase > 4:

        center_boss_active = false
        center_boss_defeated.emit()
        print("[ZoneThreat] 💀 CENTER 보스 처치!")
        return


    planet_data.reset_final_core_hp()

    var phase_name = CENTER_PHASE_NAMES[center_phase]
    center_phase_changed.emit(center_phase, phase_name)
    print("[ZoneThreat] 💀 페이즈 %d: %s 시작!" % [center_phase, phase_name])


    _init_phase_threats(center_phase)


func _init_phase_threats(phase: int):
    match phase:
        1:
            print("[ZoneThreat] 💀 페이즈 1 — 가시 블록 재생 활성")
        2:
            laser_states.clear()
            overheat_gauge = 0.0
            is_overheated = false
            print("[ZoneThreat] 💀 페이즈 2 — 조준 레이저 추가")
        3:
            wind_timer = 0.0
            wind_warning_active = false
            debris_list.clear()
            debris_timers.clear()
            print("[ZoneThreat] 💀 페이즈 3 — 유도파편 + 강풍 추가")
        4:
            cold_slow_amount = 0.0
            _init_center_cross_lasers()
            print("[ZoneThreat] 💀 페이즈 4 — 감속 + 회전 십자레이저 추가")


func _update_center_spring(delta: float):

    var fc = planet_data.get_final_core()
    if fc == null or not fc.alive:
        return
    var cid = fc.id
    if cid not in spring_regen_timers:
        spring_regen_timers[cid] = 0.0
    spring_regen_timers[cid] += delta


    var interval = SPRING_ATTACKED_INTERVAL_BOSS
    var max_count = SPRING_ATTACKED_COUNT_BOSS

    if spring_regen_timers[cid] >= interval:
        spring_regen_timers[cid] = 0.0
        var count = randi_range(1, max_count)
        _save_player_grid()
        var actual = planet_data.spawn_thorn_blocks(fc, count)
        if actual > 0:
            _check_thorn_knockback(fc)


func _init_center_cross_lasers():

    var fc = planet_data.get_final_core()
    if fc == null or not fc.alive:
        return
    var cid = fc.id
    if cross_laser_states.has(cid):
        return

    var world_cx = fc.center.x * PlanetData.BLOCK_SIZE + PlanetData.BLOCK_SIZE * 0.5
    var world_cy = fc.center.y * PlanetData.BLOCK_SIZE + PlanetData.BLOCK_SIZE * 0.5
    var origin = Vector2(world_cx, world_cy)
    var beam_length = float(fc.influence_radius * PlanetData.BLOCK_SIZE)
    var speed = CROSS_LASER_SPEED_BOSS_LOW
    var core_pixel_radius = float(fc.size) * 0.5 * PlanetData.BLOCK_SIZE
    var core_edge_ratio = clampf(core_pixel_radius / beam_length + 0.05, 0.1, 0.4)

    var gaps: Array = []
    for arm_i in range(4):
        gaps.append({
            "pos": randf_range(core_edge_ratio, CROSS_LASER_GAP_MAX), 
            "dir": 1.0 if randf() > 0.5 else -1.0, 
        })
    cross_laser_states[cid] = {
        "angle": randf() * TAU, 
        "origin": origin, 
        "length": beam_length, 
        "speed": speed, 
        "hit_timer": 0.0, 
        "is_boss": true, 
        "core_ref": fc, 
        "gaps": gaps, 
        "core_edge_ratio": core_edge_ratio, 
    }
    print("[ZoneThreat] 💀 최종 코어 회전 십자레이저 초기화")






func _is_center_boss_core(core: Dictionary, min_phase: int) -> bool:
    return core.id == PlanetData.FINAL_CORE_ID\
and center_boss_active\
and center_phase >= min_phase


func _is_player_in_final_core_influence() -> bool:
    var fc = planet_data.get_final_core()
    if fc == null or not fc.alive:
        return false
    var player_grid = planet_data.world_to_grid(player.global_position)
    var dx = player_grid.x - fc.center.x
    var dy = player_grid.y - fc.center.y
    return dx * dx + dy * dy <= fc.influence_radius * fc.influence_radius


func _update_center_overheat(delta: float):
    var in_influence = _is_player_in_final_core_influence()
    var is_mining = player.get("has_target") == true
    var gain_mult = 1.0 - Global.overheat_resist
    var decay_mult = 1.0 + Global.overheat_resist
    if in_influence and is_mining:
        overheat_gauge += OVERHEAT_GAIN_RATE * gain_mult * delta
    else:
        overheat_gauge -= OVERHEAT_DECAY_RATE * decay_mult * delta

    overheat_gauge = clampf(overheat_gauge, 0.0, OVERHEAT_MAX)
    overheat_changed.emit(overheat_gauge, OVERHEAT_MAX)

    if overheat_gauge >= OVERHEAT_MAX and not is_overheated:
        is_overheated = true
        overheat_triggered.emit()
        if player.has_method("apply_knockback"):
            var push_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
            player.apply_knockback(push_dir * OVERHEAT_KNOCKBACK)
            player.knockback_stun_timer = 0.2
        Global.request_shake(4.0, 0.3)
        overheat_gauge = OVERHEAT_PENALTY_RESET
        is_overheated = false


func _update_center_wind(delta: float):
    if not _is_player_in_final_core_influence():
        wind_warning_active = false
        wind_timer = 0.0
        return

    var interval = WIND_INTERVAL_BOSS
    wind_timer += delta

    if not wind_warning_active and wind_timer >= interval - WIND_WARN_TIME:
        wind_warning_active = true
        wind_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
        wind_warning.emit(wind_direction, WIND_WARN_TIME)
        _spawn_wind_leaves(wind_direction)
        if SoundManager.has_method("play"):
            SoundManager.play("wind_warn")

    if wind_warning_active:
        var time_left = interval - wind_timer
        wind_warning.emit(wind_direction, maxf(0, time_left))

    if wind_timer >= interval:
        wind_timer = 0.0
        wind_warning_active = false
        _accelerate_wind_leaves(wind_direction)
        _apply_wind_gust(wind_direction, WIND_FORCE_BOSS_LOW)


func _update_center_cold(delta: float):
    var in_influence = _is_player_in_final_core_influence()
    if in_influence:
        var target_slow = COLD_SLOW_BOSS
        var max_slow = COLD_SLOW_MAX * (1.0 - Global.cold_resist)
        target_slow = minf(target_slow, max_slow)
        var rise_rate = target_slow * 0.1
        cold_slow_amount = minf(cold_slow_amount + rise_rate * delta, target_slow)
    else:
        cold_slow_amount = maxf(0.0, cold_slow_amount - 0.167 * delta)

    cold_slow_changed.emit(cold_slow_amount)
    _apply_cold_slow()
