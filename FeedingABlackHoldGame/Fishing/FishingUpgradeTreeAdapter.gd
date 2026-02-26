extends RefCounted
class_name FishingUpgradeTreeAdapter

const DATA_PATH: String = "res://Data/FishingUpgradeData.json"
const GROUPED_TIER_MAX := 5
const LAYOUT_DIRS: Array[Vector2] = [
    Vector2.RIGHT,
    Vector2.LEFT,
    Vector2.UP,
    Vector2.DOWN,
    Vector2(1, -1),
    Vector2(-1, -1),
    Vector2(1, 1),
    Vector2(-1, 1),
]
const ICON_MODS: Array[int] = [
    Util.MODS.BASE_DAMAGE_PER_CLICK,
    Util.MODS.CLICK_RATE,
    Util.MODS.CLICK_AOE,
    Util.MODS.CLICKER_CRIT_CHANCE,
    Util.MODS.CLICKER_CRIT_BONUS,
    Util.MODS.PASSIVE_MONEY_PER_SECOND,
    Util.MODS.BONUS_MONEY_SCALE,
    Util.MODS.RUN_TIMER_BASE,
]
const THEME_HERO_UNLOCK_ACT := 1
const THEME_DAMAGE_ACT := 2
const THEME_UTILITY_ECON_ACT := 3
const THEME_DEFENSE_SURVIVAL_ACT := 4
const THEME_POWER_ACTIVE_ACT := 5
const THEME_BOSS_DENSITY_ACT := 6
const THEME_MISC_TEAM_ACT := 7
const EXTRA_SKILL_THEME_CYCLE: Array[int] = [
    THEME_UTILITY_ECON_ACT, # ECON
    THEME_BOSS_DENSITY_ACT, # DENS
    THEME_DEFENSE_SURVIVAL_ACT, # SURV
    THEME_UTILITY_ECON_ACT, # MOVE
    THEME_POWER_ACTIVE_ACT, # POWR
    THEME_POWER_ACTIVE_ACT, # ACTV
    THEME_BOSS_DENSITY_ACT, # BOSS
    THEME_MISC_TEAM_ACT, # TEAM
]

