extends RefCounted
class_name OpenPitEmpirePlanetData

signal minimap_block_erased(pos: Vector2i)
signal minimap_block_spawned(pos: Vector2i, type: int)
signal final_core_exposed()
signal final_core_phase_depleted(phase: int)

const BLOCK_SIZE: int = 32
const PIT_MIN_X: int = -250
const PIT_MAX_X: int = 250
const PIT_TOP_Y: int = -220
const PIT_BOTTOM_Y: int = 260
const PIT_CAP_TOP_Y: int = -248
const PIT_TOP_HALF_WIDTH: float = 208.0
const PIT_MIDDLE_HALF_WIDTH: float = 170.0
const PIT_LOWER_HALF_WIDTH: float = 205.0
const PIT_ROOT_HALF_WIDTH: float = 162.0
const PIT_CORE_NECK_HALF_WIDTH: float = 76.0
const PIT_WALL_THICKNESS: int = 8
const ELECTRIC_CHANCE: float = 0.02
const GOLD_CHANCE: float = 0.02
const GOLD_RESOURCE_MULT: float = 5.0
const CORE_INDIRECT_DR: float = 0.15
const THORN_HP_MULT: float = 1.3
const NEXT_ZONE_SPIKE_CHANCE: float = 0.045
const NEXT_ZONE_SPIKE_HP_MULT: float = 1.4
const NEXT_ZONE_SPIKE_RES_MULT: float = 1.35
const FINAL_CORE_ID: int = 16
const FINAL_CORE_PHASE_COUNT: int = 5
const FINAL_CORE_PHASE_HP_GROWTH: float = 0.45
const SAVE_X_SLICES: int = 10
const SAVE_DEPTH_SLICES: int = 10
const SAVE_SECTION_COUNT: int = SAVE_X_SLICES * SAVE_DEPTH_SLICES
const SAVE_SECTION_PREWARM_SETTLE_MSEC: int = 5000
const ELECTRIC_CHAIN_MAX_TARGETS_PER_STEP: int = 8
const ELECTRIC_CHAIN_MAX_TOTAL_RESULTS: int = 96
const CORE_SHARED_HP_BLOCK_MULT: float = 2.0
const CORE_TOTAL_HP_MULT: float = 4.0
const NON_CORE_INFLUENCE_HP_STRENGTH: float = 0.55
const CORE_DIRECT_DR: float = 0.2
const CORE_BOSS_DIRECT_DR: float = 0.75
const CORE_FINAL_DIRECT_DR: float = 1.0
const CORE_MAX_HP_FRACTION_PER_HIT: float = 0.08
const CORE_AUTHORED_HP_CAP_MIN: float = 1000000.0

enum Zone { PROXY, CIPHER, GHOST, ROOT, CENTER }
enum BlockType { NORMAL, CORE, ELECTRIC, GOLD, THORN }

const CORE_CONFIGS := [
    {"id": 0, "center": Vector2i(-120, -162), "size": 3, "influence": 16, "hp_mult": 15.0, "total_hp": 50, "inf_mult": 2.0, "res_mult": 1.0, "zone": Zone.PROXY, "role": "outer"},
    {"id": 1, "center": Vector2i(0, -154), "size": 3, "influence": 16, "hp_mult": 20.0, "total_hp": 120, "inf_mult": 2.0, "res_mult": 1.2, "zone": Zone.PROXY, "role": "outer"},
    {"id": 2, "center": Vector2i(118, -168), "size": 3, "influence": 16, "hp_mult": 25.0, "total_hp": 250, "inf_mult": 2.5, "res_mult": 1.5, "zone": Zone.PROXY, "role": "outer"},
    {"id": 12, "center": Vector2i(0, -106), "size": 5, "influence": 22, "hp_mult": 80.0, "total_hp": 500, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.PROXY, "role": "boss"},
    {"id": 3, "center": Vector2i(-108, -58), "size": 3, "influence": 18, "hp_mult": 75.0, "total_hp": 5000, "inf_mult": 3.0, "res_mult": 1.5, "zone": Zone.CIPHER, "role": "outer"},
    {"id": 4, "center": Vector2i(0, -50), "size": 3, "influence": 18, "hp_mult": 90.0, "total_hp": 8000, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.CIPHER, "role": "outer"},
    {"id": 5, "center": Vector2i(108, -44), "size": 3, "influence": 18, "hp_mult": 100.0, "total_hp": 15000, "inf_mult": 3.0, "res_mult": 2.0, "zone": Zone.CIPHER, "role": "outer"},
    {"id": 13, "center": Vector2i(-8, 6), "size": 5, "influence": 25, "hp_mult": 250.0, "total_hp": 20000, "inf_mult": 3.5, "res_mult": 3.0, "zone": Zone.CIPHER, "role": "boss"},
    {"id": 6, "center": Vector2i(-92, 56), "size": 3, "influence": 20, "hp_mult": 125.0, "total_hp": 80000, "inf_mult": 3.5, "res_mult": 2.5, "zone": Zone.GHOST, "role": "outer"},
    {"id": 7, "center": Vector2i(0, 72), "size": 3, "influence": 20, "hp_mult": 150.0, "total_hp": 150000, "inf_mult": 3.5, "res_mult": 3.0, "zone": Zone.GHOST, "role": "outer"},
    {"id": 8, "center": Vector2i(92, 60), "size": 3, "influence": 20, "hp_mult": 175.0, "total_hp": 250000, "inf_mult": 4.0, "res_mult": 3.0, "zone": Zone.GHOST, "role": "outer"},
    {"id": 14, "center": Vector2i(0, 124), "size": 7, "influence": 28, "hp_mult": 400.0, "total_hp": 18000000, "inf_mult": 4.0, "res_mult": 4.0, "zone": Zone.GHOST, "role": "boss"},
    {"id": 9, "center": Vector2i(-104, 156), "size": 5, "influence": 22, "hp_mult": 200.0, "total_hp": 5000000, "inf_mult": 4.0, "res_mult": 3.5, "zone": Zone.ROOT, "role": "outer"},
    {"id": 10, "center": Vector2i(0, 184), "size": 5, "influence": 22, "hp_mult": 250.0, "total_hp": 10000000, "inf_mult": 4.0, "res_mult": 4.0, "zone": Zone.ROOT, "role": "outer"},
    {"id": 11, "center": Vector2i(104, 158), "size": 5, "influence": 22, "hp_mult": 300.0, "total_hp": 20000000, "inf_mult": 4.5, "res_mult": 5.0, "zone": Zone.ROOT, "role": "outer"},
    {"id": 15, "center": Vector2i(0, 214), "size": 7, "influence": 32, "hp_mult": 600.0, "total_hp": 35000000, "inf_mult": 5.0, "res_mult": 6.0, "zone": Zone.ROOT, "role": "boss"},
    {"id": 16, "center": Vector2i(0, 246), "size": 7, "influence": 35, "hp_mult": 500.0, "total_hp": 120000000, "inf_mult": 5.0, "res_mult": 8.0, "zone": Zone.CENTER, "role": "final"},
]

