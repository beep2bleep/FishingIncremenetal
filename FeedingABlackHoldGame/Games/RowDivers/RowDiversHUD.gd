extends CanvasLayer
const Style = preload("res://Games/RowDivers/RowDiversStyle.gd")
const NAMES = {"ArrowShield": "ARROW SHIELD", "Harvester": "HARVESTER", "Shuriken": "SHURIKEN", "SlowDown": "SLOW DOWN"}
const TUTORIAL = [
	["01 / KEEP MOVING", "The row carries you forward automatically.\nUse A / D or the arrow keys to steer around enemies.\nShift toggles running: 50% faster, with 50% more row damage."],
	["02 / MAKE EVERY SHOT COUNT", "Left click fires straight ahead. A green crosshair means a target is in range.\nHealth drains every two seconds. Defeat enemies and collect their drops.\nDeath banks your loot: buy upgrades, then dive again."],
	["03 / BUILD YOUR LOADOUT", "Unlock Hold Fire and Auto Shoot in the upgrade tree.\nAfter Auto Shoot, use 1 for Hold and 2 for Auto.\nDagger strikes nearby foes automatically. Third Eye follows your mouse."],
	["04 / TURN THE FIGHT", "3 — Arrow Shield: block enemy arrows for 5 seconds.\n4 — Harvester: double gold and gems collected for 10 seconds.\n5 — Shuriken: add shuriken shots for 10 seconds.\n6 — Slow Down: reduce forward speed for 4 seconds.\nBuy each ability first. Watch its cooldown; Escape pauses."]
]
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
var settings_panel: PanelContainer
var settings_content: Control
var overlay_detail: Label
var upgrades_button: Button
var settings_button: Button
var tutorial_button: Button
var tutorial_page = -1

func build(owner_battle: Node3D) -> void:
	battle = owner_battle
	root_ui = Control.new()
	root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)
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
	var abilities := HBoxContainer.new()
	root_ui.add_child(abilities)
	abilities.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	abilities.position += Vector2(-410, -102)
	abilities.add_theme_constant_override("separation", 12)
	var key = 3
	for ability in NAMES:
		var column := VBoxContainer.new()
		abilities.add_child(column)
		var button := make_button("[%d] %s" % [key, NAMES[ability]], func(): battle._activate(ability))
		button.custom_minimum_size = Vector2(196, 52)
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
		key += 1
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
	SignalBus.text_size_changed.connect(_apply_text_scale)
	_apply_text_scale()

func _apply_text_scale() -> void:
	Style.scale_fonts(root_ui)

func make_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	Style.style_button(button)
	button.pressed.connect(func():
		if battle.audio != null: battle.audio.sound("purchase")
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
	var eyebrow := Style.label("RAILWAY FURY  /  ROW DIVERS", 16, true)
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
	battle.resume = make_button("RESUME", battle._resume)
	box.add_child(battle.resume)
	battle.retry = make_button("DIVE AGAIN", func(): battle.get_tree().reload_current_scene())
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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings_panel.show()
	settings_content.show_screen()

func show_tutorial() -> void:
	tutorial_page = 0
	battle.suspended = true
	battle.overlay.show()
	battle.retry.hide()
	battle.resume.show()
	upgrades_button.hide()
	settings_button.hide()
	tutorial_button.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_tutorial()

func _refresh_tutorial() -> void:
	battle.overlay_title.text = TUTORIAL[tutorial_page][0]
	overlay_detail.text = TUTORIAL[tutorial_page][1]
	battle.resume.text = "START DIVING" if tutorial_page == TUTORIAL.size() - 1 else "NEXT"

func advance_tutorial() -> bool:
	if tutorial_page < 0: return false
	tutorial_page += 1
	if tutorial_page < TUTORIAL.size():
		_refresh_tutorial()
		return true
	tutorial_page = -1
	upgrades_button.show()
	settings_button.show()
	tutorial_button.show()
	overlay_detail.text = ""
	return false

func pause() -> void:
	tutorial_page = -1
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
	battle.hud.text = "VITALITY  %s / %s" % [Util.get_number_short_text(battle.health), Util.get_number_short_text(battle.s("MaxHP"))]
	hp_bar.max_value = maxf(1, battle.s("MaxHP"))
	hp_bar.value = battle.health
	armor_label.text = "ARMOR %s  /  %s  /  %s" % [Util.get_number_short_text(battle.armor), "RUN" if battle.running else "WALK", battle.fire_mode.to_upper()]
	currency.text = "GOLD %s   GEMS %s   CROWNS %s" % [Util.get_number_short_text(battle.data.wallet[0]), Util.get_number_short_text(battle.data.wallet[1]), Util.get_number_short_text(battle.data.wallet[2])]
	battle.ability_hud.text = "%.1f m    SECTION %d / 15    PRESTIGE %d    ESC PAUSE" % [battle.distance, mini(15, battle.section), int(battle.data.prestige)]
	var key = 3
	for ability in NAMES:
		var state: Dictionary = battle.abilities[ability]
		var owned: bool = battle.unlocked(ability)
		var status: String = "LOCKED" if not owned else ("ACTIVE %.1fs" % state.active if state.active > 0 else ("%.0fs" % ceil(state.cooldown) if state.cooldown > 0 else "READY"))
		ability_buttons[ability].text = "[%d] %s\n%s" % [key, NAMES[ability], status]
		ability_buttons[ability].disabled = not owned or state.active > 0 or state.cooldown > 0
		ability_buttons[ability].tooltip_text = "Press %d or click to activate. Cooldown starts after the effect ends." % key if owned else "Unlock this ability in Upgrades."
		ability_bars[ability].value = state.active / state.duration if state.active > 0 else (1.0 - state.cooldown / state.wait if owned else 0.0)
		key += 1
	var nearest: Dictionary = {}
	for enemy in battle.enemies:
		if enemy.boss and enemy.node.position.distance_to(battle.player_position) < 20:
			nearest = enemy
			break
	boss_label.visible = not nearest.is_empty()
	boss_bar.visible = not nearest.is_empty()
	if not nearest.is_empty():
		boss_label.text = ["", "", "", "", "THE PLAGUEKEEPER", "THE SOUL WARDEN", "THE LAST SOVEREIGN"][int(nearest.kind)]
		boss_bar.max_value = nearest.max_hp
		boss_bar.value = nearest.hp

func _process(delta: float) -> void:
	toast_time = maxf(0, toast_time - delta)
	toast_label.modulate.a = minf(1, toast_time * 3)
	feedback.color.a = maxf(0, feedback.color.a - delta * 0.8)
