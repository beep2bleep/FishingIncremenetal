extends Node

const STEAM_VANGUARD_APP_ID := 4519820
const STEAM_VANGUARD_DEMO_APP_ID := 4524190
const STEAM_DEEPCORE_APP_ID := 4562070
const STEAM_DEEPCORE_DEMO_APP_ID := 4615740
const STEAM_BLEEPWARE_INCREMENTALS_APP_ID := 4637560
const STEAM_BLEEPWARE_INCREMENTALS_DEMO_APP_ID := 4642530
const STEAM_BLEEPWARE_INCREMENTALS_STORE_PATH := "BleepWare_Incrementals"
const STEAM_STORE_PATH := "Vanguard__Idle_Auto_Battler"
const LEADERBOARD_LEVEL7_SHARED := "level7_clear_time"
const LEADERBOARD_LEVEL20_FULL := "full_level20_clear_time"
const LEADERBOARD_DEEPCORE_TIME_TO_TIER8 := "DeepcoreTimeToTier8"
const LEADERBOARD_FETCH_COUNT := 5
const LEADERBOARD_AROUND_USER_RADIUS := 2
const OPEN_PIT_PROGRESS_SCRIPT = preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")


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

var app_id = STEAM_VANGUARD_APP_ID
signal steamworks_error
signal leaderboard_data_updated
var steam_enabled: bool = false

var statistics: Dictionary = {



}
var achievements: Dictionary = {}
var leaderboard_handles: Dictionary = {}
var leaderboard_entries: Dictionary = {}
var leaderboard_entries_around_user: Dictionary = {}
var leaderboard_statuses: Dictionary = {}
var leaderboard_entry_counts: Dictionary = {}
var leaderboard_name_to_id: Dictionary = {}
var leaderboard_id_to_name: Dictionary = {}
var leaderboard_pending_submissions: Dictionary = {}
var leaderboard_last_submitted_scores: Dictionary = {}
var leaderboard_last_uploaded_ranks: Dictionary = {}
var _leaderboard_request_queue: Array[String] = []
var _leaderboard_download_queue: Array[Dictionary] = []
var _leaderboard_active_request_id := ""
var _leaderboard_active_download_id := ""
var _leaderboard_active_download_scope := ""
var _leaderboard_active_request_started_msec: int = 0
var _leaderboard_active_download_started_msec: int = 0
var _leaderboard_last_polled_handle: int = 0
var _quit_requested := false
var _steam_shutdown_started := false


func get_store_url() -> String:
    var combined_export_url := "https://store.steampowered.com/app/%s/%s/" % [STEAM_BLEEPWARE_INCREMENTALS_APP_ID, STEAM_BLEEPWARE_INCREMENTALS_STORE_PATH]
    if Util.is_all_high_level_mode_active():
        return combined_export_url
    if Util.is_mining_game_active():
        return "https://store.steampowered.com/app/%s/Deepcore/" % STEAM_DEEPCORE_APP_ID
    return "https://store.steampowered.com/app/%s/%s/" % [_resolve_steam_app_id(), STEAM_STORE_PATH]

func is_steam_deck():
    if OS.has_feature("web"):
        return false

    if not steam_enabled:
        return false

    if not Steam.has_method("isSteamRunningOnSteamDeck"):
        return false

    return bool(Steam.call("isSteamRunningOnSteamDeck"))

func _ready():
    app_id = _resolve_steam_app_id()
    for key in ACHIVEMENTS.keys():
        achievements[key] = false

    for mode in Util.GAME_MODES.keys():
        achievements[mode] = false

    initialize_steam()
    _setup_leaderboard_support()
    set_process(steam_enabled)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        request_app_quit()

func _exit_tree() -> void:
    shutdown_steam()

func request_app_quit() -> void:
    if _quit_requested:
        return

    _quit_requested = true
    shutdown_steam()

    var tree: SceneTree = get_tree()
    if tree != null:
        tree.quit()

func shutdown_steam() -> void:
    if _steam_shutdown_started:
        return

    _steam_shutdown_started = true
    set_process(false)

    if not steam_enabled:
        return

    if Steam.has_method("storeStats"):
        Steam.call("storeStats")

    if Steam.has_method("run_callbacks"):
        Steam.call("run_callbacks")
    elif Steam.has_method("runCallbacks"):
        Steam.call("runCallbacks")

    if Steam.has_method("steamShutdown"):
        Steam.call("steamShutdown")
    elif Steam.has_method("shutdown"):
        Steam.call("shutdown")

    steam_enabled = false


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

