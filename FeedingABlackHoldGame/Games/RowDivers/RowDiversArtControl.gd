extends Node
## Session-only editor art selector, also editable in the Remote inspector.
const Graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
const GothicMusic = preload("res://Games/RowDivers/RowDiversGothicMusic.gd")
@export_enum("Modern", "Original", "Illustrated", "Gothic Gore") var art_style: int = 0
@export_group("Gothic Music")
@export_enum("Sanctum Obscura", "Forbidden Grimoire", "Dusk Covenant") var upgrade_music: int = 0
@export_enum("Abyssal Slayer", "Carnage Requiem", "Blood Crucible") var combat_music: int = 0
var previous = -1
var previous_upgrade = 0
var previous_combat = 0
var picker: OptionButton
var upgrade_picker: OptionButton
var combat_picker: OptionButton
var snapshots: Dictionary = {}
var tints: Dictionary = {}
var bars: Dictionary = {}
var flag: ColorRect
var ui_root: Node

static func install(target: Node) -> void:
	if target.has_node("RuntimeArtStyle"): return
	var control := new()
	control.name = "RuntimeArtStyle"
	target.add_child(control)

func _ready() -> void:
	ui_root = get_parent()
	art_style = Graphics.mode()
	previous = art_style
	upgrade_music = GothicMusic.upgrade_track
	combat_music = GothicMusic.combat_track
	previous_upgrade = upgrade_music
	previous_combat = combat_music
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalBus.settings_updated.connect(_refresh)
	if OS.has_feature("editor"):
		var layer := CanvasLayer.new()
		layer.layer = 120
		add_child(layer)
		picker = OptionButton.new()
		picker.name = "EditorArtStyle"
		for title in ["ART: MODERN", "ART: ORIGINAL", "ART: ILLUSTRATED", "ART: GOTHIC GORE"]: picker.add_item(title)
		picker.position = Vector2(1090, 20)
		picker.custom_minimum_size = Vector2(300, 42)
		picker.tooltip_text = "Editor session art style. Also editable under RuntimeArtStyle in the Remote inspector."
		picker.item_selected.connect(func(index): art_style = index)
		layer.add_child(picker)
		upgrade_picker = _music_picker(layer, "menu", "UPGRADE: ")
		combat_picker = _music_picker(layer, "battle", "COMBAT: ")
		get_viewport().size_changed.connect(_place_picker)
		_place_picker()
	call_deferred("_refresh")

func _music_picker(layer: CanvasLayer, context: String, prefix: String) -> OptionButton:
	var result := OptionButton.new()
	result.name = "GothicCombatMusic" if context == "battle" else "GothicUpgradeMusic"
	for cue in GothicMusic.entries(context): result.add_item(prefix + str(GothicMusic.catalog().music[cue].title))
	result.custom_minimum_size = Vector2(315, 42)
	result.tooltip_text = "Phat Phrog Studio — Hellfire Reigns" if context == "battle" else "Phat Phrog Studio — Dark Arts"
	result.item_selected.connect(func(index):
		if context == "battle": combat_music = index
		else: upgrade_music = index)
	layer.add_child(result)
	return result

func _place_picker() -> void:
	picker.position.x = get_viewport().get_visible_rect().size.x - 330
	picker.position.y = 280 if ui_root.get_parent() is CanvasLayer else 20
	upgrade_picker.position = picker.position + Vector2(-330, 0)
	combat_picker.position = picker.position + Vector2(-330, 48)

func _process(_delta: float) -> void:
	var changed := false
	if art_style != previous:
		Graphics.select_mode(clampi(art_style, 0, 3))
		previous = art_style
		changed = true
	if upgrade_music != previous_upgrade:
		GothicMusic.select("menu", upgrade_music)
		previous_upgrade = GothicMusic.upgrade_track
		changed = true
	if combat_music != previous_combat:
		GothicMusic.select("battle", combat_music)
		previous_combat = GothicMusic.combat_track
		changed = true
	if changed: SignalBus.settings_updated.emit()

func _refresh() -> void:
	art_style = Graphics.mode()
	previous = art_style
	if picker != null: picker.select(art_style)
	upgrade_music = GothicMusic.upgrade_track
	combat_music = GothicMusic.combat_track
	previous_upgrade = upgrade_music
	previous_combat = combat_music
	if upgrade_picker != null:
		upgrade_picker.select(upgrade_music)
		combat_picker.select(combat_music)
		upgrade_picker.visible = Graphics.gothic()
		combat_picker.visible = Graphics.gothic()
	# Refresh after the shared UI has applied its own palette.
	call_deferred("_theme")

func _theme() -> void:
	if ui_root.has_method("update_colors"): ui_root.update_colors()
	for node in ui_root.find_children("*", "CanvasItem", true, false):
		if node is Line2D or (node is Sprite2D and node.name == "Center Sprite"):
			if not tints.has(node): tints[node] = node.modulate
			node.modulate = Color("864555") if Graphics.gothic() else tints[node]
		if node is ProgressBar:
			if not bars.has(node): bars[node] = node.get_theme_stylebox("fill") if node.has_theme_stylebox_override("fill") else null
			if Graphics.gothic():
				var fill := StyleBoxFlat.new()
				fill.bg_color = Color("a12642")
				node.add_theme_stylebox_override("fill", fill)
			elif bars[node] != null: node.add_theme_stylebox_override("fill", bars[node])
			else: node.remove_theme_stylebox_override("fill")
	for node in ui_root.find_children("*", "Control", true, false):
		if not (node is Button or node is PanelContainer or node is Panel): continue
		if not snapshots.has(node):
			var styles: Dictionary = {}
			for key in (["normal", "hover", "pressed", "disabled", "focus"] if node is Button else ["panel"]):
				styles[key] = node.get_theme_stylebox(key) if node.has_theme_stylebox_override(key) else null
			snapshots[node] = styles
		for key in snapshots[node]:
			if Graphics.gothic():
				var box := StyleBoxFlat.new()
				box.bg_color = Color("3d1925") if key in ["hover", "pressed"] else Color("17151b")
				box.border_color = Color("bd5268") if key in ["focus", "hover"] else Color("63404b")
				box.set_border_width_all(2)
				box.set_corner_radius_all(2)
				box.set_content_margin_all(12)
				node.add_theme_stylebox_override(key, box)
			elif snapshots[node][key] != null: node.add_theme_stylebox_override(key, snapshots[node][key])
			else: node.remove_theme_stylebox_override(key)
	var mask := ui_root.get_node_or_null("%Click Mask")
	if mask == null: mask = ui_root.get_node_or_null("Background")
	if mask != null:
		if flag == null:
			flag = ColorRect.new()
			flag.name = "GothicFlag"
			flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			flag.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			var shader := ShaderMaterial.new()
			shader.shader = preload("res://Games/RowDivers/GothicFlag.gdshader")
			shader.set_shader_parameter("symbols", load("res://Games/RowDivers/Art/Gothic/symbols.svg"))
			flag.material = shader
			mask.add_child(flag)
		flag.visible = Graphics.gothic()
	# Remove transient blood when returning to another presentation.
	if not Graphics.gothic():
		var blood := ui_root.get_parent().get_node_or_null("GothicBlood")
		if blood != null: blood.queue_free()
