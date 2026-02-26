extends Node


var PATH_JSON_DATA = "res://Data/Black Hole Data.json"

var PATH_MAIN = "res://Singletons/Main.tscn"
var PATH_MAIN_MENU = "res://Main Menu.tscn"
var PATH_FISHING_UPGRADES = "res://Fishing/FishingUpgradeScene.tscn"
var PATH_FISHING_BATTLE = "res://Fishing/BattleScene.tscn"


var dark_pallet = "res://Pallets/Dark_Pallet.tres"
var light_pallet = "res://Pallets/Light_Pallet.tres"


enum GAME_MODES{
    MAIN, 
    QUICK_PLAY, 
    MINI_CHALLENGE, 
    CHALLENGE, 
    THE_LINE, 
    GIANT_GRID, 
    ZEN_MODE, 
    ROGUELIKE, 
    DEMO, 
    DEMO_DEMO
}


enum GAME_MODE_TYPE{
    NORMAL, 
    ROGUELIKE
}

enum RESOURCE_TYPES{
    MATTER, 
    PLANET, 
    STAR, 
    BLACK_HOLE, 
    MONEY
}

enum OBJECT_TYPES{
    ASTEROID, 
    PLANET, 
    COMET, 
    UFO, 
    STAR
}


enum COMET_TYPE{
    CLICKER_AOE_BUFF, 
    MONEY_BUFF, 
    CLICKER_CRIT_CHANCE_BUFF
}

enum NODE_TYPES{
    NORMAL, 
    ROGUELIKE, 
    ROGUELIKE_DUMMY
}



enum MINION_TYPE{
    BREAKER, 
    COLLECTOR
}


enum CONFIG_TYPES{
    ASTEROID_BASE_HEALTH, 
    ASTEROID_BASE_XP, 
    ASTEROID_EXPONENT_FOR_XP_TIER, 
    PLANET_BASE_HEALTH, 
    PLANET_BASE_XP, 
    PLANET_EXPONENT_FOR_XP_TIER, 
    STAR_BASE_HEALTH, 
    STAR_BASE_XP, 
    STAR_EXPONENT_FOR_XP_TIER, 

    MAX_SUPERNOVA, 
    MIN_SPECIAL_STARS_PERCENT, 
    MAX_SPECIAL_STARS_PERCENT, 

    ASTEROIDS_TO_PREWARM, 
    PLANETS_TO_PREWARM, 
    STARS_TO_PREWARM, 

}


enum MODS{
    PASSIVE_MONEY_PER_SECOND, 
    MONEY_PER_MATTER, 
    BONUS_MONEY_SCALE, 

    CLICK_AOE, 
    CLICK_RATE, 
    BASE_DAMAGE_PER_CLICK, 

    RUN_TIMER_BASE, 

    RUN_TIMER_AMOUNT_ON_BLACK_HOLE_GROW, 
    MAX_ASTEROID_SIZE, 

    CHANCE_TO_ADD_TIME_ON_ASTEROID_DESTROYED, 
    RUN_TIMER_AMOUNT_ON_ASTEROID_DESTROYED, 

    ASTEROIDS_TO_SPAWN, 
    ASTEROID_DENSITY, 

    ASTEROIDS_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW, 
    CHANCE_TO_RESPAWN_ASTEROID_ON_BREAK, 

    SPECIAL_ASTEROID_BOMB_DAMAGE, 
    SPECIAL_ASTEROID_BOMB_SCALE, 

    CHANCE_TO_SPAWN_SPECIAL_ASTEROID_ELECTRIC, 
    SPECIAL_ASTEROID_ELECTRIC_DAMAGE, 
    SPECIAL_ASTEROID_ELECTRIC_MAX_CHAINS, 
    SPECIAL_ASTEROID_CHANCE_TO_FORK, 
    SPECIAL_ASTEROID_CHAIN_DISTANCE_SCALE, 


    CHANCE_TO_SPAWN_SPECIAL_ASTEROID_RADIOACTIVE, 
    SPECIAL_ASTEROID_RADIOACTIVE_DOT, 
    SPECIAL_ASTEROID_RADIOACTIVE_DURATION, 
    SPECIAL_ASTEROID_RADIOACTIVE_AOE_SCALE, 

    CLICKER_CRIT_CHANCE, 
    CLICKER_CRIT_BONUS, 

    ELECTRIC_CRIT_CHANCE, 
    ELECTRIC_CRIT_BONUS, 

    COMET_SPAWN_CHANCE, 
    COMET_BUFF_DURATION, 

    BLACK_HOLE_MAX_SIZE, 
    STARTING_BLACK_HOLE_LEVEL, 

    PLANET_DENSITY, 
    CLICKER_BONUS_DAMAGE_TO_PLANETS, 
    NUMBER_OF_ASTEROIDS_INTO_PLANETS, 
    MAX_PLANET_SIZE, 

