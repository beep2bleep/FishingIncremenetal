extends CanvasLayer
const Style = preload("res://Games/RowDivers/RowDiversStyle.gd")
const NAMES = {"ArrowShield": "SHIELD", "Harvester": "MAGPIE", "Shuriken": "ARROW STORM", "SlowDown": "REGEN", "GhostPower": "GHOST"}
const POWERUP_ICONS = {"ArrowShield": "res://Games/RowDivers/Art/Powerups/shield.svg", "Harvester": "res://Games/RowDivers/Art/Powerups/magpie.svg", "Shuriken": "res://Games/RowDivers/Art/Powerups/arrow_storm.svg", "GhostPower": "res://Games/RowDivers/Art/Powerups/ghost.svg"}
var powerup_effects: Control
var powerup_highlights: Dictionary = {}
var battle: Node3D
var root_ui: Control
var hp_bar: ProgressBar
var armor_label: Label
var currency: Label
var boss_label: Label
var boss_bar: ProgressBar
var toast_label: Label
var toast_time = 0.0
var feedback: ColorRect
var ability_buttons: Dictionary = {}
var ability_bars: Dictionary = {}
var ability_columns: Dictionary = {}
var settings_panel: PanelContainer
var settings_content: Control
var overlay_detail: Label
var upgrades_button: Button
var settings_button: Button
var tutorial_button: Button
var tutorial_page = -1
var tutorial_cards: HBoxContainer
var debug_speed_label: Label
var debug_speed_buttons: Dictionary = {}

func build(owner_battle: Node3D) -> void:
	battle = owner_battle
	root_ui = Control.new()
	root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)
	powerup_effects = preload("res://Games/RowDivers/RowDiversPowerupEffects.gd").new()
	powerup_effects.battle = battle
	root_ui.add_child(powerup_effects)
	var stats := PanelContainer.new()
	stats.position = Vector2(24, 20)
	stats.custom_minimum_size = Vector2(350, 130)
	stats.add_theme_stylebox_override("panel", Style.panel(Color(0.055, 0.08, 0.11, 0.93)))
	root_ui.add_child(stats)
	var stats_box := VBoxContainer.new()
	stats.add_child(stats_box)
	battle.hud = Style.label("", 18, true)
	stats_box.add_child(battle.hud)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(300, 12)
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("background", Style.bar(Color("35252e")))
	hp_bar.add_theme_stylebox_override("fill", Style.bar(Color("d47769")))
	stats_box.add_child(hp_bar)
	armor_label = Style.label("", 15)
	stats_box.add_child(armor_label)
	currency = Style.label("", 18, true)
	root_ui.add_child(currency)
	currency.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	currency.position += Vector2(-400, 28)
	currency.size.x = 370
	currency.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boss_label = Style.label("", 21, true)
	root_ui.add_child(boss_label)
	boss_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	boss_label.position += Vector2(-230, 24)
	boss_label.size.x = 460
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_bar = ProgressBar.new()
	root_ui.add_child(boss_bar)
	boss_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	boss_bar.position += Vector2(-230, 62)
	boss_bar.size = Vector2(460, 10)
	boss_bar.show_percentage = false
	boss_bar.add_theme_stylebox_override("fill", Style.bar(Color("dca85a")))
	toast_label = Style.label("", 21, true)
	root_ui.add_child(toast_label)
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast_label.position += Vector2(-380, 112)
	toast_label.size.x = 760
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle.crosshair = Style.label("+", 30, true)
	root_ui.add_child(battle.crosshair)
	battle.crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	battle.crosshair.position -= Vector2(9, 20)
	battle.crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if battle.free_aim_mode:
		battle.crosshair.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var abilities := HBoxContainer.new()
	root_ui.add_child(abilities)
	abilities.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	abilities.offset_top = -102
	abilities.offset_bottom = -30
	abilities.alignment = BoxContainer.ALIGNMENT_CENTER
	abilities.add_theme_constant_override("separation", 12)
	for ability in NAMES:
		var column := VBoxContainer.new()
		abilities.add_child(column)
		ability_columns[ability] = column
		column.visible = battle.unlocked(ability)
		var button := make_button(tr(NAMES[ability]), func(): battle._activate(ability))
		# Space always belongs to the power queue, even after clicking a card.
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(170, 52)
		button.add_theme_font_size_override("font_size", 15)
		button.set_meta("railway_font_size", 15)
		button.tooltip_text = "Unlock this ability in Upgrades."
		column.add_child(button)
		ability_buttons[ability] = button
		var bar := ProgressBar.new()
		bar.custom_minimum_size.y = 5
		bar.show_percentage = false
		bar.max_value = 1
		bar.add_theme_stylebox_override("fill", Style.bar(Style.GOLD))
		column.add_child(bar)
		ability_bars[ability] = bar
	battle.ability_hud = Style.label("", 14)
	root_ui.add_child(battle.ability_hud)
	battle.ability_hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	battle.ability_hud.position += Vector2(24, -35)
	feedback = ColorRect.new()
	root_ui.add_child(feedback)
	feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback.color = Color(0.8, 0.15, 0.12, 0)
	_build_overlay()
	_build_settings()
	_build_debug_speed_controls()
	SignalBus.text_size_changed.connect(_apply_text_scale)
	_apply_text_scale()
	SignalBus.settings_updated.connect(_refresh_graphics)
	_refresh_graphics()
	if preload("res://Games/RowDivers/RowDiversDemo.gd").enabled():
		var demo_label := Style.label("DEMO MODE", 18, true)
		demo_label.position = Vector2(24, 163)
		demo_label.modulate = Style.GOLD
		root_ui.add_child(demo_label)

