extends Control

const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")
const STAR_TEXTURE: Texture2D = preload("res://Art/star_tiny.png")
const BACKGROUND_PARTICLE_MATERIAL: Material = preload("res://Upgrade Tree Particles.tres")

const TITLE_TEXT_KEY := "MAIN MENU"
const VANGUARD_BUTTON_TEXT := "VANGUARD"
const MINING_BUTTON_TEXT := "MINING"
const RED_SKY_BUTTON_TEXT := "RED SKY DEFENSE"
const TURKEY_BUTTON_TEXT := "TURKEY"
const REEL_BUTTON_TEXT := "REEL INTO DARKNESS"
const LANGUAGE_BUTTON_WIDTH := 340.0
const LANGUAGE_BUTTON_FONT_SIZE := 20
const LANGUAGE_BUTTON_TITLE_FONT_SIZE := 26
const LANGUAGE_BUTTON_SELECTED_FONT_SIZE := 36
const LANGUAGE_BUTTON_LIST_FONT_SIZE := 24
const LANGUAGE_BUTTON_ROW_FLAG_WIDTH := 56
const LANGUAGE_BUTTON_ROW_FLAG_HEIGHT := 36
const LANGUAGE_LEFTBAR_LIST_FLAG_WIDTH := 42
const LANGUAGE_LEFTBAR_LIST_FLAG_HEIGHT := 27
const LANGUAGE_LEFTBAR_LIST_ROW_SEP := 9
const LANGUAGE_LEFTBAR_LIST_VSEP := 6
const SETTINGS_PANEL_LEFT_GUTTER := LANGUAGE_BUTTON_WIDTH + 88.0
const LANGUAGE_PANEL_COLUMNS := 3
const LANGUAGE_ENTRY_FONT_SIZE := 44
const LANGUAGE_ENTRY_HEIGHT := 112
const FLAG_ICON_WIDTH := 56
const FLAG_ICON_HEIGHT := 36
const GAME_CARD_COLUMNS := 2
const GAME_CARD_IMAGE_HEIGHT := 208
const GAME_CARD_TITLE_FONT_SIZE := 30
const GAME_CARD_DETAIL_FONT_SIZE := 18
const BACKGROUND_TWEEN_DURATION := 2.0
const MENU_NEUTRAL_BG := Color(0.09, 0.1, 0.12, 1.0)
const GAME_LAUNCHER_PANEL_MIN_WIDTH := 1080.0
const GAME_LAUNCHER_PANEL_MAX_WIDTH := 1680.0
const GAME_LAUNCHER_PANEL_VIEWPORT_RATIO := 0.94
const GAME_LAUNCHER_RIGHT_MARGIN := 16.0
const GAME_CARD_HOVER_VOLUME_DB_OFFSET := -12.0
const GAME_CARD_TITLE_HOVER_SCALE := 1.08
const GAME_CARD_TITLE_HOVER_DURATION := 0.16
const GAME_CARD_TITLE_RESET_DURATION := 0.12

@onready var background_rect: ColorRect = get_node_or_null("Background") as ColorRect
@onready var center_container: CenterContainer = get_node_or_null("CenterContainer") as CenterContainer
@onready var launcher_panel: PanelContainer = get_node_or_null("CenterContainer/PanelContainer") as PanelContainer
@onready var title_label: Label = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel") as Label
@onready var subtitle_label: Label = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SubtitleLabel") as Label
@onready var vanguard_button: Button = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VanguardButton") as Button
@onready var mining_button: Button = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MiningButton") as Button
@onready var red_sky_button: Button = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RedSkyButton") as Button
@onready var turkey_button: Button = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TurkeyButton") as Button
@onready var reel_button: Button = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ReelButton") as Button

var settings_button: Button
var settings_panel: PanelContainer
var settings_title_label: Label
var settings_content: Settings
var settings_close_button: Button
var language_button: Button
var language_panel: PanelContainer
var language_title_label: Label
var language_list_container: GridContainer
var language_close_button: Button
var language_button_title_label: Label
var language_button_selected_header_label: Label
var language_button_selected_flag: TextureRect
var language_button_selected_value_label: Label
var language_button_preview_list: VBoxContainer
var language_flag_cache: Dictionary = {}
var game_cards_grid: GridContainer
var game_card_texture_cache: Dictionary = {}
var background_particles_root: Node2D
var background_particles_light: GPUParticles2D
var background_particles_dark: GPUParticles2D
var background_color_tween: Tween
var last_hovered_game_id: String = ""

func _ready() -> void:
    Global.game_state = Util.GAME_STATES.MAIN_MENU
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    _setup_background_fx()
    _setup_game_cards()
    _setup_settings_panel()
    _setup_language_panel()
    _refresh_text()
    _apply_background_palette(_get_background_palette_for_game(""), false)
    _refresh_launcher_panel_layout()
    if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
        get_viewport().size_changed.connect(_on_viewport_size_changed)

    if vanguard_button != null and not vanguard_button.pressed.is_connected(_on_vanguard_button_pressed):
        vanguard_button.pressed.connect(_on_vanguard_button_pressed)
    if mining_button != null and not mining_button.pressed.is_connected(_on_mining_button_pressed):
        mining_button.pressed.connect(_on_mining_button_pressed)
    if red_sky_button != null and not red_sky_button.pressed.is_connected(_on_red_sky_button_pressed):
        red_sky_button.pressed.connect(_on_red_sky_button_pressed)
    if turkey_button != null and not turkey_button.pressed.is_connected(_on_turkey_button_pressed):
        turkey_button.pressed.connect(_on_turkey_button_pressed)
    if reel_button != null and not reel_button.pressed.is_connected(_on_reel_button_pressed):
        reel_button.pressed.connect(_on_reel_button_pressed)

    if vanguard_button != null:
        vanguard_button.grab_focus()

func _on_viewport_size_changed() -> void:
    _layout_background_fx()
    _refresh_launcher_panel_layout()
    _refresh_game_card_layout()

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        _refresh_text()

func _input(event: InputEvent) -> void:
    if not event.is_action_pressed("escape") and not event.is_action_pressed("back"):
        return
    if _is_language_panel_open():
        _hide_language_panel()
        get_viewport().set_input_as_handled()
        return
    if _is_settings_panel_open():
        _hide_settings_panel()
        get_viewport().set_input_as_handled()

func _on_vanguard_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_VANGUARD)

func _on_mining_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_MINING)

func _on_red_sky_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_RED_SKY)

func _on_turkey_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_TURKEY)

