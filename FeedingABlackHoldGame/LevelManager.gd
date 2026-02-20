extends Node
class_name LevelManager

signal updated(level_manager_updated_data: LevelManagerUpdatedData)

var level: int = 0
var current_xp: int = 0
var total_xp: int = 0
var is_at_max = false
var current_black_hole_tier_data: BlackHoleTierData
var current_tier_index = 0:
    set(new_value):
        current_tier_index = min(new_value, black_hole_tiers.size() - 1)
        current_black_hole_tier_data = black_hole_tiers[current_tier_index]
        update_tier()

var starting_max_level = 0
var max_level = 2
var black_hole_tiers: Array[BlackHoleTierData] = []

func _ready():

    if Global.game_mode_data_manager.tiers.size() > 0:
        var next_starting_level = 0
        for black_hole_tier: BlackHoleTierData in Global.game_mode_data_manager.tiers:
            black_hole_tier.starting_level = next_starting_level
            black_hole_tier.max_level = next_starting_level + black_hole_tier.xp_per_level.size() - 1
            black_hole_tiers.append(black_hole_tier)

            next_starting_level = black_hole_tier.max_level + 1
    else:
        seed_defualt_teirs()

    starting_max_level = black_hole_tiers[0].max_level
    max_level = black_hole_tiers[-1].max_level

    current_tier_index = 0
    update_tier()

func on_epilogue_started():
    current_tier_index += 1

func get_tiers_until_full_game():
    var count = 0
    for tdata: BlackHoleTierData in black_hole_tiers:
        if tdata.epilogue == false:
            count += 1
    return count


func reset():
    level = current_black_hole_tier_data.starting_level
    current_xp = 0
    total_xp = 0
    is_at_max = false

    emit_updated_data(0, current_xp, 0, level, false)

func update_tier():
    Global.mods.set_mod(Util.MODS.STARTING_BLACK_HOLE_LEVEL, current_black_hole_tier_data.starting_level)
    Global.mods.set_mod(Util.MODS.BLACK_HOLE_MAX_SIZE, current_black_hole_tier_data.max_level)

    if current_black_hole_tier_data.forced_objects_to_spawn != null:
        if current_black_hole_tier_data.forced_objects_to_spawn.size() >= 1:
            Global.mods.set_mod(Util.MODS.ASTEROIDS_TO_SPAWN, current_black_hole_tier_data.forced_objects_to_spawn[0])

        if current_black_hole_tier_data.forced_objects_to_spawn.size() >= 2:
            Global.mods.set_mod(Util.MODS.PLANETS_TO_SPAWN, current_black_hole_tier_data.forced_objects_to_spawn[1])

        if current_black_hole_tier_data.forced_objects_to_spawn.size() >= 3:
            Global.mods.set_mod(Util.MODS.STARS_TO_SPAWN, current_black_hole_tier_data.forced_objects_to_spawn[2])

    if current_black_hole_tier_data.forced_session_timer != null:
        Global.mods.set_mod(Util.MODS.RUN_TIMER_BASE, current_black_hole_tier_data.forced_session_timer)

    SaveHandler.save_player_last_run()

func get_remianing_xp_needed_to_level_up():
    return get_xp_for_next_level() - current_xp

func get_xp_for_next_level() -> int:
    return current_black_hole_tier_data.xp_per_level[min(level - current_black_hole_tier_data.starting_level, current_black_hole_tier_data.xp_per_level.size() - 1)]

func get_black_hole_radius() -> float:
    var levels_in_tier = current_black_hole_tier_data.xp_per_level.size()
    var current_level_in_tier = level - current_black_hole_tier_data.starting_level
    var progress = float(current_level_in_tier) / float(max(1, levels_in_tier - 1))

    return lerp(
        current_black_hole_tier_data.radius_start, 
        current_black_hole_tier_data.radius_end, 
        progress
    )

func add_xp(amount: int) -> void :
    if Global.game_state != Util.GAME_STATES.PLAYING or is_at_max:
        return

    var old_xp = current_xp
    var old_level = level
    current_xp += amount
    total_xp += amount
    var was_level_up = check_for_level_up()
    emit_updated_data(old_xp, current_xp, old_level, level, was_level_up)

func get_last_tier():
    return black_hole_tiers[max(0, current_tier_index - 1)]

func is_in_epilogue() -> bool:
    return current_black_hole_tier_data.epilogue

func get_first_epilogue_tier_index() -> int:
    for i in range(black_hole_tiers.size()):
        if black_hole_tiers[i].epilogue:
            return i
    return -1

func force_end_of_game():
    current_tier_index = get_tiers_until_full_game() - 1
    force_finish_current_tier()

func force_finish_current_tier():
    level = current_black_hole_tier_data.max_level
    add_xp(Global.black_hole.level_manager.get_remianing_xp_needed_to_level_up())

func check_for_level_up() -> bool:
    var leveled_up = false
    while current_xp >= get_xp_for_next_level():
        print_debug("lvl: %d | xp: %d / %d" % [level, current_xp, get_xp_for_next_level()])

        leveled_up = true
        if level + 1 > Global.mods.get_mod(Util.MODS.BLACK_HOLE_MAX_SIZE):
            is_at_max = true


            if current_tier_index + 1 < get_tiers_until_full_game():
                current_xp = 0
                Global.main.on_tier_finished(current_tier_index)
                current_tier_index += 1
            else:

                if current_black_hole_tier_data.epilogue:

                    current_xp = 0
                    Global.main.on_game_over(current_tier_index)
                else:

                    current_xp = 0
                    Global.main.on_game_over(current_tier_index)

            break

        if leveled_up and is_at_max == false:
            current_xp -= get_xp_for_next_level()
            level += 1
    return leveled_up

