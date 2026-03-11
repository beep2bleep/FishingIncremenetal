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
static var _cached_json_data: Dictionary = {}

static func apply_simulation_upgrades() -> void:
    var json_variant: Variant = _get_cached_json_data()
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
    _sanitize_dependency_graph(grouped_upgrades)
    _enforce_branch_anchors(grouped_upgrades)
    _enforce_tier_chain_order(grouped_upgrades)
    _sanitize_dependency_graph(grouped_upgrades)
    if OS.has_feature("editor"):
        _validate_dependencies_reach_center(grouped_upgrades)
    var id_to_cell: Dictionary = _build_tree_layout(grouped_upgrades)
    var formatter: FishingUpgradeDB = FishingUpgradeDB.new(json_data)

    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var demo_mode_enabled: bool = _is_demo_mode_enabled()
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
        if demo_mode_enabled and _is_demo_locked_for_display_name(upgrade.sim_name):
            upgrade.demo_locked = 1

        var dep_variant: Variant = entry.get("dependency", null)
        if dep_variant != null:
            var dep_id: String = str(dep_variant)
            if dep_id == "__CENTER__":
                upgrade.forced_cell = Vector2.ZERO
            elif dep_id != "" and id_to_cell.has(dep_id):
                upgrade.forced_cell = id_to_cell[dep_id]

        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = SaveHandler.get_fishing_upgrade_level(upgrade.sim_key)
        if upgrade.demo_locked == 1:
            owned_level = min(owned_level, upgrade.sim_level - 1)
        if owned_level >= upgrade.sim_level:
            var unlocked_tiers: int = clamp(owned_level - upgrade.sim_level + 1, 0, upgrade.max_tier)
            upgrade.current_tier = unlocked_tiers
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _is_demo_mode_enabled() -> bool:
    return bool(ProjectSettings.get_setting("global/Demo", false))

static func _is_demo_locked_for_display_name(display_name: String) -> bool:
    var words: PackedStringArray = display_name.strip_edges().split(" ", false)
    if words.is_empty():
        return false
    return _roman_to_int(words[words.size() - 1]) >= 3

static func _roman_to_int(value: String) -> int:
    match value.strip_edges().to_upper():
        "I":
            return 1
        "II":
            return 2
        "III":
            return 3
        "IV":
            return 4
        "V":
            return 5
        "VI":
            return 6
        "VII":
            return 7
        "VIII":
            return 8
        "IX":
            return 9
        "X":
            return 10
        _:
            return 0

static func clear_cached_json_data() -> void:
    _cached_json_data = {}

static func _get_cached_json_data() -> Dictionary:
    if _cached_json_data.is_empty():
        var loaded: Variant = FishingUpgradeDB.get_cached_data()
        if loaded is Dictionary:
            _cached_json_data = loaded
    return _cached_json_data

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
        var chunk_limit: int = GROUPED_TIER_MAX
        if _should_keep_key_as_single_root_node(key):
            chunk_limit = key_entries.size()
        while cursor < key_entries.size():
            var first: Dictionary = key_entries[cursor]
            var chunk_size: int = min(chunk_limit, key_entries.size() - cursor)
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

static func _should_keep_key_as_single_root_node(key: String) -> bool:
    match key:
        "battle_speed_unlock_2x", "core_armor":
            return true
        _:
            return false

static func _party_parent_key(key: String) -> String:
    match key:
        "party_damage_boost":
            return ""
        "party_battle_standard":
            return "party_damage_boost"
        "party_war_drums":
            return "party_battle_standard"
        "party_execution_doctrine":
            return "party_war_drums"
        "party_apex_overdrive":
            return "party_execution_doctrine"
        _:
            return ""

