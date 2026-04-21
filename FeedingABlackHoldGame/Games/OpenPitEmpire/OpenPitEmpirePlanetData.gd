extends RefCounted
class_name OpenPitEmpirePlanetData

signal minimap_block_erased(pos: Vector2i)
signal minimap_block_spawned(pos: Vector2i, type: int)
signal final_core_exposed()
signal final_core_phase_depleted(phase: int)

const BLOCK_SIZE: int = 32
const PLANET_RADIUS: int = 280
const CENTER_RADIUS: int = 55
const ELECTRIC_CHANCE: float = 0.02
const GOLD_CHANCE: float = 0.02
const GOLD_RESOURCE_MULT: float = 5.0
const CORE_INDIRECT_DR: float = 0.15
const THORN_HP_MULT: float = 1.6
const FINAL_CORE_ID: int = 16
const SAVE_ANGLE_SLICES: int = 10
const SAVE_DEPTH_SLICES: int = 10
const SAVE_SECTION_COUNT: int = SAVE_ANGLE_SLICES * SAVE_DEPTH_SLICES

enum Zone { SPRING, SUMMER, AUTUMN, WINTER, CENTER }
enum BlockType { NORMAL, CORE, ELECTRIC, GOLD, THORN }

const CORE_CONFIGS := [
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

const ZONE_BOSS_IDS := {
    Zone.SPRING: 12,
    Zone.SUMMER: 13,
    Zone.AUTUMN: 14,
    Zone.WINTER: 15,
}

const ZONE_UNLOCK_REQUIRES := {
    Zone.SPRING: -1,
    Zone.SUMMER: 12,
    Zone.AUTUMN: 13,
    Zone.WINTER: 14,
    Zone.CENTER: 15,
}

const ZONE_BOSS_DIST := {
    Zone.SPRING: 180.0,
    Zone.SUMMER: 150.0,
    Zone.AUTUMN: 120.0,
    Zone.WINTER: 90.0,
    Zone.CENTER: 0.0,
}

const ZONE_HP_RANGE := {
    Zone.SPRING: {"min": 15.0, "max": 300.0},
    Zone.SUMMER: {"min": 200.0, "max": 12000.0},
    Zone.AUTUMN: {"min": 4000.0, "max": 220000.0},
    Zone.WINTER: {"min": 120000.0, "max": 20000000.0},
    Zone.CENTER: {"min": 5000000.0, "max": 120000000.0},
}

const ZONE_RES_RANGE := {
    Zone.SPRING: {"min": 5.0, "max": 100.0},
    Zone.SUMMER: {"min": 120.0, "max": 3500.0},
    Zone.AUTUMN: {"min": 3500.0, "max": 95000.0},
    Zone.WINTER: {"min": 60000.0, "max": 1500000.0},
    Zone.CENTER: {"min": 750000.0, "max": 12000000.0},
}

var blocks: Dictionary = {}
var cores: Array = []
var proximity_cache: Dictionary = {}
var zone_initial_blocks: Dictionary = {}
var zone_destroyed_blocks: Dictionary = {}
var zone_current_blocks: Dictionary = {}
var exposed_edges: Dictionary = {}
var _pending_edge_positions: Dictionary = {}
var initial_block_count: int = 0
var on_core_destroyed_callback: Callable = Callable()
var final_boss_active: bool = false
var final_core_phase: int = 0
var _final_core_exposed_emitted: bool = false
var balance_script: Variant = null
var world_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var core_difficulty_mult: float = 1.0
var _dirty_sections: Dictionary = {}
var _section_cells: Array = []
var _section_cells_ready: bool = false

static func get_zone(pos: Vector2i) -> int:
    var dist_sq: int = pos.x * pos.x + pos.y * pos.y
    if dist_sq <= CENTER_RADIUS * CENTER_RADIUS:
        return Zone.CENTER
    var angle: float = atan2(float(pos.y), float(pos.x))
    if angle >= -PI * 2.0 / 3.0 and angle < -PI / 3.0:
        return Zone.SPRING
    if angle >= -PI / 3.0 and angle < PI / 9.0:
        return Zone.SUMMER
    if angle >= PI / 9.0 and angle < PI * 2.0 / 3.0:
        return Zone.AUTUMN
    return Zone.WINTER

static func get_core_zone(core_id: int) -> int:
    for config in CORE_CONFIGS:
        if int(config.id) == core_id:
            return int(config.zone)
    return Zone.CENTER

static func get_core_role(core_id: int) -> String:
    for config in CORE_CONFIGS:
        if int(config.id) == core_id:
            return str(config.role)
    return "outer"

static func get_core_tier(core_id: int) -> int:
    match get_core_role(core_id):
        "outer":
            return 1
        "boss":
            return 2
        "final":
            return 3
        _:
            return 1

func generate_sync(_depth_level: int, _persistent_destroyed: Dictionary, balance_script_ref: Variant, rng: RandomNumberGenerator) -> void:
    balance_script = balance_script_ref
    world_rng = rng if rng != null else RandomNumberGenerator.new()
    _reset_generation_state()
    var radius_sq: int = PLANET_RADIUS * PLANET_RADIUS
    for x in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
            var pos := Vector2i(x, y)
            if x * x + y * y > radius_sq:
                continue
            var hp: float = _calc_block_hp(pos)
            var res: float = _calc_block_resource(pos)
            var zone: int = get_zone(pos)
            var block_type: int = BlockType.NORMAL
            var roll: float = world_rng.randf()
            if roll < GOLD_CHANCE:
                block_type = BlockType.GOLD
            elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                block_type = BlockType.ELECTRIC
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
    var persistent_removed_count := 0
    if not _persistent_destroyed.is_empty():
        var erased_positions: Array[Vector2i] = []
        for pos_variant in _persistent_destroyed.keys():
            var pos: Vector2i = pos_variant
            if not blocks.has(pos):
                continue
            var block_zone: int = int(blocks[pos].get("zone", get_zone(pos)))
            blocks.erase(pos)
            zone_destroyed_blocks[block_zone] = int(zone_destroyed_blocks.get(block_zone, 0)) + 1
            zone_current_blocks[block_zone] = maxi(int(zone_current_blocks.get(block_zone, 0)) - 1, 0)
            erased_positions.append(pos)
            persistent_removed_count += 1
        if not erased_positions.is_empty():
            _update_edges_batch(erased_positions)
    _rebuild_proximity_cache()
    _rebuild_exposed_edges()
    initial_block_count = blocks.size() + persistent_removed_count
    _mark_all_sections_dirty()

func generate_async(tree: SceneTree, _depth_level: int, _persistent_destroyed: Dictionary, balance_script_ref: Variant, rng: RandomNumberGenerator, progress_callback: Callable = Callable()) -> void:
    balance_script = balance_script_ref
    world_rng = rng if rng != null else RandomNumberGenerator.new()
    _reset_generation_state()
    _emit_generation_progress(progress_callback, 0.0)
    var radius_sq: int = PLANET_RADIUS * PLANET_RADIUS
    var total_columns: int = PLANET_RADIUS * 2 + 1
    for x in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
            var pos := Vector2i(x, y)
            if x * x + y * y > radius_sq:
                continue
            var hp: float = _calc_block_hp(pos)
            var res: float = _calc_block_resource(pos)
            var zone: int = get_zone(pos)
            var block_type: int = BlockType.NORMAL
            var roll: float = world_rng.randf()
            if roll < GOLD_CHANCE:
                block_type = BlockType.GOLD
            elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                block_type = BlockType.ELECTRIC
            blocks[pos] = {
                "type": block_type,
                "hp": hp,
                "max_hp": hp,
                "resource": res,
                "core_id": -1,
                "zone": zone,
            }
        var column_index: int = x + PLANET_RADIUS
        _emit_generation_progress(progress_callback, 0.8 * float(column_index + 1) / float(total_columns))
        if tree != null and ((column_index + 1) % 12 == 0):
            await tree.process_frame
    _place_cores()
    _emit_generation_progress(progress_callback, 0.86)
    if tree != null:
        await tree.process_frame
    _apply_influence_zone_boost()
    _emit_generation_progress(progress_callback, 0.92)
    if tree != null:
        await tree.process_frame
    _rebuild_proximity_cache()
    _emit_generation_progress(progress_callback, 0.97)
    if tree != null:
        await tree.process_frame
    _rebuild_exposed_edges()
    initial_block_count = blocks.size()
    _emit_generation_progress(progress_callback, 1.0)
    _mark_all_sections_dirty()

func _reset_generation_state() -> void:
    blocks.clear()
    cores.clear()
    exposed_edges.clear()
    proximity_cache.clear()
    zone_initial_blocks.clear()
    zone_destroyed_blocks.clear()
    zone_current_blocks.clear()
    final_boss_active = false
    final_core_phase = 0
    _final_core_exposed_emitted = false
    initial_block_count = 0
    _dirty_sections.clear()

func _emit_generation_progress(progress_callback: Callable, value: float) -> void:
    if progress_callback.is_valid():
        progress_callback.call(clampf(value, 0.0, 1.0))

func has_block(pos: Vector2i) -> bool:
    return blocks.has(pos)

func get_block_type(pos: Vector2i) -> int:
    if blocks.has(pos):
        return int(blocks[pos].get("type", -1))
    return -1

func is_zone_unlocked(zone: int, free_planet_mode: bool = false) -> bool:
    if free_planet_mode:
        return true
    var required_boss_id: int = int(ZONE_UNLOCK_REQUIRES.get(zone, -1))
    if required_boss_id < 0:
        return true
    var boss: Variant = _get_core_by_id(required_boss_id)
    return boss != null and not bool(boss.alive)

func is_core_locked(core_id: int, free_planet_mode: bool = false) -> bool:
    if free_planet_mode:
        return false
    var zone: int = get_core_zone(core_id)
    if not is_zone_unlocked(zone, free_planet_mode):
        return true
    var role: String = get_core_role(core_id)
    if role == "boss":
        return get_alive_outer_in_zone(zone) > 0
    if role == "final":
        for boss_id_variant in ZONE_BOSS_IDS.values():
            var boss: Variant = _get_core_by_id(int(boss_id_variant))
            if boss != null and bool(boss.alive):
                return true
    return false

func get_alive_outer_in_zone(zone: int) -> int:
    var count := 0
    for core in cores:
        if bool(core.alive) and int(core.zone) == zone and str(core.role) == "outer":
            count += 1
    return count

func get_alive_cores_in_zone(zone: int) -> int:
    var count := 0
    for core in cores:
        if bool(core.alive) and int(core.zone) == zone:
            count += 1
    return count

func get_alive_cores_in_tier(tier: int) -> int:
    var count := 0
    for core in cores:
        if bool(core.alive) and get_core_tier(int(core.id)) == tier:
            count += 1
    return count

func get_destroyed_in_tier(tier: int) -> int:
    var count := 0
    for core in cores:
        if not bool(core.alive) and get_core_tier(int(core.id)) == tier:
            count += 1
    return count

func get_active_core_behaviors() -> Dictionary:
    var alive_t2: int = get_alive_cores_in_tier(2)
    var alive_t3: int = get_alive_cores_in_tier(3)
    return {
        "regen_boost": alive_t2 > 0 or alive_t3 > 0,
        "defense_blocks": alive_t2 > 0,
        "shockwave": alive_t2 > 0 or alive_t3 > 0,
        "final_rage": alive_t3 > 0 and alive_t2 == 0 and get_alive_cores_in_tier(1) == 0,
        "destroyed_t1": get_destroyed_in_tier(1),
    }

func spawn_defense_blocks() -> Array[Vector2i]:
    var spawned_positions: Array[Vector2i] = []
    var used := {}
    for core in cores:
        if not bool(core.alive):
            continue
        if get_core_tier(int(core.id)) < 2:
            continue
        var radius: int = int(core.influence_radius)
        for _attempt in range(5):
            var angle: float = world_rng.randf() * TAU
            var dist: float = world_rng.randf_range(float(radius) * 0.45, float(radius) * 0.95)
            var pos := Vector2i(
                int(round(float(core.center.x) + cos(angle) * dist)),
                int(round(float(core.center.y) + sin(angle) * dist))
            )
            if used.has(pos) or pos.x * pos.x + pos.y * pos.y > PLANET_RADIUS * PLANET_RADIUS:
                continue
            if blocks.has(pos):
                continue
            var hp: float = _calc_block_hp(pos) * THORN_HP_MULT
            var influence_mult: float = _get_influence_hp_mult(pos, true)
            hp *= influence_mult
            blocks[pos] = {
                "type": BlockType.THORN,
                "hp": hp,
                "max_hp": hp,
                "resource": 0.0,
                "core_id": -1,
                "zone": get_zone(pos),
                "regenerated": true,
            }
            minimap_block_spawned.emit(pos, BlockType.THORN)
            _update_edges_around(pos)
            zone_current_blocks[int(blocks[pos].zone)] = int(zone_current_blocks.get(int(blocks[pos].zone), 0)) + 1
            _mark_section_dirty(pos)
            used[pos] = true
            spawned_positions.append(pos)
            break
    return spawned_positions

func spawn_thorn_ring(core: Dictionary, ring_min: int, ring_max: int) -> int:
    var center: Vector2i = core.center
    var scan: int = mini(ring_max, int(core.influence_radius))
    var ring_min_sq: int = ring_min * ring_min
    var ring_max_sq: int = ring_max * ring_max
    var spawned := 0
    var regen_positions: Array[Vector2i] = []
    for x in range(center.x - scan, center.x + scan + 1):
        for y in range(center.y - scan, center.y + scan + 1):
            var pos := Vector2i(x, y)
            var dx: int = x - center.x
            var dy: int = y - center.y
            var dist_sq: int = dx * dx + dy * dy
            if dist_sq < ring_min_sq or dist_sq >= ring_max_sq:
                continue
            if pos.x * pos.x + pos.y * pos.y > PLANET_RADIUS * PLANET_RADIUS:
                continue
            if blocks.has(pos) or is_in_dead_core_zone(pos):
                continue
            var hp: float = _calc_block_hp(pos) * THORN_HP_MULT
            hp *= _get_influence_hp_mult(pos, true)
            blocks[pos] = {
                "type": BlockType.THORN,
                "hp": hp,
                "max_hp": hp,
                "resource": 0.0,
                "core_id": -1,
                "zone": get_zone(pos),
                "regenerated": true,
                "birth_time": Time.get_ticks_msec() * 0.001,
            }
            minimap_block_spawned.emit(pos, BlockType.THORN)
            regen_positions.append(pos)
            spawned += 1
    if not regen_positions.is_empty():
        _update_edges_batch(regen_positions)
        _mark_dirty_positions(regen_positions)
    return spawned

func get_shockwave_cores() -> Array:
    var result: Array = []
    for core in cores:
        if not bool(core.alive):
            continue
        if get_core_tier(int(core.id)) >= 2:
            result.append(core)
    return result

func get_effective_influence_radius(core: Dictionary) -> int:
    return int(core.get("influence_radius", 0)) + get_regen_radius_bonus(core)

func get_regen_radius_bonus(core: Dictionary) -> int:
    return 2 if str(core.get("role", "")) == "final" else 0

func get_core_hp_ratio(core: Dictionary) -> float:
    var total_hp := 0.0
    var total_max := 0.0
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(int(core.center.x) + dx, int(core.center.y) + dy)
            var block: Dictionary = blocks.get(pos, {})
            if not block.is_empty() and int(block.get("core_id", -1)) == int(core.get("id", -1)):
                total_hp += float(block.get("hp", 0.0))
                total_max += float(block.get("max_hp", 0.0))
    if total_max <= 0.0:
        return 0.0
    return clampf(total_hp / total_max, 0.0, 1.0)

func is_in_dead_core_zone(pos: Vector2i) -> bool:
    for core in cores:
        if bool(core.alive):
            continue
        var dx: int = pos.x - int(core.center.x)
        var dy: int = pos.y - int(core.center.y)
        var radius: int = int(core.influence_radius)
        if dx * dx + dy * dy <= radius * radius:
            return true
    return false

func damage_block(pos: Vector2i, damage: float, indirect: bool = false, free_planet_mode: bool = false) -> Dictionary:
    if not blocks.has(pos):
        return {"destroyed": false, "type": -1, "resource": 0.0}
    var block: Dictionary = blocks[pos]
    if int(block.get("type", BlockType.CORE)) == BlockType.CORE and int(block.get("core_id", -1)) >= 0:
        var actual_damage: float = damage * CORE_INDIRECT_DR if indirect else damage
        return _damage_core(pos, int(block.get("core_id", -1)), actual_damage, free_planet_mode)
    block["hp"] = float(block.get("hp", 0.0)) - damage
    if float(block.get("hp", 0.0)) <= 0.0:
        var block_resource: float = float(block.get("resource", 0.0))
        var block_type: int = int(block.get("type", BlockType.NORMAL))
        if block_type == BlockType.GOLD:
            block_resource *= GOLD_RESOURCE_MULT
        var block_zone: int = int(block.get("zone", get_zone(pos)))
        blocks.erase(pos)
        minimap_block_erased.emit(pos)
        _queue_edge_update(pos)
        _mark_section_dirty(pos)
        if block_type != BlockType.THORN:
            zone_destroyed_blocks[block_zone] = int(zone_destroyed_blocks.get(block_zone, 0)) + 1
            zone_current_blocks[block_zone] = maxi(int(zone_current_blocks.get(block_zone, 0)) - 1, 0)
        _check_final_core_exposure(pos)
        return {"destroyed": true, "type": block_type, "resource": block_resource}
    blocks[pos] = block
    _mark_section_dirty(pos)
    return {"destroyed": false, "type": int(block.get("type", BlockType.NORMAL)), "resource": 0.0}

func convert_to_gold(pos: Vector2i) -> bool:
    if not blocks.has(pos):
        return false
    var block: Dictionary = blocks[pos]
    if int(block.get("type", BlockType.NORMAL)) != BlockType.NORMAL:
        return false
    if bool(block.get("regenerated", false)):
        return false
    block["type"] = BlockType.GOLD
    block["converted_gold"] = true
    block["hp"] = float(block.get("max_hp", 1.0))
    blocks[pos] = block
    minimap_block_spawned.emit(pos, BlockType.GOLD)
    _mark_section_dirty(pos)
    return true

func revert_converted_gold() -> void:
    var changed_positions: Array[Vector2i] = []
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        if bool(block.get("converted_gold", false)):
            block["type"] = BlockType.NORMAL
            block.erase("converted_gold")
            blocks[pos] = block
            minimap_block_spawned.emit(pos, BlockType.NORMAL)
            changed_positions.append(pos)
    if not changed_positions.is_empty():
        _mark_dirty_positions(changed_positions)

func regenerate_around_cores() -> int:
    var changed_positions: Array[Vector2i] = []
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE and int(block.get("core_id", -1)) >= 0:
            var core: Variant = _get_core_by_id(int(block.get("core_id", -1)))
            if core != null and bool(core.alive):
                block["hp"] = float(block.get("max_hp", 0.0))
                blocks[pos] = block
                changed_positions.append(pos)
    var regenerated := 0
    var regen_positions: Array[Vector2i] = []
    for core in cores:
        if not bool(core.alive):
            continue
        var radius: int = get_effective_influence_radius(core)
        var center: Vector2i = core.center
        for x in range(center.x - radius, center.x + radius + 1):
            for y in range(center.y - radius, center.y + radius + 1):
                var pos := Vector2i(x, y)
                var dx: int = x - center.x
                var dy: int = y - center.y
                if dx * dx + dy * dy > radius * radius:
                    continue
                if pos.x * pos.x + pos.y * pos.y > PLANET_RADIUS * PLANET_RADIUS:
                    continue
                if blocks.has(pos) or is_in_dead_core_zone(pos):
                    continue
                var hp: float = _calc_block_hp(pos)
                var res: float = _calc_block_resource(pos)
                var regen_type: int = BlockType.NORMAL
                var roll: float = world_rng.randf()
                if roll < GOLD_CHANCE:
                    regen_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    regen_type = BlockType.ELECTRIC
                hp *= _get_influence_hp_mult(pos, true)
                var zone: int = get_zone(pos)
                blocks[pos] = {
                    "type": regen_type,
                    "hp": hp,
                    "max_hp": hp,
                    "resource": res,
                    "core_id": -1,
                    "zone": zone,
                    "regenerated": true,
                }
                zone_current_blocks[zone] = int(zone_current_blocks.get(zone, 0)) + 1
                minimap_block_spawned.emit(pos, regen_type)
                regen_positions.append(pos)
                regenerated += 1
    if not regen_positions.is_empty():
        _queue_edge_updates(regen_positions)
        changed_positions.append_array(regen_positions)
    if not changed_positions.is_empty():
        _mark_dirty_positions(changed_positions)
    return regenerated

func electric_chain(origin: Vector2i, damage: float, chain_range: int, chain_depth: int, current_depth: int = 0, free_planet_mode: bool = false) -> Array:
    var results: Array = []
    if current_depth >= chain_depth:
        return results
    var targets: Array[Vector2i] = []
    for dx in range(-chain_range, chain_range + 1):
        for dy in range(-chain_range, chain_range + 1):
            if dx == 0 and dy == 0:
                continue
            if abs(dx) + abs(dy) > chain_range:
                continue
            var pos := Vector2i(origin.x + dx, origin.y + dy)
            if has_block(pos):
                targets.append(pos)
    var erased_positions: Array[Vector2i] = []
    for pos in targets:
        if not has_block(pos):
            continue
        var result: Dictionary = damage_block(pos, damage, true, free_planet_mode)
        result["pos"] = pos
        results.append(result)
        if bool(result.get("destroyed", false)):
            erased_positions.append(pos)
            if int(result.get("type", BlockType.NORMAL)) == BlockType.ELECTRIC:
                results.append_array(electric_chain(pos, damage, chain_range, chain_depth, current_depth + 1, free_planet_mode))
    if not erased_positions.is_empty():
        _queue_edge_updates(erased_positions)
    return results

func get_core_proximity(pos: Vector2i) -> float:
    return float(proximity_cache.get(pos, 0.0))

func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(floor(world_pos.x / float(BLOCK_SIZE))), int(floor(world_pos.y / float(BLOCK_SIZE))))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(float(grid_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2), float(grid_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2))