func _setup_leaderboard_support() -> void:
    _rebuild_leaderboard_name_maps()
    if not steam_enabled:
        return
    _debug_print_leaderboard_api()
    if Steam.has_signal("leaderboard_find_result") and not Steam.leaderboard_find_result.is_connected(_on_leaderboard_find_result):
        Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
    if Steam.has_signal("leaderboard_scores_downloaded") and not Steam.leaderboard_scores_downloaded.is_connected(_on_leaderboard_scores_downloaded):
        Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
    if Steam.has_signal("leaderboard_score_uploaded") and not Steam.leaderboard_score_uploaded.is_connected(_on_leaderboard_score_uploaded):
        Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
    request_active_fishing_leaderboards()

func _debug_print_leaderboard_api() -> void:
    var signal_names: Array[String] = []
    for signal_data: Dictionary in Steam.get_signal_list():
        var signal_name: String = str(signal_data.get("name", ""))
        if signal_name.to_lower().contains("leaderboard"):
            signal_names.append(signal_name)
    signal_names.sort()
    print("STEAM LEADERBOARD SIGNALS: ", signal_names)

    var method_names: Array[String] = []
    for method_data: Dictionary in Steam.get_method_list():
        var method_name: String = str(method_data.get("name", ""))
        if method_name.to_lower().contains("leaderboard"):
            method_names.append(method_name)
    method_names.sort()
    print("STEAM LEADERBOARD METHODS: ", method_names)

func _rebuild_leaderboard_name_maps() -> void:
    leaderboard_name_to_id.clear()
    leaderboard_id_to_name.clear()
    for config: Dictionary in get_active_fishing_leaderboard_configs():
        var board_id: String = str(config.get("id", ""))
        var board_name: String = str(config.get("steam_name", ""))
        if board_id == "" or board_name == "":
            continue
        leaderboard_name_to_id[board_name] = board_id
        leaderboard_id_to_name[board_id] = board_name

func _is_demo_build() -> bool:
    return bool(ProjectSettings.get_setting("global/Demo", false))

func _resolve_steam_app_id() -> int:
    if Util.is_all_high_level_mode_active():
        if _is_demo_build():
            return STEAM_BLEEPWARE_INCREMENTALS_DEMO_APP_ID
        return STEAM_BLEEPWARE_INCREMENTALS_APP_ID
    if Util.is_mining_game_active():
        if _is_demo_build():
            return STEAM_DEEPCORE_DEMO_APP_ID
        return STEAM_DEEPCORE_APP_ID
    if _is_demo_build():
        return STEAM_VANGUARD_DEMO_APP_ID
    return STEAM_VANGUARD_APP_ID

func get_active_fishing_leaderboard_configs() -> Array[Dictionary]:
    if Util.is_red_sky_game_active() or Util.is_turkey_game_active() or Util.is_reel_into_darkness_game_active():
        return []
    if Util.is_mining_game_active():
        if _is_demo_build():
            return [
                {
                    "id": LEADERBOARD_DEEPCORE_TIME_TO_TIER8,
                    "steam_name": LEADERBOARD_DEEPCORE_TIME_TO_TIER8,
                    "title_key": "DEEPCORE_LEADERBOARD_TIME_TO_TIER8",
                    "description_key": "DEEPCORE_LEADERBOARD_TIME_TO_TIER8_DESC",
                }
            ]
        return []
    if _is_demo_build():
        return [
            {
                "id": LEADERBOARD_LEVEL7_SHARED,
                "steam_name": LEADERBOARD_LEVEL7_SHARED,
                "level": 7,
                "title": "Level 7",
            }
        ]
    return [
        {
            "id": LEADERBOARD_LEVEL7_SHARED,
            "steam_name": LEADERBOARD_LEVEL7_SHARED,
            "level": 7,
            "title": "Level 7",
        },
        {
            "id": LEADERBOARD_LEVEL20_FULL,
            "steam_name": LEADERBOARD_LEVEL20_FULL,
            "level": 20,
            "title": "Level 20",
        }
    ]

func get_cached_leaderboard_entries(board_id: String) -> Array:
    return leaderboard_entries.get(board_id, [])

