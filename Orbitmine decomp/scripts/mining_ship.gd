extends CharacterBody2D







var move_speed: float = 300.0
var stop_distance: float = 5.0


var laser_damage: float = 1.0
var laser_range: float = 80.0
var laser_fire_rate: float = 0.8
var laser_timer: float = 0.0
var shot_counter: int = 0
var is_charged_shot: bool = false
var is_crit_shot: bool = false


var barrier_count: int = 0
var overheat_ratio: float = 0.0
var barrier_regen_timer: float = 0.0
var is_dead: bool = false
var cargo_full_stop: bool = false


var is_braking: bool = false


var spawn_protection_timer: float = 0.0


var target_block: Vector2i = Vector2i(-9999, -9999)
var target_world_pos: Vector2 = Vector2.ZERO
var has_target: bool = false


var laser_flash_timer: float = 0.0
var laser_visible_timer: float = 0.0
const LASER_VISIBLE_DURATION: float = 0.08
var ship_glow_phase: float = 0.0


const NORMAL_SHAKE_INTENSITY: float = 0.8
const NORMAL_SHAKE_DURATION: float = 0.06
const CORE_SHAKE_INTENSITY: float = 8.0
const CORE_SHAKE_DURATION: float = 0.5



const SHIP_LINE: = Color(0.5, 1.8, 2.0)
const SHIP_GLOW: = Color(0.3, 1.2, 1.5, 0.15)
const ENGINE_COLOR: = Color(0.5, 1.8, 2.0, 0.9)
const LASER_LINE: = Color(2.0, 0.7, 0.2)
const LASER_GLOW: = Color(1.5, 0.5, 0.15, 0.3)
const HIT_FLASH: = Color(2.0, 1.8, 1.0)
const RANGE_LINE: = Color(0.3, 1.0, 1.2, 0.06)
const BARRIER_COLOR: = Color(0.3, 1.5, 2.0, 0.4)
const ELECTRIC_ARC: = Color(0.5, 1.5, 2.5)

const CRIT_LINE: = Color(2.0, 2.0, 0.4)
const CRIT_GLOW: = Color(1.5, 1.5, 0.2, 0.35)
const CRIT_BEAM_WIDTH: float = 2.5
const CHARGED_LINE: = Color(2.5, 1.5, 0.2)
const CHARGED_GLOW: = Color(2.0, 1.0, 0.1, 0.4)
const CHARGED_BEAM_WIDTH: float = 4.0


const COLLISION_RADIUS: float = 10.0


const DRONE_LINE: = Color(0.3, 2.0, 0.5)
const DRONE_GLOW: = Color(0.2, 1.5, 0.4, 0.15)
const DRONE_LASER: = Color(0.3, 2.0, 0.6)
const DRONE_LASER_GLOW: = Color(0.2, 1.5, 0.4, 0.3)
var last_move_dir: Vector2 = Vector2(0, -1)


var chain_arcs: Array = []
const CHAIN_ARC_DURATION: float = 0.2
const CHAIN_LIGHTNING_COLOR: = Color(1.0, 0.8, 2.5)
const CHAIN_GLOW_COLOR: = Color(0.7, 0.5, 2.0, 0.3)


const MEGA_LASER_LINE: = Color(2.5, 1.2, 0.3)
const MEGA_LASER_GLOW: = Color(2.0, 0.8, 0.2, 0.35)
const MEGA_BEAM_WIDTH: float = 5.0
const MEGA_GLOW_WIDTH: float = 20.0
const MEGA_CORE_WIDTH: float = 2.0


var is_warping: bool = false
var warp_timer: float = 0.0
var warp_dir: Vector2 = Vector2(0, -1)
const WARP_DURATION: float = 1.2
const WARP_ACCEL: float = 8000.0
const WARP_LINE: = Color(0.5, 2.0, 2.5)
const WARP_GLOW: = Color(0.3, 1.5, 2.0, 0.4)




var is_entering: bool = false
var entry_timer: float = 0.0
var entry_start_pos: Vector2 = Vector2.ZERO
var entry_target_pos: Vector2 = Vector2.ZERO
const ENTRY_DURATION: float = 1.0
const ENTRY_OFFSET: float = 1500.0
signal entry_finished