func _refresh_graphics() -> void:
	var graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
	var icons := {"ArrowShield": "Arrow Shield.png", "Harvester": "Harvester.png", "Shuriken": "shuriken.png", "SlowDown": "Remedy.png"}
	for ability in ability_buttons:
		var button: Button = ability_buttons[ability]
		button.icon = load(POWERUP_ICONS[ability]) if POWERUP_ICONS.has(ability) else graphics.texture(icons[ability])
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 30)

# Editor-only QA panel, also gated by railway_fury/debug/enable_speed_cheats.
func _build_debug_speed_controls() -> void:
	if not battle.debug_speed_cheats_enabled(): return
	var panel := PanelContainer.new()
	panel.name = "TEMP_CHEATS_REMOVE_BEFORE_RELEASE"
	root_ui.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.position += Vector2(-470, 78)
	panel.custom_minimum_size.x = 440
	panel.add_theme_stylebox_override("panel", Style.panel(Color("45152e"), Color("ff69c5")))
	var column := VBoxContainer.new()
	panel.add_child(column)
	var warning := Style.label("EDITOR CHEATS", 18, true)
	warning.modulate = Color("ff8ad3")
	column.add_child(warning)
	debug_speed_label = Style.label("", 16, true)
	column.add_child(debug_speed_label)
	var buttons := GridContainer.new()
	buttons.columns = 4
	column.add_child(buttons)
	for multiplier in battle.DEBUG_SPEEDS:
		var button := make_button(tr("%dx") % multiplier, func(): battle.set_debug_speed(multiplier))
		button.custom_minimum_size = Vector2(62, 38)
		button.tooltip_text = "Speed up the entire simulation. At 4x and above: automatically aim and fire at the closest enemy without lateral movement, use unlocked abilities as soon as they are ready, and ignore enemy arrows. Row and contact damage still apply. Carries between track runs until you quit the game."
		if battle.free_aim_mode:
			button.tooltip_text = "At 4x and above, the simulation pilot aims, shoots, dodges fire and projectiles, collects loot and uses abilities. All damage still applies. Below 4x you control the player."
		buttons.add_child(button)
		debug_speed_buttons[multiplier] = button
	var hint := Style.label("F7 CYCLE  /  F8 NORMAL  ·  session only", 13)
	column.add_child(hint)
	panel.mouse_entered.connect(func(): VirtualCursor.set_gameplay_pointer_hidden(false))
	panel.mouse_exited.connect(func():
		if not battle.suspended and not battle.ended: VirtualCursor.set_gameplay_pointer_hidden(true))
	refresh_debug_speed()

func refresh_debug_speed() -> void:
	if debug_speed_label == null: return
	debug_speed_label.text = tr("GAMEPLAY SPEED: %dx") % battle.debug_speed
	if battle.editor_autopilot_enabled(): debug_speed_label.text += tr("  /  AUTOPILOT")
	for multiplier in debug_speed_buttons:
		debug_speed_buttons[multiplier].modulate = Color("ff8ad3") if multiplier == battle.debug_speed else Color.WHITE

func _apply_text_scale() -> void:
	Style.scale_fonts(root_ui)

func make_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	Style.style_button(button)
	button.pressed.connect(func():
		action.call())
	return button

