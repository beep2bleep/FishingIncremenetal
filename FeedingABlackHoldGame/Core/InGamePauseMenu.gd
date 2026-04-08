extends CanvasLayer
class_name InGamePauseMenu

const SETTINGS_SCENE := preload("res://Settings.tscn")

signal resume_requested
signal end_run_requested

var _open := false
var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _settings_content: Settings
var _end_run_button: Button
var _resume_button: Button

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	hide()

func is_open() -> bool:
	return _open

func open_menu() -> void:
	if _open:
		return
	_open = true
	_refresh_text()
	show()
	if _settings_content != null and is_instance_valid(_settings_content):
		_settings_content.show_screen()
		_settings_content.refresh_from_save()

func close_menu() -> void:
	if not _open:
		return
	_open = false
	hide()

func toggle_menu() -> void:
	if _open:
		close_menu()
	else:
		open_menu()

func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.color = Color(0.02, 0.03, 0.06, 0.78)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.0
	_panel.anchor_top = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = 16.0
	_panel.offset_top = 16.0
	_panel.offset_right = -16.0
	_panel.offset_bottom = -16.0
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_panel_style(_panel)
	_overlay.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(layout)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 46)
	layout.add_child(_title_label)

	_settings_content = SETTINGS_SCENE.instantiate() as Settings
	if _settings_content != null:
		_settings_content.name = "SettingsContent"
		_settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_settings_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_settings_content.scale = Vector2(1.7, 1.7)
		layout.add_child(_settings_content)

	_end_run_button = Button.new()
	_end_run_button.name = "EndRunButton"
	_end_run_button.focus_mode = Control.FOCUS_NONE
	_end_run_button.custom_minimum_size = Vector2(0.0, 120.0)
	_end_run_button.add_theme_font_size_override("font_size", 30)
	_end_run_button.pressed.connect(_on_end_run_pressed)
	_style_button(_end_run_button)
	layout.add_child(_end_run_button)

	_resume_button = Button.new()
	_resume_button.name = "SettingsCloseButton"
	_resume_button.focus_mode = Control.FOCUS_NONE
	_resume_button.custom_minimum_size = Vector2(0.0, 150.0)
	_resume_button.add_theme_font_size_override("font_size", 34)
	_resume_button.pressed.connect(_on_resume_pressed)
	_style_button(_resume_button)
	layout.add_child(_resume_button)

	_refresh_text()

func _apply_panel_style(panel: PanelContainer) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.04, 0.06, 0.1, 0.98)
	box.border_color = Color(0.88, 0.92, 1.0, 1.0)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.corner_radius_top_left = 6
	box.corner_radius_top_right = 6
	box.corner_radius_bottom_right = 6
	box.corner_radius_bottom_left = 6
	panel.add_theme_stylebox_override("panel", box)

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.1, 0.16, 0.96)
	normal.border_color = Color(0.88, 0.92, 1.0, 1.0)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 4
	normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = 4
	normal.corner_radius_bottom_right = 4
	var hover := normal.duplicate(true)
	hover.bg_color = Color(0.14, 0.18, 0.26, 0.98)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)

func _refresh_text() -> void:
	if _title_label != null and is_instance_valid(_title_label):
		_title_label.text = tr("UI_SETTINGS_TITLE")
	if _end_run_button != null and is_instance_valid(_end_run_button):
		_end_run_button.text = tr("MINING_END_RUN")
	if _resume_button != null and is_instance_valid(_resume_button):
		_resume_button.text = tr("UI_BACK")

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_end_run_pressed() -> void:
	end_run_requested.emit()
