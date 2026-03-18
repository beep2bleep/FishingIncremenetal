extends PanelContainer
class_name MiningUpgradePanel

signal request_run
signal play_ui_click

const SAVE_PATH := "user://mining_mode_save_v1.json"
const FIRST_BOSS_DEPTH := 800
const BOSS_INTERVAL_METERS := 200

@onready var title_label: Label = $Margin/Root/TitleLabel
@onready var summary_label: Label = $Margin/Root/SummaryPanel/SummaryMargin/SummaryLabel
@onready var wallet_label: Label = $Margin/Root/WalletLabel
@onready var checkpoint_list: VBoxContainer = $Margin/Root/Content/LeftPanel/LeftMargin/LeftVBox/CheckpointList
@onready var loadout_list: VBoxContainer = $Margin/Root/Content/LeftPanel/LeftMargin/LeftVBox/LoadoutList
@onready var upgrade_list: VBoxContainer = $Margin/Root/Content/RightPanel/RightMargin/RightVBox/UpgradeScroll/UpgradeList
@onready var reset_button: Button = $Margin/Root/ActionRow/ResetButton

var persistent_data := {
	"wallet": 0,
	"best_depth": 0.0,
	"upgrades": {},
	"boss_unlocks": {},
	"checkpoint_owned": {},
	"selected_checkpoint": 0,
	"equipped": ["pistol", ""],
	"last_run_summary": "No mining run completed yet."
}

var checkpoint_buttons := {}
var loadout_buttons: Array[Button] = []
var upgrade_buttons := {}
var icon_cache := {}
var weapon_labels := {
	"pistol": "Pistol",
	"shotgun": "Scattergun",
	"rifle": "Burst Rifle",
	"railgun": "Railgun"
}
var upgrade_catalog: Array[Dictionary] = [
	{"id": "drill_power", "label": "Drill Power", "summary": "Shreds harder nodes faster.", "base_cost": 24, "cost_mult": 1.42, "max_level": 10, "icon": "drill"},
	{"id": "drill_integrity", "label": "Drill Integrity", "summary": "More drill durability per run.", "base_cost": 26, "cost_mult": 1.43, "max_level": 10, "icon": "drill"},
	{"id": "oxygen_tanks", "label": "Oxygen Tanks", "summary": "Longer dives before recall.", "base_cost": 28, "cost_mult": 1.45, "max_level": 10, "icon": "oxygen"},
	{"id": "hull_plating", "label": "Hull Plating", "summary": "More hull to tank hazards and bosses.", "base_cost": 28, "cost_mult": 1.45, "max_level": 10, "icon": "shield"},
	{"id": "cargo_racks", "label": "Ore Grading", "summary": "Raises the cash value of the haul you bring back.", "base_cost": 32, "cost_mult": 1.47, "max_level": 8, "icon": "ore"},
	{"id": "dirt_compressor", "label": "Dirt Compressor", "summary": "Makes the basic shaft dirt worth more.", "base_cost": 20, "cost_mult": 1.4, "max_level": 8, "icon": "ore"},
	{"id": "ore_scanner", "label": "Ore Scanner", "summary": "Boosts deep rare node spawns.", "base_cost": 44, "cost_mult": 1.48, "max_level": 6, "icon": "scanner"},
	{"id": "thruster_power", "label": "Thruster Power", "summary": "Base descent speed goes up.", "base_cost": 34, "cost_mult": 1.45, "max_level": 10, "icon": "speed"},
	{"id": "shaft_lubricant", "label": "Shaft Lubricant", "summary": "Cleaner steering and a little more speed.", "base_cost": 38, "cost_mult": 1.45, "max_level": 8, "icon": "speed"},
	{"id": "cord_winch", "label": "Cord Winch", "summary": "Ascent cord hauls you up even faster.", "base_cost": 48, "cost_mult": 1.48, "max_level": 8, "icon": "speed"},
	{"id": "launch_thrusters", "label": "Launch Thrusters", "summary": "The start of every run gets much faster.", "base_cost": 56, "cost_mult": 1.5, "max_level": 6, "requires": {"thruster_power": 2}, "icon": "speed"},
	{"id": "start_boost", "label": "Drop Rails", "summary": "Extends the super-fast opening burst.", "base_cost": 78, "cost_mult": 1.56, "max_level": 5, "requires": {"launch_thrusters": 2}, "icon": "speed"},
	{"id": "teleport_core", "label": "Teleport Core", "summary": "Instant shaft entry burst with auto-scoop.", "base_cost": 620, "cost_mult": 2.0, "max_level": 1, "requires": {"start_boost": 5}, "icon": "speed"},
	{"id": "punch_damage", "label": "Shock Fist", "summary": "Punches become a real backup weapon.", "base_cost": 16, "cost_mult": 1.38, "max_level": 10, "icon": "weapon"},
	{"id": "pistol_damage", "label": "Pistol Damage", "summary": "Better skeet cleanup and boss chip damage.", "base_cost": 22, "cost_mult": 1.42, "max_level": 10, "icon": "weapon"},
	{"id": "pistol_reload", "label": "Pistol Reload", "summary": "Less downtime on the starter gun.", "base_cost": 22, "cost_mult": 1.42, "max_level": 8, "icon": "weapon"},
	{"id": "shotgun_unlock", "label": "Unlock Scattergun", "summary": "Adds a short-range burst weapon for slot two.", "base_cost": 96, "cost_mult": 2.0, "max_level": 1, "requires": {"pistol_damage": 2}, "icon": "weapon"},
	{"id": "shotgun_damage", "label": "Scattergun Damage", "summary": "More burst for close mining fights.", "base_cost": 54, "cost_mult": 1.46, "max_level": 8, "requires": {"shotgun_unlock": 1}, "icon": "weapon"},
	{"id": "shotgun_reload", "label": "Scattergun Reload", "summary": "Gets the shell swap moving.", "base_cost": 56, "cost_mult": 1.46, "max_level": 8, "requires": {"shotgun_unlock": 1}, "icon": "weapon"},
	{"id": "rifle_unlock", "label": "Unlock Burst Rifle", "summary": "A stable midrange gun with good uptime.", "base_cost": 168, "cost_mult": 2.0, "max_level": 1, "requires": {"shotgun_unlock": 1, "pistol_reload": 3}, "icon": "weapon"},
	{"id": "rifle_damage", "label": "Burst Rifle Damage", "summary": "Scales the rifle into late bosses.", "base_cost": 72, "cost_mult": 1.48, "max_level": 8, "requires": {"rifle_unlock": 1}, "icon": "weapon"},
	{"id": "rifle_reload", "label": "Burst Rifle Reload", "summary": "Keeps the rifle cycling smoothly.", "base_cost": 72, "cost_mult": 1.48, "max_level": 8, "requires": {"rifle_unlock": 1}, "icon": "weapon"},
	{"id": "railgun_unlock", "label": "Unlock Railgun", "summary": "Huge punch, long reload, perfect swap gun.", "base_cost": 320, "cost_mult": 2.0, "max_level": 1, "requires": {"rifle_unlock": 1, "start_boost": 2}, "icon": "weapon"},
	{"id": "railgun_damage", "label": "Railgun Damage", "summary": "Turns the railgun into a checkpoint breaker.", "base_cost": 122, "cost_mult": 1.52, "max_level": 6, "requires": {"railgun_unlock": 1}, "icon": "weapon"},
	{"id": "railgun_reload", "label": "Railgun Reload", "summary": "Shaves the reload enough for swap loops.", "base_cost": 118, "cost_mult": 1.52, "max_level": 6, "requires": {"railgun_unlock": 1}, "icon": "weapon"}
]

