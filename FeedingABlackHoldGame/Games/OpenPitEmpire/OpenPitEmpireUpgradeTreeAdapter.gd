extends RefCounted
class_name OpenPitEmpireUpgradeTreeAdapter

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")

const BRANCH_REWARDS_PROXY := 1
const BRANCH_REWARDS_CIPHER := 2
const BRANCH_REWARDS_GHOST := 3
const BRANCH_REWARDS_KERNEL := 4
const BRANCH_CASH_PATH := 5
const BRANCH_SURVIVAL := 8
const BRANCH_XP_PATH := 9
const BRANCH_CORE_PATH := 10

const ACT_REWARD := 1
const ACT_OFFENSE := 2
const ACT_LOGISTICS := 3
const ACT_SYSTEMS := 4
const ACT_SURVIVAL := 5

const BRANCH_THEME_BY_ID := {
    "core:clear_proxy_25": {"group": BRANCH_REWARDS_PROXY, "pos": 1, "act": ACT_REWARD},
    "core:clear_proxy_50": {"group": BRANCH_REWARDS_PROXY, "pos": 2, "act": ACT_REWARD},
    "core:clear_proxy_75": {"group": BRANCH_REWARDS_PROXY, "pos": 3, "act": ACT_REWARD},
    "core:clear_cipher_25": {"group": BRANCH_REWARDS_CIPHER, "pos": 1, "act": ACT_REWARD},
    "core:clear_cipher_50": {"group": BRANCH_REWARDS_CIPHER, "pos": 2, "act": ACT_REWARD},
    "core:clear_cipher_75": {"group": BRANCH_REWARDS_CIPHER, "pos": 3, "act": ACT_REWARD},
    "core:clear_ghost_25": {"group": BRANCH_REWARDS_GHOST, "pos": 1, "act": ACT_REWARD},
    "core:clear_ghost_50": {"group": BRANCH_REWARDS_GHOST, "pos": 2, "act": ACT_REWARD},
    "core:clear_ghost_75": {"group": BRANCH_REWARDS_GHOST, "pos": 3, "act": ACT_REWARD},
    "core:clear_kernel_25": {"group": BRANCH_REWARDS_KERNEL, "pos": 1, "act": ACT_REWARD},
    "core:clear_kernel_50": {"group": BRANCH_REWARDS_KERNEL, "pos": 2, "act": ACT_REWARD},
    "core:clear_kernel_75": {"group": BRANCH_REWARDS_KERNEL, "pos": 3, "act": ACT_REWARD},
    "laser_cutter": {"group": BRANCH_CASH_PATH, "pos": 1, "act": ACT_LOGISTICS},
    "cargo_racks": {"group": BRANCH_CASH_PATH, "pos": 2, "act": ACT_LOGISTICS},
    "fuel_cells": {"group": BRANCH_CASH_PATH, "pos": 3, "act": ACT_LOGISTICS},
    "minimap": {"group": BRANCH_CASH_PATH, "pos": 4, "act": ACT_LOGISTICS},
    "rapid_cycle": {"group": BRANCH_CASH_PATH, "pos": 5, "act": ACT_LOGISTICS},
    "ore_appraisal": {"group": BRANCH_CASH_PATH, "pos": 6, "act": ACT_LOGISTICS},
    "barrier_mesh": {"group": BRANCH_CASH_PATH, "pos": 7, "act": ACT_LOGISTICS},
    "shock_bits": {"group": BRANCH_CASH_PATH, "pos": 8, "act": ACT_LOGISTICS},
    "breach_drones": {"group": BRANCH_CASH_PATH, "pos": 9, "act": ACT_LOGISTICS},
    "salvage_contract": {"group": BRANCH_CASH_PATH, "pos": 10, "act": ACT_LOGISTICS},
    "funnel_resonance": {"group": BRANCH_CASH_PATH, "pos": 11, "act": ACT_LOGISTICS},
    "daemon_lances": {"group": BRANCH_CASH_PATH, "pos": 12, "act": ACT_LOGISTICS},
    "root_breaker": {"group": BRANCH_CASH_PATH, "pos": 13, "act": ACT_LOGISTICS},
    "overburn_reactors": {"group": BRANCH_CASH_PATH, "pos": 14, "act": ACT_LOGISTICS},
    "seismic_lattice": {"group": BRANCH_CASH_PATH, "pos": 15, "act": ACT_LOGISTICS},
    "auto_salvage": {"group": BRANCH_CASH_PATH, "pos": 16, "act": ACT_LOGISTICS},
    "mantle_drills": {"group": BRANCH_CASH_PATH, "pos": 17, "act": ACT_LOGISTICS},
    "fault_charges": {"group": BRANCH_CASH_PATH, "pos": 18, "act": ACT_LOGISTICS},
    "void_cutters": {"group": BRANCH_CASH_PATH, "pos": 19, "act": ACT_LOGISTICS},
    "inversion_drives": {"group": BRANCH_CASH_PATH, "pos": 20, "act": ACT_LOGISTICS},
    "vault_pulsers": {"group": BRANCH_CASH_PATH, "pos": 21, "act": ACT_LOGISTICS},
    "gravity_wells": {"group": BRANCH_CASH_PATH, "pos": 22, "act": ACT_LOGISTICS},
    "abyssal_rigs": {"group": BRANCH_CASH_PATH, "pos": 23, "act": ACT_LOGISTICS},
    "mirror_saws": {"group": BRANCH_CASH_PATH, "pos": 24, "act": ACT_LOGISTICS},
    "fault_harpoons": {"group": BRANCH_CASH_PATH, "pos": 25, "act": ACT_LOGISTICS},
    "null_borers": {"group": BRANCH_CASH_PATH, "pos": 26, "act": ACT_LOGISTICS},
    "ash_crowns": {"group": BRANCH_CASH_PATH, "pos": 27, "act": ACT_LOGISTICS},
    "xp:packet_sniffer": {"group": BRANCH_XP_PATH, "pos": 1, "act": ACT_SYSTEMS},
    "xp:trace_scrubber": {"group": BRANCH_XP_PATH, "pos": 2, "act": ACT_SYSTEMS},
    "xp:heap_climber": {"group": BRANCH_XP_PATH, "pos": 3, "act": ACT_SYSTEMS},
    "xp:cache_warmers": {"group": BRANCH_XP_PATH, "pos": 4, "act": ACT_SYSTEMS},
    "xp:deep_scan": {"group": BRANCH_XP_PATH, "pos": 5, "act": ACT_SYSTEMS},
    "xp:sidechannel": {"group": BRANCH_XP_PATH, "pos": 6, "act": ACT_SYSTEMS},
    "xp:zero_day": {"group": BRANCH_XP_PATH, "pos": 7, "act": ACT_SYSTEMS},
    "xp:crash_cartography": {"group": BRANCH_XP_PATH, "pos": 8, "act": ACT_SYSTEMS},
    "xp:kernel_rehearsal": {"group": BRANCH_XP_PATH, "pos": 9, "act": ACT_SYSTEMS},
    "xp:deep_manifest": {"group": BRANCH_XP_PATH, "pos": 10, "act": ACT_SYSTEMS},
    "xp:thermal_mapping": {"group": BRANCH_XP_PATH, "pos": 11, "act": ACT_SYSTEMS},
    "xp:vault_heuristics": {"group": BRANCH_XP_PATH, "pos": 12, "act": ACT_SYSTEMS},
    "xp:graveyard_index": {"group": BRANCH_XP_PATH, "pos": 13, "act": ACT_SYSTEMS},
    "xp:mirror_daemons": {"group": BRANCH_XP_PATH, "pos": 14, "act": ACT_SYSTEMS},
    "xp:inversion_ledger": {"group": BRANCH_XP_PATH, "pos": 15, "act": ACT_SYSTEMS},
    "xp:fault_oracles": {"group": BRANCH_XP_PATH, "pos": 16, "act": ACT_SYSTEMS},
    "xp:null_archive": {"group": BRANCH_XP_PATH, "pos": 17, "act": ACT_SYSTEMS},
    "xp:ash_scriptures": {"group": BRANCH_XP_PATH, "pos": 18, "act": ACT_SYSTEMS},
    "core:core_detect": {"group": BRANCH_CORE_PATH, "pos": 1, "act": ACT_SURVIVAL},
    "core:spawn_direction": {"group": BRANCH_CORE_PATH, "pos": 2, "act": ACT_SURVIVAL},
    "core:brake": {"group": BRANCH_CORE_PATH, "pos": 3, "act": ACT_SURVIVAL},
    "core:barrier_regen": {"group": BRANCH_CORE_PATH, "pos": 4, "act": ACT_SURVIVAL},
    "core:return_shortcut": {"group": BRANCH_CORE_PATH, "pos": 5, "act": ACT_SURVIVAL},
    "core:emergency_return": {"group": BRANCH_CORE_PATH, "pos": 6, "act": ACT_SURVIVAL},
    "core:core_focus": {"group": BRANCH_CORE_PATH, "pos": 7, "act": ACT_SURVIVAL},
    "core:countermeasure_bridge": {"group": BRANCH_CORE_PATH, "pos": 8, "act": ACT_SURVIVAL},
    "core:kernel_breach": {"group": BRANCH_CORE_PATH, "pos": 9, "act": ACT_SURVIVAL},
    "core:core_stasis": {"group": BRANCH_CORE_PATH, "pos": 10, "act": ACT_SURVIVAL},
    "core:center_unlock": {"group": BRANCH_CORE_PATH, "pos": 11, "act": ACT_SURVIVAL},
    "core:core_siphon": {"group": BRANCH_CORE_PATH, "pos": 12, "act": ACT_SURVIVAL},
    "core:salvage_limiter": {"group": BRANCH_CORE_PATH, "pos": 13, "act": ACT_SURVIVAL},
    "core:mantle_permits": {"group": BRANCH_CORE_PATH, "pos": 14, "act": ACT_SURVIVAL},
    "core:inversion_tether": {"group": BRANCH_CORE_PATH, "pos": 15, "act": ACT_SURVIVAL},
    "core:voidfire_brakes": {"group": BRANCH_CORE_PATH, "pos": 16, "act": ACT_SURVIVAL},
    "core:mirror_keys": {"group": BRANCH_CORE_PATH, "pos": 17, "act": ACT_SURVIVAL},
    "core:fault_insulation": {"group": BRANCH_CORE_PATH, "pos": 18, "act": ACT_SURVIVAL},
    "core:null_anchor": {"group": BRANCH_CORE_PATH, "pos": 19, "act": ACT_SURVIVAL},
    "core:ash_ward": {"group": BRANCH_CORE_PATH, "pos": 20, "act": ACT_SURVIVAL},
    "core:autopilot_drone": {"group": BRANCH_CORE_PATH, "pos": 21, "act": ACT_SURVIVAL},
    "core:planet_mastery": {"group": BRANCH_CORE_PATH, "pos": 22, "act": ACT_SURVIVAL},
}

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var saved_upgrades: Dictionary = PROGRESS.load_data().get("upgrades", {})
    saved_upgrades.merge(PROGRESS.get_xp_upgrade_levels(), true)
    saved_upgrades.merge(PROGRESS.get_core_upgrade_levels(), true)
    var best_layer_clear_percents: Dictionary = PROGRESS.get_best_layer_clear_percents()
    var next_id := 0
    for entry in BALANCE.get_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id, best_layer_clear_percents)
        next_id += 1
    for entry in BALANCE.get_xp_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id, best_layer_clear_percents)
        next_id += 1
    for entry in BALANCE.get_core_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id, best_layer_clear_percents)
        next_id += 1

