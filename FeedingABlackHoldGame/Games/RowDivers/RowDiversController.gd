extends Node
## Controller input shared by Railway Fury's battle and menus.
signal action_pressed(action: String)
signal menu_changed
var menu_owner: Node
var menu_surface: Node
var menu_context := ""
var menu_state := {}
var menu_hint: Control
var _syncing_menu := false
var _was_using_controller := false
var battle: Node
var trigger_down := {}
var event_axes := {}
var active_device := -1
var pointer := Vector2.INF
const DEADZONE := 0.2
const UTILITY_BUTTONS := [JOY_BUTTON_START, JOY_BUTTON_BACK, JOY_BUTTON_TOUCHPAD]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.joy_connection_changed.connect(_connection_changed)
	var layer := CanvasLayer.new()
	layer.layer = 250
	add_child(layer)
	menu_hint = PanelContainer.new()
	menu_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	menu_hint.offset_left = 16
	menu_hint.offset_right = -16
	menu_hint.offset_top = -70
	menu_hint.offset_bottom = -10
	layer.add_child(menu_hint)
	var hints = preload("res://Games/RowDivers/RowDiversInputHints.gd").new()
	hints.context = "modal"
	menu_hint.add_child(hints)
	menu_hint.hide()

func configure_menu(owner: Node) -> void:
	menu_owner = owner
	menu_surface = null
	sync_menu()

func _process(_delta: float) -> void:
	if active(): sync_menu()
	elif is_instance_valid(menu_hint): menu_hint.hide()

func native_popup_open() -> bool:
	if not is_instance_valid(menu_owner): return false
	for window in menu_owner.find_children("*", "Window", true, false):
		if window.visible:
			if window is AcceptDialog and not window.has_meta("railway_controller_dialog"):
				window.set_meta("railway_controller_dialog", true)
				window.window_input.connect(_dialog_input.bind(window))
			return true
	return false

func _dialog_input(event: InputEvent, window: Window) -> void:
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B and event.pressed:
		window.hide()
		if window is AcceptDialog: window.canceled.emit()
		window.set_input_as_handled()
		sync_menu()

func sync_menu() -> void:
	if _syncing_menu or not is_instance_valid(menu_hint): return
	_syncing_menu = true
	var was_locked: bool = menu_state.get("input_locked", false)
	menu_state = menu_owner.controller_menu() if is_instance_valid(menu_owner) and menu_owner.has_method("controller_menu") else {}
	# Every Railway menu uses the same pointer/click model. Never switch back to
	# focus navigation when a D-pad or menu shortcut is pressed.
	if menu_state.get("surface") != null: menu_state["cursor_only"] = true
	if native_popup_open(): menu_state["context"] = "dialog"
	var surface: Node = menu_state.get("surface")
	if is_instance_valid(surface) and not _surface_visible(surface): surface = null
	var changed := surface != menu_surface or menu_context != str(menu_state.get("context", "")) or (using_controller() and not _was_using_controller) or was_locked != bool(menu_state.get("input_locked", false))
	_was_using_controller = using_controller()
	if changed and (menu_context == "dialog" or str(menu_state.get("context", "")) == "dialog"):
		# Popup windows receive their own trigger releases, outside this viewport.
		trigger_down.clear()
	menu_surface = surface
	menu_context = str(menu_state.get("context", ""))
	menu_hint.visible = is_instance_valid(surface) and using_controller()
	menu_hint.offset_right = -550 if menu_context == "upgrades" else -16
	if menu_context == "upgrades" and is_instance_valid(menu_owner):
		var play: Control = menu_owner.go_again_button
		if is_instance_valid(play):
			# Include the separate Start glyph, whose width can vary by device.
			menu_hint.offset_right = minf(-16.0, play.get_parent().get_global_rect().position.x - get_viewport().get_visible_rect().size.x - 20.0)
	if is_instance_valid(surface) and _surface_visible(surface):
		_set_pointer_focus(surface, using_controller())
		VirtualCursor.set_gameplay_pointer_hidden(false)
		if not VirtualCursor._scene_enabled: VirtualCursor.set_scene_enabled(true)
		if using_controller() and not native_popup_open():
			if menu_state.get("input_locked", false):
				get_viewport().gui_release_focus()
				if changed: menu_changed.emit()
				_syncing_menu = false
				return
			if menu_state.get("cursor_only", false):
				get_viewport().gui_release_focus()
				VirtualCursor._set_virtual_cursor_active(true)
				if changed:
					VirtualCursor.release_buttons()
					VirtualCursor.move_to_control(menu_state.default)
					menu_changed.emit()
				_syncing_menu = false
				return
			var focused := get_viewport().gui_get_focus_owner()
			if changed or not _in_surface(focused):
				var first: Control = menu_state.get("default")
				if not is_instance_valid(first) or not first.is_visible_in_tree():
					var controls := _menu_controls()
					first = null if controls.is_empty() else controls[0]
				if is_instance_valid(first):
					first.grab_focus()
					_scroll_to(first)
					if changed:
						var cursor_active: bool = VirtualCursor._virtual_cursor_active
						VirtualCursor.move_to_control(first)
						if not cursor_active: VirtualCursor._set_virtual_cursor_active(false)
	if changed: menu_changed.emit()
	_syncing_menu = false

