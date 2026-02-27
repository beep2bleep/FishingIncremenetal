extends RefCounted
class_name FishingUpgradeTreeAdapter

const DATA_PATH: String = "res://Data/FishingUpgradeData.json"
const GROUPED_TIER_MAX := 5
const MAX_CHILDREN_PER_NODE := 4
const LAYOUT_DIRS: Array[Vector2] = [
    Vector2.RIGHT,
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
]
const INVALID_LAYOUT_CELL := Vector2(2147483647, 2147483647)
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
    _retarget_dependencies_to_hubs(grouped_upgrades)
    _enforce_required_prerequisites(grouped_upgrades)
    _enforce_max_children_per_node(grouped_upgrades, MAX_CHILDREN_PER_NODE)
    _enforce_required_prerequisites(grouped_upgrades)
    _sanitize_dependency_graph(grouped_upgrades)
    _flatten_linear_dependency_chains(grouped_upgrades, MAX_CHILDREN_PER_NODE)
    _enforce_required_prerequisites(grouped_upgrades)
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
            if dep_id == "__CENTER__":
                upgrade.forced_cell = Vector2.ZERO
            elif dep_id != "" and id_to_cell.has(dep_id):
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
        var previous_group_id: String = ""
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
            grouped_entry["dependency"] = previous_group_id if previous_group_id != "" else str(first.get("dependency", ""))
            grouped.append(grouped_entry)
            previous_group_id = group_id

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

    for i in range(grouped.size()):
        var grouped_entry_variant: Variant = grouped[i]
        if not (grouped_entry_variant is Dictionary):
            continue
        var grouped_entry: Dictionary = grouped_entry_variant
        var dep_id: String = str(grouped_entry.get("dependency", ""))
        if dep_id == "":
            grouped_entry["dependency"] = "__CENTER__"
            grouped[i] = grouped_entry

    return grouped

static func _retarget_dependencies_to_hubs(grouped_upgrades: Array) -> void:
    var key_to_primary_id: Dictionary = {}
    var key_to_entries: Dictionary = {}
    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        var entry_id: String = str(entry.get("id", ""))
        if key == "" or entry_id == "":
            continue
        if not key_to_primary_id.has(key):
            key_to_primary_id[key] = entry_id
        if not key_to_entries.has(key):
            key_to_entries[key] = []
        var arr: Array = key_to_entries[key]
        arr.append(entry)
        key_to_entries[key] = arr

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        var entry_id: String = str(entry.get("id", ""))
        if key == "" or entry_id == "":
            continue

        var dep_key: String = _select_hub_dependency_key(key, key_to_primary_id)
        if dep_key == "":
            entry["dependency"] = "__CENTER__"
        elif key_to_primary_id.has(dep_key):
            entry["dependency"] = str(key_to_primary_id[dep_key])
        else:
            entry["dependency"] = "__CENTER__"

        # Avoid accidental self-dependency if a key resolves to its own primary entry.
        if str(entry.get("dependency", "")) == entry_id:
            entry["dependency"] = "__CENTER__"

        grouped_upgrades[i] = entry

