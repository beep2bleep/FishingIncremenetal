extends Node







const IS_DEMO: bool = false
const DEMO_BOSS_CORE_ID: int = 12
var demo_ending_shown: bool = false
var ending_shown: bool = false
var epilogue_shown: bool = false

signal cargo_full


var currency: float = 0.0
var core_currency: int = 0
var planet_cleared: bool = false
var planet_fully_destroyed: bool = false
var planet_mastery_unlocked: bool = false
var free_planet_mode: bool = false


var planet_data: PlanetData = null
var sortie_resources: float = 0.0
var sortie_ore_count: int = 0


var cargo_capacity: float = 15.0
var cargo_base_capacity: float = 15.0
var cargo_bonus: float = 0.0


var ore_sell_rate: float = 1.0


var fuel_capacity: float = 30.0
var fuel_base_capacity: float = 30.0
var fuel_bonus: float = 0.0
var fuel_current: float = 30.0
var fuel_rate: float = 1.0
var fuel_efficiency: float = 1.0
var fuel_loss_reduction: float = 0.0
signal fuel_empty
var sortie_blocks_destroyed: int = 0
var sortie_cores_destroyed: int = 0
var sortie_combat_stats: Dictionary = {}
var total_resources: float = 0.0
var sortie_count: int = 0
var total_play_time: float = 0.0
var tutorial_shown: bool = false
var tutorial_active: bool = false


var sortie_history: Array = []
var planet_snapshots: Array = []
var _sortie_nodes_purchased: Array = []



var mining_damage_flat: float = 0.0
var mining_season_dmg_mult: float = 1.0
var season_dmg_boosts: Array = []
var mining_range_bonus: float = 0.0
var mining_speed_bonus: float = 0.0
var mining_time_bonus: float = 0.0
var mining_fire_rate: float = 0.8
var mining_barrier_count: int = 0
var mining_season_res_mult: float = 1.0
var season_res_boosts: Array = []
var mining_resource_flat: float = 0.0
var gold_bonus_flat: float = 0.0


var thorn_knockback_resist: float = 0.0
var overheat_resist: float = 0.0
var wind_resist: float = 0.0
var cold_resist: float = 0.0
var pickup_range: float = 64.0
var instant_collect: bool = false


var critical_unlocked: bool = false
var critical_chance: float = 0.2
var critical_bonus: float = 2.0



var charged_shot_unlocked: bool = false
var charged_shot_interval: int = 5
var charged_shot_bonus: float = 2.0


var electric_unlocked: bool = false
var gold_unlocked: bool = false
var multi_laser_count: int = 1
var electric_range: int = 2
var electric_chain_depth: int = 1


var drone_unlocked: bool = false
var drone_count: int = 1
var drone_fixed_damage: float = 8.0
var drone_fire_rate_bonus: float = 0.0
var drone_pierce: int = 1

var drone_sync_unlocked: bool = false
var drone_sync_ratio: float = 0.15
var drone_crit_unlocked: bool = false
var drone_crit_chance: float = 0.15
var drone_crit_bonus: float = 2.0

var drone_damage_ratio: float = 0.3
var chain_lightning_unlocked: bool = false
var chain_lightning_jumps: int = 3
var resonance_unlocked: bool = false
var resonance_max_bonus: float = 1.0


var mega_laser_unlocked: bool = false
var mega_laser_gauge_need: int = 30
var mega_laser_duration: float = 5.0
var shockwave_unlocked: bool = false
var shockwave_interval: int = 15
var shockwave_range: int = 6


var core_breaker_unlocked: bool = false
var core_breaker_bonus: float = 2.0


var overdrive_unlocked: bool = false
var overdrive_kill_need: int = 50
var overdrive_duration: float = 3.0
var overdrive_speed_mult: float = 2.0
var overdrive_speed_bonus: float = 300.0
var overdrive_fire_mult: float = 3.0


var combo_unlocked: bool = false
var combo_flat_per_stack: float = 0.0
var combo_count: int = 0
var combo_max_reached: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW: float = 1.5
const COMBO_MAX: int = 50



var minimap_unlocked: bool = false
var spawn_points_available: int = 1
var core_detect_unlocked: bool = false
var brake_unlocked: bool = false
var barrier_regen_unlocked: bool = false
var aoe_mining_unlocked: bool = false
var resume_pos_unlocked: bool = false
var resume_position: Vector2 = Vector2.ZERO
var resume_position_valid: bool = false
var core_focus_unlocked: bool = false
const CORE_FOCUS_BONUS: float = 1.0
const BARRIER_REGEN_INTERVAL: float = 30.0
var spawn_direction_unlocked: bool = false
var return_shortcut_unlocked: bool = false
var infinite_fuel_unlocked: bool = false
var center_unlock_unlocked: bool = false
var mastery_popup_shown: bool = false


var tree_view_offset: Vector2 = Vector2.ZERO
var tree_view_zoom: float = 0.8
var tree_view_saved: bool = false

var perm_damage_accumulated: float = 0.0
var perm_time_accumulated: float = 0.0


var total_cores_destroyed: int = 0
const CORE_SCALING_BASE: float = 1.5


func get_core_difficulty_mult() -> float:
    return pow(CORE_SCALING_BASE, total_cores_destroyed)


var screen_shake_enabled: bool = true
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0


var node_levels: Dictionary = {}
var nodes: Dictionary = {}


func get_node_level(node_id: String) -> int:
    return node_levels.get(node_id, 0)


func is_node_purchased(node_id: String) -> bool:
    return node_levels.get(node_id, 0) >= 1


func is_node_maxed(node_id: String) -> bool:
    var node = nodes.get(node_id)
    if not node:
        return false
    return node_levels.get(node_id, 0) >= node.get("max_level", 1)



const PHASE_COST_MULT: Dictionary = {1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0}


func get_node_cost(node_id: String) -> float:
    var node = nodes.get(node_id)
    if not node:
        return 0
    var level = get_node_level(node_id)
    var base = float(node.get("base_cost", node.get("cost", 0)))
    var mult = node.get("cost_mult", 1.0)
    var phase_mult = PHASE_COST_MULT.get(node.get("phase", 1), 1.0)
    return base * pow(mult, level) * phase_mult





func _ready():
    initialize_game()
    set_process(true)
    _setup_custom_cursor()


func _setup_custom_cursor():
    var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    for x in range(2, 6):
        for y in range(2, 6):
            var dist = Vector2(x - 3.5, y - 3.5).length()
            if dist < 2.0:
                img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.7))
    var tex = ImageTexture.create_from_image(img)
    Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, Vector2(4, 4))

func _process(delta):
    total_play_time += delta
    if shake_timer > 0:
        shake_timer -= delta
        if shake_timer <= 0:
            shake_timer = 0.0
            shake_intensity = 0.0

const MAX_SHAKE_INTENSITY: float = 6.0

func request_shake(intensity: float, duration: float):
    if not screen_shake_enabled:
        return
    intensity = minf(intensity, MAX_SHAKE_INTENSITY)
    if intensity > shake_intensity:
        shake_intensity = intensity
        shake_duration = duration
        shake_timer = duration

func get_shake_offset() -> Vector2:
    if shake_timer <= 0:
        return Vector2.ZERO
    var decay = shake_timer / shake_duration
    var offset_x = randf_range( - shake_intensity, shake_intensity) * decay
    var offset_y = randf_range( - shake_intensity, shake_intensity) * decay
    return Vector2(offset_x, offset_y)

func initialize_game():
    currency = 0
    core_currency = 0
    total_play_time = 0.0
    planet_cleared = false
    planet_fully_destroyed = false
    planet_mastery_unlocked = false
    tutorial_shown = false
    tutorial_active = false
    node_levels.clear()
    sortie_history.clear()
    planet_snapshots.clear()
    _sortie_nodes_purchased.clear()
    reset_mining_stats()
    initialize_nodes()

    node_levels["start"] = 1

