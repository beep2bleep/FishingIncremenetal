extends RefCounted
class_name FishingUpgradeTreeAdapter

const DATA_PATH: String = "res://Data/FishingUpgradeData.json"
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
    var id_to_cell: Dictionary = _build_tree_layout(raw_upgrades)
    var formatter: FishingUpgradeDB = FishingUpgradeDB.new()

    Global.game_mode_data_manager.upgrades = {}
    Global.game_mode_data_manager.unlocked_upgrades = {}

    var i: int = 0
    for entry_variant: Variant in raw_upgrades:
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
        upgrade.max_tier = 1
        upgrade.base_cost = int(round(float(entry.get("cost", 0.0))))
        upgrade.cost_scale = 0.0
        upgrade.forced_cell = null
        upgrade.demo_locked = 0
        upgrade.section = 0
        upgrade.act = 1
        upgrade.epilogue = 0
        upgrade.type = Util.NODE_TYPES.NORMAL

        upgrade.sim_key = str(entry.get("key", ""))
        upgrade.sim_name = formatter.get_display_name(entry)
        upgrade.sim_description = formatter.get_description(entry)
        upgrade.sim_icon = str(entry.get("icon", ""))
        if upgrade.sim_icon == "":
            upgrade.sim_icon = upgrade.sim_name.substr(0, 1)
        upgrade.sim_group = int(entry.get("group", 1))
        upgrade.sim_level = int(entry.get("level", 1))
        upgrade.sim_group_pos = int(entry.get("group_pos", 1))

        var dep_variant: Variant = entry.get("dependency", null)
        if dep_variant != null:
            var dep_id: String = str(dep_variant)
            if dep_id != "" and id_to_cell.has(dep_id):
                upgrade.forced_cell = id_to_cell[dep_id]

        Global.game_mode_data_manager.upgrades[upgrade.cell] = upgrade

        var owned_level: int = SaveHandler.get_fishing_upgrade_level(upgrade.sim_key)
        if owned_level >= upgrade.sim_level:
            upgrade.current_tier = 1
            Global.game_mode_data_manager.unlocked_upgrades[upgrade.cell] = upgrade.to_dict()

static func _build_tree_layout(raw_upgrades: Array) -> Dictionary:
    var id_to_cell: Dictionary = {}
    var used_cells: Dictionary = {}
    var dirs: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

    var first_assigned: bool = false
    for entry_variant: Variant in raw_upgrades:
        if not (entry_variant is Dictionary):
            continue
        var entry: Dictionary = entry_variant
        var upgrade_id: String = str(entry.get("id", ""))
        if upgrade_id == "":
            continue

        var cell: Vector2 = Vector2.ZERO
        if not first_assigned:
            cell = Vector2(1, 0)
            first_assigned = true
        else:
            var dep_id: String = str(entry.get("dependency", ""))
            var key: String = str(entry.get("key", ""))
            var branch: int = _branch_for_key(key)
            var dir: Vector2 = dirs[branch]
            var parent_cell: Vector2 = id_to_cell.get(dep_id, Vector2.ZERO)
            cell = parent_cell + dir * 2.0
            while used_cells.has(cell):
                cell += dir * 2.0

        id_to_cell[upgrade_id] = cell
        used_cells[cell] = true

    return id_to_cell

static func _branch_for_key(key: String) -> int:
    var lower: String = key.to_lower()
    if lower.find("archer") >= 0:
        return 0
    if lower.find("knight") >= 0:
        return 1
    if lower.find("mage") >= 0:
        return 2
    if lower.find("guardian") >= 0:
        return 3

    var hash_val: int = 0
    for c in lower:
        hash_val = int((hash_val * 31 + c.unicode_at(0)) % 2147483647)
    return int(abs(hash_val) % 4)
