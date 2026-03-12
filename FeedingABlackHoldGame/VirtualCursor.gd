extends CanvasLayer

const CURSOR_TEXTURE: Texture2D = preload("res://Art/pointer_c.png")
const CURSOR_SPEED := 1400.0
const STICK_DEADZONE := 0.2
const CURSOR_LAYER := 200

var _scene_enabled := false
var _virtual_cursor_active := false
var _cursor_position := Vector2.ZERO
var _left_mouse_down := false
var _right_mouse_down := false
var _injecting_mouse_event := false
var _ignore_next_mouse_motion := false
var _ignore_next_left_mouse_button := false
var _ignore_next_right_mouse_button := false
var _cursor_sprite: TextureRect

func _ready() -> void:
    layer = CURSOR_LAYER
    process_mode = Node.PROCESS_MODE_ALWAYS
    _cursor_sprite = TextureRect.new()
    _cursor_sprite.name = "VirtualCursorSprite"
    _cursor_sprite.texture = CURSOR_TEXTURE
    _cursor_sprite.size = CURSOR_TEXTURE.get_size()
    _cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _cursor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _cursor_sprite.stretch_mode = TextureRect.STRETCH_KEEP
    _cursor_sprite.top_level = true
    _cursor_sprite.z_index = 1000
    _cursor_sprite.hide()
    add_child(_cursor_sprite)
    set_process(true)
    set_process_input(true)
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _sync_cursor_to_mouse()

func set_scene_enabled(value: bool) -> void:
    _scene_enabled = value
    if _scene_enabled:
        _sync_cursor_to_mouse()
        if ControllerIcons != null and ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            _set_virtual_cursor_active(true)
    else:
        _left_mouse_down = false
        _right_mouse_down = false
        _set_virtual_cursor_active(false)

func activate_for_controller() -> void:
    if not _scene_enabled:
        return
    _set_virtual_cursor_active(true)

func move_to_screen_position(position: Vector2) -> void:
    if not _scene_enabled:
        return
    var previous_position := _cursor_position
    _cursor_position = _clamp_to_viewport(position)
    _set_virtual_cursor_active(true)
    _warp_mouse(_cursor_position)
    _emit_mouse_motion(previous_position, _cursor_position)
    _update_cursor_visual()

func move_to_control(control: Control) -> void:
    if control == null or not is_instance_valid(control):
        return
    move_to_screen_position(control.get_global_rect().get_center())

func get_screen_position() -> Vector2:
    return _cursor_position

func _input(event: InputEvent) -> void:
    if not _scene_enabled:
        return
    if _injecting_mouse_event:
        return

    if event is InputEventMouseMotion:
        var motion_event := event as InputEventMouseMotion
        if _ignore_next_mouse_motion:
            _ignore_next_mouse_motion = false
            return
        _cursor_position = _clamp_to_viewport(motion_event.position)
        _update_cursor_visual()
        _set_virtual_cursor_active(false)
        return

    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT and _ignore_next_left_mouse_button:
            _ignore_next_left_mouse_button = false
            return
        if mouse_event.button_index == MOUSE_BUTTON_RIGHT and _ignore_next_right_mouse_button:
            _ignore_next_right_mouse_button = false
            return
        _cursor_position = _clamp_to_viewport(mouse_event.position)
        _update_cursor_visual()
        _set_virtual_cursor_active(false)
        return

    if event is InputEventJoypadMotion:
        var joy_motion := event as InputEventJoypadMotion
        if not _is_target_device(joy_motion.device):
            return
        if joy_motion.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y] and abs(joy_motion.axis_value) >= STICK_DEADZONE:
            _set_virtual_cursor_active(true)
        return

    if event is InputEventJoypadButton:
        var joy_button := event as InputEventJoypadButton
        if not _is_target_device(joy_button.device):
            return
        if joy_button.button_index == JOY_BUTTON_A:
            _set_virtual_cursor_active(true)
            _emit_mouse_button(MOUSE_BUTTON_LEFT, joy_button.pressed)
            get_viewport().set_input_as_handled()
        elif joy_button.button_index == JOY_BUTTON_B:
            _set_virtual_cursor_active(true)
            _emit_mouse_button(MOUSE_BUTTON_RIGHT, joy_button.pressed)
            get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
    if not _scene_enabled:
        return
    var device := _get_target_device()
    if device == -1:
        return

    var stick := Vector2(
        Input.get_joy_axis(device, JOY_AXIS_LEFT_X),
        Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
    )
    var stick_length := stick.length()
    if stick_length < STICK_DEADZONE:
        return

    _set_virtual_cursor_active(true)
    var strength := inverse_lerp(STICK_DEADZONE, 1.0, min(stick_length, 1.0))
    var move_delta := stick.normalized() * strength * CURSOR_SPEED * delta
    if move_delta == Vector2.ZERO:
        return

    var previous_position := _cursor_position
    _cursor_position = _clamp_to_viewport(_cursor_position + move_delta)
    if _cursor_position.is_equal_approx(previous_position):
        return

    _warp_mouse(_cursor_position)
    _emit_mouse_motion(previous_position, _cursor_position)
    _update_cursor_visual()

