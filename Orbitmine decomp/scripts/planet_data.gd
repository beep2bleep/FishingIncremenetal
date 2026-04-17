extends RefCounted
class_name PlanetData







const BLOCK_SIZE: int = 32
const PLANET_RADIUS: int = 280



enum Zone{SPRING, SUMMER, AUTUMN, WINTER, CENTER}







const CENTER_RADIUS: int = 55


static func get_zone(pos: Vector2i) -> int:
    var dist_sq = pos.x * pos.x + pos.y * pos.y
    if dist_sq <= CENTER_RADIUS * CENTER_RADIUS:
        return Zone.CENTER
    var angle = atan2(float(pos.y), float(pos.x))
    if angle >= - PI * 2.0 / 3.0 and angle < - PI / 3.0:
        return Zone.SPRING
    elif angle >= - PI / 3.0 and angle < PI / 9.0:
        return Zone.SUMMER
    elif angle >= PI / 9.0 and angle < PI * 2.0 / 3.0:
        return Zone.AUTUMN
    else:
        return Zone.WINTER


static func get_zone_name(zone: int) -> String:
    match zone:
        Zone.SPRING: return "🌸 봄"
        Zone.SUMMER: return "☀️ 여름"
        Zone.AUTUMN: return "🍂 가을"
        Zone.WINTER: return "❄️ 겨울"
        Zone.CENTER: return "💀 최종"
        _: return "???"


enum BlockType{NORMAL, CORE, ELECTRIC, GOLD, THORN}



var blocks: Dictionary = {}
var cores: Array = []
var proximity_cache: Dictionary = {}


var zone_initial_blocks: Dictionary = {}
var zone_destroyed_blocks: Dictionary = {}
var zone_current_blocks: Dictionary = {}
var exposed_edges: Dictionary = {}



const ELECTRIC_CHANCE: float = 0.02
const GOLD_CHANCE: float = 0.02
const GOLD_RESOURCE_MULT: float = 5.0











const ANGLE_TABLE: Array = [
    - PI * 0.5, 
    - PI * 0.25, 
    0.0, 
    PI * 0.25, 
    PI * 0.5, 
    PI * 0.75, 
    PI, 
    - PI * 0.75, 
]

const CORE_CONFIGS = [

    {"id": 0, "dist": 240, "angle_deg": -110, "size": 3, "influence": 16, "hp_mult": 15.0, "total_hp": 50, "inf_mult": 2.0, "res_mult": 1.0, "zone": Zone.SPRING, "role": "outer"}, 
    {"id": 1, "dist": 240, "angle_deg": -90, "size": 3, "influence": 16, "hp_mult": 20.0, "total_hp": 120, "inf_mult": 2.0, "res_mult": 1.2, "zone": Zone.SPRING, "role": "outer"}, 
    {"id": 2, "dist": 240, "angle_deg": -70, "size": 3, "influence": 16, "hp_mult": 25.0, "total_hp": 250, "inf_mult": 2.5, "res_mult": 1.5, "zone": Zone.SPRING, "role": "outer"}, 
    {"id": 12, "dist": 180, "angle_deg": -90, "size": 5, "influence": 22, "hp_mult": 80.0, "total_hp": 500, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.SPRING, "role": "boss"}, 

    {"id": 3, "dist": 220, "angle_deg": -45, "size": 3, "influence": 18, "hp_mult": 75.0, "total_hp": 5000, "inf_mult": 3.0, "res_mult": 1.5, "zone": Zone.SUMMER, "role": "outer"}, 
    {"id": 4, "dist": 220, "angle_deg": -20, "size": 3, "influence": 18, "hp_mult": 90.0, "total_hp": 8000, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.SUMMER, "role": "outer"}, 
    {"id": 5, "dist": 220, "angle_deg": 5, "size": 3, "influence": 18, "hp_mult": 100.0, "total_hp": 15000, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.SUMMER, "role": "outer"}, 
    {"id": 13, "dist": 150, "angle_deg": -20, "size": 5, "influence": 25, "hp_mult": 250.0, "total_hp": 20000, "inf_mult": 3.5, "res_mult": 3.0, "zone": Zone.SUMMER, "role": "boss"}, 

    {"id": 6, "dist": 200, "angle_deg": 40, "size": 3, "influence": 20, "hp_mult": 125.0, "total_hp": 80000, "inf_mult": 3.5, "res_mult": 2.5, "zone": Zone.AUTUMN, "role": "outer"}, 
    {"id": 7, "dist": 200, "angle_deg": 70, "size": 3, "influence": 20, "hp_mult": 150.0, "total_hp": 150000, "inf_mult": 3.5, "res_mult": 3.0, "zone": Zone.AUTUMN, "role": "outer"}, 
    {"id": 8, "dist": 200, "angle_deg": 100, "size": 3, "influence": 20, "hp_mult": 175.0, "total_hp": 250000, "inf_mult": 4.0, "res_mult": 3.0, "zone": Zone.AUTUMN, "role": "outer"}, 
    {"id": 14, "dist": 120, "angle_deg": 70, "size": 7, "influence": 28, "hp_mult": 400.0, "total_hp": 350000, "inf_mult": 4.0, "res_mult": 4.0, "zone": Zone.AUTUMN, "role": "boss"}, 

    {"id": 9, "dist": 180, "angle_deg": 150, "size": 5, "influence": 22, "hp_mult": 200.0, "total_hp": 5000000, "inf_mult": 4.0, "res_mult": 3.5, "zone": Zone.WINTER, "role": "outer"}, 
    {"id": 10, "dist": 180, "angle_deg": 180, "size": 5, "influence": 22, "hp_mult": 250.0, "total_hp": 10000000, "inf_mult": 4.0, "res_mult": 4.0, "zone": Zone.WINTER, "role": "outer"}, 
    {"id": 11, "dist": 180, "angle_deg": 210, "size": 5, "influence": 22, "hp_mult": 300.0, "total_hp": 20000000, "inf_mult": 4.5, "res_mult": 5.0, "zone": Zone.WINTER, "role": "outer"}, 
    {"id": 15, "dist": 90, "angle_deg": 180, "size": 7, "influence": 32, "hp_mult": 600.0, "total_hp": 50000000, "inf_mult": 5.0, "res_mult": 6.0, "zone": Zone.WINTER, "role": "boss"}, 

    {"id": 16, "dist": 0, "angle_deg": 0, "size": 7, "influence": 35, "hp_mult": 500.0, "total_hp": 180000000, "inf_mult": 5.0, "res_mult": 8.0, "zone": Zone.CENTER, "role": "final"}, 
]

