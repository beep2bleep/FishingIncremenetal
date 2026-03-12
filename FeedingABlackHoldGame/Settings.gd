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
var locale_codes: Array[String] = []
var _is_refreshing: bool = false

func show_screen():
    _set_credits_visible(false)
    refresh_from_save()
    %"Main Volume".grab_focus()

    pass


func _ready():
    hide()

    populate_language_list()
    populate_window_mode_list()
    populate_fps_list()
    _refresh_hidden_control_visibility()
    refresh_from_save()

    show()

func _set_credits_visible(is_visible: bool) -> void:
    %"Credits Panel".visible = is_visible
    %"Credits Button".visible = not is_visible
    var grid_container: GridContainer = get_node_or_null("GridContainer")
    if grid_container != null:
        grid_container.visible = not is_visible

func _on_credits_button_pressed() -> void:
    _set_credits_visible(true)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_hide_credits_pressed() -> void:
    _set_credits_visible(false)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _refresh_hidden_control_visibility() -> void:
    var touch_input_label: Label = get_node_or_null("GridContainer/Touch Input")
    if touch_input_label != null:
        touch_input_label.visible = false
    var touch_input_container: CenterContainer = get_node_or_null("GridContainer/CenterContainer11")
    if touch_input_container != null:
        touch_input_container.visible = false
    var controller_sensitivity_label: Label = get_node_or_null("GridContainer/Ctrl Sens")
    if controller_sensitivity_label != null:
        controller_sensitivity_label.visible = false
    var controller_sensitivity_container: HBoxContainer = get_node_or_null("GridContainer/HBoxContainer3")
    if controller_sensitivity_container != null:
        controller_sensitivity_container.visible = false

func refresh_from_save() -> void:
    _is_refreshing = true
    %"Music Volume".value = SaveHandler.music_volume
    %"Main Volume".value = SaveHandler.main_volume
    %"Effect Volume Slider".value = SaveHandler.effect_volume
    ctrl_sense = SaveHandler.controller_sensitivity
    %"V Sync Enabled".button_pressed = SaveHandler.vsync_enabled
    %"Floating Currency CheckButton".button_pressed = SaveHandler.money_text
    %"Floating Damage CheckButton".button_pressed = SaveHandler.damage_text
    %"Confirm Upgrade Purchase CheckButton".button_pressed = SaveHandler.confirm_upgrade_purchase
    text_scale = SaveHandler.text_scale
    _refresh_language_selection()
    _refresh_window_mode_selection()
    _refresh_fps_selection()
    _is_refreshing = false

func populate_language_list() -> void:
    locale_codes.clear()
    %"Language Dropdown".clear()
    for locale_code: String in SaveHandler.supported_locales.keys():
        locale_codes.append(locale_code)
        %"Language Dropdown".add_item(str(SaveHandler.supported_locales[locale_code]))
    _refresh_language_selection()

func _refresh_language_selection() -> void:
    for i in range(locale_codes.size()):
        if locale_codes[i] == SaveHandler.locale:
            %"Language Dropdown".select(i)
            return


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

func _refresh_window_mode_selection() -> void:
    var index := 0
    for r in screen_modes.keys():
        if r == SaveHandler.screen_mode:
            %"Screen Mode Dropdown".select(index)
            return
        index += 1

func _refresh_fps_selection() -> void:
    var index := 0
    for r in fps_limits.keys():
        if r == SaveHandler.fps_limit:
            %"FPS Dropdown".select(index)
            return
        index += 1


func _on_screen_mode_dropdown_item_selected(index: int) -> void :
    SaveHandler.update_screen_mode(screen_modes.keys()[index])
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_fps_dropdown_item_selected(index: int) -> void :
    SaveHandler.update_fps_limit(fps_limits.keys()[index])
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_language_dropdown_item_selected(index: int) -> void:
    if index < 0 or index >= locale_codes.size():
        return
    SaveHandler.update_locale(locale_codes[index])
    SaveHandler.update_has_shown_pick_locale_first_time(true)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_v_sync_enabled_toggled(toggled_on: bool) -> void :
    SaveHandler.update_vysnc(toggled_on)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveHandler.vsync_enabled else DisplayServer.VSYNC_DISABLED)
    if visible and not _is_refreshing:
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



func _on_shuffle_music_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_shuffle_music(toggled_on)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_floating_currency_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_floating_money_text(toggled_on)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_floating_damage_check_button_toggled(toggled_on: bool) -> void :
    SaveHandler.update_floating_damage_text(toggled_on)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_confirm_upgrade_purchase_check_button_toggled(toggled_on: bool) -> void:
    SaveHandler.update_confirm_upgrade_purchase(toggled_on)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_touch_input_check_button_toggled(toggled_on: bool) -> void:
    SaveHandler.update_touch_input_mode(toggled_on)
    if visible and not _is_refreshing:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)



func _on_effect_volume_slider_value_changed(value: float) -> void :
    AudioServer.set_bus_volume_db(
    2, 
    linear_to_db(value * 3.0)
    )
    SaveHandler.update_effect_volume(value)


var text_scale = 1.0:
    set(new_value):
        text_scale = snapped(clamp(0.5, new_value, 1.5), 0.1)
        %"Text Size Label".text = str(int(text_scale * 100), "%")
        ThemeManager.text_scale = text_scale
        if not _is_refreshing:
            SignalBus.settings_updated.emit()





func _on_text_smaller_pressed() -> void :
    text_scale -= 0.1


func _on_text_larger_pressed() -> void :
    text_scale += 0.1


var ctrl_sense = 1.0:
    set(new_value):
        ctrl_sense = snapped(clamp(0.1, new_value, 10.0), 0.1)
        %"Contr Sens Label".text = str(int(ctrl_sense * 100), "%")
        if not _is_refreshing:
            SaveHandler.update_controller_sensitivity(ctrl_sense)


func _on_sens_down_pressed() -> void :
    ctrl_sense -= 0.1


func _on_sens_up_pressed() -> void :
    ctrl_sense += 0.1
