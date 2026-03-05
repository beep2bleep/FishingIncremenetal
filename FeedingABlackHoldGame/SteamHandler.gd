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
var steam_enabled: bool = false

var statistics: Dictionary = {



}
var achievements: Dictionary = {}

func is_steam_deck():
    if not steam_enabled:
        return false

    if not Steam.has_method("isSteamRunningOnSteamDeck"):
        return false

    return bool(Steam.call("isSteamRunningOnSteamDeck"))

func _ready():
    for key in ACHIVEMENTS.keys():
        achievements[key] = false

    for mode in Util.GAME_MODES.keys():
        achievements[mode] = false

    initialize_steam()
    set_process(steam_enabled)


func initialize_steam() -> void :
    if OS.has_feature("web"):
        print_debug("Steam integration disabled on Web export")
        steam_enabled = false
        return

    if not Engine.has_singleton("Steam") and not ClassDB.class_exists("Steam"):
        print_debug("Steam API not available; Steam integration disabled")
        steam_enabled = false
        return

    var initialize_data: Dictionary = Steam.call("steamInitEx", app_id, true)
    print_debug("Did Steam initialize: %s" % initialize_data)

    if initialize_data.get("status") != Steam.STEAM_API_INIT_RESULT_OK:
        print_debug("Failed to initialize Steam. Reason: %s" % initialize_data.get("verbal", "unknown"))
        steamworks_error.emit("Failed to initialized Steam! Skillet will now shut down. Check your log files to find out more.")
        steam_enabled = false
        return

    steam_enabled = true
    load_steam_stats()
    load_steam_achievements()
    print_debug("Finished Steam initialization process")




func _process(_delta):
    if steam_enabled:
        if Steam.has_method("run_callbacks"):
            Steam.call("run_callbacks")
        elif Steam.has_method("runCallbacks"):
            Steam.call("runCallbacks")


func _achievement_to_name(achievement) -> String:
    if achievement is int:
        var enum_name = ACHIVEMENTS.find_key(achievement)
        if enum_name != null:
            return str(enum_name)
    return str(achievement)


func load_steam_stats() -> void :
    if not steam_enabled:
        print_debug("Steam integration disabled - skipping load_steam_stats")
        return

    if Steam.has_method("requestCurrentStats"):
        Steam.call("requestCurrentStats")


func load_steam_achievements() -> void :
    if not steam_enabled:
        print_debug("Steam integration disabled - skipping load_steam_achievements")
        return

    for key in achievements.keys():
        if Steam.has_method("getAchievement"):
            var data = Steam.call("getAchievement", str(key))
            if data is Dictionary and data.has("achieved"):
                achievements[key] = data["achieved"]
            elif data is Array and data.size() > 0:
                achievements[key] = data[0]


func set_achievement(achivement, store_now = true) -> bool:
    if not steam_enabled:
        print_debug("Steam integration disabled - skipping set_achievement: %s" % achivement)
        return false

    var achivement_name := _achievement_to_name(achivement)
    if not achievements.has(achivement_name):
        achievements[achivement_name] = false

    if achievements[achivement_name] == true:
        return false

    var success := false
    if Steam.has_method("setAchievement"):
        success = bool(Steam.call("setAchievement", achivement_name))

    if success:
        achievements[achivement_name] = true
        if store_now:
            store_steam_data()

    return success




func set_statistic(this_stat: String, new_value: int = 1) -> void :
    if not steam_enabled:
        print_debug("Steam integration disabled - skipping set_statistic: %s" % this_stat)
        return

    statistics[this_stat] = new_value
    if Steam.has_method("setStatInt"):
        Steam.call("setStatInt", this_stat, new_value)


func store_steam_data() -> void :
    if not steam_enabled:
        print_debug("Steam integration disabled - skipping store_steam_data")
        return

    if Steam.has_method("storeStats"):
        Steam.call("storeStats")
