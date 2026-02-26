extends Node

enum SCREEN_MODES{FULL_SCREEN, WINDOWED, BORDERLESS, BORDERLESS_FULL_SCREEN}

var supported_locales = {
    "en": "English", 
    "es": "Español", 
    "de": "Deutsch", 
    "pt": "Português", 
    "fr": "Français", 
    "it": "Italiano", 
    "zh": "简体中文", 
    "ja": "日本語", 
    "ko": "한국어", 
    "ru": "Русский", 
    "pl": "Polski", 
    "tr": "Türkçe", 
    "th": "ไทย", 
    "id": "Bahasa Indonesia", 
    "cs": "Čeština", 
    "ca": "Català", 
    "vi": "Tiếng Việt", 
}

func _ready():
    print("Save Handler _ready()")

    load_local_settings()

    load_progression_data()
    load_fishing_progress()

    if has_shown_pick_locale_first_time == false:
        if supported_locales.has(OS.get_locale_language()):
            update_locale(OS.get_locale_language())


    TranslationServer.set_locale(locale)
    Engine.max_fps = fps_limit
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveHandler.vsync_enabled else DisplayServer.VSYNC_DISABLED)
    Refs.pallet = load(Util.dark_pallet if dark_mode else Util.light_pallet)

    set_audio()


func set_audio():
    AudioServer.set_bus_volume_db(0, main_volume)
    AudioServer.set_bus_volume_db(1, music_volume)
    AudioServer.set_bus_volume_db(2, effect_volume)





var player_last_run_file_location = "user://"

var money: int
var comet_show_session_cooldown: int
var upgrades_unlocked_upgrades = {}
var upgrades_in_use_mods = []
var current_tier = 0
var tier_stats = {
    "total_damage_this_tier": 0.0, 
    "total_objects_destoryed_this_tier": 0.0, 
    "total_money_earned_this_teir": 0.0, 
    "session_this_tier": 0.0, 
}
var epilogue = false
var run_time = 0.0
var audio_run_plays = []

func _get_active_save_file_name() -> String:
    if Global.current_game_mode_data != null:
        return Global.current_game_mode_data.get_save_file_name()
    return "main_cloud_file.save"

func has_old_save_data():
    return money != 0 and upgrades_unlocked_upgrades.keys().size() > 0


func has_save_data_for_game_mode_data(game_mode_data: GameModeData):
    var actual_file_path = str(player_last_run_file_location, game_mode_data.get_save_file_name())
    return FileAccess.file_exists(actual_file_path)


var progression_data = {}


func has_beated_main_mode():
    if not progression_data.has(Util.GAME_MODES.MAIN):
        return false
    return progression_data[Util.GAME_MODES.MAIN].get("COMPLETED", false)


func register_player_win(mode: Util.GAME_MODES, time):

    if progression_data.has(mode):
        var existing_time = progression_data[mode].get("TIME", INF)

        if time < existing_time:
            progression_data[mode]["TIME"] = time

        progression_data[mode]["COMPLETED"] = true
    else:

        progression_data[mode] = {
            "MODE": mode, 
            "COMPLETED": true, 
            "TIME": time
        }

    save_progression_data()


func save_progression_data():
    var file_path = str(player_last_run_file_location, "player_progression_cloud_file.save")
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(progression_data)
        file.store_string(json_string)
        file.close()
        return true
    else:
        push_error("Failed to save progression data: " + str(FileAccess.get_open_error()))
        return false

func load_progression_data():
    var file_path = str(player_last_run_file_location, "player_progression_cloud_file.save")
    var json_data = Util.load_json_data_from_path(file_path)
    if json_data == null:
        progression_data = {}
        return


    progression_data = {}
    for key in json_data.keys():
        var int_key = int(key)
        progression_data[int_key] = json_data[key]

