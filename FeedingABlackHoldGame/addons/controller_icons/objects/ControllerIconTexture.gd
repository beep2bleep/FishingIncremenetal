@tool
@icon("res://addons/controller_icons/objects/controller_texture_icon.svg")
extends Texture2D
class_name ControllerIconTexture
















































@export var path: String = "":
    set(_path):
        path = _path
        _load_texture_path()

enum ShowMode{
    ANY, 
    KEYBOARD_MOUSE, 
    CONTROLLER
}



@export var show_mode: ShowMode = ShowMode.ANY:
    set(_show_mode):
        show_mode = _show_mode
        _load_texture_path()










@export var force_controller_icon_style: ControllerSettings.Devices = ControllerSettings.Devices.NONE:
    set(_force_controller_icon_style):
        force_controller_icon_style = _force_controller_icon_style
        _load_texture_path()

enum ForceType{
    NONE, 
    KEYBOARD_MOUSE, 
    CONTROLLER, 
}






@export var force_type: ForceType = ForceType.NONE:
    set(_force_type):
        force_type = _force_type
        _load_texture_path()

enum ForceDevice{
    DEVICE_0, 
    DEVICE_1, 
    DEVICE_2, 
    DEVICE_3, 
    DEVICE_4, 
    DEVICE_5, 
    DEVICE_6, 
    DEVICE_7, 
    DEVICE_8, 
    DEVICE_9, 
    DEVICE_10, 
    DEVICE_11, 
    DEVICE_12, 
    DEVICE_13, 
    DEVICE_14, 
    DEVICE_15, 
    ANY
}




@export var force_device: ForceDevice = ForceDevice.ANY:
    set(_force_device):
        force_device = _force_device
        _load_texture_path()

@export_subgroup("Text Rendering")

@export var custom_label_settings: LabelSettings:
    set(_custom_label_settings):
        custom_label_settings = _custom_label_settings
        _load_texture_path()


        _textures = _textures









func get_tts_string() -> String:
    if force_type:
        return ControllerIcons.parse_path_to_tts(path, force_type - 1)
    else:
        return ControllerIcons.parse_path_to_tts(path)

func _can_be_shown():
    match show_mode:
        1:
            return ControllerIcons._last_input_type == ControllerIcons.InputType.KEYBOARD_MOUSE
        2:
            return ControllerIcons._last_input_type == ControllerIcons.InputType.CONTROLLER
        0, _:
            return true

var _textures: Array[Texture2D]:
    set(__textures):



        for tex in __textures:
            if tex and tex.is_connected("changed", _reload_resource):
                tex.disconnect("changed", _reload_resource)

        if _label_settings and _label_settings.is_connected("changed", _on_label_settings_changed):
            _label_settings.disconnect("changed", _on_label_settings_changed)

        _textures = __textures
        _label_settings = null
        if _textures and _textures.size() > 1:
            _label_settings = custom_label_settings
            if not _label_settings:
                _label_settings = ControllerIcons._settings.custom_label_settings
            if not _label_settings:
                _label_settings = LabelSettings.new()
            _label_settings.connect("changed", _on_label_settings_changed)
            _font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
            _on_label_settings_changed()



        for tex in __textures:
            if tex:
                tex.connect("changed", _reload_resource)

var _font: Font
var _label_settings: LabelSettings
var _text_size: Vector2

func _on_label_settings_changed():
    _font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
    _text_size = _font.get_string_size("+", HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size)
    _reload_resource()

func _reload_resource():
    _dirty = true
    emit_changed()

func _load_texture_path_impl():
    var textures: Array[Texture2D] = []
    if ControllerIcons.is_node_ready() and _can_be_shown():
        var input_type = ControllerIcons._last_input_type if force_type == ForceType.NONE else force_type - 1
        if ControllerIcons.get_path_type(path) == ControllerIcons.PathType.INPUT_ACTION:
            var event: = ControllerIcons.get_matching_event(path, input_type)
            textures.append_array(ControllerIcons.parse_event_modifiers(event))
        var target_device = force_device if force_device != ForceDevice.ANY else ControllerIcons._last_controller
        var tex: = ControllerIcons.parse_path(path, input_type, target_device, force_controller_icon_style)
        if tex:
            textures.append(tex)
    _textures = textures
    _reload_resource()

func _load_texture_path():

    if OS.get_thread_caller_id() != OS.get_main_thread_id():



        ControllerIcons._defer_texture_load(_load_texture_path_impl)
    else:
        _load_texture_path_impl()

func _init():
    ControllerIcons.input_type_changed.connect(_on_input_type_changed)

func _on_input_type_changed(input_type: int, controller: int):
    _load_texture_path()


const _NULL_SIZE: = 2

func _get_width() -> int:
    if _can_be_shown():
        var ret: = _textures.reduce( func(accum: int, texture: Texture2D):
            if texture:
                return accum + texture.get_width()
            return accum
        , 0)
        if _label_settings:
            ret += max(0, _textures.size() - 1) * _text_size.x


        return ret if ret > 0 else _NULL_SIZE
    return _NULL_SIZE

func _get_height() -> int:
    if _can_be_shown():
        var ret: = _textures.reduce( func(accum: int, texture: Texture2D):
            if texture:
                return max(accum, texture.get_height())
            return accum
        , 0)
        if _label_settings and _textures.size() > 1:
            ret = max(ret, _text_size.y)


        return ret if ret > 0 else _NULL_SIZE
    return _NULL_SIZE