func emit_updated_data(old_xp: int, new_xp: int, old_level: int, new_level: int, was_level_up: bool) -> void :
    var update = LevelManagerUpdatedData.new()
    update.old_xp = old_xp
    update.new_xp = new_xp
    update.old_level = old_level
    update.new_level = new_level
    update.was_level_up = was_level_up
    update.current_level_xp = get_xp_for_next_level()
    update.total_xp = total_xp
    update.percent = float(new_xp) / float(update.current_level_xp)
    updated.emit(update)


func seed_defualt_teirs():
    black_hole_tiers = []

    var tier_0: BlackHoleTierData = BlackHoleTierData.new(
        [
            70, 420, 2520, 15120, 90720, 
            150000, 900000, 10000000, 12000000, 16500000, 
        ], 
        [
            "BLACK_HOLE_NAME_0", 
            "BLACK_HOLE_NAME_1", 
            "BLACK_HOLE_NAME_2", 
            "BLACK_HOLE_NAME_3", 
            "BLACK_HOLE_NAME_4", 
            "BLACK_HOLE_NAME_5", 
            "BLACK_HOLE_NAME_6", 
            "BLACK_HOLE_NAME_7", 
            "BLACK_HOLE_NAME_8", 
            "BLACK_HOLE_NAME_9", 
        ], 
        1.0, 
        100000000, 
        10.0, 
        50.0, 
        false
    )

    var tier_1: BlackHoleTierData = BlackHoleTierData.new(
    [
        7000000, 10000000, 35000000, 75000000, 165000000, 
        750000000, 5000000000, 17500000000, 23000000000, 29000000000, 
    ], 
    [
        "BLACK_HOLE_NAME_10", 
        "BLACK_HOLE_NAME_11", 
        "BLACK_HOLE_NAME_12", 
        "BLACK_HOLE_NAME_13", 
        "BLACK_HOLE_NAME_14", 
        "BLACK_HOLE_NAME_15", 
        "BLACK_HOLE_NAME_16", 
        "BLACK_HOLE_NAME_17", 
        "BLACK_HOLE_NAME_18", 
        "BLACK_HOLE_NAME_19", 
    ], 
    0.6, 
    200000000000, 
    50.0, 
    100.0, 
    false
    )

    var tier_2: BlackHoleTierData = BlackHoleTierData.new(
    [
        10000000000, 13250000000, 22000000000, 27000000000, 30000000000, 
        35000000000, 45000000000, 50000000000, 60000000000, 100000000000, 
    ], 
    [
        "BLACK_HOLE_NAME_20", 
        "BLACK_HOLE_NAME_21", 
        "BLACK_HOLE_NAME_22", 
        "BLACK_HOLE_NAME_23", 
        "BLACK_HOLE_NAME_24", 
        "BLACK_HOLE_NAME_25", 
        "BLACK_HOLE_NAME_26", 
        "BLACK_HOLE_NAME_27", 
        "BLACK_HOLE_NAME_28", 
        "BLACK_HOLE_NAME_29", 
    ], 
    0.45, 
    7500000000000, 
    100.0, 
    200.0, 
    false
    )

    var tier_3: BlackHoleTierData = BlackHoleTierData.new(
    [
        536800000000, 875320000000, 1357920000000, 1862860000000, 2443440000000
    ], 
    [
        "BLACK_HOLE_NAME_30", 
        "BLACK_HOLE_NAME_31", 
        "BLACK_HOLE_NAME_32", 
        "BLACK_HOLE_NAME_33", 
        "BLACK_HOLE_NAME_34", 
    ], 
    0.35, 
    13000000000000, 
    200.0, 
    300.0, 
    false
    )

    var tier_4: BlackHoleTierData = BlackHoleTierData.new(
    [
        6100000000000, 11500000000000, 26000000000000, 31000000000000, 37000000000000
    ], 
    [
        "BLACK_HOLE_NAME_35", 
        "BLACK_HOLE_NAME_36", 
        "BLACK_HOLE_NAME_37", 
        "BLACK_HOLE_NAME_38", 
        "BLACK_HOLE_NAME_39", 
    ], 
    0.3, 
    100000000000000, 
    300.0, 
    400.0, 
    false
    )

    var tier_5: BlackHoleTierData = BlackHoleTierData.new(
    [
        235000000000000
    ], 
    [
        "BLACK_HOLE_NAME_40", 
    ], 
    0.28, 
    500000000000000, 
    400.0, 
    600.0, 
    false
    )

    var tier_6: BlackHoleTierData = BlackHoleTierData.new(
    [
        690000000000000
    ], 
    [
        "BLACK_HOLE_NAME_41", 
    ], 
    0.25, 
    1000000000000000, 
    600.0, 
    800.0, 
    false
    )

    var tier_7: BlackHoleTierData = BlackHoleTierData.new(
    [
        3950000000000000
    ], 
    [
        "BLACK_HOLE_NAME_42", 
    ], 
    0.19, 
    10000000000000000, 
    800.0, 
    900.0, 
    true
    )

    tier_0.starting_level = 0
    tier_1.starting_level = 10
    tier_2.starting_level = 20
    tier_3.starting_level = 30
    tier_4.starting_level = 35
    tier_5.starting_level = 40
    tier_6.starting_level = 41
    tier_7.starting_level = 42

    black_hole_tiers.append(tier_0)
    black_hole_tiers.append(tier_1)
    black_hole_tiers.append(tier_2)
    black_hole_tiers.append(tier_3)
    black_hole_tiers.append(tier_4)
    black_hole_tiers.append(tier_5)
    black_hole_tiers.append(tier_6)
    black_hole_tiers.append(tier_7)