func _ready() -> void:
	_style_panel()
	_load_progress()
	_build_ui()
	_refresh_ui()
	reset_button.pressed.connect(_on_reset_pressed)

func refresh_panel() -> void:
	_load_progress()
	_refresh_ui()

func _style_panel() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.12, 0.09, 0.07, 0.96)
	box.border_color = Color(0.86, 0.69, 0.33, 1.0)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.corner_radius_top_left = 6
	box.corner_radius_top_right = 6
	box.corner_radius_bottom_left = 6
	box.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", box)

func _build_ui() -> void:
	for child in checkpoint_list.get_children():
		child.queue_free()
	for child in loadout_list.get_children():
		child.queue_free()
	for child in upgrade_list.get_children():
		child.queue_free()
	checkpoint_buttons.clear()
	loadout_buttons.clear()
	upgrade_buttons.clear()
	for checkpoint in range(FIRST_BOSS_DEPTH, 2001, BOSS_INTERVAL_METERS):
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_checkpoint_pressed.bind(checkpoint))
		_style_button(button)
		checkpoint_list.add_child(button)
		checkpoint_buttons[checkpoint] = button
	for slot_index in range(2):
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_loadout_pressed.bind(slot_index))
		_style_button(button)
		loadout_list.add_child(button)
		loadout_buttons.append(button)
	for upgrade_def in upgrade_catalog:
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_upgrade_pressed.bind(String(upgrade_def["id"])))
		_style_button(button)
		upgrade_list.add_child(button)
		upgrade_buttons[String(upgrade_def["id"])] = button

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.13, 0.09, 0.95)
	normal.border_color = Color(0.76, 0.6, 0.3, 1.0)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	var hover := normal.duplicate(true)
	hover.bg_color = Color(0.25, 0.18, 0.12, 0.98)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", Color(0.97, 0.93, 0.82, 1.0))

