extends Node

var sound_effect_dict = {}
var cached_web_audio_players: Dictionary = {}
var cached_web_audio_last_play_ms: Dictionary = {}

const WEB_CACHED_AUDIO_COOLDOWN_MS := {
    SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER: 90,
}

@export var sound_effect_settings: Array[SoundEffectSettings]

func _ready():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_dict[sound_effect_setting.type] = sound_effect_setting
        sound_effect_setting.setup()
    _prewarm_cached_web_audio_players()


func on_load_game():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_setting.reset()

    for key in SaveHandler.audio_run_plays:
        if sound_effect_dict.has(key):
            sound_effect_dict[key].run_plays = SaveHandler.audio_run_plays[key]




func on_new_game():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_setting.reset()


func create_2d_audio_at_location(location, type: SoundEffectSettings.SOUND_EFFECT_TYPE, volume_db_offset: float = 0.0, pitch_scale_offset: float = 0.0):
    if sound_effect_dict.has(type):
        var sound_effect_setting: SoundEffectSettings = sound_effect_dict[type]
        if sound_effect_setting.has_open_limit():
            sound_effect_setting.change_audio_count(1)
            sound_effect_setting.run_plays += 1
            var new_2D_audio = AudioStreamPlayer2D.new()
            add_child(new_2D_audio)

            new_2D_audio.bus = "Effects"

            new_2D_audio.position = location
            new_2D_audio.stream = sound_effect_setting.sound_effect
            new_2D_audio.volume_db = sound_effect_setting.get_volume() + volume_db_offset

            new_2D_audio.pitch_scale = sound_effect_setting.pitch_scale + pitch_scale_offset
            if sound_effect_setting.pitch_up_on_count_enabled == true:
                new_2D_audio.pitch_scale += sound_effect_setting.get_pitch_up_amount()
                sound_effect_setting.pitch_up_count += 1
            new_2D_audio.pitch_scale += Global.rng.randf_range( - sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
            new_2D_audio.finished.connect(sound_effect_setting.on_audio_finished)
            new_2D_audio.finished.connect(new_2D_audio.queue_free)

            new_2D_audio.play()


    else:
        push_error("Audio Manager failed to find setting for type ", type)


func create_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE, volume_db_offset: float = 0.0, pitch_scale_offset: float = 0.0):
    if sound_effect_dict.has(type):
        var sound_effect_setting: SoundEffectSettings = sound_effect_dict[type]
        if _should_use_cached_web_audio(type):
            _play_cached_web_audio(sound_effect_setting, type, volume_db_offset, pitch_scale_offset)
            return
        if sound_effect_setting.has_open_limit():
            sound_effect_setting.change_audio_count(1)
            sound_effect_setting.run_plays += 1
            var new_audio = AudioStreamPlayer.new()
            add_child(new_audio)

            new_audio.bus = "Effects"

            new_audio.stream = sound_effect_setting.sound_effect
            new_audio.volume_db = sound_effect_setting.get_volume() + volume_db_offset

            new_audio.pitch_scale = sound_effect_setting.pitch_scale + pitch_scale_offset
            if sound_effect_setting.pitch_up_on_count_enabled == true:
                new_audio.pitch_scale += sound_effect_setting.get_pitch_up_amount()
                sound_effect_setting.pitch_up_count += 1
            new_audio.pitch_scale += Global.rng.randf_range( - sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)

            new_audio.finished.connect(sound_effect_setting.on_audio_finished)
            new_audio.finished.connect(new_audio.queue_free)

            new_audio.play()
    else:
        push_error("Audio Manager failed to find setting for type ", type)

func _should_use_cached_web_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> bool:
    return OS.has_feature("web") and WEB_CACHED_AUDIO_COOLDOWN_MS.has(type)

func _prewarm_cached_web_audio_players() -> void:
    if not OS.has_feature("web"):
        return
    for type_variant in WEB_CACHED_AUDIO_COOLDOWN_MS.keys():
        _get_or_create_cached_web_audio_player(type_variant)

func _get_or_create_cached_web_audio_player(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> AudioStreamPlayer:
    if cached_web_audio_players.has(type):
        return cached_web_audio_players[type] as AudioStreamPlayer
    if not sound_effect_dict.has(type):
        return null
    var sound_effect_setting: SoundEffectSettings = sound_effect_dict[type]
    var cached_audio := AudioStreamPlayer.new()
    cached_audio.bus = "Effects"
    cached_audio.stream = sound_effect_setting.sound_effect
    add_child(cached_audio)
    cached_web_audio_players[type] = cached_audio
    return cached_audio

func _play_cached_web_audio(sound_effect_setting: SoundEffectSettings, type: SoundEffectSettings.SOUND_EFFECT_TYPE, volume_db_offset: float, pitch_scale_offset: float) -> void:
    var now_ms: int = Time.get_ticks_msec()
    var cooldown_ms: int = int(WEB_CACHED_AUDIO_COOLDOWN_MS.get(type, 0))
    var last_play_ms: int = int(cached_web_audio_last_play_ms.get(type, -cooldown_ms))
    if cooldown_ms > 0 and now_ms - last_play_ms < cooldown_ms:
        return

    var cached_audio: AudioStreamPlayer = _get_or_create_cached_web_audio_player(type)
    if cached_audio == null:
        return

    cached_web_audio_last_play_ms[type] = now_ms
    sound_effect_setting.run_plays += 1
    cached_audio.stop()
    cached_audio.stream = sound_effect_setting.sound_effect
    cached_audio.volume_db = sound_effect_setting.get_volume() + volume_db_offset
    cached_audio.pitch_scale = sound_effect_setting.pitch_scale + pitch_scale_offset
    if sound_effect_setting.pitch_up_on_count_enabled == true:
        cached_audio.pitch_scale += sound_effect_setting.get_pitch_up_amount()
        sound_effect_setting.pitch_up_count += 1
    cached_audio.pitch_scale += Global.rng.randf_range(-sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
    cached_audio.play()