func _emit_mouse_motion(previous_position: Vector2, current_position: Vector2) -> void:
    var motion := InputEventMouseMotion.new()
    motion.position = current_position
    motion.global_position = current_position
    motion.relative = current_position - previous_position
    motion.button_mask = _current_button_mask()
    _parse_input_event(motion)

func _emit_mouse_button(button_index: MouseButton, pressed: bool) -> void:
    if button_index == MOUSE_BUTTON_LEFT:
        _left_mouse_down = pressed
        _ignore_next_left_mouse_button = true
    elif button_index == MOUSE_BUTTON_RIGHT:
        _right_mouse_down = pressed
        _ignore_next_right_mouse_button = true

    var mouse_button := InputEventMouseButton.new()
    mouse_button.button_index = button_index
    mouse_button.pressed = pressed
    mouse_button.position = _cursor_position
    mouse_button.global_position = _cursor_position
    mouse_button.button_mask = _current_button_mask()
    _parse_input_event(mouse_button)

func _parse_input_event(event: InputEvent) -> void:
    _injecting_mouse_event = true
    Input.parse_input_event(event)
    _injecting_mouse_event = false

func _current_button_mask() -> MouseButtonMask:
    var mask: int = 0
    if _left_mouse_down:
        mask |= MOUSE_BUTTON_MASK_LEFT
    if _right_mouse_down:
        mask |= MOUSE_BUTTON_MASK_RIGHT
    return mask as MouseButtonMask

func _set_virtual_cursor_active(value: bool) -> void:
    if _virtual_cursor_active == value:
        return
    _virtual_cursor_active = value
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if _virtual_cursor_active else Input.MOUSE_MODE_VISIBLE)
    _cursor_sprite.visible = _virtual_cursor_active and _scene_enabled
    _update_cursor_visual()

func _sync_cursor_to_mouse() -> void:
    _cursor_position = _clamp_to_viewport(get_viewport().get_mouse_position())
    _update_cursor_visual()

func _warp_mouse(position: Vector2) -> void:
    var viewport := get_viewport()
    if viewport == null:
        return
    _ignore_next_mouse_motion = true
    viewport.warp_mouse(position)

func _update_cursor_visual() -> void:
    if _cursor_sprite == null:
        return
    _cursor_sprite.position = _cursor_position

func _clamp_to_viewport(position: Vector2) -> Vector2:
    var viewport := get_viewport()
    if viewport == null:
        return position
    var size := viewport.get_visible_rect().size
    return Vector2(
        clamp(position.x, 0.0, max(size.x - 1.0, 0.0)),
        clamp(position.y, 0.0, max(size.y - 1.0, 0.0))
    )

func _get_target_device() -> int:
    var connected := Input.get_connected_joypads()
    if connected.is_empty():
        return -1
    if ControllerIcons != null and ControllerIcons._last_controller in connected:
        return int(ControllerIcons._last_controller)
    return int(connected[0])

func _is_target_device(device: int) -> bool:
    var target_device := _get_target_device()
    return target_device != -1 and device == target_device

func _on_viewport_size_changed() -> void:
    _cursor_position = _clamp_to_viewport(_cursor_position)
    _update_cursor_visual()