func _on_reel_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_REEL_INTO_DARKNESS)

func _start_game(game_id: String) -> void:
    _hide_settings_panel()
    _hide_language_panel()
    Util.set_active_game_id(game_id)
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    if GameAnalytics != null and GameAnalytics.has_method("refresh_active_game_session"):
        GameAnalytics.refresh_active_game_session(true)
    SaveHandler.load_fishing_progress()
    Global.current_game_mode_data = null
    Global.ensure_default_game_mode_data()
    Global.new_game()

    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false

    if game_id == Util.ACTIVE_GAME_MINING or game_id == Util.ACTIVE_GAME_RED_SKY or game_id == Util.ACTIVE_GAME_TURKEY or game_id == Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
        SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)
        return
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)

func _refresh_text() -> void:
    if title_label != null and is_instance_valid(title_label):
        title_label.text = tr(TITLE_TEXT_KEY)
    if subtitle_label != null and is_instance_valid(subtitle_label):
        subtitle_label.text = tr("PLAY_NEW_MODES")
    _refresh_game_card_text(vanguard_button, Util.ACTIVE_GAME_VANGUARD)
    _refresh_game_card_text(mining_button, Util.ACTIVE_GAME_MINING)
    _refresh_game_card_text(red_sky_button, Util.ACTIVE_GAME_RED_SKY)
    _refresh_game_card_text(turkey_button, Util.ACTIVE_GAME_TURKEY)
    _refresh_game_card_text(reel_button, Util.ACTIVE_GAME_REEL_INTO_DARKNESS)

    if settings_button != null and is_instance_valid(settings_button):
        settings_button.text = tr("UI_SETTINGS")
    if settings_title_label != null and is_instance_valid(settings_title_label):
        settings_title_label.text = tr("UI_SETTINGS_TITLE")
    if settings_close_button != null and is_instance_valid(settings_close_button):
        settings_close_button.text = tr("UI_BACK")
    if language_button != null and is_instance_valid(language_button):
        language_button.text = ""
        language_button.tooltip_text = ""
    if language_title_label != null and is_instance_valid(language_title_label):
        language_title_label.text = tr("LANGUAGE")
    if language_close_button != null and is_instance_valid(language_close_button):
        language_close_button.text = tr("UI_BACK")
    if language_button_title_label != null and is_instance_valid(language_button_title_label):
        language_button_title_label.text = tr("LANGUAGE")
    if language_button_selected_header_label != null and is_instance_valid(language_button_selected_header_label):
        language_button_selected_header_label.text = tr("UI_SELECTED_LANGUAGE")
    if language_button_selected_flag != null and is_instance_valid(language_button_selected_flag):
        language_button_selected_flag.texture = _get_flag_texture_for_locale(SaveHandler.locale)
    if language_button_selected_value_label != null and is_instance_valid(language_button_selected_value_label):
        language_button_selected_value_label.text = str(SaveHandler.supported_locales.get(SaveHandler.locale, SaveHandler.locale))

    _rebuild_language_buttons()
    _rebuild_language_button_preview()

