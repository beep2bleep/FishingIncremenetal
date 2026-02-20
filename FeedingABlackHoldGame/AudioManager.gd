extends Node

var sound_effect_dict = {}

@export var sound_effect_settings: Array[SoundEffectSettings]

func _ready():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_dict[sound_effect_setting.type] = sound_effect_setting
        sound_effect_setting.setup()


func on_load_game():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_setting.reset()

    for key in SaveHandler.audio_run_plays:
        if sound_effect_dict.has(key):
            sound_effect_dict[key].run_plays = SaveHandler.audio_run_plays[key]




func on_new_game():
    for sound_effect_setting: SoundEffectSettings in sound_effect_settings:
        sound_effect_setting.reset()


func create_2d_audio_at_location(location, type: SoundEffectSettings.SOUND_EFFECT_TYPE):
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
            new_2D_audio.volume_db = sound_effect_setting.get_volume()

            new_2D_audio.pitch_scale = sound_effect_setting.pitch_scale
            if sound_effect_setting.pitch_up_on_count_enabled == true:
                new_2D_audio.pitch_scale += sound_effect_setting.get_pitch_up_amount()
                sound_effect_setting.pitch_up_count += 1
            new_2D_audio.pitch_scale += Global.rng.randf_range( - sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
            new_2D_audio.finished.connect(sound_effect_setting.on_audio_finished)
            new_2D_audio.finished.connect(new_2D_audio.queue_free)

            new_2D_audio.play()


    else:
        push_error("Audio Manager failed to find setting for type ", type)


func create_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
    if sound_effect_dict.has(type):
        var sound_effect_setting: SoundEffectSettings = sound_effect_dict[type]
        if sound_effect_setting.has_open_limit():
            sound_effect_setting.change_audio_count(1)
            sound_effect_setting.run_plays += 1
            var new_audio = AudioStreamPlayer.new()
            add_child(new_audio)

            new_audio.bus = "Effects"

            new_audio.stream = sound_effect_setting.sound_effect
            new_audio.volume_db = sound_effect_setting.get_volume()

            new_audio.pitch_scale = sound_effect_setting.pitch_scale
            if sound_effect_setting.pitch_up_on_count_enabled == true:
                new_audio.pitch_scale += sound_effect_setting.get_pitch_up_amount()
                sound_effect_setting.pitch_up_count += 1
            new_audio.pitch_scale += Global.rng.randf_range( - sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)

            new_audio.finished.connect(sound_effect_setting.on_audio_finished)
            new_audio.finished.connect(new_audio.queue_free)

            new_audio.play()
    else:
        push_error("Audio Manager failed to find setting for type ", type)
