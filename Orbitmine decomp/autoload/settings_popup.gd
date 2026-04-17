extends CanvasLayer






const SAVE_PATH: = "user://settings.cfg"


signal language_changed


const LANGUAGES: = [
    {"name": "한국어", "code": "ko"}, 
    {"name": "English", "code": "en"}, 
    {"name": "日本語", "code": "ja"}, 
    {"name": "中文简体", "code": "zh_Hans"}, 
    {"name": "Русский", "code": "ru"}, 
    {"name": "Português (BR)", "code": "pt_BR"}, 
    {"name": "Deutsch", "code": "de"}, 
    {"name": "Español (España)", "code": "es"}, 
    {"name": "Español (Latinoamérica)", "code": "es_MX"}, 
    {"name": "Français", "code": "fr"}, 
    {"name": "Polski", "code": "pl"}, 
    {"name": "Türkçe", "code": "tr"}, 
]


var overlay: ColorRect
var panel: PanelContainer
var bgm_slider: HSlider
var sfx_slider: HSlider
var mute_check: CheckButton
var shake_check: CheckButton
var fullscreen_check: CheckButton
var lang_option: OptionButton
var is_open: bool = false
var _initializing: bool = true


var title_label: Label
var bgm_label: Label
var sfx_label: Label
var mute_label: Label
var shake_label: Label
var fullscreen_label: Label
var lang_label: Label
var close_btn: Button
var menu_btn: Button


const C_BG: = Color(0.02, 0.02, 0.06, 0.85)
const C_BORDER: = Color(0.3, 1.0, 1.2, 0.8)
const C_ACCENT: = Color(0.5, 1.8, 2.0)
const C_TEXT: = Color(0.85, 0.9, 0.95)
const C_DIM: = Color(0.5, 0.55, 0.6)

func _ready():
    layer = 90
    _load_settings()
    _build_ui()
    _apply_pending()
    _apply_settings()
    _set_visible(false)

    await get_tree().process_frame
    _set_fullscreen(fullscreen_check.button_pressed)
    _initializing = false

func _unhandled_input(event: InputEvent):
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        if is_open:
            _close()
        else:
            _open()
        get_viewport().set_input_as_handled()





func _build_ui():

    overlay = ColorRect.new()
    overlay.color = Color(0.0, 0.0, 0.0, 0.5)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.gui_input.connect(_on_overlay_click)
    add_child(overlay)


    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.custom_minimum_size = Vector2(360, 380)
    panel.offset_left = -180
    panel.offset_right = 180
    panel.offset_top = -190
    panel.offset_bottom = 190

    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = C_BG
    panel_style.border_color = C_BORDER
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(8)
    panel_style.content_margin_left = 24
    panel_style.content_margin_right = 24
    panel_style.content_margin_top = 20
    panel_style.content_margin_bottom = 20
    panel.add_theme_stylebox_override("panel", panel_style)
    add_child(panel)


    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16)
    panel.add_child(vbox)


    title_label = Label.new()
    title_label.text = tr("SETTINGS_TITLE")
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 22)
    title_label.add_theme_color_override("font_color", C_ACCENT)
    vbox.add_child(title_label)


    var sep1: = HSeparator.new()
    sep1.add_theme_color_override("separator", C_BORDER * Color(1, 1, 1, 0.3))
    vbox.add_child(sep1)


    bgm_label = _create_label(tr("SETTINGS_BGM"))
    bgm_slider = _add_slider_row(vbox, bgm_label)
    bgm_slider.value_changed.connect(_on_bgm_changed)


    sfx_label = _create_label(tr("SETTINGS_SFX"))
    sfx_slider = _add_slider_row(vbox, sfx_label)
    sfx_slider.value_changed.connect(_on_sfx_changed)


    mute_label = _create_label(tr("SETTINGS_MUTE"))
    mute_check = _add_toggle_row(vbox, mute_label, false)
    mute_check.toggled.connect(_on_mute_toggled)


    shake_label = _create_label(tr("SETTINGS_SHAKE"))
    shake_check = _add_toggle_row(vbox, shake_label)
    shake_check.toggled.connect(_on_shake_toggled)


    fullscreen_label = _create_label(tr("SETTINGS_FULLSCREEN"))
    fullscreen_check = _add_toggle_row(vbox, fullscreen_label, true)
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)


    lang_label = _create_label(tr("SETTINGS_LANG"))
    lang_option = _add_lang_row(vbox, lang_label)
    lang_option.item_selected.connect(_on_lang_selected)


    var sep2: = HSeparator.new()
    sep2.add_theme_color_override("separator", C_BORDER * Color(1, 1, 1, 0.3))
    vbox.add_child(sep2)


    menu_btn = Button.new()
    menu_btn.text = tr("SETTINGS_MAIN_MENU")
    menu_btn.custom_minimum_size = Vector2(0, 36)
    menu_btn.add_theme_font_size_override("font_size", 15)
    menu_btn.pressed.connect(_go_to_main_menu)
    vbox.add_child(menu_btn)


    close_btn = Button.new()
    close_btn.text = tr("SETTINGS_CLOSE")
    close_btn.custom_minimum_size = Vector2(0, 36)
    close_btn.add_theme_font_size_override("font_size", 15)
    close_btn.pressed.connect(_close)
    vbox.add_child(close_btn)


func _create_label(text: String) -> Label:
    var label: = Label.new()
    label.text = text
    label.custom_minimum_size.x = 100
    label.add_theme_font_size_override("font_size", 15)
    label.add_theme_color_override("font_color", C_TEXT)
    return label


