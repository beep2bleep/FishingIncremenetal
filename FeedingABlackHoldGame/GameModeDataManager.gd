extends Resource
class_name GameModeDataManager

var upgrades = {}
var unlocked_upgrades = {}
var tiers = []

func load_game_mode_data(game_mode_data: GameModeData):
    var json_data = Util.load_json_data_from_path(game_mode_data.data_path)
    if json_data != null:
        var upgrade_data = json_data.get("Upgrades")
        if upgrade_data != null and upgrade_data is Array:
            for i in range(upgrade_data.size()):
                parse_upgrade_from_data(i, upgrade_data[i])
        else:
            print_debug("Could not find Upgrades in ", game_mode_data.data_path)

        var base_mod_data = json_data.get("Base Mods Data")
        if base_mod_data != null and base_mod_data is Array:
            for i in range(base_mod_data.size()):
                parse_base_mod_from_data(base_mod_data[i])
        else:
            print_debug("Could not find Base Mods Data in ", game_mode_data.data_path)

        var black_hole_teir_data = json_data.get("Black Hole Tier Data")
        if black_hole_teir_data != null and black_hole_teir_data is Array:
            for i in range(black_hole_teir_data.size()):
                parse_black_hoel_teir_from_data(black_hole_teir_data[i])
        else:
            print_debug("Could not find Black Hole Tier Data in ", game_mode_data.data_path)

        var game_mode_config_data = json_data.get("Game Mode Config")
        if game_mode_config_data != null and game_mode_config_data is Array:
            for i in range(game_mode_config_data.size()):
                parse_config_from_data(game_mode_config_data[i])
        else:
            print_debug("Could not find Game Mode Config in ", game_mode_data.data_path)

    else:
        push_error(str("!! UpgradeManager Custom Errror !! can't load data from : ", game_mode_data))


















func parse_black_hoel_teir_from_data(json_data: Dictionary):
    var xp_per_level = json_data["xp_per_level"] if json_data.has("xp_per_level") else []
    var level_name_keys = json_data["level_name_keys"] if json_data.has("level_name_keys") else []
    var zoom = json_data["zoom"] if json_data.has("zoom") else 1.0

    var set_money_to_this_amount_on_finishing_tier = json_data["set_money_to_this_amount_on_finishing_tier"] if json_data.has("set_money_to_this_amount_on_finishing_tier") else 0.0

    var radius_start = json_data["radius_start"] if json_data.has("radius_start") else 10.0
    var radius_end = json_data["radius_end"] if json_data.has("radius_end") else 10.0

    var epilogue = json_data["epilogue"] if json_data.has("epilogue") else false

    var forced_objects_to_spawn = json_data["forced_objects_to_spawn"] if json_data.has("forced_objects_to_spawn") else null
    var forced_session_timer = json_data["forced_session_timer"] if json_data.has("forced_session_timer") else null

    var new_black_hole_tier = BlackHoleTierData.new(
        xp_per_level, 
        level_name_keys, 
        zoom, 
        set_money_to_this_amount_on_finishing_tier, 
        radius_start, 
        radius_end, 
        epilogue, 
        forced_objects_to_spawn, 
        forced_session_timer
    )
    tiers.append(new_black_hole_tier)

func parse_config_from_data(json_data: Dictionary):
    var config_type = Util.CONFIG_TYPES[json_data["type"]]
    var config_value = json_data["value"]

    if config_type != null and config_value != null:
        Global.config.set_config(config_type, config_value)


func parse_base_mod_from_data(json_data: Dictionary):
    var mod_type = Util.MODS[json_data["type"]]
    var mod_value = json_data["value"]

    if mod_type != null and mod_value != null:
        Global.mods.set_mod(mod_type, mod_value)


func parse_upgrade_from_data(id, json_data: Dictionary):
    var upgrade: Upgrade = Upgrade.new()
    upgrade.id = id

    if Util.MODS.has(json_data["type"]) == false:
        return

    upgrade.mod = Util.MODS[json_data["type"]]
    upgrade.cell = Vector2(int(json_data["x"]), int(json_data["y"]))

    if json_data["connect_x"] != null and json_data["connect_y"] != null:
        upgrade.forced_cell = Vector2(int(json_data["connect_x"]), int(json_data["connect_y"]))

    upgrade.max_tier = int(json_data["vars"]["max"])
    upgrade.value = json_data["vars"]["value"]
    upgrade.base_cost = int(json_data["vars"]["cost"])
    upgrade.cost_scale = float(json_data["vars"]["cost_scale"])


    upgrade.section = int(json_data["vars"]["section"])
    upgrade.act = int(json_data["vars"]["act"])

    upgrade.demo_locked = int(json_data["vars"]["demo_locked"]) if json_data["vars"].has("demo_locked") else 0
    upgrade.epilogue = int(json_data["vars"]["epilogue"]) if json_data["vars"].has("epilogue") else 0


    upgrades[upgrade.cell] = upgrade