static func _select_hub_dependency_key(key: String, key_to_primary_id: Dictionary) -> String:
    var lower: String = key.to_lower()
    var hero: String = _hero_from_key(lower)
    var gated_hero: bool = hero == "archer" or hero == "guardian" or hero == "mage"
    var recruit_key_for_hero: String = "recruit_%s" % hero if hero != "" else ""
    var hero_unlock_key: String = _hero_unlock_key(hero) if hero != "" else ""

    if lower.begins_with("core_") or lower.begins_with("recruit_"):
        if lower.begins_with("recruit_"):
            return ""
        if gated_hero and recruit_key_for_hero != "" and key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        return ""

    if lower.ends_with("_unlock"):
        if gated_hero and recruit_key_for_hero != "" and key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        if hero != "":
            if key_to_primary_id.has(recruit_key_for_hero):
                return recruit_key_for_hero
        return ""

    if lower.begins_with("extra_skill_"):
        if key_to_primary_id.has("core_power"):
            return "core_power"
        return ""

    if hero != "":
        if gated_hero:
            if hero_unlock_key != "" and key_to_primary_id.has(hero_unlock_key):
                return hero_unlock_key
            if recruit_key_for_hero != "" and key_to_primary_id.has(recruit_key_for_hero):
                return recruit_key_for_hero
            return ""

        var hero_core_damage_key: String = "core_%s_damage" % hero
        if key_to_primary_id.has(hero_unlock_key):
            return hero_unlock_key
        if key_to_primary_id.has(hero_core_damage_key):
            return hero_core_damage_key
        if key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        return ""

    var theme_act: int = _theme_act_for_key(key)
    match theme_act:
        THEME_DAMAGE_ACT:
            if key_to_primary_id.has("core_knight_damage"):
                return "core_knight_damage"
        THEME_UTILITY_ECON_ACT:
            if key_to_primary_id.has("core_drop"):
                return "core_drop"
            if key_to_primary_id.has("cursor_pickup_unlock"):
                return "cursor_pickup_unlock"
        THEME_DEFENSE_SURVIVAL_ACT:
            if key_to_primary_id.has("core_armor"):
                return "core_armor"
        THEME_POWER_ACTIVE_ACT:
            if key_to_primary_id.has("core_power"):
                return "core_power"
            if key_to_primary_id.has("power_harvest_unlock"):
                return "power_harvest_unlock"
        THEME_BOSS_DENSITY_ACT:
            if key_to_primary_id.has("core_density"):
                return "core_density"
        THEME_MISC_TEAM_ACT:
            if key_to_primary_id.has("auto_attack_unlock"):
                return "auto_attack_unlock"
    return ""

static func _hero_from_key(lower_key: String) -> String:
    if lower_key.find("archer") >= 0:
        return "archer"
    if lower_key.find("guardian") >= 0:
        return "guardian"
    if lower_key.find("mage") >= 0:
        return "mage"
    if lower_key.find("knight") >= 0:
        return "knight"
    return ""

static func _hero_unlock_key(hero: String) -> String:
    match hero:
        "archer":
            return "archer_pierce_unlock"
        "guardian":
            return "guardian_fortify_unlock"
        "mage":
            return "mage_storm_unlock"
        "knight":
            return "knight_vamp_unlock"
        _:
            return ""

static func _required_unlock_key_for_upgrade(key: String) -> String:
    var lower: String = key.to_lower()
    if lower == "" or lower == "__center__":
        return ""

    if lower.find("archer") >= 0 and not lower.begins_with("recruit_archer"):
        if lower.find("pierce") >= 0 or lower.find("drill") >= 0 or lower.find("piercing") >= 0:
            return "archer_pierce_unlock"
        return "recruit_archer"

    if lower.find("mage") >= 0 and not lower.begins_with("recruit_mage"):
        if lower.find("storm") >= 0 or lower.find("sigil") >= 0:
            return "mage_storm_unlock"
        return "recruit_mage"

    if lower.find("guardian") >= 0 and not lower.begins_with("recruit_guardian"):
        if lower.find("fortify") >= 0 or lower.find("bulwark") >= 0:
            return "guardian_fortify_unlock"
        return "recruit_guardian"

    if (lower.find("vamp") >= 0 or lower.find("bloodline") >= 0) and not lower.begins_with("knight_vamp_unlock"):
        return "knight_vamp_unlock"

    if (lower.find("cursor") >= 0 or lower.find("pickup") >= 0 or lower.find("magnet") >= 0 or lower.find("lens") >= 0) and lower != "cursor_pickup_unlock":
        return "cursor_pickup_unlock"

    if (lower.find("reservoir") >= 0 or lower.find("invocation") >= 0 or lower.find("channel") >= 0) and lower != "power_harvest_unlock":
        return "power_harvest_unlock"

    return ""

static func _enforce_required_prerequisites(grouped_upgrades: Array) -> void:
    var key_to_primary_id: Dictionary = {}
    var id_to_entry: Dictionary = {}
    var id_to_dep: Dictionary = {}

    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        var key: String = str(entry.get("key", ""))
        if entry_id == "":
            continue
        id_to_entry[entry_id] = entry
        id_to_dep[entry_id] = str(entry.get("dependency", ""))
        if key != "" and not key_to_primary_id.has(key):
            key_to_primary_id[key] = entry_id

    for id_variant: Variant in id_to_entry.keys():
        var entry_id: String = str(id_variant)
        var entry: Dictionary = id_to_entry[entry_id]
        var key: String = str(entry.get("key", ""))
        var required_key: String = _required_unlock_key_for_upgrade(key)
        if required_key == "" or not key_to_primary_id.has(required_key):
            continue
        var required_id: String = str(key_to_primary_id[required_key])
        if required_id == "" or required_id == entry_id:
            continue
        if _dependency_reaches_target(id_to_dep, entry_id, required_id):
            continue
        entry["dependency"] = required_id
        id_to_entry[entry_id] = entry
        id_to_dep[entry_id] = required_id

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id != "" and id_to_entry.has(entry_id):
            grouped_upgrades[i] = id_to_entry[entry_id]