    SPECIAL_PLANET_MOON_SPAWN_CHANCE, 
    SPECIAL_PLANET_MOON_MAX_MOONS, 
    SPECIAL_PLANET_MOON_BUFF_DURATION, 
    SPECIAL_PLANET_MOON_CLIKCER_RATE_BUFF_SCALE, 
    SPECIAL_PLANET_MOON_CLIKCER_AOE_BUFF_SCALE, 


    COMET_AOE_SPAWN_CHANCE, 
    COMET_CLICKER_AOE_BUFF_DURATION, 
    COMET_CLICKER_AOE_BUFF_AMOUNT, 

    COMET_MONEY_SPAWN_CHANCE, 
    COMET_MONEY_BUFF_DURATION, 
    COMET_MONEY_BUFF_AMOUNT, 

    COMET_CRIT_CHANCE_SPAWN_CHANCE, 
    COMET_CRIT_CHANCE_BUFF_DURATION, 
    COMET_CRIT_CHANCE_BUFF_SCALE, 

    SPECIAL_PLANET_CHANCE_TO_SPAWN_FROZEN, 
    SPECIAL_PLANET_FROZEN_SHARD_MAX_DAMAGE, 
    SPECIAL_PLANET_FROZEN_SHARD_AMOUNT, 

    COMET_CRIT_BONUS_DAMAGE_BUFF_SCALE, 
    SPECIAL_PLANET_FROZEN_SHARD_DISTANCE_SCALE, 

    CHANCE_TO_ADD_TIME_ON_PLANET_DESTROYED, 
    RUN_TIMER_AMOUNT_ON_PLANET_DESTROYED, 
    PLANET_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW, 
    CHANCE_TO_RESPAWN_PLANET_ON_BREAK, 

    SPECIAL_PLANET_ASTEROID_PINATA_SPAWN_CHANCE, 
    SPECIAL_PLANET_ASTEROID_PINATA_AMOUNT_OF_ASTEROID, 

    COMET_MAX_NUMBER_TO_SPAWN, 
    COMET_CHANCE_FOR_COMET_SHOWER, 
    COMET_SHOWER_SIZE, 

    UFO_ELECTRIC_CHARGES_TO_ADD, 
    UFO_SPAWN_CHANCE, 
    UFO_MAX_NUMBER_TO_SPAWN, 

    CHANCE_TO_SPAWN_SPECIAL_ASTEROID_GOLDEN, 
    SPECIAL_ASTEROID_GOLDEN_BONUS_MONEY_SCALE, 
    SPECIAL_ASTEROID_GOLDEN_CRIT_CHANCE, 
    SPECIAL_ASTEROID_GOLDEN_CRIT_BONUS_MONEY_SCALE, 

    CLICK_RATE_BUFF, 
    CLICK_AOE_BUFF, 
    CLICKER_CRIT_CHANCE_BUFF, 
    CLICKER_CRIT_BONUS_BUFF, 

    STAR_DENSITY, 
    CLICKER_BONUS_DAMAGE_TO_STAR, 
    NUMBER_OF_PLANETS_INTO_STARS, 
    MAX_STAR_SIZE, 

    CHANCE_TO_ADD_TIME_ON_STAR_DESTROYED, 
    RUN_TIMER_AMOUNT_ON_STAR_DESTROYED, 
    STAR_PERCENT_TO_RESPAWN_ON_BLACK_HOLE_GROW, 
    CHANCE_TO_RESPAWN_STAR_ON_BREAK, 

    SPECIAL_STAR_LASER_SPAWN_CHANCE, 
    LASER_DAMAGE, 
    LASER_WIDTH_SCALE, 
    LASER_CRIT_CHANCE, 
    LASER_CRIT_BONUS, 

    SPECIAL_STAR_SUPERNOVA_SPAWN_CHANCE, 
    SUPERNOVA_DAMAGE_PERCENT_CURRENT_HEALTH, 
    SUPERNOVA_RADIUS_SCALE, 


    MOON_LIMIT_HARD_CAP, 

    SPECIAL_STAR_FIREBALL_SPAWN_CHANCE, 
    SPECIAL_STAR_MAX_FIREBALLS, 
    FIREBALL_DAMAGE, 
    FIREBALL_MAX_CHAINS, 
    FIREBALL_CHAIN_DISTANCE_SCALE, 

    SPECIAL_STAR_ELECTRIC_DAMAGE, 
    SPECIAL_STAR_ELECTRIC_MAX_CHAINS, 
    SPECIAL_STAR_CHANCE_TO_FORK, 
    SPECIAL_STAR_CHAIN_DISTANCE_SCALE, 
    SPECIAL_STAR_ELECTRIC_CRIT_CHANCE, 
    SPECIAL_STAR_ELECTRIC_CRIT_BONUS, 

    SPECIAL_STAR_CHANCET_TO_SPAWN_ELECTRIC, 