const ZONE_BOSS_IDS := {
    Zone.PROXY: 12,
    Zone.CIPHER: 13,
    Zone.GHOST: 14,
    Zone.ROOT: 15,
}

const ZONE_UNLOCK_REQUIRES := {
    Zone.PROXY: -1,
    Zone.CIPHER: 12,
    Zone.GHOST: 13,
    Zone.ROOT: 14,
    Zone.CENTER: 15,
}

const ZONE_HP_RANGE := {
    Zone.PROXY: {"min": 15.0, "max": 300.0},
    Zone.CIPHER: {"min": 200.0, "max": 12000.0},
    Zone.GHOST: {"min": 4000.0, "max": 220000.0},
    Zone.ROOT: {"min": 90000.0, "max": 9000000.0},
    Zone.CENTER: {"min": 1800000.0, "max": 28000000.0},
}

const ZONE_RES_RANGE := {
    Zone.PROXY: {"min": 5.0, "max": 100.0},
    Zone.CIPHER: {"min": 120.0, "max": 3500.0},
    Zone.GHOST: {"min": 3500.0, "max": 95000.0},
    Zone.ROOT: {"min": 60000.0, "max": 1500000.0},
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
var core_defense_gate_callback: Callable = Callable()
var final_boss_active: bool = false
var final_core_phase: int = 0
var _final_core_exposed_emitted: bool = false
var balance_script: Variant = null
var world_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var core_difficulty_mult: float = 1.0
var _dirty_sections: Dictionary = {}
var _section_dirty_revision: Dictionary = {}
var _section_dirty_msec: Dictionary = {}
var _serialized_section_cache: Dictionary = {}
var _serialized_section_cache_revision: Dictionary = {}
var _section_cells: Array = []
var _section_cells_ready: bool = false

static func get_zone(pos: Vector2i) -> int:
    var depth_ratio := clampf((float(pos.y) - float(PIT_TOP_Y)) / float(max(1, PIT_BOTTOM_Y - PIT_TOP_Y)), 0.0, 1.0)
    depth_ratio += sin(float(pos.x) * 0.041 + 0.9) * 0.026
    depth_ratio += sin(float(pos.x) * 0.117 + float(pos.y) * 0.01) * 0.012
    depth_ratio = clampf(depth_ratio, 0.0, 1.0)
    if depth_ratio >= 0.92:
        return Zone.CENTER
    if depth_ratio < 0.25:
        return Zone.PROXY
    if depth_ratio < 0.5:
        return Zone.CIPHER
    if depth_ratio < 0.75:
        return Zone.GHOST
    return Zone.ROOT

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

static func get_core_config(core_id: int) -> Dictionary:
    for config in CORE_CONFIGS:
        if int(config.id) == core_id:
            return config
    return {}

static func get_authored_core_hp_cap(core_id: int) -> float:
    var config := get_core_config(core_id)
    if config.is_empty():
        return 0.0
    var role := str(config.get("role", ""))
    var total_hp := float(config.get("total_hp", 0.0))
    if role == "final" and total_hp > 0.0:
        return total_hp
    if role == "boss" and total_hp >= CORE_AUTHORED_HP_CAP_MIN:
        return total_hp
    return 0.0

func get_map_bounds() -> Rect2:
    return Rect2(float(PIT_MIN_X), float(PIT_CAP_TOP_Y), float(PIT_MAX_X - PIT_MIN_X), float(PIT_BOTTOM_Y - PIT_CAP_TOP_Y))

static func _get_depth_ratio(pos: Vector2i) -> float:
    return clampf((float(pos.y) - float(PIT_TOP_Y)) / float(max(1, PIT_BOTTOM_Y - PIT_TOP_Y)), 0.0, 1.0)

static func _get_half_width_for_y(y: int) -> float:
    var depth_ratio := _get_depth_ratio(Vector2i(0, y))
    var base_width := PIT_TOP_HALF_WIDTH
    var t := 0.0
    if depth_ratio < 0.48:
        t = _smoothstep(depth_ratio / 0.48)
        base_width = lerpf(PIT_TOP_HALF_WIDTH, PIT_MIDDLE_HALF_WIDTH, t)
    elif depth_ratio < 0.68:
        t = _smoothstep((depth_ratio - 0.48) / 0.2)
        base_width = lerpf(PIT_MIDDLE_HALF_WIDTH, PIT_LOWER_HALF_WIDTH, t)
    elif depth_ratio < 0.93:
        t = _smoothstep((depth_ratio - 0.68) / 0.25)
        base_width = lerpf(PIT_LOWER_HALF_WIDTH, PIT_ROOT_HALF_WIDTH, t)
    else:
        t = _smoothstep((depth_ratio - 0.93) / 0.07)
        base_width = lerpf(PIT_ROOT_HALF_WIDTH, PIT_CORE_NECK_HALF_WIDTH, t)
    var wobble_strength := lerpf(1.0, 0.42, _smoothstep((depth_ratio - 0.9) / 0.1))
    var wobble := (
        sin(float(y) * 0.043 + 0.35) * 19.0
        + sin(float(y) * 0.12 + 1.1) * 10.0
        + sin(float(y) * 0.22 + 2.4) * 5.0
    ) * wobble_strength
    return maxf(PIT_CORE_NECK_HALF_WIDTH, base_width + wobble)

static func _smoothstep(value: float) -> float:
    var t := clampf(value, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

static func _get_left_wall(y: int) -> int:
    return int(floor(-_get_half_width_for_y(y)))

static func _get_right_wall(y: int) -> int:
    return int(ceil(_get_half_width_for_y(y)))

static func _is_inside_pit_shape(pos: Vector2i) -> bool:
    if pos.y < PIT_TOP_Y or pos.y > PIT_BOTTOM_Y:
        return false
    return pos.x >= _get_left_wall(pos.y) and pos.x <= _get_right_wall(pos.y)

static func _is_wall_cell(pos: Vector2i) -> bool:
    if pos.y < PIT_CAP_TOP_Y or pos.y > PIT_BOTTOM_Y:
        return false
    var wall_y: int = maxi(pos.y, PIT_TOP_Y)
    var left_wall: int = _get_left_wall(wall_y)
    var right_wall: int = _get_right_wall(wall_y)
    return (pos.x >= left_wall and pos.x < left_wall + PIT_WALL_THICKNESS) or (pos.x <= right_wall and pos.x > right_wall - PIT_WALL_THICKNESS)

func get_depth_level_for_pos(pos: Vector2i, max_depth_level: int) -> int:
    return clampi(1 + int(floor(_get_depth_ratio(pos) * float(max_depth_level))), 1, max_depth_level)

func get_spawn_world_position(target_grid: Vector2i = Vector2i.ZERO) -> Vector2:
    var spawn_y := PIT_TOP_Y - 8
    var spawn_x := clampi(target_grid.x, _get_left_wall(PIT_TOP_Y) + PIT_WALL_THICKNESS + 2, _get_right_wall(PIT_TOP_Y) - PIT_WALL_THICKNESS - 2)
    return grid_to_world(Vector2i(spawn_x, spawn_y))

func get_left_wall_x(y: int) -> int:
    return _get_left_wall(maxi(y, PIT_TOP_Y))

func get_right_wall_x(y: int) -> int:
    return _get_right_wall(maxi(y, PIT_TOP_Y))

func get_upper_wall_top_y() -> int:
    return PIT_CAP_TOP_Y

func is_unbreakable_block(pos: Vector2i) -> bool:
    if not blocks.has(pos):
        return false
    return bool(blocks[pos].get("unbreakable", false))

func _build_block_data(pos: Vector2i, hp: float, res: float, zone: int, block_type: int, unbreakable: bool) -> Dictionary:
    return {
        "type": block_type,
        "hp": hp,
        "max_hp": hp,
        "resource": res,
        "core_id": -1,
        "zone": zone,
        "layer_depth": get_depth_level_for_pos(pos, 5),
        "unbreakable": unbreakable,
    }

func _add_upper_wall_cap() -> void:
    var cap_zone := get_zone(Vector2i(0, PIT_TOP_Y))
    for y in range(PIT_CAP_TOP_Y, PIT_TOP_Y):
        for x in range(PIT_MIN_X, PIT_MAX_X + 1):
            var pos := Vector2i(x, y)
            if not _is_wall_cell(pos):
                continue
            var sample_pos := Vector2i(x, PIT_TOP_Y)
            var hp: float = _calc_block_hp(sample_pos)
            var res: float = _calc_block_resource(sample_pos)
            blocks[pos] = _build_block_data(pos, hp, res, cap_zone, BlockType.NORMAL, true)

func generate_sync(_depth_level: int, _persistent_destroyed: Dictionary, balance_script_ref: Variant, rng: RandomNumberGenerator) -> void:
    balance_script = balance_script_ref
    world_rng = rng if rng != null else RandomNumberGenerator.new()
    _reset_generation_state()
    for x in range(PIT_MIN_X, PIT_MAX_X + 1):
        for y in range(PIT_TOP_Y, PIT_BOTTOM_Y + 1):
            var pos := Vector2i(x, y)
            if not _is_inside_pit_shape(pos):
                continue
            var hp: float = _calc_block_hp(pos)
            var res: float = _calc_block_resource(pos)
            var zone: int = get_zone(pos)
            var block_type: int = BlockType.NORMAL
            var unbreakable := _is_wall_cell(pos)
            if not unbreakable:
                var roll: float = world_rng.randf()
                if zone != Zone.CENTER and roll < GOLD_CHANCE:
                    block_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    block_type = BlockType.ELECTRIC
                elif zone < Zone.ROOT and world_rng.randf() < NEXT_ZONE_SPIKE_CHANCE:
                    hp *= NEXT_ZONE_SPIKE_HP_MULT
                    res *= NEXT_ZONE_SPIKE_RES_MULT
            blocks[pos] = _build_block_data(pos, hp, res, zone, block_type, unbreakable)
    _add_upper_wall_cap()
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
    initial_block_count = _count_breakable_blocks() + persistent_removed_count
    _mark_all_sections_dirty()

func generate_async(tree: SceneTree, _depth_level: int, _persistent_destroyed: Dictionary, balance_script_ref: Variant, rng: RandomNumberGenerator, progress_callback: Callable = Callable()) -> void:
    balance_script = balance_script_ref
    world_rng = rng if rng != null else RandomNumberGenerator.new()
    _reset_generation_state()
    _emit_generation_progress(progress_callback, 0.0)
    var total_columns: int = PIT_MAX_X - PIT_MIN_X + 1
    for x in range(PIT_MIN_X, PIT_MAX_X + 1):
        for y in range(PIT_TOP_Y, PIT_BOTTOM_Y + 1):
            var pos := Vector2i(x, y)
            if not _is_inside_pit_shape(pos):
                continue
            var hp: float = _calc_block_hp(pos)
            var res: float = _calc_block_resource(pos)
            var zone: int = get_zone(pos)
            var block_type: int = BlockType.NORMAL
            var unbreakable := _is_wall_cell(pos)
            if not unbreakable:
                var roll: float = world_rng.randf()
                if zone != Zone.CENTER and roll < GOLD_CHANCE:
                    block_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    block_type = BlockType.ELECTRIC
            blocks[pos] = _build_block_data(pos, hp, res, zone, block_type, unbreakable)
        var column_index: int = x - PIT_MIN_X
        _emit_generation_progress(progress_callback, 0.8 * float(column_index + 1) / float(total_columns))
        if tree != null and ((column_index + 1) % 12 == 0):
            await tree.process_frame
    _add_upper_wall_cap()
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
    initial_block_count = _count_breakable_blocks()
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
    _section_cells.clear()
    _section_cells_ready = false

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
        "final_lockdown": alive_t3 > 0 and alive_t2 == 0 and get_alive_cores_in_tier(1) == 0,
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
            if used.has(pos) or not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                continue
            if blocks.has(pos):
                continue
            var hp: float = _calc_block_hp(pos) * THORN_HP_MULT
            var influence_mult: float = _get_non_core_influence_hp_mult(pos, true)
            hp *= influence_mult
            blocks[pos] = {
                "type": BlockType.THORN,
                "hp": hp,
                "max_hp": hp,
                "resource": 0.0,
                "core_id": -1,
                "zone": get_zone(pos),
                "regenerated": true,
                "layer_depth": get_depth_level_for_pos(pos, 5),
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
            if not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                continue
            if blocks.has(pos) or is_in_dead_core_zone(pos):
                continue
            var hp: float = _calc_block_hp(pos) * THORN_HP_MULT
            hp *= _get_non_core_influence_hp_mult(pos, true)
            blocks[pos] = {
                "type": BlockType.THORN,
                "hp": hp,
                "max_hp": hp,
                "resource": 0.0,
                "core_id": -1,
                "zone": get_zone(pos),
                "regenerated": true,
                "birth_time": Time.get_ticks_msec() * 0.001,
                "layer_depth": get_depth_level_for_pos(pos, 5),
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
    var shared_hp := -1.0
    var shared_max := -1.0
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(int(core.center.x) + dx, int(core.center.y) + dy)
            var block: Dictionary = blocks.get(pos, {})
            if not block.is_empty() and int(block.get("core_id", -1)) == int(core.get("id", -1)):
                shared_hp = float(block.get("hp", 0.0))
                shared_max = float(block.get("max_hp", 0.0))
                break
        if shared_hp >= 0.0:
            break
    if shared_max <= 0.0:
        return 0.0
    return clampf(shared_hp / shared_max, 0.0, 1.0)

func sync_all_core_tile_healths() -> void:
    for core_variant in cores:
        var core: Dictionary = core_variant
        var core_id: int = int(core.get("id", -1))
        if core_id < 0:
            continue
        _sync_core_tile_health(core_id)

func _sync_core_tile_health(core_id: int) -> void:
    var core: Variant = _get_core_by_id(core_id)
    if core == null:
        return
    var center: Vector2i = core.center
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    var shared_hp := -1.0
    var shared_max_hp := -1.0
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            var block: Dictionary = blocks.get(pos, {})
            if block.is_empty() or int(block.get("core_id", -1)) != core_id:
                continue
            var hp := float(block.get("hp", 0.0))
            var max_hp := float(block.get("max_hp", hp))
            if shared_max_hp < 0.0 or max_hp > shared_max_hp:
                shared_max_hp = max_hp
            if shared_hp < 0.0:
                shared_hp = hp
            else:
                shared_hp = minf(shared_hp, hp)
    if shared_max_hp <= 0.0 or shared_hp < 0.0:
        return
    var authored_hp_cap := get_authored_core_hp_cap(core_id)
    if authored_hp_cap > 0.0 and shared_max_hp > authored_hp_cap:
        var hp_ratio := clampf(shared_hp / shared_max_hp, 0.0, 1.0)
        shared_max_hp = authored_hp_cap
        shared_hp = authored_hp_cap * hp_ratio
    shared_hp = clampf(shared_hp, 0.0, shared_max_hp)
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            var block: Dictionary = blocks.get(pos, {})
            if block.is_empty() or int(block.get("core_id", -1)) != core_id:
                continue
            block["hp"] = shared_hp
            block["max_hp"] = shared_max_hp
            blocks[pos] = block

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
    if bool(block.get("unbreakable", false)):
        return {"destroyed": false, "type": int(block.get("type", BlockType.NORMAL)), "resource": 0.0, "shielded": true, "layer_depth": int(block.get("layer_depth", 1))}
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
        return {"destroyed": true, "type": block_type, "resource": block_resource, "layer_depth": int(block.get("layer_depth", 1))}
    blocks[pos] = block
    _mark_section_dirty(pos)
    return {"destroyed": false, "type": int(block.get("type", BlockType.NORMAL)), "resource": 0.0, "layer_depth": int(block.get("layer_depth", 1))}

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
                if not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                    continue
                if blocks.has(pos) or is_in_dead_core_zone(pos):
                    continue
                var hp: float = _calc_block_hp(pos)
                var res: float = _calc_block_resource(pos)
                var regen_type: int = BlockType.NORMAL
                var zone: int = get_zone(pos)
                var roll: float = world_rng.randf()
                if zone != Zone.CENTER and roll < GOLD_CHANCE:
                    regen_type = BlockType.GOLD
                elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                    regen_type = BlockType.ELECTRIC
                hp *= _get_non_core_influence_hp_mult(pos, true)
                blocks[pos] = {
                    "type": regen_type,
                    "hp": hp,
                    "max_hp": hp,
                    "resource": res,
                    "core_id": -1,
                    "zone": zone,
                    "regenerated": true,
                    "layer_depth": get_depth_level_for_pos(pos, 5),
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

func restore_alive_core_influence_blocks() -> Array[Vector2i]:
    var restored_positions: Array[Vector2i] = []
    for core_variant in cores:
        var core: Dictionary = core_variant
        if not bool(core.get("alive", false)):
            continue
        var radius: int = get_effective_influence_radius(core)
        var center: Vector2i = core.get("center", Vector2i.ZERO)
        var core_size: int = int(core.get("size", 3))
        var half: int = core_size / 2
        for x in range(center.x - radius, center.x + radius + 1):
            for y in range(center.y - radius, center.y + radius + 1):
                var pos := Vector2i(x, y)
                var dx: int = x - center.x
                var dy: int = y - center.y
                if dx * dx + dy * dy > radius * radius:
                    continue
                if not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                    continue
                if x >= center.x - half and x < center.x + half + core_size % 2 and y >= center.y - half and y < center.y + half + core_size % 2:
                    continue
                if blocks.has(pos):
                    continue
                var hp: float = _calc_block_hp(pos) * _get_non_core_influence_hp_mult(pos, true)
                var zone: int = get_zone(pos)
                blocks[pos] = {
                    "type": BlockType.NORMAL,
                    "hp": hp,
                    "max_hp": hp,
                    "resource": _calc_block_resource(pos),
                    "core_id": -1,
                    "zone": zone,
                    "regenerated": false,
                    "core_refill": true,
                    "layer_depth": get_depth_level_for_pos(pos, 5),
                }
                zone_current_blocks[zone] = int(zone_current_blocks.get(zone, 0)) + 1
                minimap_block_spawned.emit(pos, BlockType.NORMAL)
                restored_positions.append(pos)
    if not restored_positions.is_empty():
        _queue_edge_updates(restored_positions)
        _mark_dirty_positions(restored_positions)
    return restored_positions

func regenerate_final_core_arena() -> Array[Vector2i]:
    var final_core: Variant = _get_core_by_id(FINAL_CORE_ID)
    if final_core == null:
        return []
    var restored_positions: Array[Vector2i] = []
    var center: Vector2i = final_core.get("center", Vector2i.ZERO)
    var radius: int = get_effective_influence_radius(final_core)
    var core_size: int = int(final_core.get("size", 3))
    var half: int = core_size / 2
    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            var pos := Vector2i(x, y)
            var dx: int = x - center.x
            var dy: int = y - center.y
            if dx * dx + dy * dy > radius * radius:
                continue
            if not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                continue
            if x >= center.x - half and x < center.x + half + core_size % 2 and y >= center.y - half and y < center.y + half + core_size % 2:
                continue
            var previous: Dictionary = blocks.get(pos, {})
            if int(previous.get("type", BlockType.NORMAL)) == BlockType.CORE:
                continue
            var hp: float = _calc_block_hp(pos) * _get_non_core_influence_hp_mult(pos, true)
            var zone: int = get_zone(pos)
            var block_type := BlockType.NORMAL
            var roll: float = world_rng.randf()
            if zone != Zone.CENTER and roll < GOLD_CHANCE:
                block_type = BlockType.GOLD
            elif roll < GOLD_CHANCE + ELECTRIC_CHANCE:
                block_type = BlockType.ELECTRIC
            if previous.is_empty():
                zone_current_blocks[zone] = int(zone_current_blocks.get(zone, 0)) + 1
                minimap_block_spawned.emit(pos, block_type)
            blocks[pos] = {
                "type": block_type,
                "hp": hp,
                "max_hp": hp,
                "resource": _calc_block_resource(pos),
                "core_id": -1,
                "zone": zone,
                "regenerated": true,
                "core_refill": true,
                "layer_depth": get_depth_level_for_pos(pos, 5),
            }
            restored_positions.append(pos)
    if not restored_positions.is_empty():
        _queue_edge_updates(restored_positions)
        _mark_dirty_positions(restored_positions)
    return restored_positions

func electric_chain(origin: Vector2i, damage: float, chain_range: int, chain_depth: int, current_depth: int = 0, free_planet_mode: bool = false, visited: Dictionary = {}, remaining_budget: int = ELECTRIC_CHAIN_MAX_TOTAL_RESULTS) -> Array:
    var results: Array = []
    if current_depth >= chain_depth or remaining_budget <= 0:
        return results
    if visited.is_empty():
        visited[origin] = true
    var targets: Array[Dictionary] = []
    for dx in range(-chain_range, chain_range + 1):
        for dy in range(-chain_range, chain_range + 1):
            if dx == 0 and dy == 0:
                continue
            if abs(dx) + abs(dy) > chain_range:
                continue
            var pos := Vector2i(origin.x + dx, origin.y + dy)
            if visited.has(pos) or not has_block(pos):
                continue
            var target_block: Dictionary = blocks.get(pos, {})
            if int(target_block.get("core_id", -1)) >= 0:
                continue
            targets.append({
                "pos": pos,
                "dist": abs(dx) + abs(dy),
            })
    targets.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var dist_a: int = int(a.get("dist", 0))
        var dist_b: int = int(b.get("dist", 0))
        if dist_a == dist_b:
            var pos_a: Vector2i = a.get("pos", Vector2i.ZERO)
            var pos_b: Vector2i = b.get("pos", Vector2i.ZERO)
            if pos_a.x == pos_b.x:
                return pos_a.y < pos_b.y
            return pos_a.x < pos_b.x
        return dist_a < dist_b
    )
    if targets.size() > ELECTRIC_CHAIN_MAX_TARGETS_PER_STEP:
        targets.resize(ELECTRIC_CHAIN_MAX_TARGETS_PER_STEP)
    var erased_positions: Array[Vector2i] = []
    for target in targets:
        if remaining_budget <= 0:
            break
        var pos: Vector2i = target.get("pos", Vector2i.ZERO)
        visited[pos] = true
        if not has_block(pos):
            continue
        var result: Dictionary = damage_block(pos, damage, true, free_planet_mode)
        result["pos"] = pos
        results.append(result)
        remaining_budget -= 1
        if bool(result.get("destroyed", false)):
            erased_positions.append(pos)
            if int(result.get("type", BlockType.NORMAL)) == BlockType.ELECTRIC and remaining_budget > 0:
                var child_results: Array = electric_chain(pos, damage, chain_range, chain_depth, current_depth + 1, free_planet_mode, visited, remaining_budget)
                results.append_array(child_results)
                remaining_budget -= child_results.size()
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
    return _count_breakable_blocks()

func get_remaining_layer_block_counts() -> Dictionary:
    var counts := {}
    for layer_depth in range(1, 6):
        counts[layer_depth] = 0
    for block_variant in blocks.values():
        var block: Dictionary = block_variant
        if bool(block.get("unbreakable", false)):
            continue
        if int(block.get("type", BlockType.NORMAL)) == int(BlockType.CORE):
            continue
        var layer_depth := clampi(int(block.get("layer_depth", 1)), 1, 5)
        counts[layer_depth] = int(counts.get(layer_depth, 0)) + 1
    return counts

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
    for x in range(PIT_MIN_X, PIT_MAX_X + 1):
        for y in range(PIT_TOP_Y, PIT_BOTTOM_Y + 1):
            var check := Vector2i(x, y)
            if not _is_inside_pit_shape(check):
                continue
            var pos := check
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
            int(block.get("layer_depth", 1)),
            bool(block.get("unbreakable", false)),
            bool(block.get("core_refill", false)),
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
        sections[section_id] = _serialize_section_cached(section_id)
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
            var converted_gold := bool(arr[7]) if arr.size() > 7 else false
            blocks[pos] = {
                "type": int(arr[0]),
                "hp": max_hp,
                "max_hp": max_hp,
                "resource": float(arr[3]),
                "core_id": int(arr[4]),
                "regenerated": bool(arr[5]) if arr.size() > 5 else false,
                "zone": int(arr[6]) if arr.size() > 6 else get_zone(pos),
                "converted_gold": false,
                "layer_depth": int(arr[8]) if arr.size() > 8 else get_depth_level_for_pos(pos, 5),
                "unbreakable": bool(arr[9]) if arr.size() > 9 else false,
                "core_refill": bool(arr[10]) if arr.size() > 10 else false,
            }
            if converted_gold and int(blocks[pos].get("type", BlockType.NORMAL)) == BlockType.GOLD:
                blocks[pos]["type"] = BlockType.NORMAL
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
    var zone: int = get_zone(pos)
    var depth_ratio := _get_depth_ratio(pos)
    match zone:
        Zone.PROXY:
            return clampf(depth_ratio / 0.25, 0.0, 1.0)
        Zone.CIPHER:
            return clampf((depth_ratio - 0.25) / 0.25, 0.0, 1.0)
        Zone.GHOST:
            return clampf((depth_ratio - 0.5) / 0.25, 0.0, 1.0)
        Zone.ROOT:
            return clampf((depth_ratio - 0.75) / 0.17, 0.0, 1.0)
        Zone.CENTER:
            return clampf((depth_ratio - 0.92) / 0.08, 0.0, 1.0)
        _:
            return depth_ratio

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

func _get_non_core_influence_hp_mult(pos: Vector2i, only_alive: bool = false) -> float:
    return 1.0 + (_get_influence_hp_mult(pos, only_alive) - 1.0) * NON_CORE_INFLUENCE_HP_STRENGTH

func _apply_influence_zone_boost() -> void:
    for pos_variant in blocks.keys():
        var pos: Vector2i = pos_variant
        var block: Dictionary = blocks[pos]
        if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE:
            continue
        var mult: float = _get_non_core_influence_hp_mult(pos, false)
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
        if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE or bool(block.get("unbreakable", false)):
            continue
        var zone: int = int(block.get("zone", get_zone(pos)))
        zone_initial_blocks[zone] = int(zone_initial_blocks.get(zone, 0)) + 1
    zone_current_blocks = zone_initial_blocks.duplicate(true)

func _count_breakable_blocks() -> int:
    var count := 0
    for block_variant in blocks.values():
        var block: Dictionary = block_variant
        if bool(block.get("unbreakable", false)):
            continue
        count += 1
    return count

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
    for x in range(PIT_MIN_X, PIT_MAX_X + 1):
        for y in range(PIT_TOP_Y, PIT_BOTTOM_Y + 1):
            if not _is_inside_pit_shape(Vector2i(x, y)):
                continue
            var pos := Vector2i(x, y)
            var section_id := _get_section_id(pos)
            var section_cells: Array = _section_cells[section_id]
            section_cells.append(pos)
            _section_cells[section_id] = section_cells
    _section_cells_ready = true

func _get_section_id(pos: Vector2i) -> int:
    var x_norm := clampf((float(pos.x) - float(PIT_MIN_X)) / float(max(1, PIT_MAX_X - PIT_MIN_X + 1)), 0.0, 0.999999)
    var angle_idx := clampi(int(floor(x_norm * float(SAVE_X_SLICES))), 0, SAVE_X_SLICES - 1)
    var dist_norm := _get_depth_ratio(pos)
    var depth_idx := clampi(int(floor(dist_norm * float(SAVE_DEPTH_SLICES))), 0, SAVE_DEPTH_SLICES - 1)
    return depth_idx * SAVE_X_SLICES + angle_idx

func _mark_section_dirty(pos: Vector2i) -> void:
    var section_id := _get_section_id(pos)
    _dirty_sections[section_id] = true
    _section_dirty_revision[section_id] = int(_section_dirty_revision.get(section_id, 0)) + 1
    _section_dirty_msec[section_id] = Time.get_ticks_msec()

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
        _section_dirty_revision[section_id] = int(_section_dirty_revision.get(section_id, 0)) + 1
        _section_dirty_msec[section_id] = Time.get_ticks_msec()

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
            int(block.get("layer_depth", 1)),
            bool(block.get("unbreakable", false)),
            bool(block.get("core_refill", false)),
        ])
    return rows

func _serialize_section_cached(section_id: int) -> Array:
    var revision := int(_section_dirty_revision.get(section_id, 0))
    if _serialized_section_cache.has(section_id) and int(_serialized_section_cache_revision.get(section_id, -1)) == revision:
        return _serialized_section_cache[section_id]
    var rows := _serialize_section(section_id)
    _serialized_section_cache[section_id] = rows
    _serialized_section_cache_revision[section_id] = revision
    return rows

func prewarm_dirty_save_sections(max_sections: int = 1) -> int:
    if max_sections <= 0 or _dirty_sections.is_empty():
        return 0
    var warmed := 0
    var now_msec := Time.get_ticks_msec()
    for section_id_variant in _get_dirty_section_ids():
        var section_id: int = int(section_id_variant)
        var revision := int(_section_dirty_revision.get(section_id, 0))
        if _serialized_section_cache.has(section_id) and int(_serialized_section_cache_revision.get(section_id, -1)) == revision:
            continue
        if now_msec - int(_section_dirty_msec.get(section_id, now_msec)) < SAVE_SECTION_PREWARM_SETTLE_MSEC:
            continue
        _serialize_section_cached(section_id)
        warmed += 1
        if warmed >= max_sections:
            break
    return warmed

func _serialize_dirty_sections() -> Dictionary:
    var sections := {}
    for section_id_variant in _get_dirty_section_ids():
        var section_id: int = int(section_id_variant)
        sections[section_id] = _serialize_section_cached(section_id)
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
        "format_version": 4,
        "planet_layout_version": balance_script.PLANET_LAYOUT_VERSION if balance_script != null else 0,
        "angle_slices": SAVE_X_SLICES,
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
            var converted_gold_v3 := bool(row[8])
            blocks[pos_v3] = {
                "type": int(row[2]),
                "hp": max_hp_v3,
                "max_hp": max_hp_v3,
                "resource": float(row[4]),
                "core_id": int(row[5]),
                "regenerated": bool(row[6]),
                "zone": int(row[7]),
                "converted_gold": false,
                "layer_depth": int(row[9]) if row.size() > 9 else get_depth_level_for_pos(pos_v3, 5),
                "unbreakable": bool(row[10]) if row.size() > 10 else false,
                "core_refill": bool(row[11]) if row.size() > 11 else false,
            }
            if converted_gold_v3 and int(blocks[pos_v3].get("type", BlockType.NORMAL)) == BlockType.GOLD:
                blocks[pos_v3]["type"] = BlockType.NORMAL
            continue
        if row.size() < 10:
            continue
        var pos := Vector2i(int(row[0]), int(row[1]))
        var max_hp: float = float(row[4])
        var converted_gold := bool(row[9])
        blocks[pos] = {
            "type": int(row[2]),
            "hp": max_hp,
            "max_hp": max_hp,
            "resource": float(row[5]),
            "core_id": int(row[6]),
            "regenerated": bool(row[7]),
            "zone": int(row[8]),
            "converted_gold": false,
        }
        if converted_gold and int(blocks[pos].get("type", BlockType.NORMAL)) == BlockType.GOLD:
            blocks[pos]["type"] = BlockType.NORMAL

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
    initial_block_count = int(data.get("initial_block_count", _count_breakable_blocks()))
    if zone_initial_blocks.is_empty():
        _count_zone_initial_blocks()
    if zone_current_blocks.is_empty():
        zone_current_blocks = zone_initial_blocks.duplicate(true)
    if initial_block_count <= 0:
        initial_block_count = _count_breakable_blocks()
        for destroyed_count_variant in zone_destroyed_blocks.values():
            initial_block_count += int(destroyed_count_variant)
    sync_all_core_tile_healths()

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
            var converted_gold := bool(arr[7]) if arr.size() > 7 else false
            blocks[pos] = {
                "type": int(arr[0]),
                "hp": max_hp,
                "max_hp": max_hp,
                "resource": float(arr[3]),
                "core_id": int(arr[4]),
                "regenerated": bool(arr[5]) if arr.size() > 5 else false,
                "zone": int(arr[6]) if arr.size() > 6 else get_zone(pos),
                "converted_gold": false,
                "layer_depth": int(arr[8]) if arr.size() > 8 else get_depth_level_for_pos(pos, 5),
                "unbreakable": bool(arr[9]) if arr.size() > 9 else false,
            }
            if converted_gold and int(blocks[pos].get("type", BlockType.NORMAL)) == BlockType.GOLD:
                blocks[pos]["type"] = BlockType.NORMAL
    _load_common_save_data(data)
    _rebuild_proximity_cache()
    _rebuild_exposed_edges()
    clear_dirty_sections()

func _place_cores() -> void:
    for config in CORE_CONFIGS:
        var core_id: int = int(config.id)
        var core_size: int = int(config.size)
        var center: Vector2i = config.get("center", Vector2i.ZERO)
        var block_count: int = core_size * core_size
        var normal_block_hp: float = _calc_block_hp(center) * _get_influence_hp_mult(center, true)
        var core_hp: float = maxf(
            maxf(
                normal_block_hp * float(block_count) * CORE_SHARED_HP_BLOCK_MULT,
                _calc_block_hp(center) * float(config.get("hp_mult", 1.0))
            ),
            float(config.get("total_hp", 0.0))
        )
        core_hp *= CORE_TOTAL_HP_MULT
        core_hp *= core_difficulty_mult
        var authored_hp_cap := get_authored_core_hp_cap(core_id)
        if authored_hp_cap > 0.0:
            core_hp = minf(core_hp, authored_hp_cap)
        var base_res: float = _calc_block_resource(center)
        var core_res: float = base_res * float(config.res_mult) * float(block_count)
        cores.append({
            "id": core_id,
            "center": center,
            "size": core_size,
            "influence_radius": int(config.influence),
            "alive": true,
            "depth": _get_depth_ratio(center),
            "zone": int(config.zone),
            "role": str(config.role),
        })
        var half: int = core_size / 2
        for dx in range(-half, half + core_size % 2):
            for dy in range(-half, half + core_size % 2):
                var pos := Vector2i(center.x + dx, center.y + dy)
                if not _is_inside_pit_shape(pos) or _is_wall_cell(pos):
                    continue
                blocks[pos] = {
                    "type": BlockType.CORE,
                    "hp": core_hp,
                    "max_hp": core_hp,
                    "resource": core_res / float(block_count),
                    "core_id": core_id,
                    "zone": int(config.zone),
                    "layer_depth": get_depth_level_for_pos(pos, 5),
                }
    for core in cores:
        var core_zone: int = int(core.zone)
        zone_current_blocks[core_zone] = int(zone_current_blocks.get(core_zone, 0))
    sync_all_core_tile_healths()

func _damage_core(_hit_pos: Vector2i, core_id: int, damage: float, free_planet_mode: bool = false) -> Dictionary:
    var core: Variant = _get_core_by_id(core_id)
    if core == null or not bool(core.alive):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0}
    if is_core_locked(core_id, free_planet_mode):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "shielded": true}
    var center: Vector2i = core.center
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    var shared_hp := -1.0
    var shared_max_hp := -1.0
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                shared_hp = float(blocks[pos].get("hp", 0.0))
                shared_max_hp = float(blocks[pos].get("max_hp", 0.0))
                break
        if shared_hp >= 0.0:
            break
    if shared_hp < 0.0:
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "core_id": core_id}
    var authored_hp_cap := get_authored_core_hp_cap(core_id)
    if core_id == FINAL_CORE_ID:
        authored_hp_cap *= pow(1.0 + FINAL_CORE_PHASE_HP_GROWTH, final_core_phase)
    if authored_hp_cap > 0.0 and shared_max_hp > authored_hp_cap:
        var hp_ratio := clampf(shared_hp / shared_max_hp, 0.0, 1.0)
        shared_max_hp = authored_hp_cap
        shared_hp = authored_hp_cap * hp_ratio
    var direct_dr := CORE_DIRECT_DR
    var role := str(core.get("role", ""))
    if role == "final":
        direct_dr = CORE_FINAL_DIRECT_DR
    elif role == "boss":
        direct_dr = CORE_BOSS_DIRECT_DR
    var applied_damage := damage * direct_dr
    var max_hit_damage := maxf(1.0, shared_max_hp * CORE_MAX_HP_FRACTION_PER_HIT)
    applied_damage = minf(applied_damage, max_hit_damage)
    var next_shared_hp := shared_hp - applied_damage
    if next_shared_hp > 0.0:
        for dx in range(-half, half + core_size % 2):
            for dy in range(-half, half + core_size % 2):
                var pos := Vector2i(center.x + dx, center.y + dy)
                if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                    blocks[pos]["hp"] = next_shared_hp
                    blocks[pos]["max_hp"] = shared_max_hp
        _mark_core_section_dirty(center, core_size)
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "core_id": core_id}
    if role == "boss" and core_defense_gate_callback.is_valid():
        var defense_response: Variant = core_defense_gate_callback.call(core.duplicate(true), shared_max_hp)
        if defense_response is Dictionary and bool(defense_response.get("handled", false)):
            var held_hp: float = clampf(float(defense_response.get("hp_ratio", 0.01)), 0.001, 1.0) * shared_max_hp
            for dx in range(-half, half + core_size % 2):
                for dy in range(-half, half + core_size % 2):
                    var pos := Vector2i(center.x + dx, center.y + dy)
                    if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                        blocks[pos]["hp"] = held_hp
                        blocks[pos]["max_hp"] = shared_max_hp
            _mark_core_section_dirty(center, core_size)
            return {
                "destroyed": false,
                "type": BlockType.CORE,
                "resource": 0.0,
                "core_id": core_id,
                "core_role": role,
                "defense_triggered": true,
                "layer_depth": get_depth_level_for_pos(center, 5),
            }
    if core_id == FINAL_CORE_ID and final_core_phase < FINAL_CORE_PHASE_COUNT - 1:
        final_core_phase += 1
        var next_max_hp := shared_max_hp * (1.0 + FINAL_CORE_PHASE_HP_GROWTH)
        for dx in range(-half, half + core_size % 2):
            for dy in range(-half, half + core_size % 2):
                var pos := Vector2i(center.x + dx, center.y + dy)
                if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                    blocks[pos]["hp"] = next_max_hp
                    blocks[pos]["max_hp"] = next_max_hp
        _mark_core_section_dirty(center, core_size)
        final_core_phase_depleted.emit(final_core_phase)
        return {
            "destroyed": false,
            "type": BlockType.CORE,
            "resource": 0.0,
            "core_id": core_id,
            "core_role": str(core.get("role", "")),
            "final_core": true,
            "phase_depleted": true,
            "phase": final_core_phase,
            "layer_depth": get_depth_level_for_pos(center, 5),
        }
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
        "layer_depth": get_depth_level_for_pos(center, 5),
    }

