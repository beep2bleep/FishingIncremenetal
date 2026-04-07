extends RefCounted
class_name TurkeyUpgradeTreeAdapter

const TURKEY_PROGRESS := preload("res://Games/Turkey/TurkeyProgress.gd")

const ICON_MODS: Array[int] = [
	Util.MODS.BASE_DAMAGE_PER_CLICK,
	Util.MODS.CLICK_RATE,
	Util.MODS.RUN_TIMER_BASE,
	Util.MODS.CLICK_AOE,
]

static func apply_simulation_upgrades() -> void:
	Global.game_mode_data_manager.upgrades = {}
	Global.game_mode_data_manager.unlocked_upgrades = {}

	var upgrade_catalog: Array[Dictionary] = TURKEY_PROGRESS.get_meta_upgrade_catalog()
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
		upgrade.cost_scale = 0.0
		upgrade.tier_costs = entry.get("tier_costs", [])
		upgrade.demo_locked = 0
		upgrade.section = 0
		upgrade.act = int(entry.get("act", 1))
		upgrade.epilogue = 0
		upgrade.type = Util.NODE_TYPES.NORMAL
		upgrade.sim_key = upgrade_key
		upgrade.sim_name = str(entry.get("label", upgrade_key))
		upgrade.sim_description = str(entry.get("summary", "Turkey meta upgrade."))
		upgrade.sim_icon = str(entry.get("icon", "T"))
		upgrade.sim_group = int(entry.get("branch", 0))
		upgrade.sim_level = 1
		upgrade.sim_group_pos = int(entry.get("step", 1))

		var dependency_key: String = str(entry.get("dependency", ""))
		upgrade.forced_cell = Vector2.ZERO if dependency_key.is_empty() else Vector2(id_to_cell.get(dependency_key, Vector2.ZERO))
		Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

		var owned_level: int = TURKEY_PROGRESS.get_upgrade_level(upgrade.sim_key)
		if owned_level > 0:
			upgrade.current_tier = clampi(owned_level, 0, upgrade.max_tier)
			Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()
