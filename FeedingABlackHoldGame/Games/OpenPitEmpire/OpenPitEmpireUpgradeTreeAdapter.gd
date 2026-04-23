extends RefCounted
class_name OpenPitEmpireUpgradeTreeAdapter

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var saved_upgrades: Dictionary = PROGRESS.load_data().get("upgrades", {})
    saved_upgrades.merge(PROGRESS.get_xp_upgrade_levels(), true)
    saved_upgrades.merge(PROGRESS.get_core_upgrade_levels(), true)
    var next_id := 0
    for entry in BALANCE.get_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id)
        next_id += 1
    for entry in BALANCE.get_xp_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id)
        next_id += 1
    for entry in BALANCE.get_core_upgrade_catalog():
        _append_upgrade(entry, saved_upgrades, next_id)
        next_id += 1

static func _append_upgrade(entry: Dictionary, saved_levels: Dictionary, next_id: int) -> void:
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
    upgrade.demo_locked = 0
    upgrade.section = 0
    upgrade.act = int(entry.get("phase", 1))
    upgrade.epilogue = 0
    upgrade.type = Util.NODE_TYPES.NORMAL
    upgrade.sim_key = upgrade_id
    upgrade.sim_name = str(entry.get("label", upgrade_id))
    upgrade.sim_description = str(entry.get("summary", "Data Breach upgrade."))
    upgrade.sim_icon = str(entry.get("icon", "O"))
    upgrade.sim_group = 3 if BALANCE.is_core_upgrade(upgrade_id) else (2 if BALANCE.is_xp_upgrade(upgrade_id) else 1)
    upgrade.sim_level = 1
    upgrade.sim_group_pos = 1
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