func reset_mining_stats():

    mining_damage_flat = 0.0
    mining_season_dmg_mult = 1.0
    season_dmg_boosts.clear()
    mining_range_bonus = 0.0
    mining_speed_bonus = 0.0
    mining_time_bonus = 0.0
    mining_fire_rate = 0.8
    mining_barrier_count = 0
    mining_season_res_mult = 1.0
    season_res_boosts.clear()
    mining_resource_flat = 0.0
    gold_bonus_flat = 0.0
    thorn_knockback_resist = 0.0
    overheat_resist = 0.0
    wind_resist = 0.0
    cold_resist = 0.0
    pickup_range = 64.0
    instant_collect = false


    cargo_base_capacity = 15.0
    cargo_bonus = 0.0
    cargo_capacity = 15.0


    ore_sell_rate = 1.0


    fuel_base_capacity = 30.0
    fuel_bonus = 0.0
    fuel_capacity = 30.0
    fuel_current = 30.0
    fuel_rate = 1.0
    fuel_efficiency = 1.0
    fuel_loss_reduction = 0.0


    critical_unlocked = false
    critical_chance = 0.2
    critical_bonus = 2.0


    charged_shot_unlocked = false
    charged_shot_interval = 5
    charged_shot_bonus = 2.0


    electric_unlocked = false
    gold_unlocked = false
    multi_laser_count = 1
    electric_range = 2
    electric_chain_depth = 1


    drone_unlocked = false
    drone_count = 1
    drone_fixed_damage = 8.0
    drone_fire_rate_bonus = 0.0
    drone_pierce = 1
    drone_damage_ratio = 0.3
    drone_sync_unlocked = false
    drone_sync_ratio = 0.15
    drone_crit_unlocked = false
    drone_crit_chance = 0.15
    drone_crit_bonus = 2.0
    chain_lightning_unlocked = false
    chain_lightning_jumps = 3
    resonance_unlocked = false
    resonance_max_bonus = 1.0


    mega_laser_unlocked = false
    mega_laser_gauge_need = 30
    mega_laser_duration = 5.0
    shockwave_unlocked = false
    shockwave_interval = 15
    shockwave_range = 6


    core_breaker_unlocked = false
    core_breaker_bonus = 2.0


    overdrive_unlocked = false
    overdrive_kill_need = 50
    overdrive_duration = 3.0
    overdrive_speed_mult = 2.0
    overdrive_fire_mult = 3.0


    combo_unlocked = false
    combo_flat_per_stack = 0.0
    combo_count = 0
    combo_timer = 0.0




    minimap_unlocked = false
    core_detect_unlocked = false
    brake_unlocked = false
    barrier_regen_unlocked = false
    aoe_mining_unlocked = false
    resume_pos_unlocked = false
    resume_position = Vector2.ZERO
    resume_position_valid = false
    core_focus_unlocked = false
    spawn_direction_unlocked = false
    spawn_points_available = 1
    return_shortcut_unlocked = false
    infinite_fuel_unlocked = false
    center_unlock_unlocked = false
    perm_damage_accumulated = 0.0
    perm_time_accumulated = 0.0
    total_cores_destroyed = 0



func initialize_planet():
    planet_data = PlanetData.new()
    await planet_data.generate_async(get_tree())
    sortie_count = 0
    total_resources = 0
    print("[Global] 행성 생성: %d 블록, %d 코어" % [planet_data.get_total_blocks(), planet_data.get_alive_cores()])


func initialize_planet_with_progress(callback: Callable):
    planet_data = PlanetData.new()
    await planet_data.generate_async_with_progress(get_tree(), callback)
    sortie_count = 0
    total_resources = 0
    print("[Global] 행성 생성: %d 블록, %d 코어" % [planet_data.get_total_blocks(), planet_data.get_alive_cores()])

var _sortie_dps_start: float = 0.0
var _sortie_start_time: int = 0

func start_sortie():
    sortie_resources = 0
    sortie_ore_count = 0
    sortie_blocks_destroyed = 0
    sortie_cores_destroyed = 0
    sortie_count += 1

    if tutorial_shown:
        SteamManager.unlock("ACH_FIRST_SORTIE")
    reset_combo()
    _sortie_nodes_purchased.clear()
    _sortie_dps_start = get_effective_damage()
    _sortie_start_time = Time.get_ticks_msec()


    cargo_capacity = cargo_base_capacity + cargo_bonus


    fuel_capacity = fuel_base_capacity + fuel_bonus
    fuel_current = fuel_capacity

    print("[Global] 출항 #%d (화물칸: %.0f, 연료: %.1f초)" % [sortie_count, cargo_capacity, fuel_capacity])

func end_sortie():
    var sell_amount = sortie_resources * ore_sell_rate
    currency += sell_amount
    total_resources += sell_amount



    _reconcile_core_currency()

    if planet_data:
        planet_data.revert_converted_gold()
        planet_data.regenerate_around_cores()

    print("[Global] 출항 #%d 종료: 광석 %.0f × %.1f배 = 화폐 %.0f, 블록 %d" % [
        sortie_count, sortie_resources, ore_sell_rate, sell_amount, sortie_blocks_destroyed
    ])

    if planet_data and planet_data.get_total_blocks() == 0 and not planet_fully_destroyed:
        planet_fully_destroyed = true
        print("[Global] 💥 행성 완전 소멸! 블록 0개")


    _record_sortie_stats()
    _check_zone_clear_achievements()

    save_game()


func end_sortie_async(tree: SceneTree):
    var sell_amount = sortie_resources * ore_sell_rate
    currency += sell_amount
    total_resources += sell_amount
    _reconcile_core_currency()

    if planet_data:
        planet_data.revert_converted_gold()
        await planet_data.regenerate_around_cores_async(tree)

    print("[Global] 출항 #%d 종료: 광석 %.0f × %.1f배 = 화폐 %.0f, 블록 %d" % [
        sortie_count, sortie_resources, ore_sell_rate, sell_amount, sortie_blocks_destroyed
    ])
    if planet_data and planet_data.get_total_blocks() == 0 and not planet_fully_destroyed:
        planet_fully_destroyed = true
        print("[Global] 💥 행성 완전 소멸! 블록 0개")
    _record_sortie_stats()
    _check_zone_clear_achievements()



func _check_zone_clear_achievements():
    if not planet_data:
        return
    var zone_ach = {
        PlanetData.Zone.SPRING: "ACH_CLEAR_SPRING", 
        PlanetData.Zone.SUMMER: "ACH_CLEAR_SUMMER", 
        PlanetData.Zone.AUTUMN: "ACH_CLEAR_AUTUMN", 
        PlanetData.Zone.WINTER: "ACH_CLEAR_WINTER", 
    }
    for zone in zone_ach:
        if planet_data.get_zone_destruction_ratio(zone) >= 1.0:
            SteamManager.unlock(zone_ach[zone])


func record_core_fully_destroyed():
    core_currency += 1
    total_cores_destroyed += 1
    sortie_cores_destroyed += 1
    print("[Global] ★ 코어 완전 파괴! 코어 재화: %d, 총 파괴: %d, 난이도 ×%.1f" % [
        core_currency, total_cores_destroyed, get_core_difficulty_mult()
    ])

    if total_cores_destroyed == 1:
        SteamManager.unlock("ACH_FIRST_CORE")


    if planet_data and planet_data.get_alive_cores() == 0 and not planet_cleared:
        planet_cleared = true
        SteamManager.unlock("ACH_FINAL_BOSS")
        print("[Global] 🌟 행성 정복! 모든 코어 파괴 완료")


func _reconcile_core_currency():
    if not planet_data:
        return


    var actual_dead = 0
    for core in planet_data.cores:
        if not core.alive:
            actual_dead += 1


    var spent = 0
    for uid in purchased_core_upgrades:
        var upgrade = core_upgrades.get(uid)
        if upgrade:
            spent += upgrade.cost


    var expected_currency = actual_dead - spent


    if total_cores_destroyed < actual_dead:
        print("[🔒 Reconcile] total_cores_destroyed 보정: %d → %d" % [total_cores_destroyed, actual_dead])
        total_cores_destroyed = actual_dead


    if core_currency < expected_currency:
        var missing = expected_currency - core_currency
        print("[🔒 Reconcile] 코어 재화 보정: %d → %d (+%d 누락분)" % [core_currency, expected_currency, missing])
        core_currency = expected_currency


    if planet_data.get_alive_cores() == 0 and not planet_cleared:
        planet_cleared = true
        print("[🔒 Reconcile] planet_cleared 보정: true")

func gain_mining_resource(amount: float, is_core: bool = false):

    if sortie_ore_count >= cargo_capacity and not is_core:
        return


    if not is_core:
        sortie_ore_count += 1


    var combo_add = combo_flat_per_stack * combo_count if combo_unlocked else 0.0
    var final = (amount + mining_resource_flat + combo_add) * _calc_season_res_mult()
    sortie_resources += final


    if not is_core and sortie_ore_count >= cargo_capacity:
        emit_signal("cargo_full")


func consume_fuel(delta: float) -> bool:
    if fuel_current <= 0:
        return false
    fuel_current -= fuel_rate * fuel_efficiency * delta
    if fuel_current <= 0:
        fuel_current = 0
        emit_signal("fuel_empty")
        return false
    return true