func get_total_blocks() -> int:
    return blocks.size()

func get_alive_cores() -> int:
    var count := 0
    for core in cores:
        if bool(core.alive):
            count += 1
    return count

func get_total_cores() -> int:
    return cores.size()

func get_destroyed_cell_keys() -> Array[String]:
    var keys: Array[String] = []
    var radius_sq: int = PLANET_RADIUS * PLANET_RADIUS
    for x in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
            if x * x + y * y > radius_sq:
                continue
            var pos := Vector2i(x, y)
            if blocks.has(pos):
                continue
            keys.append("%d,%d" % [x, y])
    keys.sort()
    return keys

func to_save_data() -> Dictionary:
    var block_data := {}
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        var max_hp: float = float(block.get("max_hp", 0.0))
        block_data["%d,%d" % [pos.x, pos.y]] = [
            int(block.get("type", BlockType.NORMAL)),
            max_hp,
            max_hp,
            float(block.get("resource", 0.0)),
            int(block.get("core_id", -1)),
            bool(block.get("regenerated", false)),
            int(block.get("zone", get_zone(pos))),
            bool(block.get("converted_gold", false)),
        ]
    var core_data: Array = []
    for core in cores:
        core_data.append({
            "id": int(core.id),
            "center": [int(core.center.x), int(core.center.y)],
            "size": int(core.size),
            "influence_radius": int(core.influence_radius),
            "alive": bool(core.alive),
            "depth": float(core.get("depth", 0.0)),
            "zone": int(core.zone),
            "role": str(core.role),
        })
    return {
        "blocks": block_data,
        "cores": core_data,
        "zone_initial_blocks": zone_initial_blocks.duplicate(true),
        "zone_destroyed_blocks": zone_destroyed_blocks.duplicate(true),
        "zone_current_blocks": zone_current_blocks.duplicate(true),
        "final_boss_active": final_boss_active,
        "final_core_phase": final_core_phase,
    }