static func apply_simulation_upgrades() -> void:
    var json_variant: Variant = Util.load_json_data_from_path(DATA_PATH)
    if not (json_variant is Dictionary):
        push_error("FishingUpgradeTreeAdapter: failed to read " + DATA_PATH)
        return

    var json_data: Dictionary = json_variant
    var upgrades_variant: Variant = json_data.get("upgrades", [])
    if not (upgrades_variant is Array):
        push_error("FishingUpgradeTreeAdapter: upgrades array missing in " + DATA_PATH)
        return

    var raw_upgrades: Array = upgrades_variant
    var grouped_upgrades: Array = _group_repeated_upgrades(raw_upgrades)
    _sanitize_dependency_graph(grouped_upgrades)
    var id_to_cell: Dictionary = _build_tree_layout(grouped_upgrades)
    var formatter: FishingUpgradeDB = FishingUpgradeDB.new()

    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var i: int = 0
    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant

        var upgrade: Upgrade = Upgrade.new()
        upgrade.id = i
        i += 1

        var upgrade_id: String = str(entry.get("id", ""))
        upgrade.cell = id_to_cell.get(upgrade_id, Vector2.ZERO)

        var mod_index: int = i % ICON_MODS.size()
        upgrade.mod = ICON_MODS[mod_index]
        upgrade.value = 0.0
        upgrade.max_tier = int(entry.get("max_tier", 1))
        upgrade.base_cost = int(round(float(entry.get("cost", 0.0))))
        upgrade.cost_scale = 0.0
        var tier_costs_variant: Variant = entry.get("tier_costs", [])
        if tier_costs_variant is Array:
            upgrade.tier_costs = tier_costs_variant
        upgrade.forced_cell = null
        upgrade.demo_locked = 0
        upgrade.section = 0
        upgrade.epilogue = 0
        upgrade.type = Util.NODE_TYPES.NORMAL

        upgrade.sim_key = str(entry.get("key", ""))
        upgrade.act = _theme_act_for_key(upgrade.sim_key)
        upgrade.sim_name = formatter.get_display_name(entry)
        upgrade.sim_description = formatter.get_description(entry)
        upgrade.sim_icon = _resolve_icon(entry, upgrade.sim_key)
        upgrade.sim_group = int(entry.get("group", 1))
        upgrade.sim_level = int(entry.get("level", 1))
        upgrade.sim_group_pos = int(entry.get("group_pos", 1))

        var dep_variant: Variant = entry.get("dependency", null)
        if dep_variant != null:
            var dep_id: String = str(dep_variant)
            if dep_id != "" and id_to_cell.has(dep_id):
                upgrade.forced_cell = id_to_cell[dep_id]

        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = SaveHandler.get_fishing_upgrade_level(upgrade.sim_key)
        if owned_level >= upgrade.sim_level:
            var unlocked_tiers: int = clamp(owned_level - upgrade.sim_level + 1, 0, upgrade.max_tier)
            upgrade.current_tier = unlocked_tiers
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _group_repeated_upgrades(raw_upgrades: Array) -> Array:
    var by_key: Dictionary = {}
    var key_order: Array[String] = []
    for entry_variant: Variant in raw_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        if key == "":
            continue
        if not by_key.has(key):
            by_key[key] = []
            key_order.append(key)
        var arr: Array = by_key[key]
        arr.append(entry)
        by_key[key] = arr

    var grouped: Array = []
    var raw_id_to_group_id: Dictionary = {}

    for key in key_order:
        var key_entries: Array = by_key.get(key, [])
        key_entries.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.get("level", 1)) < int(b.get("level", 1)))

        var chunk_index: int = 0
        var cursor: int = 0
        while cursor < key_entries.size():
            var first: Dictionary = key_entries[cursor]
            var chunk_size: int = min(GROUPED_TIER_MAX, key_entries.size() - cursor)
            var chunk: Array = []
            for i in range(chunk_size):
                chunk.append(key_entries[cursor + i])

            var group_id: String = "%s__G%d" % [key, chunk_index + 1]
            var tier_costs: Array = []
            for raw in chunk:
                tier_costs.append(float(raw.get("cost", 0.0)))
                var raw_id: String = str(raw.get("id", ""))
                if raw_id != "":
                    raw_id_to_group_id[raw_id] = group_id

            var grouped_entry: Dictionary = first.duplicate(true)
            grouped_entry["id"] = group_id
            grouped_entry["max_tier"] = chunk_size
            grouped_entry["tier_costs"] = tier_costs
            grouped_entry["cost"] = float(tier_costs[0]) if tier_costs.size() > 0 else float(first.get("cost", 0.0))
            grouped_entry["level"] = int(first.get("level", 1))
            grouped_entry["dependency"] = str(first.get("dependency", ""))
            grouped.append(grouped_entry)

            chunk_index += 1
            cursor += chunk_size

    for i in range(grouped.size()):
        var grouped_entry_variant: Variant = grouped[i]
        if not (grouped_entry_variant is Dictionary):
            continue
        var grouped_entry: Dictionary = grouped_entry_variant
        var dep_id: String = str(grouped_entry.get("dependency", ""))
        if dep_id != "" and raw_id_to_group_id.has(dep_id):
            grouped_entry["dependency"] = str(raw_id_to_group_id[dep_id])
        grouped[i] = grouped_entry

    return grouped

