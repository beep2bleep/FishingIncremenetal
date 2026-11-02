extends HBoxContainer
## Real controller artwork, refreshed when the active device changes.
var context := "battle"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 12)
	ControllerIcons.input_type_changed.connect(_refresh)
	_refresh()

func _refresh(_type = 0, _device = -1) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var controller := RailwayController.using_controller()
	var entries: Array
	if context == "battle":
		entries = [["MOVE", ["joypad/l_stick"] if controller else ["key/a", "key/d"]], ["AIM", ["joypad/r_stick"] if controller else ["mouse/simple"]], ["SHOOT", ["joypad/rt", "joypad/rb"] if controller else ["mouse/left"]], ["POWER", ["joypad/lt", "joypad/lb"] if controller else ["key/space"]], ["PAUSE", ["joypad/start"] if controller else ["key/esc"]]]
	elif context == "upgrades":
		entries = [["BUY", ["joypad/rt", "joypad/rb"] if controller else ["mouse/left"]]]
	else:
		entries = [["SELECT", ["joypad/l_stick"] if controller else ["mouse/simple"]], ["PLAY / CONFIRM", ["joypad/rt", "joypad/rb"] if controller else ["mouse/left"]]]
	for entry in entries:
		for path in entry[1]:
			var icon := TextureRect.new()
			icon.texture = RailwayController.glyph(path)
			icon.custom_minimum_size = Vector2(40, 40)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(icon)
		var label := preload("res://Games/RowDivers/RowDiversStyle.gd").label(entry[0], 18)
		add_child(label)