func build_dirty_save_data() -> Dictionary:
    return _build_chunked_save_payload(_serialize_dirty_sections())

func build_save_data_async(tree: SceneTree, progress_callback: Callable = Callable()) -> Dictionary:
    var dirty_section_ids: Array = _get_dirty_section_ids()
    var sections := {}
    var total_sections: int = max(1, dirty_section_ids.size())
    _emit_generation_progress(progress_callback, 0.0)
    for idx in range(dirty_section_ids.size()):
        var section_id: int = int(dirty_section_ids[idx])
        sections[section_id] = _serialize_section(section_id)
        if tree != null and ((idx + 1) % 2 == 0):
            _emit_generation_progress(progress_callback, 0.82 * float(idx + 1) / float(total_sections))
            await tree.process_frame
    _emit_generation_progress(progress_callback, 1.0)
    return _build_chunked_save_payload(sections)

func load_save_data(data: Dictionary) -> void:
    blocks.clear()
    cores.clear()
    exposed_edges.clear()
    proximity_cache.clear()
    _apply_loaded_save_data(data)

func load_save_data_async(tree: SceneTree, data: Dictionary, progress_callback: Callable = Callable()) -> void:
    blocks.clear()
    cores.clear()
    exposed_edges.clear()
    proximity_cache.clear()
    _emit_generation_progress(progress_callback, 0.0)
    var format_version: int = int(data.get("format_version", 1))
    if format_version >= 2 and data.get("sections", {}) is Dictionary:
        var sections: Dictionary = data.get("sections", {})
        var section_ids: Array = sections.keys()
        var total_sections: int = max(1, section_ids.size())
        for idx in range(section_ids.size()):
            _load_section_blocks(sections.get(section_ids[idx], []), format_version)
            if tree != null and ((idx + 1) % 2 == 0):
                _emit_generation_progress(progress_callback, 0.78 * float(idx + 1) / float(total_sections))
                await tree.process_frame
    else:
        var block_data: Dictionary = data.get("blocks", {})
        var block_keys: Array = block_data.keys()
        var total_blocks: int = max(1, block_keys.size())
        for idx in range(block_keys.size()):
            var key: String = str(block_keys[idx])
            var parts: PackedStringArray = key.split(",")
            if parts.size() != 2:
                continue
            var pos := Vector2i(int(parts[0]), int(parts[1]))
            var arr: Array = block_data[key]
            var max_hp: float = float(arr[2])
            blocks[pos] = {
                "type": int(arr[0]),
                "hp": max_hp,
                "max_hp": max_hp,
                "resource": float(arr[3]),
                "core_id": int(arr[4]),
                "regenerated": bool(arr[5]) if arr.size() > 5 else false,
                "zone": int(arr[6]) if arr.size() > 6 else get_zone(pos),
                "converted_gold": bool(arr[7]) if arr.size() > 7 else false,
            }
            if tree != null and ((idx + 1) % 2000 == 0):
                _emit_generation_progress(progress_callback, 0.78 * float(idx + 1) / float(total_blocks))
                await tree.process_frame
    _emit_generation_progress(progress_callback, 0.8)
    _load_common_save_data(data)
    _emit_generation_progress(progress_callback, 0.88)
    if tree != null:
        await tree.process_frame
    _rebuild_proximity_cache()
    _emit_generation_progress(progress_callback, 0.95)
    if tree != null:
        await tree.process_frame
    _rebuild_exposed_edges()
    clear_dirty_sections()
    _emit_generation_progress(progress_callback, 1.0)

