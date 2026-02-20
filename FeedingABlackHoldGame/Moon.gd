extends Node2D
class_name Moon

var enable = false
var buff_rate_scale = 0.0
var buff_aoe_scale = 0.0

enum STATES{FREE, PLANET, CLICKER}
var state = STATES.FREE

func _ready():
    SignalBus.game_state_changed.connect(_on_game_state_changed)
    %"Special Overlay".polygon = Util.get_evenly_spaced_points_on_a_circle(16, 32)

func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.START_OF_SESSION:
            clean_up()
        Util.GAME_STATES.END_OF_SESSION:
            clean_up()
        Util.GAME_STATES.END_OF_TEIR:
            clean_up()
        Util.GAME_STATES.GAME_OVER:
            clean_up()
        Util.GAME_STATES.MAIN_MENU:
            clean_up()


func on_added_to_planet():
    FlairManager.current_active_moons += 1
    show()
    state = STATES.PLANET

func setup(_duration, _buff_rate_scale, _buff_aoe_scale):
    state = STATES.CLICKER

    Global.session_stats.moons_collected += 1

    show()
    enable = true

    buff_rate_scale = _buff_rate_scale
    buff_aoe_scale = _buff_aoe_scale

    scale = Vector2.ONE

    %Timer.wait_time = _duration
    %Timer.start()
    Global.mods.change_mod(Util.MODS.CLICK_RATE_BUFF, buff_rate_scale)
    Global.mods.change_mod(Util.MODS.CLICK_AOE_BUFF, buff_aoe_scale)

    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MOON)


func clean_up():
    match state:
        STATES.PLANET:
            FlairManager.current_active_moons -= 1
            Util.orphan(self)
            FlairManager.add_child(self)
            FlairManager.moon_pool.append(self)
        STATES.CLICKER:
            FlairManager.current_active_moons -= 1
            Util.orphan(self)
            FlairManager.add_child(self)

            Global.mods.change_mod(Util.MODS.CLICK_RATE_BUFF, - buff_rate_scale)
            Global.mods.change_mod(Util.MODS.CLICK_AOE_BUFF, - buff_aoe_scale)
            FlairManager.moon_pool.append(self)

    hide()
    %Timer.stop()
    state = STATES.FREE


func _on_timer_timeout() -> void :
    clean_up()
