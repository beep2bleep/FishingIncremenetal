extends Control
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Audio = preload("res://Games/RowDivers/RowDiversAudio.gd")
var data: Dictionary
var nodes: Dictionary = {}
var buttons: Dictionary = {}
var world: Node2D
var connections: Node2D
var wallet: Label
var info: Label
var audio: Node
var zoom = 0.22
var pan = Vector2.ZERO
var selected: Dictionary = {}
var details: PanelContainer
var buy_button: Button
var prestige: OptionButton
var description: Label
var achievement_button: Button
var bestiary_button: Button
var collection: PanelContainer
const COLORS = [Color("bec8cc"), Color("78ba88"), Color("7eb4d7"), Color("bf8eda"), Color("ebba60")]

func _ready() -> void:
	if "--rowdivers-compare" in OS.get_cmdline_user_args():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1100, 700))
		DisplayServer.window_set_position(Vector2i(20, 50))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.game_state = Util.GAME_STATES.UPGRADES
	if is_instance_valid(MusicPlayer):
		MusicPlayer.stop()
	data = Progress.load_data()
	var bg = ColorRect.new()
	bg.color = Color("19171d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	world = Node2D.new()
	add_child(world)
	connections = Node2D.new()
	world.add_child(connections)
	for node in Progress.design().upgrades:
		nodes[node.id] = node
		var button = Button.new()
		button.name = "Upgrade_" + node.id
		button.size = Vector2(100, 100)
		button.position = Vector2(float(node.position[0]), -float(node.position[1])) * 20.0 - button.size * 0.5
		button.add_theme_font_size_override("font_size", 20)
		button.text = _symbol(node)
		button.tooltip_text = str(node.upgradeName)
		button.pressed.connect(_purchase_node.bind(node))
		button.mouse_entered.connect(_select.bind(node))
		world.add_child(button)
		buttons[node.id] = button
	wallet = _label(Vector2(40, 30), 28)
	info = _label(Vector2(40, 80), 18)
	var title = _label(Vector2(0, 24), 28)
	title.text = "RAILWAY FURY  /  ROW DIVERS"
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.position.x -= 220
	_button("PLAY  ▶", Vector2(-270, -90), Vector2(230, 60), func():
		Progress.save_data(data)
		get_tree().change_scene_to_file("res://Games/RowDivers/Scenes/RowDiversBattleScene.tscn"), true)
	_button("Center tree", Vector2(40, -90), Vector2(180, 48), _center, true)
	var hint = _label(Vector2(40, -36), 16)
	hint.anchor_top = 1
	hint.anchor_bottom = 1
	hint.text = "Right-drag to pan  •  Scroll to zoom  •  Select a node to inspect and buy"
	prestige = OptionButton.new()
	prestige.position = Vector2(40, 124)
	for i in range(int(data.max_prestige) + 1):
		prestige.add_item("Prestige " + str(i))
	prestige.selected = int(data.prestige)
	prestige.item_selected.connect(func(index): data.prestige = index; Progress.save_data(data))
	add_child(prestige)
	achievement_button = _button("Achievements", Vector2(40, 174), Vector2(180, 42), _show_achievements)
	bestiary_button = _button("Bestiary", Vector2(40, 224), Vector2(180, 42), _show_bestiary)
	collection = PanelContainer.new()
	collection.position = Vector2(350, 160)
	collection.size = Vector2(1050, 710)
	add_child(collection)
	collection.hide()
	details = PanelContainer.new()
	details.position = Vector2(1380, 180)
	details.size = Vector2(480, 420)
	details.anchor_left = 1
	details.anchor_right = 1
	details.position.x = -520
	add_child(details)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	details.add_child(box)
	description = Label.new()
	description.name = "Description"
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(420, 290)
	description.add_theme_font_size_override("font_size", 22)
	box.add_child(description)
	buy_button = Button.new()
	buy_button.custom_minimum_size.y = 58
	buy_button.text = "BUY"
	buy_button.pressed.connect(_buy)
	box.add_child(buy_button)
	details.hide()
	audio = Audio.new()
	add_child(audio)
	audio.play_music(false)
	_center()
	_refresh()

func _label(pos: Vector2, font_size: int) -> Label:
	var label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func _button(text: String, pos: Vector2, dimensions: Vector2, action: Callable, bottom = false) -> Button:
	var button = Button.new()
	button.text = text
	button.position = pos
	button.size = dimensions
	if bottom:
		button.anchor_top = 1
		button.anchor_bottom = 1
		if pos.x < 0:
			button.anchor_left = 1
			button.anchor_right = 1
	button.pressed.connect(action)
	add_child(button)
	return button

func _symbol(node: Dictionary) -> String:
	var title = str(node.upgradeName).to_lower()
	if "arrow" in title or "bow" in title: return "➶"
	if "hp" in title or "health" in title or "heart" in title: return "+"
	if "armor" in title: return "◇"
	if "dagger" in title: return "†"
	if "fire" in title or "burn" in title: return "△"
	if not node.unlocks.is_empty(): return "★"
	return "○"

func _center() -> void:
	var root: Dictionary = Progress.design().upgrades.filter(func(n): return n.isVisible)[0]
	zoom = 1.0 if data.levels.size() < 5 else 0.55
	pan = size * 0.5 - Vector2(float(root.position[0]), -float(root.position[1])) * 20.0 * zoom
	_update_transform()

func _update_transform() -> void:
	world.position = pan
	world.scale = Vector2.ONE * zoom

func _refresh() -> void:
	achievement_button.visible = bool(data.unlocks.get("AchievementsTab", false))
	bestiary_button.visible = bool(data.unlocks.get("BestiaryTab", false))
	wallet.text = "●  %s     ◆  %s     ♛  %s" % [str(data.wallet[0]), str(data.wallet[1]), str(data.wallet[2])]
	info.text = "Runs %d   •   Best %.1f m" % [data.runs, data.best_distance]
	for child in connections.get_children():
		child.queue_free()
	for node in nodes.values():
		var button: Button = buttons[node.id]
		button.visible = Progress.visible(data, node)
		var rank = Progress.level(data, node)
		var style = StyleBoxFlat.new()
		style.bg_color = Color("26222a") if rank == 0 else Color("394539")
		style.border_color = COLORS[clampi(int(node.rarity), 0, COLORS.size() - 1)]
		style.set_border_width_all(5)
		style.set_corner_radius_all(7)
		button.add_theme_stylebox_override("normal", style)
		button.modulate.a = 1.0 if rank > 0 or Progress.can_buy(data, node) else 0.5
		button.text = _symbol(node) + "\n%d/%d" % [rank, node.maxLevel]
		for child_id in node.children:
			if not Progress.visible(data, nodes[child_id]): continue
			var line = Line2D.new()
			line.width = 4
			line.default_color = Color("a18e80")
			line.add_point(button.position + button.size * 0.5)
			line.add_point(buttons[child_id].position + buttons[child_id].size * 0.5)
			connections.add_child(line)
	if not selected.is_empty(): _select(selected)

func _select(node: Dictionary) -> void:
	selected = node
	details.show()
	description.text = "%s\n\n%s\n\nLevel %d / %d\nCost: %s %s" % [node.upgradeName, node.upgradeDescription, Progress.level(data, node), node.maxLevel, str(Progress.cost(data, node)), ["Gold", "Gems", "Crowns"][int(node.cost.currencyType)]]
	buy_button.disabled = not Progress.can_buy(data, node)
	buy_button.text = "MAXED" if Progress.level(data, node) >= int(node.maxLevel) else "BUY UPGRADE"

func _buy() -> void:
	if Progress.buy(data, selected):
		Progress.save_data(data)
		audio.sound("purchase")
		_refresh()

func _purchase_node(node: Dictionary) -> void:
	_select(node)
	_buy()

func _collection_box(title: String) -> VBoxContainer:
	for child in collection.get_children():
		collection.remove_child(child)
		child.queue_free()
	var box = VBoxContainer.new()
	collection.add_child(box)
	var close = Button.new()
	close.text = title + "  —  CLOSE"
	close.custom_minimum_size.y = 48
	close.pressed.connect(collection.hide)
	box.add_child(close)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1000, 620)
	box.add_child(scroll)
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)
	collection.show()
	return content

