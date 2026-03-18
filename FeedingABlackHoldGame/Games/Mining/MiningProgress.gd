extends RefCounted
class_name MiningProgress

const SAVE_PATH := "user://mining_mode_save_v1.json"

const DEFAULT_DATA := {
	"wallet": 0,
	"best_depth": 0.0,
	"upgrades": {},
	"boss_unlocks": {},
	"checkpoint_owned": {},
	"selected_checkpoint": 0,
	"equipped": ["pistol", ""],
	"last_run_summary": "No mining run completed yet."
}

const UPGRADE_CATALOG: Array[Dictionary] = [
	{"id": "drill_power", "label": "Drill Power", "summary": "Shreds harder nodes faster.", "base_cost": 24, "cost_mult": 1.42, "max_level": 10, "requires": {}, "act": 2, "icon": "D"},
	{"id": "drill_integrity", "label": "Drill Integrity", "summary": "More drill durability per run.", "base_cost": 26, "cost_mult": 1.43, "max_level": 10, "requires": {"drill_power": 1}, "act": 2, "icon": "I"},
	{"id": "oxygen_tanks", "label": "Oxygen Tanks", "summary": "Longer dives before recall.", "base_cost": 28, "cost_mult": 1.45, "max_level": 10, "requires": {}, "act": 4, "icon": "O"},
	{"id": "hull_plating", "label": "Hull Plating", "summary": "More hull to tank hazards and bosses.", "base_cost": 28, "cost_mult": 1.45, "max_level": 10, "requires": {"oxygen_tanks": 1}, "act": 4, "icon": "H"},
	{"id": "cargo_racks", "label": "Ore Grading", "summary": "Raises the cash value of the haul you bring back.", "base_cost": 32, "cost_mult": 1.47, "max_level": 8, "requires": {"dirt_compressor": 1}, "act": 3, "icon": "G"},
	{"id": "dirt_compressor", "label": "Dirt Compressor", "summary": "Makes the basic shaft dirt worth more.", "base_cost": 20, "cost_mult": 1.4, "max_level": 8, "requires": {}, "act": 3, "icon": "C"},
	{"id": "ore_scanner", "label": "Ore Scanner", "summary": "Boosts deep rare node spawns.", "base_cost": 44, "cost_mult": 1.48, "max_level": 6, "requires": {"cargo_racks": 1}, "act": 3, "icon": "S"},
	{"id": "thruster_power", "label": "Thruster Power", "summary": "Base descent speed goes up.", "base_cost": 34, "cost_mult": 1.45, "max_level": 10, "requires": {}, "act": 5, "icon": "T"},
	{"id": "shaft_lubricant", "label": "Shaft Lubricant", "summary": "Cleaner steering and a little more speed.", "base_cost": 38, "cost_mult": 1.45, "max_level": 8, "requires": {"thruster_power": 1}, "act": 5, "icon": "L"},
	{"id": "cord_winch", "label": "Cord Winch", "summary": "Ascent cord hauls you up even faster.", "base_cost": 48, "cost_mult": 1.48, "max_level": 8, "requires": {"shaft_lubricant": 1}, "act": 5, "icon": "W"},
	{"id": "launch_thrusters", "label": "Launch Thrusters", "summary": "The start of every run gets much faster.", "base_cost": 56, "cost_mult": 1.5, "max_level": 6, "requires": {"thruster_power": 2}, "act": 5, "icon": "B"},
	{"id": "start_boost", "label": "Drop Rails", "summary": "Extends the super-fast opening burst.", "base_cost": 78, "cost_mult": 1.56, "max_level": 5, "requires": {"launch_thrusters": 2}, "act": 5, "icon": "R"},
	{"id": "teleport_core", "label": "Teleport Core", "summary": "Instant shaft entry burst with auto-scoop.", "base_cost": 620, "cost_mult": 2.0, "max_level": 1, "requires": {"start_boost": 5}, "act": 5, "icon": "P"},
	{"id": "punch_damage", "label": "Shock Fist", "summary": "Punches become a real backup weapon.", "base_cost": 16, "cost_mult": 1.38, "max_level": 10, "requires": {}, "act": 1, "icon": "F"},
	{"id": "pistol_damage", "label": "Pistol Damage", "summary": "Better skeet cleanup and chip damage.", "base_cost": 22, "cost_mult": 1.42, "max_level": 10, "requires": {"punch_damage": 1}, "act": 1, "icon": "P"},
	{"id": "pistol_reload", "label": "Pistol Reload", "summary": "Less downtime on the starter gun.", "base_cost": 22, "cost_mult": 1.42, "max_level": 8, "requires": {"pistol_damage": 1}, "act": 1, "icon": "R"},
	{"id": "shotgun_unlock", "label": "Unlock Scattergun", "summary": "Adds a short-range burst weapon for slot two.", "base_cost": 96, "cost_mult": 2.0, "max_level": 1, "requires": {"pistol_damage": 2}, "act": 6, "icon": "S"},
	{"id": "shotgun_damage", "label": "Scattergun Damage", "summary": "More burst for close mining fights.", "base_cost": 54, "cost_mult": 1.46, "max_level": 8, "requires": {"shotgun_unlock": 1}, "act": 6, "icon": "D"},
	{"id": "shotgun_reload", "label": "Scattergun Reload", "summary": "Gets the shell swap moving.", "base_cost": 56, "cost_mult": 1.46, "max_level": 8, "requires": {"shotgun_unlock": 1}, "act": 6, "icon": "R"},
	{"id": "rifle_unlock", "label": "Unlock Burst Rifle", "summary": "A stable midrange gun with good uptime.", "base_cost": 168, "cost_mult": 2.0, "max_level": 1, "requires": {"shotgun_unlock": 1, "pistol_reload": 3}, "act": 6, "icon": "U"},
	{"id": "rifle_damage", "label": "Burst Rifle Damage", "summary": "Scales the rifle for deep hazards.", "base_cost": 72, "cost_mult": 1.48, "max_level": 8, "requires": {"rifle_unlock": 1}, "act": 6, "icon": "D"},
	{"id": "rifle_reload", "label": "Burst Rifle Reload", "summary": "Keeps the rifle cycling smoothly.", "base_cost": 72, "cost_mult": 1.48, "max_level": 8, "requires": {"rifle_unlock": 1}, "act": 6, "icon": "R"},
	{"id": "railgun_unlock", "label": "Unlock Railgun", "summary": "Huge punch, long reload, perfect swap gun.", "base_cost": 320, "cost_mult": 2.0, "max_level": 1, "requires": {"rifle_unlock": 1, "start_boost": 2}, "act": 7, "icon": "U"},
	{"id": "railgun_damage", "label": "Railgun Damage", "summary": "Turns the railgun into a checkpoint breaker.", "base_cost": 122, "cost_mult": 1.52, "max_level": 6, "requires": {"railgun_unlock": 1}, "act": 7, "icon": "D"},
	{"id": "railgun_reload", "label": "Railgun Reload", "summary": "Shaves the reload enough for swap loops.", "base_cost": 118, "cost_mult": 1.52, "max_level": 6, "requires": {"railgun_unlock": 1}, "act": 7, "icon": "R"},
]