const FINAL_CORE_ID: int = 16









const ZONE_BOSS_IDS: Dictionary = {
    Zone.SPRING: 12, 
    Zone.SUMMER: 13, 
    Zone.AUTUMN: 14, 
    Zone.WINTER: 15, 
}


const ZONE_UNLOCK_REQUIRES: Dictionary = {
    Zone.SPRING: -1, 
    Zone.SUMMER: 12, 
    Zone.AUTUMN: 13, 
    Zone.WINTER: 14, 
    Zone.CENTER: 15, 
}


static func get_core_zone(core_id: int) -> int:
    for config in CORE_CONFIGS:
        if config.id == core_id:
            return config.zone
    return Zone.CENTER


static func get_core_role(core_id: int) -> String:
    for config in CORE_CONFIGS:
        if config.id == core_id:
            return config.role
    return "outer"


func is_zone_unlocked(zone: int) -> bool:

    if Global.free_planet_mode:
        return true
    var required_boss_id = ZONE_UNLOCK_REQUIRES.get(zone, -1)
    if required_boss_id < 0:
        return true
    var boss_core = _get_core_by_id(required_boss_id)
    if boss_core == null:
        return false
    return not boss_core.alive


func is_core_locked(core_id: int) -> bool:

    if Global.free_planet_mode:
        return false
    var zone = get_core_zone(core_id)



    if not is_zone_unlocked(zone):
        return true
    var role = get_core_role(core_id)
    if role == "boss":

        return get_alive_outer_in_zone(zone) > 0
    if role == "final":

        for boss_id in ZONE_BOSS_IDS.values():
            var boss = _get_core_by_id(boss_id)
            if boss and boss.alive:
                return true
        return false
    return false


func get_alive_outer_in_zone(zone: int) -> int:
    var count = 0
    for core in cores:
        if core.alive and core.zone == zone and core.role == "outer":
            count += 1
    return count


func get_alive_cores_in_zone(zone: int) -> int:
    var count = 0
    for core in cores:
        if core.alive and core.zone == zone:
            count += 1
    return count


func is_zone_boss_dead(zone: int) -> bool:
    var boss_id = ZONE_BOSS_IDS.get(zone, -1)
    if boss_id < 0:
        return false
    var boss = _get_core_by_id(boss_id)
    return boss != null and not boss.alive



static func get_core_tier(core_id: int) -> int:
    var role = get_core_role(core_id)
    match role:
        "outer": return 1
        "boss": return 2
        "final": return 3
        _: return 1

func get_alive_cores_in_tier(tier: int) -> int:
    var count = 0
    for core in cores:
        if core.alive and get_core_tier(core.id) == tier:
            count += 1
    return count

func get_destroyed_in_tier(tier: int) -> int:
    var count = 0
    for core in cores:
        if not core.alive and get_core_tier(core.id) == tier:
            count += 1
    return count



func get_active_core_behaviors() -> Dictionary:
    return {
        "regen_boost": false, 
        "defense_blocks": false, 
        "shockwave": false, 
        "final_rage": false, 
        "destroyed_t1": 0, 
    }

func spawn_defense_blocks() -> int:
    return 0

func get_shockwave_cores() -> Array:
    return []

func get_regen_radius_bonus(_core: Dictionary) -> int:
    return 0

func get_effective_influence_radius(core: Dictionary) -> int:
    return core.influence_radius






const GENERATE_BATCH_SIZE: int = 5000

func generate_async(tree: SceneTree) -> void :
    blocks.clear()
    cores.clear()

    var radius_sq = PLANET_RADIUS * PLANET_RADIUS
    var batch_count = 0


    for x in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
            var dist_sq = x * x + y * y
            if dist_sq <= radius_sq:
                var pos = Vector2i(x, y)
                var dist = sqrt(float(dist_sq))
                var hp = _calc_block_hp(pos)
                var res = _calc_block_resource(pos)

                var block_type = BlockType.NORMAL
                var roll = randf()
                if roll < GOLD_CHANCE:
                    block_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    block_type = BlockType.ELECTRIC

                var zone = get_zone(pos)

                blocks[pos] = {
                    "type": block_type, 
                    "hp": hp, 
                    "max_hp": hp, 
                    "resource": res, 
                    "core_id": -1, 
                    "zone": zone, 
                }

                batch_count += 1
                if batch_count >= GENERATE_BATCH_SIZE:
                    batch_count = 0
                    await tree.process_frame


    _place_cores()
    _apply_influence_zone_boost()


    await _rebuild_proximity_cache_async(tree)
    await _rebuild_exposed_edges_async(tree)

    print("[PlanetData] 행성 생성: 블록 %d개, 코어 %d개, 반경 %d" % [blocks.size(), cores.size(), PLANET_RADIUS])