func _setup_settings_panel() -> void:
    if settings_button != null and is_instance_valid(settings_button):
        return

    settings_button = Button.new()
    settings_button.name = "SettingsButton"
    settings_button.anchor_left = 1.0
    settings_button.anchor_top = 0.0
    settings_button.anchor_right = 1.0
    settings_button.anchor_bottom = 0.0
    settings_button.offset_left = -200.0
    settings_button.offset_top = 16.0
    settings_button.offset_right = -16.0
    settings_button.offset_bottom = 104.0
    settings_button.focus_mode = Control.FOCUS_NONE
    settings_button.custom_minimum_size = Vector2(184, 88)
    settings_button.add_theme_font_size_override("font_size", 26)
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_utility_button(settings_button)
    add_child(settings_button)

    settings_panel = PanelContainer.new()
    settings_panel.name = "SettingsPanel"
    settings_panel.anchor_left = 0.0
    settings_panel.anchor_top = 0.0
    settings_panel.anchor_right = 1.0
    settings_panel.anchor_bottom = 1.0
    settings_panel.offset_left = SETTINGS_PANEL_LEFT_GUTTER
    settings_panel.offset_top = 16.0
    settings_panel.offset_right = -16.0
    settings_panel.offset_bottom = -16.0
    settings_panel.visible = false
    settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_panel(settings_panel)
    add_child(settings_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    settings_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(vbox)

    settings_title_label = Label.new()
    settings_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    settings_title_label.add_theme_font_size_override("font_size", 46)
    vbox.add_child(settings_title_label)

    settings_content = SETTINGS_SCENE.instantiate() as Settings
    if settings_content != null:
        settings_content.name = "SettingsContent"
        settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        settings_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
        settings_content.scale = Vector2(1.7, 1.7)
        vbox.add_child(settings_content)

    settings_close_button = Button.new()
    settings_close_button.name = "SettingsCloseButton"
    settings_close_button.focus_mode = Control.FOCUS_NONE
    settings_close_button.custom_minimum_size = Vector2(0, 150)
    settings_close_button.add_theme_font_size_override("font_size", 34)
    settings_close_button.pressed.connect(_hide_settings_panel)
    _style_utility_button(settings_close_button)
    vbox.add_child(settings_close_button)

func _setup_game_cards() -> void:
    if game_cards_grid != null and is_instance_valid(game_cards_grid):
        return
    if title_label == null or subtitle_label == null:
        return
    var root_vbox := title_label.get_parent() as VBoxContainer
    if root_vbox == null:
        return

    game_cards_grid = GridContainer.new()
    game_cards_grid.name = "GameCardsGrid"
    game_cards_grid.columns = GAME_CARD_COLUMNS
    game_cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    game_cards_grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    game_cards_grid.add_theme_constant_override("h_separation", 18)
    game_cards_grid.add_theme_constant_override("v_separation", 18)
    root_vbox.add_child(game_cards_grid)
    root_vbox.move_child(game_cards_grid, root_vbox.get_children().find(subtitle_label) + 1)

    _decorate_game_button(vanguard_button, Util.ACTIVE_GAME_VANGUARD)
    _decorate_game_button(mining_button, Util.ACTIVE_GAME_MINING)
    _decorate_game_button(red_sky_button, Util.ACTIVE_GAME_RED_SKY)
    _decorate_game_button(turkey_button, Util.ACTIVE_GAME_TURKEY)
    _decorate_game_button(reel_button, Util.ACTIVE_GAME_REEL_INTO_DARKNESS)
    _refresh_game_card_layout()

func _decorate_game_button(button: Button, game_id: String) -> void:
    if button == null or not is_instance_valid(button):
        return
    if game_cards_grid == null or not is_instance_valid(game_cards_grid):
        return
    if bool(button.get_meta("game_card_ready", false)):
        return

    var parent := button.get_parent()
    if parent != null:
        parent.remove_child(button)
    game_cards_grid.add_child(button)

    var card_def: Dictionary = _get_game_card_definition(game_id)
    button.text = ""
    button.tooltip_text = tr(str(card_def.get("title", game_id)))
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.focus_mode = Control.FOCUS_ALL
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    if not button.mouse_entered.is_connected(_on_game_button_hovered.bind(game_id)):
        button.mouse_entered.connect(_on_game_button_hovered.bind(game_id))
    if not button.focus_entered.is_connected(_on_game_button_hovered.bind(game_id)):
        button.focus_entered.connect(_on_game_button_hovered.bind(game_id))
    if not button.mouse_exited.is_connected(_on_game_button_unhovered.bind(button)):
        button.mouse_exited.connect(_on_game_button_unhovered.bind(button))
    if not button.focus_exited.is_connected(_on_game_button_unhovered.bind(button)):
        button.focus_exited.connect(_on_game_button_unhovered.bind(button))
    button.add_theme_stylebox_override("normal", _make_game_card_style(Color(card_def.get("accent", Color(0.78, 0.84, 0.96, 1.0))), 0.0))
    button.add_theme_stylebox_override("hover", _make_game_card_style(Color(card_def.get("accent", Color(0.78, 0.84, 0.96, 1.0))), 0.06))
    button.add_theme_stylebox_override("pressed", _make_game_card_style(Color(card_def.get("accent", Color(0.78, 0.84, 0.96, 1.0))).darkened(0.08), 0.1))
    button.add_theme_stylebox_override("focus", _make_game_card_style(Color(card_def.get("accent", Color(0.78, 0.84, 0.96, 1.0))).lightened(0.08), 0.08))
    button.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 0.0))
    button.add_theme_color_override("font_hover_color", Color(0.0, 0.0, 0.0, 0.0))
    button.add_theme_color_override("font_pressed_color", Color(0.0, 0.0, 0.0, 0.0))
    button.add_theme_color_override("font_focus_color", Color(0.0, 0.0, 0.0, 0.0))

    var margin := MarginContainer.new()
    margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    margin.anchor_right = 1.0
    margin.anchor_bottom = 1.0
    margin.offset_right = 0.0
    margin.offset_bottom = 0.0
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    button.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 10)
    margin.add_child(vbox)

    var preview_panel := PanelContainer.new()
    preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    preview_panel.custom_minimum_size = Vector2(0.0, GAME_CARD_IMAGE_HEIGHT)
    preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    preview_panel.add_theme_stylebox_override("panel", _make_preview_style(Color(card_def.get("accent", Color(0.78, 0.84, 0.96, 1.0)))))
    vbox.add_child(preview_panel)

    var texture_rect := TextureRect.new()
    texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_rect.anchor_right = 1.0
    texture_rect.anchor_bottom = 1.0
    texture_rect.custom_minimum_size = Vector2(0.0, GAME_CARD_IMAGE_HEIGHT)
    texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
    texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    texture_rect.texture = _get_game_card_texture(game_id)
    preview_panel.add_child(texture_rect)

    var title := Label.new()
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.add_theme_font_size_override("font_size", GAME_CARD_TITLE_FONT_SIZE)
    title.add_theme_color_override("font_color", Color(0.98, 0.98, 0.99, 1.0))
    title.add_theme_constant_override("outline_size", 2)
    title.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.08, 0.9))
    vbox.add_child(title)

    var detail := Label.new()
    detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size", GAME_CARD_DETAIL_FONT_SIZE)
    detail.add_theme_color_override("font_color", Color(0.82, 0.88, 0.95, 0.96))
    vbox.add_child(detail)

    button.set_meta("game_card_ready", true)
    button.set_meta("game_id", game_id)
    button.set_meta("card_title_label", title)
    button.set_meta("card_detail_label", detail)

func _refresh_game_card_layout() -> void:
    if game_cards_grid == null or not is_instance_valid(game_cards_grid):
        return
    var viewport_width: float = get_viewport_rect().size.x
    game_cards_grid.columns = 3 if viewport_width >= 1340.0 else 2
    var card_min_width: float = 360.0 if game_cards_grid.columns >= 3 else 460.0
    var card_height: float = 344.0 if game_cards_grid.columns >= 3 else 372.0
    for button in [vanguard_button, mining_button, red_sky_button, turkey_button, reel_button]:
        if button == null or not is_instance_valid(button):
            continue
        button.custom_minimum_size = Vector2(card_min_width, card_height)

func _refresh_launcher_panel_layout() -> void:
    if center_container == null or not is_instance_valid(center_container):
        return
    if launcher_panel == null or not is_instance_valid(launcher_panel):
        return
    var viewport_width: float = get_viewport_rect().size.x
    var available_width := maxf(
        viewport_width - SETTINGS_PANEL_LEFT_GUTTER - GAME_LAUNCHER_RIGHT_MARGIN,
        GAME_LAUNCHER_PANEL_MIN_WIDTH
    )
    center_container.offset_left = SETTINGS_PANEL_LEFT_GUTTER
    center_container.offset_right = -GAME_LAUNCHER_RIGHT_MARGIN
    launcher_panel.custom_minimum_size.x = clampf(
        available_width * GAME_LAUNCHER_PANEL_VIEWPORT_RATIO,
        GAME_LAUNCHER_PANEL_MIN_WIDTH,
        GAME_LAUNCHER_PANEL_MAX_WIDTH
    )

func _refresh_game_card_text(button: Button, game_id: String) -> void:
    if button == null or not is_instance_valid(button):
        return
    var card_def: Dictionary = _get_game_card_definition(game_id)
    var title := button.get_meta("card_title_label", null) as Label
    var detail := button.get_meta("card_detail_label", null) as Label
    if title != null and is_instance_valid(title):
        title.text = tr(str(card_def.get("title", game_id)))
    if detail != null and is_instance_valid(detail):
        detail.text = tr(str(card_def.get("detail", "")))

