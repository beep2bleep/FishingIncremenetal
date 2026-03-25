extends CanvasLayer
class_name MiningTextMirrorOverlay

const TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)
const LABEL_COLOR_KEYS := [
	"font_color",
	"font_outline_color",
	"font_shadow_color"
]
const RICH_TEXT_COLOR_KEYS := [
	"default_color",
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

var source_root: Control
var mirror_root: Control
var mirrored_entries: Array[Dictionary] = []

func configure(target_root: Control, layer_index: int = 2) -> MiningTextMirrorOverlay:
	source_root = target_root
	layer = layer_index
	if is_node_ready():
		_rebuild()
	return self

func _ready() -> void:
	layer = layer if layer != 0 else 2
	process_mode = Node.PROCESS_MODE_ALWAYS
	mirror_root = Control.new()
	mirror_root.name = "MirrorRoot"
	mirror_root.anchor_left = 0.0
	mirror_root.anchor_top = 0.0
	mirror_root.anchor_right = 1.0
	mirror_root.anchor_bottom = 1.0
	mirror_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mirror_root)
	if source_root != null:
		_rebuild()

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
		if child == self or child is CanvasLayer:
			continue
		if child is Label:
			_register_label(child as Label)
		elif child is RichTextLabel:
			_register_rich_text_label(child as RichTextLabel)
		elif child is Button:
			_register_button(child as Button)
		_collect_text_controls(child)

func _register_label(source: Label) -> void:
	var cached_colors := _capture_theme_colors(source, LABEL_COLOR_KEYS)
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
	_hide_original_text(source, LABEL_COLOR_KEYS)
	mirrored_entries.append({
		"source": source,
		"mirror": mirror,
		"type": "label",
		"cached_colors": cached_colors
	})

func _register_rich_text_label(source: RichTextLabel) -> void:
	var cached_colors := _capture_theme_colors(source, RICH_TEXT_COLOR_KEYS)
	var mirror := RichTextLabel.new()
	mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mirror.bbcode_enabled = source.bbcode_enabled
	mirror.fit_content = source.fit_content
	mirror.scroll_active = false
	mirror.autowrap_mode = source.autowrap_mode
	mirror.theme = source.theme
	mirror_root.add_child(mirror)
	_hide_original_text(source, RICH_TEXT_COLOR_KEYS)
	mirrored_entries.append({
		"source": source,
		"mirror": mirror,
		"type": "rich_text",
		"cached_colors": cached_colors
	})

func _register_button(source: Button) -> void:
	var cached_colors := _capture_theme_colors(source, BUTTON_COLOR_KEYS)
	var mirror := Label.new()
	mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mirror.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mirror.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mirror.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mirror.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	mirror.theme = source.theme
	mirror_root.add_child(mirror)
	_hide_original_text(source, BUTTON_COLOR_KEYS)
	mirrored_entries.append({
		"source": source,
		"mirror": mirror,
		"type": "button",
		"cached_colors": cached_colors
	})

func _hide_original_text(control: Control, color_keys: Array) -> void:
	for color_key in color_keys:
		control.add_theme_color_override(StringName(color_key), TRANSPARENT)

func _capture_theme_colors(control: Control, color_keys: Array) -> Dictionary:
	var cached_colors := {}
	for color_key in color_keys:
		cached_colors[color_key] = control.get_theme_color(StringName(color_key))
	return cached_colors

func _sync_entries() -> void:
	for entry in mirrored_entries:
		# NOTE: Avoid typed assignment here.
		# In Godot 4, assigning an invalid previously-freed instance into a typed variable
		# can throw before we get a chance to check `is_instance_valid()`.
		var source = entry.get("source")
		var mirror = entry.get("mirror")
		if source == null or mirror == null or not is_instance_valid(source) or not is_instance_valid(mirror):
			continue
		mirror.visible = source.visible and source.is_visible_in_tree()
		mirror.global_position = source.global_position
		mirror.size = source.size
		mirror.rotation = source.rotation
		mirror.scale = source.scale
		var entry_type: String = String(entry.get("type", ""))
		if entry_type == "label":
			_sync_label(source as Label, mirror, entry.get("cached_colors", {}))
		elif entry_type == "rich_text":
			_sync_rich_text_label(source as RichTextLabel, mirror as RichTextLabel, entry.get("cached_colors", {}))
		else:
			_sync_button(source as Button, mirror, entry.get("cached_colors", {}))

func _sync_label(source: Label, mirror: Label, cached_colors: Dictionary) -> void:
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
	mirror.add_theme_color_override("font_color", _get_visible_theme_color(source, "font_color", LABEL_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_outline_color", _get_visible_theme_color(source, "font_outline_color", LABEL_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_shadow_color", _get_visible_theme_color(source, "font_shadow_color", LABEL_COLOR_KEYS, cached_colors))

func _sync_rich_text_label(source: RichTextLabel, mirror: RichTextLabel, cached_colors: Dictionary) -> void:
	if source == null or mirror == null:
		return
	mirror.bbcode_enabled = source.bbcode_enabled
	mirror.fit_content = source.fit_content
	mirror.scroll_active = false
	mirror.autowrap_mode = source.autowrap_mode
	mirror.text = source.text
	mirror.theme = source.theme
	mirror.add_theme_font_size_override("normal_font_size", source.get_theme_font_size("normal_font_size"))
	mirror.add_theme_color_override("default_color", _get_visible_theme_color(source, "default_color", RICH_TEXT_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_outline_color", _get_visible_theme_color(source, "font_outline_color", RICH_TEXT_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_shadow_color", _get_visible_theme_color(source, "font_shadow_color", RICH_TEXT_COLOR_KEYS, cached_colors))

func _sync_button(source: Button, mirror: Label, cached_colors: Dictionary) -> void:
	if source == null:
		return
	mirror.text = source.text
	mirror.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mirror.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mirror.label_settings = null
	mirror.theme = source.theme
	mirror.add_theme_font_size_override("font_size", source.get_theme_font_size("font_size"))
	var color_name := &"font_disabled_color" if source.disabled else &"font_color"
	mirror.add_theme_color_override("font_color", _get_visible_theme_color(source, String(color_name), BUTTON_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_outline_color", _get_visible_theme_color(source, "font_outline_color", BUTTON_COLOR_KEYS, cached_colors))
	mirror.add_theme_color_override("font_shadow_color", _get_visible_theme_color(source, "font_shadow_color", BUTTON_COLOR_KEYS, cached_colors))

func _get_visible_theme_color(control: Control, color_key: String, hidden_keys: Array, cached_colors: Dictionary) -> Color:
	var actual_color: Color = control.get_theme_color(StringName(color_key))
	if hidden_keys.has(color_key) and actual_color.a <= 0.001 and cached_colors.has(color_key):
		return cached_colors[color_key]
	return actual_color
