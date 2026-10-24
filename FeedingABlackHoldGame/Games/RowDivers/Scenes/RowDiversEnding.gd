extends Control
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Style = preload("res://Games/RowDivers/RowDiversStyle.gd")
var heading: Label
var story: RichTextLabel
var choices: HBoxContainer
var continue_button: Button
var reveal: Tween
var persist_results = true
var audio: Node
var illustration: TextureRect

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.game_state = Util.GAME_STATES.UPGRADES
	audio = preload("res://Games/RowDivers/RowDiversAudio.gd").new()
	add_child(audio)
	audio.play_context("god")
	var data: Dictionary = Progress.load_data()
	Progress.check_achievements(data)
	if not data.unlocks.get("GodTab", false) or not data.get("god_panel_unlocked", false):
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
	panel.custom_minimum_size = Vector2(850, 530)
	panel.add_theme_stylebox_override("panel", Style.panel())
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	panel.add_child(column)
	var tag := Style.label("RAILWAY FURY  /  THE END OF THE ROW", 16, true)
	tag.modulate = Style.GOLD
	column.add_child(tag)
	heading = Style.label("ONE LAST CHOICE", 42, true)
	column.add_child(heading)
	illustration = TextureRect.new()
	illustration.custom_minimum_size = Vector2(0, 150)
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.visible = preload("res://Games/RowDivers/RowDiversGraphics.gd").original()
	if illustration.visible: illustration.texture = preload("res://Games/RowDivers/RowDiversGraphics.gd").texture("Throne.png")
	column.add_child(illustration)
	story = RichTextLabel.new()
	story.fit_content = true
	story.custom_minimum_size = Vector2(790, 215)
	story.add_theme_font_override("normal_font", Style.BODY)
	story.add_theme_font_size_override("normal_font_size", 23)
	story.text = "Four rows. Four crowns. The last sovereign falls, and the wheels finally slow.\n\nThe power that kept this place turning now belongs to you.\nWill you free those who remain, or take the throne for yourself?"
	column.add_child(story)
	choices = HBoxContainer.new()
	choices.add_theme_constant_override("separation", 18)
	column.add_child(choices)
	for choice in ["BenevolentGod", "EvilGod"]:
		var button := Button.new()
		button.text = "FREE THEM" if choice == "BenevolentGod" else "CLAIM THE THRONE"
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Style.style_button(button)
		button.pressed.connect(_choose.bind(choice))
		choices.add_child(button)
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
	audio.play_context("credits")
	audio.sound("ability")
	var data: Dictionary = Progress.load_data()
	data.achievements[choice] = true
	data.claimed[choice] = true
	data["ending"] = choice
	if persist_results: Progress.save_data(data)
	choices.hide()
	heading.text = "A NEW DAWN" if choice == "BenevolentGod" else "THE CROWN IS YOURS"
	if illustration != null and illustration.visible:
		illustration.texture = preload("res://Games/RowDivers/RowDiversGraphics.gd").texture("BenevolentGod.png" if choice == "BenevolentGod" else "DevilGod.png")
	story.text = ("You break the engine's hold and open the gates. For the first time, the row carries no prisoners.\n\nThe tracks stretch into daylight. Whatever comes next, they will choose it freely." if choice == "BenevolentGod" else "You sit upon the empty throne. The engine wakes to your command, and every gate bows before you.\n\nThe row runs again. This time, you decide where it leads.") + "\n\nThank you for playing Railway Fury.\nArt: Synty Studios  •  Audio: see asset credits"
	if preload("res://Games/RowDivers/RowDiversGraphics.gd").illustrated():
		story.text = story.text.replace("Art: Synty Studios", "Illustrated artwork: AI-generated")
	elif preload("res://Games/RowDivers/RowDiversGraphics.gd").original():
		story.text = story.text.replace("Art: Synty Studios", "Classic artwork: Hermurx")
		story.text = story.text.replace("  •  Audio:", "\nAudio:")
	if reveal != null: reveal.kill()
	_reveal()
	continue_button.show()