func generate_async_with_progress(tree: SceneTree, progress_cb: Callable) -> void :
    blocks.clear()
    cores.clear()

    var radius_sq = PLANET_RADIUS * PLANET_RADIUS
    var batch_count = 0
    var diameter = PLANET_RADIUS * 2 + 1
    var row_index = 0


    for x in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
        row_index += 1
        if row_index % 20 == 0:
            var pct = float(row_index) / diameter * 70.0
            progress_cb.call(pct, tr("LOADING_BLOCKS"))
        for y in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
            var dist_sq = x * x + y * y
            if dist_sq <= radius_sq:
                var pos = Vector2i(x, y)
                var dist = sqrt(float(dist_sq))
                var hp = _calc_block_hp(pos)
                var res = _calc_block_resource(pos)

                var block_type = BlockType.NORMAL
                var roll = randf()
                if roll < GOLD_CHANCE:
                    block_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    block_type = BlockType.ELECTRIC

                var zone = get_zone(pos)

                blocks[pos] = {
                    "type": block_type, 
                    "hp": hp, 
                    "max_hp": hp, 
                    "resource": res, 
                    "core_id": -1, 
                    "zone": zone, 
                }

                batch_count += 1
                if batch_count >= GENERATE_BATCH_SIZE:
                    batch_count = 0
                    await tree.process_frame


    progress_cb.call(70.0, tr("LOADING_CORES"))
    _place_cores()
    _apply_influence_zone_boost()
    await tree.process_frame


    progress_cb.call(75.0, tr("LOADING_CACHE"))
    await _rebuild_proximity_cache_async(tree)
    progress_cb.call(88.0, tr("LOADING_EDGES"))
    await _rebuild_exposed_edges_async(tree)

    progress_cb.call(100.0, tr("LOADING_DONE"))
    print("[PlanetData] 행성 생성: 블록 %d개, 코어 %d개, 반경 %d" % [blocks.size(), cores.size(), PLANET_RADIUS])


func generate():
    blocks.clear()
    cores.clear()

    var radius_sq = PLANET_RADIUS * PLANET_RADIUS

    for x in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range( - PLANET_RADIUS, PLANET_RADIUS + 1):
            var dist_sq = x * x + y * y
            if dist_sq <= radius_sq:
                var pos = Vector2i(x, y)
                var dist = sqrt(float(dist_sq))
                var hp = _calc_block_hp(pos)
                var res = _calc_block_resource(pos)

                var block_type = BlockType.NORMAL
                var roll = randf()
                if roll < GOLD_CHANCE:
                    block_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    block_type = BlockType.ELECTRIC

                var zone = get_zone(pos)

                blocks[pos] = {
                    "type": block_type, 
                    "hp": hp, 
                    "max_hp": hp, 
                    "resource": res, 
                    "core_id": -1, 
                    "zone": zone, 
                }

    _place_cores()
    _apply_influence_zone_boost()


    _rebuild_proximity_cache()
    _rebuild_exposed_edges()

    print("[PlanetData] 행성 생성: 블록 %d개, 코어 %d개, 반경 %d" % [blocks.size(), cores.size(), PLANET_RADIUS])








const ZONE_BOSS_DIST: Dictionary = {
    Zone.SPRING: 180, Zone.SUMMER: 150, 
    Zone.AUTUMN: 120, Zone.WINTER: 90, 
}

const ZONE_HP_RANGE: Dictionary = {
    Zone.SPRING: {"min": 3.0, "max": 12.0}, 
    Zone.SUMMER: {"min": 15.0, "max": 150.0}, 
    Zone.AUTUMN: {"min": 200.0, "max": 2000.0}, 
    Zone.WINTER: {"min": 3000.0, "max": 30000.0}, 
    Zone.CENTER: {"min": 30000.0, "max": 300000.0}, 
}

const ZONE_RES_RANGE: Dictionary = {
    Zone.SPRING: {"min": 3.0, "max": 15.0}, 
    Zone.SUMMER: {"min": 10.0, "max": 80.0}, 
    Zone.AUTUMN: {"min": 80.0, "max": 800.0}, 
    Zone.WINTER: {"min": 800.0, "max": 8000.0}, 
    Zone.CENTER: {"min": 8000.0, "max": 80000.0}, 
}


func _get_zone_depth(pos: Vector2i) -> float:
    var dist = sqrt(float(pos.x * pos.x + pos.y * pos.y))
    var zone = get_zone(pos)
    if zone == Zone.CENTER:

        return clampf(1.0 - dist / float(CENTER_RADIUS), 0.0, 1.0)
    var boss_dist = ZONE_BOSS_DIST.get(zone, 0)
    var depth = (float(PLANET_RADIUS) - dist) / float(PLANET_RADIUS - boss_dist)
    return clampf(depth, 0.0, 1.0)


func _calc_block_hp(pos: Vector2i) -> float:
    var zone = get_zone(pos)
    var depth = _get_zone_depth(pos)
    var hp_range = ZONE_HP_RANGE.get(zone, {"min": 15.0, "max": 300.0})
    return round(hp_range["min"] * pow(hp_range["max"] / hp_range["min"], depth))


func _calc_block_resource(pos: Vector2i) -> float:
    var zone = get_zone(pos)
    var depth = _get_zone_depth(pos)
    var res_range = ZONE_RES_RANGE.get(zone, {"min": 5.0, "max": 100.0})
    return round(res_range["min"] * pow(res_range["max"] / res_range["min"], depth))


func _get_influence_hp_mult(pos: Vector2i, only_alive: bool = false) -> float:
    var max_mult: float = 1.0
    for core in cores:
        if only_alive and not core.alive:
            continue
        var inf_m = _get_core_config_inf_mult(core.id)
        var bonus_base = maxf(0.0, inf_m - 1.0)
        if bonus_base <= 0.0:
            continue

        var dx = pos.x - core.center.x
        var dy = pos.y - core.center.y
        var dist = sqrt(float(dx * dx + dy * dy))
        var influence_r = float(core.influence_radius)
        if dist >= influence_r:
            continue

        var proximity = 1.0 - (dist / influence_r)
        var mult = 1.0 + bonus_base * proximity
        max_mult = maxf(max_mult, mult)
    return max_mult


func _get_core_config_inf_mult(core_id: int) -> float:
    for config in CORE_CONFIGS:
        if config.id == core_id:
            return config.get("inf_mult", 2.0)
    return 1.0