func _refresh_ui() -> void:
	title_label.text = "MINING UPGRADES"
	wallet_label.text = "Wallet: $%s    Best Depth: %dm    Start Depth: %dm" % [Util.get_number_short_text(int(persistent_data.get("wallet", 0))), int(round(float(persistent_data.get("best_depth", 0.0)))), int(persistent_data.get("selected_checkpoint", 0))]
	summary_label.text = String(persistent_data.get("last_run_summary", "No mining run completed yet."))
	for checkpoint in checkpoint_buttons.keys():
		var button: Button = checkpoint_buttons[checkpoint]
		var owned := bool(persistent_data["checkpoint_owned"].get(str(checkpoint), false))
		var unlocked := bool(persistent_data["boss_unlocks"].get(str(checkpoint), false))
		var selected: bool = int(persistent_data.get("selected_checkpoint", 0)) == checkpoint
		var cost := _get_checkpoint_cost(checkpoint)
		button.icon = _get_icon_texture("checkpoint")
		if owned:
			button.text = "%dm beacon%s" % [checkpoint, " (selected)" if selected else ""]
			button.disabled = false
		elif unlocked:
			button.text = "Buy %dm beacon - $%d" % [checkpoint, cost]
			button.disabled = int(persistent_data.get("wallet", 0)) < cost
		else:
			button.text = "%dm beacon locked" % checkpoint
			button.disabled = true
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	for slot_index in range(loadout_buttons.size()):
		var weapon_id := String(equipped[slot_index])
		loadout_buttons[slot_index].icon = _get_icon_texture("weapon")
		loadout_buttons[slot_index].text = "Gun %d: %s" % [slot_index + 1, "Empty" if weapon_id.is_empty() else weapon_labels.get(weapon_id, weapon_id)]
	for upgrade_def in upgrade_catalog:
		var id := String(upgrade_def["id"])
		var button: Button = upgrade_buttons[id]
		var level := _get_upgrade_level(id)
		var cost := _get_upgrade_cost(upgrade_def)
		button.icon = _get_icon_texture(String(upgrade_def.get("icon", "ore")))
		button.text = "%s  Lv %d/%d  $%d\n%s%s" % [String(upgrade_def["label"]), level, int(upgrade_def["max_level"]), cost, String(upgrade_def["summary"]), _get_requirement_text(upgrade_def)]
		button.disabled = level >= int(upgrade_def["max_level"]) or int(persistent_data.get("wallet", 0)) < cost or not _meets_requirements(upgrade_def)

func _on_reset_pressed() -> void:
	_emit_click()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	persistent_data = {
		"wallet": 0,
		"best_depth": 0.0,
		"upgrades": {},
		"boss_unlocks": {},
		"checkpoint_owned": {},
		"selected_checkpoint": 0,
		"equipped": ["pistol", ""],
		"last_run_summary": "Mining progress reset."
	}
	_save_progress()
	_refresh_ui()

func _on_checkpoint_pressed(checkpoint: int) -> void:
	_emit_click()
	var key := str(checkpoint)
	if bool(persistent_data["checkpoint_owned"].get(key, false)):
		persistent_data["selected_checkpoint"] = checkpoint
		_save_and_refresh()
		return
	if not bool(persistent_data["boss_unlocks"].get(key, false)):
		return
	var cost := _get_checkpoint_cost(checkpoint)
	if int(persistent_data.get("wallet", 0)) < cost:
		return
	persistent_data["wallet"] = int(persistent_data.get("wallet", 0)) - cost
	persistent_data["checkpoint_owned"][key] = true
	persistent_data["selected_checkpoint"] = checkpoint
	_save_and_refresh()

func _on_loadout_pressed(slot_index: int) -> void:
	_emit_click()
	var unlocked := _get_unlocked_weapons()
	unlocked.append("")
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	var current := String(equipped[slot_index])
	var current_index := unlocked.find(current)
	current_index = 0 if current_index == -1 else current_index
	for step in range(1, unlocked.size() + 1):
		var next_id := String(unlocked[(current_index + step) % unlocked.size()])
		if next_id == "" and slot_index == 0:
			continue
		if next_id != "" and slot_index == 1 and next_id == String(equipped[0]):
			continue
		equipped[slot_index] = next_id
		break
	persistent_data["equipped"] = equipped
	_save_and_refresh()