func _add_slider_row(parent: Control, label: Label) -> HSlider:
    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 12)
    parent.add_child(hbox)

    hbox.add_child(label)

    var slider: = HSlider.new()
    slider.min_value = 0.0
    slider.max_value = 100.0
    slider.step = 1.0
    slider.value = 100.0
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.custom_minimum_size.y = 24
    hbox.add_child(slider)

    var pct: = Label.new()
    pct.text = "100%"
    pct.custom_minimum_size.x = 45
    pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    pct.add_theme_font_size_override("font_size", 14)
    pct.add_theme_color_override("font_color", C_DIM)
    hbox.add_child(pct)


    slider.value_changed.connect( func(v): pct.text = "%d%%" % int(v))

    return slider


func _add_toggle_row(parent: Control, label: Label, default_on: bool = true) -> CheckButton:
    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 12)
    parent.add_child(hbox)

    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)

    var toggle: = CheckButton.new()
    toggle.button_pressed = default_on
    hbox.add_child(toggle)

    return toggle


func _add_lang_row(parent: Control, label: Label) -> OptionButton:
    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 12)
    parent.add_child(hbox)

    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)

    var option: = OptionButton.new()
    option.custom_minimum_size.x = 130
    option.add_theme_font_size_override("font_size", 14)


    for i in LANGUAGES.size():
        option.add_item(LANGUAGES[i]["name"], i)


    var current_locale: = TranslationServer.get_locale()
    for i in LANGUAGES.size():
        if LANGUAGES[i]["code"] == current_locale:
            option.select(i)
            break

    hbox.add_child(option)
    return option





func _open():
    is_open = true
    _set_visible(true)
    get_tree().paused = true
    process_mode = Node.PROCESS_MODE_ALWAYS

func _close():
    is_open = false
    _set_visible(false)
    get_tree().paused = false
    _save_settings()

func _set_visible(v: bool):
    overlay.visible = v
    panel.visible = v

func _on_overlay_click(event: InputEvent):
    if event is InputEventMouseButton and event.pressed:
        _close()


func _go_to_main_menu():
    _save_settings()
    is_open = false
    _set_visible(false)
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")





func _on_bgm_changed(value: float):
    SoundManager.bgm_volume = value / 100.0

func _on_sfx_changed(value: float):
    SoundManager.sfx_volume = value / 100.0

func _on_mute_toggled(pressed: bool):
    SoundManager.muted = pressed

func _on_shake_toggled(pressed: bool):
    Global.screen_shake_enabled = pressed

func _on_fullscreen_toggled(pressed: bool):
    if _initializing:
        return
    _set_fullscreen(pressed)


func _on_lang_selected(index: int):
    var code: String = LANGUAGES[index]["code"]
    TranslationServer.set_locale(code)
    _refresh_ui_texts()
    _save_settings()
    language_changed.emit()


func _refresh_ui_texts():
    title_label.text = tr("SETTINGS_TITLE")
    bgm_label.text = tr("SETTINGS_BGM")
    sfx_label.text = tr("SETTINGS_SFX")
    mute_label.text = tr("SETTINGS_MUTE")
    shake_label.text = tr("SETTINGS_SHAKE")
    fullscreen_label.text = tr("SETTINGS_FULLSCREEN")
    lang_label.text = tr("SETTINGS_LANG")
    menu_btn.text = tr("SETTINGS_MAIN_MENU")
    close_btn.text = tr("SETTINGS_CLOSE")





func _apply_settings():
    SoundManager.bgm_volume = bgm_slider.value / 100.0
    SoundManager.sfx_volume = sfx_slider.value / 100.0
    SoundManager.muted = mute_check.button_pressed
    Global.screen_shake_enabled = shake_check.button_pressed
    _set_fullscreen(fullscreen_check.button_pressed)





func _save_settings():
    var config: = ConfigFile.new()
    config.set_value("audio", "bgm_volume", bgm_slider.value)
    config.set_value("audio", "sfx_volume", sfx_slider.value)
    config.set_value("audio", "muted", mute_check.button_pressed)
    config.set_value("display", "screen_shake", shake_check.button_pressed)
    config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
    config.set_value("display", "language", TranslationServer.get_locale())
    config.save(SAVE_PATH)

func _load_settings():
    var config: = ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        TranslationServer.set_locale("en")
        return


    var saved_lang: String = config.get_value("display", "language", "en")
    TranslationServer.set_locale(saved_lang)



    _pending_bgm = config.get_value("audio", "bgm_volume", 100.0)
    _pending_sfx = config.get_value("audio", "sfx_volume", 100.0)
    _pending_mute = config.get_value("audio", "muted", false)
    _pending_shake = config.get_value("display", "screen_shake", true)
    _pending_fullscreen = config.get_value("display", "fullscreen", true)


var _pending_bgm: float = 100.0
var _pending_sfx: float = 100.0
var _pending_mute: bool = false
var _pending_shake: bool = true
var _pending_fullscreen: bool = true


func _set_fullscreen(fullscreen: bool):
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(Vector2i(1280, 720))
        var screen: = DisplayServer.screen_get_size()
        DisplayServer.window_set_position(Vector2i((screen.x - 1280) / 2, (screen.y - 720) / 2))


func _apply_pending():
    bgm_slider.value = _pending_bgm
    sfx_slider.value = _pending_sfx
    mute_check.button_pressed = _pending_mute
    shake_check.button_pressed = _pending_shake
    fullscreen_check.button_pressed = _pending_fullscreen
