extends Node

const API_BASE := "https://api.gameanalytics.com"
const API_VERSION := 2
const SDK_VERSION := "rest api v2"
const STATE_PATH_TEMPLATE := "user://gameanalytics_state_%s.cfg"
const MINING_GAME_KEY := "b8a2581219b15c0021b5b3a16949645f"
const MINING_SECRET_KEY := "fd45f4799dbac827b520bd9963deaa6cc8bad0b0"
const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")
const RED_SKY_GAME_KEY := "12617c1402467d51b3ce07143b20ea50"
const RED_SKY_SECRET_KEY := "6249954fe53e2f5438c7354d9093045fdf47be4c"
const RED_SKY_PROGRESS_SCRIPT = preload("res://Games/RedSkyDefense/RedSkyProgress.gd")
const PROGRESSION_STATUS_MAP := {
    "start": "Start",
    "complete": "Complete",
    "fail": "Fail",
}

var _game_key := ""
var _secret_key := ""
var _build := "dev"
var _info_log := false
var _enabled := false
var _configured_game_id := ""
var _default_vanguard_game_key := ""
var _default_vanguard_secret_key := ""

var _user_id := ""
var _session_id := ""
var _session_num := 0
var _server_ts_offset := 0
var _first_game_start_sent := false

var _platform := "windows"
var _os_version := ""
var _manufacturer := "unknown"
var _device := "desktop"

var _http: HTTPRequest
var _pending: Array[Dictionary] = []
var _request_in_flight := false
var _init_done := false

func _ready() -> void:
    _http = HTTPRequest.new()
    _http.timeout = 10.0
    add_child(_http)
    _http.request_completed.connect(_on_request_completed)

    _build = str(ProjectSettings.get_setting("gameanalytics/build", "dev"))
    _info_log = bool(ProjectSettings.get_setting("gameanalytics/info_log", OS.is_debug_build()))
    _default_vanguard_game_key = str(ProjectSettings.get_setting("gameanalytics/game_key", ""))
    _default_vanguard_secret_key = str(ProjectSettings.get_setting("gameanalytics/secret_key", ""))
    _platform = _detect_platform()
    _os_version = "%s %s" % [_platform, str(OS.get_version())]
    _manufacturer = "unknown"
    _device = str(OS.get_model_name())
    if _device == "":
        _device = "desktop"

    if _info_log:
        print("GameAnalyticsManager: initialized platform=%s build=%s" % [_platform, _build])
    if not _should_defer_initial_session():
        refresh_active_game_session()

func configureBuild(build: String) -> void:
    _build = build

func setEnabledInfoLog(flag: bool) -> void:
    _info_log = flag

func init(game_key: String, secret_key: String) -> void:
    _game_key = game_key
    _secret_key = secret_key
    if _game_key != "" and _secret_key != "":
        _enabled = true
        _start_session()

func addDesignEvent(options: Dictionary) -> void:
    refresh_active_game_session()
    var event_id: String = str(options.get("eventId", ""))
    if event_id == "":
        return

    var event: Dictionary = _base_event_payload("design")
    event["event_id"] = event_id

    var value: Variant = options.get("value", null)
    if value is int or value is float:
        event["value"] = float(value)

    var custom_fields: Dictionary = _read_custom_fields(options)
    if not custom_fields.is_empty():
        event["custom_fields"] = custom_fields

    _enqueue_event(event)

func addProgressionEvent(options: Dictionary) -> void:
    refresh_active_game_session()
    var progression_status_raw: String = str(options.get("progressionStatus", "")).strip_edges().to_lower()
    var progression_status: String = str(PROGRESSION_STATUS_MAP.get(progression_status_raw, ""))
    if progression_status == "":
        return

    var event_id_parts: Array[String] = [progression_status]
    for key in ["progression01", "progression02", "progression03"]:
        var value: String = str(options.get(key, "")).strip_edges()
        if value != "":
            event_id_parts.append(value)

    if event_id_parts.size() < 2:
        return

    var event: Dictionary = _base_event_payload("progression")
    event["event_id"] = ":".join(event_id_parts)

    var attempt_num: int = int(options.get("attemptNum", 0))
    if attempt_num > 0 and progression_status != PROGRESSION_STATUS_MAP["start"]:
        event["attempt_num"] = attempt_num

    var score: Variant = options.get("score", null)
    if score is int or score is float:
        event["score"] = int(round(float(score)))

    var custom_fields: Dictionary = _read_custom_fields(options)
    if not custom_fields.is_empty():
        event["custom_fields"] = custom_fields

    _enqueue_event(event)

