extends CanvasLayer
class_name CrtTextMirrorOverlay

const TEXT_MIRROR_CRT_SHADER: Shader = preload("res://Core/CrtTextMirrorComposite.gdshader")

const CRT_SHADER_SYNC_KEYS: Array[String] = [
    "target_vertical_resolution",
    "barrel_distortion",
    "scanline_strength",
    "grille_strength",
    "vignette_strength",
    "noise_strength",
    "chroma_offset",
    "tint",
    "fast_mode",
]
const TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)
const LABEL_COLOR_KEYS := [
    "font_color",
    "font_outline_color",
    "font_shadow_color"
]
const BUTTON_COLOR_KEYS := [
    "font_color",
    "font_hover_color",
    "font_pressed_color",
    "font_focus_color",
    "font_disabled_color",
    "font_hover_pressed_color",
    "font_outline_color",
    "font_shadow_color"
]

var source_root: Node
var apply_screen_barrel_warp := false
var mirror_host: Control
var warp_canvas_group: CanvasGroup
var text_crt_composite_material: ShaderMaterial
var mirror_root: Control
var mirrored_entries: Array[Dictionary] = []

func configure(target_root: Node, layer_index: int = 2, p_apply_screen_barrel_warp: bool = false) -> CrtTextMirrorOverlay:
    source_root = target_root
    layer = layer_index
    apply_screen_barrel_warp = p_apply_screen_barrel_warp
    if is_node_ready():
        _rebuild()
    return self

func sync_text_crt_from(source_material: ShaderMaterial) -> void:
    if text_crt_composite_material == null or source_material == null:
        return
    for key: String in CRT_SHADER_SYNC_KEYS:
        text_crt_composite_material.set_shader_parameter(key, source_material.get_shader_parameter(key))

func _ready() -> void:
    layer = layer if layer != 0 else 2
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_mirror_host_tree()
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _on_viewport_size_changed()
    if source_root != null:
        _rebuild()

func _exit_tree() -> void:
    var vp := get_viewport()
    if vp != null and vp.size_changed.is_connected(_on_viewport_size_changed):
        vp.size_changed.disconnect(_on_viewport_size_changed)

func _build_mirror_host_tree() -> void:
    mirror_host = Control.new()
    mirror_host.name = "CrtTextMirrorHost"
    mirror_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mirror_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(mirror_host)
    mirror_root = Control.new()
    mirror_root.name = "MirrorRoot"
    mirror_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if apply_screen_barrel_warp:
        warp_canvas_group = CanvasGroup.new()
        warp_canvas_group.name = "TextWarpCanvasGroup"
        warp_canvas_group.clear_margin = 96.0
        warp_canvas_group.fit_margin = 96.0
        text_crt_composite_material = ShaderMaterial.new()
        text_crt_composite_material.shader = TEXT_MIRROR_CRT_SHADER
        warp_canvas_group.material = text_crt_composite_material
        mirror_host.add_child(warp_canvas_group)
        warp_canvas_group.add_child(mirror_root)
    else:
        warp_canvas_group = null
        text_crt_composite_material = null
        mirror_host.add_child(mirror_root)
        mirror_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_viewport_size_changed() -> void:
    if mirror_root == null:
        return
    if apply_screen_barrel_warp:
        var sz: Vector2 = get_viewport().get_visible_rect().size
        mirror_root.size = sz
        mirror_root.position = Vector2.ZERO

func _process(_delta: float) -> void:
    if source_root == null or mirror_root == null:
        return
    if mirrored_entries.is_empty():
        _rebuild()
    _sync_entries()

func _rebuild() -> void:
    if source_root == null or mirror_root == null:
        return
    for child in mirror_root.get_children():
        child.queue_free()
    mirrored_entries.clear()
    _collect_text_controls(source_root)
    _sync_entries()

func _collect_text_controls(node: Node) -> void:
    for child in node.get_children():
        if child == self:
            continue
        if child.name in [
            "EditorCrtOverlay",
            "EditorCrtTextMirrorOverlay",
            "MiningCrtOverlay",
            "MiningTextMirrorOverlay",
            "VanguardCrtOverlay",
            "VanguardCrtTextMirrorOverlay",
            "CrtTextMirrorHost",
            "TextWarpCanvasGroup",
        ]:
            continue
        if child is Label:
            _register_label(child as Label)
        elif child is Button:
            _register_button(child as Button)
        _collect_text_controls(child)

