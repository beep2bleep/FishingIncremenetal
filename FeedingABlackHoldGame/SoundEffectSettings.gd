extends Resource
class_name SoundEffectSettings

enum SOUND_EFFECT_TYPE{
    TECH_TREE_NODE_HOVER, 
    TECH_TREE_NODE_CLICK, 
    ON_ASTEROID_SUCK_UP, 
    ON_ASTEROID_DESTORY, 
    ON_RESOURCE_SUCKED_UP, 
    ON_ASTEROID_CLICKED, 
    BLACK_HOLE_GROW, 
    ELECTRIC, 
    RADIOACTIVE_DOT, 
    ON_ASTEROID_SPAWNED, 
    ON_CLICKER_CRIT, 
    ELECTRIC_CRIT, 
    FROZEN_PLANET_BREAK, 
    FORZEN_SHARD_IMPACT, 
    PINATA_BREAK, 
    PLANET_BREAK, 
    PLANET_HIT, 
    CLICK_HIT_NOTHING, 
    ON_GOLDEN_BREAK, 
    ON_GOLDEN_BREAK_CRIT, 
    ON_LASER, 
    ON_LASER_CRIT, 
    MOON, 
    COMET, 
    SUPERNOVA, 
    ELECTRIC_STAR, 
    ELECTRIC_STAR_CRIT, 
    STAR_HIT, 
    STAR_DESTROYED, 
    BLACK_HOLE_COLLAPSE, 
    BLACK_HOLE_GROW_MILESTONE, 
    TECH_TREE_NODE_POP_IN, 
    TECH_TREE_LINE_FILL, 
    BUTTON_CLICK, 
    GAME_MODE_HOVER
}

@export_range(0, 20) var limit: int = 5
@export var type: SOUND_EFFECT_TYPE
@export var sound_effect: AudioStreamMP3
@export_range(-40, 20) var volume = 0
@export_range(0.0, 4.0, 0.01) var pitch_scale = 1.0
@export_range(0.0, 1.0, 0.01) var pitch_randomness = 0.0

@export_group("Taper Off")
@export var taper_off_enabled: bool = false
@export var taper_off_db_amount: float = 0.0
@export var play_limit_to_full_taper: int = 0
@export var taper_fall_off_curve: Curve

@export_group("Pitch Up")
@export var pitch_up_on_count_enabled: bool = false
@export_range(0.0, 1.0, 0.01) var pitch_up_amount_per_count = 0.0

@export var pitch_up_max_count: int = 0
@export_range(0.0, 10.0, 0.01) var pitch_up_decay_rate = 0.0

var pitch_up_count = 0:
    set(new_value):
        pitch_up_count = clamp(new_value, 0, pitch_up_max_count)

var pitch_up_timer: Timer
var audio_count = 0
var run_plays = 0

func reset():
    run_plays = 0
    audio_count = 0
    pitch_up_count = 0



func setup():
    if pitch_up_on_count_enabled == true:
        pitch_up_timer = Timer.new()
        AudioManager.add_child(pitch_up_timer)
        pitch_up_timer.wait_time = max(pitch_up_decay_rate, 0)
        pitch_up_timer.timeout.connect(_on_pitch_up_timer_timeout)
        pitch_up_timer.one_shot = false
        pitch_up_timer.start()


func _on_pitch_up_timer_timeout():
    pitch_up_count -= 1


func get_pitch_up_amount():
    if pitch_up_on_count_enabled == true:
        return pitch_up_count * pitch_up_amount_per_count

func change_audio_count(amount: int):

    audio_count = max(0, audio_count + amount)

func has_open_limit() -> bool:
    return audio_count < limit

func on_audio_finished():
    change_audio_count(-1)


func get_volume():
    var vol = volume

    if taper_off_enabled == true:
        var fall_off_percent = min(1.0, float(run_plays) / float(play_limit_to_full_taper))
        if taper_fall_off_curve != null:
            vol -= taper_off_db_amount * taper_fall_off_curve.sample(fall_off_percent)
        else:
            vol -= taper_off_db_amount * fall_off_percent

    return vol
