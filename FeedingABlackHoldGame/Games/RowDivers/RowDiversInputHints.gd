extends HFlowContainer
## Real controller artwork, refreshed when the active device changes.
var context := "battle"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = 1
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 4)
	ControllerIcons.input_type_changed.connect(_refresh)
	RailwayController.menu_changed.connect(_refresh)
	_refresh()

func _refresh(_type = 0, _device = -1) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var controller := RailwayController.using_controller()
	if context in ["menu", "upgrades"]: visible = not controller
	var entries: Array
	if context == "modal":
		entries = [["CURSOR", ["joypad/l_stick"]], ["SELECT", ["joypad/dpad"]], ["CONFIRM", ["joypad/a", "joypad/rt"]]]
		match RailwayController.menu_context:
			"upgrades":
				# Play already has its own glyph beside the button. Keep this strip
				# compact enough to wrap within the space to its left.
				entries = [["CURSOR", ["joypad/l_stick"]], ["SELECT", ["joypad/dpad"]], ["BUY", ["joypad/a"]], ["PAN", ["joypad/r_stick"]], ["ZOOM", ["joypad/lt", "joypad/r_stick"]], ["MENU", ["joypad/y"]], ["SETTINGS", ["joypad/b"]]]
			"results":
				if RailwayController.menu_state.get("cursor_only", false):
					entries = [["MOVE CURSOR", ["joypad/l_stick"]], ["SELECT", ["joypad/a", "joypad/rt"]]]
				else: entries += [["UPGRADES", ["joypad/b"]], ["PLAY AGAIN", ["joypad/start"]]]
			"pause": entries += [["RESUME", ["joypad/b", "joypad/start"]]]
			"tutorial": entries += [["PLAY / RETURN", ["joypad/b", "joypad/start"]]]
			"menu": entries += [["PLAY", ["joypad/start"]], ["SETTINGS", ["joypad/b"]]]
			"ending": entries += [["MAIN MENU", ["joypad/b"]]]
			_: entries += [["SCROLL", ["joypad/r_stick"]], ["BACK", ["joypad/b"]]]
		if RailwayController.menu_state.get("cursor_only", false):
			entries = [["MOVE CURSOR", ["joypad/l_stick"]], ["SELECT", ["joypad/a", "joypad/rt"]]]
			if RailwayController.menu_context == "upgrades":
				entries += [["PAN", ["joypad/r_stick"]], ["ZOOM", ["joypad/lt", "joypad/r_stick"]]]
			else: entries += [["SCROLL", ["joypad/r_stick"]]]
	elif context == "battle":
		entries = [["MOVE", ["joypad/l_stick"] if controller else ["key/a", "key/d"]], ["AIM", ["joypad/r_stick"] if controller else ["mouse/simple"]], ["POWER", ["joypad/lt", "joypad/lb"] if controller else ["key/space"]], ["PAUSE", ["joypad/start"] if controller else ["key/esc"]]]
		if controller: entries += [["RUN", ["joypad/l_stick_click"]]]
	elif context == "upgrades":
		entries = [["SELECT", ["joypad/l_stick"]], ["BUY", ["joypad/a", "joypad/rt"]], ["PAN", ["joypad/r_stick"]], ["ZOOM", ["joypad/lt", "joypad/r_stick"]], ["SETTINGS / BACK", ["joypad/b"]]] if controller else [["BUY", ["mouse/left"]]]
	else:
		entries = [["SELECT", ["joypad/l_stick"]], ["PLAY / CONFIRM", ["joypad/a", "joypad/rt"]], ["SETTINGS / BACK", ["joypad/b"]]] if controller else [["SELECT", ["mouse/simple"]], ["PLAY / CONFIRM", ["mouse/left"]]]
	for entry in entries:
		var group := HBoxContainer.new()
		group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		group.add_theme_constant_override("separation", 6)
		add_child(group)
		for path in entry[1]:
			var icon := TextureRect.new()
			icon.texture = RailwayController.glyph(path)
			icon.custom_minimum_size = Vector2(28, 28)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			group.add_child(icon)
		var label := preload("res://Games/RowDivers/RowDiversStyle.gd").label(entry[0], 15)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		group.add_child(label)