func _get_zone_depth(pos: Vector2i) -> float:
    var dist: float = Vector2(float(pos.x), float(pos.y)).length()
    var zone: int = get_zone(pos)
    if zone == Zone.CENTER:
        return clampf(1.0 - dist / float(CENTER_RADIUS), 0.0, 1.0)
    var boss_dist: float = float(ZONE_BOSS_DIST.get(zone, 0.0))
    return clampf((float(PLANET_RADIUS) - dist) / maxf(1.0, float(PLANET_RADIUS) - boss_dist), 0.0, 1.0)

func _calc_block_hp(pos: Vector2i) -> float:
    var zone: int = get_zone(pos)
    var depth: float = _get_zone_depth(pos)
    var hp_range: Dictionary = ZONE_HP_RANGE.get(zone, {"min": 15.0, "max": 300.0})
    return round(float(hp_range["min"]) * pow(float(hp_range["max"]) / float(hp_range["min"]), depth))

func _calc_block_resource(pos: Vector2i) -> float:
    var zone: int = get_zone(pos)
    var depth: float = _get_zone_depth(pos)
    var res_range: Dictionary = ZONE_RES_RANGE.get(zone, {"min": 5.0, "max": 100.0})
    return round(float(res_range["min"]) * pow(float(res_range["max"]) / float(res_range["min"]), depth))