func _get_game_card_definition(game_id: String) -> Dictionary:
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return {
                "title": VANGUARD_BUTTON_TEXT,
                "detail": "Feed the black hole and break planets apart.",
                "asset_rel_path": "1232x706maincap.png",
                "accent": Color(0.43, 0.68, 1.0, 1.0),
                "bg_top": Color(0.07, 0.11, 0.19, 1.0),
                "bg_bottom": Color(0.03, 0.05, 0.1, 1.0)
            }
        Util.ACTIVE_GAME_MINING:
            return {
                "title": MINING_BUTTON_TEXT,
                "detail": "Drill deeper, haul ore, and upgrade the rig.",
                "asset_rel_path": "Mining/1232x706.png",
                "accent": Color(0.86, 0.69, 0.33, 1.0),
                "bg_top": Color(0.18, 0.12, 0.05, 1.0),
                "bg_bottom": Color(0.06, 0.04, 0.02, 1.0)
            }
        Util.ACTIVE_GAME_RED_SKY:
            return {
                "title": RED_SKY_BUTTON_TEXT,
                "detail": "Defend the base and survive the next wave.",
                "asset_rel_path": "ChatGPT Image Mar 12, 2026, 04_18_10 PM.png",
                "accent": Color(0.98, 0.62, 0.42, 1.0),
                "bg_top": Color(0.22, 0.05, 0.06, 1.0),
                "bg_bottom": Color(0.1, 0.02, 0.03, 1.0)
            }
        Util.ACTIVE_GAME_TURKEY:
            return {
                "title": TURKEY_BUTTON_TEXT,
                "detail": "Arcade chaos with fast dodging and scoring.",
                "asset_rel_path": "ChatGPT Image Mar 12, 2026, 04_16_15 PM.png",
                "accent": Color(0.96, 0.84, 0.45, 1.0),
                "bg_top": Color(0.24, 0.1, 0.03, 1.0),
                "bg_bottom": Color(0.11, 0.04, 0.01, 1.0)
            }
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return {
                "title": REEL_BUTTON_TEXT,
                "detail": "Haunted fishing in the dark with eerie catches.",
                "asset_rel_path": "ChatGPT Image Mar 12, 2026, 04_13_25 PM.png",
                "accent": Color(0.56, 0.84, 0.94, 1.0),
                "bg_top": Color(0.03, 0.08, 0.12, 1.0),
                "bg_bottom": Color(0.01, 0.03, 0.06, 1.0)
            }
        _:
            return {
                "title": game_id,
                "detail": "",
                "asset_rel_path": "",
                "accent": Color(0.82, 0.86, 0.92, 1.0),
                "bg_top": Color(0.08, 0.1, 0.16, 1.0),
                "bg_bottom": Color(0.03, 0.05, 0.08, 1.0)
            }

func _get_game_card_texture(game_id: String) -> Texture2D:
    if game_card_texture_cache.has(game_id):
        return game_card_texture_cache[game_id] as Texture2D
    var card_def: Dictionary = _get_game_card_definition(game_id)
    var texture := _load_external_asset_texture(str(card_def.get("asset_rel_path", "")))
    if texture == null:
        texture = _build_fallback_game_card_texture(game_id)
    game_card_texture_cache[game_id] = texture
    return texture

func _load_external_asset_texture(relative_asset_path: String) -> Texture2D:
    if relative_asset_path.is_empty():
        return null
    var absolute_path: String = ProjectSettings.globalize_path("res://../assets/%s" % relative_asset_path)
    if not FileAccess.file_exists(absolute_path):
        return null
    var image := Image.new()
    var load_error: Error = image.load(absolute_path)
    if load_error != OK:
        return null
    return ImageTexture.create_from_image(image)

func _build_fallback_game_card_texture(game_id: String) -> Texture2D:
    var card_def: Dictionary = _get_game_card_definition(game_id)
    var image := Image.create(720, 405, false, Image.FORMAT_RGBA8)
    var top_color: Color = card_def.get("bg_top", Color(0.08, 0.1, 0.16, 1.0))
    var bottom_color: Color = card_def.get("bg_bottom", Color(0.03, 0.05, 0.08, 1.0))
    var accent: Color = card_def.get("accent", Color(0.82, 0.86, 0.92, 1.0))
    for y in range(image.get_height()):
        var t: float = float(y) / max(float(image.get_height() - 1), 1.0)
        var row_color: Color = top_color.lerp(bottom_color, t)
        for x in range(image.get_width()):
            image.set_pixel(x, y, row_color)
    _fill_image_rect(image, Rect2i(0, image.get_height() - 84, image.get_width(), 84), Color(0.0, 0.0, 0.0, 0.22))
    _draw_image_circle(image, Vector2i(544, 132), 112, Color(accent.r, accent.g, accent.b, 0.8))
    _draw_image_circle(image, Vector2i(600, 164), 54, Color(1.0, 1.0, 1.0, 0.14))
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            _fill_image_rect(image, Rect2i(64, 252, 220, 18), Color(0.72, 0.82, 1.0, 0.9))
            _fill_image_rect(image, Rect2i(94, 190, 160, 16), Color(0.92, 0.96, 1.0, 0.78))
            _draw_image_circle(image, Vector2i(170, 128), 66, Color(0.08, 0.09, 0.15, 1.0))
        Util.ACTIVE_GAME_MINING:
            _fill_image_rect(image, Rect2i(82, 118, 140, 196), Color(0.22, 0.18, 0.14, 1.0))
            _fill_image_rect(image, Rect2i(110, 84, 84, 40), Color(0.94, 0.74, 0.28, 1.0))
            _fill_image_rect(image, Rect2i(228, 206, 120, 12), Color(0.98, 0.88, 0.48, 0.92))
        Util.ACTIVE_GAME_RED_SKY:
            _fill_image_rect(image, Rect2i(0, 286, image.get_width(), 64), Color(0.12, 0.04, 0.04, 0.95))
            _fill_image_rect(image, Rect2i(288, 206, 146, 76), Color(0.8, 0.22, 0.18, 1.0))
            _draw_image_circle(image, Vector2i(360, 184), 68, Color(0.97, 0.48, 0.24, 0.82))
        Util.ACTIVE_GAME_TURKEY:
            _fill_image_rect(image, Rect2i(130, 190, 180, 96), Color(0.52, 0.24, 0.1, 1.0))
            _draw_image_circle(image, Vector2i(220, 150), 54, Color(0.88, 0.46, 0.22, 1.0))
            _fill_image_rect(image, Rect2i(252, 122, 68, 24), Color(0.96, 0.74, 0.34, 1.0))
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            _fill_image_rect(image, Rect2i(0, 266, image.get_width(), 100), Color(0.02, 0.08, 0.12, 0.96))
            _fill_image_rect(image, Rect2i(176, 178, 10, 118), Color(0.78, 0.86, 0.92, 0.95))
            _draw_image_circle(image, Vector2i(184, 174), 22, Color(0.74, 0.9, 1.0, 1.0))
        _:
            _fill_image_rect(image, Rect2i(92, 212, 240, 72), accent)
    return ImageTexture.create_from_image(image)