func _on_upgrade_pressed(upgrade_id: String) -> void:
	_emit_click()
	var upgrade_def := _get_upgrade_def(upgrade_id)
	if upgrade_def.is_empty() or not _meets_requirements(upgrade_def):
		return
	var level := _get_upgrade_level(upgrade_id)
	if level >= int(upgrade_def["max_level"]):
		return
	var cost := _get_upgrade_cost(upgrade_def)
	if int(persistent_data.get("wallet", 0)) < cost:
		return
	persistent_data["wallet"] = int(persistent_data.get("wallet", 0)) - cost
	persistent_data["upgrades"][upgrade_id] = level + 1
	if upgrade_id == "shotgun_unlock":
		_try_auto_equip("shotgun")
	elif upgrade_id == "rifle_unlock":
		_try_auto_equip("rifle")
	elif upgrade_id == "railgun_unlock":
		_try_auto_equip("railgun")
	_save_and_refresh()

func _save_and_refresh() -> void:
	_save_progress()
	_refresh_ui()

func _get_upgrade_def(upgrade_id: String) -> Dictionary:
	for upgrade_def in upgrade_catalog:
		if String(upgrade_def["id"]) == upgrade_id:
			return upgrade_def
	return {}

func _get_upgrade_level(upgrade_id: String) -> int:
	return int(persistent_data["upgrades"].get(upgrade_id, 0))

func _get_upgrade_cost(upgrade_def: Dictionary) -> int:
	var level := _get_upgrade_level(String(upgrade_def["id"]))
	return int(round(float(upgrade_def["base_cost"]) * pow(float(upgrade_def.get("cost_mult", 1.45)), level)))

func _meets_requirements(upgrade_def: Dictionary) -> bool:
	var reqs: Dictionary = upgrade_def.get("requires", {})
	for req_id in reqs.keys():
		if _get_upgrade_level(String(req_id)) < int(reqs[req_id]):
			return false
	return true

func _get_requirement_text(upgrade_def: Dictionary) -> String:
	if _meets_requirements(upgrade_def):
		return ""
	var parts := PackedStringArray()
	var reqs: Dictionary = upgrade_def.get("requires", {})
	for req_id in reqs.keys():
		parts.append(" needs %s %d" % [String(_get_upgrade_def(String(req_id)).get("label", req_id)), int(reqs[req_id])])
	return "\n" + ", ".join(parts)

func _get_unlocked_weapons() -> Array[String]:
	var weapons: Array[String] = ["pistol"]
	if _get_upgrade_level("shotgun_unlock") > 0:
		weapons.append("shotgun")
	if _get_upgrade_level("rifle_unlock") > 0:
		weapons.append("rifle")
	if _get_upgrade_level("railgun_unlock") > 0:
		weapons.append("railgun")
	return weapons

func _try_auto_equip(weapon_id: String) -> void:
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	if String(equipped[1]).is_empty():
		equipped[1] = weapon_id
	persistent_data["equipped"] = equipped

func _get_checkpoint_cost(checkpoint: int) -> int:
	var tier: int = max(1, int(checkpoint / BOSS_INTERVAL_METERS))
	return int(round(90.0 + 68.0 * pow(float(tier), 1.35)))

func _emit_click() -> void:
	play_ui_click.emit()

func _get_icon_texture(icon_id: String) -> Texture2D:
	if icon_cache.has(icon_id):
		return icon_cache[icon_id]
	var image := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color := Color(0.86, 0.69, 0.33, 1.0)
	match icon_id:
		"drill":
			_draw_rect(image, Rect2i(4, 10, 12, 8), color)
			_draw_rect(image, Rect2i(16, 12, 8, 4), color)
		"oxygen":
			_draw_rect(image, Rect2i(8, 4, 12, 18), color)
			_draw_rect(image, Rect2i(10, 2, 8, 4), color)
		"shield":
			for y in range(4, 22):
				var width: int = int(10 - abs(13 - y) / 2)
				for x in range(14 - width, 14 + width):
					image.set_pixel(x, y, color)
		"scanner":
			_draw_rect(image, Rect2i(5, 5, 14, 14), color)
			_draw_rect(image, Rect2i(17, 17, 6, 6), color)
		"speed":
			for i in range(4):
				_draw_rect(image, Rect2i(4 + i * 4, 6 + i * 4, 12, 2), color)
		"weapon":
			_draw_rect(image, Rect2i(4, 12, 18, 4), color)
			_draw_rect(image, Rect2i(18, 9, 6, 2), color)
		"checkpoint":
			_draw_rect(image, Rect2i(12, 4, 4, 16), color)
			_draw_rect(image, Rect2i(8, 20, 12, 4), color)
		_:
			_draw_rect(image, Rect2i(6, 6, 16, 16), color)
	var texture := ImageTexture.create_from_image(image)
	icon_cache[icon_id] = texture
	return texture

func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			image.set_pixel(x, y, color)

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	persistent_data = persistent_data.merged(parsed, true)

func _save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(persistent_data, "\t"))