func _get_core_config_inf_mult(core_id: int) -> float:
    for config in CORE_CONFIGS:
        if int(config.id) == core_id:
            return float(config.get("inf_mult", 1.0))
    return 1.0

func _get_influence_hp_mult(pos: Vector2i, only_alive: bool = false) -> float:
    var max_mult := 1.0
    for core in cores:
        if only_alive and not bool(core.alive):
            continue
        var inf_mult: float = _get_core_config_inf_mult(int(core.id))
        var bonus_base: float = maxf(0.0, inf_mult - 1.0)
        if bonus_base <= 0.0:
            continue
        var dx: float = float(pos.x - int(core.center.x))
        var dy: float = float(pos.y - int(core.center.y))
        var dist: float = sqrt(dx * dx + dy * dy)
        var influence_r: float = float(core.influence_radius)
        if dist >= influence_r:
            continue
        var proximity: float = 1.0 - dist / influence_r
        max_mult = maxf(max_mult, 1.0 + bonus_base * proximity)
    return max_mult

func _apply_influence_zone_boost() -> void:
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE:
            continue
        var mult: float = _get_influence_hp_mult(pos, false)
        if mult > 1.0:
            block["hp"] = float(block.get("hp", 0.0)) * mult
            block["max_hp"] = float(block.get("max_hp", 0.0)) * mult
            blocks[pos] = block
    _count_zone_initial_blocks()