func get_cached_leaderboard_around_user_entries(board_id: String) -> Array:
    return leaderboard_entries_around_user.get(board_id, [])

func get_cached_leaderboard_status(board_id: String) -> String:
    return str(leaderboard_statuses.get(board_id, "Unavailable"))

func request_active_fishing_leaderboards() -> void:
    _rebuild_leaderboard_name_maps()
    for config: Dictionary in get_active_fishing_leaderboard_configs():
        request_leaderboard(str(config.get("id", "")))

func request_leaderboard(board_id: String) -> void:
    if board_id == "":
        return
    if not steam_enabled:
        leaderboard_statuses[board_id] = "Steam unavailable"
        leaderboard_data_updated.emit()
        return
    if leaderboard_handles.has(board_id):
        _queue_leaderboard_download(board_id, "top")
        _queue_leaderboard_download(board_id, "around_user")
        return
    if _leaderboard_request_queue.has(board_id) or _leaderboard_active_request_id == board_id:
        return
    leaderboard_statuses[board_id] = "Loading..."
    _leaderboard_request_queue.append(board_id)
    _pump_leaderboard_request_queue()
    leaderboard_data_updated.emit()

func _pump_leaderboard_request_queue() -> void:
    if not steam_enabled or _leaderboard_active_request_id != "" or _leaderboard_active_download_id != "" or _leaderboard_request_queue.is_empty():
        return
    _leaderboard_active_request_id = _leaderboard_request_queue.pop_front()
    _leaderboard_active_request_started_msec = Time.get_ticks_msec()
    _leaderboard_last_polled_handle = 0
    var board_name: String = str(leaderboard_id_to_name.get(_leaderboard_active_request_id, ""))
    if board_name == "":
        leaderboard_statuses[_leaderboard_active_request_id] = "Missing name"
        _leaderboard_active_request_id = ""
        _leaderboard_active_request_started_msec = 0
        leaderboard_data_updated.emit()
        return
    if Steam.has_method("set_leaderboard_handle"):
        Steam.call("set_leaderboard_handle", 0)
    if Steam.has_method("findLeaderboard"):
        Steam.call("findLeaderboard", board_name)
    else:
        leaderboard_statuses[_leaderboard_active_request_id] = "findLeaderboard unavailable"
        _leaderboard_active_request_id = ""
        _leaderboard_active_request_started_msec = 0
        leaderboard_data_updated.emit()

func _on_leaderboard_find_result(new_handle: int, was_found: int) -> void:
    var board_id := _leaderboard_active_request_id
    _leaderboard_active_request_id = ""
    _leaderboard_active_request_started_msec = 0
    if board_id == "":
        _pump_leaderboard_request_queue()
        return
    var expected_name: String = str(leaderboard_id_to_name.get(board_id, ""))
    if new_handle != 0 and expected_name != "" and Steam.has_method("getLeaderboardName"):
        var resolved_name: String = str(Steam.call("getLeaderboardName", new_handle))
        if resolved_name != "" and resolved_name != expected_name:
            leaderboard_statuses[board_id] = "Handle mismatch: %s" % resolved_name
            leaderboard_data_updated.emit()
            _pump_leaderboard_request_queue()
            return
    if was_found != 1 or new_handle == 0:
        leaderboard_statuses[board_id] = "Not found"
        leaderboard_data_updated.emit()
        _pump_leaderboard_request_queue()
        return
    leaderboard_handles[board_id] = new_handle
    leaderboard_statuses[board_id] = "Loaded"
    _download_leaderboard_entries(board_id, "top")
    _queue_leaderboard_download(board_id, "around_user")
    _submit_pending_leaderboard_score(board_id)
    leaderboard_data_updated.emit()

func _queue_leaderboard_download(board_id: String, scope: String = "top") -> void:
    if board_id == "":
        return
    if _leaderboard_active_download_id == board_id and _leaderboard_active_download_scope == scope:
        return
    for queued_request_variant: Variant in _leaderboard_download_queue:
        if not (queued_request_variant is Dictionary):
            continue
        var queued_request: Dictionary = queued_request_variant
        if str(queued_request.get("board_id", "")) == board_id and str(queued_request.get("scope", "top")) == scope:
            return
    if _leaderboard_active_download_id != "":
        _leaderboard_download_queue.append({
            "board_id": board_id,
            "scope": scope,
        })
        return
    _download_leaderboard_entries(board_id, scope)