func _make_game_card_style(border_color: Color, tint_amount: float) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.07, 0.1, 0.14, 0.98).lerp(border_color.darkened(0.72), clampf(tint_amount, 0.0, 0.2))
    style.border_color = border_color
    style.set_border_width_all(2)
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.shadow_size = 8
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
    style.content_margin_left = 0.0
    style.content_margin_top = 0.0
    style.content_margin_right = 0.0
    style.content_margin_bottom = 0.0
    return style

func _make_preview_style(border_color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.05, 0.08, 1.0)
    style.border_color = border_color.lightened(0.08)
    style.set_border_width_all(1)
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    style.shadow_size = 4
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
    return style

func _setup_language_panel() -> void:
    if language_button != null and is_instance_valid(language_button):
        return

    language_button = Button.new()
    language_button.name = "LanguageButton"
    language_button.anchor_left = 0.0
    language_button.anchor_top = 0.0
    language_button.anchor_right = 0.0
    language_button.anchor_bottom = 1.0
    language_button.offset_left = 16.0
    language_button.offset_top = 16.0
    language_button.offset_right = LANGUAGE_BUTTON_WIDTH
    language_button.offset_bottom = -16.0
    language_button.focus_mode = Control.FOCUS_NONE
    language_button.text = ""
    language_button.add_theme_font_size_override("font_size", LANGUAGE_BUTTON_FONT_SIZE)
    language_button.pressed.connect(_on_language_button_pressed)
    _style_utility_button(language_button)
    add_child(language_button)

    var button_margin := MarginContainer.new()
    button_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button_margin.anchor_right = 1.0
    button_margin.anchor_bottom = 1.0
    button_margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
    button_margin.grow_vertical = Control.GROW_DIRECTION_BOTH
    button_margin.add_theme_constant_override("margin_left", 10)
    button_margin.add_theme_constant_override("margin_top", 10)
    button_margin.add_theme_constant_override("margin_right", 10)
    button_margin.add_theme_constant_override("margin_bottom", 10)
    language_button.add_child(button_margin)

    var button_vbox := VBoxContainer.new()
    button_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    button_vbox.add_theme_constant_override("separation", 8)
    button_margin.add_child(button_vbox)

    language_button_title_label = Label.new()
    language_button_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    language_button_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    language_button_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    language_button_title_label.add_theme_font_size_override("font_size", LANGUAGE_BUTTON_TITLE_FONT_SIZE)
    language_button_title_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
    button_vbox.add_child(language_button_title_label)

    language_button_selected_header_label = Label.new()
    language_button_selected_header_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    language_button_selected_header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    language_button_selected_header_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    language_button_selected_header_label.add_theme_font_size_override("font_size", LANGUAGE_BUTTON_SELECTED_FONT_SIZE)
    language_button_selected_header_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.95, 0.96))
    button_vbox.add_child(language_button_selected_header_label)

    var selected_row := HBoxContainer.new()
    selected_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    selected_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    selected_row.alignment = BoxContainer.ALIGNMENT_CENTER
    selected_row.add_theme_constant_override("separation", 12)
    button_vbox.add_child(selected_row)

    language_button_selected_flag = TextureRect.new()
    language_button_selected_flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
    language_button_selected_flag.custom_minimum_size = Vector2(LANGUAGE_BUTTON_ROW_FLAG_WIDTH, LANGUAGE_BUTTON_ROW_FLAG_HEIGHT)
    language_button_selected_flag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    language_button_selected_flag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    selected_row.add_child(language_button_selected_flag)

    language_button_selected_value_label = Label.new()
    language_button_selected_value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    language_button_selected_value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    language_button_selected_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    language_button_selected_value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    language_button_selected_value_label.add_theme_font_size_override("font_size", LANGUAGE_BUTTON_SELECTED_FONT_SIZE)
    language_button_selected_value_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
    selected_row.add_child(language_button_selected_value_label)

    var separator := HSeparator.new()
    separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button_vbox.add_child(separator)

    var scroll := ScrollContainer.new()
    scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    button_vbox.add_child(scroll)

    language_button_preview_list = VBoxContainer.new()
    language_button_preview_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
    language_button_preview_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    language_button_preview_list.add_theme_constant_override("separation", LANGUAGE_LEFTBAR_LIST_VSEP)
    scroll.add_child(language_button_preview_list)

    language_panel = PanelContainer.new()
    language_panel.name = "LanguagePanel"
    language_panel.anchor_left = 0.0
    language_panel.anchor_top = 0.0
    language_panel.anchor_right = 1.0
    language_panel.anchor_bottom = 1.0
    language_panel.offset_left = 16.0
    language_panel.offset_top = 16.0
    language_panel.offset_right = -16.0
    language_panel.offset_bottom = -16.0
    language_panel.visible = false
    language_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_panel(language_panel)
    add_child(language_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 18)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_right", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    language_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(vbox)

    language_title_label = Label.new()
    language_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    language_title_label.add_theme_font_size_override("font_size", 42)
    vbox.add_child(language_title_label)

    language_list_container = GridContainer.new()
    language_list_container.columns = LANGUAGE_PANEL_COLUMNS
    language_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    language_list_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    language_list_container.add_theme_constant_override("h_separation", 12)
    language_list_container.add_theme_constant_override("v_separation", 10)
    vbox.add_child(language_list_container)

    language_close_button = Button.new()
    language_close_button.name = "LanguageCloseButton"
    language_close_button.focus_mode = Control.FOCUS_NONE
    language_close_button.custom_minimum_size = Vector2(0, 80)
    language_close_button.add_theme_font_size_override("font_size", 30)
    language_close_button.pressed.connect(_hide_language_panel)
    _style_utility_button(language_close_button)
    vbox.add_child(language_close_button)