var shockwave_counter: int = 0
var shockwave_firing: bool = false
const SHOCKWAVE_GOLD_CHANCE: float = 0.08


const OVERDRIVE_COLOR: = Color(2.5, 0.3, 0.2)
const OVERDRIVE_GLOW: = Color(1.5, 0.2, 0.1, 0.3)






var _visual_power_cache: float = 0.0

func update_visual_power_cache():
    var dmg = Global.get_effective_damage()
    if dmg <= 1.0:
        _visual_power_cache = 0.0
    else:
        _visual_power_cache = clampf(log(dmg) / log(150.0), 0.0, 1.0)

func get_visual_power() -> float:
    return _visual_power_cache


func get_beam_width() -> float:
    return lerpf(1.5, 2.5, get_visual_power())


func get_beam_glow_width() -> float:
    return lerpf(8.0, 14.0, get_visual_power())


func get_particle_count() -> int:
    return int(lerpf(5.0, 14.0, get_visual_power()))


func get_hit_flash_radius() -> float:
    return lerpf(3.0, 8.0, get_visual_power())




var combo_popup_timer: float = 0.0
var combo_popup_scale: float = 1.0
var combo_popup_value: int = 0
var combo_popup_is_milestone: bool = false
var last_combo_count: int = 0
const COMBO_POPUP_DURATION: float = 0.8
const COMBO_MILESTONES: Array = [10, 20, 30, 50, 75, 100]


var sortie_stats: Dictionary = {}

func _reset_sortie_stats():
    sortie_stats = {

        "dmg_laser": 0.0, 
        "dmg_crit_bonus": 0.0, 
        "dmg_charged_bonus": 0.0, 
        "dmg_electric": 0.0, 
        "dmg_chain": 0.0, 
        "dmg_drone": 0.0, 
        "dmg_mega": 0.0, 
        "dmg_aoe": 0.0, 

        "kills_total": 0, 
        "kills_electric": 0, 
        "kills_drone": 0, 
        "shots_fired": 0, 
        "crits_landed": 0, 
        "charged_shots": 0, 
        "shockwave_count": 0, 
        "overdrive_count": 0, 
        "mega_count": 0, 
        "combo_max": 0, 
        "barriers_used": 0, 
    }


var planet_data: PlanetData = null
var planet_renderer: Node2D = null
var renderer: Node2D = null
var drop_system: Node = null
var drone_system: Node = null
var mega_system: Node = null
var overdrive_system: Node = null


func _is_godmode() -> bool:
    var debug = get_tree().get_first_node_in_group("debug_menu")
    return debug != null and debug.godmode

func _is_attack_disabled() -> bool:
    var debug = get_tree().get_first_node_in_group("debug_menu")
    return debug != null and debug.attack_disabled

func _ready():
    add_to_group("player")
    _reset_sortie_stats()

    renderer = Node2D.new()
    renderer.name = "ShipRenderer"
    renderer.set_script(load("res://scripts/ship_renderer.gd"))
    add_child(renderer)

    drop_system = Node.new()
    drop_system.name = "DropSystem"
    drop_system.set_script(load("res://scripts/drop_system.gd"))
    add_child(drop_system)

    drone_system = Node.new()
    drone_system.name = "DroneSystem"
    drone_system.set_script(load("res://scripts/drone_system.gd"))
    add_child(drone_system)

    mega_system = Node.new()
    mega_system.name = "MegaLaserSystem"
    mega_system.set_script(load("res://scripts/mega_laser_system.gd"))
    add_child(mega_system)

    overdrive_system = Node.new()
    overdrive_system.name = "OverdriveSystem"
    overdrive_system.set_script(load("res://scripts/overdrive_system.gd"))
    add_child(overdrive_system)


    _apply_global_stats()

func _input(event: InputEvent):

    if Global.brake_unlocked and event is InputEventMouseButton:
        var mb = event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT:
            is_braking = mb.pressed