func apply_fuel_penalty():
    var keep_ratio = fuel_loss_reduction
    var lost = sortie_resources * (1.0 - keep_ratio)
    sortie_resources -= lost
    print("[⛽] 연료 고갈! 자원 %.0f 손실 (보존 %.0f%%)" % [lost, keep_ratio * 100])


func get_fuel_ratio() -> float:
    if fuel_capacity <= 0:
        return 0.0
    return clampf(fuel_current / fuel_capacity, 0.0, 1.0)


func on_combo_hit():
    if not combo_unlocked:
        return
    combo_count = mini(combo_count + 1, COMBO_MAX)
    if combo_count > combo_max_reached:
        combo_max_reached = combo_count
    combo_timer = COMBO_WINDOW


func update_combo(delta: float):
    if not combo_unlocked or combo_count == 0:
        return
    combo_timer -= delta
    if combo_timer <= 0:
        combo_count = 0
        combo_timer = 0.0


func reset_combo():
    combo_count = 0
    combo_max_reached = 0
    combo_timer = 0.0

func record_block_destroyed(is_core: bool):
    sortie_blocks_destroyed += 1





func _record_sortie_stats():
    var elapsed_ms = Time.get_ticks_msec() - _sortie_start_time
    var dps_end = get_effective_damage()


    var phase = 1
    if is_node_purchased("overdrive1"): phase = 5
    elif is_node_purchased("multi2"): phase = 4
    elif is_node_purchased("drone_dmg"): phase = 3
    elif is_node_purchased("multi1"): phase = 2


    var weapons: Array = ["laser"]
    if is_node_purchased("critical_hit"): weapons.append("critical")
    if is_node_purchased("charged_shot"): weapons.append("charged_shot")
    if is_node_purchased("electric_unlock"): weapons.append("electric")
    if drone_unlocked: weapons.append("drone")
    if chain_lightning_unlocked: weapons.append("chain_lightning")
    if mega_laser_unlocked: weapons.append("mega_laser")
    if shockwave_unlocked: weapons.append("shockwave")
    if overdrive_unlocked: weapons.append("overdrive")
    if core_breaker_unlocked: weapons.append("core_breaker")
    if combo_unlocked: weapons.append("combo")

    var record = {
        "sortie_num": sortie_count, 
        "resources": sortie_resources, 
        "blocks": sortie_blocks_destroyed, 
        "cores": sortie_cores_destroyed, 
        "nodes_purchased": _sortie_nodes_purchased.duplicate(), 
        "dps_start": _sortie_dps_start, 
        "dps_end": dps_end, 
        "time_ms": elapsed_ms, 
        "phase": phase, 
        "weapons": weapons, 
        "combo_max": combo_count, 
        "total_currency": currency, 
        "cargo_capacity": cargo_capacity, 
    }
    sortie_history.append(record)

    print("[통계] 출항 #%d 기록 완료 (노드 %d개 구매, DPS %.0f→%.0f, 스냅샷 %d장)" % [
        sortie_count, _sortie_nodes_purchased.size(), _sortie_dps_start, dps_end, planet_snapshots.size()
    ])


func _capture_planet_snapshot():
    if not planet_data:
        return
    var src_radius = PlanetData.PLANET_RADIUS
    var sf = 4
    var thumb_r = src_radius / sf
    var thumb_size = thumb_r * 2 + 1
    var img = Image.create(thumb_size, thumb_size, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))

    var radius_sq = src_radius * src_radius


    var zc = {
        0: Color(0.4, 1.5, 2.0), 
        1: Color(1.4, 1.3, 0.5), 
        2: Color(1.7, 1.0, 0.3), 
        3: Color(0.4, 0.8, 2.0), 
        4: Color(2.0, 0.15, 0.05), 
    }
    var core_c: = Color(2.5, 0.3, 0.08)
    var fill_c: = Color(0.02, 0.02, 0.035)
    var empty_c: = Color(0.008, 0.008, 0.02)
    var dirs = [Vector2i(sf, 0), Vector2i( - sf, 0), Vector2i(0, sf), Vector2i(0, - sf)]


    for tx in range(thumb_size):
        for ty in range(thumb_size):
            var ox = (tx - thumb_r) * sf
            var oy = (ty - thumb_r) * sf
            if ox * ox + oy * oy > radius_sq:
                continue
            var pos = Vector2i(ox, oy)


            if not planet_data.blocks.has(pos):
                img.set_pixel(tx, ty, empty_c)
                continue

            var block = planet_data.blocks[pos]
            var zone = PlanetData.get_zone(pos)
            var zone_col = zc.get(zone, zc[0])


            var has_exposed = false
            for dir in dirs:
                var nb = pos + dir
                var nd2 = nb.x * nb.x + nb.y * nb.y
                if not planet_data.blocks.has(nb) or nd2 > radius_sq:
                    has_exposed = true
                    break

            if has_exposed:

                var edge_c: Color
                if block.type == PlanetData.BlockType.CORE:
                    edge_c = core_c
                else:
                    edge_c = zone_col
                var dist = sqrt(float(ox * ox + oy * oy))
                var brightness = clampf(dist / float(src_radius) * 1.2, 0.5, 1.0)
                img.set_pixel(tx, ty, Color(edge_c.r * brightness, edge_c.g * brightness, edge_c.b * brightness))
                continue


            var is_boundary = false
            var nb_zone_c = Color.BLACK
            for dir in dirs:
                var nb = pos + dir
                if planet_data.blocks.has(nb):
                    var nb_zone = PlanetData.get_zone(nb)
                    if nb_zone != zone:
                        is_boundary = true
                        nb_zone_c = zc.get(nb_zone, zc[0])
                        break

            if is_boundary:

                var blend = Color(
                    (zone_col.r + nb_zone_c.r) * 0.5 * 0.3, 
                    (zone_col.g + nb_zone_c.g) * 0.5 * 0.3, 
                    (zone_col.b + nb_zone_c.b) * 0.5 * 0.3
                )
                img.set_pixel(tx, ty, blend)
            else:

                var dist = sqrt(float(ox * ox + oy * oy))
                var depth = dist / float(src_radius)
                var zone_hint = 0.08 + depth * 0.14
                var color = fill_c.lerp(
                    Color(zone_col.r * 0.12, zone_col.g * 0.12, zone_col.b * 0.12, 1.0), zone_hint)
                if block.type == PlanetData.BlockType.CORE:
                    color = Color(0.8, 0.08, 0.04)
                img.set_pixel(tx, ty, color)


    var outline_c = Color(0.15, 0.5, 0.65, 0.8)
    var r_inner = float(src_radius - sf * 2)
    var r_outer = float(src_radius + sf)
    for tx in range(thumb_size):
        for ty in range(thumb_size):
            var ox = (tx - thumb_r) * sf
            var oy = (ty - thumb_r) * sf
            var dist = sqrt(float(ox * ox + oy * oy))
            if dist < r_inner or dist > r_outer:
                continue
            var pos = Vector2i(ox, oy)
            var has_nearby = planet_data.blocks.has(pos)
            if not has_nearby and dist > 1.0:
                var dx = - float(ox) / dist
                var dy = - float(oy) / dist
                for step in [sf, sf * 2]:
                    if planet_data.blocks.has(Vector2i(ox + int(round(dx * step)), oy + int(round(dy * step)))):
                        has_nearby = true
                        break
            if not has_nearby:
                continue
            var existing = img.get_pixel(tx, ty)
            if existing.r + existing.g + existing.b < 0.1:
                img.set_pixel(tx, ty, outline_c)


    var png_bytes = img.save_png_to_buffer()
    planet_snapshots.append(png_bytes)

func get_effective_damage() -> float:
    return (1.0 + mining_damage_flat) * _calc_season_dmg_mult() * (1.0 + perm_damage_accumulated * 0.01)


func _calc_season_dmg_mult() -> float:
    var mult: float = 1.0
    for boost in season_dmg_boosts:
        var ratio = planet_data.get_zone_destruction_ratio(boost.zone) if planet_data else 0.0

        mult *= 1.0 + (boost.mult - 1.0) * ratio
    return mult


func _calc_season_res_mult() -> float:
    var mult: float = 1.0
    for boost in season_res_boosts:
        var ratio = planet_data.get_zone_destruction_ratio(boost.zone) if planet_data else 0.0
        mult *= 1.0 + (boost.mult - 1.0) * ratio
    return mult


func get_effective_sortie_time() -> float:
    return 30.0 + mining_time_bonus + perm_time_accumulated