static func _append_upgrade(entry: Dictionary, saved_levels: Dictionary, next_id: int, best_layer_clear_percents: Dictionary) -> void:
    var upgrade := Upgrade.new()
    var upgrade_id: String = str(entry.get("id", ""))
    if upgrade_id.is_empty():
        return
    upgrade.id = next_id
    if BALANCE.is_core_upgrade(upgrade_id):
        upgrade.cell = BALANCE.get_core_upgrade_cell(upgrade_id)
    elif BALANCE.is_xp_upgrade(upgrade_id):
        upgrade.cell = BALANCE.get_xp_upgrade_cell(upgrade_id)
    else:
        upgrade.cell = BALANCE.get_upgrade_cell(upgrade_id)
    upgrade.mod = _mod_for_upgrade(upgrade_id)
    upgrade.value = 0.0
    upgrade.max_tier = int(entry.get("max_level", 1))
    upgrade.base_cost = int(entry.get("base_cost", 0))
    upgrade.cost_scale = 0.0
    upgrade.tier_costs = _build_tier_costs(upgrade_id, upgrade.max_tier)
    upgrade.demo_locked = 2 if BALANCE.is_reward_core_upgrade(upgrade_id) else 0
    upgrade.section = 0
    var branch_theme: Dictionary = _get_branch_theme(upgrade_id)
    upgrade.act = int(branch_theme.get("act", entry.get("phase", 1)))
    upgrade.epilogue = 0
    upgrade.type = Util.NODE_TYPES.NORMAL
    upgrade.sim_key = upgrade_id
    upgrade.sim_name = str(entry.get("label", upgrade_id))
    upgrade.sim_description = _build_sim_description(entry, upgrade_id, best_layer_clear_percents)
    upgrade.sim_icon = str(entry.get("icon", "O"))
    upgrade.sim_group = int(branch_theme.get("group", 3 if BALANCE.is_core_upgrade(upgrade_id) else (2 if BALANCE.is_xp_upgrade(upgrade_id) else 1)))
    upgrade.sim_level = 1
    upgrade.sim_group_pos = int(branch_theme.get("pos", 1))
    var dep_id := ""
    if BALANCE.is_core_upgrade(upgrade_id):
        dep_id = BALANCE.get_core_upgrade_dependency(upgrade_id)
    elif BALANCE.is_xp_upgrade(upgrade_id):
        dep_id = BALANCE.get_xp_upgrade_dependency(upgrade_id)
    else:
        dep_id = BALANCE.get_upgrade_dependency(upgrade_id)
    if dep_id.is_empty() or dep_id == "start":
        upgrade.forced_cell = Vector2.ZERO
    else:
        if BALANCE.is_core_upgrade(upgrade_id):
            upgrade.forced_cell = BALANCE.get_core_upgrade_cell(dep_id)
        elif BALANCE.is_xp_upgrade(upgrade_id):
            upgrade.forced_cell = BALANCE.get_xp_upgrade_cell(dep_id)
        else:
            upgrade.forced_cell = BALANCE.get_upgrade_cell(dep_id)
    Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

    var owned_level: int = int(saved_levels.get(upgrade_id, 0))
    if owned_level > 0:
        upgrade.current_tier = clampi(owned_level, 0, upgrade.max_tier)
        Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _get_branch_theme(upgrade_id: String) -> Dictionary:
    return Dictionary(BRANCH_THEME_BY_ID.get(upgrade_id, {}))

