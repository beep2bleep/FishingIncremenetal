extends Node

const API_BASE := "https://api.gameanalytics.com"
const API_VERSION := 2
const SDK_VERSION := "rest api v2"
const STATE_PATH := "user://gameanalytics_state.cfg"

var _game_key := ""
var _secret_key := ""
var _build := "dev"
var _info_log := false
var _enabled := false

var _user_id := ""
var _session_id := ""
var _session_num := 0
var _server_ts_offset := 0

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
    _game_key = str(ProjectSettings.get_setting("gameanalytics/game_key", ""))
    _secret_key = str(ProjectSettings.get_setting("gameanalytics/secret_key", ""))
    _platform = _detect_platform()
    _os_version = "%s %s" % [_platform, str(OS.get_version())]
    _manufacturer = "unknown"
    _device = str(OS.get_model_name())
    if _device == "":
        _device = "desktop"

    if _game_key == "" or _secret_key == "":
        push_warning("GameAnalyticsManager: missing gameanalytics/game_key or gameanalytics/secret_key in ProjectSettings.")
        return

    _enabled = true
    if _info_log:
        print("GameAnalyticsManager: initialized platform=%s build=%s" % [_platform, _build])
    _load_or_create_state()
    _start_session()

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
    var event_id: String = str(options.get("eventId", ""))
    if event_id == "":
        return

    var event: Dictionary = _base_event_payload("design")
    event["event_id"] = event_id

    var value: Variant = options.get("value", null)
    if value is int or value is float:
        event["value"] = float(value)

    var custom_fields_json: String = str(options.get("customFields", ""))
    if custom_fields_json != "":
        var parsed: Variant = JSON.parse_string(custom_fields_json)
        if parsed is Dictionary:
            var custom_fields: Dictionary = _sanitize_custom_fields(parsed as Dictionary)
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
    return {
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

func _client_ts() -> int:
    return int(Time.get_unix_time_from_system()) + _server_ts_offset

func _auth_header(body: String) -> String:
    var crypto := Crypto.new()
    var key_bytes: PackedByteArray = _secret_key.to_utf8_buffer()
    var body_bytes: PackedByteArray = body.to_utf8_buffer()
    var digest: PackedByteArray = crypto.hmac_digest(HashingContext.HASH_SHA256, key_bytes, body_bytes)
    return Marshalls.raw_to_base64(digest)

func _sanitize_custom_fields(fields: Dictionary) -> Dictionary:
    var output: Dictionary = {}
    for key_variant in fields.keys():
        var key: String = str(key_variant)
        if key == "":
            continue
        var value: Variant = fields[key_variant]
        if value is String or value is int or value is float or value is bool:
            output[key] = value
    return output

func _load_or_create_state() -> void:
    var cfg := ConfigFile.new()
    var err: int = cfg.load(STATE_PATH)
    if err == OK:
        _user_id = str(cfg.get_value("ga", "user_id", ""))
        _session_num = int(cfg.get_value("ga", "session_num", 0))
    if _user_id == "":
        _user_id = _new_uuid_v4()
    _session_num = maxi(0, _session_num) + 1
    _session_id = _new_uuid_v4()
    _save_state()

func _save_state() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("ga", "user_id", _user_id)
    cfg.set_value("ga", "session_num", _session_num)
    cfg.save(STATE_PATH)

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