func _has_alpha() -> bool:
    return _textures.any( func(texture: Texture2D):
        return texture.has_alpha()
    )

func _is_pixel_opaque(x, y) -> bool:



    return true

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool):
    var position: = pos

    for i in range(_textures.size()):
        var tex: Texture2D = _textures[i]
        if !tex: continue

        if i != 0:

            var font_position: = Vector2(
                position.x, 
                position.y + (get_height() - _text_size.y) / 2.0
            )
            _draw_text(to_canvas_item, font_position, "+")
            position.x += _text_size.x

        tex.draw(to_canvas_item, position, modulate, transpose)
        position.x += tex.get_width()

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool):
    var position: = rect.position
    var width_ratio: = rect.size.x / _get_width()
    var height_ratio: = rect.size.y / _get_height()

    for i in range(_textures.size()):
        var tex: Texture2D = _textures[i]
        if !tex: continue

        if i != 0:

            var font_position: = Vector2(
                position.x + (_text_size.x * width_ratio) / 2 - (_text_size.x / 2), 
                position.y + (rect.size.y - _text_size.y) / 2.0
            )
            _draw_text(to_canvas_item, font_position, "+")
            position.x += _text_size.x * width_ratio

        var size: = tex.get_size() * Vector2(width_ratio, height_ratio)
        tex.draw_rect(to_canvas_item, Rect2(position, size), tile, modulate, transpose)
        position.x += size.x

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool):
    var position: = rect.position
    var width_ratio: = rect.size.x / _get_width()
    var height_ratio: = rect.size.y / _get_height()

    for i in range(_textures.size()):
        var tex: Texture2D = _textures[i]
        if !tex: continue

        if i != 0:

            var font_position: = Vector2(
                position.x + (_text_size.x * width_ratio) / 2 - (_text_size.x / 2), 
                position.y + (rect.size.y - _text_size.y) / 2.0
            )
            _draw_text(to_canvas_item, font_position, "+")
            position.x += _text_size.x * width_ratio

        var size: = tex.get_size() * Vector2(width_ratio, height_ratio)
        var src_rect_ratio: = Vector2(
            tex.get_width() / float(_get_width()), 
            tex.get_height() / float(_get_height())
        )
        var tex_src_rect: = Rect2(
            src_rect.position * src_rect_ratio, 
            src_rect.size * src_rect_ratio
        )

        tex.draw_rect_region(to_canvas_item, Rect2(position, size), tex_src_rect, modulate, transpose, clip_uv)
        position.x += size.x

func _draw_text(to_canvas_item: RID, font_position: Vector2, text: String):
    font_position.y += _font.get_ascent(_label_settings.font_size)

    if _label_settings.shadow_color.a > 0:
        _font.draw_string(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_color)
        if _label_settings.shadow_size > 0:
            _font.draw_string_outline(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_size, _label_settings.shadow_color)
    if _label_settings.outline_color.a > 0 and _label_settings.outline_size > 0:
            _font.draw_string_outline(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.outline_size, _label_settings.outline_color)
    _font.draw_string(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_CENTER, -1, _label_settings.font_size, _label_settings.font_color)

var _helper_viewport: Viewport
var _is_stitching_texture: bool = false
func _stitch_texture():
    if _textures.is_empty():
        return

    _is_stitching_texture = true

    var font_image: Image
    if _textures.size() > 1:

        _helper_viewport = SubViewport.new()

        _helper_viewport.size = _text_size + Vector2(3, 0)
        _helper_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        _helper_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
        _helper_viewport.transparent_bg = true

        var label: = Label.new()
        label.label_settings = _label_settings
        label.text = "+"
        label.position = Vector2.ZERO
        _helper_viewport.add_child(label)

        ControllerIcons.add_child(_helper_viewport)
        await RenderingServer.frame_post_draw
        font_image = _helper_viewport.get_texture().get_image()
        ControllerIcons.remove_child(_helper_viewport)
        _helper_viewport.free()

    var position: = Vector2i(0, 0)
    var img: Image
    for i in range(_textures.size()):
        if !_textures[i]: continue

        if i != 0:

            var region: = font_image.get_used_rect()
            var font_position: = Vector2i(
                position.x, 
                position.y + (get_height() - region.size.y) / 2
            )
            img.blit_rect(font_image, region, font_position)
            position.x += ceili(region.size.x)

        var texture_raw: = _textures[i].get_image()
        texture_raw.decompress()
        if not img:
            img = Image.create(_get_width(), _get_height(), true, texture_raw.get_format())

        img.blit_rect(texture_raw, Rect2i(0, 0, texture_raw.get_width(), texture_raw.get_height()), position)
        position.x += texture_raw.get_width()

    _is_stitching_texture = false
    _dirty = false
    _texture_3d = ImageTexture.create_from_image(img)
    emit_changed()



var _dirty: = true
var _texture_3d: Texture
func _get_rid():
    if _dirty:
        if not _is_stitching_texture:


            _stitch_texture()
            if _is_stitching_texture:
                return 0
        else:
            return 0
    return _texture_3d.get_rid() if not _textures.is_empty() else 0
