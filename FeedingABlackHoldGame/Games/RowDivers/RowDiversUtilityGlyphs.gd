extends HBoxContainer
## Four common utility-button markings; either Start or Select starts play.
const ICONS = [
	preload("res://addons/controller_icons/assets/switch/plus.png"),
	preload("res://addons/controller_icons/assets/switch/minus.png"),
	preload("res://addons/controller_icons/assets/xboxone/menu.png"),
	preload("res://addons/controller_icons/assets/xboxone/view.png"),
]

func _ready() -> void:
	name = "UtilityPlayGlyphs"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)
	for texture in ICONS:
		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = Vector2(42, 42)
		icon.self_modulate = Color(2.0, 2.0, 2.0, 1.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
	ControllerIcons.input_type_changed.connect(_refresh)
	_refresh()

func _refresh(_type = 0, _device = -1) -> void:
	visible = RailwayController.using_controller()