func set_core_hp_ratio(core_id: int, hp_ratio: float) -> bool:
    var core: Variant = _get_core_by_id(core_id)
    if core == null or not bool(core.alive):
        return false
    var center: Vector2i = core.center
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
    var shared_max_hp := -1.0
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                shared_max_hp = maxf(shared_max_hp, float(blocks[pos].get("max_hp", 0.0)))
    if shared_max_hp <= 0.0:
        return false
    var next_hp: float = clampf(hp_ratio, 0.0, 1.0) * shared_max_hp
    for dx in range(-half, half + core_size % 2):
        for dy in range(-half, half + core_size % 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if blocks.has(pos) and int(blocks[pos].get("core_id", -1)) == core_id:
                blocks[pos]["hp"] = next_hp
                blocks[pos]["max_hp"] = shared_max_hp
    _mark_core_section_dirty(center, core_size)
    return true

func force_destroy_core(core_id: int) -> Dictionary:
    var core: Variant = _get_core_by_id(core_id)
    if core == null or not bool(core.alive):
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "core_id": core_id}
    var center: Vector2i = core.center
    var core_size: int = int(core.get("size", 3))
    var half: int = core_size / 2
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
    if erased_positions.is_empty():
        return {"destroyed": false, "type": BlockType.CORE, "resource": 0.0, "core_id": core_id}
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
        "layer_depth": get_depth_level_for_pos(center, 5),
    }

func _on_core_destroyed(core: Dictionary) -> void:
    var core_id: int = int(core.get("id", -1))
    var core_index := _get_core_index_by_id(core_id)
    if core_index >= 0:
        var stored_core: Dictionary = cores[core_index]
        stored_core["alive"] = false
        cores[core_index] = stored_core
        core = stored_core
    else:
        core["alive"] = false
    _rebuild_proximity_cache()
    if on_core_destroyed_callback.is_valid():
        on_core_destroyed_callback.call(core)

func _get_core_by_id(core_id: int) -> Variant:
    for core in cores:
        if int(core.id) == core_id:
            return core
    return null

func _get_core_index_by_id(core_id: int) -> int:
    for idx in range(cores.size()):
        var core: Dictionary = cores[idx]
        if int(core.get("id", -1)) == core_id:
            return idx
    return -1

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