    PLANETS_TO_SPAWN, 
    STARS_TO_SPAWN, 
    CLICKER_ELECTRIC_CLICKS_TO_START_WITH, 

}



enum SPECIAL_TYPES{
    ELECTRIC, 
    RADIOACTIVE, 
    MOONS, 
    FROZEN, 
    PINATA, 
    GOLDEN, 
    SUPERNOVA, 
    LASER, 
    FIREBALL
}

enum GAME_STATES{
    PLAYING, 
    START_OF_SESSION, 
    END_OF_SESSION, 
    UPGRADES, 
    END_OF_TEIR, 
    GAME_OVER, 
    MAIN_MENU, 

}

enum FLOATING_TEXT_TYPES{
    DAMAGE_CLICK, 
    DAMAGE_CRIT, 
    MONEY, 
    GOLDEN_MONEY
}

func orphan(child: Node):
    if child != null and child.get_parent() != null:
        child.get_parent().remove_child(child)



func get_random_point_in_circle(radius) -> Vector2:
    var rand_radius = Global.rng.randf_range(0, radius)
    var angle = Global.rng.randf() * TAU
    var x = cos(angle) * rand_radius
    var y = sin(angle) * rand_radius
    return Vector2(x, y)


func get_random_point_on_a_circle(radius) -> Vector2:
    var angle = Global.rng.randf() * TAU
    var x = cos(angle) * radius
    var y = sin(angle) * radius
    return Vector2(x, y)



func get_node2d_viewport_position(node2d: Node2D, camera):
    return node2d.global_position * camera.zoom + node2d.get_canvas_transform().origin

func get_glob_pos_viewport_position_relative_to_origin(glob_pos, origin, camera):
    return glob_pos * camera.zoom + origin


func get_number_short_text(number: float, intify = true, show_more_decimals = true) -> String:
    var abs_number = abs(number)
    var suffixes: = ["K", "M", "B", "T", "Q"]
    var i: = -1


    if abs_number < 100000.0:
        return str(int(number)) if intify else str(number)


    while abs_number >= 1000.0 and i < suffixes.size() - 1:
        abs_number /= 1000.0
        i += 1


    if i == suffixes.size() - 1 and abs_number >= 1000.0:
        var exponent: = int(log(abs(number)) / log(10))
        var mantissa: = number / pow(10, exponent)
        return "%0.2f" % mantissa + "e" + str(exponent)


    var short_number = snappedf(abs_number, 0.01) if show_more_decimals else snappedf(abs_number, 0.1)
    if number < 0:
        short_number = - short_number

    return "{SHOT_NUM}{SUFFIX}".format({
        "SHOT_NUM": str(short_number), 
        "SUFFIX": suffixes[i]
        })


func load_json_data_from_path(path: String):
    if FileAccess.file_exists(path) == false:
        push_warning("Custom Warning: load_json_data_from_path file does not exist: ", path)
        return null

    var file_string = FileAccess.get_file_as_string(path)
    var json_data
    if file_string != null:
        json_data = JSON.parse_string(file_string)

    else:
        push_warning("Custom Warning: load_json_data_from_path failed get_file_as_string for path: ", path)

    if json_data == null:
        push_warning("Custom Warning: load_json_data_from_path failed to parse file data to JSON for ", path)
        return null

    return json_data


func get_zoom():
    return Global.main.get_traget_camera_zoom().x

func get_zoom_factor():
    return 1.0 / max(Global.main.get_traget_camera_zoom().x, 0.01) if Global.main else 1.0

func get_evenly_spaced_points_on_a_circle(point_count, radius) -> Array[Vector2]:
    var points: Array[Vector2] = []

    var angle_increment = TAU / float(point_count)

    for i in range(point_count):
        var angle = i * angle_increment

        var x = radius * cos(angle)
        var y = radius * sin(angle)

        points.append(Vector2(x, y))

    return points


func format_time(total_seconds: float) -> String:
    var seconds = int(total_seconds) % 60
    var minutes = (int(total_seconds) / 60) % 60
    var hours = (int(total_seconds) / 3600)

    return "%02d:%02d:%02d" % [hours, minutes, seconds]


func get_wave_bbcode(text, amp = 50.0, freq = 5.0):
    return "[wave  amp={AMP} freq={FREQ} connected=1]{TEXT}[/wave]".format({
        "AMP": str(amp), 
        "FREQ": str(freq), 
        "TEXT": tr(text)
    })


func get_raindbow_bbcode(text, freq = 5.0, sat = 0.8, val = 0.8, speed = 0.1):
    return "[rainbow freq={FREQ} sat={SAT} val={VAL} speed={SPEED}]{TEXT}[/rainbow]".format({
        "FREQ": str(freq), 
        "SAT": str(sat), 
        "VAL": str(val), 
        "SPEED": str(speed), 
        "TEXT": tr(text)
    })
