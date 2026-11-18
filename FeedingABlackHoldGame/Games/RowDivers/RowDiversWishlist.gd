extends RefCounted
const URL := "https://store.steampowered.com/app/5520300/Railway_Fury/"

static func open_full_game() -> void:
	if OS.has_feature("web"):
		var window = JavaScriptBridge.get_interface("window")
		if window != null:
			window.call("open", URL, "_blank")
		return
	OS.shell_open(URL)

static func make_button(large := false) -> Button:
	var button := Button.new()
	button.name = "RailwayWishlistButton"
	button.text = "WISHLIST NOW"
	button.tooltip_text = URL
	button.custom_minimum_size.y = 72 if large else 48
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var style = preload("res://Games/RowDivers/RowDiversStyle.gd")
	style.style_button(button)
	button.add_theme_font_size_override("font_size", 30 if large else 24)
	button.set_meta("railway_font_size", 30 if large else 24)
	button.add_theme_color_override("font_color", style.GOLD)
	button.pressed.connect(open_full_game)
	return button