static func _group_number_from_id(entry_id: String) -> int:
    var idx: int = entry_id.find("__G")
    if idx < 0:
        return 0
    return int(entry_id.substr(idx + 3)) if entry_id.length() > idx + 3 else 0

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

    # Sort each key's entries by group number so G1, G2, G3... are in order (escalating chains).
    for k in key_to_entries:
        var arr: Array = key_to_entries[k]
        arr.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
            return _group_number_from_id(str(a.get("id", ""))) < _group_number_from_id(str(b.get("id", "")))
        )

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        var entry_id: String = str(entry.get("id", ""))
        if key == "" or entry_id == "":
            continue

        var entries_for_key: Array = key_to_entries.get(key, [])
        var chain_index: int = -1
        for j in range(entries_for_key.size()):
            if str(entries_for_key[j].get("id", "")) == entry_id:
                chain_index = j
                break

        # Escalating upgrades (multiple groups for same key): each group depends on the previous group.
        if chain_index > 0:
            var prev_id: String = str(entries_for_key[chain_index - 1].get("id", ""))
            entry["dependency"] = prev_id
        else:
            # Armor tracks 2–5: L1 depends on previous track's last node (I → II → III → IV → V).
            var armor_dep: String = _armor_track_dependency(key, key_to_entries)
            if armor_dep != "":
                entry["dependency"] = armor_dep
            else:
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

# For armor track keys (core_armor_enemy_N, core_armor_dot_N, core_armor_boss_N) with N >= 2,
# returns the previous track's last grouped node id so track order is I -> II -> III -> IV -> V.
static func _armor_track_dependency(key: String, key_to_entries: Dictionary) -> String:
    var lower: String = key.to_lower()
    var prefix: String = ""
    var track: int = 0
    if lower.begins_with("core_armor_enemy_"):
        prefix = "core_armor_enemy_"
    elif lower.begins_with("core_armor_dot_"):
        prefix = "core_armor_dot_"
    elif lower.begins_with("core_armor_boss_"):
        prefix = "core_armor_boss_"
    else:
        return ""
    track = int(lower.trim_prefix(prefix)) if lower.length() > prefix.length() else 0
    if track <= 1:
        return ""
    var prev_key: String = "%s%d" % [prefix, track - 1]
    var prev_entries: Array = key_to_entries.get(prev_key, [])
    if prev_entries.is_empty():
        return ""
    prev_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return _group_number_from_id(str(a.get("id", ""))) < _group_number_from_id(str(b.get("id", "")))
    )
    return str(prev_entries[prev_entries.size() - 1].get("id", ""))