func track_design_event(event_id: String, value: Variant = null, custom_fields: Dictionary = {}) -> void:
    var options: Dictionary = {
        "eventId": event_id
    }
    if value is int or value is float:
        options["value"] = value
    if not custom_fields.is_empty():
        options["customFields"] = JSON.stringify(custom_fields)
    addDesignEvent(options)

func track_progression_event(status: String, progression01: String, progression02: String = "", progression03: String = "", score: Variant = null, custom_fields: Dictionary = {}, attempt_num: int = 0) -> void:
    var options: Dictionary = {
        "progressionStatus": status,
        "progression01": progression01,
        "progression02": progression02,
        "progression03": progression03,
    }
    if score is int or score is float:
        options["score"] = int(round(float(score)))
    if not custom_fields.is_empty():
        options["customFields"] = JSON.stringify(custom_fields)
    if attempt_num > 0:
        options["attemptNum"] = attempt_num
    addProgressionEvent(options)

func refresh_active_game_session(force_restart: bool = false) -> void:
    var credentials: Dictionary = _get_active_credentials()
    var game_id: String = str(credentials.get("game_id", Util.ACTIVE_GAME_VANGUARD))
    var game_key: String = str(credentials.get("game_key", ""))
    var secret_key: String = str(credentials.get("secret_key", ""))
    if game_key == "" or secret_key == "":
        _enabled = false
        push_warning("GameAnalyticsManager: missing analytics credentials for active game '%s'." % game_id)
        return
    if not force_restart and _enabled and _configured_game_id == game_id and _session_id != "":
        return

    _configured_game_id = game_id
    _game_key = game_key
    _secret_key = secret_key
    _enabled = true
    _pending.clear()
    _request_in_flight = false
    _init_done = false
    _server_ts_offset = 0
    _user_id = ""
    _session_id = ""
    _session_num = 0
    _first_game_start_sent = false
    _load_or_create_state()
    _start_session()

func _start_session() -> void:
    if not _enabled:
        return
    if _user_id == "":
        _load_or_create_state()
    if _session_id == "":
        _session_id = _new_uuid_v4()
    if _session_num <= 0:
        _session_num = 1
    _save_state()
    _send_init()
    _send_user_start_event()
    _send_first_game_start_event()
    _send_active_game_progression_start_event()

func _send_init() -> void:
    var payload: Dictionary = {
        "user_id": _user_id,
        "sdk_version": SDK_VERSION,
        "os_version": _os_version,
        "platform": _platform,
        "build": _build,
        "session_num": _session_num
    }
    _send_request("/v2/%s/init" % _game_key, payload, true)

func _send_user_start_event() -> void:
    var user_event: Dictionary = _base_event_payload("user")
    _enqueue_event(user_event)

func _send_first_game_start_event() -> void:
    if _first_game_start_sent:
        return
    _first_game_start_sent = true
    _save_state()
    track_design_event("game:first_start")