func get_effective_range() -> float:
    return 80.0 + mining_range_bonus


func get_effective_speed() -> float:
    return 300.0 + mining_speed_bonus


func get_resonance_add_ratio(depth_ratio: float) -> float:
    if not resonance_unlocked:
        return 0.0
    return resonance_max_bonus * depth_ratio


func get_effective_drone_damage() -> float:
    var dmg = drone_fixed_damage

    if drone_sync_unlocked:
        dmg += get_effective_damage() * drone_sync_ratio
    return dmg



static func format_number(value) -> String:
    var v: float = float(value)
    if v >= 1e+18:
        return "%.2fQ" % (v / 1e+18)
    elif v >= 1e+15:
        return "%.2fq" % (v / 1e+15)
    elif v >= 1000000000000.0:
        return "%.2fT" % (v / 1000000000000.0)
    elif v >= 1000000000.0:
        return "%.2fB" % (v / 1000000000.0)
    elif v >= 1000000.0:
        return "%.2fM" % (v / 1000000.0)
    elif v >= 1000.0:
        return "%.1fK" % (v / 1000.0)
    else:
        return str(int(v))







const PHASE_BRIDGES: Dictionary = {
    2: {"gate": "multi1", "entry": "electric_unlock"}, 
    3: {"gate": "fuel_save1", "entry": "chain_unlock"}, 
    4: {"gate": "fuel_save2", "entry": "shockwave_unlock"}, 
    5: {"gate": "overdrive1", "entry": "mega_laser_unlock"}, 
}



const PHASE_NODE_ORDER: Dictionary = {

    1: ["start", "dmg1", "fuel_tank1", "resource1", 
        "fire_rate1", "cargo_expand1", "speed1", "minimap", 
        "combo_unlock", "aoe_mining", "critical_hit", "multi1"], 

    2: ["electric_unlock", "cargo_expand2", "dmg2", "fuel_tank2", 
        "drone_proto", "combo_enhance", "range1", "value1", 
        "dmg_boost1", "gold_unlock", "pickup_expand", "drone_dmg", 
        "res_boost1", "charged_shot", "fire_rate2", 
        "gold_value", "fuel_save1"], 


    3: ["chain_unlock", "cargo_expand3", "dmg3", "fuel_tank3", 
        "drone_deploy", "resource2", "fire_rate3", "drone_speed", 
        "chain_jump", "dmg_boost2", "electric_range", "value2", 
        "res_boost2", "drone_pierce", "magnet1", "range2", 
        "fuel_save2", "multi2", "barrier1", "overheat_shield"], 


    4: ["drone_sync", "speed2", "resonance_unlock", "shockwave_unlock", 
        "dmg4", "dmg_boost3", "shockwave_enhance", "cargo_expand4", 
        "drone_crit", "electric_range2", "gold_enhance", "resonance_enhance", 
        "drone_overclock", "barrier2", "fuel_efficiency1", "fuel_tank4", 
        "overdrive1", "res_boost3"], 

    5: ["mega_laser_unlock", "dmg5", "mega_enhance", "electric_chain", 
        "resource3", "cargo_expand5", "dmg_boost4", "final_resonance", 
        "overdrive_enhance", "fire_rate4", "multi3", "res_boost4", 
        "dmg6", "core_breaker", "barrier3", "fuel_safe"], 
}
const PHASE_COLS: int = 4
const CORE_COLS: int = 5








const PHASE_OFFSETS: Dictionary = {
    1: Vector2(2, 2), 
    2: Vector2(12, 2), 
    3: Vector2(12, 14), 
    4: Vector2(2, 14), 
    5: Vector2(2, 26), 
    -1: Vector2(2, 0), 
}

const PHASE_COLORS: Dictionary = {
    1: Color(0.9, 0.75, 0.2), 
    2: Color(0.3, 0.8, 0.95), 
    3: Color(0.2, 0.85, 0.35), 
    4: Color(0.85, 0.4, 0.15), 
    5: Color(0.7, 0.3, 0.85), 
    -1: Color(1.0, 0.35, 0.25), 
}


func is_phase_unlocked(phase: int) -> bool:

    if IS_DEMO and phase > 2:
        return false
    return true


func _has_adjacent_purchased(node_id: String) -> bool:
    if node_id == "start": return true
    var node = nodes.get(node_id)
    if not node: return false
    var phase = node.get("phase", 0)
    var order = PHASE_NODE_ORDER.get(phase, [])
    var idx = order.find(node_id)
    if idx < 0: return false
    var cols = PHASE_COLS
    var col = idx % cols
    var row = idx / cols

    for dir in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
        var nc = col + int(dir.x)
        var nr = row + int(dir.y)
        if nc < 0 or nc >= cols or nr < 0: continue
        var ni = nr * cols + nc
        if ni < 0 or ni >= order.size(): continue
        if is_node_purchased(order[ni]): return true

    var bridge = PHASE_BRIDGES.get(phase)
    if bridge and bridge.entry == node_id:
        return is_node_purchased(bridge.gate)
    return false

