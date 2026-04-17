extends RefCounted
class_name OpenPitOrbitUpgradeTreeAdapter

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const PROGRESS := preload("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var saved_upgrades: Dictionary = PROGRESS.load_data().get("upgrades", {})
    var next_id := 0
    for entry in BALANCE.get_upgrade_catalog():
        var upgrade := Upgrade.new()
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id.is_empty():
            continue
        upgrade.id = next_id
        next_id += 1
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
        upgrade.sim_description = str(entry.get("summary", "Orbit mining upgrade."))
        upgrade.sim_icon = str(entry.get("icon", "O"))
        upgrade.sim_group = 1
        upgrade.sim_level = 1
        upgrade.sim_group_pos = 1
        var dep_id: String = BALANCE.get_upgrade_dependency(upgrade_id)
        if dep_id.is_empty() or dep_id == "start":
            upgrade.forced_cell = Vector2.ZERO
        else:
            upgrade.forced_cell = BALANCE.get_upgrade_cell(dep_id)
        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = int(saved_upgrades.get(upgrade_id, 0))
        if owned_level > 0:
            upgrade.current_tier = clampi(owned_level, 0, upgrade.max_tier)
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _build_tier_costs(upgrade_id: String, max_tier: int) -> Array:
    var costs: Array = []
    for level in range(max_tier):
        costs.append(BALANCE.get_upgrade_cost(upgrade_id, level))
    return costs

static func _mod_for_upgrade(upgrade_id: String) -> Util.MODS:
    if upgrade_id.begins_with("dmg") or upgrade_id == "core_breaker":
        return Util.MODS.BASE_DAMAGE_PER_CLICK
    if upgrade_id.begins_with("fire_rate"):
        return Util.MODS.CLICK_RATE
    if upgrade_id.begins_with("range") or upgrade_id == "pickup_expand" or upgrade_id == "magnet1":
        return Util.MODS.CLICK_AOE
    if upgrade_id.begins_with("speed") or upgrade_id.begins_with("fuel_tank") or upgrade_id == "fuel_efficiency1":
        return Util.MODS.RUN_TIMER_BASE
    if upgrade_id.begins_with("cargo") or upgrade_id.begins_with("resource") or upgrade_id.begins_with("value") or upgrade_id == "gold_value":
        return Util.MODS.MONEY_PER_MATTER
    if upgrade_id.begins_with("barrier"):
        return Util.MODS.ASTEROID_DENSITY
    if upgrade_id.begins_with("drone"):
        return Util.MODS.ELECTRIC_CRIT_CHANCE
    if upgrade_id.contains("electric") or upgrade_id.contains("chain"):
        return Util.MODS.CLICKER_CRIT_CHANCE
    if upgrade_id.contains("shockwave") or upgrade_id.contains("overdrive") or upgrade_id.contains("mega"):
        return Util.MODS.ASTEROIDS_TO_SPAWN
    return Util.MODS.MONEY_PER_MATTER
