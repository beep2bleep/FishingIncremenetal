extends Node


enum ACHIVEMENTS{
    GROW_BLACK_HOLE, 
    FINISH_A_SESSION, 
    COMPLETE_A_MILESTONE_1, 
    COMPLETE_A_MILESTONE_2, 
    COMPLETE_A_MILESTONE_3, 
    COMPLETE_A_MILESTONE_4, 
    COMPLETE_A_MILESTONE_5, 
    COMPLETE_A_MILESTONE_6, 
    START_RUN_WITH_50_ASTEROIDS, 
    DESTROY_2_ASTEROIDS_AT_ONCE, 
    DESTROY_A_PLANET, 
    DESTROY_A_STAR, 
    HAVE_50_UPGRADES, 
    HAVE_100_UPGRADES, 
    HAVE_150_UPGRADES, 
    HAVE_200_UPGRADES, 
    BEAT_THE_EPILOGUE, 



    MONEY_BAGS_0, 
    MONEY_BAGS_1, 
    MONEY_BAGS_2, 
    MONEY_BAGS_3, 
    MONEY_BAGS_4, 
    MONEY_BAGS_5, 
    MONEY_BAGS_6, 
    MONEY_BAGS_7, 
    TOO_MANY_CLICKS, 
    DESTROY_ALL_OBJECTS


}

var app_id = 3694480
signal steamworks_error

var statistics: Dictionary = {



}
var achievements: Dictionary = {}

func is_steam_deck():
    return false

func _ready():
    for key in ACHIVEMENTS.keys():
        achievements[key] = false

    for mode in Util.GAME_MODES.keys():
        achievements[mode] = false

    initialize_steam()


func initialize_steam() -> void :
    print_debug("Steam integration disabled")
    return


    var initialize_data: Dictionary = Steam.steamInitEx(app_id, true)
    print_debug("Did Steam initialize: %s" % initialize_data)

    if initialize_data["status"] != Steam.STEAM_API_INIT_RESULT_OK:
        print_debug("Failed to initialize Steam. Reason: %s" % initialize_data["verbal"])
        steamworks_error.emit("Failed to initialized Steam! Skillet will now shut down. Check your log files to find out more.")
        return


    load_steam_stats()
    load_steam_achievements()
    print_debug("Finished Steam initialization process")





func load_steam_stats() -> void :
    print_debug("Steam integration disabled - skipping load_steam_stats")
    return


func load_steam_achievements() -> void :
    print_debug("Steam integration disabled - skipping load_steam_achievements")
    return


func set_achievement(achivement, store_now = true) -> bool:
    print_debug("Steam integration disabled - skipping set_achievement: %s" % achivement)
    return false




func set_statistic(this_stat: String, new_value: int = 1) -> void :
    print_debug("Steam integration disabled - skipping set_statistic: %s" % this_stat)
    return


func store_steam_data() -> void :
    print_debug("Steam integration disabled - skipping store_steam_data")
    return
