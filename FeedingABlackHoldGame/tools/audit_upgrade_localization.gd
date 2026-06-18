extends Node

const MINING_UPGRADE_TREE_ADAPTER := preload("res://Games/Mining/MiningUpgradeTreeAdapter.gd")
const OPEN_PIT_UPGRADE_TREE_ADAPTER := preload("res://Games/OpenPitEmpire/OpenPitEmpireUpgradeTreeAdapter.gd")
const RED_SKY_UPGRADE_TREE_ADAPTER := preload("res://Games/RedSkyDefense/RedSkyUpgradeTreeAdapter.gd")
const TURKEY_UPGRADE_TREE_ADAPTER := preload("res://Games/Turkey/TurkeyUpgradeTreeAdapter.gd")
const REEL_UPGRADE_TREE_ADAPTER := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessUpgradeTreeAdapter.gd")

const LOCALES := [
	"en",
	"ar",
	"ca",
	"cs",
	"de",
	"es",
	"fr",
	"he",
	"id",
	"it",
	"ja",
	"ko",
	"pl",
	"pt",
	"ru",
	"th",
	"tr",
	"vi",
	"zh",
]

const GAME_IDS := [
	"vanguard",
	"mining",
	"openpit",
	"redsky",
	"turkey",
	"reelintodarkness",
]

var _english_by_game: Dictionary = {}
var _issues: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	TranslationServer.set_locale("en")
	for game_id in GAME_IDS:
		_english_by_game[game_id] = _collect_game_strings(game_id)

	for locale in LOCALES:
		TranslationServer.set_locale(locale)
		for game_id in GAME_IDS:
			var rows: Dictionary = _collect_game_strings(game_id)
			_audit_rows(locale, game_id, rows)

	if _issues.is_empty():
		print("UPGRADE_LOCALIZATION_AUDIT_OK locales=%d games=%d" % [LOCALES.size(), GAME_IDS.size()])
		get_tree().quit(0)
		return

	for issue in _issues:
		push_error(issue)
	print("UPGRADE_LOCALIZATION_AUDIT_FAILED issues=%d" % _issues.size())
	get_tree().quit(1)

func _collect_game_strings(game_id: String) -> Dictionary:
	ProjectSettings.set_setting("global/ActiveGame", game_id)
	ProjectSettings.set_setting("global/HighLevelMode", game_id)
	var global_node: Node = get_tree().root.get_node("/root/Global")
	global_node.game_mode_data_manager.upgrades = {}
	global_node.game_mode_data_manager.unlocked_upgrades = {}

	match game_id:
		"mining":
			MINING_UPGRADE_TREE_ADAPTER.apply_simulation_upgrades()
		"openpit":
			OPEN_PIT_UPGRADE_TREE_ADAPTER.apply_simulation_upgrades()
		"redsky":
			RED_SKY_UPGRADE_TREE_ADAPTER.apply_simulation_upgrades()
		"turkey":
			TURKEY_UPGRADE_TREE_ADAPTER.apply_simulation_upgrades()
		"reelintodarkness":
			REEL_UPGRADE_TREE_ADAPTER.apply_simulation_upgrades()
		_:
			FishingUpgradeTreeAdapter.apply_simulation_upgrades()

	var rows: Dictionary = {}
	for upgrade_variant: Variant in global_node.game_mode_data_manager.upgrades.values():
		if not (upgrade_variant is Upgrade):
			continue
		var upgrade: Upgrade = upgrade_variant
		var sim_key := str(upgrade.sim_key)
		if sim_key.is_empty():
			sim_key = str(upgrade.id)
		rows[sim_key] = {
			"name": upgrade.sim_name.strip_edges(),
			"description": upgrade.sim_description.strip_edges(),
		}
	return rows

func _audit_rows(locale: String, game_id: String, rows: Dictionary) -> void:
	var english_rows: Dictionary = _english_by_game.get(game_id, {})
	for sim_key: String in rows.keys():
		var row: Dictionary = rows[sim_key]
		var english_row: Dictionary = english_rows.get(sim_key, {})
		_check_text(locale, game_id, sim_key, "name", str(row.get("name", "")), str(english_row.get("name", "")))
		_check_text(locale, game_id, sim_key, "description", str(row.get("description", "")), str(english_row.get("description", "")))

func _check_text(locale: String, game_id: String, sim_key: String, field: String, text: String, english_text: String) -> void:
	if text.is_empty():
		_issues.append("%s/%s/%s %s is blank" % [locale, game_id, sim_key, field])
		return
	if _looks_like_raw_translation_key(text):
		_issues.append("%s/%s/%s %s leaked key: %s" % [locale, game_id, sim_key, field, text])
	if locale == "en":
		return
	if field != "name" and text == english_text and _should_be_translated(text):
		_issues.append("%s/%s/%s %s still English: %s" % [locale, game_id, sim_key, field, text])

func _looks_like_raw_translation_key(text: String) -> bool:
	var lines := text.split("\n", false)
	for line in lines:
		var stripped := line.strip_edges()
		if stripped.begins_with("UPGRADE_") \
				or stripped.begins_with("MINING_") \
				or stripped.begins_with("OPEN_PIT_") \
				or stripped.begins_with("RED_SKY_") \
				or stripped.begins_with("TURKEY_") \
				or stripped.begins_with("REEL_") \
				or stripped.begins_with("MULTI_MODE_") \
				or stripped.begins_with("CROSS_"):
			return true
	return false

func _should_be_translated(text: String) -> bool:
	var stripped := text.strip_edges()
	if stripped.length() <= 2:
		return false
	if stripped.find("%") != -1 or stripped.find("{") != -1:
		return false
	if stripped.is_valid_int() or stripped.is_valid_float():
		return false
	return stripped.find(" ") != -1 or stripped.find(".") != -1