func initialize_nodes():
    nodes = {

        "start": {
            "name": "시작", "description": "여기서부터 시작", 
            "phase": 1, "cost": 0, "effects": {}
        }, 







        "dmg1": {
            "name": "레이저 출력 I", 
            "description": "레이저 데미지 +1", 
            "max_level": 3, 
            "base_cost": 20, 
            "cost_mult": 2.0, 
            "phase": 1, 
            "effects": {"damage_flat": 1.0}
        }, 
        "fire_rate1": {
            "name": "연사속도 I", 
            "description": "발사간격 -0.12초", 
            "max_level": 3, 
            "base_cost": 30, 
            "cost_mult": 1.8, 
            "phase": 1, 
            "effects": {"fire_rate": -0.12}
        }, 
        "critical_hit": {
            "name": "🎯 크리티컬 히트", 
            "description": "20% 확률 데미지 ×3", 
            "max_level": 1, 
            "base_cost": 150, 
            "cost_mult": 1.0, 
            "phase": 1, 
            "effects": {"critical_unlock": true}
        }, 


        "resource1": {
            "name": "자원 효율 I", 
            "description": "자원 획득 +2", 
            "max_level": 2, 
            "base_cost": 25, 
            "cost_mult": 2.0, 
            "phase": 1, 
            "effects": {"resource_flat": 2.0}
        }, 
        "value1": {
            "name": "💰 금광 가치 I", 
            "description": "금/코어 블록 자원 +5", 
            "max_level": 2, 
            "base_cost": 800, 
            "cost_mult": 2.0, 
            "phase": 2, 
            "effects": {"gold_bonus_flat": 5.0}
        }, 


        "speed1": {
            "name": "추진기 강화 I", 
            "description": "이동속도 +60", 
            "max_level": 2, 
            "base_cost": 30, 
            "cost_mult": 2.0, 
            "phase": 1, 
            "effects": {"speed": 60.0}
        }, 


        "multi1": {
            "name": "⊞ 멀티 레이저 I", 
            "description": "동시 2블록 타격", 
            "max_level": 1, 
            "base_cost": 200, 
            "cost_mult": 1.0, 
            "phase": 1, 
            "effects": {"multi_laser": 1}
        }, 







        "dmg_boost1": {
            "name": "⚔ 데미지 증폭 I", 
            "description": "🌸 봄 파괴율에 비례 증가\n최대 데미지 ×2", 
            "max_level": 1, 
            "base_cost": 1300, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"season_dmg_mult": 2.0, "boost_zone": 0}
        }, 
        "res_boost1": {
            "name": "💰 자원 증폭 I", 
            "description": "🌸 봄 파괴율에 비례 증가\n최대 자원 ×2", 
            "max_level": 1, 
            "base_cost": 2000, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"season_res_mult": 2.0, "boost_zone": 0}
        }, 


        "electric_unlock": {
            "name": "⚡ 전기 블록 해금", 
            "description": "전기 블록 출현", 
            "max_level": 1, 
            "base_cost": 500, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"electric_unlock": true}
        }, 
        "electric_range": {
            "name": "⚡ 전기 범위 강화 I", 
            "description": "연쇄 범위 +1칸", 
            "max_level": 2, 
            "base_cost": 30000, 
            "cost_mult": 1.5, 
            "phase": 3, 
            "effects": {"electric_range": 1}
        }, 
        "electric_range2": {
            "name": "⚡ 전기 범위 강화 II", 
            "description": "연쇄 범위 +1칸", 
            "max_level": 2, 
            "base_cost": 1000000, 
            "cost_mult": 1.5, 
            "phase": 4, 
            "effects": {"electric_range": 1}
        }, 


        "gold_unlock": {
            "name": "💰 금블록 해금", 
            "description": "금블록 출현\n자원 5배 드롭", 
            "max_level": 1, 
            "base_cost": 1300, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"gold_unlock": true}
        }, 
        "gold_value": {
            "name": "💰 금블록 가치", 
            "description": "자원 획득 +5", 
            "max_level": 1, 
            "base_cost": 3000, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"resource_flat": 5.0}
        }, 
        "pickup_expand": {
            "name": "🧲 수집 범위 확대", 
            "description": "수집 범위 2칸 → 6칸", 
            "max_level": 1, 
            "base_cost": 1300, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"magnet": 128.0}
        }, 


        "dmg2": {
            "name": "레이저 출력 II", 
            "description": "레이저 데미지 +3", 
            "max_level": 3, 
            "base_cost": 500, 
            "cost_mult": 1.5, 
            "phase": 2, 
            "effects": {"damage_flat": 3.0}
        }, 
        "range1": {
            "name": "사거리 확장 I", 
            "description": "사거리 +45px", 
            "max_level": 2, 
            "base_cost": 800, 
            "cost_mult": 1.5, 
            "phase": 2, 
            "effects": {"range": 45.0}
        }, 
        "fire_rate2": {
            "name": "연사속도 II", 
            "description": "발사간격 -0.12초", 
            "max_level": 1, 
            "base_cost": 2000, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"fire_rate": -0.12}
        }, 
        "charged_shot": {
            "name": "🔥 차지 샷", 
            "description": "매 5발째 크리티컬\n데미지 ×3", 
            "max_level": 1, 
            "base_cost": 2000, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"charged_shot_unlock": true}
        }, 







        "dmg_boost2": {
            "name": "⚔ 데미지 증폭 II", 
            "description": "☀️ 여름 파괴율에 비례 증가\n최대 데미지 ×2.5\n⚠ 조건: 코어 2개 파괴", 
            "max_level": 1, 
            "base_cost": 30000, 
            "cost_mult": 1.0, 
            "core_cost": 2, 
            "phase": 3, 
            "effects": {"season_dmg_mult": 2.5, "boost_zone": 1}
        }, 
        "res_boost2": {
            "name": "💰 자원 증폭 II", 
            "description": "☀️ 여름 파괴율에 비례 증가\n최대 자원 ×2", 
            "max_level": 1, 
            "base_cost": 80000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"season_res_mult": 2.0, "boost_zone": 1}
        }, 


        "drone_proto": {
            "name": "🤖 드론 프로토타입", 
            "description": "드론 1기 배치\n고정 데미지 8", 
            "max_level": 1, 
            "base_cost": 800, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"drone_unlock": true}
        }, 
        "drone_dmg": {
            "name": "🤖 드론 화력칩", 
            "description": "드론 데미지 +5", 
            "max_level": 3, 
            "base_cost": 1300, 
            "cost_mult": 1.6, 
            "phase": 2, 
            "effects": {"drone_damage_up": 5.0}
        }, 
        "drone_deploy": {
            "name": "🤖 드론 추가 배치", 
            "description": "드론 +1기", 
            "max_level": 2, 
            "base_cost": 15000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"drone_add": 1}
        }, 
        "drone_speed": {
            "name": "🤖 드론 연사 모듈", 
            "description": "드론 공격속도 ↑0.2초", 
            "max_level": 2, 
            "base_cost": 15000, 
            "cost_mult": 1.8, 
            "phase": 3, 
            "effects": {"drone_fire_rate": 0.2}
        }, 
        "drone_pierce": {
            "name": "🤖 드론 관통", 
            "description": "드론 레이저가 2블록 관통", 
            "max_level": 1, 
            "base_cost": 80000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"drone_pierce_up": 1}
        }, 


        "chain_unlock": {
            "name": "⚡ 체인 라이트닝", 
            "description": "레이저 적중 시\n번개 3회 연쇄", 
            "max_level": 1, 
            "base_cost": 8000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"chain_lightning_unlock": true}
        }, 
        "chain_jump": {
            "name": "⚡ 체인 점프 강화", 
            "description": "번개 연쇄 +2회", 
            "max_level": 2, 
            "base_cost": 30000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"chain_jump": 2}
        }, 


        "dmg3": {
            "name": "레이저 출력 III", 
            "description": "레이저 데미지 +8", 
            "max_level": 4, 
            "base_cost": 8000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"damage_flat": 8.0}
        }, 
        "resource2": {
            "name": "자원 효율 II", 
            "description": "자원 획득 +8", 
            "max_level": 3, 
            "base_cost": 15000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"resource_flat": 8.0}
        }, 
        "value2": {
            "name": "💰 금광 가치 II", 
            "description": "금/코어 블록 자원 +12", 
            "max_level": 2, 
            "base_cost": 30000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"gold_bonus_flat": 12.0}
        }, 
        "multi2": {
            "name": "⊞ 멀티 레이저 II", 
            "description": "동시 3블록 타격", 
            "max_level": 1, 
            "base_cost": 200000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"multi_laser": 1}
        }, 
        "magnet1": {
            "name": "🧲 자원 자석", 
            "description": "자원 즉시 획득\n파편 수집 불필요", 
            "max_level": 1, 
            "base_cost": 80000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"instant_collect": true}
        }, 
        "range2": {
            "name": "사거리 확장 II", 
            "description": "사거리 +30px", 
            "max_level": 2, 
            "base_cost": 80000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"range": 30.0}
        }, 
        "barrier1": {
            "name": "배리어 I", 
            "description": "배리어 +1", 
            "max_level": 1, 
            "base_cost": 200000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"barrier": 1}
        }, 
        "overheat_shield": {
            "name": "🌡️ 내열 방어", 
            "description": "과열 게이지 상승 속도 30% 감소", 
            "max_level": 1, 
            "base_cost": 200000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"overheat_resist": 0.3}
        }, 







        "dmg_boost3": {
            "name": "⚔ 데미지 증폭 III", 
            "description": "🍂 가을 파괴율에 비례 증가\n최대 데미지 ×2.5\n⚠ 조건: 코어 4개 파괴", 
            "max_level": 1, 
            "base_cost": 500000, 
            "cost_mult": 1.0, 
            "core_cost": 4, 
            "phase": 4, 
            "effects": {"season_dmg_mult": 2.5, "boost_zone": 2}
        }, 
        "res_boost3": {
            "name": "💰 자원 증폭 III", 
            "description": "🍂 가을 파괴율에 비례 증가\n최대 자원 ×2.5", 
            "max_level": 1, 
            "base_cost": 2000000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"season_res_mult": 2.5, "boost_zone": 2}
        }, 


        "speed2": {
            "name": "추진기 강화 II", 
            "description": "이동속도 +60", 
            "max_level": 2, 
            "base_cost": 250000, 
            "cost_mult": 2.0, 
            "phase": 4, 
            "effects": {"speed": 60.0}
        }, 
        "drone_sync": {
            "name": "🤖 드론 동기화", 
            "description": "드론 동기화\n플레이어 공격력의 15% 추가", 
            "max_level": 1, 
            "base_cost": 250000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"drone_sync_unlock": true}
        }, 
        "drone_crit": {
            "name": "🤖 드론 크리티컬", 
            "description": "드론 크리티컬 15%\n데미지 ×3", 
            "max_level": 1, 
            "base_cost": 500000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"drone_crit_unlock": true}
        }, 
        "drone_overclock": {
            "name": "🤖 드론 오버클럭", 
            "description": "동기화 30%, 크리 25%", 
            "max_level": 1, 
            "base_cost": 1000000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"drone_overclock": true}
        }, 

        "resonance_unlock": {
            "name": "💠 심층 공명", 
            "description": "행성 중심에 가까울수록\n데미지 증가 (최대 +100%)", 
            "max_level": 1, 
            "base_cost": 250000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"resonance_unlock": true}
        }, 
        "shockwave_unlock": {
            "name": "🌀 충격파", 
            "description": "15블록 파괴마다\n주변 블록 금광 변환", 
            "max_level": 1, 
            "base_cost": 250000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"shockwave_unlock": true}
        }, 
        "overdrive1": {
            "name": "💢 오버드라이브", 
            "description": "50블록 파괴마다 3초간\n공격×3 이속+300", 
            "max_level": 1, 
            "base_cost": 5000000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"overdrive_unlock": true}
        }, 
        "dmg4": {
            "name": "레이저 출력 IV", 
            "description": "레이저 데미지 +15", 
            "max_level": 4, 
            "base_cost": 250000, 
            "cost_mult": 2.0, 
            "phase": 4, 
            "effects": {"damage_flat": 15.0}
        }, 
        "fire_rate3": {
            "name": "연사속도 III", 
            "description": "발사간격 -0.04초", 
            "max_level": 2, 
            "base_cost": 15000, 
            "cost_mult": 2.0, 
            "phase": 3, 
            "effects": {"fire_rate": -0.04}
        }, 

        "resonance_enhance": {
            "name": "💠 공명 증폭", 
            "description": "깊이 보너스 +100%", 
            "max_level": 2, 
            "base_cost": 1000000, 
            "cost_mult": 2.0, 
            "phase": 4, 
            "effects": {"resonance_enhance": 1.0}
        }, 
        "shockwave_enhance": {
            "name": "🌀 충격파 강화", 
            "description": "범위↑ 발동간격↓", 
            "max_level": 2, 
            "base_cost": 500000, 
            "cost_mult": 2.0, 
            "phase": 4, 
            "effects": {"shockwave_enhance": true}
        }, 
        "gold_enhance": {
            "name": "💰 금블록 강화", 
            "description": "자원 획득 +12", 
            "max_level": 2, 
            "base_cost": 1000000, 
            "cost_mult": 2.0, 
            "phase": 4, 
            "effects": {"resource_flat": 12.0}
        }, 
        "barrier2": {
            "name": "배리어 II", 
            "description": "배리어 +1", 
            "max_level": 1, 
            "base_cost": 2000000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"barrier": 1}
        }, 







        "dmg_boost4": {
            "name": "⚔ 데미지 증폭 IV", 
            "description": "❄️ 겨울 파괴율에 비례 증가\n최대 데미지 ×3\n⚠ 조건: 코어 8개 파괴", 
            "max_level": 1, 
            "base_cost": 100000000, 
            "cost_mult": 1.0, 
            "core_cost": 8, 
            "phase": 5, 
            "effects": {"season_dmg_mult": 3.0, "boost_zone": 3}
        }, 
        "res_boost4": {
            "name": "💰 자원 증폭 IV", 
            "description": "❄️ 겨울 파괴율에 비례 증가\n최대 자원 ×3", 
            "max_level": 1, 
            "base_cost": 200000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"season_res_mult": 3.0, "boost_zone": 3}
        }, 

        "mega_laser_unlock": {
            "name": "⚡ 메가 레이저", 
            "description": "30블록 파괴마다\n5초간 관통 빔", 
            "max_level": 1, 
            "base_cost": 30000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"mega_laser_unlock": true}
        }, 
        "mega_enhance": {
            "name": "⚡ 메가 레이저 강화", 
            "description": "게이지↓ 지속시간↑", 
            "max_level": 3, 
            "base_cost": 40000000, 
            "cost_mult": 2.0, 
            "phase": 5, 
            "effects": {"mega_enhance": true}
        }, 
        "multi3": {
            "name": "⊞ 멀티 레이저 III", 
            "description": "동시 4블록 타격", 
            "max_level": 1, 
            "base_cost": 150000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"multi_laser": 1}
        }, 
        "core_breaker": {
            "name": "💥 코어 분쇄기", 
            "description": "코어 블록 데미지 ×3", 
            "max_level": 1, 
            "base_cost": 300000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"core_breaker_unlock": true}
        }, 
        "dmg5": {
            "name": "레이저 출력 V", 
            "description": "레이저 데미지 +25", 
            "max_level": 4, 
            "base_cost": 30000000, 
            "cost_mult": 2.0, 
            "phase": 5, 
            "effects": {"damage_flat": 25.0}
        }, 
        "electric_chain": {
            "name": "⚡ 전기 연쇄 강화", 
            "description": "연쇄 2단계 전파", 
            "max_level": 2, 
            "base_cost": 50000000, 
            "cost_mult": 2.0, 
            "phase": 5, 
            "effects": {"electric_chain": 1}
        }, 
        "final_resonance": {
            "name": "💠 최종 공명", 
            "description": "깊이 보너스 +100%", 
            "max_level": 2, 
            "base_cost": 120000000, 
            "cost_mult": 2.0, 
            "phase": 5, 
            "effects": {"resonance_enhance": 1.0}
        }, 
        "overdrive_enhance": {
            "name": "💢 오버드라이브 강화", 
            "description": "지속+1.5초 필요-10블록", 
            "max_level": 1, 
            "base_cost": 200000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"overdrive_enhance": true}
        }, 
        "fire_rate4": {
            "name": "연사속도 IV", 
            "description": "발사간격 -0.02초", 
            "max_level": 1, 
            "base_cost": 150000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"fire_rate": -0.02}
        }, 
        "barrier3": {
            "name": "배리어 III", 
            "description": "배리어 +10", 
            "max_level": 1, 
            "base_cost": 350000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"barrier": 10}
        }, 


        "dmg6": {
            "name": "레이저 출력 VI", 
            "description": "레이저 데미지 +40", 
            "max_level": 3, 
            "base_cost": 200000000, 
            "cost_mult": 2.0, 
            "phase": 5, 
            "effects": {"damage_flat": 40.0}
        }, 
        "resource3": {
            "name": "자원 효율 III", 
            "description": "자원 획득 +20", 
            "max_level": 2, 
            "base_cost": 80000000, 
            "cost_mult": 2.5, 
            "phase": 5, 
            "effects": {"resource_flat": 20.0}
        }, 


        "aoe_mining": {
            "name": "💢 스플래시 레이저", 
            "description": "레이저 타격 시 인접 블록에\n30% 데미지", 
            "max_level": 1, 
            "base_cost": 120, 
            "cost_mult": 1.0, 
            "phase": 1, 
            "effects": {"aoe_mining_unlock": true}
        }, 


        "combo_unlock": {
            "name": "🔥 콤보 카운터", 
            "description": "연속 파괴 시 콤보 증가\n스택당 자원 +2%", 
            "max_level": 1, 
            "base_cost": 80, 
            "cost_mult": 1.0, 
            "phase": 1, 
            "effects": {"combo_unlock": true, "combo_bonus": 0.02}
        }, 
        "combo_enhance": {
            "name": "🔥 콤보 강화", 
            "description": "스택당 자원 +2%", 
            "max_level": 3, 
            "base_cost": 800, 
            "cost_mult": 1.5, 
            "phase": 2, 
            "effects": {"combo_bonus": 0.02}
        }, 
        "minimap": {
            "name": "📍 미니맵", 
            "description": "채굴 중 미니맵 표시\n코어/특수블록 위치 확인", 
            "max_level": 1, 
            "base_cost": 60, 
            "cost_mult": 1.0, 
            "phase": 1, 
            "effects": {"minimap_unlock": true}
        }, 


        "fuel_tank1": {
            "name": "⛽ 연료탱크 I", 
            "description": "연료 +2초", 
            "max_level": 3, 
            "base_cost": 25, 
            "cost_mult": 2.0, 
            "phase": 1, 
            "effects": {"fuel_expand": 2.0}
        }, 
        "fuel_tank2": {
            "name": "⛽ 연료탱크 II", 
            "description": "연료 +3초", 
            "max_level": 3, 
            "base_cost": 500, 
            "cost_mult": 1.8, 
            "phase": 2, 
            "effects": {"fuel_expand": 3.0}
        }, 
        "fuel_tank3": {
            "name": "⛽ 연료탱크 III", 
            "description": "연료 +5초", 
            "max_level": 3, 
            "base_cost": 8000, 
            "cost_mult": 1.8, 
            "phase": 3, 
            "effects": {"fuel_expand": 5.0}
        }, 
        "fuel_tank4": {
            "name": "⛽ 연료탱크 IV", 
            "description": "연료 +12초", 
            "max_level": 3, 
            "base_cost": 2000000, 
            "cost_mult": 1.8, 
            "phase": 4, 
            "effects": {"fuel_expand": 12.0}
        }, 
        "fuel_save1": {
            "name": "🛡 비상 귀환 I", 
            "description": "연료 고갈 시 자원 30% 보존", 
            "max_level": 1, 
            "base_cost": 3000, 
            "cost_mult": 1.0, 
            "phase": 2, 
            "effects": {"fuel_loss_reduce": 0.3}
        }, 
        "fuel_save2": {
            "name": "🛡 비상 귀환 II", 
            "description": "연료 고갈 시 자원 60% 보존", 
            "max_level": 1, 
            "base_cost": 200000, 
            "cost_mult": 1.0, 
            "phase": 3, 
            "effects": {"fuel_loss_reduce": 0.6}
        }, 
        "fuel_efficiency1": {
            "name": "⚡ 연료 효율", 
            "description": "연료 소모 20% 감소", 
            "max_level": 1, 
            "base_cost": 2000000, 
            "cost_mult": 1.0, 
            "phase": 4, 
            "effects": {"fuel_efficiency": 0.8}
        }, 
        "fuel_safe": {
            "name": "💫 안전 장치", 
            "description": "우주선 파괴 시 자원 손실률 0%", 
            "max_level": 1, 
            "base_cost": 250000000, 
            "cost_mult": 1.0, 
            "phase": 5, 
            "effects": {"fuel_loss_reduce": 1.0}
        }, 


        "cargo_expand1": {
            "name": "📦 화물칸 확장 I", 
            "description": "화물칸 +10개", 
            "max_level": 3, 
            "base_cost": 30, 
            "cost_mult": 2.0, 
            "phase": 1, 
            "effects": {"cargo_expand": 10.0}
        }, 
        "cargo_expand2": {
            "name": "📦 화물칸 확장 II", 
            "description": "화물칸 +50개", 
            "max_level": 3, 
            "base_cost": 500, 
            "cost_mult": 1.8, 
            "phase": 2, 
            "effects": {"cargo_expand": 50.0}
        }, 
        "cargo_expand3": {
            "name": "📦 화물칸 확장 III", 
            "description": "화물칸 +200개", 
            "max_level": 3, 
            "base_cost": 8000, 
            "cost_mult": 1.8, 
            "phase": 3, 
            "effects": {"cargo_expand": 200.0}
        }, 
        "cargo_expand4": {
            "name": "📦 화물칸 확장 IV", 
            "description": "화물칸 +1000개", 
            "max_level": 3, 
            "base_cost": 500000, 
            "cost_mult": 1.8, 
            "phase": 4, 
            "effects": {"cargo_expand": 1000.0}
        }, 
        "cargo_expand5": {
            "name": "📦 화물칸 확장 V", 
            "description": "화물칸 +5000개", 
            "max_level": 3, 
            "base_cost": 80000000, 
            "cost_mult": 1.8, 
            "phase": 5, 
            "effects": {"cargo_expand": 5000.0}
        }, 
    }


    var total_levels: int = 0
    for id in nodes:
        if id != "start":
            total_levels += nodes[id].get("max_level", 1)
    print("채굴 노드 초기화 완료: %d개 노드, %d 총 레벨" % [nodes.size(), total_levels])





