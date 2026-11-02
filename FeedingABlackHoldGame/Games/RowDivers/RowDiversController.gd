extends Node
## Controller input shared by Railway Fury's battle and menus.
signal action_pressed(action: String)
var battle: Node
var trigger_down := {}
var pointer := Vector2.INF
const DEADZONE := 0.2

func _ready() -> void:
	Input.joy_connection_changed.connect(_connection_changed)

func active() -> bool:
	return Util.is_row_divers_game_active()

func using_controller() -> bool:
	return ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER

func device() -> int:
	var pads := Input.get_connected_joypads()
	if ControllerIcons._last_controller in pads: return ControllerIcons._last_controller
	return -1 if pads.is_empty() else int(pads.front())

func stick(x: int, y: int) -> Vector2:
	var pad := device()
	if pad < 0 or not using_controller(): return Vector2.ZERO
	var value := Vector2(Input.get_joy_axis(pad, x), Input.get_joy_axis(pad, y)).limit_length()
	if value.length() <= DEADZONE: return Vector2.ZERO
	return value.normalized() * inverse_lerp(DEADZONE, 1.0, value.length())

func firing() -> bool:
	var pad := device()
	return pad >= 0 and using_controller() and (Input.get_joy_axis(pad, JOY_AXIS_TRIGGER_RIGHT) > 0.55 or Input.is_joy_button_pressed(pad, JOY_BUTTON_RIGHT_SHOULDER))

func playing() -> bool:
	return is_instance_valid(battle) and not battle.suspended and not battle.ended

func _connection_changed(pad: int, connected: bool) -> void:
	if not connected:
		trigger_down.erase(Vector2i(pad, JOY_AXIS_TRIGGER_LEFT))
		trigger_down.erase(Vector2i(pad, JOY_AXIS_TRIGGER_RIGHT))
		if VirtualCursor._left_mouse_down: VirtualCursor._emit_mouse_button(MOUSE_BUTTON_LEFT, false)

func _input(event: InputEvent) -> void:
	if not active(): return
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
			JOY_BUTTON_START: action = "pause"
			JOY_BUTTON_LEFT_STICK: action = "run"
	if action.is_empty(): return
	if pressed and (not using_controller() or ControllerIcons._last_controller != event.device):
		ControllerIcons._set_last_input_type(ControllerIcons.InputType.CONTROLLER, event.device)
	if is_instance_valid(battle) and (playing() or action == "pause"):
		if pressed: action_pressed.emit(action)
		get_viewport().set_input_as_handled()
	elif action == "fire":
		if VirtualCursor._scene_enabled:
			VirtualCursor.activate_for_controller()
			VirtualCursor._emit_mouse_button(MOUSE_BUTTON_LEFT, pressed)
		elif pressed:
			var focused := get_viewport().gui_get_focus_owner()
			if focused is BaseButton and focused.is_visible_in_tree() and not focused.disabled: focused.pressed.emit()
		get_viewport().set_input_as_handled()

func aim_pointer(delta: float, viewport_size: Vector2) -> Vector2:
	if not pointer.is_finite(): pointer = viewport_size * 0.5
	pointer += stick(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y) * viewport_size.y * 0.9 * delta
	pointer = pointer.clamp(Vector2.ONE * 12, viewport_size - Vector2.ONE * 12)
	return pointer

func glyph(path: String) -> Texture2D:
	return ControllerIcons.parse_path(path)