func _count_zone_initial_blocks() -> void:
    zone_initial_blocks.clear()
    zone_destroyed_blocks.clear()
    zone_current_blocks.clear()
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE:
            continue
        var zone: int = int(block.get("zone", get_zone(pos)))
        zone_initial_blocks[zone] = int(zone_initial_blocks.get(zone, 0)) + 1
    zone_current_blocks = zone_initial_blocks.duplicate(true)

func clear_dirty_sections() -> void:
    _dirty_sections.clear()

func mark_saved_sections_clean(section_ids: Array) -> void:
    for section_id_variant in section_ids:
        _dirty_sections.erase(int(section_id_variant))

func _ensure_section_cells_built() -> void:
    if _section_cells_ready:
        return
    _section_cells.resize(SAVE_SECTION_COUNT)
    for section_id in range(SAVE_SECTION_COUNT):
        _section_cells[section_id] = []
    var radius_sq: int = PLANET_RADIUS * PLANET_RADIUS
    for x in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
        for y in range(-PLANET_RADIUS, PLANET_RADIUS + 1):
            if x * x + y * y > radius_sq:
                continue
            var pos := Vector2i(x, y)
            var section_id := _get_section_id(pos)
            var section_cells: Array = _section_cells[section_id]
            section_cells.append(pos)
            _section_cells[section_id] = section_cells
    _section_cells_ready = true

func _get_section_id(pos: Vector2i) -> int:
    var angle := atan2(float(pos.y), float(pos.x))
    var angle_norm := fposmod(angle + PI, TAU) / TAU
    var angle_idx := clampi(int(floor(angle_norm * float(SAVE_ANGLE_SLICES))), 0, SAVE_ANGLE_SLICES - 1)
    var dist_norm := clampf(Vector2(float(pos.x), float(pos.y)).length() / float(PLANET_RADIUS), 0.0, 0.999999)
    var depth_idx := clampi(int(floor(dist_norm * float(SAVE_DEPTH_SLICES))), 0, SAVE_DEPTH_SLICES - 1)
    return depth_idx * SAVE_ANGLE_SLICES + angle_idx

func _mark_section_dirty(pos: Vector2i) -> void:
    _dirty_sections[_get_section_id(pos)] = true

func _mark_dirty_positions(positions: Array) -> void:
    for pos_variant in positions:
        _mark_section_dirty(Vector2i(pos_variant))

func _mark_core_section_dirty(center: Vector2i, core_size: int) -> void:
    var half: int = core_size / 2
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            _mark_section_dirty(Vector2i(center.x + dx, center.y + dy))

func _mark_all_sections_dirty() -> void:
    for section_id in range(SAVE_SECTION_COUNT):
        _dirty_sections[section_id] = true

func _get_dirty_section_ids() -> Array:
    if _dirty_sections.is_empty():
        return []
    var ids: Array = _dirty_sections.keys()
    ids.sort()
    return ids

func _serialize_section(section_id: int) -> Array:
    _ensure_section_cells_built()
    var rows: Array = []
    var section_cells: Array = _section_cells[section_id]
    for pos_variant in section_cells:
        var pos: Vector2i = pos_variant
        if not blocks.has(pos):
            continue
        var block: Dictionary = blocks[pos]
        rows.append([
            pos.x,
            pos.y,
            int(block.get("type", BlockType.NORMAL)),
            float(block.get("max_hp", 0.0)),
            float(block.get("resource", 0.0)),
            int(block.get("core_id", -1)),
            bool(block.get("regenerated", false)),
            int(block.get("zone", get_zone(pos))),
            bool(block.get("converted_gold", false)),
        ])
    return rows

func _serialize_dirty_sections() -> Dictionary:
    var sections := {}
    for section_id_variant in _get_dirty_section_ids():
        var section_id: int = int(section_id_variant)
        sections[section_id] = _serialize_section(section_id)
    return sections

func _serialize_core_data() -> Array:
    var core_data: Array = []
    for core in cores:
        core_data.append({
            "id": int(core.id),
            "center": [int(core.center.x), int(core.center.y)],
            "size": int(core.size),
            "influence_radius": int(core.influence_radius),
            "alive": bool(core.alive),
            "depth": float(core.get("depth", 0.0)),
            "zone": int(core.zone),
            "role": str(core.role),
        })
    return core_data