func _set_pointer_focus(surface: Node, pointer_mode: bool) -> void:
	# Mouse clicks can give a Button focus. Releasing it on the following frame
	# cancels a held click before A/RT is released, so cursor controls must not
	# acquire focus in the first place. Restore keyboard focus for real mouse use.
	for control in surface.find_children("*", "Control", true, false):
		if not (control is BaseButton or control is Range): continue
		if pointer_mode:
			if not control.has_meta("railway_pointer_focus_mode"):
				control.set_meta("railway_pointer_focus_mode", control.focus_mode)
			control.focus_mode = Control.FOCUS_NONE
		elif control.has_meta("railway_pointer_focus_mode"):
			control.focus_mode = int(control.get_meta("railway_pointer_focus_mode"))
			control.remove_meta("railway_pointer_focus_mode")

func _surface_visible(surface: Node) -> bool:
	if surface is CanvasItem: return surface.is_visible_in_tree()
	if surface is CanvasLayer: return surface.visible and surface.is_inside_tree()
	return surface.is_inside_tree()

func _in_surface(control: Control) -> bool:
	return is_instance_valid(control) and control.is_visible_in_tree() and is_instance_valid(menu_surface) and (control == menu_surface or menu_surface.is_ancestor_of(control))

func _menu_controls() -> Array[Control]:
	var result: Array[Control] = []
	if not is_instance_valid(menu_surface): return result
	for candidate in menu_surface.find_children("*", "Control", true, false):
		if not (candidate is BaseButton or candidate is Range): continue
		if not candidate.is_visible_in_tree() or candidate.focus_mode == Control.FOCUS_NONE: continue
		if candidate is BaseButton and candidate.disabled: continue
		if candidate.find_parent("RuntimeArtStyle") != null: continue
		result.append(candidate)
	return result

func _scroll_to(control: Control) -> void:
	if not is_instance_valid(control): return
	var parent := control.get_parent()
	while parent != null:
		if parent is ScrollContainer: parent.ensure_control_visible(control)
		parent = parent.get_parent()

func _navigate(button: int) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if menu_context == "upgrades" and menu_owner.controller_tree_navigation(button): return
	var controls := _menu_controls()
	if controls.is_empty(): return
	var step := -1 if button in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT] else 1
	var index := controls.find(focused)
	var target := controls[posmod(index + step, controls.size())]
	target.grab_focus()
	_scroll_to(target)

func _menu_input(event: InputEvent) -> bool:
	if not is_instance_valid(menu_surface) or native_popup_open(): return false
	if menu_state.get("input_locked", false):
		return event is InputEventJoypadButton or event is InputEventMouseButton or event is InputEventAction or event is InputEventKey or (event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT])
	# Start/Select (including Switch +/- and Xbox Menu/View) are explicit
	# shortcuts. Handle them before the cursor-only navigation guard.
	if event is InputEventJoypadButton and event.button_index in UTILITY_BUTTONS:
		if event.pressed:
			var callback: Callable = menu_state.get("start", Callable())
			if callback.is_valid():
				VirtualCursor.release_buttons()
				callback.call()
				sync_menu()
		return true
	if menu_state.get("cursor_only", false) and event is InputEventJoypadButton and event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_B, JOY_BUTTON_START, JOY_BUTTON_Y]:
		return true
	if event is InputEventJoypadButton:
		if event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]:
			VirtualCursor.release_buttons()
			VirtualCursor._set_virtual_cursor_active(false)
			var focused := get_viewport().gui_get_focus_owner()
			if focused is Range and event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]: return false
			if event.pressed: _navigate(event.button_index)
			return true
		if event.button_index in [JOY_BUTTON_B, JOY_BUTTON_START]:
			if event.pressed:
				VirtualCursor.release_buttons()
				var callback: Callable = menu_state.get("start" if event.button_index == JOY_BUTTON_START else "back", Callable())
				if callback.is_valid(): callback.call()
				sync_menu()
			return true
		if event.button_index == JOY_BUTTON_Y and menu_context in ["upgrades", "purchase"]:
			if event.pressed:
				if menu_context == "purchase": menu_owner._cancel_controller_purchase()
				VirtualCursor._set_virtual_cursor_active(false)
				menu_owner.go_again_button.grab_focus()
			return true
		if event.button_index == JOY_BUTTON_A and VirtualCursor._virtual_cursor_active:
			VirtualCursor._emit_mouse_button(MOUSE_BUTTON_LEFT, event.pressed)
			return true
	return false

func active() -> bool:
	return Util.is_row_divers_game_active()

func using_controller() -> bool:
	return ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER

func device() -> int:
	var pads := Input.get_connected_joypads()
	if ControllerIcons._last_controller in pads: return ControllerIcons._last_controller
	return ControllerIcons._last_controller if pads.is_empty() and using_controller() else -1 if pads.is_empty() else int(pads.front())