static func _dependency_reaches_target(id_to_dep: Dictionary, from_id: String, target_id: String) -> bool:
    if from_id == "" or target_id == "":
        return false
    var current: String = from_id
    var visited: Dictionary = {}
    while id_to_dep.has(current):
        var dep_id: String = str(id_to_dep.get(current, ""))
        if dep_id == "" or dep_id == "__CENTER__":
            return false
        if dep_id == target_id:
            return true
        if visited.has(dep_id):
            return false
        visited[dep_id] = true
        current = dep_id
    return false

static func _enforce_max_children_per_node(grouped_upgrades: Array, max_children: int) -> void:
    if max_children <= 0:
        return

    var id_to_entry: Dictionary = {}
    var children_by_dep: Dictionary = {}
    var child_count: Dictionary = {}
    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id == "":
            continue
        id_to_entry[entry_id] = entry
        var dep_id: String = str(entry.get("dependency", ""))
        if dep_id == "":
            continue
        if not children_by_dep.has(dep_id):
            children_by_dep[dep_id] = []
        var dep_children: Array = children_by_dep[dep_id]
        dep_children.append(entry_id)
        children_by_dep[dep_id] = dep_children
        child_count[dep_id] = int(child_count.get(dep_id, 0)) + 1

    var dep_ids: Array = children_by_dep.keys()
    dep_ids.sort()
    for dep_variant: Variant in dep_ids:
        var dep_id: String = str(dep_variant)
        var dep_children: Array = children_by_dep.get(dep_id, [])
        if dep_children.size() <= max_children:
            continue

        dep_children.sort_custom(func(a: Variant, b: Variant) -> bool:
            var a_id: String = str(a)
            var b_id: String = str(b)
            var a_entry: Dictionary = id_to_entry.get(a_id, {})
            var b_entry: Dictionary = id_to_entry.get(b_id, {})
            return float(a_entry.get("cost", 0.0)) < float(b_entry.get("cost", 0.0))
        )

        var keep_children: Array = dep_children.slice(0, max_children)
        var overflow_children: Array = dep_children.slice(max_children)
        child_count[dep_id] = max_children
        children_by_dep[dep_id] = keep_children

        var candidate_parents: Array = keep_children.duplicate()
        var candidate_index: int = 0

        for overflow_variant: Variant in overflow_children:
            var overflow_id: String = str(overflow_variant)
            if overflow_id == "":
                continue
            if not id_to_entry.has(overflow_id):
                continue

            var new_parent: String = ""
            var attempts: int = 0
            while candidate_parents.size() > 0 and attempts < candidate_parents.size():
                if candidate_index >= candidate_parents.size():
                    candidate_index = 0
                var candidate: String = str(candidate_parents[candidate_index])
                candidate_index += 1
                attempts += 1
                if candidate == "" or candidate == overflow_id:
                    continue
                var current_children: int = int(child_count.get(candidate, 0))
                if current_children >= max_children:
                    continue
                new_parent = candidate
                break

            if new_parent == "":
                new_parent = dep_id

            var entry_to_move: Dictionary = id_to_entry[overflow_id]
            entry_to_move["dependency"] = new_parent
            id_to_entry[overflow_id] = entry_to_move

            child_count[new_parent] = int(child_count.get(new_parent, 0)) + 1
            if not children_by_dep.has(new_parent):
                children_by_dep[new_parent] = []
            var new_parent_children: Array = children_by_dep[new_parent]
            new_parent_children.append(overflow_id)
            children_by_dep[new_parent] = new_parent_children

            if not candidate_parents.has(overflow_id):
                candidate_parents.append(overflow_id)

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id == "":
            continue
        if id_to_entry.has(entry_id):
            grouped_upgrades[i] = id_to_entry[entry_id]

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
        if dep_id == "__CENTER__":
            continue
        if dep_id == upgrade_id or not id_to_entry.has(dep_id):
            var invalid_entry: Dictionary = id_to_entry[upgrade_id]
            invalid_entry["dependency"] = "__CENTER__"
            id_to_entry[upgrade_id] = invalid_entry
            id_to_dep[upgrade_id] = "__CENTER__"

    for upgrade_id_variant: Variant in id_to_dep.keys():
        var upgrade_id: String = str(upgrade_id_variant)
        var seen: Dictionary = {}
        var current: String = upgrade_id

        while true:
            var dep_id: String = str(id_to_dep.get(current, ""))
            if dep_id == "":
                break
            if dep_id == "__CENTER__":
                break
            if dep_id == upgrade_id or seen.has(dep_id):
                var break_entry: Dictionary = id_to_entry[current]
                break_entry["dependency"] = "__CENTER__"
                id_to_entry[current] = break_entry
                id_to_dep[current] = "__CENTER__"
                break
            seen[current] = true
            current = dep_id
            if not id_to_dep.has(current):
                break

    for upgrade_id_variant: Variant in id_to_dep.keys():
        var upgrade_id: String = str(upgrade_id_variant)
        if str(id_to_dep.get(upgrade_id, "")) == "":
            var root_entry: Dictionary = id_to_entry[upgrade_id]
            root_entry["dependency"] = "__CENTER__"
            id_to_entry[upgrade_id] = root_entry
            id_to_dep[upgrade_id] = "__CENTER__"

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id != "" and id_to_entry.has(upgrade_id):
            grouped_upgrades[i] = id_to_entry[upgrade_id]

