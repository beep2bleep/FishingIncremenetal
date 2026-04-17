extends RefCounted
class_name OpenPitEmpireUpgradeTreeAdapter

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")

const GROUPED_TIER_MAX := 5
const LAYOUT_BY_KEY := {
    "attack_damage": {"root": Vector2(-2, -1), "step": Vector2(-1, 0)},
    "attack_speed": {"root": Vector2(-3, -2), "step": Vector2(-1, -1)},
    "mining_radius": {"root": Vector2(0, -2), "step": Vector2(0, -1)},
    "pickup_radius": {"root": Vector2(1, -1), "step": Vector2(1, 0)},
    "move_speed": {"root": Vector2(2, -2), "step": Vector2(1, -1)},
    "shield_count": {"root": Vector2(3, -1), "step": Vector2(1, 0)},
    "salvage_keep": {"root": Vector2(-1, 2), "step": Vector2(-1, 1)},
    "multi_target": {"root": Vector2(-2, 1), "step": Vector2(-1, 0)},
    "ore_value": {"root": Vector2(0, 2), "step": Vector2(0, 1)},
    "cargo_capacity": {"root": Vector2(1, 2), "step": Vector2(1, 1)},
    "layer_access": {"root": Vector2(0, 4), "step": Vector2(0, 1)},
    "crit_chance": {"root": Vector2(-4, 0), "step": Vector2(-1, 0)},
    "explosion_chance": {"root": Vector2(-5, 1), "step": Vector2(-1, 0)},
    "chain_chance": {"root": Vector2(-6, 2), "step": Vector2(-1, 0)},
    "companion_ships": {"root": Vector2(3, 2), "step": Vector2(1, 1)},
    "run_time": {"root": Vector2(2, 1), "step": Vector2(1, 0)},
    "core_damage": {"root": Vector2(1, 5), "step": Vector2(1, 0)},
}

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var saved_data: Dictionary = PROGRESS.load_data()
    var saved_upgrades: Dictionary = saved_data.get("upgrades", {})
    var grouped_upgrades: Array[Dictionary] = _group_upgrades(BALANCE.get_upgrade_catalog())
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
        upgrade.mod = _mod_for_open_pit_upgrade_key(upgrade_key)
        upgrade.value = 0.0
        upgrade.max_tier = int(entry.get("max_tier", 1))
        upgrade.base_cost = int(entry.get("base_cost", 0))
        upgrade.cost_scale = 0.0
        upgrade.tier_costs = entry.get("tier_costs", [])
        upgrade.demo_locked = 0
        upgrade.section = 0
        upgrade.act = int(entry.get("act", 1))
        upgrade.epilogue = 0
        upgrade.type = Util.NODE_TYPES.NORMAL
        upgrade.sim_key = upgrade_key
        upgrade.sim_name = str(entry.get("label", upgrade_key))
        upgrade.sim_description = str(entry.get("summary", "Open Pit upgrade."))
        upgrade.sim_icon = str(entry.get("icon", "O"))
        upgrade.sim_group = int(entry.get("group", 1))
        upgrade.sim_level = int(entry.get("level", 1))
        upgrade.sim_group_pos = 1
        var dep_id: String = str(entry.get("dependency", ""))
        upgrade.forced_cell = Vector2.ZERO if dep_id.is_empty() or dep_id == "__CENTER__" else Vector2(id_to_cell.get(dep_id, Vector2.ZERO))
        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = int(saved_upgrades.get(upgrade_key, 0))
        if owned_level >= upgrade.sim_level:
            upgrade.current_tier = clampi(owned_level - upgrade.sim_level + 1, 0, upgrade.max_tier)
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _group_upgrades(upgrade_catalog: Array[Dictionary]) -> Array[Dictionary]:
    var grouped: Array[Dictionary] = []
    for upgrade_def in upgrade_catalog:
        var upgrade_key: String = str(upgrade_def.get("id", ""))
        if upgrade_key.is_empty():
            continue
        var tier_costs: Array = []
        var max_level: int = int(upgrade_def.get("max_level", 1))
        for level in range(max_level):
            tier_costs.append(BALANCE.get_upgrade_cost(upgrade_key, level))
        var previous_group_id := ""
        var cursor := 0
        var group_index := 0
        while cursor < max_level:
            var start_level: int = cursor + 1
            var chunk_size: int = min(GROUPED_TIER_MAX, max_level - cursor)
            var group_id := "%s__G%d" % [upgrade_key, group_index + 1]
            var grouped_entry: Dictionary = upgrade_def.duplicate(true)
            grouped_entry["id"] = group_id
            grouped_entry["key"] = upgrade_key
            grouped_entry["max_tier"] = chunk_size
            grouped_entry["base_cost"] = int(tier_costs[cursor])
            grouped_entry["tier_costs"] = tier_costs.slice(cursor, cursor + chunk_size)
            grouped_entry["level"] = start_level
            grouped_entry["group"] = group_index + 1
            grouped_entry["dependency"] = previous_group_id if previous_group_id != "" else _resolve_root_dependency(upgrade_def)
            grouped_entry["label"] = str(upgrade_def.get("label", upgrade_key))
            grouped.append(grouped_entry)
            previous_group_id = group_id
            cursor += chunk_size
            group_index += 1
    return grouped

