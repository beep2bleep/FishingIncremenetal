extends CanvasLayer

class SparkCanvas extends Node2D:
    var owner_ref: CanvasLayer

    func _draw() -> void:
        if owner_ref == null:
            return
        var sparks: Array = owner_ref.get("_open_pit_cursor_sparks")
        var base_color: Color = owner_ref.get("_open_pit_cursor_color")
        if sparks.is_empty():
            return
        for spark_variant in sparks:
            var spark: Dictionary = spark_variant
            var max_life := maxf(float(spark.get("max_life", 0.3)), 0.001)
            var alpha := clampf(float(spark.get("life", 0.0)) / max_life, 0.0, 1.0)
            var color := Color(spark.get("color", base_color))
            color.a = alpha
            var pos := Vector2(spark.get("pos", Vector2.ZERO))
            var vel := Vector2(spark.get("vel", Vector2.ZERO))
            if vel.length() > 0.01:
                draw_line(pos, pos - vel.normalized() * lerpf(2.0, 9.0, alpha), color, 1.5)
            draw_circle(pos, lerpf(0.8, 2.0, alpha), color)

const CURSOR_TEXTURE: Texture2D = preload("res://Art/pointer_c.png")
const CURSOR_SPEED := 1400.0
const STICK_DEADZONE := 0.2
const CURSOR_LAYER := 200
const OPEN_PIT_ORBIT_CURSOR_SIZE := 5
const OPEN_PIT_CURSOR_COLOR := Color(0.88, 0.97, 1.0, 1.0)
const OPEN_PIT_CURSOR_SPARK_COUNT := 12
const OPEN_PIT_CURSOR_SHADER_CODE := """
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

void fragment() {
    vec4 cursor_tex = texture(TEXTURE, UV);
    vec4 under = texture(screen_tex, SCREEN_UV);
    vec3 inverted = vec3(1.0) - under.rgb;
    COLOR = vec4(inverted, cursor_tex.a);
}
"""

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
var _cursor_texture: Texture2D
var _cursor_hotspot := Vector2.ZERO
var _open_pit_orbit_cursor_texture: Texture2D
var _open_pit_cursor_enabled := false
var _open_pit_cursor_shader: Shader
var _open_pit_cursor_material: ShaderMaterial
var _open_pit_cursor_color := OPEN_PIT_CURSOR_COLOR
var _open_pit_cursor_sparks: Array[Dictionary] = []
var _spark_canvas: SparkCanvas

func _ready() -> void:
    layer = CURSOR_LAYER
    process_mode = Node.PROCESS_MODE_ALWAYS
    _cursor_sprite = TextureRect.new()
    _cursor_sprite.name = "VirtualCursorSprite"
    _cursor_texture = CURSOR_TEXTURE
    _cursor_sprite.texture = _cursor_texture
    _cursor_sprite.size = _cursor_texture.get_size()
    _cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _cursor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _cursor_sprite.stretch_mode = TextureRect.STRETCH_KEEP
    _cursor_sprite.top_level = true
    _cursor_sprite.z_index = 1000
    _cursor_sprite.hide()
    add_child(_cursor_sprite)
    _spark_canvas = SparkCanvas.new()
    _spark_canvas.owner_ref = self
    _spark_canvas.top_level = true
    _spark_canvas.z_index = 999
    add_child(_spark_canvas)
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

func is_injecting_mouse_event() -> bool:
    return _injecting_mouse_event

func use_open_pit_orbit_cursor(enabled: bool) -> void:
    _open_pit_cursor_enabled = enabled
    if enabled:
        if _open_pit_orbit_cursor_texture == null:
            _open_pit_orbit_cursor_texture = _build_open_pit_orbit_cursor_texture()
        if _open_pit_cursor_material == null:
            _ensure_open_pit_cursor_material()
        _set_cursor_texture(_open_pit_orbit_cursor_texture, Vector2(2.0, 2.0))
        if _cursor_sprite != null:
            _cursor_sprite.modulate = _open_pit_cursor_color
            _cursor_sprite.material = _open_pit_cursor_material
    else:
        _set_cursor_texture(CURSOR_TEXTURE, Vector2.ZERO)
        if _cursor_sprite != null:
            _cursor_sprite.modulate = Color.WHITE
            _cursor_sprite.material = null
    _refresh_cursor_display_mode()

func use_open_pit_empire_cursor(enabled: bool) -> void:
    use_open_pit_orbit_cursor(enabled)