func read_axis(pad: int, axis: int) -> float:
	if pad in Input.get_connected_joypads(): return Input.get_joy_axis(pad, axis)
	return float(event_axes.get(Vector2i(pad, axis), 0.0))

func stick(x: int, y: int) -> Vector2:
	var pad := device()
	if pad < 0 or not using_controller(): return Vector2.ZERO
	var value := Vector2(read_axis(pad, x), read_axis(pad, y)).limit_length()
	if value.length() <= DEADZONE: return Vector2.ZERO
	return value.normalized() * inverse_lerp(DEADZONE, 1.0, value.length())

func firing() -> bool:
	var pad := device()
	return pad >= 0 and using_controller() and (Input.get_joy_axis(pad, JOY_AXIS_TRIGGER_RIGHT) > 0.55 or Input.is_joy_button_pressed(pad, JOY_BUTTON_RIGHT_SHOULDER))

func playing() -> bool:
	return is_instance_valid(battle) and not battle.suspended and not battle.ended

func _connection_changed(pad: int, connected: bool) -> void:
	if not connected:
		for key in event_axes.keys():
			if key.x == pad: event_axes.erase(key)
		trigger_down.erase(Vector2i(pad, JOY_AXIS_TRIGGER_LEFT))
		trigger_down.erase(Vector2i(pad, JOY_AXIS_TRIGGER_RIGHT))
		if VirtualCursor._left_mouse_down: VirtualCursor._emit_mouse_button(MOUSE_BUTTON_LEFT, false)
		if VirtualCursor._right_mouse_down: VirtualCursor._emit_mouse_button(MOUSE_BUTTON_RIGHT, false)
		if pad == active_device and playing(): action_pressed.emit("pause")

func _input(event: InputEvent) -> void:
	if not active(): return
	if event is InputEventJoypadMotion: event_axes[Vector2i(event.device, event.axis)] = event.axis_value
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > DEADZONE):
		active_device = event.device
		if not using_controller() or ControllerIcons._last_controller != event.device:
			ControllerIcons._set_last_input_type(ControllerIcons.InputType.CONTROLLER, event.device)
		sync_menu()
	if _menu_input(event):
		get_viewport().set_input_as_handled()
		return
	if native_popup_open():
		for window in menu_owner.find_children("*", "AcceptDialog", true, false):
			if window.visible: _dialog_input(event, window)
		return
	var action := ""
	var pressed := false
	if event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT]:
		var key := Vector2i(event.device, event.axis)
		var previous: bool = trigger_down.get(key, false)
		pressed = event.axis_value > (0.35 if previous else 0.55)
		trigger_down[key] = pressed
		if pressed == previous: return
		action = "fire" if event.axis == JOY_AXIS_TRIGGER_RIGHT else "ability"
	elif event is InputEventJoypadButton:
		pressed = event.pressed
		match event.button_index:
			JOY_BUTTON_RIGHT_SHOULDER: action = "fire"
			JOY_BUTTON_LEFT_SHOULDER: action = "ability"
			JOY_BUTTON_START, JOY_BUTTON_BACK, JOY_BUTTON_TOUCHPAD: action = "pause"
			JOY_BUTTON_LEFT_STICK: action = "run"
			JOY_BUTTON_B:
				if is_instance_valid(battle) and not playing(): action = "pause"
	if action.is_empty(): return
	if pressed and (not using_controller() or ControllerIcons._last_controller != event.device):
		ControllerIcons._set_last_input_type(ControllerIcons.InputType.CONTROLLER, event.device)
	if is_instance_valid(battle) and (playing() or action == "pause"):
		if pressed: action_pressed.emit(action)
		get_viewport().set_input_as_handled()
	elif action == "fire":
		if VirtualCursor._scene_enabled and VirtualCursor._virtual_cursor_active:
			VirtualCursor.activate_for_controller()
			VirtualCursor._emit_mouse_button(MOUSE_BUTTON_LEFT, pressed)
		elif pressed:
			var focused := get_viewport().gui_get_focus_owner()
			if focused is BaseButton and focused.is_visible_in_tree() and not focused.disabled:
				# Route through GUI input: emitting pressed bypasses checkboxes,
				# option popups, and buttons configured to activate on release.
				var accept := InputEventAction.new()
				accept.action = "ui_accept"
				accept.pressed = true
				Input.parse_input_event(accept)
				var release := InputEventAction.new()
				release.action = "ui_accept"
				Input.parse_input_event(release)
		get_viewport().set_input_as_handled()

func aim_pointer(delta: float, viewport_size: Vector2) -> Vector2:
	if not pointer.is_finite(): pointer = viewport_size * 0.5
	pointer += stick(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y) * viewport_size.y * 0.9 * delta
	pointer = pointer.clamp(Vector2.ONE * 12, viewport_size - Vector2.ONE * 12)
	return pointer

func glyph(path: String) -> Texture2D:
	return ControllerIcons.parse_path(path)
