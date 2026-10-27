extends Button
## Local Steam artwork keeps the menu independent of network availability.
const FRANCHISE_URL = "https://store.steampowered.com/franchise/Beep2Bleep"
const GAMES = [
	["Vanguard - Idle Auto Battler", preload("res://Games/RowDivers/Art/OtherGames/4519820.jpg")],
	["Deepcore", preload("res://Games/RowDivers/Art/OtherGames/4562070.jpg")],
	["BleepWare Incrementals", preload("res://Games/RowDivers/Art/OtherGames/4637560.jpg")],
	["Bleeping Spaceships", preload("res://Games/RowDivers/Art/OtherGames/3821510.jpg")],
	["Bounty For Sharks", preload("res://Games/RowDivers/Art/OtherGames/1237090.jpg")],
	["Home Plate Baseball", preload("res://Games/RowDivers/Art/OtherGames/989260.jpg")],
]
var capsule_count = 2
var vertical_layout = false
var fade_after_delay = false
var capsule_size = Vector2(246, 115)
var capsules: Array[TextureRect] = []
var capsule: TextureRect
var heading: Label
var game_title: Label
var current_index = 0

func _ready() -> void:
	name = "PlayMyOtherGames"
	custom_minimum_size = Vector2(capsule_size.x+24, capsule_size.y+84) if vertical_layout else Vector2(0, 142)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = FRANCHISE_URL
	if fade_after_delay: set_meta("railway_no_hover_rotation", true)
	preload("res://Games/RowDivers/RowDiversStyle.gd").style_button(self)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_"+side, 12)
	add_child(margin)
	var layout: BoxContainer = VBoxContainer.new() if vertical_layout else HBoxContainer.new()
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_theme_constant_override("separation", 12 if vertical_layout else 24)
	margin.add_child(layout)
	heading = Label.new()
	heading.add_theme_font_size_override("font_size", 23 if vertical_layout else 30)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if vertical_layout:
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		layout.add_child(heading)
	var images := HBoxContainer.new()
	images.mouse_filter = Control.MOUSE_FILTER_IGNORE
	images.add_theme_constant_override("separation", 14)
	layout.add_child(images)
	for i in range(clampi(capsule_count, 1, GAMES.size())):
		var image := TextureRect.new()
		image.custom_minimum_size = capsule_size
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		images.add_child(image)
		capsules.append(image)
	capsule = capsules[0]
	var words := VBoxContainer.new()
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(words)
	if not vertical_layout:
		words.add_child(heading)
	game_title = Label.new()
	game_title.add_theme_font_size_override("font_size", 20)
	game_title.modulate = Color("eec782")
	game_title.visible = not vertical_layout
	words.add_child(game_title)
	words.visible = not vertical_layout
	current_index = int(Time.get_unix_time_from_system()) % GAMES.size()
	_refresh()
	pressed.connect(func(): OS.shell_open(FRANCHISE_URL))
	if fade_after_delay:
		var fade = create_tween()
		fade.tween_interval(3.0)
		fade.tween_property(self, "modulate:a", 0.0, 3.0)
		fade.tween_callback(func():
			disabled = true
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			focus_mode = Control.FOCUS_NONE
			hide())
		return
	var timer := Timer.new()
	timer.wait_time = 6.0
	timer.timeout.connect(advance)
	add_child(timer)
	timer.start()

func advance() -> void:
	if fade_after_delay: return
	current_index = (current_index+capsules.size()) % GAMES.size()
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and heading != null:
		_refresh()

func _refresh() -> void:
	heading.text = tr("Play my other games")
	var titles: PackedStringArray = []
	for i in range(capsules.size()):
		var game = GAMES[(current_index+i)%GAMES.size()]
		capsules[i].texture = game[1]
		titles.append(game[0])
	game_title.text = "\n".join(titles)
	tooltip_text = heading.text + ": " + ", ".join(titles) + "\n" + FRANCHISE_URL