static func _flatten_linear_dependency_chains(grouped_upgrades: Array, max_children: int) -> void:
    if max_children <= 1:
        return

    var id_to_entry: Dictionary = {}
    var children_by_dep: Dictionary = {}

    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id == "":
            continue
        id_to_entry[entry_id] = entry
        var dep_id: String = str(entry.get("dependency", ""))
        if dep_id == "":
            continue
        if not children_by_dep.has(dep_id):
            children_by_dep[dep_id] = []
        var dep_children: Array = children_by_dep[dep_id]
        dep_children.append(entry_id)
        children_by_dep[dep_id] = dep_children

    for parent_variant: Variant in children_by_dep.keys():
        var parent_id: String = str(parent_variant)
        var direct_children: Array = children_by_dep.get(parent_id, [])
        if direct_children.size() != 1:
            continue

        var chain: Array[String] = []
        var cursor: String = str(direct_children[0])
        while cursor != "" and id_to_entry.has(cursor):
            chain.append(cursor)
            var next_children: Array = children_by_dep.get(cursor, [])
            if next_children.size() != 1:
                break
            cursor = str(next_children[0])

        if chain.size() < 4:
            continue

        var slots_remaining: int = max_children - int(direct_children.size())
        if slots_remaining <= 0:
            continue

        for i in range(1, chain.size()):
            if slots_remaining <= 0:
                break
            var node_id: String = chain[i]
            var node_entry: Dictionary = id_to_entry.get(node_id, {})
            if node_entry.is_empty():
                continue

            var old_dep: String = str(node_entry.get("dependency", ""))
            if old_dep == parent_id:
                continue

            if old_dep != "" and children_by_dep.has(old_dep):
                var old_children: Array = children_by_dep[old_dep]
                old_children.erase(node_id)
                children_by_dep[old_dep] = old_children

            node_entry["dependency"] = parent_id
            id_to_entry[node_id] = node_entry
            if not children_by_dep.has(parent_id):
                children_by_dep[parent_id] = []
            var parent_children: Array = children_by_dep[parent_id]
            if not parent_children.has(node_id):
                parent_children.append(node_id)
                children_by_dep[parent_id] = parent_children
                slots_remaining -= 1

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id != "" and id_to_entry.has(entry_id):
            grouped_upgrades[i] = id_to_entry[entry_id]