func _apply_influence_zone_boost():
    var boosted: int = 0
    for pos in blocks:
        var block = blocks[pos]
        if block.type == BlockType.CORE:
            continue
        var mult = _get_influence_hp_mult(pos, false)
        if mult > 1.0:
            block.hp *= mult
            block.max_hp *= mult
            boosted += 1
    if boosted > 0:
        print("[코어영향권] %d 블록 HP 강화 적용" % boosted)

    _count_zone_initial_blocks()


func _count_zone_initial_blocks():
    zone_initial_blocks.clear()
    zone_destroyed_blocks.clear()
    zone_current_blocks.clear()
    for pos in blocks:
        var block = blocks[pos]
        if block.type == BlockType.CORE:
            continue
        var zone = block.get("zone", get_zone(pos))
        zone_initial_blocks[zone] = zone_initial_blocks.get(zone, 0) + 1
    zone_current_blocks = zone_initial_blocks.duplicate()
    print("[구역블록] 초기 카운트 (코어제외): %s" % str(zone_initial_blocks))



func get_zone_destruction_ratio(zone: int) -> float:
    var initial = zone_initial_blocks.get(zone, 0)
    if initial <= 0:
        return 0.0
    var remaining = zone_current_blocks.get(zone, 0)
    return clampf(1.0 - float(remaining) / float(initial), 0.0, 1.0)





func _place_cores():
    for config in CORE_CONFIGS:
        var core_id: int = config.id
        var core_size: int = config.size
        var dist: float = float(config.dist)


        var cx: int = 0
        var cy: int = 0
        if dist > 0:
            var angle_rad: float = deg_to_rad(float(config.angle_deg))
            cx = int(round(cos(angle_rad) * dist))
            cy = int(round(sin(angle_rad) * dist))
        var center: = Vector2i(cx, cy)


        var block_count: int = core_size * core_size
        var core_hp: float = float(config.total_hp)


        var base_res: = _calc_block_resource(center)
        var core_res: float = base_res * config.res_mult * block_count


        core_hp *= Global.get_core_difficulty_mult()


        var depth_ratio: float = 1.0 - (dist / PLANET_RADIUS) if dist > 0 else 1.0
        cores.append({
            "id": core_id, 
            "center": center, 
            "size": core_size, 
            "influence_radius": config.influence, 
            "alive": true, 
            "depth": depth_ratio, 
            "zone": config.zone, 
            "role": config.role, 
        })


        var half: int = core_size / 2
        for dx in range( - half, half + core_size % 2):
            for dy in range( - half, half + core_size % 2):
                var pos: = Vector2i(center.x + dx, center.y + dy)
                if pos.x * pos.x + pos.y * pos.y <= PLANET_RADIUS * PLANET_RADIUS:

                    blocks[pos] = {
                        "type": BlockType.CORE, 
                        "hp": core_hp, 
                        "max_hp": core_hp, 
                        "resource": core_res / float(block_count), 
                        "core_id": core_id, 
                        "zone": config.zone, 
                    }


    for zone_id in [Zone.SPRING, Zone.SUMMER, Zone.AUTUMN, Zone.WINTER, Zone.CENTER]:
        var zone_cores = []
        for core in cores:
            if core.zone == zone_id:
                zone_cores.append("#%d(%s)" % [core.id, core.role])
        if zone_cores.size() > 0:
            print("[코어배치] %s: %s" % [get_zone_name(zone_id), ", ".join(zone_cores)])








const CORE_INDIRECT_DR: float = 0.15

func damage_block(pos: Vector2i, damage: float, indirect: bool = false) -> Dictionary:
    if not blocks.has(pos):
        return {"destroyed": false, "type": -1, "resource": 0.0}


    if Global.IS_DEMO and get_zone(pos) != Zone.SPRING:
        return {"destroyed": false, "type": blocks[pos].type, "resource": 0.0, "demo_locked": true}


    if get_zone(pos) == Zone.CENTER and not Global.center_unlock_unlocked:
        return {"destroyed": false, "type": blocks[pos].type, "resource": 0.0, "shielded": true}

    var block = blocks[pos]


    if block.type == BlockType.CORE and block.core_id >= 0:
        var actual_dmg = damage * CORE_INDIRECT_DR if indirect else damage
        return _damage_core(pos, block.core_id, actual_dmg)


    block.hp -= damage
    if block.hp <= 0:
        var block_resource = block.resource
        var block_type = block.type

        if block_type == BlockType.GOLD and Global.gold_unlocked:
            block_resource *= GOLD_RESOURCE_MULT
        var block_zone = block.get("zone", get_zone(pos))
        blocks.erase(pos)
        minimap_block_erased.emit(pos)
        _update_edges_around(pos)

        if block_type != BlockType.THORN:
            zone_destroyed_blocks[block_zone] = zone_destroyed_blocks.get(block_zone, 0) + 1
            zone_current_blocks[block_zone] = maxi(zone_current_blocks.get(block_zone, 0) - 1, 0)

        _check_final_core_exposure(pos)
        return {"destroyed": true, "type": block_type, "resource": block_resource}

    return {"destroyed": false, "type": block.type, "resource": 0.0}


