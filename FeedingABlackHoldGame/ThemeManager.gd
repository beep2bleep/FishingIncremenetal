extends Node

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

func scale_default_font_sizes():
    for theme: Theme in theme_default_font_size.keys():
        theme.default_font_size = int(theme_default_font_size[theme] * text_scale)