static func _build_tree_layout(grouped_upgrades: Array) -> Dictionary:
    var id_to_cell: Dictionary = {}
    var used_cells: Dictionary = {}
    used_cells[Vector2.ZERO] = true
    var root_counts: Dictionary = {}
    var parent_child_counts: Dictionary = {}
    var placed_edges: Array[Dictionary] = []
    var pending_by_id: Dictionary = {}
    for entry_variant: Variant in grouped_upgrades:
        if entry_variant is Dictionary:
            var entry: Dictionary = entry_variant
            var upgrade_id: String = str(entry.get("id", ""))
            if upgrade_id != "":
                pending_by_id[upgrade_id] = entry

    while not pending_by_id.is_empty():
        var ids: Array = pending_by_id.keys()
        ids.sort_custom(func(a: Variant, b: Variant) -> bool:
            var a_entry: Dictionary = pending_by_id[str(a)]
            var b_entry: Dictionary = pending_by_id[str(b)]
            return float(a_entry.get("cost", 0.0)) < float(b_entry.get("cost", 0.0))
        )
        var placed_any: bool = false
        for id_variant: Variant in ids:
            var upgrade_id: String = str(id_variant)
            if not pending_by_id.has(upgrade_id):
                continue
            var entry: Dictionary = pending_by_id[upgrade_id]
            var dep_id: String = str(entry.get("dependency", ""))
            if dep_id != "" and dep_id != "__CENTER__" and not id_to_cell.has(dep_id):
                continue

            var key: String = str(entry.get("key", ""))
            var preferred_branch: int = _branch_for_key(key)
            var branch: int = preferred_branch
            if dep_id == "" or dep_id == "__CENTER__":
                branch = _choose_root_branch(preferred_branch, root_counts)
            var dir: Vector2 = LAYOUT_DIRS[branch]
            var cell: Vector2 = INVALID_LAYOUT_CELL

            if dep_id != "" and dep_id != "__CENTER__":
                var parent_cell: Vector2 = id_to_cell[dep_id]
                var child_index: int = int(parent_child_counts.get(dep_id, 0))
                parent_child_counts[dep_id] = child_index + 1
                cell = _find_layout_cell_for_child(parent_cell, branch, child_index, used_cells, placed_edges)
            else:
                var branch_count: int = int(root_counts.get(branch, 0))
                root_counts[branch] = branch_count + 1
                cell = _find_layout_cell_for_root(branch, branch_count, used_cells, placed_edges)

            id_to_cell[upgrade_id] = cell
            used_cells[cell] = true
            if dep_id != "":
                var from_cell: Vector2 = cell
                var to_cell: Vector2 = Vector2.ZERO if dep_id == "__CENTER__" else id_to_cell[dep_id]
                placed_edges.append({"a": from_cell, "b": to_cell})
            pending_by_id.erase(upgrade_id)
            placed_any = true

        if placed_any:
            continue

        var first_id: String = str(ids[0])
        var forced_entry: Dictionary = pending_by_id[first_id]
        forced_entry["dependency"] = ""
        pending_by_id[first_id] = forced_entry

    return id_to_cell

static func _find_free_adjacent_layout_cell(parent_cell: Vector2, preferred_branch: int, index_seed: int, used_cells: Dictionary) -> Vector2:
    var branch_order: Array[int] = _branch_order_for_child(preferred_branch, index_seed)
    for branch_variant: Variant in branch_order:
        var branch: int = int(branch_variant)
        if branch < 0 or branch >= LAYOUT_DIRS.size():
            continue
        var candidate: Vector2 = parent_cell + LAYOUT_DIRS[branch]
        if not used_cells.has(candidate):
            return candidate
    return INVALID_LAYOUT_CELL