func save_player_last_run():
    var actual_file_path = str(player_last_run_file_location, _get_active_save_file_name())

    var save_data: Dictionary = {
        "last_save_time": Time.get_unix_time_from_system(), 
        "money": Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY), 
        "current_tier": Global.black_hole.level_manager.current_tier_index if Global.black_hole else 0, 
        "comet_show_session_cooldown": Global.main.object_manager.comet_show_session_cooldown, 
        "epilogue": Global.main.epilogue, 
        "run_time": Global.run_stats.run_time, 
    }

    tier_stats = {
        "total_damage_this_tier": Global.tier_stats.total_damage_this_tier, 
        "total_objects_destoryed_this_tier": Global.tier_stats.total_objects_destoryed_this_tier, 
        "total_money_earned_this_teir": Global.tier_stats.total_money_earned_this_teir, 
        "session_this_tier": Global.tier_stats.session_this_tier, 
    }

    save_data["tier_stats"] = tier_stats


    var unlock_data = []
    for data in Global.game_mode_data_manager.unlocked_upgrades.values():



        unlock_data.append(data)






    save_data["upgrades_unlocked_cells"] = unlock_data
    var in_use_mods = {}
    for data in unlock_data:
        if data.has("mod"):
            in_use_mods[int(data["mod"])] = true
    save_data["upgrades_in_use_mods"] = in_use_mods.keys()


    var save_audio_run_plays = []
    for sound_effect_setting: SoundEffectSettings in AudioManager.sound_effect_dict.values():
        var data = {
            "type": SoundEffectSettings.SOUND_EFFECT_TYPE.find_key(sound_effect_setting.type), 
            "run_plays": sound_effect_setting.run_plays
        }
        save_audio_run_plays.append(data)

    save_data["audio_run_plays"] = save_audio_run_plays

    var file = FileAccess.open(actual_file_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_player_last_run():
    var actual_file_path = str(player_last_run_file_location, _get_active_save_file_name())

    var json_data = Util.load_json_data_from_path(actual_file_path)
    if json_data == null:
        money = 0
        upgrades_unlocked_upgrades = {}
        return

    money = int(json_data["money"]) if json_data.has("money") else 0
    current_tier = int(json_data["current_tier"]) if json_data.has("current_tier") else 0
    epilogue = bool(json_data["epilogue"]) if json_data.has("epilogue") else false
    run_time = float(json_data["run_time"]) if json_data.has("run_time") else 0.0
    comet_show_session_cooldown = int(json_data["comet_show_session_cooldown"]) if json_data.has("comet_show_session_cooldown") else 0
    if json_data.has("tier_stats"):
        tier_stats = json_data["tier_stats"]

    upgrades_unlocked_upgrades = {}
    upgrades_in_use_mods = []
    if json_data.has("upgrades_unlocked_cells"):
        for entry in json_data["upgrades_unlocked_cells"]:
            if entry.has("cell"):
                var cell_str: String = str(entry["cell"])

                var matches = cell_str.strip_edges().replace("(", "").replace(")", "").split(",")
                if matches.size() == 2:
                    var x = float(matches[0])
                    var y = float(matches[1])
                    var cell = Vector2(x, y)
                    upgrades_unlocked_upgrades[cell] = entry
    if json_data.has("upgrades_in_use_mods"):
        for mod_value in json_data["upgrades_in_use_mods"]:
            upgrades_in_use_mods.append(int(mod_value))


    audio_run_plays = {}
    if json_data.has("audio_run_plays"):
        for entry in json_data["audio_run_plays"]:
            if entry.has("type") and entry.has("run_plays"):
                if SoundEffectSettings.SOUND_EFFECT_TYPE.has(entry["type"]):
                    var type = SoundEffectSettings.SOUND_EFFECT_TYPE.get(entry["type"])
                    var run_plays = int(entry["run_plays"])

                    audio_run_plays[type] = run_plays




var local_settings_file_path = "user://local_settings.save"
var main_volume: float = 0.5
var effect_volume: float = 0.5
var music_volume: float = 0.25

var text_scale: float = 1.0
var first_time_load = false
var vsync_enabled: bool = true
var locale = "en"
var fps_limit = 144
var has_shown_pick_locale_first_time = false
var dark_mode = false
var money_text = true
var damage_text = true
var shuffle_music = false
var screen_shake = true
var black_hole_pulse = true
var black_hole_particles = true
var controller_sensitivity = 1.0
var run_timer = false



var screen_mode: SCREEN_MODES:
    set(new_value):
        screen_mode = new_value
        match screen_mode:
            SCREEN_MODES.FULL_SCREEN:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
            SCREEN_MODES.WINDOWED:
                DisplayServer.window_set_max_size(Vector2i(1152, 648))
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
                DisplayServer.window_set_max_size(Vector2i.ZERO)


func save_local_settings():
    var save_data = {}
    save_data["main_volume"] = main_volume
    save_data["music_volume"] = music_volume
    save_data["effect_volume"] = effect_volume
    save_data["text_scale"] = text_scale
    save_data["first_time_load"] = first_time_load
    save_data["screen_mode"] = screen_mode
    save_data["vsync_enabled"] = vsync_enabled
    save_data["locale"] = locale
    save_data["fps_limit"] = fps_limit
    save_data["has_shown_pick_locale_first_time"] = has_shown_pick_locale_first_time
    save_data["dark_mode"] = dark_mode
    save_data["damage_text"] = damage_text
    save_data["money_text"] = money_text
    save_data["shuffle_music"] = shuffle_music
    save_data["screen_shake"] = screen_shake
    save_data["black_hole_pulse"] = black_hole_pulse
    save_data["black_hole_particles"] = black_hole_particles
    save_data["run_timer"] = run_timer
    save_data["controller_sensitivity"] = controller_sensitivity
    var file = FileAccess.open(local_settings_file_path, FileAccess.WRITE)
    file.store_string(str(save_data))
    file.close()

func load_local_settings():
    var json_data = Util.load_json_data_from_path(local_settings_file_path)
    if json_data != null:
        main_volume = float(json_data["main_volume"]) if json_data.has("main_volume") else 0.5
        music_volume = float(json_data["music_volume"]) if json_data.has("music_volume") else 0.25
        effect_volume = float(json_data["effect_volume"]) if json_data.has("effect_volume") else 0.5
        text_scale = float(json_data["text_scale"]) if json_data.has("text_scale") else 1.0
        screen_mode = int(json_data["screen_mode"]) if json_data.has("screen_mode") else SCREEN_MODES.FULL_SCREEN
        vsync_enabled = bool(json_data["vsync_enabled"]) if json_data.has("vsync_enabled") else true
        locale = json_data["locale"] if json_data.has("locale") else "en"
        fps_limit = int(json_data["fps_limit"]) if json_data.has("fps_limit") else 144
        has_shown_pick_locale_first_time = bool(json_data["has_shown_pick_locale_first_time"]) if json_data.has("has_shown_pick_locale_first_time") else false
        dark_mode = bool(json_data["dark_mode"]) if json_data.has("dark_mode") else false
        damage_text = bool(json_data["damage_text"]) if json_data.has("damage_text") else true
        money_text = bool(json_data["money_text"]) if json_data.has("money_text") else true
        shuffle_music = bool(json_data["shuffle_music"]) if json_data.has("shuffle_music") else false
        screen_shake = bool(json_data["screen_shake"]) if json_data.has("screen_shake") else true
        black_hole_pulse = bool(json_data["black_hole_pulse"]) if json_data.has("black_hole_pulse") else true
        run_timer = bool(json_data["run_timer"]) if json_data.has("run_timer") else false
        first_time_load = bool(json_data["first_time_load"]) if json_data.has("first_time_load") else false
        black_hole_particles = bool(json_data["black_hole_particles"]) if json_data.has("black_hole_particles") else true
        controller_sensitivity = float(json_data["controller_sensitivity"]) if json_data.has("controller_sensitivity") else 1.0

func update_first_time_load(value):
    first_time_load = value
    save_local_settings()

func update_main_volume(new_value):
    main_volume = new_value
    save_local_settings()


func update_music_volume(new_value):
    music_volume = new_value
    save_local_settings()


func update_effect_volume(new_value):
    effect_volume = new_value
    save_local_settings()



func update_text_scale(new_value):
    text_scale = new_value
    save_local_settings()


func update_screen_mode(new_value):
    screen_mode = new_value
    save_local_settings()


func update_vysnc(new_value: bool):
    vsync_enabled = new_value
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveHandler.vsync_enabled else DisplayServer.VSYNC_DISABLED)
    save_local_settings()