func _build_overlay() -> void:
	battle.overlay = ColorRect.new()
	root_ui.add_child(battle.overlay)
	battle.overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle.overlay.color = Color(0.025, 0.04, 0.065, 0.96)
	var center := CenterContainer.new()
	battle.overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 760
	panel.add_theme_stylebox_override("panel", Style.panel())
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var eyebrow := Style.label("RAILWAY FURY", 16, true)
	eyebrow.modulate = Style.GOLD
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(eyebrow)
	battle.overlay_title = Style.label("PAUSED", 32, true)
	battle.overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(battle.overlay_title)
	overlay_detail = Style.label("", 18)
	overlay_detail.custom_minimum_size.x = 700
	overlay_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(overlay_detail)
	tutorial_cards = HBoxContainer.new()
	tutorial_cards.add_theme_constant_override("separation", 18)
	box.add_child(tutorial_cards)
	for shooting in [false, true]:
		var card = VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tutorial_cards.add_child(card)
		var picture = preload("res://Games/RowDivers/RowDiversControlsPicture.gd").new()
		picture.shooting = shooting
		card.add_child(picture)
		var caption = Style.label("CLICK TO SHOOT" if shooting else "MOVE LEFT / RIGHT", 20, true)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(caption)
		if not shooting:
			var speed_hint = Style.label("Press Shift to toggle double speed", 16)
			speed_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			card.add_child(speed_hint)
	var power_hint := Style.label("SPACE: Activate the highlighted power.\nEach press uses one ready power.", 16)
	power_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	power_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	power_hint.custom_minimum_size.x = 700
	box.add_child(power_hint)
	tutorial_cards.hide()
	battle.resume = make_button("RESUME", battle._resume)
	box.add_child(battle.resume)
	battle.retry = make_button("RUN THE TRACKS", func(): battle.get_tree().reload_current_scene())
	box.add_child(battle.retry)
	battle.retry.hide()
	upgrades_button = make_button("UPGRADES", func():
		if not battle.ended: battle._finish(false)
		battle.get_tree().change_scene_to_file(Util.get_upgrade_scene_path()))
	box.add_child(upgrades_button)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	settings_button = make_button("SETTINGS", show_settings)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(settings_button)
	tutorial_button = make_button("HOW TO PLAY", show_tutorial)
	tutorial_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(tutorial_button)
	var menu := make_button("MAIN MENU", func():
		preload("res://Games/RowDivers/RowDiversEditorLoop.gd").stop()
		if not battle.ended: battle._finish(false)
		battle.get_tree().change_scene_to_file(Util.PATH_GAME_LAUNCHER))
	menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(menu)
	battle.overlay.hide()

func _build_settings() -> void:
	settings_panel = PanelContainer.new()
	root_ui.add_child(settings_panel)
	settings_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_panel.offset_left = 80
	settings_panel.offset_top = 24
	settings_panel.offset_right = -80
	settings_panel.offset_bottom = -24
	settings_panel.add_theme_stylebox_override("panel", Style.panel())
	var box := VBoxContainer.new()
	settings_panel.add_child(box)
	box.add_child(make_button("SETTINGS  /  BACK TO PAUSE", settings_panel.hide))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	settings_content = load("res://Settings.tscn").instantiate()
	settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(settings_content)
	Style.apply_fonts(settings_content)
	settings_panel.hide()

