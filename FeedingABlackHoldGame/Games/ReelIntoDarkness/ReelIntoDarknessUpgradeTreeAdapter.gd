extends RefCounted
class_name ReelIntoDarknessUpgradeTreeAdapter

const REEL_DATA := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
const REEL_PROGRESS := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")
const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")

const ICON_MODS: Array[int] = [
    Util.MODS.RUN_TIMER_BASE,
    Util.MODS.MAX_ASTEROID_SIZE,
    Util.MODS.RUN_TIMER_AMOUNT_ON_BLACK_HOLE_GROW,
    Util.MODS.BONUS_MONEY_SCALE,
]

static func apply_simulation_upgrades() -> void:
    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var demo_mode_enabled: bool = bool(ProjectSettings.get_setting("global/Demo", false))
    var upgrade_catalog: Array[Dictionary] = REEL_DATA.get_meta_upgrade_catalog()
    if Util.is_all_high_level_mode_active():
        upgrade_catalog.append(CROSS_GAME_BONUSES.get_cross_bonus_node_definition(Util.ACTIVE_GAME_REEL_INTO_DARKNESS))
    var id_to_cell: Dictionary = {}
    for entry in upgrade_catalog:
        id_to_cell[str(entry.get("id", ""))] = Vector2(entry.get("cell", Vector2.ZERO))

    var next_id := 0
    for entry in upgrade_catalog:
        var upgrade_key: String = str(entry.get("id", ""))
        if upgrade_key.is_empty():
            continue

        var upgrade := Upgrade.new()
        upgrade.id = next_id
        next_id += 1
        upgrade.cell = Vector2(entry.get("cell", Vector2.ZERO))
        upgrade.mod = ICON_MODS[(next_id - 1) % ICON_MODS.size()]
        upgrade.value = 0.0
        upgrade.max_tier = int(entry.get("max_tier", 1))
        upgrade.base_cost = int(entry.get("base_cost", 0))
        upgrade.cost_scale = float(entry.get("cost_scale", 1.0))
        upgrade.tier_costs = []
        upgrade.demo_locked = 0
        if demo_mode_enabled and REEL_DATA.should_lock_meta_upgrade_in_demo(entry):
            upgrade.demo_locked = 1
        upgrade.section = 0
        upgrade.act = int(entry.get("act", 1))
        upgrade.epilogue = 0
        upgrade.type = Util.NODE_TYPES.NORMAL
        upgrade.sim_key = upgrade_key
        upgrade.sim_name = TranslationServer.translate(str(entry.get("label", upgrade_key)))
        upgrade.sim_description = TranslationServer.translate(str(entry.get("summary", "Reel Into Darkness upgrade.")))
        upgrade.sim_icon = str(entry.get("icon", "R"))
        upgrade.sim_group = int(entry.get("branch", 0))
        upgrade.sim_level = 1
        upgrade.sim_group_pos = int(entry.get("step", 1))

        var dependency_key: String = str(entry.get("dependency", ""))
        upgrade.forced_cell = Vector2.ZERO if dependency_key.is_empty() else Vector2(id_to_cell.get(dependency_key, Vector2.ZERO))
        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = REEL_PROGRESS.get_upgrade_level(upgrade.sim_key)
        if CROSS_GAME_BONUSES.is_cross_bonus_key(upgrade.sim_key):
            owned_level = CROSS_GAME_BONUSES.get_target_bonus_level(Util.ACTIVE_GAME_REEL_INTO_DARKNESS)
        if upgrade.demo_locked == 1:
            owned_level = 0
        if owned_level > 0:
            upgrade.current_tier = clampi(owned_level, 0, upgrade.max_tier)
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()