func _apply_global_stats():
    laser_damage = Global.get_effective_damage()
    laser_range = Global.get_effective_range()
    move_speed = Global.get_effective_speed()
    laser_fire_rate = Global.mining_fire_rate
    barrier_count = Global.mining_barrier_count


    if drone_system:
        drone_system.init_drones()

    var drone_count = drone_system.positions.size() if drone_system else 0
    print("[Ship] 스탯 적용 — DMG:%.1f RNG:%.0f SPD:%.0f RATE:%.2f BAR:%d DRONE:%d DRONE_DMG:%.1f" % [
        laser_damage, laser_range, move_speed, laser_fire_rate, barrier_count, 
        drone_count, Global.get_effective_drone_damage()
    ])



func _get_resonance_damage(base_damage: float, grid_pos: Vector2i) -> float:

    if not Global.resonance_unlocked:
        return base_damage
    var dist = sqrt(float(grid_pos.x * grid_pos.x + grid_pos.y * grid_pos.y))
    var depth_ratio = 1.0 - clampf(dist / PlanetData.PLANET_RADIUS, 0.0, 1.0)
    return base_damage + base_damage * Global.get_resonance_add_ratio(depth_ratio)


func _apply_core_breaker(damage: float, grid_pos: Vector2i) -> float:

    if planet_data.get_block_type(grid_pos) == PlanetData.BlockType.CORE:
        var bonus = 0.0
        if Global.core_focus_unlocked:
            bonus += Global.CORE_FOCUS_BONUS
        if Global.core_breaker_unlocked:
            bonus += Global.core_breaker_bonus
        return damage + damage * bonus
    return damage


func start_entry():
    is_entering = true
    entry_timer = 0.0
    entry_target_pos = global_position

    var outward_dir = entry_target_pos.normalized()
    if outward_dir.length() < 0.1:
        outward_dir = Vector2(0, -1)
    entry_start_pos = entry_target_pos + outward_dir * ENTRY_OFFSET
    global_position = entry_start_pos

    var entry_dir = (entry_target_pos - entry_start_pos).normalized()
    visual_rotation = entry_dir.angle() + PI * 0.5
    print("[Ship] 🚀 진입 애니메이션 시작!")


func start_warp():
    if is_warping or is_dead:
        return
    is_warping = true
    warp_timer = 0.0

    if global_position.length() > 10:
        warp_dir = global_position.normalized()
    else:
        warp_dir = Vector2(0, -1)

    visual_rotation = warp_dir.angle() + PI * 0.5
    print("[Ship] 🚀 워프 이탈 시작!")