func _register_label(source: Label) -> void:
    var captured_colors := _capture_theme_colors(source, LABEL_COLOR_KEYS)
    _hide_original_text(source, LABEL_COLOR_KEYS)
    var mirror := Label.new()
    mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mirror.clip_text = source.clip_text
    mirror.autowrap_mode = source.autowrap_mode
    mirror.text_overrun_behavior = source.text_overrun_behavior
    mirror.horizontal_alignment = source.horizontal_alignment
    mirror.vertical_alignment = source.vertical_alignment
    mirror.visible_characters_behavior = source.visible_characters_behavior
    mirror.theme = source.theme
    mirror.label_settings = source.label_settings
    mirror_root.add_child(mirror)
    mirrored_entries.append({
        "source": source,
        "mirror": mirror,
        "type": "label",
        "colors": captured_colors
    })

func _register_button(source: Button) -> void:
    var captured_colors := _capture_theme_colors(source, BUTTON_COLOR_KEYS)
    _hide_original_text(source, BUTTON_COLOR_KEYS)
    var mirror := Label.new()
    mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mirror.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mirror.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    mirror.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    mirror.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    mirror.theme = source.theme
    mirror_root.add_child(mirror)
    mirrored_entries.append({
        "source": source,
        "mirror": mirror,
        "type": "button",
        "colors": captured_colors
    })

func _hide_original_text(control: Control, color_keys: Array) -> void:
    for color_key in color_keys:
        control.add_theme_color_override(StringName(color_key), TRANSPARENT)

func _capture_theme_colors(control: Control, color_keys: Array) -> Dictionary:
    var colors := {}
    for color_key in color_keys:
        colors[String(color_key)] = control.get_theme_color(StringName(color_key))
    return colors

func _sync_entries() -> void:
    for entry in mirrored_entries:
        var source = entry.get("source")
        var mirror = entry.get("mirror")
        if source == null or mirror == null or not is_instance_valid(source) or not is_instance_valid(mirror):
            continue
        mirror.visible = source.visible and source.is_visible_in_tree()
        mirror.global_position = source.global_position
        mirror.size = source.size
        mirror.rotation = source.rotation
        mirror.scale = source.scale
        if entry.get("type", "") == "label":
            _sync_label(source as Label, mirror, entry.get("colors", {}))
        else:
            _sync_button(source as Button, mirror, entry.get("colors", {}))

func _sync_label(source: Label, mirror: Label, colors: Dictionary) -> void:
    if source == null:
        return
    mirror.text = source.text
    mirror.clip_text = source.clip_text
    mirror.autowrap_mode = source.autowrap_mode
    mirror.text_overrun_behavior = source.text_overrun_behavior
    mirror.horizontal_alignment = source.horizontal_alignment
    mirror.vertical_alignment = source.vertical_alignment
    mirror.label_settings = source.label_settings
    mirror.theme = source.theme
    mirror.add_theme_font_size_override("font_size", source.get_theme_font_size("font_size"))
    mirror.add_theme_color_override("font_color", colors.get("font_color", Color.WHITE))
    mirror.add_theme_color_override("font_outline_color", colors.get("font_outline_color", TRANSPARENT))
    mirror.add_theme_color_override("font_shadow_color", colors.get("font_shadow_color", TRANSPARENT))

func restore_source_text_colors() -> void:
    for entry in mirrored_entries:
        var source = entry.get("source")
        if source == null or not is_instance_valid(source):
            continue
        var colors: Dictionary = entry.get("colors", {})
        var entry_type: String = str(entry.get("type", ""))
        var keys: Array = LABEL_COLOR_KEYS if entry_type == "label" else BUTTON_COLOR_KEYS
        for color_key in keys:
            var key_str := String(color_key)
            if colors.has(key_str):
                source.add_theme_color_override(StringName(color_key), colors[key_str])
    mirrored_entries.clear()

func _sync_button(source: Button, mirror: Label, colors: Dictionary) -> void:
    if source == null:
        return
    mirror.text = source.text
    mirror.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mirror.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    mirror.label_settings = null
    mirror.theme = source.theme
    mirror.add_theme_font_size_override("font_size", source.get_theme_font_size("font_size"))
    var color_key := "font_disabled_color" if source.disabled else "font_color"
    mirror.add_theme_color_override("font_color", colors.get(color_key, colors.get("font_color", Color.WHITE)))
    mirror.add_theme_color_override("font_outline_color", colors.get("font_outline_color", TRANSPARENT))
    mirror.add_theme_color_override("font_shadow_color", colors.get("font_shadow_color", TRANSPARENT))