func purchase_node(node_id: String) -> bool:
    var node = nodes.get(node_id)
    if not node:
        return false

    var current_level = get_node_level(node_id)
    var max_level = node.get("max_level", 1)
    if current_level >= max_level:
        return false

    var cost = get_node_cost(node_id)
    if currency < cost:
        return false


    var cc = node.get("core_cost", 0)
    if cc > 0 and total_cores_destroyed < cc:
        return false


    var phase = node.get("phase", 0)
    if not is_phase_unlocked(phase):
        return false
    if not _has_adjacent_purchased(node_id):
        return false

    currency -= cost
    node_levels[node_id] = current_level + 1
    apply_node_effect(node)


    _sortie_nodes_purchased.append({
        "id": node_id, 
        "name": node.name, 
        "level": node_levels[node_id], 
        "cost": cost, 
    })

    if sortie_history.size() > 0:
        sortie_history[-1]["nodes_purchased"] = _sortie_nodes_purchased.duplicate()

    print("노드 구매: %s Lv%d (비용 %s)" % [node.name, node_levels[node_id], format_number(cost)])
    return true

func can_purchase_node(node_id: String) -> bool:
    var node = nodes.get(node_id)
    if not node:
        return false
    if get_node_level(node_id) >= node.get("max_level", 1):
        return false
    if currency < get_node_cost(node_id):
        return false

    var cc = node.get("core_cost", 0)
    if cc > 0 and total_cores_destroyed < cc:
        return false
    var phase = node.get("phase", 0)
    if not is_phase_unlocked(phase):
        return false
    if not _has_adjacent_purchased(node_id):
        return false
    return true