static func _sanitize_dependency_graph(grouped_upgrades: Array) -> void:
    var id_to_entry: Dictionary = {}
    var id_to_dep: Dictionary = {}

    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id == "":
            continue
        id_to_entry[upgrade_id] = entry
        id_to_dep[upgrade_id] = str(entry.get("dependency", ""))

    for upgrade_id_variant: Variant in id_to_dep.keys():
        var upgrade_id: String = str(upgrade_id_variant)
        var dep_id: String = str(id_to_dep.get(upgrade_id, ""))
        if dep_id == "":
            continue
        if dep_id == upgrade_id or not id_to_entry.has(dep_id):
            var invalid_entry: Dictionary = id_to_entry[upgrade_id]
            invalid_entry["dependency"] = ""
            id_to_entry[upgrade_id] = invalid_entry
            id_to_dep[upgrade_id] = ""

    for upgrade_id_variant: Variant in id_to_dep.keys():
        var upgrade_id: String = str(upgrade_id_variant)
        var seen: Dictionary = {}
        var current: String = upgrade_id

        while true:
            var dep_id: String = str(id_to_dep.get(current, ""))
            if dep_id == "":
                break
            if dep_id == upgrade_id or seen.has(dep_id):
                var break_entry: Dictionary = id_to_entry[current]
                break_entry["dependency"] = ""
                id_to_entry[current] = break_entry
                id_to_dep[current] = ""
                break
            seen[current] = true
            current = dep_id
            if not id_to_dep.has(current):
                break

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id != "" and id_to_entry.has(upgrade_id):
            grouped_upgrades[i] = id_to_entry[upgrade_id]

static func _build_tree_layout(grouped_upgrades: Array) -> Dictionary:
    var id_to_cell: Dictionary = {}
    var used_cells: Dictionary = {}
    var root_counts: Dictionary = {}

    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id == "":
            continue

        var key: String = str(entry.get("key", ""))
        var branch: int = _branch_for_key(key)
        var dir: Vector2 = LAYOUT_DIRS[branch]
        var dep_id: String = str(entry.get("dependency", ""))

        var target: Vector2
        if dep_id != "" and id_to_cell.has(dep_id):
            var parent_cell: Vector2 = id_to_cell[dep_id]
            target = parent_cell + dir
        else:
            var branch_count: int = int(root_counts.get(branch, 0))
            var ring: int = 1 + int(branch_count / 2)
            target = dir * ring
            root_counts[branch] = branch_count + 1

        var cell: Vector2 = _find_free_layout_cell(target, used_cells)

        id_to_cell[upgrade_id] = cell
        used_cells[cell] = true

    return id_to_cell

static func _find_free_layout_cell(target: Vector2, used_cells: Dictionary) -> Vector2:
    if not used_cells.has(target):
        return target
    for radius in range(1, 6):
        for y in range(-radius, radius + 1):
            for x in range(-radius, radius + 1):
                var candidate: Vector2 = target + Vector2(x, y)
                if used_cells.has(candidate):
                    continue
                return candidate
    var fallback: Vector2 = target
    while used_cells.has(fallback):
        fallback += Vector2.RIGHT
    return fallback

static func _branch_for_key(key: String) -> int:
    var theme_act: int = _theme_act_for_key(key)
    match theme_act:
        THEME_HERO_UNLOCK_ACT:
            return 0
        THEME_DAMAGE_ACT:
            return 1
        THEME_UTILITY_ECON_ACT:
            return 2
        THEME_DEFENSE_SURVIVAL_ACT:
            return 3
        THEME_POWER_ACTIVE_ACT:
            return 4
        THEME_BOSS_DENSITY_ACT:
            return 5
        THEME_MISC_TEAM_ACT:
            return 6

    var lower: String = key.to_lower()
    var hash_val: int = 0
    for c in lower:
        hash_val = int((hash_val * 31 + c.unicode_at(0)) % 2147483647)
    return int(abs(hash_val) % LAYOUT_DIRS.size())