func _pump_leaderboard_download_queue() -> void:
    if _leaderboard_active_download_id != "" or _leaderboard_download_queue.is_empty():
        return
    var next_request_variant: Variant = _leaderboard_download_queue.pop_front()
    if not (next_request_variant is Dictionary):
        return
    var next_request: Dictionary = next_request_variant
    _download_leaderboard_entries(str(next_request.get("board_id", "")), str(next_request.get("scope", "top")))

func _download_leaderboard_entries(board_id: String, scope: String = "top") -> void:
    if not steam_enabled:
        return
    if not leaderboard_handles.has(board_id):
        request_leaderboard(board_id)
        return
    if not Steam.has_method("downloadLeaderboardEntries"):
        leaderboard_statuses[board_id] = "downloadLeaderboardEntries unavailable"
        leaderboard_data_updated.emit()
        return
    if Steam.has_method("set_leaderboard_handle"):
        Steam.call("set_leaderboard_handle", int(leaderboard_handles[board_id]))
    if Steam.has_method("set_leaderboard_entries"):
        Steam.call("set_leaderboard_entries", [])
    if scope == "top" and Steam.has_method("getLeaderboardEntryCount"):
        leaderboard_entry_counts[board_id] = int(Steam.call("getLeaderboardEntryCount", int(leaderboard_handles[board_id])))
    _leaderboard_active_download_id = board_id
    _leaderboard_active_download_scope = scope
    _leaderboard_active_download_started_msec = Time.get_ticks_msec()
    var range_start: int = 1
    var range_end: int = LEADERBOARD_FETCH_COUNT
    var request_type: int = 0
    if scope == "around_user":
        range_start = -LEADERBOARD_AROUND_USER_RADIUS
        range_end = LEADERBOARD_AROUND_USER_RADIUS
        request_type = 1
    Steam.call("downloadLeaderboardEntries", range_start, range_end, request_type, int(leaderboard_handles[board_id]))
    leaderboard_statuses[board_id] = "Refreshing..."
    leaderboard_data_updated.emit()

func _on_leaderboard_scores_downloaded(this_handle: int, these_results: Array) -> void:
    print("LEADERBOARD DOWNLOAD CALLBACK handle=", this_handle, " results=", these_results)
    var board_id := _leaderboard_active_download_id
    var scope := _leaderboard_active_download_scope
    if board_id == "":
        for key: Variant in leaderboard_handles.keys():
            if int(leaderboard_handles[key]) == this_handle:
                board_id = str(key)
                break
    _leaderboard_active_download_id = ""
    _leaderboard_active_download_scope = ""
    _leaderboard_active_download_started_msec = 0
    if board_id == "":
        _pump_leaderboard_download_queue()
        return
    if scope == "around_user":
        leaderboard_entries_around_user[board_id] = these_results
    else:
        leaderboard_entries[board_id] = these_results
        leaderboard_entry_counts[board_id] = max(int(leaderboard_entry_counts.get(board_id, 0)), these_results.size())
    leaderboard_statuses[board_id] = "Loaded"
    leaderboard_data_updated.emit()
    _pump_leaderboard_download_queue()
    _pump_leaderboard_request_queue()

func _on_leaderboard_score_uploaded(_success: int, _handle: int, _score: int, _score_changed: bool, _global_rank_new: int, _global_rank_previous: int) -> void:
    print("LEADERBOARD UPLOAD CALLBACK success=", _success, " handle=", _handle, " score=", _score, " changed=", _score_changed, " new_rank=", _global_rank_new, " prev_rank=", _global_rank_previous)
    for key: Variant in leaderboard_handles.keys():
        if int(leaderboard_handles[key]) == _handle:
            leaderboard_statuses[str(key)] = "Submitted"
            leaderboard_last_uploaded_ranks[str(key)] = int(_global_rank_new)
            _queue_leaderboard_download(str(key), "top")
            _queue_leaderboard_download(str(key), "around_user")
            break
    leaderboard_data_updated.emit()

func submit_fishing_boss_clear_time(level: int, clear_time_seconds: float) -> void:
    var board_id := _get_leaderboard_id_for_level(level)
    if board_id == "" or clear_time_seconds < 0.0:
        return
    _submit_fishing_boss_clear_time_to_board(board_id, clear_time_seconds)