static func _select_hub_dependency_key(key: String, key_to_primary_id: Dictionary) -> String:
    var lower: String = key.to_lower()
    var hero: String = _hero_from_key(lower)
    var recruit_key_for_hero: String = "recruit_%s" % hero if hero != "" else ""
    var party_parent_key: String = _party_parent_key(lower)

    if lower == "battle_speed_unlock_4x":
        if key_to_primary_id.has("battle_speed_unlock_2x"):
            return "battle_speed_unlock_2x"
        return ""
    if lower == "battle_speed_unlock_8x":
        if key_to_primary_id.has("battle_speed_unlock_4x"):
            return "battle_speed_unlock_4x"
        return ""
    if lower == "old_art_unlock":
        if key_to_primary_id.has("battle_speed_unlock_4x"):
            return "battle_speed_unlock_4x"
        return ""

    if party_parent_key != "":
        if key_to_primary_id.has(party_parent_key):
            return party_parent_key
        return ""

    if lower == "cursor_pickup_unlock" \
    or lower == "knight_vamp_unlock" \
    or lower == "auto_attack_unlock" \
    or lower == "battle_speed_unlock_2x" \
    or lower == "core_armor" \
    or lower == "party_damage_boost" \
    or lower == "vitality_foundation" \
    or lower.begins_with("recruit_"):
        return ""

    if lower == "vitality_hitpoints" or lower == "vitality_power" or lower == "vitality_channel":
        if key_to_primary_id.has("vitality_foundation"):
            return "vitality_foundation"
        return ""

    if lower.begins_with("extra_skill_"):
        return _extra_skill_dependency_key(lower, key_to_primary_id)

    if lower.begins_with("core_armor_") and key_to_primary_id.has("core_armor"):
        return "core_armor"

    if lower.begins_with("core_"):
        if lower == "core_drop" and key_to_primary_id.has("cursor_pickup_unlock"):
            return "cursor_pickup_unlock"
        if (lower == "core_density" or lower == "core_power") and key_to_primary_id.has("auto_attack_unlock"):
            return "auto_attack_unlock"
        var active_key: String = _hero_unlock_key(hero)
        if active_key != "" and key_to_primary_id.has(active_key):
            return active_key
        if hero != "" and recruit_key_for_hero != "" and key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        return ""

    if lower.ends_with("_unlock"):
        if lower == "power_harvest_unlock" and key_to_primary_id.has("auto_attack_unlock"):
            return "auto_attack_unlock"
        if hero != "" and recruit_key_for_hero != "" and key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        return ""

    if lower == "impact_weave":
        if key_to_primary_id.has("knight_vamp_unlock"):
            return "knight_vamp_unlock"
        return ""

    if lower == "line_pressure_1":
        if key_to_primary_id.has("recruit_guardian"):
            return "recruit_guardian"
        return ""

    if lower == "focused_breathing_60":
        if key_to_primary_id.has("auto_attack_unlock"):
            return "auto_attack_unlock"
        return ""

    if hero != "":
        if hero == "knight" and key_to_primary_id.has("knight_vamp_unlock"):
            return "knight_vamp_unlock"
        if key_to_primary_id.has(recruit_key_for_hero):
            return recruit_key_for_hero
        return ""

    if _is_enemy_pressure_key(lower):
        if key_to_primary_id.has("core_density"):
            return "core_density"
        if key_to_primary_id.has("auto_attack_unlock"):
            return "auto_attack_unlock"
        return ""

    if _is_power_generation_key(lower):
        if key_to_primary_id.has("core_power"):
            return "core_power"
        if key_to_primary_id.has("power_harvest_unlock"):
            return "power_harvest_unlock"
        if key_to_primary_id.has("auto_attack_unlock"):
            return "auto_attack_unlock"
        return ""

    if _is_global_mitigation_key(lower):
        if key_to_primary_id.has("core_armor"):
            return "core_armor"
        return ""

    if lower == "trail_boots":
        if key_to_primary_id.has("cursor_pickup_unlock"):
            return "cursor_pickup_unlock"
        return ""

    if _is_movement_key(lower):
        if key_to_primary_id.has("trail_boots"):
            return "trail_boots"
        if key_to_primary_id.has("cursor_pickup_unlock"):
            return "cursor_pickup_unlock"
        return ""

    if _is_cursor_coin_key(lower):
        if key_to_primary_id.has("core_drop"):
            return "core_drop"
        if key_to_primary_id.has("cursor_pickup_unlock"):
            return "cursor_pickup_unlock"
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
            if key_to_primary_id.has("party_damage_boost"):
                return "party_damage_boost"
    return ""

static func _extra_skill_dependency_key(lower_key: String, key_to_primary_id: Dictionary) -> String:
    var n: int = _extra_skill_index(lower_key)
    if n <= 0:
        if key_to_primary_id.has("party_damage_boost"):
            return "party_damage_boost"
        return ""
    var family_index: int = (n - 1) % EXTRA_SKILL_THEME_CYCLE.size()
    match family_index:
        0: # ECON
            if key_to_primary_id.has("core_drop"):
                return "core_drop"
            if key_to_primary_id.has("cursor_pickup_unlock"):
                return "cursor_pickup_unlock"
        1: # DENS
            if key_to_primary_id.has("core_density"):
                return "core_density"
            if key_to_primary_id.has("auto_attack_unlock"):
                return "auto_attack_unlock"
        2: # SURV
            if key_to_primary_id.has("core_armor"):
                return "core_armor"
        3: # MOVE
            if key_to_primary_id.has("cursor_pickup_unlock"):
                return "cursor_pickup_unlock"
        4: # POWR
            if key_to_primary_id.has("core_power"):
                return "core_power"
            if key_to_primary_id.has("auto_attack_unlock"):
                return "auto_attack_unlock"
        5: # ACTV
            if key_to_primary_id.has("core_power"):
                return "core_power"
            if key_to_primary_id.has("auto_attack_unlock"):
                return "auto_attack_unlock"
        6: # BOSS
            if key_to_primary_id.has("core_density"):
                return "core_density"
            if key_to_primary_id.has("auto_attack_unlock"):
                return "auto_attack_unlock"
        7: # TEAM
            if key_to_primary_id.has("party_damage_boost"):
                return "party_damage_boost"
    if key_to_primary_id.has("party_damage_boost"):
        return "party_damage_boost"
    return ""