static func _find_layout_cell_for_child(parent_cell: Vector2, preferred_branch: int, child_index: int, used_cells: Dictionary, placed_edges: Array) -> Vector2:
    var branch_order: Array[int] = _branch_order_for_child(preferred_branch, child_index)
    for branch_variant: Variant in branch_order:
        var b: int = int(branch_variant)
        var candidate: Vector2 = parent_cell + LAYOUT_DIRS[b]
        if used_cells.has(candidate):
            continue
        if not _is_strictly_outward(candidate, parent_cell):
            continue
        if _edge_is_clean(candidate, parent_cell, used_cells, placed_edges):
            return candidate

    var target: Vector2 = _compute_child_target(parent_cell, LAYOUT_DIRS[preferred_branch], child_index)
    var candidates: Array[Vector2] = _candidate_cells_cardinal(target, LAYOUT_DIRS[preferred_branch], 10)
    for candidate_variant: Variant in candidates:
        var candidate: Vector2 = candidate_variant
        if used_cells.has(candidate):
            continue
        if not _is_strictly_outward(candidate, parent_cell):
            continue
        if _edge_is_clean(candidate, parent_cell, used_cells, placed_edges):
            return candidate
    # Final fallback: march outward along preferred branch direction only.
    var dir: Vector2 = LAYOUT_DIRS[preferred_branch]
    for step in range(1, 512):
        var candidate: Vector2 = parent_cell + dir * step
        if used_cells.has(candidate):
            continue
        if not _is_strictly_outward(candidate, parent_cell):
            continue
        if _edge_is_clean(candidate, parent_cell, used_cells, placed_edges):
            return candidate

    # Last-resort sweep around growing manhattan rings, still requiring outward + clean edge.
    var parent_dist: int = _core_distance(parent_cell)
    for ring in range(parent_dist + 1, parent_dist + 256):
        for x in range(-ring, ring + 1):
            var y_abs: int = ring - abs(x)
            var c1: Vector2 = Vector2(x, y_abs)
            var c2: Vector2 = Vector2(x, -y_abs)
            for candidate in [c1, c2]:
                if used_cells.has(candidate):
                    continue
                if not _is_strictly_outward(candidate, parent_cell):
                    continue
                if _edge_is_clean(candidate, parent_cell, used_cells, placed_edges):
                    return candidate

    return _find_free_layout_cell_cardinal(parent_cell + dir * 2, dir, used_cells)

static func _find_layout_cell_for_root(branch: int, branch_count: int, used_cells: Dictionary, placed_edges: Array) -> Vector2:
    var dir: Vector2 = LAYOUT_DIRS[branch]
    var target: Vector2 = _compute_root_target(dir, branch_count)
    var candidates: Array[Vector2] = _candidate_cells_cardinal(target, dir, 10)
    for candidate_variant: Variant in candidates:
        var candidate: Vector2 = candidate_variant
        if used_cells.has(candidate):
            continue
        if not _is_valid_root_cell(candidate):
            continue
        if _edge_is_clean(candidate, Vector2.ZERO, used_cells, placed_edges):
            return candidate
    var fallback: Vector2 = _find_free_layout_cell_cardinal(target, dir, used_cells)
    if _is_valid_root_cell(fallback) and _edge_is_clean(fallback, Vector2.ZERO, used_cells, placed_edges):
        return fallback
    for step in range(2, 128):
        var candidate: Vector2 = dir * step
        if used_cells.has(candidate):
            continue
        if not _is_valid_root_cell(candidate):
            continue
        if _edge_is_clean(candidate, Vector2.ZERO, used_cells, placed_edges):
            return candidate
    return dir * 2

static func _candidate_cells_cardinal(target: Vector2, dir: Vector2, max_step: int) -> Array[Vector2]:
    var out: Array[Vector2] = []
    out.append(target)
    for step in range(1, max_step + 1):
        out.append(target + dir * step)
        out.append(target - dir * step)
    return out

static func _edge_is_clean(a: Vector2, b: Vector2, used_cells: Dictionary, placed_edges: Array) -> bool:
    if not _segment_clear_of_nodes(a, b, used_cells):
        return false
    if _segment_intersects_edges(a, b, placed_edges):
        return false
    return true

static func _segment_clear_of_nodes(a: Vector2, b: Vector2, used_cells: Dictionary) -> bool:
    for point_variant: Variant in used_cells.keys():
        if not (point_variant is Vector2):
            continue
        var p: Vector2 = point_variant
        if p == a or p == b:
            continue
        if _point_on_segment(p, a, b):
            return false
    return true

static func _segment_intersects_edges(a: Vector2, b: Vector2, placed_edges: Array) -> bool:
    for edge_variant: Variant in placed_edges:
        if not (edge_variant is Dictionary):
            continue
        var edge: Dictionary = edge_variant
        var c: Vector2 = edge.get("a", Vector2.ZERO)
        var d: Vector2 = edge.get("b", Vector2.ZERO)
        if _shares_endpoint(a, b, c, d):
            continue
        if Geometry2D.segment_intersects_segment(a, b, c, d) != null:
            return true
    return false