static func _build_sim_description(entry: Dictionary, upgrade_id: String, best_layer_clear_percents: Dictionary) -> String:
    var summary: String = str(entry.get("summary", "Data Breach upgrade."))
    if not BALANCE.is_reward_core_upgrade(upgrade_id):
        return summary
    var target_layer_depth: int = BALANCE.get_reward_core_upgrade_target_layer_depth(upgrade_id)
    var layer_name: String = BALANCE.get_reward_core_upgrade_target_layer_name(upgrade_id)
    var target_percent: float = BALANCE.get_reward_core_upgrade_target_percent(upgrade_id)
    var current_percent: float = min(float(best_layer_clear_percents.get(target_layer_depth, 0.0)), target_percent)
    if current_percent >= target_percent:
        return "%s\nUnlocked at %.1f%% clear of %s." % [summary, target_percent, layer_name]
    return "%s\nProgress: %.1f%% / %.1f%% clear of %s." % [summary, current_percent, target_percent, layer_name]

static func _build_tier_costs(upgrade_id: String, max_tier: int) -> Array:
    var costs: Array = []
    for level in range(max_tier):
        if BALANCE.is_core_upgrade(upgrade_id):
            costs.append(BALANCE.get_core_upgrade_cost(upgrade_id, level))
        elif BALANCE.is_xp_upgrade(upgrade_id):
            costs.append(BALANCE.get_xp_upgrade_cost(upgrade_id, level))
        else:
            costs.append(BALANCE.get_upgrade_cost(upgrade_id, level))
    return costs