static func _extra_skill_index(lower_key: String) -> int:
    if not lower_key.begins_with("extra_skill_"):
        return -1
    return int(lower_key.trim_prefix("extra_skill_"))

static func _is_cursor_coin_key(lower_key: String) -> bool:
    return lower_key.find("cursor") >= 0 \
    or lower_key.find("pickup") >= 0 \
    or lower_key.find("coin") >= 0 \
    or lower_key.find("drop") >= 0 \
    or lower_key.find("salvage") >= 0 \
    or lower_key.find("magnet") >= 0 \
    or lower_key.find("lens") >= 0 \
    or lower_key.find("collector") >= 0 \
    or lower_key.find("broker") >= 0 \
    or lower_key.find("market") >= 0 \
    or lower_key.find("yield") >= 0

static func _is_movement_key(lower_key: String) -> bool:
    return lower_key.find("move") >= 0 \
    or lower_key.find("trail") >= 0 \
    or lower_key.find("stride") >= 0 \
    or lower_key.find("route") >= 0 \
    or lower_key.find("pathline") >= 0 \
    or lower_key.find("quickstep") >= 0 \
    or lower_key.find("momentum") >= 0 \
    or lower_key.find("march") >= 0 \
    or lower_key.find("sprint") >= 0

static func _is_power_generation_key(lower_key: String) -> bool:
    return lower_key.find("power") >= 0 \
    or lower_key.find("reservoir") >= 0 \
    or lower_key.find("condensed") >= 0 \
    or lower_key.find("echo") >= 0 \
    or lower_key.find("overclock") >= 0 \
    or lower_key.find("overflow") >= 0 \
    or lower_key.find("invocation") >= 0 \
    or lower_key.find("channel") >= 0 \
    or lower_key.find("cadence") >= 0

static func _is_enemy_pressure_key(lower_key: String) -> bool:
    return lower_key.find("enemy") >= 0 \
    or lower_key.find("horde") >= 0 \
    or lower_key.find("density") >= 0 \
    or lower_key.find("wave") >= 0 \
    or lower_key.find("crowd") >= 0 \
    or lower_key.find("pressure") >= 0 \
    or lower_key.find("taxonomy") >= 0

static func _is_global_mitigation_key(lower_key: String) -> bool:
    if lower_key.find("guardian") >= 0:
        return false
    return lower_key.find("armor") >= 0 \
    or lower_key.find("plate") >= 0 \
    or lower_key.find("carapace") >= 0 \
    or lower_key.find("shock") >= 0 \
    or lower_key.find("deflector") >= 0 \
    or lower_key.find("hemostasis") >= 0 \
    or lower_key.find("front_compression") >= 0 \
    or lower_key.find("dot") >= 0

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

