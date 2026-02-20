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
    return Steam.isSteamRunningOnSteamDeck()

func _ready():
    for key in ACHIVEMENTS.keys():
        achievements[key] = false

    for mode in Util.GAME_MODES.keys():
        achievements[mode] = false

    initialize_steam()


func initialize_steam() -> void :
    if not Engine.has_singleton("Steam"):
        print_debug("This version somehow is missing Steamworks. Shutting down.")
        steamworks_error.emit("This version somehow is missing Steamworks! Check your log files to find out more.")
        return

    if not Steam.isSteamRunning():
        print_debug("Steam is not running. Shutting down.")
        steamworks_error.emit("Steam is not running. Check your log files to find out more.")
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
    for this_stat in statistics.keys():
        var steam_stat: int = Steam.getStatInt(this_stat)

        if statistics[this_stat] > steam_stat:
            print_debug("Stat mismatch; local value is higher (%s), replacing Steam value (%s)" % [statistics[this_stat], steam_stat])
            set_statistic(this_stat, statistics[this_stat])
        elif statistics[this_stat] < steam_stat:
            print_debug("Stat mismatch; local value is lower (%s), replacing with Steam value (%s)" % [statistics[this_stat], steam_stat])
            set_statistic(this_stat, steam_stat)
        else:
            print_debug("Steam stat matches local file: %s" % this_stat)
    print_debug("Steam statistics loaded")


func load_steam_achievements() -> void :
    for key in achievements.keys():


        var steam_achievement: Dictionary = Steam.getAchievement(key)

        if not steam_achievement["ret"]:
            print_debug("Steam does not have this achievement, defaulting to local value: %s" % key)
            continue

        if achievements[key] == steam_achievement["achieved"]:
            print_debug("Steam achievements match local file, skipping: %s" % key)
            continue

        set_achievement(key)
    print_debug("Steam achievements loaded")


func set_achievement(achivement, store_now = true) -> bool:
    var this_achievement = ACHIVEMENTS.find_key(achivement)
    if this_achievement != null:
        achivement = ACHIVEMENTS.find_key(achivement)

    if not achievements.has(achivement):
        print_debug("This achievement does not exist locally: %s" % achivement)
        return false

    if achievements[achivement] == true:
        print_debug("This achievement is already unlocked: %s" % achivement)
        return false

    achievements[achivement] = true

    if not Steam.setAchievement(achivement):
        print_debug("Failed to set achievement: %s" % achivement)
        return false

    print_debug("Set achievement: %s" % achivement)

    if store_now == true:
        store_steam_data()
        return false

    return true




func set_statistic(this_stat: String, new_value: int = 1) -> void :
    if not statistics.has(this_stat):
        print_debug("This statistic does not exist locally: %s" % this_stat)
        return
    statistics[this_stat] += new_value

    if not Steam.setStatInt(this_stat, statistics[this_stat]):
        print_debug("Failed to set stat %s to: %s" % [this_stat, statistics[this_stat]])
        return

    print_debug("Set statistics %s succesfully: %s" % [this_stat, statistics[this_stat]])


func store_steam_data() -> void :
    if not Steam.storeStats():
        print_debug("Failed to store data on Steam, should be stored locally")
    print_debug("Data successfully sent to Steam")