func _damage_core(hit_pos: Vector2i, core_id: int, damage: float) -> Dictionary:
    var core = _get_core_by_id(core_id)
    if core == null or not core.alive:
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0}


    if is_core_locked(core_id):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "shielded": true}


    var center = core.center
    var core_size: int = core.get("size", 3)
    var half: int = core_size / 2
    var any_hp_left = false

    for dx in range( - half, half + core_size % 2):
        for dy in range( - half, half + core_size % 2):
            var pos = Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and blocks[pos].core_id == core_id:
                blocks[pos].hp -= damage
                if blocks[pos].hp > 0:
                    any_hp_left = true

    if not any_hp_left:

        if core_id == FINAL_CORE_ID and not final_boss_active:

            for dx2 in range( - half, half + core_size % 2):
                for dy2 in range( - half, half + core_size % 2):
                    var pos2 = Vector2i(center.x + dx2, center.y + dy2)
                    if blocks.has(pos2) and blocks[pos2].core_id == core_id:
                        blocks[pos2].hp = maxf(blocks[pos2].hp, 1.0)
            final_core_exposed.emit()
            print("[PlanetData] 💀 최종 코어 HP 소진 → 보스전 자동 트리거! (파괴 방지)")
            return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "boss_triggered": true}


        if core_id == FINAL_CORE_ID and final_boss_active and final_core_phase >= 1 and final_core_phase < 4:
            final_core_phase_depleted.emit(final_core_phase)
            print("[PlanetData] 💀 최종 코어 페이즈 %d HP 소진! 전환 대기" % final_core_phase)
            return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "phase_depleted": true}


        var total_resource = 0.0
        var erased_positions: Array = []
        var core_zone = core.get("zone", 0)
        for dx in range( - half, half + core_size % 2):
            for dy in range( - half, half + core_size % 2):
                var pos = Vector2i(center.x + dx, center.y + dy)
                if blocks.has(pos) and blocks[pos].core_id == core_id:
                    total_resource += blocks[pos].resource
                    blocks.erase(pos)
                    minimap_block_erased.emit(pos)
                    erased_positions.append(pos)

                    zone_destroyed_blocks[core_zone] = zone_destroyed_blocks.get(core_zone, 0) + 1

        _update_edges_batch(erased_positions)
        _on_core_destroyed(core)
        return {"destroyed": true, "type": BlockType.CORE, "resource": total_resource}


    return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0}


func _get_core_by_id(core_id: int) -> Variant:
    for core in cores:
        if core.id == core_id:
            return core
    return null


var on_core_destroyed_callback: Callable = Callable()


var final_boss_active: bool = false
var final_core_phase: int = 0
var _final_core_exposed_emitted: bool = false
signal final_core_exposed()
signal final_core_phase_depleted(phase: int)


signal minimap_block_erased(pos: Vector2i)
signal minimap_block_spawned(pos: Vector2i, type: int)

func _on_core_destroyed(core: Dictionary):
    core.alive = false

    _rebuild_proximity_cache()
    print("[PlanetData] ★ 코어 #%d (%s %s) 파괴! 영향 반경: %d" % [
        core.id, get_zone_name(core.zone), core.role, core.influence_radius
    ])

    var zone = core.zone
    if core.role == "boss":
        var next_zone = zone + 1
        if next_zone <= Zone.CENTER:
            print("[PlanetData] 🔓 %s 해금!" % get_zone_name(next_zone))

    if on_core_destroyed_callback.is_valid():
        on_core_destroyed_callback.call(core)


func convert_to_gold(pos: Vector2i) -> bool:
    if not blocks.has(pos):
        return false
    var block = blocks[pos]
    if block.type != BlockType.NORMAL:
        return false
    if block.get("regenerated", false):
        return false
    block.type = BlockType.GOLD
    block.converted_gold = true

    block.hp = block.max_hp
    return true


func has_block(pos: Vector2i) -> bool:
    return blocks.has(pos)


func get_block_type(pos: Vector2i) -> int:
    if blocks.has(pos):
        return blocks[pos].type
    return -1


func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(world_pos.x / BLOCK_SIZE)), 
        int(floor(world_pos.y / BLOCK_SIZE))
    )


func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        grid_pos.x * BLOCK_SIZE + BLOCK_SIZE * 0.5, 
        grid_pos.y * BLOCK_SIZE + BLOCK_SIZE * 0.5
    )







func get_core_proximity(pos: Vector2i) -> float:
    return proximity_cache.get(pos, 0.0)



func _rebuild_proximity_cache():
    proximity_cache.clear()
    var pulse_range = 8
    for core in cores:
        if not core.alive:
            continue
        var center = core.center

        for dx in range( - pulse_range, pulse_range + 1):
            for dy in range( - pulse_range, pulse_range + 1):
                var dist_sq = dx * dx + dy * dy
                if dist_sq >= pulse_range * pulse_range:
                    continue
                var pos = Vector2i(center.x + dx, center.y + dy)
                if not blocks.has(pos):
                    continue
                var dist = sqrt(float(dist_sq))
                var prox = 1.0 - (dist / pulse_range)

                if prox > proximity_cache.get(pos, 0.0):
                    proximity_cache[pos] = prox


func _rebuild_proximity_cache_async(tree: SceneTree):
    proximity_cache.clear()
    var pulse_range = 8
    var batch_count = 0
    for core in cores:
        if not core.alive:
            continue
        var center = core.center
        for dx in range( - pulse_range, pulse_range + 1):
            for dy in range( - pulse_range, pulse_range + 1):
                var dist_sq = dx * dx + dy * dy
                if dist_sq >= pulse_range * pulse_range:
                    continue
                var pos = Vector2i(center.x + dx, center.y + dy)
                if not blocks.has(pos):
                    continue
                var dist = sqrt(float(dist_sq))
                var prox = 1.0 - (dist / pulse_range)
                if prox > proximity_cache.get(pos, 0.0):
                    proximity_cache[pos] = prox
                batch_count += 1
                if batch_count >= GENERATE_BATCH_SIZE:
                    batch_count = 0
                    await tree.process_frame






func _calc_edges(pos: Vector2i) -> int:
    var mask = 0
    if not blocks.has(pos + Vector2i(0, -1)): mask |= 1
    if not blocks.has(pos + Vector2i(0, 1)): mask |= 2
    if not blocks.has(pos + Vector2i(-1, 0)): mask |= 4
    if not blocks.has(pos + Vector2i(1, 0)): mask |= 8
    return mask


func _rebuild_exposed_edges():
    exposed_edges.clear()
    for pos in blocks:
        exposed_edges[pos] = _calc_edges(pos)


func _rebuild_exposed_edges_async(tree: SceneTree) -> void :
    exposed_edges.clear()
    var batch_count = 0
    for pos in blocks:
        exposed_edges[pos] = _calc_edges(pos)
        batch_count += 1
        if batch_count >= GENERATE_BATCH_SIZE:
            batch_count = 0
            await tree.process_frame