func update_locale(value):
    if supported_locales.has(value):
        if locale != value:
            TranslationServer.set_locale(value)
            locale = value
    save_local_settings()

func update_has_shown_pick_locale_first_time(value):
    has_shown_pick_locale_first_time = value
    save_local_settings()


func update_fps_limit(value):
    fps_limit = value
    Engine.max_fps = value
    save_local_settings()

func update_dark_mode(value):
    dark_mode = value

    Refs.pallet = load(Util.dark_pallet if dark_mode else Util.light_pallet)
    SignalBus.pallet_updated.emit()
    save_local_settings()


func update_floating_money_text(value):
    money_text = value

    save_local_settings()


func update_floating_damage_text(value):
    damage_text = value

    save_local_settings()

func update_shuffle_music(value):
    shuffle_music = value

    MusicPlayer.update()

    save_local_settings()


func update_screen_shake(value):
    screen_shake = value
    save_local_settings()


func update_black_hole_pulse(value):
    black_hole_pulse = value
    save_local_settings()

func update_run_timer(value):
    run_timer = value
    SignalBus.settings_updated.emit()
    save_local_settings()

func update_black_hole_particles(value):
    black_hole_particles = value

    save_local_settings()



func update_controller_sensitivity(value):
    controller_sensitivity = value

    save_local_settings()