func _build_chunked_save_payload(sections: Dictionary) -> Dictionary:
    return {
        "format_version": 3,
        "angle_slices": SAVE_ANGLE_SLICES,
        "depth_slices": SAVE_DEPTH_SLICES,
        "initial_block_count": initial_block_count,
        "cores": _serialize_core_data(),
        "zone_initial_blocks": zone_initial_blocks.duplicate(true),
        "zone_destroyed_blocks": zone_destroyed_blocks.duplicate(true),
        "zone_current_blocks": zone_current_blocks.duplicate(true),
        "final_boss_active": final_boss_active,
        "final_core_phase": final_core_phase,
        "sections": sections,
    }

func _load_section_blocks(section_blocks: Array, format_version: int = 2) -> void:
    for row_variant in section_blocks:
        var row: Array = row_variant
        if format_version >= 3:
            if row.size() < 9:
                continue
            var pos_v3 := Vector2i(int(row[0]), int(row[1]))
            var max_hp_v3: float = float(row[3])
            blocks[pos_v3] = {
                "type": int(row[2]),
                "hp": max_hp_v3,
                "max_hp": max_hp_v3,
                "resource": float(row[4]),
                "core_id": int(row[5]),
                "regenerated": bool(row[6]),
                "zone": int(row[7]),
                "converted_gold": bool(row[8]),
            }
            continue
        if row.size() < 10:
            continue
        var pos := Vector2i(int(row[0]), int(row[1]))
        var max_hp: float = float(row[4])
        blocks[pos] = {
            "type": int(row[2]),
            "hp": max_hp,
            "max_hp": max_hp,
            "resource": float(row[5]),
            "core_id": int(row[6]),
            "regenerated": bool(row[7]),
            "zone": int(row[8]),
            "converted_gold": bool(row[9]),
        }

func _load_common_save_data(data: Dictionary) -> void:
    var core_data: Array = data.get("cores", [])
    for core_variant in core_data:
        var core_dict: Dictionary = core_variant
        var center_arr: Array = core_dict.get("center", [0, 0])
        cores.append({
            "id": int(core_dict.get("id", -1)),
            "center": Vector2i(int(center_arr[0]), int(center_arr[1])),
            "size": int(core_dict.get("size", 3)),
            "influence_radius": int(core_dict.get("influence_radius", 0)),
            "alive": bool(core_dict.get("alive", true)),
            "depth": float(core_dict.get("depth", 0.0)),
            "zone": int(core_dict.get("zone", Zone.CENTER)),
            "role": str(core_dict.get("role", get_core_role(int(core_dict.get("id", -1))))),
        })
    zone_initial_blocks = data.get("zone_initial_blocks", {}).duplicate(true)
    zone_destroyed_blocks = data.get("zone_destroyed_blocks", {}).duplicate(true)
    zone_current_blocks = data.get("zone_current_blocks", {}).duplicate(true)
    final_boss_active = bool(data.get("final_boss_active", false))
    final_core_phase = int(data.get("final_core_phase", 0))
    initial_block_count = int(data.get("initial_block_count", blocks.size()))
    if zone_initial_blocks.is_empty():
        _count_zone_initial_blocks()
    if zone_current_blocks.is_empty():
        zone_current_blocks = zone_initial_blocks.duplicate(true)
    if initial_block_count <= 0:
        initial_block_count = blocks.size()
        for destroyed_count_variant in zone_destroyed_blocks.values():
            initial_block_count += int(destroyed_count_variant)

func _apply_loaded_save_data(data: Dictionary) -> void:
    var format_version: int = int(data.get("format_version", 1))
    if format_version >= 2 and data.get("sections", {}) is Dictionary:
        var sections: Dictionary = data.get("sections", {})
        for section_blocks_variant in sections.values():
            _load_section_blocks(section_blocks_variant, format_version)
    else:
        var block_data: Dictionary = data.get("blocks", {})
        for key_variant in block_data.keys():
            var key: String = str(key_variant)
            var parts: PackedStringArray = key.split(",")
            if parts.size() != 2:
                continue
            var pos := Vector2i(int(parts[0]), int(parts[1]))
            var arr: Array = block_data[key]
            var max_hp: float = float(arr[2])
            blocks[pos] = {
                "type": int(arr[0]),
                "hp": max_hp,
                "max_hp": max_hp,
                "resource": float(arr[3]),
                "core_id": int(arr[4]),
                "regenerated": bool(arr[5]) if arr.size() > 5 else false,
                "zone": int(arr[6]) if arr.size() > 6 else get_zone(pos),
                "converted_gold": bool(arr[7]) if arr.size() > 7 else false,
            }
    _load_common_save_data(data)
    _rebuild_proximity_cache()
    _rebuild_exposed_edges()
    clear_dirty_sections()

func _place_cores() -> void:
    for config in CORE_CONFIGS:
        var core_id: int = int(config.id)
        var core_size: int = int(config.size)
        var dist: float = float(config.dist)
        var cx := 0
        var cy := 0
        if dist > 0.0:
            var angle_rad: float = deg_to_rad(float(config.angle_deg))
            cx = int(round(cos(angle_rad) * dist))
            cy = int(round(sin(angle_rad) * dist))
        var center := Vector2i(cx, cy)
        var block_count: int = core_size * core_size
        var core_hp: float = float(config.total_hp)
        core_hp *= core_difficulty_mult
        var base_res: float = _calc_block_resource(center)
        var core_res: float = base_res * float(config.res_mult) * float(block_count)
        cores.append({
            "id": core_id,
            "center": center,
            "size": core_size,
            "influence_radius": int(config.influence),
            "alive": true,
            "depth": 1.0 - dist / float(PLANET_RADIUS) if dist > 0.0 else 1.0,
            "zone": int(config.zone),
            "role": str(config.role),
        })
        var half: int = core_size / 2
        for dx in range(-half, half + core_size % 2):
            for dy in range(-half, half + core_size % 2):
                var pos := Vector2i(center.x + dx, center.y + dy)
                if pos.x * pos.x + pos.y * pos.y > PLANET_RADIUS * PLANET_RADIUS:
                    continue
                blocks[pos] = {
                    "type": BlockType.CORE,
                    "hp": core_hp,
                    "max_hp": core_hp,
                    "resource": core_res / float(block_count),
                    "core_id": core_id,
                    "zone": int(config.zone),
                }
    for core in cores:
        var core_zone: int = int(core.zone)
        zone_current_blocks[core_zone] = int(zone_current_blocks.get(core_zone, 0))

