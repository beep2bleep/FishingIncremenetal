extends RefCounted
class_name MiningUpgradeTreeAdapter

const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")

const LAYOUT_BY_KEY := {
	"timer_reserve": Vector2(-1, 0),
	"engine_tuning": Vector2(0, -1),
	"drill_torque": Vector2(0, 1),
	"drill_plating": Vector2(1, 1),
	"cargo_pods": Vector2(-1, 1),
	"ore_refinery": Vector2(-2, 1),
	"pickup_radius": Vector2(-2, 0),
	"xp_calibration": Vector2(-3, 1),
	"dirt_softener": Vector2(1, -1),
	"depth_scanner": Vector2(2, -1),
	"magnet_drone": Vector2(-3, 0),
	"delivery_drone": Vector2(-4, 0),
}

static func apply_simulation_upgrades() -> void:
	Global.game_mode_data_manager.upgrades = {}
	Global.game_mode_data_manager.unlocked_upgrades = {}

	var saved_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
	var saved_upgrades: Dictionary = saved_data.get("upgrades", {})
	var upgrade_catalog: Array[Dictionary] = MINING_PROGRESS_SCRIPT.get_upgrade_catalog()

	var next_id := 0
	for upgrade_def in upgrade_catalog:
		var upgrade := Upgrade.new()
		var upgrade_id: String = str(upgrade_def.get("id", ""))
		if upgrade_id.is_empty():
			continue
		upgrade.id = next_id
		next_id += 1
		upgrade.cell = Vector2(LAYOUT_BY_KEY.get(upgrade_id, Vector2.ZERO))
		upgrade.mod = Util.MODS.PASSIVE_MONEY_PER_SECOND
		upgrade.value = 0.0
		upgrade.max_tier = int(upgrade_def.get("max_level", 1))
		upgrade.base_cost = int(upgrade_def.get("base_cost", 0))
		upgrade.cost_scale = 0.0
		upgrade.tier_costs = _build_tier_costs(upgrade_def)
		upgrade.demo_locked = 0
		upgrade.section = 0
		upgrade.act = int(upgrade_def.get("act", 1))
		upgrade.epilogue = 0
		upgrade.type = Util.NODE_TYPES.NORMAL
		upgrade.sim_key = upgrade_id
		upgrade.sim_name = str(upgrade_def.get("label", upgrade_id))
		upgrade.sim_description = str(upgrade_def.get("summary", ""))
		upgrade.sim_icon = str(upgrade_def.get("icon", "M"))

		var requires: Dictionary = upgrade_def.get("requires", {})
		if requires.is_empty():
			upgrade.forced_cell = Vector2.ZERO
		else:
			var req_id: String = str(requires.keys()[0])
			upgrade.forced_cell = Vector2(LAYOUT_BY_KEY.get(req_id, Vector2.ZERO))

		Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

		var owned_level: int = int(saved_upgrades.get(upgrade_id, 0))
		if owned_level > 0:
			upgrade.current_tier = clampi(owned_level, 0, upgrade.max_tier)
			Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _build_tier_costs(upgrade_def: Dictionary) -> Array:
	var costs: Array = []
	var base_cost: float = float(upgrade_def.get("base_cost", 0))
	var scale: float = float(upgrade_def.get("cost_mult", 1.0))
	var max_level: int = int(upgrade_def.get("max_level", 1))
	for level in range(max_level):
		costs.append(int(round(base_cost * pow(scale, level))))
	return costs