func _rebuild_language_buttons() -> void:
    if language_list_container == null or not is_instance_valid(language_list_container):
        return

    for child in language_list_container.get_children():
        child.queue_free()

    for locale_code: String in SaveHandler.supported_locales.keys():
        var button := Button.new()
        button.text = str(SaveHandler.supported_locales[locale_code])
        button.icon = _get_flag_texture_for_locale(locale_code)
        button.custom_minimum_size = Vector2(0, LANGUAGE_ENTRY_HEIGHT)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.focus_mode = Control.FOCUS_NONE
        button.disabled = locale_code == SaveHandler.locale
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        button.add_theme_font_size_override("font_size", LANGUAGE_ENTRY_FONT_SIZE)
        button.pressed.connect(_on_language_selected.bind(locale_code))
        _style_utility_button(button)
        language_list_container.add_child(button)

func _rebuild_language_button_preview() -> void:
    if language_button_preview_list == null or not is_instance_valid(language_button_preview_list):
        return

    for child in language_button_preview_list.get_children():
        child.queue_free()

    for locale_code: String in SaveHandler.supported_locales.keys():
        var row := HBoxContainer.new()
        row.mouse_filter = Control.MOUSE_FILTER_IGNORE
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_theme_constant_override("separation", LANGUAGE_LEFTBAR_LIST_ROW_SEP)
        language_button_preview_list.add_child(row)

        var flag := TextureRect.new()
        flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
        flag.custom_minimum_size = Vector2(LANGUAGE_LEFTBAR_LIST_FLAG_WIDTH, LANGUAGE_LEFTBAR_LIST_FLAG_HEIGHT)
        flag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        flag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        flag.texture = _get_flag_texture_for_locale(locale_code)
        row.add_child(flag)

        var label := Label.new()
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.text = str(SaveHandler.supported_locales[locale_code])
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.add_theme_font_size_override("font_size", LANGUAGE_BUTTON_LIST_FONT_SIZE)
        label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
        label.modulate = Color(1.0, 1.0, 1.0, 1.0) if locale_code == SaveHandler.locale else Color(0.86, 0.9, 0.96, 0.95)
        row.add_child(label)

func _setup_background_fx() -> void:
    if background_particles_root != null and is_instance_valid(background_particles_root):
        return
    if background_rect != null and is_instance_valid(background_rect):
        background_rect.color = MENU_NEUTRAL_BG

    background_particles_root = Node2D.new()
    background_particles_root.name = "BackgroundParticles"
    add_child(background_particles_root)
    if background_rect != null and is_instance_valid(background_rect):
        move_child(background_particles_root, get_children().find(background_rect) + 1)

    background_particles_light = _create_background_particles_node("BackgroundParticlesLight")
    background_particles_dark = _create_background_particles_node("BackgroundParticlesDark")
    background_particles_root.add_child(background_particles_light)
    background_particles_root.add_child(background_particles_dark)
    _layout_background_fx()

func _create_background_particles_node(node_name: String) -> GPUParticles2D:
    var particles := GPUParticles2D.new()
    particles.name = node_name
    particles.amount = 64
    particles.texture = STAR_TEXTURE
    particles.lifetime = 5.0
    particles.preprocess = 10.0
    particles.randomness = 0.5
    particles.process_material = BACKGROUND_PARTICLE_MATERIAL
    particles.emitting = true
    return particles

func _layout_background_fx() -> void:
    if background_particles_root == null or not is_instance_valid(background_particles_root):
        return
    var center := get_viewport_rect().size * 0.5
    background_particles_root.position = center
    if background_particles_light != null and is_instance_valid(background_particles_light):
        background_particles_light.position = Vector2.ZERO
    if background_particles_dark != null and is_instance_valid(background_particles_dark):
        background_particles_dark.position = Vector2.ZERO

func _on_game_button_hovered(game_id: String) -> void:
    if last_hovered_game_id != game_id:
        last_hovered_game_id = game_id
        _play_game_card_hover_sound()
    var hovered_button := _get_game_button_for_id(game_id)
    _animate_game_card_title(hovered_button, true)
    _apply_background_palette(_get_background_palette_for_game(game_id), true)

func _on_game_button_unhovered(button: Button) -> void:
    _animate_game_card_title(button, false)

func _play_game_card_hover_sound() -> void:
    if AudioManager == null:
        return
    AudioManager.create_audio(
        SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER,
        GAME_CARD_HOVER_VOLUME_DB_OFFSET
    )

func _animate_game_card_title(button: Button, is_hovered: bool) -> void:
    if button == null or not is_instance_valid(button):
        return
    var title := button.get_meta("card_title_label", null) as Label
    if title == null or not is_instance_valid(title):
        return
    var existing_tween := button.get_meta("card_title_tween", null) as Tween
    if existing_tween != null and existing_tween.is_running():
        existing_tween.kill()
    title.pivot_offset = title.size * 0.5
    var tween := create_tween()
    button.set_meta("card_title_tween", tween)
    if is_hovered:
        tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        tween.tween_property(title, "scale", Vector2.ONE * GAME_CARD_TITLE_HOVER_SCALE, GAME_CARD_TITLE_HOVER_DURATION)
        tween.parallel().tween_property(title, "rotation_degrees", _get_game_card_title_hover_rotation(button), GAME_CARD_TITLE_HOVER_DURATION)
        return
    tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
    tween.tween_property(title, "scale", Vector2.ONE, GAME_CARD_TITLE_RESET_DURATION)
    tween.parallel().tween_property(title, "rotation_degrees", 0.0, GAME_CARD_TITLE_RESET_DURATION)

func _get_game_card_title_hover_rotation(button: Button) -> float:
    if button == null or not is_instance_valid(button):
        return 0.0
    var game_id := str(button.get_meta("game_id", ""))
    match game_id:
        Util.ACTIVE_GAME_MINING:
            return -2.0
        Util.ACTIVE_GAME_RED_SKY:
            return 2.2
        Util.ACTIVE_GAME_TURKEY:
            return -1.8
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return 1.8
        _:
            return -1.6

func _get_game_button_for_id(game_id: String) -> Button:
    match game_id:
        Util.ACTIVE_GAME_VANGUARD:
            return vanguard_button
        Util.ACTIVE_GAME_MINING:
            return mining_button
        Util.ACTIVE_GAME_RED_SKY:
            return red_sky_button
        Util.ACTIVE_GAME_TURKEY:
            return turkey_button
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return reel_button
        _:
            return null