func submit_level7_clear_time(clear_time_seconds: float) -> void:
    _submit_fishing_boss_clear_time_to_board(LEADERBOARD_LEVEL7_SHARED, clear_time_seconds)

func submit_level20_clear_time(clear_time_seconds: float) -> void:
    _submit_fishing_boss_clear_time_to_board(LEADERBOARD_LEVEL20_FULL, clear_time_seconds)

func submit_deepcore_tier8_time(clear_time_seconds: float) -> void:
    _submit_fishing_boss_clear_time_to_board(LEADERBOARD_DEEPCORE_TIME_TO_TIER8, clear_time_seconds)

func _submit_fishing_boss_clear_time_to_board(board_id: String, clear_time_seconds: float) -> void:
    if board_id == "" or clear_time_seconds < 0.0:
        return
    var score: int = maxi(1, int(round(clear_time_seconds * 1000.0)))
    leaderboard_pending_submissions[board_id] = score
    leaderboard_last_submitted_scores[board_id] = score
    leaderboard_statuses[board_id] = "Submitted"
    if not steam_enabled:
        leaderboard_statuses[board_id] = "Steam unavailable"
        leaderboard_data_updated.emit()
        return
    if not leaderboard_handles.has(board_id):
        request_leaderboard(board_id)
        return
    _submit_pending_leaderboard_score(board_id)

func _submit_pending_leaderboard_score(board_id: String) -> void:
    if not steam_enabled or not leaderboard_pending_submissions.has(board_id):
        return
    if Util.is_open_pit_game_active() and not OPEN_PIT_PROGRESS_SCRIPT.can_write_leaderboards():
        leaderboard_pending_submissions.erase(board_id)
        leaderboard_statuses[board_id] = "Editor assists used"
        leaderboard_data_updated.emit()
        return
    if not leaderboard_handles.has(board_id):
        request_leaderboard(board_id)
        return
    if not Steam.has_method("uploadLeaderboardScore"):
        leaderboard_statuses[board_id] = "uploadLeaderboardScore unavailable"
        leaderboard_data_updated.emit()
        return
    var score: int = int(leaderboard_pending_submissions[board_id])
    Steam.call("uploadLeaderboardScore", score, true, PackedInt32Array(), int(leaderboard_handles[board_id]))
    leaderboard_pending_submissions.erase(board_id)
    _queue_leaderboard_download(board_id, "top")
    _queue_leaderboard_download(board_id, "around_user")

func _get_leaderboard_id_for_level(level: int) -> String:
    for config: Dictionary in get_active_fishing_leaderboard_configs():
        if int(config.get("level", -1)) == level:
            return str(config.get("id", ""))
    return ""

func get_cached_leaderboard_last_submitted_score(board_id: String) -> int:
    return int(leaderboard_last_submitted_scores.get(board_id, -1))

func get_cached_leaderboard_display_entries(board_id: String) -> Array:
    var entries: Array = get_cached_leaderboard_entries(board_id)
    if not entries.is_empty():
        return entries
    var entry_count: int = int(leaderboard_entry_counts.get(board_id, -1))
    var submitted_score: int = get_cached_leaderboard_last_submitted_score(board_id)
    if entry_count > 0 and submitted_score >= 0:
        var persona_name := "Player"
        if steam_enabled and Steam.has_method("getPersonaName"):
            var resolved_name: String = str(Steam.call("getPersonaName")).strip_edges()
            if resolved_name != "":
                persona_name = resolved_name
        return [{
            "rank": 1 if entry_count == 1 else 0,
            "name": persona_name,
            "score": submitted_score,
        }]
    return []

func get_cached_leaderboard_around_user_display_entries(board_id: String) -> Array:
    var entries: Array = get_cached_leaderboard_around_user_entries(board_id)
    if not entries.is_empty():
        return entries
    var submitted_score: int = get_cached_leaderboard_last_submitted_score(board_id)
    if submitted_score < 0:
        return []
    var fallback_rank: int = int(leaderboard_last_uploaded_ranks.get(board_id, 0))
    var persona_name := "Player"
    if steam_enabled and Steam.has_method("getPersonaName"):
        var resolved_name: String = str(Steam.call("getPersonaName")).strip_edges()
        if resolved_name != "":
            persona_name = resolved_name
    return [{
        "rank": fallback_rank,
        "name": persona_name,
        "score": submitted_score,
    }]