static func get_default_data() -> Dictionary:
	return DEFAULT_DATA.duplicate(true)

static func get_upgrade_catalog() -> Array[Dictionary]:
	return UPGRADE_CATALOG.duplicate(true)

static func load_data() -> Dictionary:
	var data: Dictionary = get_default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		return data
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return data
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = data.merged(parsed, true)
	return data

static func save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))

static func reset_progress() -> Dictionary:
	var data: Dictionary = get_default_data()
	save_data(data)
	return data

static func get_wallet() -> int:
	return int(load_data().get("wallet", 0))

static func get_upgrade_level(upgrade_id: String) -> int:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("upgrades", {})
	return int(upgrades.get(upgrade_id, 0))

static func apply_tree_purchase(upgrade_id: String, level: int, wallet_after_purchase: int) -> void:
	var data: Dictionary = load_data()
	var upgrades: Dictionary = data.get("upgrades", {})
	upgrades[upgrade_id] = max(level, int(upgrades.get(upgrade_id, 0)))
	data["upgrades"] = upgrades
	data["wallet"] = max(0, wallet_after_purchase)
	_try_auto_equip_weapon(data, upgrade_id)
	save_data(data)

static func set_wallet(wallet_value: int) -> void:
	var data: Dictionary = load_data()
	data["wallet"] = max(0, wallet_value)
	save_data(data)

static func unlock_checkpoint(depth_marker: int) -> void:
	var data: Dictionary = load_data()
	var key: String = str(depth_marker)
	var boss_unlocks: Dictionary = data.get("boss_unlocks", {})
	var checkpoint_owned: Dictionary = data.get("checkpoint_owned", {})
	boss_unlocks[key] = true
	checkpoint_owned[key] = true
	data["boss_unlocks"] = boss_unlocks
	data["checkpoint_owned"] = checkpoint_owned
	data["selected_checkpoint"] = max(int(data.get("selected_checkpoint", 0)), depth_marker)
	save_data(data)

static func _try_auto_equip_weapon(data: Dictionary, upgrade_id: String) -> void:
	var weapon_id := ""
	match upgrade_id:
		"shotgun_unlock":
			weapon_id = "shotgun"
		"rifle_unlock":
			weapon_id = "rifle"
		"railgun_unlock":
			weapon_id = "railgun"
	if weapon_id.is_empty():
		return
	var equipped: Array = data.get("equipped", ["pistol", ""])
	if String(equipped[1]).is_empty():
		equipped[1] = weapon_id
	elif String(equipped[0]) == "pistol" and String(equipped[1]) == "shotgun" and weapon_id == "rifle":
		equipped[1] = weapon_id
	data["equipped"] = equipped
