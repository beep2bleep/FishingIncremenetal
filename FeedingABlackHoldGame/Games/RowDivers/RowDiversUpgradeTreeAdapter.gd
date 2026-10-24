extends RefCounted
class_name RowDiversUpgradeTreeAdapter

const PROGRESS := preload("res://Games/RowDivers/RowDiversProgress.gd")
const ICON_MODS: Array[int] = [
	Util.MODS.BASE_DAMAGE_PER_CLICK,
	Util.MODS.CLICK_RATE,
	Util.MODS.CLICK_AOE,
	Util.MODS.CLICKER_CRIT_CHANCE,
]

static func apply_simulation_upgrades() -> void:
	if not SignalBus.settings_updated.is_connected(_refresh_icons): SignalBus.settings_updated.connect(_refresh_icons)
	var data: Dictionary = PROGRESS.design()
	var progress: Dictionary = PROGRESS.load_data()
	PROGRESS.check_achievements(progress)
	# PanelManager.PrestigePanelVisibility defaults each new dive to the highest
	# unlocked prestige. The shared scene exposes that choice before PLAY instead.
	progress.prestige = int(progress.max_prestige)
	var raw_upgrades: Array = data.get("upgrades", [])
	var id_to_cell: Dictionary = {}
	for index in range(raw_upgrades.size()):
		id_to_cell[str(raw_upgrades[index].get("id", ""))] = Vector2(index + 1, 0)

	Global.game_mode_data_manager.upgrades = {}
	Global.game_mode_data_manager.unlocked_upgrades = {}
	for index in range(raw_upgrades.size()):
		var entry: Dictionary = raw_upgrades[index]
		var upgrade := Upgrade.new()
		upgrade.id = index
		upgrade.cell = id_to_cell[str(entry.get("id", ""))]
		upgrade.mod = ICON_MODS[index % ICON_MODS.size()]
		upgrade.value = 0.0
		upgrade.max_tier = int(entry.get("maxLevel", 1))
		upgrade.base_cost = int(entry.get("baseUpgradeCost", 0))
		upgrade.cost_scale = 0.0
		upgrade.tier_costs = []
		for tier in range(upgrade.max_tier):
			upgrade.tier_costs.append(ceil(float(upgrade.base_cost) * pow(1.2, mini(tier, upgrade.max_tier - 1))))
		upgrade.demo_locked = 0
		upgrade.section = 0
		upgrade.act = clampi(int(entry.get("rarity", 0)) + 1, 1, 7)
		upgrade.epilogue = 0
		upgrade.type = Util.NODE_TYPES.NORMAL
		upgrade.sim_key = str(entry.get("id", ""))
		upgrade.sim_name = str(entry.get("upgradeName", "Railway Fury Upgrade"))
		upgrade.sim_description = str(entry.get("upgradeDescription", ""))
		upgrade.sim_icon = _icon_for(entry)
		upgrade.sim_group = int(entry.get("rarity", 0))
		upgrade.sim_level = 1
		upgrade.sim_group_pos = 1
		# The Unity RectTransform positions are the authoritative layout. Its 5-unit
		# grid becomes 100 px per node in the source UI, matching the shared tree's
		# 96 px node spacing at this scale.
		var position: Array = entry.get("position", [0.0, 0.0])
		upgrade.sim_position = Vector2(float(position[0]), -float(position[1])) * 20.0
		upgrade.sim_currency = int(entry.get("cost", {}).get("currencyType", 0))
		var parents: Array = entry.get("parents", [])
		for parent_id in parents:
			if id_to_cell.has(str(parent_id)):
				var parent_cell: Vector2 = id_to_cell[str(parent_id)]
				upgrade.sim_connections.append(parent_cell)
				upgrade.sim_parent_thresholds[parent_cell] = int(entry.get("unlockAtParentLevel", 1))
		if upgrade.sim_connections.size() == 1:
			upgrade.forced_cell = upgrade.sim_connections[0]
		elif upgrade.sim_connections.is_empty():
			upgrade.forced_cell = Vector2.ZERO

		Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade
		var owned: int = PROGRESS.level(progress, entry)
		if owned > 0:
			upgrade.current_tier = mini(owned, upgrade.max_tier)
			Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _icon_for(entry: Dictionary) -> String:
	var title: String = str(entry.get("upgradeName", "")).to_lower()
	if "arrow" in title or "bow" in title: return "➶"
	if "hp" in title or "health" in title: return "+"
	if "armor" in title: return "◇"
	if "dagger" in title: return "†"
	if "fire" in title or "burn" in title: return "△"
	if not Dictionary(entry.get("unlocks", {})).is_empty(): return "★"
	return "○"

static func _refresh_icons() -> void:
	if not Util.is_row_divers_game_active(): return
	for upgrade in Global.game_mode_data_manager.upgrades.values():
		var entry: Dictionary = PROGRESS.find_upgrade(upgrade.sim_key)
		if not entry.is_empty(): upgrade.sim_icon = _icon_for(entry)