func _update_edges_around(pos: Vector2i):

    if blocks.has(pos):
        exposed_edges[pos] = _calc_edges(pos)
    else:
        exposed_edges.erase(pos)

    for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
        var npos = pos + neighbor
        if blocks.has(npos):
            exposed_edges[npos] = _calc_edges(npos)


func _update_edges_batch(positions: Array):

    var dirty: Dictionary = {}
    for pos in positions:
        dirty[pos] = true
        for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
            dirty[pos + neighbor] = true
    for pos in dirty:
        if blocks.has(pos):
            exposed_edges[pos] = _calc_edges(pos)
        else:
            exposed_edges.erase(pos)


func is_in_dead_core_zone(pos: Vector2i) -> bool:
    for core in cores:
        if core.alive:
            continue
        var center = core.center
        var dx = pos.x - center.x
        var dy = pos.y - center.y
        if dx * dx + dy * dy <= core.influence_radius * core.influence_radius:
            return true
    return false


func get_nearest_alive_core(pos: Vector2i) -> Dictionary:
    var best_dist = INF
    var best_core = {}
    for core in cores:
        if not core.alive:
            continue
        var dx = pos.x - core.center.x
        var dy = pos.y - core.center.y
        var dist = sqrt(float(dx * dx + dy * dy))
        if dist < best_dist:
            best_dist = dist
            best_core = core
    return best_core






func revert_converted_gold():
    var count: int = 0
    for pos in blocks:
        var block = blocks[pos]
        if block.get("converted_gold", false):
            block.type = BlockType.NORMAL
            block.erase("converted_gold")
            count += 1
    if count > 0:
        print("[금블록] 충격파 변환 %d개 되돌림" % count)

func regenerate_around_cores():

    for pos in blocks:
        var block = blocks[pos]
        if block.type == BlockType.CORE and block.core_id >= 0:
            var core = _get_core_by_id(block.core_id)
            if core and core.alive:
                block.hp = block.max_hp

    var regenerated = 0
    var regen_positions: Array = []

    for core in cores:
        if not core.alive:
            continue

        var center = core.center
        var radius = core.influence_radius
        var radius_sq = radius * radius

        for x in range(center.x - radius, center.x + radius + 1):
            for y in range(center.y - radius, center.y + radius + 1):
                var pos = Vector2i(x, y)
                var dx = x - center.x
                var dy = y - center.y

                if dx * dx + dy * dy <= radius_sq\
and pos.x * pos.x + pos.y * pos.y <= PLANET_RADIUS * PLANET_RADIUS\
and not blocks.has(pos):

                    if is_in_dead_core_zone(pos):
                        continue

                    var hp = _calc_block_hp(pos)
                    var res = _calc_block_resource(pos)

                    var regen_type = BlockType.NORMAL
                    var regen_roll = randf()
                    if regen_roll < GOLD_CHANCE:
                        regen_type = BlockType.GOLD
                    elif regen_roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                        regen_type = BlockType.ELECTRIC

                    var influence_mult = _get_influence_hp_mult(pos, true)
                    if influence_mult > 1.0:
                        hp *= influence_mult

                    var zone = get_zone(pos)
                    blocks[pos] = {
                        "type": regen_type, 
                        "hp": hp, 
                        "max_hp": hp, 
                        "resource": res, 
                        "core_id": -1, 
                        "zone": zone, 
                        "regenerated": true, 
                    }
                    zone_current_blocks[zone] = zone_current_blocks.get(zone, 0) + 1
                    regen_positions.append(pos)
                    regenerated += 1

    if regenerated > 0:
        _update_edges_batch(regen_positions)
        print("[PlanetData] 코어 재생: %d 블록 복구" % regenerated)


func regenerate_around_cores_async(tree: SceneTree):

    for pos in blocks:
        var block = blocks[pos]
        if block.type == BlockType.CORE and block.core_id >= 0:
            var core = _get_core_by_id(block.core_id)
            if core and core.alive:
                block.hp = block.max_hp

    var regenerated = 0
    var regen_positions: Array = []
    var batch_count = 0

    for core in cores:
        if not core.alive:
            continue
        var center = core.center
        var radius = core.influence_radius
        var radius_sq = radius * radius

        for x in range(center.x - radius, center.x + radius + 1):
            for y in range(center.y - radius, center.y + radius + 1):
                var pos = Vector2i(x, y)
                var dx = x - center.x
                var dy = y - center.y

                if dx * dx + dy * dy <= radius_sq\
and pos.x * pos.x + pos.y * pos.y <= PLANET_RADIUS * PLANET_RADIUS\
and not blocks.has(pos):

                    if is_in_dead_core_zone(pos):
                        continue

                    var hp = _calc_block_hp(pos)
                    var res = _calc_block_resource(pos)

                    var regen_type = BlockType.NORMAL
                    var regen_roll = randf()
                    if regen_roll < GOLD_CHANCE:
                        regen_type = BlockType.GOLD
                    elif regen_roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                        regen_type = BlockType.ELECTRIC

                    var influence_mult = _get_influence_hp_mult(pos, true)
                    if influence_mult > 1.0:
                        hp *= influence_mult

                    var zone = get_zone(pos)
                    blocks[pos] = {
                        "type": regen_type, 
                        "hp": hp, 
                        "max_hp": hp, 
                        "resource": res, 
                        "core_id": -1, 
                        "zone": zone, 
                        "regenerated": true, 
                    }
                    zone_current_blocks[zone] = zone_current_blocks.get(zone, 0) + 1
                    regen_positions.append(pos)
                    regenerated += 1
                    batch_count += 1
                    if batch_count >= GENERATE_BATCH_SIZE:
                        batch_count = 0
                        await tree.process_frame

    if regenerated > 0:
        _update_edges_batch(regen_positions)
        print("[PlanetData] 코어 재생(비동기): %d 블록 복구" % regenerated)





func get_total_blocks() -> int:
    return blocks.size()