static func _enforce_branch_anchors(grouped_upgrades: Array) -> void:
    var key_to_primary_id: Dictionary = {}
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

    for i in range(grouped_upgrades.size()):
        var entry_variant: Variant = grouped_upgrades[i]
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        var entry_id: String = str(entry.get("id", ""))
        if key == "" or entry_id == "":
            continue
        if str(key_to_primary_id.get(key, "")) != entry_id:
            continue

        var forced_dep: String = ""
        match key:
            "battle_speed_unlock_2x":
                forced_dep = str(key_to_primary_id.get("auto_attack_unlock", ""))
            "battle_speed_unlock_4x":
                forced_dep = str(key_to_primary_id.get("battle_speed_unlock_2x", ""))
            "battle_speed_unlock_8x":
                forced_dep = str(key_to_primary_id.get("battle_speed_unlock_4x", ""))
            "old_art_unlock":
                forced_dep = str(key_to_primary_id.get("battle_speed_unlock_4x", ""))
            "party_damage_boost":
                forced_dep = "__CENTER__"
            "party_battle_standard":
                forced_dep = str(key_to_primary_id.get("party_damage_boost", ""))
            "party_war_drums":
                forced_dep = str(key_to_primary_id.get("party_battle_standard", ""))
            "party_execution_doctrine":
                forced_dep = str(key_to_primary_id.get("party_war_drums", ""))
            "party_apex_overdrive":
                forced_dep = str(key_to_primary_id.get("party_execution_doctrine", ""))
            "core_knight_damage", "core_knight_speed":
                forced_dep = str(key_to_primary_id.get("knight_vamp_unlock", ""))
            "core_guardian_damage", "core_guardian_speed":
                forced_dep = str(key_to_primary_id.get("guardian_fortify_unlock", ""))
            "core_archer_damage", "core_archer_speed":
                forced_dep = str(key_to_primary_id.get("archer_pierce_unlock", ""))
            "core_mage_damage", "core_mage_speed":
                forced_dep = str(key_to_primary_id.get("mage_storm_unlock", ""))
            "core_drop", "trail_boots":
                forced_dep = str(key_to_primary_id.get("cursor_pickup_unlock", ""))
            "core_density", "core_power", "power_harvest_unlock", "focused_breathing_60":
                forced_dep = str(key_to_primary_id.get("auto_attack_unlock", ""))
            "core_armor":
                forced_dep = "__CENTER__"
            "vitality_foundation":
                forced_dep = "__CENTER__"
            "vitality_hitpoints", "vitality_power", "vitality_channel":
                forced_dep = str(key_to_primary_id.get("vitality_foundation", ""))

        if forced_dep == "":
            continue
        entry["dependency"] = forced_dep
        grouped_upgrades[i] = entry

## Ensures tier N+1 is always a direct child of tier N (e.g. Vitality Channel II depends on Vitality Channel I).
static func _enforce_tier_chain_order(grouped_upgrades: Array) -> void:
    var key_to_entries: Dictionary = {}
    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var key: String = str(entry.get("key", ""))
        var entry_id: String = str(entry.get("id", ""))
        if key == "" or entry_id == "":
            continue
        if not key_to_entries.has(key):
            key_to_entries[key] = []
        var arr: Array = key_to_entries[key]
        arr.append(entry)
        key_to_entries[key] = arr

    for key in key_to_entries:
        var entries: Array = key_to_entries[key]
        if entries.size() <= 1:
            continue
        entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
            return _group_number_from_id(str(a.get("id", ""))) < _group_number_from_id(str(b.get("id", "")))
        )
        for i in range(1, entries.size()):
            var prev_id: String = str(entries[i - 1].get("id", ""))
            var cur_entry: Dictionary = entries[i]
            if prev_id == "":
                continue
            cur_entry["dependency"] = prev_id

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
        if dep_id == "__CENTER__":
            continue
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

static func _is_armor_track_key(key: String) -> bool:
    var lower: String = key.to_lower()
    return lower.begins_with("core_armor_enemy_") or lower.begins_with("core_armor_dot_") or lower.begins_with("core_armor_boss_")