func _physics_process(delta):
    if is_dead:
        return


    update_visual_power_cache()


    if is_entering:
        entry_timer += delta
        var t = clampf(entry_timer / ENTRY_DURATION, 0.0, 1.0)

        var eased = 1.0 - pow(1.0 - t, 3.0)
        global_position = entry_start_pos.lerp(entry_target_pos, eased)
        ship_glow_phase += delta * 10.0
        if renderer: renderer.queue_redraw()
        if t >= 1.0:
            is_entering = false
            global_position = entry_target_pos
            entry_finished.emit()
            print("[Ship] 🚀 진입 완료!")
        return


    if is_warping:
        warp_timer += delta

        var t = warp_timer / WARP_DURATION
        var speed = WARP_ACCEL * t * t
        global_position += warp_dir * speed * delta
        ship_glow_phase += delta * 10.0
        if renderer: renderer.queue_redraw()
        return

    handle_movement()


    if Global.tutorial_active:
        var scene = get_parent()
        if scene and "spawn_position" in scene:
            var half_vp = get_viewport_rect().size * 0.5
            var sp = scene.spawn_position
            global_position.x = clampf(global_position.x, sp.x - half_vp.x, sp.x + half_vp.x)
            global_position.y = clampf(global_position.y, sp.y - half_vp.y, sp.y + half_vp.y)


    if spawn_protection_timer > 0:
        spawn_protection_timer -= delta
    else:
        check_block_collision()


    if collision_invincible_timer > 0:
        collision_invincible_timer -= delta
    if knockback_stun_timer > 0:
        knockback_stun_timer -= delta
    if is_dead:
        return
    handle_auto_mining(delta)

    ship_glow_phase += delta * 3.0
    laser_flash_timer = max(laser_flash_timer - delta, 0.0)
    laser_visible_timer = max(laser_visible_timer - delta, 0.0)
    drop_system.update_cooldown(delta)


    var expired_arcs: Array = []
    for i in range(electric_arcs.size()):
        electric_arcs[i].timer -= delta
        if electric_arcs[i].timer <= 0:
            expired_arcs.append(i)
    for i in range(expired_arcs.size() - 1, -1, -1):
        electric_arcs.remove_at(expired_arcs[i])


    var expired_chains: Array = []
    for i in range(chain_arcs.size()):
        chain_arcs[i].timer -= delta
        if chain_arcs[i].timer <= 0:
            expired_chains.append(i)
    for i in range(expired_chains.size() - 1, -1, -1):
        chain_arcs.remove_at(expired_chains[i])


    for i in range(shockwave_rings.size() - 1, -1, -1):
        shockwave_rings[i].radius += SHOCKWAVE_RING_SPEED * delta
        var progress = shockwave_rings[i].radius / shockwave_rings[i].max_radius
        shockwave_rings[i].alpha = 0.8 * (1.0 - progress)
        if shockwave_rings[i].radius >= shockwave_rings[i].max_radius:
            shockwave_rings.remove_at(i)


    if mega_system:
        mega_system.update(delta)


    if Global.drone_unlocked and drone_system:
        drone_system.update(delta)


    if overdrive_system:
        overdrive_system.update(delta)


    if Global.barrier_regen_unlocked:
        barrier_regen_timer += delta
        if barrier_regen_timer >= Global.BARRIER_REGEN_INTERVAL:
            barrier_regen_timer = 0.0
            barrier_count += 1
            print("[🛡️] 배리어 재생! 현재: %d" % barrier_count)


    if Global.combo_unlocked:
        var current_combo = Global.combo_count
        if current_combo > last_combo_count and current_combo > 0:

            combo_popup_value = current_combo
            combo_popup_timer = COMBO_POPUP_DURATION
            combo_popup_scale = 1.5

            combo_popup_is_milestone = current_combo in COMBO_MILESTONES
            if combo_popup_is_milestone:
                ScreenFX.combo_milestone()
        last_combo_count = current_combo

        if combo_popup_timer > 0:
            combo_popup_timer -= delta

            combo_popup_scale = lerpf(combo_popup_scale, 1.0, delta * 10.0)


    drop_system.collect_nearby_drops()

    if renderer: renderer.queue_redraw()


var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 5.0

func apply_knockback(force: Vector2):
    knockback_velocity += force


const DEAD_ZONE: float = 30.0
const MAX_INPUT_DIST: float = 350.0


var visual_rotation: float = 0.0
const ROTATION_SPEED: float = 8.0

func handle_movement():

    if knockback_stun_timer > 0:
        velocity = knockback_velocity
        if knockback_velocity.length() > 1.0:
            knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * get_physics_process_delta_time() * knockback_velocity.length())
        move_and_slide()
        return


    if is_braking:
        velocity = Vector2.ZERO

        knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 
            KNOCKBACK_DECAY * get_physics_process_delta_time() * knockback_velocity.length() * 3.0)
        move_and_slide()
        return

    var viewport_size = get_viewport_rect().size
    var screen_center = viewport_size * 0.5
    var mouse_screen = get_viewport().get_mouse_position()


    var offset = mouse_screen - screen_center
    var distance = offset.length()

    if distance < DEAD_ZONE:

        velocity = velocity.move_toward(Vector2.ZERO, move_speed * 0.15)
    else:

        var speed_ratio = clampf((distance - DEAD_ZONE) / (MAX_INPUT_DIST - DEAD_ZONE), 0.0, 1.0)
        var _od_active = overdrive_system and overdrive_system.active
        var effective_speed = (move_speed + Global.overdrive_speed_bonus) if _od_active else move_speed
        var target_speed = effective_speed * speed_ratio
        velocity = offset.normalized() * target_speed

        last_move_dir = offset.normalized()

        var target_angle = offset.angle() + PI * 0.5
        visual_rotation = lerp_angle(visual_rotation, target_angle, ROTATION_SPEED * get_physics_process_delta_time())


    if knockback_velocity.length() > 1.0:
        velocity += knockback_velocity
        knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * get_physics_process_delta_time() * knockback_velocity.length())

    move_and_slide()