func set_open_pit_empire_cursor_combo(combo_ratio: float) -> void:
    var t := clampf(combo_ratio, 0.0, 1.0)
    _open_pit_cursor_color = OPEN_PIT_CURSOR_COLOR.lerp(Color(1.0, 0.18, 0.12, 1.0), t)
    if _cursor_sprite != null and _open_pit_cursor_enabled:
        _cursor_sprite.modulate = _open_pit_cursor_color

func burst_open_pit_empire_cursor_sparks(intensity: float = 1.0) -> void:
    var count := maxi(6, int(round(OPEN_PIT_CURSOR_SPARK_COUNT * clampf(intensity, 0.5, 2.0))))
    for _i in range(count):
        var max_life := randf_range(0.22, 0.42)
        _open_pit_cursor_sparks.append({
            "pos": _cursor_position,
            "vel": Vector2.from_angle(randf() * TAU) * randf_range(44.0, 118.0) * clampf(intensity, 0.5, 2.0),
            "life": max_life,
            "max_life": max_life,
            "color": _open_pit_cursor_color.lerp(Color(1.0, 0.9, 0.65, 1.0), randf_range(0.25, 0.85)),
        })
    if _spark_canvas != null:
        _spark_canvas.queue_redraw()

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
        elif joy_button.button_index == JOY_BUTTON_B:
            _set_virtual_cursor_active(true)
            _emit_mouse_button(MOUSE_BUTTON_RIGHT, joy_button.pressed)

func _process(delta: float) -> void:
    if not _scene_enabled:
        return
    for idx in range(_open_pit_cursor_sparks.size() - 1, -1, -1):
        var spark := _open_pit_cursor_sparks[idx]
        spark["life"] = float(spark.get("life", 0.0)) - delta
        if float(spark.get("life", 0.0)) <= 0.0:
            _open_pit_cursor_sparks.remove_at(idx)
            continue
        spark["pos"] = Vector2(spark.get("pos", Vector2.ZERO)) + Vector2(spark.get("vel", Vector2.ZERO)) * delta
        spark["vel"] = Vector2(spark.get("vel", Vector2.ZERO)) * pow(0.18, delta)
        _open_pit_cursor_sparks[idx] = spark
    if _spark_canvas != null and not _open_pit_cursor_sparks.is_empty():
        _spark_canvas.queue_redraw()
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
    _refresh_cursor_display_mode()
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
    _cursor_sprite.position = _cursor_position - _cursor_hotspot
    if _spark_canvas != null:
        _spark_canvas.position = Vector2.ZERO

func _set_cursor_texture(texture: Texture2D, hotspot: Vector2) -> void:
    _cursor_texture = texture
    _cursor_hotspot = hotspot
    if _cursor_sprite != null:
        _cursor_sprite.texture = texture
        _cursor_sprite.size = texture.get_size() if texture != null else Vector2.ZERO
    Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, hotspot)
    _update_cursor_visual()

func _build_open_pit_orbit_cursor_texture() -> Texture2D:
    var image := Image.create(OPEN_PIT_ORBIT_CURSOR_SIZE, OPEN_PIT_ORBIT_CURSOR_SIZE, false, Image.FORMAT_RGBA8)
    image.fill(Color(0.0, 0.0, 0.0, 0.0))
    for x in range(OPEN_PIT_ORBIT_CURSOR_SIZE):
        for y in range(OPEN_PIT_ORBIT_CURSOR_SIZE):
            image.set_pixel(x, y, Color.WHITE)
    return ImageTexture.create_from_image(image)

func _ensure_open_pit_cursor_material() -> void:
    if _open_pit_cursor_material != null:
        return
    _open_pit_cursor_shader = Shader.new()
    _open_pit_cursor_shader.code = OPEN_PIT_CURSOR_SHADER_CODE
    _open_pit_cursor_material = ShaderMaterial.new()
    _open_pit_cursor_material.shader = _open_pit_cursor_shader

func _refresh_cursor_display_mode() -> void:
    if _cursor_sprite == null:
        return
    var force_sprite_cursor: bool = _open_pit_cursor_enabled and _scene_enabled
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if force_sprite_cursor or _virtual_cursor_active else Input.MOUSE_MODE_VISIBLE)
    _cursor_sprite.visible = _scene_enabled and (force_sprite_cursor or _virtual_cursor_active)

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