static func _theme_act_for_key(key: String) -> int:
    var lower: String = key.to_lower()

    var extra_skill_theme: int = _extra_skill_theme_act(lower)
    if extra_skill_theme > 0:
        return extra_skill_theme

    # Theme 1: hero recruitment and roster unlocks.
    if lower.begins_with("recruit_"):
        return THEME_HERO_UNLOCK_ACT

    # Theme 2: direct combat power scaling.
    if lower.find("damage") >= 0 \
    or lower.find("speed") >= 0 \
    or lower.find("pierce") >= 0 \
    or lower.find("storm") >= 0 \
    or lower.find("bloodline") >= 0 \
    or lower.find("vamp") >= 0 \
    or lower.find("wave") >= 0 \
    or lower.find("impact") >= 0 \
    or lower.find("sigil") >= 0 \
    or lower.find("piercing") >= 0 \
    or lower.find("drill") >= 0 \
    or lower.find("line_pressure") >= 0 \
    or lower.find("auto_attack") >= 0:
        return THEME_DAMAGE_ACT

    # Theme 3: utility/economy/pickup/QoL systems.
    if lower.find("cursor") >= 0 \
    or lower.find("pickup") >= 0 \
    or lower.find("drop") >= 0 \
    or lower.find("salvage") >= 0 \
    or lower.find("broker") >= 0 \
    or lower.find("collector") >= 0 \
    or lower.find("market") >= 0 \
    or lower.find("scanner") >= 0 \
    or lower.find("magnet") >= 0 \
    or lower.find("lens") >= 0 \
    or lower.find("breathing") >= 0 \
    or lower.find("rhythm") >= 0 \
    or lower.find("momentum") >= 0 \
    or lower.find("trail") >= 0 \
    or lower.find("route") >= 0 \
    or lower.find("yield") >= 0 \
    or lower.find("march") >= 0 \
    or lower.find("sprint") >= 0 \
    or lower.find("quickstep") >= 0 \
    or lower.find("overflow") >= 0:
        return THEME_UTILITY_ECON_ACT

    # Theme 4: durability and mitigation.
    if lower.find("armor") >= 0 \
    or lower.find("plate") >= 0 \
    or lower.find("carapace") >= 0 \
    or lower.find("shock") >= 0 \
    or lower.find("hemostasis") >= 0 \
    or lower.find("bulwark") >= 0 \
    or lower.find("fortify") >= 0 \
    or lower.find("deflector") >= 0:
        return THEME_DEFENSE_SURVIVAL_ACT

    # Theme 5: power economy and active cadence.
    if lower.find("power") >= 0 \
    or lower.find("reservoir") >= 0 \
    or lower.find("condensed") >= 0 \
    or lower.find("invocation") >= 0 \
    or lower.find("channel") >= 0 \
    or lower.find("overclock") >= 0 \
    or lower.find("cadence") >= 0 \
    or lower.find("active") >= 0:
        return THEME_POWER_ACTIVE_ACT

    # Theme 6: boss interaction and enemy density pressure.
    if lower.find("boss") >= 0 \
    or lower.find("horde") >= 0 \
    or lower.find("density") >= 0 \
    or lower.find("wave") >= 0 \
    or lower.find("crowd") >= 0 \
    or lower.find("pressure") >= 0 \
    or lower.find("front_compression") >= 0:
        return THEME_BOSS_DENSITY_ACT

    # Theme 7: remaining mixed/team/meta upgrades.
    return THEME_MISC_TEAM_ACT

static func _extra_skill_theme_act(lower_key: String) -> int:
    if not lower_key.begins_with("extra_skill_"):
        return 0
    var suffix: String = lower_key.trim_prefix("extra_skill_")
    if suffix == "":
        return 0
    var index: int = int(suffix) - 1
    if index < 0:
        return 0
    return EXTRA_SKILL_THEME_CYCLE[index % EXTRA_SKILL_THEME_CYCLE.size()]

static func _resolve_icon(entry: Dictionary, key: String) -> String:
    var raw_icon: String = str(entry.get("icon", "")).strip_edges()
    if raw_icon != "":
        return raw_icon.substr(0, 1)
    return _fallback_icon_for_key(key)

static func _fallback_icon_for_key(key: String) -> String:
    var theme_act: int = _theme_act_for_key(key)
    match theme_act:
        THEME_HERO_UNLOCK_ACT:
            return "H"
        THEME_DAMAGE_ACT:
            return "D"
        THEME_UTILITY_ECON_ACT:
            return "U"
        THEME_DEFENSE_SURVIVAL_ACT:
            return "S"
        THEME_POWER_ACTIVE_ACT:
            return "P"
        THEME_BOSS_DENSITY_ACT:
            return "B"
        _:
            return "M"