func check_block_collision():
    if planet_data == null:
        return


    var my_grid = planet_data.world_to_grid(global_position)

    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var check = Vector2i(my_grid.x + dx, my_grid.y + dy)
            if not planet_data.has_block(check):
                continue


            var block_center = planet_data.grid_to_world(check)
            var dist = global_position.distance_to(block_center)


            var collision_dist = PlanetData.BLOCK_SIZE * 0.5 + COLLISION_RADIUS

            if dist < collision_dist:

                var btype = planet_data.get_block_type(check)
                if btype == PlanetData.BlockType.THORN:
                    _on_thorn_collision()
                    return
                _on_block_collision()
                return


const KNOCKBACK_FORCE: float = 600.0
const KNOCKBACK_INVINCIBLE: float = 0.4
const KNOCKBACK_STUN: float = 0.3
var collision_invincible_timer: float = 0.0
var knockback_stun_timer: float = 0.0

func _on_block_collision():

    if collision_invincible_timer > 0:
        return


    if _is_godmode():
        var push_dir = velocity.normalized() * -1
        if push_dir.length() < 0.1:
            push_dir = Vector2(0, -1)
        global_position += push_dir * 20
        apply_knockback(push_dir * KNOCKBACK_FORCE)
        collision_invincible_timer = KNOCKBACK_INVINCIBLE
        knockback_stun_timer = KNOCKBACK_STUN
        Global.request_shake(2.0, 0.1)
        return

    if barrier_count > 0:

        barrier_count -= 1
        sortie_stats.barriers_used += 1
        SoundManager.play("barrier_hit")
        print("[Ship] 배리어 소모! 남은: %d" % barrier_count)

        var push_dir = velocity.normalized() * -1
        if push_dir.length() < 0.1:
            push_dir = Vector2(0, -1)
        global_position += push_dir * 20
        apply_knockback(push_dir * KNOCKBACK_FORCE)
        collision_invincible_timer = KNOCKBACK_INVINCIBLE
        knockback_stun_timer = KNOCKBACK_STUN
        Global.request_shake(3.0, 0.15)
        return


    if Global.tutorial_active:
        var push_dir = velocity.normalized() * -1
        if push_dir.length() < 0.1:
            push_dir = Vector2(0, -1)
        global_position += push_dir * 30
        apply_knockback(push_dir * KNOCKBACK_FORCE * 1.5)
        collision_invincible_timer = KNOCKBACK_INVINCIBLE * 2.0
        knockback_stun_timer = KNOCKBACK_STUN
        Global.request_shake(3.0, 0.2)
        SoundManager.play("barrier_hit")
        return


    is_dead = true
    visible = false
    SoundManager.play("barrier_break")
    Global.request_shake(5.0, 0.4)
    drop_system.spawn_crash_explosion()
    print("[Ship] 블록 충돌! 즉사!")

    var scene = get_parent()
    if scene.has_method("on_ship_crashed"):
        scene.on_ship_crashed()



func _on_thorn_collision():

    var nearest_core = planet_data.get_nearest_alive_core(
        planet_data.world_to_grid(global_position)
    )
    var push_dir: Vector2
    if nearest_core.is_empty():

        push_dir = global_position.normalized()
    else:

        var core_world = planet_data.grid_to_world(nearest_core.center)
        push_dir = (global_position - core_world).normalized()
    if push_dir.length() < 0.1:
        push_dir = Vector2(0, -1)


    var scan_pos = global_position
    var bs = float(PlanetData.BLOCK_SIZE)
    for i in range(1, 30):
        scan_pos = global_position + push_dir * (bs * i)
        var grid = planet_data.world_to_grid(scan_pos)
        if not planet_data.has_block(grid):

            global_position = planet_data.grid_to_world(grid)
            break


    if collision_invincible_timer > 0:
        return


    apply_knockback(push_dir * KNOCKBACK_FORCE * 0.75)
    collision_invincible_timer = KNOCKBACK_INVINCIBLE
    knockback_stun_timer = 0.15
    Global.request_shake(2.0, 0.1)



