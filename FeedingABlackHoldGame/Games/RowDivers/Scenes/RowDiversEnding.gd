extends Control
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Style = preload("res://Games/RowDivers/RowDiversStyle.gd")
const Analytics = preload("res://Games/RowDivers/RowDiversAnalytics.gd")
const Endings = preload("res://Games/RowDivers/RowDiversEndings.gd")
var heading: Label
var story: RichTextLabel
var choices: GridContainer
var continue_button: Button
var reveal: Tween
var persist_results = true
var audio: Node
var illustration: TextureRect
var choice_made = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.game_state = Util.GAME_STATES.UPGRADES
	audio = preload("res://Games/RowDivers/RowDiversAudio.gd").new()
	add_child(audio)
	audio.play_context("god")
	var data: Dictionary = Progress.load_data()
	Progress.check_achievements(data)
	if Progress.Demo.enabled() or not data.unlocks.get("GodTab", false) or not data.get("god_panel_unlocked", false):
		get_tree().call_deferred("change_scene_to_file", Util.get_upgrade_scene_path())
		return
	var background := ColorRect.new()
	background.color = Color("0c1420")
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1100, 530)
	panel.add_theme_stylebox_override("panel", Style.panel())
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var tag := Style.label("RAILWAY FURY  /  THE END OF THE ROW", 16, true)
	tag.modulate = Style.GOLD
	column.add_child(tag)
	heading = Style.label("ONE LAST CHOICE", 42, true)
	column.add_child(heading)
	illustration = TextureRect.new()
	illustration.custom_minimum_size = Vector2(0, 440)
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.hide()
	column.add_child(illustration)
	story = RichTextLabel.new()
	story.fit_content = true
	story.custom_minimum_size = Vector2(1056, 215)
	story.add_theme_font_override("normal_font", Style.BODY)
	story.add_theme_font_size_override("normal_font_size", 23)
	story.text = "Four rows. Four crowns. The last sovereign falls, and the wheels finally slow.\n\nBuild a home from the railway, or leave its power behind and step into the unknown.\n\nWhat will you do with the end of the line?"
	column.add_child(story)
	choices = GridContainer.new()
	choices.columns = 2
	choices.add_theme_constant_override("h_separation", 18)
	choices.add_theme_constant_override("v_separation", 12)
	column.add_child(choices)
	for choice in Endings.CHOICES:
		var card := VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choices.add_child(card)
		var picture := TextureRect.new()
		picture.texture = load(Endings.CHOICES[choice].texture)
		picture.custom_minimum_size = Vector2(0, 255)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(picture)
		var button := Button.new()
		button.text = Endings.CHOICES[choice].button
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Style.style_button(button)
		button.pressed.connect(_choose.bind(choice))
		card.add_child(button)
	continue_button = Button.new()
	continue_button.text = "THANKS FOR PLAYING  /  MAIN MENU"
	Style.style_button(continue_button)
	continue_button.pressed.connect(func(): get_tree().change_scene_to_file(Util.PATH_GAME_LAUNCHER))
	column.add_child(continue_button)
	continue_button.hide()
	Style.scale_fonts(self)
	story.add_theme_font_size_override("normal_font_size", roundi(23 * SaveHandler.text_scale))
	_reveal()

func _reveal() -> void:
	story.visible_ratio = 0
	reveal = create_tween()
	reveal.tween_property(story, "visible_ratio", 1.0, 3.5)

func _choose(choice: String) -> void:
	if choice_made or not Endings.CHOICES.has(choice): return
	choice_made = true
	var definition: Dictionary = Endings.CHOICES[choice]
	audio.play_context("credits")
	audio.sound("ability")
	var data: Dictionary = Progress.load_data()
	data["ending"] = choice
	if not data.has("endings_seen"): data.endings_seen = {}
	data.endings_seen[choice] = true
	if persist_results:
		preload("res://Games/RowDivers/RowDiversTiming.gd").record(data,"ending")
		Analytics.ending(data, Progress.free_aim_mode, Progress.active_tree)
		Progress.save_data(data)
	choices.hide()
	heading.text = tr(definition.title)
	illustration.texture = load(definition.texture)
	illustration.show()
	var credits := tr("Art: Synty Studios")
	if preload("res://Games/RowDivers/RowDiversGraphics.gd").illustrated():
		credits = ""
	elif preload("res://Games/RowDivers/RowDiversGraphics.gd").original():
		credits = tr("Classic artwork: Hermurx")
	story.text = tr(definition.story) + "\n\n" + tr("Thank you for playing Railway Fury.") + "\n" + credits + "\n" + tr("Audio: see asset credits")
	if reveal != null: reveal.kill()
	_reveal()
	continue_button.show()