func _get_background_palette_for_game(game_id: String) -> Dictionary:
    var default_palette := _get_default_background_palette()
    match game_id:
        Util.ACTIVE_GAME_MINING:
            return {
                "bg": Color(0.13, 0.1, 0.08, 1.0),
                "light": Color(0.72, 0.55, 0.22, 0.65),
                "dark": Color(0.28, 0.18, 0.1, 0.55)
            }
        Util.ACTIVE_GAME_RED_SKY:
            return {
                "bg": Color(0.19, 0.095, 0.085, 1.0),
                "light": Color(0.81, 0.39, 0.24, 0.64),
                "dark": Color(0.36, 0.135, 0.095, 0.6)
            }
        Util.ACTIVE_GAME_TURKEY:
            return {
                "bg": Color(0.04, 0.04, 0.045, 1.0),
                "light": Color(0.62, 0.52, 0.28, 0.48),
                "dark": Color(0.12, 0.12, 0.13, 0.56)
            }
        Util.ACTIVE_GAME_REEL_INTO_DARKNESS:
            return {
                "bg": Color(0.05, 0.11, 0.16, 1.0),
                "light": Color(0.37, 0.7, 0.84, 0.62),
                "dark": Color(0.02, 0.07, 0.12, 0.58)
            }
        Util.ACTIVE_GAME_VANGUARD:
            return default_palette
        _:
            return default_palette

func _get_default_background_palette() -> Dictionary:
    var bg_color := MENU_NEUTRAL_BG
    if Refs != null and Refs.pallet != null:
        bg_color = Refs.pallet.background
    var light_color := bg_color
    light_color.v *= 1.05
    light_color.a = 0.65
    var dark_color := bg_color
    dark_color.v *= 0.95
    dark_color.a = 0.55
    return {
        "bg": bg_color,
        "light": light_color,
        "dark": dark_color
    }

func _apply_background_palette(palette: Dictionary, should_tween: bool) -> void:
    if background_rect == null or not is_instance_valid(background_rect):
        return
    var bg_color: Color = palette.get("bg", MENU_NEUTRAL_BG)
    var light_color: Color = palette.get("light", Color(0.16, 0.2, 0.3, 0.62))
    var dark_color: Color = palette.get("dark", Color(0.04, 0.06, 0.1, 0.56))
    if background_color_tween != null and background_color_tween.is_running():
        background_color_tween.kill()
    if not should_tween:
        background_rect.color = bg_color
        if background_particles_light != null and is_instance_valid(background_particles_light):
            background_particles_light.modulate = light_color
        if background_particles_dark != null and is_instance_valid(background_particles_dark):
            background_particles_dark.modulate = dark_color
        return
    background_color_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    background_color_tween.tween_property(background_rect, "color", bg_color, BACKGROUND_TWEEN_DURATION)
    if background_particles_light != null and is_instance_valid(background_particles_light):
        background_color_tween.parallel().tween_property(background_particles_light, "modulate", light_color, BACKGROUND_TWEEN_DURATION)
    if background_particles_dark != null and is_instance_valid(background_particles_dark):
        background_color_tween.parallel().tween_property(background_particles_dark, "modulate", dark_color, BACKGROUND_TWEEN_DURATION)

func _get_flag_texture_for_locale(locale_code: String) -> Texture2D:
    if language_flag_cache.has(locale_code):
        return language_flag_cache[locale_code] as Texture2D
    var texture := _build_flag_texture(locale_code)
    language_flag_cache[locale_code] = texture
    return texture

func _build_flag_texture(locale_code: String) -> Texture2D:
    var image := Image.create(FLAG_ICON_WIDTH, FLAG_ICON_HEIGHT, false, Image.FORMAT_RGBA8)
    image.fill(Color(0.12, 0.12, 0.14, 1.0))

    match locale_code:
        "en":
            _draw_horizontal_flag(image, [Color(0.7, 0.12, 0.14, 1.0), Color(0.95, 0.95, 0.95, 1.0), Color(0.7, 0.12, 0.14, 1.0), Color(0.95, 0.95, 0.95, 1.0), Color(0.7, 0.12, 0.14, 1.0), Color(0.95, 0.95, 0.95, 1.0), Color(0.7, 0.12, 0.14, 1.0)])
            _fill_image_rect(image, Rect2i(0, 0, 12, 10), Color(0.14, 0.22, 0.52, 1.0))
        "es":
            _draw_horizontal_flag(image, [Color(0.71, 0.08, 0.12, 1.0), Color(0.95, 0.8, 0.16, 1.0), Color(0.95, 0.8, 0.16, 1.0), Color(0.71, 0.08, 0.12, 1.0)])
        "de":
            _draw_horizontal_flag(image, [Color(0.08, 0.08, 0.08, 1.0), Color(0.74, 0.08, 0.12, 1.0), Color(0.92, 0.76, 0.12, 1.0)])
        "pt":
            _draw_vertical_flag(image, [Color(0.07, 0.45, 0.2, 1.0), Color(0.8, 0.12, 0.14, 1.0)], [2, 3])
        "fr":
            _draw_vertical_flag(image, [Color(0.14, 0.24, 0.72, 1.0), Color(0.96, 0.96, 0.96, 1.0), Color(0.83, 0.12, 0.16, 1.0)])
        "it":
            _draw_vertical_flag(image, [Color(0.05, 0.56, 0.24, 1.0), Color(0.96, 0.96, 0.96, 1.0), Color(0.83, 0.12, 0.16, 1.0)])
        "zh":
            image.fill(Color(0.82, 0.08, 0.12, 1.0))
            _fill_image_rect(image, Rect2i(4, 4, 5, 5), Color(0.98, 0.84, 0.18, 1.0))
        "ja":
            image.fill(Color(0.96, 0.96, 0.96, 1.0))
            _draw_circle(image, Vector2i(FLAG_ICON_WIDTH / 2, FLAG_ICON_HEIGHT / 2), 5, Color(0.8, 0.12, 0.16, 1.0))
        "ko":
            image.fill(Color(0.96, 0.96, 0.96, 1.0))
            _fill_image_rect(image, Rect2i(10, 4, 8, 5), Color(0.81, 0.14, 0.18, 1.0))
            _fill_image_rect(image, Rect2i(10, 9, 8, 5), Color(0.16, 0.3, 0.72, 1.0))
        "ru":
            _draw_horizontal_flag(image, [Color(0.96, 0.96, 0.96, 1.0), Color(0.14, 0.3, 0.75, 1.0), Color(0.78, 0.12, 0.18, 1.0)])
        "pl":
            _draw_horizontal_flag(image, [Color(0.96, 0.96, 0.96, 1.0), Color(0.84, 0.18, 0.26, 1.0)])
        "tr":
            image.fill(Color(0.79, 0.07, 0.12, 1.0))
            _draw_circle(image, Vector2i(11, 9), 5, Color(0.96, 0.96, 0.96, 1.0))
            _draw_circle(image, Vector2i(13, 9), 4, Color(0.79, 0.07, 0.12, 1.0))
            _fill_image_rect(image, Rect2i(18, 7, 3, 3), Color(0.96, 0.96, 0.96, 1.0))
        "th":
            _draw_horizontal_flag(image, [Color(0.72, 0.12, 0.16, 1.0), Color(0.96, 0.96, 0.96, 1.0), Color(0.14, 0.2, 0.54, 1.0), Color(0.14, 0.2, 0.54, 1.0), Color(0.96, 0.96, 0.96, 1.0), Color(0.72, 0.12, 0.16, 1.0)])
        "id":
            _draw_horizontal_flag(image, [Color(0.82, 0.12, 0.16, 1.0), Color(0.96, 0.96, 0.96, 1.0)])
        "cs":
            _draw_horizontal_flag(image, [Color(0.96, 0.96, 0.96, 1.0), Color(0.8, 0.14, 0.18, 1.0)])
            _draw_left_triangle(image, Color(0.14, 0.28, 0.7, 1.0))
        "ca":
            _draw_vertical_flag(image, [Color(0.14, 0.26, 0.7, 1.0), Color(0.96, 0.84, 0.18, 1.0), Color(0.82, 0.14, 0.16, 1.0)])
        "vi":
            image.fill(Color(0.82, 0.08, 0.12, 1.0))
            _fill_image_rect(image, Rect2i(11, 7, 6, 4), Color(0.98, 0.84, 0.18, 1.0))
        _:
            _draw_horizontal_flag(image, [Color(0.28, 0.34, 0.62, 1.0), Color(0.9, 0.9, 0.94, 1.0), Color(0.86, 0.28, 0.32, 1.0)])

    return ImageTexture.create_from_image(image)