func is_node_visible(node_id: String) -> bool:
    if is_node_purchased(node_id):
        return true
    return _has_adjacent_purchased(node_id)





func apply_node_effect(node: Dictionary):
    var effects = node.effects


    if effects.has("damage_flat"):
        mining_damage_flat += effects.damage_flat
    if effects.has("season_dmg_mult"):
        var zone = effects.get("boost_zone", -1)
        if zone >= 0:
            season_dmg_boosts.append({"zone": zone, "mult": effects.season_dmg_mult})
        else:
            mining_season_dmg_mult *= effects.season_dmg_mult
    if effects.has("range"):
        mining_range_bonus += effects.range
    if effects.has("speed"):
        mining_speed_bonus += effects.speed

    if effects.has("fire_rate"):
        mining_fire_rate = maxf(0.05, mining_fire_rate + effects.fire_rate)
    if effects.has("barrier"):
        mining_barrier_count += effects.barrier
    if effects.has("season_res_mult"):
        var zone = effects.get("boost_zone", -1)
        if zone >= 0:
            season_res_boosts.append({"zone": zone, "mult": effects.season_res_mult})
        else:
            mining_season_res_mult *= effects.season_res_mult
    if effects.has("resource_flat"):
        mining_resource_flat += effects.resource_flat
    if effects.has("gold_bonus_flat"):
        gold_bonus_flat += effects.gold_bonus_flat


    if effects.has("electric_unlock"):
        electric_unlocked = true
    if effects.has("gold_unlock"):
        gold_unlocked = true
    if effects.has("multi_laser"):
        multi_laser_count += effects.multi_laser
    if effects.has("electric_range"):
        electric_range += effects.electric_range
    if effects.has("electric_chain"):
        electric_chain_depth += effects.electric_chain


    if effects.has("drone_unlock"):
        drone_unlocked = true
    if effects.has("chain_lightning_unlock"):
        chain_lightning_unlocked = true
    if effects.has("resonance_unlock"):
        resonance_unlocked = true


    if effects.has("mega_laser_unlock"):
        mega_laser_unlocked = true
    if effects.has("shockwave_unlock"):
        shockwave_unlocked = true

    if effects.has("drone_damage_up"):
        drone_fixed_damage += effects.drone_damage_up
    if effects.has("drone_add"):
        drone_count += effects.drone_add
    if effects.has("drone_fire_rate"):
        drone_fire_rate_bonus += effects.drone_fire_rate
    if effects.has("drone_pierce_up"):
        drone_pierce += effects.drone_pierce_up
    if effects.has("drone_sync_unlock"):
        drone_sync_unlocked = true
    if effects.has("drone_crit_unlock"):
        drone_crit_unlocked = true
    if effects.has("drone_overclock"):

        drone_sync_ratio = 0.3
        drone_crit_chance = 0.25




    if effects.has("mega_enhance"):
        mega_laser_gauge_need = maxi(10, mega_laser_gauge_need - 5)
        mega_laser_duration += 1.0
    if effects.has("shockwave_enhance"):
        shockwave_range += 2
        shockwave_interval = maxi(5, shockwave_interval - 2)
    if effects.has("resonance_enhance"):
        resonance_max_bonus += effects.resonance_enhance


    if effects.has("critical_unlock"):
        critical_unlocked = true
    if effects.has("charged_shot_unlock"):
        charged_shot_unlocked = true
    if effects.has("magnet"):
        pickup_range += effects.magnet
    if effects.has("instant_collect"):
        instant_collect = true
    if effects.has("aoe_mining_unlock"):
        aoe_mining_unlocked = true
    if effects.has("chain_jump"):
        chain_lightning_jumps += effects.chain_jump
    if effects.has("overdrive_unlock"):
        overdrive_unlocked = true
    if effects.has("core_breaker_unlock"):
        core_breaker_unlocked = true
    if effects.has("overdrive_enhance"):
        overdrive_duration += 1.5
        overdrive_kill_need = maxi(20, overdrive_kill_need - 10)


    if effects.has("combo_unlock"):
        combo_unlocked = true
    if effects.has("combo_bonus"):
        combo_flat_per_stack += effects.combo_bonus
    if effects.has("minimap_unlock"):
        minimap_unlocked = true


    if effects.has("cargo_expand"):
        cargo_bonus += effects.cargo_expand
        cargo_capacity = cargo_base_capacity + cargo_bonus


    if effects.has("sell_rate"):
        ore_sell_rate += effects.sell_rate


    if effects.has("fuel_expand"):
        fuel_bonus += effects.fuel_expand
        fuel_capacity = fuel_base_capacity + fuel_bonus
    if effects.has("fuel_efficiency"):
        fuel_efficiency *= effects.fuel_efficiency
    if effects.has("overheat_resist"):
        overheat_resist = clampf(overheat_resist + effects.overheat_resist, 0.0, 0.9)
    if effects.has("fuel_loss_reduce"):
        fuel_loss_reduction = maxf(fuel_loss_reduction, effects.fuel_loss_reduce)