func _send_active_game_progression_start_event() -> void:
    if not _enabled:
        return
    if Util.is_mining_game_active():
        var mining_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
        var player_level: int = max(1, int(mining_data.get("player_level", 1)))
        track_progression_event(
            "start",
            Util.ACTIVE_GAME_MINING,
            "player_level",
            "level_%d" % player_level,
            null,
            {
                "player_level": player_level,
                "total_xp": int(mining_data.get("xp", 0)),
            }
        )
        return
    if Util.is_red_sky_game_active():
        var rs_data: Dictionary = RED_SKY_PROGRESS_SCRIPT.load_data()
        var best_wave: int = max(0, int(rs_data.get("best_wave", 0)))
        var profile_wave: int = maxi(1, best_wave)
        track_progression_event(
            "start",
            Util.ACTIVE_GAME_RED_SKY,
            "profile",
            "wave_%d" % profile_wave,
            null,
            {
                "best_wave": best_wave,
                "selected_start_wave": int(RED_SKY_PROGRESS_SCRIPT.get_selected_start_wave(rs_data)),
                "runs": int(rs_data.get("runs", 0)),
                "total_waves_cleared": int(rs_data.get("total_waves_cleared", 0)),
            }
        )
        return
    if Util.is_turkey_game_active():
        track_progression_event(
            "start",
            Util.ACTIVE_GAME_TURKEY,
            "frame",
            "frame_1",
            null,
            {
                "frame": 1,
            }
        )
        return
    if Util.is_reel_into_darkness_game_active():
        track_progression_event(
            "start",
            Util.ACTIVE_GAME_REEL_INTO_DARKNESS,
            "run",
            "dock",
            null,
            {
                "run": 1,
            }
        )
        return
    var battle_level: int = max(1, int(SaveHandler.fishing_next_battle_level))
    track_progression_event(
        "start",
        Util.ACTIVE_GAME_VANGUARD,
        "battle",
        "level_%d" % battle_level,
        null,
        {
            "battle_level": battle_level,
            "max_unlocked_level": int(SaveHandler.fishing_max_unlocked_battle_level),
        }
    )

func _enqueue_event(event: Dictionary) -> void:
    if not _enabled:
        return
    _pending.append(event)
    _pump_queue()

func _pump_queue() -> void:
    if _request_in_flight:
        return
    if _pending.is_empty():
        return
    var batch := _pending.duplicate(true)
    _pending.clear()
    _send_request("/v2/%s/events" % _game_key, batch, false)

func _send_request(path: String, payload: Variant, is_init: bool) -> void:
    if not _enabled:
        return
    if _request_in_flight:
        return

    var body: String = JSON.stringify(payload)
    var auth: String = _auth_header(body)
    var headers := PackedStringArray([
        "Content-Type: application/json",
        "Authorization: %s" % auth
    ])

    var err: int = _http.request(API_BASE + path, headers, HTTPClient.METHOD_POST, body)
    if err != OK:
        if _info_log:
            push_warning("GameAnalyticsManager: request failed to start. code=%d path=%s" % [err, path])
        _request_in_flight = false
        return

    _request_in_flight = true
    set_meta("ga_last_is_init", is_init)
    set_meta("ga_last_path", path)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    _request_in_flight = false
    var is_init: bool = bool(get_meta("ga_last_is_init", false))
    var path: String = str(get_meta("ga_last_path", ""))
    var text: String = body.get_string_from_utf8()
    if _info_log:
        print("GameAnalyticsManager: response code=%d path=%s" % [response_code, path])
        if response_code < 200 or response_code >= 300:
            print("GameAnalyticsManager: response body=%s" % text)

    if is_init:
        var parsed: Variant = JSON.parse_string(text)
        if parsed is Dictionary and (parsed as Dictionary).has("server_ts"):
            var server_ts: int = int((parsed as Dictionary).get("server_ts", 0))
            if server_ts > 0:
                _server_ts_offset = server_ts - int(Time.get_unix_time_from_system())
        _init_done = (response_code >= 200 and response_code < 300)

    _pump_queue()

func _base_event_payload(category: String) -> Dictionary:
    var payload := {
        "category": category,
        "v": API_VERSION,
        "user_id": _user_id,
        "client_ts": _client_ts(),
        "sdk_version": SDK_VERSION,
        "os_version": _os_version,
        "manufacturer": _manufacturer,
        "device": _device,
        "platform": _platform,
        "session_id": _session_id,
        "session_num": _session_num,
        "build": _build
    }
    payload["custom_fields"] = _default_custom_fields()
    return payload

func _client_ts() -> int:
    return int(Time.get_unix_time_from_system()) + _server_ts_offset

func _auth_header(body: String) -> String:
    var crypto := Crypto.new()
    var key_bytes: PackedByteArray = _secret_key.to_utf8_buffer()
    var body_bytes: PackedByteArray = body.to_utf8_buffer()
    var digest: PackedByteArray = crypto.hmac_digest(HashingContext.HASH_SHA256, key_bytes, body_bytes)
    return Marshalls.raw_to_base64(digest)