func _draw_horizontal_flag(image: Image, colors: Array[Color]) -> void:
    var stripe_count: int = max(colors.size(), 1)
    var y := 0
    for stripe_index in range(stripe_count):
        var next_y: int = int(round(float(FLAG_ICON_HEIGHT) * float(stripe_index + 1) / float(stripe_count)))
        _fill_image_rect(image, Rect2i(0, y, FLAG_ICON_WIDTH, max(1, next_y - y)), colors[stripe_index])
        y = next_y

func _draw_vertical_flag(image: Image, colors: Array[Color], weights: Array[int] = []) -> void:
    var total_weight := 0
    if weights.is_empty():
        total_weight = colors.size()
    else:
        for weight in weights:
            total_weight += max(weight, 1)
    var current_weight := 0
    for stripe_index in range(colors.size()):
        var weight: int = 1 if weights.is_empty() else max(int(weights[stripe_index]), 1)
        var start_x: int = int(round(float(FLAG_ICON_WIDTH) * float(current_weight) / float(total_weight)))
        current_weight += weight
        var next_x: int = int(round(float(FLAG_ICON_WIDTH) * float(current_weight) / float(total_weight)))
        _fill_image_rect(image, Rect2i(start_x, 0, max(1, next_x - start_x), FLAG_ICON_HEIGHT), colors[stripe_index])

func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
    var radius_sq: int = radius * radius
    for y in range(max(center.y - radius, 0), min(center.y + radius + 1, image.get_height())):
        for x in range(max(center.x - radius, 0), min(center.x + radius + 1, image.get_width())):
            var dx: int = x - center.x
            var dy: int = y - center.y
            if dx * dx + dy * dy <= radius_sq:
                image.set_pixel(x, y, color)

func _draw_image_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
    _draw_circle(image, center, radius, color)

func _draw_left_triangle(image: Image, color: Color) -> void:
    for x in range(image.get_width() / 2):
        var half_height: float = float(image.get_height()) * (1.0 - float(x) / max(float(image.get_width() / 2), 1.0)) * 0.5
        var center_y: float = float(image.get_height() - 1) * 0.5
        var top: int = int(floor(center_y - half_height))
        var bottom: int = int(ceil(center_y + half_height))
        for y in range(max(top, 0), min(bottom + 1, image.get_height())):
            image.set_pixel(x, y, color)

func _fill_image_rect(image: Image, rect: Rect2i, color: Color) -> void:
    var start_x: int = clampi(rect.position.x, 0, image.get_width())
    var start_y: int = clampi(rect.position.y, 0, image.get_height())
    var end_x: int = clampi(rect.position.x + rect.size.x, 0, image.get_width())
    var end_y: int = clampi(rect.position.y + rect.size.y, 0, image.get_height())
    for y in range(start_y, end_y):
        for x in range(start_x, end_x):
            image.set_pixel(x, y, color)

func _on_settings_button_pressed() -> void:
    _hide_language_panel()
    if settings_content != null and is_instance_valid(settings_content):
        settings_content.show_screen()
        settings_content.refresh_from_save()
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.show()

func _hide_settings_panel() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()

func _is_settings_panel_open() -> bool:
    return settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible

func _on_language_button_pressed() -> void:
    _hide_settings_panel()
    if language_panel != null and is_instance_valid(language_panel):
        language_panel.show()

func _hide_language_panel() -> void:
    if language_panel != null and is_instance_valid(language_panel):
        language_panel.hide()

func _is_language_panel_open() -> bool:
    return language_panel != null and is_instance_valid(language_panel) and language_panel.visible

func _on_language_selected(locale_code: String) -> void:
    SaveHandler.update_locale(locale_code)
    SaveHandler.update_has_shown_pick_locale_first_time(true)
    if settings_content != null and is_instance_valid(settings_content):
        settings_content.refresh_from_save()
    _hide_language_panel()
    _refresh_text()

func _style_utility_button(button: Button) -> void:
    if button == null:
        return
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

func _style_utility_panel(panel: PanelContainer) -> void:
    if panel == null:
        return
    var box := StyleBoxFlat.new()
    box.bg_color = Color(0.04, 0.06, 0.1, 0.98)
    box.border_color = Color(0.88, 0.92, 1.0, 1.0)
    box.border_width_left = 2
    box.border_width_top = 2
    box.border_width_right = 2
    box.border_width_bottom = 2
    box.corner_radius_top_left = 6
    box.corner_radius_top_right = 6
    box.corner_radius_bottom_left = 6
    box.corner_radius_bottom_right = 6
    panel.add_theme_stylebox_override("panel", box)