var fishing_progress_file_path = "user://fishing_incremental_progress.save"
var fishing_currency = 0
var fishing_lifetime_coins = 0
var fishing_unlocked_upgrades: Dictionary = {}
var fishing_active_upgrades: Dictionary = {}
var fishing_last_battle_summary: Dictionary = {}
var fishing_next_battle_level := 1
var fishing_max_unlocked_battle_level := 1

func load_fishing_progress():
    var json_data = Util.load_json_data_from_path(fishing_progress_file_path)
    if json_data == null:
        fishing_currency = 0
        fishing_lifetime_coins = 0
        fishing_unlocked_upgrades = {}
        fishing_active_upgrades = {}
        fishing_last_battle_summary = {}
        fishing_next_battle_level = 1
        fishing_max_unlocked_battle_level = 1
        return

    fishing_currency = int(json_data.get("currency", 0))
    fishing_lifetime_coins = int(json_data.get("lifetime_coins", 0))
    fishing_unlocked_upgrades = json_data.get("unlocked_upgrades", {})
    fishing_active_upgrades = json_data.get("active_upgrades", {})
    fishing_last_battle_summary = json_data.get("last_battle_summary", {})
    fishing_next_battle_level = max(1, int(json_data.get("next_battle_level", 1)))
    fishing_max_unlocked_battle_level = clamp(int(json_data.get("max_unlocked_battle_level", 1)), 1, 3)
    fishing_next_battle_level = clamp(fishing_next_battle_level, 1, fishing_max_unlocked_battle_level)

func save_fishing_progress():
    var save_data = {
        "currency": fishing_currency,
        "lifetime_coins": fishing_lifetime_coins,
        "unlocked_upgrades": fishing_unlocked_upgrades,
        "active_upgrades": fishing_active_upgrades,
        "last_battle_summary": fishing_last_battle_summary,
        "next_battle_level": fishing_next_battle_level,
        "max_unlocked_battle_level": fishing_max_unlocked_battle_level,
    }
    var file = FileAccess.open(fishing_progress_file_path, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(save_data))
    file.close()

func get_fishing_upgrade_level(key: String) -> int:
    return int(fishing_unlocked_upgrades.get(key, 0))

func has_fishing_upgrade(key: String) -> bool:
    return get_fishing_upgrade_level(key) > 0

func unlock_fishing_upgrade(key: String, repeatable: bool = false):
    var new_level = 1 if not repeatable else get_fishing_upgrade_level(key) + 1
    fishing_unlocked_upgrades[key] = new_level
    fishing_active_upgrades[key] = true
    save_fishing_progress()