func _show_achievements() -> void:
	var box = _collection_box("ACHIEVEMENTS")
	for achievement in Progress.design().settings.achievements:
		var key = str(Progress.design().enums.AchievementType[str(int(achievement.achievementType))])
		var row = Button.new()
		row.custom_minimum_size.y = 82
		row.text = "%s — %s\nReward: %s %s  •  %s" % [achievement.achievementName, achievement.description, str(achievement.reward), ["Gold", "Gems", "Crowns"][int(achievement.currencyType)], "Claimed" if data.claimed.get(key, false) else ("CLAIM" if data.achievements.get(key, false) else "Locked")]
		row.disabled = not data.achievements.get(key, false) or data.claimed.get(key, false)
		row.pressed.connect(func():
			if Progress.claim(data, achievement):
				Progress.save_data(data)
				_refresh()
				_show_achievements())
		box.add_child(row)

func _show_bestiary() -> void:
	var box = _collection_box("BESTIARY")
	for i in range(7):
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 24)
		label.text = "%s   •   Defeated: %d" % [str(Progress.design().enums.ZombieType[str(i)]).replace("_", " "), int(data.bestiary.get(str(i), 0))]
		box.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pan += event.relative
		_update_transform()
	if event is InputEventMouseButton and event.pressed:
		var factor = 1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var old = zoom
			zoom = clampf(zoom * factor, 0.08, 2.0)
			pan = event.position - (event.position - pan) * zoom / old
			_update_transform()
