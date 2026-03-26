extends RefCounted
class_name MiningUpgradeTreeAdapter

const MINING_BALANCE_SCRIPT = preload("res://Games/Mining/MiningBalance.gd")
const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")

const GROUPED_TIER_MAX := 5
const DEMO_PROJECT_SETTING := "global/Demo"
const MINING_DEMO_MAX_GROUP_PROJECT_SETTING := "global/mining_demo_max_group"
const MINING_DEMO_DEFAULT_MAX_GROUP := 6
const MINING_DEMO_RECOMMENDED_20_MIN_GROUP_CAP := 4
const MINING_DEMO_RECOMMENDED_40_MIN_GROUP_CAP := 6

const THEME_TIME := 1
const THEME_DRILL := 2
const THEME_CARGO := 3
const THEME_DRONES := 4

const LAYOUT_BY_KEY := {
    "timer_reserve": {"root": Vector2(-1, -3), "step": Vector2(0, -1)},
    "route_planner": {"root": Vector2(-2, -4), "step": Vector2(-1, -1)},
    "engine_tuning": {"root": Vector2(1, -3), "step": Vector2(0, -1)},
    "dirt_softener": {"root": Vector2(2, -4), "step": Vector2(1, -1)},
    "drill_torque": {"root": Vector2(-3, 0), "step": Vector2(-1, 0)},
    "drill_plating": {"root": Vector2(-4, 1), "step": Vector2(-1, 0)},
    "cooling_loop": {"root": Vector2(-5, 2), "step": Vector2(-1, 0)},
    "foreman_bot": {"root": Vector2(-6, 1), "step": Vector2(-1, 0)},
    "cargo_pods": {"root": Vector2(0, 3), "step": Vector2(0, 1)},
    "cargo_compressor": {"root": Vector2(1, 5), "step": Vector2(1, 1)},
    "ore_refinery": {"root": Vector2(-1, 4), "step": Vector2(-1, 1)},
    "xp_calibration": {"root": Vector2(-2, 5), "step": Vector2(-1, 1)},
    "depth_scanner": {"root": Vector2(-3, 6), "step": Vector2(-1, 1)},
    "seismic_sonar": {"root": Vector2(-4, 7), "step": Vector2(-1, 1)},
    "pickup_radius": {"root": Vector2(1, 4), "step": Vector2(1, 0)},
    "magnet_drone": {"root": Vector2(2, 5), "step": Vector2(1, 1)},
    "delivery_drone": {"root": Vector2(2, 3), "step": Vector2(1, -1)},
    "auto_sorters": {"root": Vector2(3, 3), "step": Vector2(1, -1)},
}

const PRIMARY_DEPENDENCY_OVERRIDE := {
    "foreman_bot": "drill_plating",
    "delivery_drone": "magnet_drone",
}

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var saved_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
    var saved_upgrades: Dictionary = saved_data.get("upgrades", {})
    var demo_mode_enabled: bool = _is_demo_mode_enabled()
    var demo_max_group: int = _get_demo_max_group()
    var upgrade_catalog: Array[Dictionary] = MINING_PROGRESS_SCRIPT.get_upgrade_catalog()
    var grouped_upgrades: Array[Dictionary] = _group_upgrades(upgrade_catalog)
    var id_to_cell: Dictionary = _build_tree_layout(grouped_upgrades)

    var next_id := 0
    for entry in grouped_upgrades:
        var upgrade := Upgrade.new()
        var upgrade_id: String = str(entry.get("id", ""))
        var upgrade_key: String = str(entry.get("key", ""))
        if upgrade_id.is_empty() or upgrade_key.is_empty():
            continue

        upgrade.id = next_id
        next_id += 1
        upgrade.cell = Vector2(id_to_cell.get(upgrade_id, Vector2.ZERO))
        # Mining sim upgrades should have distinct icons in the tech tree.
        # We reuse Vanguard's existing mod-icon textures instead of relying on the
        # single-letter `icon` fields from the mining balance data.
        upgrade.mod = _mod_for_mining_upgrade_key(upgrade_key)
        upgrade.value = 0.0
        upgrade.max_tier = int(entry.get("max_tier", 1))
        upgrade.base_cost = int(entry.get("base_cost", 0))
        upgrade.cost_scale = 0.0
        upgrade.tier_costs = entry.get("tier_costs", [])
        upgrade.demo_locked = 0
        upgrade.section = 0
        upgrade.act = _theme_act_for_key(upgrade_key)
        upgrade.epilogue = 0
        upgrade.type = Util.NODE_TYPES.NORMAL
        upgrade.sim_key = upgrade_key
        upgrade.sim_name = str(entry.get("label", upgrade_key))
        upgrade.sim_description = MINING_BALANCE_SCRIPT.get_upgrade_description(entry)
        upgrade.sim_icon = str(entry.get("icon", "M"))
        upgrade.sim_group = int(entry.get("group", 1))
        upgrade.sim_level = int(entry.get("level", 1))
        upgrade.sim_group_pos = 1
        if demo_mode_enabled and upgrade.sim_group > demo_max_group:
            upgrade.demo_locked = 1

        var dep_id: String = str(entry.get("dependency", ""))
        if dep_id.is_empty() or dep_id == "__CENTER__":
            upgrade.forced_cell = Vector2.ZERO
        else:
            upgrade.forced_cell = Vector2(id_to_cell.get(dep_id, Vector2.ZERO))

        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = int(saved_upgrades.get(upgrade_key, 0))
        if upgrade.demo_locked == 1:
            owned_level = min(owned_level, upgrade.sim_level - 1)
        if owned_level >= upgrade.sim_level:
            var unlocked_tiers: int = clampi(owned_level - upgrade.sim_level + 1, 0, upgrade.max_tier)
            upgrade.current_tier = unlocked_tiers
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _is_demo_mode_enabled() -> bool:
    return bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))