func _damage_core(_hit_pos: Vector2i, core_id: int, damage: float, free_planet_mode: bool = false) -> Dictionary:
    var core: Variant = _get_core_by_id(core_id)
    if core == null or not bool(core.alive):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0}
    if is_core_locked(core_id, free_planet_mode):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "shielded": true}
    var center: Vector2i = core.center
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    var any_hp_left := false
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                blocks[pos]["hp"] = float(blocks[pos].get("hp", 0.0)) - damage
                if float(blocks[pos].get("hp", 0.0)) > 0.0:
                    any_hp_left = true
    if any_hp_left:
        _mark_core_section_dirty(center, core_size)
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "core_id": core_id}
    var total_resource := 0.0
    var erased_positions: Array[Vector2i] = []
    var core_zone: int = int(core.get("zone", Zone.CENTER))
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                total_resource += float(blocks[pos].get("resource", 0.0))
                blocks.erase(pos)
                minimap_block_erased.emit(pos)
                erased_positions.append(pos)
                zone_destroyed_blocks[core_zone] = int(zone_destroyed_blocks.get(core_zone, 0)) + 1
    _queue_edge_updates(erased_positions)
    _mark_dirty_positions(erased_positions)
    _on_core_destroyed(core)
    return {
        "destroyed": true,
        "type": BlockType.CORE,
        "resource": total_resource,
        "core_id": core_id,
        "core_role": str(core.get("role", "")),
        "final_core": core_id == FINAL_CORE_ID,
    }

func _on_core_destroyed(core: Dictionary) -> void:
    core["alive"] = false
    _rebuild_proximity_cache()
    if on_core_destroyed_callback.is_valid():
        on_core_destroyed_callback.call(core)

func _get_core_by_id(core_id: int) -> Variant:
    for core in cores:
        if int(core.id) == core_id:
            return core
    return null

func _check_final_core_exposure(destroyed_pos: Vector2i) -> void:
    if _final_core_exposed_emitted or final_boss_active:
        return
    var final_core: Variant = _get_core_by_id(FINAL_CORE_ID)
    if final_core == null or not bool(final_core.alive):
        return
    var half: int = int(final_core.size) / 2
    for dx in range(-half, half + int(final_core.size) % 2):
        for dy in range(-half, half + int(final_core.size) % 2):
            var core_pos := Vector2i(int(final_core.center.x) + dx, int(final_core.center.y) + dy)
            for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
                if core_pos + neighbor == destroyed_pos:
                    _final_core_exposed_emitted = true
                    final_core_exposed.emit()
                    return

func _rebuild_proximity_cache() -> void:
    proximity_cache.clear()
    var pulse_range := 8
    for core in cores:
        if not bool(core.alive):
            continue
        var center: Vector2i = core.center
        for dx in range(-pulse_range, pulse_range + 1):
            for dy in range(-pulse_range, pulse_range + 1):
                var dist_sq: int = dx * dx + dy * dy
                if dist_sq >= pulse_range * pulse_range:
                    continue
                var pos := Vector2i(center.x + dx, center.y + dy)
                if not blocks.has(pos):
                    continue
                var prox: float = 1.0 - sqrt(float(dist_sq)) / float(pulse_range)
                if prox > float(proximity_cache.get(pos, 0.0)):
                    proximity_cache[pos] = prox

func _calc_edges(pos: Vector2i) -> int:
    var mask := 0
    if not blocks.has(pos + Vector2i(0, -1)):
        mask |= 1
    if not blocks.has(pos + Vector2i(0, 1)):
        mask |= 2
    if not blocks.has(pos + Vector2i(-1, 0)):
        mask |= 4
    if not blocks.has(pos + Vector2i(1, 0)):
        mask |= 8
    return mask

func _rebuild_exposed_edges() -> void:
    exposed_edges.clear()
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        exposed_edges[pos] = _calc_edges(pos)

func _update_edges_around(pos: Vector2i) -> void:
    _queue_edge_update(pos)

func _queue_edge_update(pos: Vector2i) -> void:
    _pending_edge_positions[pos] = true
    for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
        _pending_edge_positions[pos + neighbor] = true

func _queue_edge_updates(positions: Array) -> void:
    for pos_variant in positions:
        _queue_edge_update(Vector2i(pos_variant))

func flush_pending_exposed_edges() -> void:
    if _pending_edge_positions.is_empty():
        return
    for pos_variant in _pending_edge_positions.keys():
        var pos: Vector2i = pos_variant
        if blocks.has(pos):
            exposed_edges[pos] = _calc_edges(pos)
        else:
            exposed_edges.erase(pos)
    _pending_edge_positions.clear()

func _update_edges_batch(positions: Array) -> void:
    _queue_edge_updates(positions)

func _update_edges_around_immediate(pos: Vector2i) -> void:
    if blocks.has(pos):
        exposed_edges[pos] = _calc_edges(pos)
    else:
        exposed_edges.erase(pos)
    for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
        var npos: Vector2i = pos + neighbor
        if blocks.has(npos):
            exposed_edges[npos] = _calc_edges(npos)

func _update_edges_batch_immediate(positions: Array) -> void:
    var dirty := {}
    for pos_variant in positions:
        var pos: Vector2i = pos_variant
        dirty[pos] = true
        for neighbor in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
            dirty[pos + neighbor] = true
    for pos_variant in dirty.keys():
        var pos: Vector2i = pos_variant
        if blocks.has(pos):
            exposed_edges[pos] = _calc_edges(pos)
        else:
            exposed_edges.erase(pos)