func get_alive_cores() -> int:
    var count = 0
    for core in cores:
        if core.alive:
            count += 1
    return count

func get_total_cores() -> int:
    return cores.size()

func is_final_core_destroyed() -> bool:
    for core in cores:
        if core.id == FINAL_CORE_ID:
            return not core.alive
    return false






func _check_final_core_exposure(destroyed_pos: Vector2i):
    if _final_core_exposed_emitted or final_boss_active:
        return
    var fc = _get_core_by_id(FINAL_CORE_ID)
    if fc == null or not fc.alive:
        return

    var half: int = fc.size / 2
    for dx in range( - half, half + fc.size % 2):
        for dy in range( - half, half + fc.size % 2):
            var core_pos = Vector2i(fc.center.x + dx, fc.center.y + dy)

            for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
                if core_pos + neighbor == destroyed_pos:
                    _final_core_exposed_emitted = true
                    final_core_exposed.emit()
                    print("[PlanetData] 💀 최종 코어 노출! 보스전 트리거")
                    return



func get_arena_rings(radius: int, ring_step: int = 3) -> Array:
    var fc = _get_core_by_id(FINAL_CORE_ID)
    if fc == null:
        return []
    var center = fc.center
    var radius_sq = radius * radius


    var ring_count = ceili(float(radius) / ring_step)
    var rings: Array = []
    for i in range(ring_count):
        rings.append([])

    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            var pos = Vector2i(x, y)
            var dx = x - center.x
            var dy = y - center.y
            var dist_sq = dx * dx + dy * dy
            if dist_sq > radius_sq:
                continue
            if not blocks.has(pos):
                continue
            if blocks[pos].type == BlockType.CORE:
                continue

            var dist = sqrt(float(dist_sq))
            var ring_idx = mini(int(dist / ring_step), ring_count - 1)
            rings[ring_idx].append(pos)

    var total = 0
    for ring in rings:
        total += ring.size()
    print("[PlanetData] 💀 아레나 링 준비: 반경 %d, %d링, 총 %d블록" % [radius, rings.size(), total])
    return rings


func erase_arena_ring(ring_positions: Array) -> void :
    for pos in ring_positions:
        if blocks.has(pos) and blocks[pos].type != BlockType.CORE:
            var block = blocks[pos]
            var zone = block.get("zone", get_zone(pos))
            blocks.erase(pos)
            minimap_block_erased.emit(pos)

            if block.type != BlockType.THORN:
                zone_destroyed_blocks[zone] = zone_destroyed_blocks.get(zone, 0) + 1
                zone_current_blocks[zone] = maxi(zone_current_blocks.get(zone, 0) - 1, 0)
    if ring_positions.size() > 0:
        _update_edges_batch(ring_positions)


func reset_final_core_hp():
    var fc = _get_core_by_id(FINAL_CORE_ID)
    if fc == null or not fc.alive:
        return
    var center = fc.center
    var half: int = fc.size / 2
    for dx in range( - half, half + fc.size % 2):
        for dy in range( - half, half + fc.size % 2):
            var pos = Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and blocks[pos].core_id == FINAL_CORE_ID:
                blocks[pos].hp = blocks[pos].max_hp
    print("[PlanetData] 💀 최종 코어 HP 리셋 (페이즈 %d)" % final_core_phase)


func get_final_core() -> Variant:
    return _get_core_by_id(FINAL_CORE_ID)





func electric_chain(origin: Vector2i, damage: float, chain_range: int, chain_depth: int, _current_depth: int = 0) -> Array:
    var results: Array = []
    if _current_depth >= chain_depth:
        return results

    var targets: Array = []
    for dx in range( - chain_range, chain_range + 1):
        for dy in range( - chain_range, chain_range + 1):
            if dx == 0 and dy == 0:
                continue
            var pos = Vector2i(origin.x + dx, origin.y + dy)
            if not blocks.has(pos):
                continue
            if abs(dx) + abs(dy) <= chain_range:
                targets.append(pos)

    for pos in targets:
        if not blocks.has(pos):
            continue
        var block = blocks[pos]

        if block.type == BlockType.CORE and block.core_id >= 0:
            var core_result = _damage_core(pos, block.core_id, damage * CORE_INDIRECT_DR)
            if core_result.destroyed:
                results.append({
                    "pos": pos, 
                    "destroyed": true, 
                    "type": BlockType.CORE, 
                    "resource": core_result.resource, 
                })
            continue

        block.hp -= damage
        if block.hp <= 0:
            var was_electric = block.type == BlockType.ELECTRIC
            var block_res = block.resource
            var block_type = block.type
            var block_zone = block.get("zone", get_zone(pos))
            blocks.erase(pos)
            minimap_block_erased.emit(pos)


            if block_type != BlockType.THORN:
                zone_destroyed_blocks[block_zone] = zone_destroyed_blocks.get(block_zone, 0) + 1
                zone_current_blocks[block_zone] = maxi(zone_current_blocks.get(block_zone, 0) - 1, 0)

            results.append({
                "pos": pos, 
                "destroyed": true, 
                "type": block_type, 
                "resource": block_res, 
            })

            if was_electric:
                var sub = electric_chain(pos, damage, chain_range, chain_depth, _current_depth + 1)
                results.append_array(sub)
        else:
            results.append({
                "pos": pos, 
                "destroyed": false, 
                "type": block.type, 
                "resource": 0.0, 
            })

    return results





const THORN_HP_MULT: float = 0.5


func spawn_thorn_blocks(core: Dictionary, count: int) -> int:
    var center = core.center
    var radius = core.influence_radius
    var radius_sq = radius * radius
    var planet_r_sq = PLANET_RADIUS * PLANET_RADIUS


    var empty_spots: Array = []
    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            var pos = Vector2i(x, y)
            var dx = x - center.x
            var dy = y - center.y
            if dx * dx + dy * dy <= radius_sq\