func handle_auto_mining(delta):
    if planet_data == null:
        return

    if _is_attack_disabled():
        has_target = false
        return

    laser_timer += delta

    var _od_active = overdrive_system and overdrive_system.active
    var effective_fire_rate = laser_fire_rate / (Global.overdrive_fire_mult if _od_active else 1.0)
    if laser_timer >= effective_fire_rate:
        laser_timer = 0.0
        auto_fire_laser()


var multi_targets: Array = []


var electric_arcs: Array = []
const ARC_DURATION: float = 0.15

func auto_fire_laser():
    var grid_range = int(ceil(laser_range / PlanetData.BLOCK_SIZE)) + 1
    var my_grid = planet_data.world_to_grid(global_position)
    var laser_count = Global.multi_laser_count



    var candidates: Array = []
    for dx in range( - grid_range, grid_range + 1):
        for dy in range( - grid_range, grid_range + 1):
            var check = Vector2i(my_grid.x + dx, my_grid.y + dy)
            if not planet_data.has_block(check):
                continue
            var block_world = planet_data.grid_to_world(check)
            var dist_sq = global_position.distance_squared_to(block_world)
            if dist_sq < laser_range * laser_range:
                candidates.append({"pos": check, "dist_sq": dist_sq, "world": block_world})

    candidates.sort_custom( func(a, b): return a.dist_sq < b.dist_sq)


    var hit_count = mini(laser_count, candidates.size())
    var any_destroyed = false
    multi_targets.clear()

    if hit_count == 0:
        has_target = false
        return


    is_charged_shot = false
    is_crit_shot = false
    if Global.charged_shot_unlocked:
        shot_counter += 1
        if shot_counter >= Global.charged_shot_interval:
            shot_counter = 0
            is_charged_shot = true

    for i in range(hit_count):
        var target = candidates[i]
        var pos = target.pos

        if i == 0:

            has_target = true
            target_block = pos
            target_world_pos = target.world
        else:

            multi_targets.append(target.world)

        if planet_renderer and planet_renderer.has_method("register_hit"):
            planet_renderer.register_hit(pos)

        var dmg = _get_resonance_damage(laser_damage, pos)
        dmg = _apply_core_breaker(dmg, pos)
        var base_dmg = dmg


        if is_charged_shot:
            dmg += laser_damage * Global.charged_shot_bonus
            is_crit_shot = true
            drop_system.spawn_crit_effect(target.world)
            Global.request_shake(2.0, 0.1)
            sortie_stats.charged_shots += 1
            sortie_stats.dmg_charged_bonus += dmg - base_dmg


        var is_crit = false
        var pre_crit_dmg = dmg
        if Global.critical_unlocked and randf() < Global.critical_chance:
            dmg += laser_damage * Global.critical_bonus
            is_crit = true
            sortie_stats.crits_landed += 1
            sortie_stats.dmg_crit_bonus += dmg - pre_crit_dmg
            if not is_crit_shot:
                is_crit_shot = true
                drop_system.spawn_crit_effect(target.world)
                Global.request_shake(2.0, 0.1)

        sortie_stats.dmg_laser += dmg
        var result = planet_data.damage_block(pos, dmg)
        if result.destroyed:
            any_destroyed = true
            _on_block_destroyed(pos, result.type, result.resource)


        if Global.aoe_mining_unlocked:
            var aoe_dmg = dmg * 0.3
            for adj in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
                var adj_pos = pos + adj
                if planet_data.has_block(adj_pos):
                    if planet_renderer:
                        planet_renderer.register_hit(adj_pos)
                    sortie_stats.dmg_aoe += aoe_dmg
                    var a_res = planet_data.damage_block(adj_pos, aoe_dmg, true)
                    if a_res.destroyed:
                        any_destroyed = true
                        _on_block_destroyed(adj_pos, a_res.type, a_res.resource)

        if not result.destroyed and result.get("shielded", false):
            drop_system.on_shield_hit(target.world)

    laser_flash_timer = 0.1
    laser_visible_timer = LASER_VISIBLE_DURATION

    sortie_stats.shots_fired += 1


    if any_destroyed:
        Global.on_combo_hit()


    SoundManager.play("laser_fire")
    if is_crit_shot:
        SoundManager.play("critical_hit")


    if Global.chain_lightning_unlocked and hit_count > 0:
        var first_target = candidates[0]
        _trigger_chain_lightning(first_target.pos, first_target.world)