func _sanitize_custom_fields(fields: Dictionary) -> Dictionary:
    var output: Dictionary = _default_custom_fields()
    for key_variant in fields.keys():
        var key: String = str(key_variant)
        if key == "":
            continue
        var value: Variant = fields[key_variant]
        if value is String or value is int or value is float or value is bool:
            output[key] = value
    return output

func _read_custom_fields(options: Dictionary) -> Dictionary:
    var custom_fields_json: String = str(options.get("customFields", ""))
    if custom_fields_json == "":
        return _default_custom_fields()
    var parsed: Variant = JSON.parse_string(custom_fields_json)
    if parsed is Dictionary:
        return _sanitize_custom_fields(parsed as Dictionary)
    return _default_custom_fields()

func _default_custom_fields() -> Dictionary:
    return {
        "active_game": Util.get_active_game_id()
    }

func _load_or_create_state() -> void:
    var cfg := ConfigFile.new()
    var err: int = cfg.load(_get_state_path())
    if err == OK:
        _user_id = str(cfg.get_value("ga", "user_id", ""))
        _session_num = int(cfg.get_value("ga", "session_num", 0))
        _first_game_start_sent = bool(cfg.get_value("ga", "first_game_start_sent", false))
    if _user_id == "":
        _user_id = _new_uuid_v4()
    _session_num = maxi(0, _session_num) + 1
    _session_id = _new_uuid_v4()
    _save_state()

func _save_state() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("ga", "user_id", _user_id)
    cfg.set_value("ga", "session_num", _session_num)
    cfg.set_value("ga", "first_game_start_sent", _first_game_start_sent)
    cfg.save(_get_state_path())

func _get_state_path() -> String:
    var game_id: String = _configured_game_id
    if game_id == "":
        game_id = Util.get_active_game_id()
    return STATE_PATH_TEMPLATE % game_id

func _get_active_credentials() -> Dictionary:
    if Util.is_mining_game_active():
        return {
            "game_id": Util.ACTIVE_GAME_MINING,
            "game_key": MINING_GAME_KEY,
            "secret_key": MINING_SECRET_KEY,
        }
    if Util.is_red_sky_game_active():
        return {
            "game_id": Util.ACTIVE_GAME_RED_SKY,
            "game_key": RED_SKY_GAME_KEY,
            "secret_key": RED_SKY_SECRET_KEY,
        }
    if Util.is_turkey_game_active():
        return {
            "game_id": Util.ACTIVE_GAME_TURKEY,
            "game_key": _default_vanguard_game_key,
            "secret_key": _default_vanguard_secret_key,
        }
    if Util.is_reel_into_darkness_game_active():
        return {
            "game_id": Util.ACTIVE_GAME_REEL_INTO_DARKNESS,
            "game_key": _default_vanguard_game_key,
            "secret_key": _default_vanguard_secret_key,
        }
    return {
        "game_id": Util.ACTIVE_GAME_VANGUARD,
        "game_key": _default_vanguard_game_key,
        "secret_key": _default_vanguard_secret_key,
    }

func _should_defer_initial_session() -> bool:
    return Util.get_configured_start_scene_path() == Util.PATH_GAME_LAUNCHER

func _new_uuid_v4() -> String:
    var crypto := Crypto.new()
    var bytes: PackedByteArray = crypto.generate_random_bytes(16)
    if bytes.size() != 16:
        return str(Time.get_unix_time_from_system()) + "-" + str(randi())
    bytes[6] = (bytes[6] & 0x0F) | 0x40
    bytes[8] = (bytes[8] & 0x3F) | 0x80
    var hex := ""
    for b in bytes:
        hex += "%02x" % int(b)
    return "%s-%s-%s-%s-%s" % [
        hex.substr(0, 8),
        hex.substr(8, 4),
        hex.substr(12, 4),
        hex.substr(16, 4),
        hex.substr(20, 12)
    ]

func _detect_platform() -> String:
    match OS.get_name():
        "Windows":
            return "windows"
        "Linux", "FreeBSD", "NetBSD", "OpenBSD":
            return "linux"
        "macOS":
            return "mac_osx"
        "Android":
            return "android"
        "iOS":
            return "ios"
        _:
            return "windows"