static func _get_demo_max_group() -> int:
    return max(1, int(ProjectSettings.get_setting(MINING_DEMO_MAX_GROUP_PROJECT_SETTING, MINING_DEMO_DEFAULT_MAX_GROUP)))

static func _group_upgrades(upgrade_catalog: Array[Dictionary]) -> Array[Dictionary]:
    var grouped: Array[Dictionary] = []
    for upgrade_def in upgrade_catalog:
        var upgrade_key: String = str(upgrade_def.get("id", ""))
        if upgrade_key.is_empty():
            continue

        var tier_costs: Array = _build_tier_costs(upgrade_def)
        var max_level: int = int(upgrade_def.get("max_level", 1))
        var previous_group_id: String = ""
        var cursor: int = 0
        var group_index: int = 0

        while cursor < max_level:
            var start_level: int = cursor + 1
            var chunk_size: int = min(GROUPED_TIER_MAX, max_level - cursor)
            var end_level: int = start_level + chunk_size - 1
            var group_id: String = "%s__G%d" % [upgrade_key, group_index + 1]
            var chunk_costs: Array = []
            for offset in range(chunk_size):
                chunk_costs.append(tier_costs[cursor + offset])

            var grouped_entry: Dictionary = upgrade_def.duplicate(true)
            grouped_entry["id"] = group_id
            grouped_entry["key"] = upgrade_key
            grouped_entry["label"] = _format_group_label(str(upgrade_def.get("label", upgrade_key)), start_level, end_level, max_level)
            grouped_entry["max_tier"] = chunk_size
            grouped_entry["base_cost"] = int(chunk_costs[0]) if chunk_costs.size() > 0 else int(upgrade_def.get("base_cost", 0))
            grouped_entry["tier_costs"] = chunk_costs
            grouped_entry["level"] = start_level
            grouped_entry["group"] = group_index + 1
            grouped_entry["dependency"] = previous_group_id if previous_group_id != "" else _resolve_root_dependency(upgrade_def)
            grouped.append(grouped_entry)

            previous_group_id = group_id
            group_index += 1
            cursor += chunk_size

    return grouped

static func _resolve_root_dependency(upgrade_def: Dictionary) -> String:
    var requires: Dictionary = upgrade_def.get("requires", {})
    if requires.is_empty():
        return "__CENTER__"

    var upgrade_key: String = str(upgrade_def.get("id", ""))
    var dependency_key: String = _select_dependency_key(upgrade_key, requires)
    var required_level: int = int(requires.get(dependency_key, 1))
    return _group_id_for_level(dependency_key, required_level)

static func _select_dependency_key(upgrade_key: String, requires: Dictionary) -> String:
    if PRIMARY_DEPENDENCY_OVERRIDE.has(upgrade_key):
        return str(PRIMARY_DEPENDENCY_OVERRIDE[upgrade_key])
    for key_variant in requires.keys():
        return str(key_variant)
    return ""