static func _mod_for_upgrade(upgrade_id: String) -> Util.MODS:
    if BALANCE.is_core_upgrade(upgrade_id):
        return Util.MODS.MONEY_PER_MATTER
    if BALANCE.is_xp_upgrade(upgrade_id):
        return Util.MODS.RUN_TIMER_BASE
    if upgrade_id in ["laser_cutter", "shock_bits", "daemon_lances", "root_breaker", "mantle_drills", "mirror_saws", "null_borers"]:
        return Util.MODS.BASE_DAMAGE_PER_CLICK
    if upgrade_id in ["rapid_cycle", "fault_charges", "vault_pulsers"]:
        return Util.MODS.CLICK_RATE
    if upgrade_id in ["void_cutters", "gravity_wells"]:
        return Util.MODS.CLICK_AOE
    if upgrade_id in ["fuel_cells", "inversion_drives"]:
        return Util.MODS.RUN_TIMER_BASE
    if upgrade_id in ["cargo_racks", "ore_appraisal", "salvage_contract", "abyssal_rigs", "ash_crowns"]:
        return Util.MODS.MONEY_PER_MATTER
    if upgrade_id == "barrier_mesh":
        return Util.MODS.ASTEROID_DENSITY
    if upgrade_id == "breach_drones":
        return Util.MODS.ELECTRIC_CRIT_CHANCE
    if upgrade_id in ["fault_harpoons"]:
        return Util.MODS.CLICKER_CRIT_CHANCE
    if upgrade_id in ["funnel_resonance", "overburn_reactors", "seismic_lattice"]:
        return Util.MODS.ASTEROIDS_TO_SPAWN
    return Util.MODS.MONEY_PER_MATTER