static func _shares_endpoint(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
    return a == c or a == d or b == c or b == d

static func _point_on_segment(p: Vector2, a: Vector2, b: Vector2) -> bool:
    var ab: Vector2 = b - a
    var ap: Vector2 = p - a
    var cross: float = abs(ab.cross(ap))
    if cross > 0.0001:
        return false
    var dot_val: float = ap.dot(ab)
    if dot_val < 0.0:
        return false
    if dot_val > ab.length_squared():
        return false
    return true

static func _core_distance(cell: Vector2) -> int:
    return abs(int(cell.x)) + abs(int(cell.y))

static func _is_strictly_outward(candidate: Vector2, parent_cell: Vector2) -> bool:
    return _core_distance(candidate) > _core_distance(parent_cell)

static func _is_valid_root_cell(candidate: Vector2) -> bool:
    return candidate != Vector2.ZERO and _core_distance(candidate) >= 2

static func _branch_order_for_child(preferred_branch: int, index_seed: int) -> Array[int]:
    var p: int = ((preferred_branch % LAYOUT_DIRS.size()) + LAYOUT_DIRS.size()) % LAYOUT_DIRS.size()
    var base: Array[int] = [
        p,
        (p + 1) % LAYOUT_DIRS.size(),
        (p + 3) % LAYOUT_DIRS.size(),
        (p + 2) % LAYOUT_DIRS.size(),
    ]
    var rotation: int = 0
    if base.size() > 0:
        rotation = int(abs(index_seed)) % base.size()
    var ordered: Array[int] = []
    for i in range(base.size()):
        ordered.append(base[(i + rotation) % base.size()])
    return ordered

static func _compute_root_target(main_dir: Vector2, branch_count: int) -> Vector2:
    var lane_pattern: Array[int] = [0, 1, -1]
    var lane: int = lane_pattern[branch_count % lane_pattern.size()]
    var ring: int = int(branch_count / lane_pattern.size())
    var forward: int = 2 + ring * 2
    var perp: Vector2 = _perpendicular_dir(main_dir)
    return (main_dir * forward) + (perp * lane)

static func _find_free_layout_cell_cardinal(target: Vector2, dir: Vector2, used_cells: Dictionary) -> Vector2:
    if not used_cells.has(target):
        return target
    for step in range(1, 8):
        var candidates: Array[Vector2] = [
            target + dir * step,
            target - dir * step,
        ]
        for candidate in candidates:
            if not used_cells.has(candidate):
                return candidate
    var fallback: Vector2 = target
    while used_cells.has(fallback):
        fallback += dir
    return fallback

static func _choose_root_branch(preferred_branch: int, root_counts: Dictionary) -> int:
    var min_count: int = 2147483647
    for i in range(LAYOUT_DIRS.size()):
        var count: int = int(root_counts.get(i, 0))
        if count < min_count:
            min_count = count

    var candidates: Array[int] = []
    for i in range(LAYOUT_DIRS.size()):
        var count: int = int(root_counts.get(i, 0))
        if count == min_count:
            candidates.append(i)

    if candidates.has(preferred_branch):
        return preferred_branch
    if candidates.is_empty():
        return preferred_branch
    return candidates[0]

static func _compute_child_target(parent_cell: Vector2, main_dir: Vector2, child_index: int) -> Vector2:
    var forward: int = 1 + int(child_index / 6)
    var lane_index: int = child_index % 6
    var lateral_unit: int = _lateral_from_lane(lane_index)
    var perp: Vector2 = _perpendicular_dir(main_dir)
    return parent_cell + (main_dir * forward) + (perp * lateral_unit)

static func _lateral_from_lane(lane_index: int) -> int:
    var lanes: Array[int] = [0, 1, -1, 2, -2, 3]
    if lane_index >= 0 and lane_index < lanes.size():
        return lanes[lane_index]
    return 0

static func _perpendicular_dir(main_dir: Vector2) -> Vector2:
    if main_dir == Vector2.RIGHT or main_dir == Vector2.LEFT:
        return Vector2.UP
    return Vector2.RIGHT

static func _branch_for_key(key: String) -> int:
    var theme_act: int = _theme_act_for_key(key)
    match theme_act:
        THEME_HERO_UNLOCK_ACT:
            return 0
        THEME_DAMAGE_ACT:
            return 0
        THEME_UTILITY_ECON_ACT:
            return 3
        THEME_DEFENSE_SURVIVAL_ACT:
            return 2
        THEME_POWER_ACTIVE_ACT:
            return 1
        THEME_BOSS_DENSITY_ACT:
            return 3
        THEME_MISC_TEAM_ACT:
            return 2

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