func get_leaderboard_entry_rank(entry: Dictionary, fallback_rank: int = 0) -> int:
    for key in ["global_rank", "rank", "globalRank", "globalrank"]:
        if entry.has(key):
            return int(entry.get(key, fallback_rank))
    return fallback_rank

func get_leaderboard_entry_display_name(entry: Dictionary) -> String:
    for key in ["name", "persona_name", "steam_name", "persona", "player_name"]:
        var value: String = str(entry.get(key, "")).strip_edges()
        if value != "":
            return value

    var steam_id: int = 0
    for key in ["steam_id", "steamID", "user", "user_id", "steam_id_user"]:
        if entry.has(key):
            steam_id = int(entry.get(key, 0))
            if steam_id != 0:
                break

    if steam_id != 0:
        if Steam.has_method("getFriendPersonaName"):
            var friend_name: String = str(Steam.call("getFriendPersonaName", steam_id)).strip_edges()
            if friend_name != "":
                return friend_name
        if Steam.has_method("getPersonaName"):
            var own_name: String = str(Steam.call("getPersonaName")).strip_edges()
            if own_name != "":
                return own_name

    return "Player"




func _process(_delta):
    if steam_enabled:
        if Steam.has_method("run_callbacks"):
            Steam.call("run_callbacks")
        elif Steam.has_method("runCallbacks"):
            Steam.call("runCallbacks")
        _poll_leaderboard_fallbacks()

func _poll_leaderboard_fallbacks() -> void:
    if _leaderboard_active_request_id != "" and Steam.has_method("get_leaderboard_handle"):
        var polled_handle: int = int(Steam.call("get_leaderboard_handle"))
        if polled_handle != 0:
            var expected_name: String = str(leaderboard_id_to_name.get(_leaderboard_active_request_id, ""))
            var resolved_name: String = ""
            if Steam.has_method("getLeaderboardName"):
                resolved_name = str(Steam.call("getLeaderboardName", polled_handle))
            if resolved_name != "" and expected_name != "" and resolved_name == expected_name and polled_handle != _leaderboard_last_polled_handle:
                _leaderboard_last_polled_handle = polled_handle
                _on_leaderboard_find_result(polled_handle, 1)
                return
        if _leaderboard_active_request_started_msec > 0 and Time.get_ticks_msec() - _leaderboard_active_request_started_msec > 4000:
            leaderboard_statuses[_leaderboard_active_request_id] = "Find timed out"
            _leaderboard_active_request_id = ""
            _leaderboard_active_request_started_msec = 0
            leaderboard_data_updated.emit()
            _pump_leaderboard_request_queue()
            return

    if _leaderboard_active_download_id != "" and Steam.has_method("get_leaderboard_entries"):
        var polled_entries: Variant = Steam.call("get_leaderboard_entries")
        if polled_entries is Array:
            var entries: Array = polled_entries
            if not entries.is_empty():
                _on_leaderboard_scores_downloaded(int(leaderboard_handles.get(_leaderboard_active_download_id, 0)), entries)
                return
            var expected_handle: int = int(leaderboard_handles.get(_leaderboard_active_download_id, 0))
            var entry_count: int = -1
            if _leaderboard_active_download_scope == "top" and expected_handle != 0 and Steam.has_method("getLeaderboardEntryCount"):
                entry_count = int(Steam.call("getLeaderboardEntryCount", expected_handle))
            if (entry_count == 0 or _leaderboard_active_download_scope == "around_user") and _leaderboard_active_download_started_msec > 0 and Time.get_ticks_msec() - _leaderboard_active_download_started_msec > 1000:
                _on_leaderboard_scores_downloaded(expected_handle, entries)
                return
        if _leaderboard_active_download_started_msec > 0 and Time.get_ticks_msec() - _leaderboard_active_download_started_msec > 5000:
            if _leaderboard_active_download_scope == "around_user":
                leaderboard_entries_around_user[_leaderboard_active_download_id] = []
            else:
                leaderboard_entries[_leaderboard_active_download_id] = []
            leaderboard_statuses[_leaderboard_active_download_id] = "Download timed out"
            _leaderboard_active_download_id = ""
            _leaderboard_active_download_scope = ""
            _leaderboard_active_download_started_msec = 0
            leaderboard_data_updated.emit()
            _pump_leaderboard_download_queue()
            _pump_leaderboard_request_queue()


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