static func _resolve_root_dependency(upgrade_def: Dictionary) -> String:
    var requires: Dictionary = upgrade_def.get("requires", {})
    if requires.is_empty():
        return "__CENTER__"
    for key_variant in requires.keys():
        var dependency_key: String = str(key_variant)
        var required_level: int = int(requires.get(dependency_key, 1))
        var group_index: int = max(1, int(ceil(float(max(required_level, 1)) / float(GROUPED_TIER_MAX))))
        return "%s__G%d" % [dependency_key, group_index]
    return "__CENTER__"

static func _build_tree_layout(grouped_upgrades: Array[Dictionary]) -> Dictionary:
    var id_to_cell: Dictionary = {}
    var used_cells: Dictionary = {Vector2.ZERO: true}
    for entry in grouped_upgrades:
        var upgrade_id: String = str(entry.get("id", ""))
        var upgrade_key: String = str(entry.get("key", ""))
        var group_index: int = int(entry.get("group", 1))
        var layout: Dictionary = LAYOUT_BY_KEY.get(upgrade_key, {})
        var root: Vector2 = Vector2(layout.get("root", Vector2.ZERO))
        var step: Vector2 = Vector2(layout.get("step", Vector2.RIGHT))
        var cell: Vector2 = root + step * max(0, group_index - 1)
        while used_cells.has(cell):
            cell += step
        id_to_cell[upgrade_id] = cell
        used_cells[cell] = true
    return id_to_cell

static func _mod_for_open_pit_upgrade_key(upgrade_key: String) -> Util.MODS:
    match upgrade_key:
        "attack_damage", "core_damage":
            return Util.MODS.BASE_DAMAGE_PER_CLICK
        "attack_speed":
            return Util.MODS.CLICK_RATE
        "mining_radius", "pickup_radius":
            return Util.MODS.CLICK_AOE
        "move_speed":
            return Util.MODS.RUN_TIMER_AMOUNT_ON_ASTEROID_DESTROYED
        "shield_count":
            return Util.MODS.ASTEROID_DENSITY
        "salvage_keep":
            return Util.MODS.CHANCE_TO_RESPAWN_ASTEROID_ON_BREAK
        "multi_target":
            return Util.MODS.ASTEROIDS_TO_SPAWN
        "ore_value", "cargo_capacity":
            return Util.MODS.MONEY_PER_MATTER
        "layer_access":
            return Util.MODS.MAX_ASTEROID_SIZE
        "crit_chance", "explosion_chance", "chain_chance":
            return Util.MODS.CLICKER_CRIT_CHANCE
        "companion_ships":
            return Util.MODS.ELECTRIC_CRIT_CHANCE
        "run_time":
            return Util.MODS.RUN_TIMER_BASE
        _:
            return Util.MODS.MONEY_PER_MATTER