func show_settings() -> void:
	battle.suspended = true
	VirtualCursor.set_gameplay_pointer_hidden(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings_panel.show()
	settings_content.show_screen()

func show_tutorial() -> void:
	tutorial_page = 0
	battle.suspended = true
	VirtualCursor.set_gameplay_pointer_hidden(false)
	battle.overlay.show()
	battle.retry.hide()
	battle.resume.show()
	upgrades_button.hide()
	settings_button.hide()
	tutorial_button.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_tutorial()

func _refresh_tutorial() -> void:
	battle.overlay_title.text = "HOW TO PLAY"
	overlay_detail.hide()
	tutorial_cards.show()
	battle.resume.text = "PLAY"

func advance_tutorial() -> bool:
	if tutorial_page < 0: return false
	tutorial_page = -1
	tutorial_cards.hide()
	overlay_detail.show()
	upgrades_button.show()
	settings_button.show()
	tutorial_button.show()
	overlay_detail.text = ""
	return false

func pause() -> void:
	tutorial_page = -1
	tutorial_cards.hide()
	overlay_detail.show()
	battle.overlay_title.text = "TAKE A BREATHER"
	overlay_detail.text = "Your run is paused."
	battle.resume.text = "RESUME"
	battle.resume.show()
	battle.overlay.show()
	upgrades_button.show()
	settings_button.show()
	tutorial_button.show()

func toast(text: String, color = Color("eec782")) -> void:
	toast_label.text = text
	toast_label.modulate = color
	toast_time = 2.1

func refresh() -> void:
	if not is_instance_valid(battle) or battle.data == null: return
	battle.hud.text = tr("VITALITY  %s / %s") % [Util.get_number_short_text(battle.health), Util.get_number_short_text(battle.s("MaxHP"))]
	hp_bar.max_value = maxf(1, battle.s("MaxHP"))
	hp_bar.value = battle.health
	armor_label.text = tr("ARMOR %s  /  %s  /  %s\nTRACK RUN TIME %s") % [Util.get_number_short_text(battle.armor), tr("DOUBLE SPEED") if battle.running else tr("NORMAL SPEED"), tr(battle.fire_mode.to_upper()), preload("res://Games/RowDivers/RowDiversTiming.gd").format_time(float(battle.data.get("gameplay_seconds",0)))]
	currency.text = tr("GOLD %s   GEMS %s   CROWNS %s") % [Util.get_number_short_text(battle.data.wallet[0]), Util.get_number_short_text(battle.data.wallet[1]), Util.get_number_short_text(battle.data.wallet[2])]
	battle.ability_hud.text = tr("%.1f m    SECTION %d / 15    %s    ESC PAUSE") % [(-battle.player_position.z if battle.free_aim_mode else battle.distance), mini(15, battle.section), preload("res://Games/RowDivers/RowDiversLevelThemes.gd").level_name(int(battle.data.prestige))]
	if battle.free_aim_mode:
		battle.ability_hud.text += tr("    FIRE %d / 3 · CONTROL %d%%") % [battle.fire_waves.stage + 1, battle.s("Fire_Wave_Control_" + str(int(battle.data.prestige)))]
	var next: String = battle.next_powerup()
	for ability in NAMES:
		var state: Dictionary = battle.abilities[ability]
		var owned: bool = battle.unlocked(ability)
		ability_columns[ability].visible = owned
		var status: String = "LOCKED" if not owned else (tr("ACTIVE %.1fs") % state.active if state.active > 0 else (tr("%.0fs") % ceil(state.cooldown) if state.cooldown > 0 else "READY"))
		var selected: bool = ability == next
		ability_buttons[ability].text = (tr("[SPACE] ") if selected else "") + tr(NAMES[ability]) + "\n" + tr(status)
		if powerup_highlights.get(ability) != selected:
			powerup_highlights[ability] = selected
			var card_style = Style.panel(Color("29333d") if selected else Color("172431"), Style.GOLD if selected else Color("465462"))
			card_style.content_margin_left = 10
			card_style.content_margin_right = 10
			card_style.set_border_width_all(2 if selected else 1)
			ability_buttons[ability].add_theme_stylebox_override("normal", card_style)
		ability_buttons[ability].disabled = not owned or state.active > 0 or state.cooldown > 0
		ability_buttons[ability].tooltip_text = tr("Press Space to use the highlighted power, or click a ready power. Lasts 10 seconds; recharges for 30 seconds after it ends.") if owned else tr("Unlock this ability in Upgrades.")
		if ability == "SlowDown" and owned:
			ability_buttons[ability].tooltip_text += "\n" + tr("Regenerates %.2f%% of maximum health per second (1.5x walking damage).") % battle.regen_percent_per_second()
		ability_bars[ability].value = state.active / state.duration if state.active > 0 else (1.0 - state.cooldown / state.wait if owned else 0.0)
	var nearest: Dictionary = {}
	for enemy in battle.enemies:
		if enemy.boss and enemy.node.position.distance_to(battle.player_position) < 20:
			nearest = enemy
			break
	boss_label.visible = not nearest.is_empty()
	boss_bar.visible = not nearest.is_empty()
	if not nearest.is_empty():
		boss_label.text = tr(["", "", "", "", "THE PLAGUEKEEPER", "THE SOUL WARDEN", "THE LAST SOVEREIGN"][int(nearest.kind)])
		boss_bar.max_value = nearest.max_hp
		boss_bar.value = nearest.hp

func _process(delta: float) -> void:
	toast_time = maxf(0, toast_time - delta)
	toast_label.modulate.a = minf(1, toast_time * 3)
	feedback.color.a = maxf(0, feedback.color.a - delta * 0.8)
