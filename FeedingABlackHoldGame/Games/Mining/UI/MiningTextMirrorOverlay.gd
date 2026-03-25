extends CanvasLayer
class_name MiningTextMirrorOverlay

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
		elif child is Button:
			_register_button(child as Button)
		_collect_text_controls(child)

func _register_label(source: Label) -> void:
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
		"type": "label"
	})

func _register_button(source: Button) -> void:
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
		"type": "button"
	})

func _hide_original_text(control: Control, color_keys: Array) -> void:
	for color_key in color_keys:
		control.add_theme_color_override(StringName(color_key), TRANSPARENT)

func _sync_entries() -> void:
	for entry in mirrored_entries:
		var source: Control = entry.get("source")
		var mirror: Label = entry.get("mirror")
		if source == null or mirror == null or not is_instance_valid(source) or not is_instance_valid(mirror):
			continue
		mirror.visible = source.visible and source.is_visible_in_tree()
		mirror.global_position = source.global_position
		mirror.size = source.size
		mirror.rotation = source.rotation
		mirror.scale = source.scale
		if entry.get("type", "") == "label":
			_sync_label(source as Label, mirror)
		else:
			_sync_button(source as Button, mirror)

func _sync_label(source: Label, mirror: Label) -> void:
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
	mirror.add_theme_color_override("font_color", source.get_theme_color("font_color"))
	mirror.add_theme_color_override("font_outline_color", source.get_theme_color("font_outline_color"))
	mirror.add_theme_color_override("font_shadow_color", source.get_theme_color("font_shadow_color"))

func _sync_button(source: Button, mirror: Label) -> void:
	if source == null:
		return
	mirror.text = source.text
	mirror.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mirror.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mirror.label_settings = null
	mirror.theme = source.theme
	mirror.add_theme_font_size_override("font_size", source.get_theme_font_size("font_size"))
	var color_name := &"font_disabled_color" if source.disabled else &"font_color"
	mirror.add_theme_color_override("font_color", source.get_theme_color(color_name))
	mirror.add_theme_color_override("font_outline_color", source.get_theme_color("font_outline_color"))
	mirror.add_theme_color_override("font_shadow_color", source.get_theme_color("font_shadow_color"))