func _on_block_destroyed(pos: Vector2i, block_type: int, resource: float):
    var is_core = block_type == PlanetData.BlockType.CORE
    var is_electric = block_type == PlanetData.BlockType.ELECTRIC
    var is_gold = block_type == PlanetData.BlockType.GOLD
    var world_pos = planet_data.grid_to_world(pos)


    SoundManager.play("block_destroy")


    var scene = get_parent()
    if scene.has_method("record_destroyed"):
        scene.record_destroyed(is_core)

    if is_core:

        drop_system.spawn_core_explosion(world_pos, pos)
        Global.request_shake(CORE_SHAKE_INTENSITY, CORE_SHAKE_DURATION)
        ScreenFX.core_destroy()
        drop_system.spawn_resource_drop(world_pos, resource, block_type)
    elif is_electric and Global.electric_unlocked:

        drop_system.spawn_electric_particles(world_pos)
        Global.request_shake(NORMAL_SHAKE_INTENSITY * 1.5, NORMAL_SHAKE_DURATION * 1.5)
        drop_system.spawn_resource_drop(world_pos, resource, block_type)
        _trigger_electric_chain(pos, world_pos)
    elif is_gold and Global.gold_unlocked:

        drop_system.spawn_gold_particles(world_pos)
        Global.request_shake(NORMAL_SHAKE_INTENSITY * 1.2, NORMAL_SHAKE_DURATION)
        drop_system.spawn_resource_drop(world_pos, resource, block_type)
    elif is_gold and not Global.gold_unlocked:

        drop_system.spawn_destroy_particles(world_pos, pos, false)
        var shake_mult = 1.0 + get_visual_power() * 1.5
        Global.request_shake(NORMAL_SHAKE_INTENSITY * shake_mult, NORMAL_SHAKE_DURATION)
        drop_system.spawn_resource_drop(world_pos, resource, PlanetData.BlockType.NORMAL)
    else:

        drop_system.spawn_destroy_particles(world_pos, pos, false)
        var shake_mult = 1.0 + get_visual_power() * 1.5
        Global.request_shake(NORMAL_SHAKE_INTENSITY * shake_mult, NORMAL_SHAKE_DURATION)
        drop_system.spawn_resource_drop(world_pos, resource, block_type)


    if mega_system:
        mega_system.on_block_destroyed()


    if Global.shockwave_unlocked and not shockwave_firing:
        shockwave_counter += 1
        if shockwave_counter >= Global.shockwave_interval:
            shockwave_counter = 0
            _trigger_shockwave()


    if overdrive_system:
        overdrive_system.on_block_destroyed()




func _trigger_electric_chain(origin_pos: Vector2i, origin_world: Vector2):
    SoundManager.play("electric_chain")

    Global.on_combo_hit()
    var chain_results = planet_data.electric_chain(
        origin_pos, 
        laser_damage, 
        Global.electric_range, 
        Global.electric_chain_depth
    )


    var destroyed_positions: Array = []
    for r in chain_results:
        if r.destroyed:
            destroyed_positions.append(r.pos)
    if destroyed_positions.size() > 0:
        planet_data._update_edges_batch(destroyed_positions)


    sortie_stats.dmg_electric += laser_damage * chain_results.size()
    for r in chain_results:
        if r.destroyed:
            sortie_stats.kills_electric += 1

    var scene = get_parent()
    var particle_count = 0
    for result in chain_results:
        var target_world = planet_data.grid_to_world(result.pos)


        electric_arcs.append({
            "from": origin_world, 
            "to": target_world, 
            "timer": ARC_DURATION, 
        })

        if planet_renderer and planet_renderer.has_method("register_hit"):
            planet_renderer.register_hit(result.pos)

        if result.destroyed:

            if scene.has_method("record_destroyed"):
                scene.record_destroyed(result.type == PlanetData.BlockType.CORE)

            var drop_type = result.type
            if result.type == PlanetData.BlockType.GOLD and not Global.gold_unlocked:
                drop_type = PlanetData.BlockType.NORMAL
            drop_system.spawn_resource_drop(target_world, result.resource, drop_type)

            if particle_count < 8:
                drop_system.spawn_chain_destroy_particle(target_world)
                particle_count += 1





