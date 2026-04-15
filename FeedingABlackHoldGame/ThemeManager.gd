extends Node

const FONT_MONTSERRAT: FontFile = preload("res://Theme/Montserrat-SemiBold.ttf")
const FONT_POPPINS_BOLD: FontFile = preload("res://Theme/Poppins-Bold.ttf")
const FONT_POPPINS_REGULAR: FontFile = preload("res://Theme/Poppins-Regular.ttf")
const FONT_POPPINS_SEMIBOLD: FontFile = preload("res://Theme/Poppins-SemiBold.ttf")
const FONT_ROBOTO_MONO_SEMIBOLD: FontFile = preload("res://Theme/RobotoMono-SemiBold.ttf")
const FONT_EXO2_BOLD: FontFile = preload("res://Theme/Exo2-Bold.ttf")
const FONT_EXO2_BOLD_ITALIC: FontFile = preload("res://Theme/Exo2-BoldItalic.ttf")

const FONT_FALLBACK_JP: FontFile = preload("res://Theme/Fallbacks/NotoSansCJKjp-Regular.otf")
const FONT_FALLBACK_SC: FontFile = preload("res://Theme/Fallbacks/NotoSansCJKsc-Regular.otf")
const FONT_FALLBACK_KR: FontFile = preload("res://Theme/Fallbacks/NotoSansCJKkr-Regular.otf")
const FONT_FALLBACK_THAI: FontFile = preload("res://Theme/Fallbacks/NotoSansThai-Regular.ttf")

const THEME_FONT_OVERRIDES := [
    {"type": "CheckBox", "name": "font"},
    {"type": "OptionButton", "name": "font"},
    {"type": "PopupMenu", "name": "font"},
    {"type": "PopupMenu", "name": "font_separator"},
    {"type": "PopupMenu", "name": "title_font"},
]

@export var themes: Array[Theme]
var theme_default_font_size = {}

var text_scale = 1.0:
    set(new_value):
        text_scale = new_value
        scale_default_font_sizes()
        SaveHandler.update_text_scale(text_scale)
        SignalBus.text_size_changed.emit()


func _ready():
    if SaveHandler.first_time_load == true and SteamHandler.is_steam_deck():
        SaveHandler.update_text_scale(1.5)

    text_scale = SaveHandler.text_scale
    for theme: Theme in themes:
        theme_default_font_size[theme] = theme.default_font_size

    _apply_locale_font_fallbacks()
    scale_default_font_sizes()

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        _apply_locale_font_fallbacks()

func scale_default_font_sizes():
    for theme: Theme in theme_default_font_size.keys():
        theme.default_font_size = int(theme_default_font_size[theme] * text_scale)

func _apply_locale_font_fallbacks() -> void:
    var fallback_fonts: Array[Font] = _get_locale_fallback_fonts()
    var shared_fonts: Array[FontFile] = [
        FONT_MONTSERRAT,
        FONT_POPPINS_BOLD,
        FONT_POPPINS_REGULAR,
        FONT_POPPINS_SEMIBOLD,
        FONT_ROBOTO_MONO_SEMIBOLD,
        FONT_EXO2_BOLD,
        FONT_EXO2_BOLD_ITALIC,
    ]
    var changed: bool = false
    for font_file: FontFile in shared_fonts:
        changed = _apply_fallbacks_to_font(font_file, fallback_fonts) or changed

    for theme: Theme in themes:
        changed = _apply_fallbacks_to_font(theme.default_font, fallback_fonts) or changed
        for entry: Dictionary in THEME_FONT_OVERRIDES:
            changed = _apply_fallbacks_to_font(theme.get_font(str(entry["name"]), str(entry["type"])), fallback_fonts) or changed
        if changed:
            theme.emit_changed()

func _get_locale_fallback_fonts() -> Array[Font]:
    return [FONT_FALLBACK_SC, FONT_FALLBACK_JP, FONT_FALLBACK_KR, FONT_FALLBACK_THAI]

func _apply_fallbacks_to_font(font: Font, fallback_fonts: Array[Font]) -> bool:
    if font is FontFile:
        var font_file := font as FontFile
        if font_file.fallbacks == fallback_fonts:
            return false
        font_file.fallbacks = fallback_fonts
        font_file.emit_changed()
        return true
    return false