static func _group_id_for_level(upgrade_key: String, required_level: int) -> String:
    var group_index: int = max(1, int(ceil(float(max(required_level, 1)) / float(GROUPED_TIER_MAX))))
    return "%s__G%d" % [upgrade_key, group_index]

static func _build_tree_layout(grouped_upgrades: Array[Dictionary]) -> Dictionary:
    var id_to_cell: Dictionary = {}
    var used_cells: Dictionary = {Vector2.ZERO: true}

    for entry in grouped_upgrades:
        var upgrade_id: String = str(entry.get("id", ""))
        var upgrade_key: String = str(entry.get("key", ""))
        var group_index: int = int(entry.get("group", 1))
        if upgrade_id.is_empty() or upgrade_key.is_empty():
            continue

        var layout: Dictionary = LAYOUT_BY_KEY.get(upgrade_key, {})
        var root: Vector2 = Vector2(layout.get("root", Vector2(group_index + 2, 0)))
        var step: Vector2 = Vector2(layout.get("step", Vector2.RIGHT))
        var cell: Vector2 = root + (step * max(0, group_index - 1))
        while used_cells.has(cell):
            cell += step
        id_to_cell[upgrade_id] = cell
        used_cells[cell] = true

    return id_to_cell

static func _theme_act_for_key(upgrade_key: String) -> int:
    match upgrade_key:
        "timer_reserve", "route_planner", "engine_tuning", "dirt_softener":
            return THEME_TIME
        "drill_torque", "drill_plating", "cooling_loop", "foreman_bot":
            return THEME_DRILL
        "cargo_pods", "cargo_compressor", "ore_refinery", "xp_calibration", "depth_scanner", "seismic_sonar":
            return THEME_CARGO
        "pickup_radius", "magnet_drone", "delivery_drone", "auto_sorters":
            return THEME_DRONES
        _:
            return THEME_CARGO

static func _mod_for_mining_upgrade_key(upgrade_key: String) -> Util.MODS:
    # Map mining upgrades to Vanguard's existing mod-icon textures (Pallets/Refs.tscn).
    # This guarantees the tech-tree nodes show real icons for every mining upgrade.
    match upgrade_key:
        "timer_reserve":
            return Util.MODS.RUN_TIMER_BASE
        "route_planner":
            return Util.MODS.CHANCE_TO_ADD_TIME_ON_ASTEROID_DESTROYED
        "engine_tuning":
            return Util.MODS.CLICK_RATE
        "dirt_softener":
            return Util.MODS.MAX_ASTEROID_SIZE
        "drill_torque":
            return Util.MODS.BASE_DAMAGE_PER_CLICK
        "drill_plating":
            return Util.MODS.ASTEROID_DENSITY
        "cooling_loop":
            return Util.MODS.CHANCE_TO_RESPAWN_ASTEROID_ON_BREAK
        "cargo_pods":
            return Util.MODS.MONEY_PER_MATTER
        "cargo_compressor":
            return Util.MODS.BONUS_MONEY_SCALE
        "ore_refinery":
            return Util.MODS.ASTEROIDS_TO_SPAWN
        "pickup_radius":
            return Util.MODS.CLICK_AOE
        "xp_calibration":
            return Util.MODS.COMET_SPAWN_CHANCE
        "depth_scanner":
            return Util.MODS.ASTEROID_DENSITY
        "seismic_sonar":
            return Util.MODS.ASTEROIDS_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW
        "magnet_drone":
            return Util.MODS.ELECTRIC_CRIT_CHANCE
        "foreman_bot":
            return Util.MODS.CLICKER_CRIT_CHANCE
        "delivery_drone":
            return Util.MODS.ELECTRIC_CRIT_BONUS
        "auto_sorters":
            return Util.MODS.CLICKER_CRIT_BONUS
        _:
            return Util.MODS.MONEY_PER_MATTER

static func _format_group_label(base_label: String, start_level: int, end_level: int, max_level: int) -> String:
    if max_level <= GROUPED_TIER_MAX:
        return base_label
    return "%s %d-%d" % [base_label, start_level, end_level]

static func _build_tier_costs(upgrade_def: Dictionary) -> Array:
    var costs: Array = []
    var upgrade_key: String = str(upgrade_def.get("id", ""))
    var max_level: int = int(upgrade_def.get("max_level", 1))
    for level in range(max_level):
        costs.append(MINING_BALANCE_SCRIPT.get_upgrade_cost(upgrade_key, level))
    return costs