func _trigger_chain_lightning(start_pos: Vector2i, start_world: Vector2):
    SoundManager.play("chain_lightning")
    var jumps = Global.chain_lightning_jumps
    var damage_base = laser_damage * 0.5
    var current_pos = start_pos
    var current_world = start_world
    var visited: Dictionary = {start_pos: true}

    for _j in range(jumps):

        var candidates: Array = []
        for dx in range(-4, 5):
            for dy in range(-4, 5):
                if dx == 0 and dy == 0:
                    continue
                var dist = abs(dx) + abs(dy)
                if dist > 4:
                    continue
                var check = Vector2i(current_pos.x + dx, current_pos.y + dy)
                if visited.has(check):
                    continue
                if not planet_data.has_block(check):
                    continue
                candidates.append({"pos": check, "dist": dist})

        if candidates.is_empty():
            break



        var weighted: Array = []
        for c in candidates:
            var weight = 5 - c.dist
            for _w in range(weight):
                weighted.append(c)

        var chosen = weighted[randi() % weighted.size()]
        var best_pos = chosen.pos
        var best_world = planet_data.grid_to_world(best_pos)


        chain_arcs.append({
            "from": current_world, 
            "to": best_world, 
            "timer": CHAIN_ARC_DURATION, 
        })


        if planet_renderer and planet_renderer.has_method("register_hit"):
            planet_renderer.register_hit(best_pos)

        var damage = _get_resonance_damage(damage_base, best_pos)
        damage = _apply_core_breaker(damage, best_pos)
        sortie_stats.dmg_chain += damage
        var result = planet_data.damage_block(best_pos, damage, true)
        if result.destroyed:
            _on_block_destroyed(best_pos, result.type, result.resource)
        elif result.get("shielded", false):
            drop_system.on_shield_hit(best_world)


        visited[best_pos] = true
        current_pos = best_pos
        current_world = best_world






var shockwave_rings: Array = []
const SHOCKWAVE_RING_COLOR: = Color(1.0, 0.85, 0.2)
const SHOCKWAVE_RING_SPEED: float = 600.0
const MAX_SHOCKWAVE_RINGS: int = 3

func _trigger_shockwave():
    shockwave_firing = true
    sortie_stats.shockwave_count += 1

    var my_grid = planet_data.world_to_grid(global_position)
    var range_val = Global.shockwave_range
    var range_sq = range_val * range_val
    var converted_count: int = 0

    for dx in range( - range_val, range_val + 1):
        for dy in range( - range_val, range_val + 1):
            if dx * dx + dy * dy > range_sq:
                continue
            var pos = Vector2i(my_grid.x + dx, my_grid.y + dy)
            if not planet_data.has_block(pos):
                continue


            if randf() < SHOCKWAVE_GOLD_CHANCE:
                if planet_data.convert_to_gold(pos):
                    converted_count += 1
                    planet_renderer.register_gold_convert(pos)

    shockwave_firing = false


    var max_r = range_val * PlanetData.BLOCK_SIZE
    if shockwave_rings.size() >= MAX_SHOCKWAVE_RINGS:
        shockwave_rings.remove_at(0)
    shockwave_rings.append({"radius": 5.0, "max_radius": max_r, "alpha": 0.8})
    Global.request_shake(2.0 + get_visual_power() * 2.0, 0.15)
    SoundManager.play("block_destroy")
    ScreenFX.shockwave_activate()

    if converted_count > 0:
        print("[Ship] 🌀 충격파: %d블록 금광 변환!" % converted_count)
