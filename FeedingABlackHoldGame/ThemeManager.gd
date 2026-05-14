extends Node

const FONT_MONTSERRAT: FontFile = preload("res://Theme/Montserrat-SemiBold.ttf")
const FONT_POPPINS_BOLD: FontFile = preload("res://Theme/Poppins-Bold.ttf")
const FONT_POPPINS_REGULAR: FontFile = preload("res://Theme/Poppins-Regular.ttf")
const FONT_POPPINS_SEMIBOLD: FontFile = preload("res://Theme/Poppins-SemiBold.ttf")
const FONT_ROBOTO_MONO_SEMIBOLD: FontFile = preload("res://Theme/RobotoMono-SemiBold.ttf")
const FONT_EXO2_BOLD: FontFile = preload("res://Theme/Exo2-Bold.ttf")
const FONT_EXO2_BOLD_ITALIC: FontFile = preload("res://Theme/Exo2-BoldItalic.ttf")
const WEB_FONT_WARMUP_TEXT := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 $%.,:;!?+-*/()[]#"
const WEB_FONT_WARMUP_SIZES := [11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 36, 42, 46, 52, 72, 84]

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

    scale_default_font_sizes()
    if OS.has_feature("web"):
        call_deferred("_warmup_web_font_glyphs")

func _notification(what: int) -> void:
    pass

func scale_default_font_sizes():
    for theme: Theme in theme_default_font_size.keys():
        theme.default_font_size = int(theme_default_font_size[theme] * text_scale)

func _warmup_web_font_glyphs() -> void:
    var fonts: Array[FontFile] = [
        FONT_MONTSERRAT,
        FONT_POPPINS_BOLD,
        FONT_POPPINS_REGULAR,
        FONT_POPPINS_SEMIBOLD,
        FONT_ROBOTO_MONO_SEMIBOLD,
        FONT_EXO2_BOLD,
        FONT_EXO2_BOLD_ITALIC,
    ]
    for font in fonts:
        for size in WEB_FONT_WARMUP_SIZES:
            font.get_string_size(WEB_FONT_WARMUP_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(size))