static func _is_armor_track_chain(parent_id: String, chain: Array, id_to_entry: Dictionary) -> bool:
    var parent_entry: Dictionary = id_to_entry.get(parent_id, {})
    if parent_entry.is_empty() or not _is_armor_track_key(str(parent_entry.get("key", ""))):
        return false
    for node_id_variant in chain:
        var node_entry: Dictionary = id_to_entry.get(str(node_id_variant), {})
        if node_entry.is_empty() or not _is_armor_track_key(str(node_entry.get("key", ""))):
            return false
    return true

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

        # Keep armor tracks as a direct chain I -> II -> III -> IV -> V; do not flatten.
        if _is_armor_track_chain(parent_id, chain, id_to_entry):
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
                cell = _find_layout_cell_for_child(parent_cell, branch, child_index, used_cells)
            else:
                var branch_count: int = int(root_counts.get(branch, 0))
                root_counts[branch] = branch_count + 1
                cell = _find_layout_cell_for_root(branch, branch_count, used_cells, key)

            id_to_cell[upgrade_id] = cell
            used_cells[cell] = true
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

static func _find_layout_cell_for_child(parent_cell: Vector2, preferred_branch: int, child_index: int, used_cells: Dictionary) -> Vector2:
    var preferred_dir: Vector2 = LAYOUT_DIRS[preferred_branch]
    var main_dir: Vector2 = _outward_dir_for_parent(parent_cell, preferred_dir)
    var perp: Vector2 = _perpendicular_dir(main_dir)
    # Fan children around the forward direction while still progressing outward.
    var lane_order: Array[int] = [0, 1, -1, 2, -2, 3, -3]
    var lane_rotation: int = int(abs(child_index)) % lane_order.size()
    for step in range(1, 96):
        for i in range(lane_order.size()):
            var lane: int = lane_order[(i + lane_rotation) % lane_order.size()]
            var candidate: Vector2 = parent_cell + (main_dir * step) + (perp * lane)
            if used_cells.has(candidate):
                continue
            if not _is_child_direction_allowed(parent_cell, candidate, main_dir):
                continue
            if not _is_child_distance_allowed(parent_cell, candidate):
                continue
            return candidate
    return _find_free_layout_cell_cardinal(parent_cell + (main_dir * 2), main_dir, used_cells)

static func _find_layout_cell_for_root(branch: int, branch_count: int, used_cells: Dictionary, key: String = "") -> Vector2:
    var dir: Vector2 = LAYOUT_DIRS[branch]
    var target: Vector2 = _compute_root_target(dir, branch_count)
    # Root branches brought in by 3 from previous positions.
    var fixed_root_targets := {
        "knight_vamp_unlock": Vector2(0, -3),
        "recruit_archer": Vector2(3, -2),
        "cursor_pickup_unlock": Vector2(3, 2),
        "auto_attack_unlock": Vector2(0, 3),
        "core_armor": Vector2(-3, 4),
        "party_damage_boost": Vector2(-4, 0),
        "recruit_guardian": Vector2(-3, 0),
        "recruit_mage": Vector2(-2, -3),
        "battle_speed_unlock_2x": Vector2(2, -3),
        "old_art_unlock": Vector2(6, -5),
        "vitality_foundation": Vector2(-3, 2),
    }
    if fixed_root_targets.has(key):
        target = fixed_root_targets[key]
        dir = target.normalized().round()
    var candidates: Array[Vector2] = _candidate_cells_cardinal(target, dir, 24)
    for candidate_variant: Variant in candidates:
        var candidate: Vector2 = candidate_variant
        if used_cells.has(candidate):
            continue
        return candidate
    return _find_free_layout_cell_cardinal(target, dir, used_cells)

static func _candidate_cells_cardinal(target: Vector2, dir: Vector2, max_step: int) -> Array[Vector2]:
    var out: Array[Vector2] = []
    out.append(target)
    # Favor moving farther away from center before trying inward fallback.
    for step in range(1, max_step + 1):
        out.append(target + dir * step)
    for step in range(1, max_step + 1):
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