var core_upgrades: Dictionary = {
    "core_detect": {"name": "🔍 코어 탐지", "desc": "CORE_DESC_DETECT", "cost": 1}, 
    "brake": {"name": "🛑 긴급 제동", "desc": "CORE_DESC_BRAKE", "cost": 1}, 
    "barrier_regen": {"name": "🛡️ 배리어 재생", "desc": "CORE_DESC_BARRIER", "cost": 2}, 
    "spawn_direction": {"name": "🧭 출항 방향", "desc": "CORE_DESC_DIRECTION", "cost": 2}, 
    "return_shortcut": {"name": "⏱️ 귀환 단축", "desc": "CORE_DESC_SHORTCUT", "cost": 2}, 
    "core_focus": {"name": "🎯 코어 집중", "desc": "CORE_DESC_FOCUS", "cost": 3}, 
    "emergency_return": {"name": "♻️ 연료 무한", "desc": "CORE_DESC_EMERGENCY", "cost": 3}, 
    "center_unlock": {"name": "🟣 중심 해금", "desc": "CORE_DESC_CENTER", "cost": 2, "requires": "emergency_return"}, 
    "planet_mastery": {"name": "🌑 행성 지배", "desc": "CORE_DESC_MASTERY", "cost": 1, "requires": "center_unlock"}, 
}

var purchased_core_upgrades: Array = []

func purchase_core_upgrade(upgrade_id: String) -> bool:
    if upgrade_id in purchased_core_upgrades:
        return false
    var upgrade = core_upgrades.get(upgrade_id)
    if not upgrade:
        return false
    if core_currency < upgrade.cost:
        return false

    if upgrade.has("requires") and upgrade.requires not in purchased_core_upgrades:
        return false

    if upgrade_id == "planet_mastery" and not can_purchase_planet_mastery():
        return false

    core_currency -= upgrade.cost
    purchased_core_upgrades.append(upgrade_id)
    apply_core_upgrade(upgrade_id)
    print("코어 보상 구매: %s (코어 %d개)" % [upgrade.name, upgrade.cost])
    return true

func apply_core_upgrade(upgrade_id: String):
    match upgrade_id:
        "core_detect":
            core_detect_unlocked = true
        "brake":
            brake_unlocked = true
        "barrier_regen":
            barrier_regen_unlocked = true
        "spawn_direction":
            spawn_direction_unlocked = true
            spawn_points_available = 2
        "return_shortcut":
            return_shortcut_unlocked = true
        "core_focus":
            core_focus_unlocked = true
        "emergency_return":
            infinite_fuel_unlocked = true
        "center_unlock":
            center_unlock_unlocked = true
            print("[Global] 🟣 중심 구역 해금! CENTER 블록 파괴 가능")
        "planet_mastery":
            planet_mastery_unlocked = true
            free_planet_mode = true
            print("[Global] 🌑 행성 지배 해금! 재생성 가능")

        _:
            print("[Global] 알 수 없는 코어 업그레이드: %s (무시)" % upgrade_id)


func can_purchase_planet_mastery() -> bool:
    return planet_cleared and planet_fully_destroyed


func regenerate_planet():
    if not planet_mastery_unlocked:
        return

    planet_cleared = false
    planet_fully_destroyed = false
    total_cores_destroyed = 0

    await initialize_planet()
    save_game()
    print("[Global] 🌍 새 행성 생성 완료!")





func get_save_data() -> Dictionary:
    var data = {
        "currency": currency, 
        "core_currency": core_currency, 
        "node_levels": node_levels, 
        "purchased_core_upgrades": purchased_core_upgrades, 
        "total_cores_destroyed": total_cores_destroyed, 
        "sortie_count": sortie_count, 
        "total_play_time": total_play_time, 
        "total_resources": total_resources, 
        "perm_damage_accumulated": perm_damage_accumulated, 
        "perm_time_accumulated": perm_time_accumulated, 
        "resume_position_x": resume_position.x, 
        "resume_position_y": resume_position.y, 
        "resume_position_valid": resume_position_valid, 
        "planet_cleared": planet_cleared, 
        "planet_fully_destroyed": planet_fully_destroyed, 
        "ending_shown": ending_shown, 
        "epilogue_shown": epilogue_shown, 
        "mastery_popup_shown": mastery_popup_shown, 
        "planet_mastery_unlocked": planet_mastery_unlocked, 
        "free_planet_mode": free_planet_mode, 
        "sortie_history": sortie_history, 
        "planet_snapshots": planet_snapshots, 

        "cargo_bonus": cargo_bonus, 

        "fuel_bonus": fuel_bonus, 
        "fuel_efficiency": fuel_efficiency, 
        "fuel_loss_reduction": fuel_loss_reduction, 
    }

    if planet_data:
        data["planet"] = planet_data.to_save_data()
    return data

func save_game():
    var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
    save_file.store_var(get_save_data())
    save_file.close()
    print("게임 저장 완료!")

func load_game() -> bool:
    if not FileAccess.file_exists("user://savegame.save"):
        return false
    var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
    var data = save_file.get_var()
    save_file.close()

    if data == null:
        push_warning("[Global] 세이브 파일 손상 — 새 게임으로 시작")
        return false

    currency = data.get("currency", 0)
    core_currency = data.get("core_currency", 0)
    node_levels = data.get("node_levels", {})
    purchased_core_upgrades = data.get("purchased_core_upgrades", [])
    total_cores_destroyed = data.get("total_cores_destroyed", 0)
    sortie_count = data.get("sortie_count", 0)
    total_play_time = data.get("total_play_time", 0.0)
    total_resources = data.get("total_resources", 0)
    perm_damage_accumulated = data.get("perm_damage_accumulated", 0.0)
    perm_time_accumulated = data.get("perm_time_accumulated", 0.0)
    resume_position = Vector2(data.get("resume_position_x", 0.0), data.get("resume_position_y", 0.0))
    resume_position_valid = data.get("resume_position_valid", false)
    planet_cleared = data.get("planet_cleared", false)
    planet_fully_destroyed = data.get("planet_fully_destroyed", false)
    ending_shown = data.get("ending_shown", false)
    epilogue_shown = data.get("epilogue_shown", false)
    mastery_popup_shown = data.get("mastery_popup_shown", false)
    planet_mastery_unlocked = data.get("planet_mastery_unlocked", false)
    free_planet_mode = data.get("free_planet_mode", false)
    sortie_history = data.get("sortie_history", [])
    planet_snapshots = data.get("planet_snapshots", [])

    cargo_bonus = data.get("cargo_bonus", 0.0)
    cargo_capacity = cargo_base_capacity + cargo_bonus

    fuel_bonus = data.get("fuel_bonus", 0.0)
    fuel_efficiency = data.get("fuel_efficiency", 1.0)
    fuel_loss_reduction = data.get("fuel_loss_reduction", 0.0)
    fuel_capacity = fuel_base_capacity + fuel_bonus


    if data.has("planet"):
        planet_data = PlanetData.new()
        planet_data.load_save_data(data["planet"])
    else:
        planet_data = null

    reapply_all_nodes()


    resume_position = Vector2(data.get("resume_position_x", 0.0), data.get("resume_position_y", 0.0))
    resume_position_valid = data.get("resume_position_valid", false)
    total_cores_destroyed = data.get("total_cores_destroyed", 0)
    perm_damage_accumulated = data.get("perm_damage_accumulated", 0.0)
    perm_time_accumulated = data.get("perm_time_accumulated", 0.0)


    _reconcile_core_currency()

    print("게임 로드 완료!")
    return true

func reapply_all_nodes():
    reset_mining_stats()

    for node_id in node_levels:
        var node = nodes.get(node_id)
        if node:
            for i in range(node_levels[node_id]):
                apply_node_effect(node)

    for upgrade_id in purchased_core_upgrades:
        apply_core_upgrade(upgrade_id)

func delete_save():
    if FileAccess.file_exists("user://savegame.save"):
        DirAccess.remove_absolute("user://savegame.save")
        sortie_history.clear()
        planet_snapshots.clear()
        _sortie_nodes_purchased.clear()
        print("세이브 삭제! (통계 포함)")