and pos.x * pos.x + pos.y * pos.y <= planet_r_sq\
and not blocks.has(pos):
                if not is_in_dead_core_zone(pos):
                    empty_spots.append(pos)

    if empty_spots.is_empty():
        return 0

    empty_spots.shuffle()
    var actual_count = mini(count, empty_spots.size())

    for i in range(actual_count):
        var pos = empty_spots[i]
        var hp = _calc_block_hp(pos) * THORN_HP_MULT


        var influence_mult = _get_influence_hp_mult(pos, true)
        if influence_mult > 1.0:
            hp *= influence_mult

        var zone = get_zone(pos)
        blocks[pos] = {
            "type": BlockType.THORN, 
            "hp": hp, 
            "max_hp": hp, 
            "resource": 0.0, 
            "core_id": -1, 
            "zone": zone, 
            "regenerated": true, 
            "birth_time": Time.get_ticks_msec() * 0.001, 
        }
        minimap_block_spawned.emit(pos, BlockType.THORN)
        _update_edges_around(pos)

    return actual_count



func spawn_thorn_ring(core: Dictionary, ring_min: int, ring_max: int) -> int:
    var center = core.center
    var radius = core.influence_radius
    var planet_r_sq = PLANET_RADIUS * PLANET_RADIUS
    var ring_min_sq = ring_min * ring_min
    var ring_max_sq = ring_max * ring_max
    var spawned: int = 0
    var spawn_positions: Array = []


    var scan = mini(ring_max, radius)
    for x in range(center.x - scan, center.x + scan + 1):
        for y in range(center.y - scan, center.y + scan + 1):
            var pos = Vector2i(x, y)
            var dx = x - center.x
            var dy = y - center.y
            var dist_sq = dx * dx + dy * dy

            if dist_sq < ring_min_sq or dist_sq >= ring_max_sq:
                continue
            if pos.x * pos.x + pos.y * pos.y > planet_r_sq:
                continue
            if blocks.has(pos):
                continue
            if is_in_dead_core_zone(pos):
                continue

            var hp = _calc_block_hp(pos) * THORN_HP_MULT

            var influence_mult = _get_influence_hp_mult(pos, true)
            if influence_mult > 1.0:
                hp *= influence_mult

            var zone = get_zone(pos)
            blocks[pos] = {
                "type": BlockType.THORN, 
                "hp": hp, 
                "max_hp": hp, 
                "resource": 0.0, 
                "core_id": -1, 
                "zone": zone, 
                "regenerated": true, 
                "birth_time": Time.get_ticks_msec() * 0.001, 
            }
            minimap_block_spawned.emit(pos, BlockType.THORN)
            spawn_positions.append(pos)
            spawned += 1

    _update_edges_batch(spawn_positions)
    return spawned





func to_save_data() -> Dictionary:
    var block_data: = {}
    for pos in blocks:
        var b = blocks[pos]
        var key = "%d,%d" % [pos.x, pos.y]

        block_data[key] = [b.type, b.hp, b.max_hp, b.resource, b.core_id, b.get("regenerated", false), b.get("zone", 0)]

    var core_data: = []
    for c in cores:
        core_data.append({
            "id": c.id, 
            "center": [c.center.x, c.center.y], 
            "size": c.size, 
            "influence_radius": c.influence_radius, 
            "alive": c.alive, 
            "depth": c.depth, 
            "zone": c.zone, 
            "role": c.role, 
        })

    return {
        "blocks": block_data, 
        "cores": core_data, 
        "zone_initial_blocks": zone_initial_blocks, 
        "zone_destroyed_blocks": zone_destroyed_blocks, 
        "zone_current_blocks": zone_current_blocks, 
    }

func load_save_data(data: Dictionary) -> void :
    blocks.clear()
    cores.clear()

    var block_data = data.get("blocks", {})
    for key in block_data:
        var parts = key.split(",")
        var pos = Vector2i(int(parts[0]), int(parts[1]))
        var arr = block_data[key]
        blocks[pos] = {
            "type": int(arr[0]), 
            "hp": float(arr[1]), 
            "max_hp": float(arr[2]), 
            "resource": float(arr[3]), 
            "core_id": int(arr[4]), 
            "regenerated": bool(arr[5]) if arr.size() > 5 else false, 
            "zone": int(arr[6]) if arr.size() > 6 else get_zone(pos), 
        }

    var core_data = data.get("cores", [])
    for cd in core_data:
        var center_arr = cd.get("center", [0, 0])
        cores.append({
            "id": cd.id, 
            "center": Vector2i(int(center_arr[0]), int(center_arr[1])), 
            "size": cd.size, 
            "influence_radius": cd.influence_radius, 
            "alive": cd.alive, 
            "depth": cd.get("depth", 0.0), 
            "zone": cd.get("zone", get_core_zone(cd.id)), 
            "role": cd.get("role", get_core_role(cd.id)), 
        })


    zone_initial_blocks = data.get("zone_initial_blocks", {})
    zone_destroyed_blocks = data.get("zone_destroyed_blocks", {})
    zone_current_blocks = data.get("zone_current_blocks", {})
    if zone_initial_blocks.is_empty():

        _count_zone_initial_blocks()
        print("[구역블록] 구 세이브 — 현재 블록 기준 초기화")
    if zone_current_blocks.is_empty() and not zone_initial_blocks.is_empty():

        zone_current_blocks.clear()
        for pos in blocks:
            var block = blocks[pos]
            if block.type == BlockType.CORE:
                continue
            var zone = block.get("zone", get_zone(pos))
            zone_current_blocks[zone] = zone_current_blocks.get(zone, 0) + 1
        print("[구역블록] 구 세이브 — zone_current_blocks 재계산: %s" % str(zone_current_blocks))


    print("[PlanetData] 행성 로드: 블록 %d개, 코어 %d개 (캐시 빌드 대기중)" % [blocks.size(), cores.size()])


func rebuild_caches_async(tree: SceneTree):
    await _rebuild_proximity_cache_async(tree)
    await _rebuild_exposed_edges_async(tree)