static func _validate_dependencies_reach_center(grouped_upgrades: Array) -> void:
    var id_to_dep: Dictionary = {}
    for entry_variant: Variant in grouped_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var entry_id: String = str(entry.get("id", ""))
        if entry_id == "":
            continue
        id_to_dep[entry_id] = str(entry.get("dependency", ""))

    var unreachable: Array[String] = []
    for id_variant: Variant in id_to_dep.keys():
        var start_id: String = str(id_variant)
        var current: String = start_id
        var seen: Dictionary = {}
        var reached_center: bool = false
        var safety: int = 0
        while safety < 10000:
            safety += 1
            var dep_id: String = str(id_to_dep.get(current, ""))
            if dep_id == "__CENTER__":
                reached_center = true
                break
            if dep_id == "":
                break
            if seen.has(dep_id):
                break
            seen[dep_id] = true
            if not id_to_dep.has(dep_id):
                break
            current = dep_id
        if not reached_center:
            unreachable.append(start_id)

    if unreachable.is_empty():
        return

    var sample: Array[String] = unreachable.slice(0, min(10, unreachable.size()))
    push_error("FishingUpgradeTreeAdapter validation failed: dependencies not connected to __CENTER__. Count=%d Sample=%s" % [unreachable.size(), sample])
    assert(false, "Dependency graph validation failed in editor.")

static func _branch_order_for_child(preferred_branch: int, index_seed: int) -> Array[int]:
    var p: int = ((preferred_branch % LAYOUT_DIRS.size()) + LAYOUT_DIRS.size()) % LAYOUT_DIRS.size()
    # Allow forward + side branches only; never include direct opposite direction.
    var base: Array[int] = [
        p,
        (p + 1) % LAYOUT_DIRS.size(),
        (p + 3) % LAYOUT_DIRS.size(),
    ]
    var rotation: int = 0
    if base.size() > 0:
        rotation = int(abs(index_seed)) % base.size()
    var ordered: Array[int] = []
    for i in range(base.size()):
        ordered.append(base[(i + rotation) % base.size()])
    return ordered

static func _is_child_direction_allowed(parent_cell: Vector2, child_cell: Vector2, main_dir: Vector2) -> bool:
    var delta: Vector2 = child_cell - parent_cell
    return delta.dot(main_dir) > 0.0

static func _is_child_distance_allowed(parent_cell: Vector2, child_cell: Vector2) -> bool:
    var parent_dist: int = abs(int(parent_cell.x)) + abs(int(parent_cell.y))
    var child_dist: int = abs(int(child_cell.x)) + abs(int(child_cell.y))
    if child_dist < parent_dist:
        return false
    return child_cell.length_squared() >= parent_cell.length_squared()

static func _outward_dir_for_parent(parent_cell: Vector2, fallback_dir: Vector2) -> Vector2:
    if parent_cell == Vector2.ZERO:
        return fallback_dir

    var ax: float = abs(parent_cell.x)
    var ay: float = abs(parent_cell.y)
    if ax > ay:
        return Vector2(sign(parent_cell.x), 0.0)
    if ay > ax:
        return Vector2(0.0, sign(parent_cell.y))

    # Tie-breaker for diagonals: keep consistency with branch preference.
    if fallback_dir == Vector2.RIGHT or fallback_dir == Vector2.LEFT:
        return Vector2(sign(parent_cell.x), 0.0)
    return Vector2(0.0, sign(parent_cell.y))

static func _compute_root_target(main_dir: Vector2, branch_count: int) -> Vector2:
    # Keep first-hop branches well separated near center to avoid crossing lines. (Brought in by 3 from center.)
    var lane_pattern: Array[int] = [0, 4, -4, 8, -8, 12, -12]
    var lane: int = lane_pattern[branch_count % lane_pattern.size()]
    var ring: int = int(branch_count / lane_pattern.size())
    var forward: int = 3 + ring * 4
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

    if lower == "vitality_foundation" or lower == "vitality_hitpoints":
        return THEME_DEFENSE_SURVIVAL_ACT
    if lower == "vitality_power" or lower == "vitality_channel":
        return THEME_POWER_ACTIVE_ACT

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
        return raw_icon
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
