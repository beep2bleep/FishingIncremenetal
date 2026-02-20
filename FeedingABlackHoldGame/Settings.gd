extends VBoxContainer
class_name Settings

var screen_modes = {
    SaveHandler.SCREEN_MODES.FULL_SCREEN: "FULLSCREEN", 
    SaveHandler.SCREEN_MODES.WINDOWED: "WINDOWED", 


}


var fps_limits: Dictionary = {
        30: "30", 
        60: "60", 
        120: "120", 
        144: "144", 
        240: "240"
    }

func show_screen():
    %"Dark Mode CheckButton".grab_focus()

    pass


func _ready():
    hide()

    %"Music Volume".value = SaveHandler.music_volume
    %"Main Volume".value = SaveHandler.main_volume
    %"Effect Volume Slider".value = SaveHandler.effect_volume
    ctrl_sense = SaveHandler.controller_sensitivity

    %"V Sync Enabled".button_pressed = SaveHandler.vsync_enabled
    %"Dark Mode CheckButton".button_pressed = SaveHandler.dark_mode
    %"Monet Text CheckButton".button_pressed = SaveHandler.money_text
    %"Damage Text CheckButton".button_pressed = SaveHandler.damage_text
    %"Screen Shake CheckButton".button_pressed = SaveHandler.screen_shake
    %"Black Hole CheckButton".button_pressed = SaveHandler.black_hole_pulse
    %"Run Timer Checkbutton".button_pressed = SaveHandler.run_timer
    %"Black Hole Particles CheckButton".button_pressed = SaveHandler.black_hole_particles



    text_scale = SaveHandler.text_scale

    populate_window_mode_list()
    populate_language_list()
    populate_fps_list()

    show()


func populate_language_list():
    var index = 0
    for r in SaveHandler.supported_locales.keys():
        %"Language Dropdown".add_item(SaveHandler.supported_locales[r], index)
        if r == SaveHandler.locale:
            %"Language Dropdown".select(index)
        index += 1


func populate_window_mode_list():
    var index = 0
    for r in screen_modes.keys():
        %"Screen Mode Dropdown".add_item(screen_modes[r], index)
        if r == SaveHandler.screen_mode:
            %"Screen Mode Dropdown".select(index)
        index += 1


func populate_fps_list():
    var index = 0
    for r in fps_limits.keys():
        %"FPS Dropdown".add_item(fps_limits[r], index)
        if r == SaveHandler.fps_limit:
            %"FPS Dropdown".select(index)
        index += 1


func _on_language_dropdown_item_selected(index: int) -> void :
    SaveHandler.update_locale(SaveHandler.supported_locales.keys()[index])
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

    SignalBus.settings_updated.emit()


func _on_screen_mode_dropdown_item_selected(index: int) -> void :
    SaveHandler.update_screen_mode(screen_modes.keys()[index])
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_fps_dropdown_item_selected(index: int) -> void :
    SaveHandler.update_fps_limit(fps_limits.keys()[index])
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_v_sync_enabled_toggled(toggled_on: bool) -> void :
    SaveHandler.update_vysnc(toggled_on)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveHandler.vsync_enabled else DisplayServer.VSYNC_DISABLED)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_main_volume_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    0, 
    linear_to_db(value * 3.0)
    )
    SaveHandler.update_main_volume(value)

func _on_music_volume_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    1, 
    linear_to_db(value * 3.0)
    )
    SaveHandler.update_music_volume(value)



func _on_dark_mode_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_dark_mode(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)


func _on_monet_text_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_floating_money_text(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)


func _on_damage_text_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_floating_damage_text(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)


func _on_shuffle_music_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_shuffle_music(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)



func _on_screen_shake_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_screen_shake(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)


func _on_effect_volume_slider_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    2, 
    linear_to_db(value * 3.0)
    )
    SaveHandler.update_effect_volume(value)


func _on_black_hole_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_black_hole_pulse(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_run_timer_checkbutton_toggled(toggled_on: bool) -> void :
    SaveHandler.update_run_timer(toggled_on)
    if visible:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

var text_scale = 1.0:
    set(new_value):
        text_scale = snapped(clamp(0.5, new_value, 1.5), 0.1)
        %"Text Size Label".text = str(int(text_scale * 100), "%")
        ThemeManager.text_scale = text_scale
        SignalBus.settings_updated.emit()





func _on_text_smaller_pressed() -> void :
    text_scale -= 0.1


func _on_text_larger_pressed() -> void :
    text_scale += 0.1


func _on_black_hole_particles_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_black_hole_particles(toggled_on)






var ctrl_sense = 1.0:
    set(new_value):
        ctrl_sense = snapped(clamp(0.1, new_value, 10.0), 0.1)
        %"Contr Sens Label".text = str(int(ctrl_sense * 100), "%")
        SaveHandler.update_controller_sensitivity(ctrl_sense)


func _on_sens_down_pressed() -> void :
    ctrl_sense -= 0.1


func _on_sens_up_pressed() -> void :
    ctrl_sense += 0.1
