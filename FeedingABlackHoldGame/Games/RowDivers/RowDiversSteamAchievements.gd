extends Node
## Mirror earned flags, never reward claims or simulated campaign results.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Demo = preload("res://Games/RowDivers/RowDiversDemo.gd")
var elapsed := 0.0
var confirmed: Dictionary = {}
var pending_store := false
var connected_api: Object

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	elapsed -= delta
	if elapsed > 0.0: return
	elapsed = 5.0
	var handler = get_parent()
	if not handler.steam_enabled or handler.app_id != 5520300 or Demo.enabled(): return
	# Only exported Steam builds touch the player's real achievement account.
	if not OS.has_feature("railway_steam") or OS.has_feature("editor"): return
	var data = Progress.load_data()
	if sync(data, handler.steam_api): Progress.save_data(data)

func sync(data: Dictionary, api: Object) -> bool:
	if api == null: return false
	var imported := false
	if connected_api != api:
		connected_api = api
		if api.has_signal("user_stats_stored"):
			api.connect("user_stats_stored", _on_stats_stored)
	for entry in Progress.design().settings.achievements:
		var key: String = Progress.design().enums.AchievementType[str(int(entry.achievementType))]
		var remote = api.call("getAchievement", key)
		if remote is Dictionary and remote.get("ret", false) and remote.get("achieved", false):
			if not data.achievements.get(key, false):
				data.achievements[key] = true
				imported = true
			confirmed[key] = true
		elif data.get("achievements", {}).get(key, false) and not confirmed.has(key) and api.call("setAchievement", key):
			confirmed[key] = true
			pending_store = true
	# Retry rejected stores. Steam handles offline delivery after accepting a store.
	if pending_store and api.call("storeStats"):
		pending_store = false
	return imported

func _on_stats_stored(game_id: int, result: int) -> void:
	if game_id != 5520300 or result == 1: return
	# A failed asynchronous commit must be retried even if setAchievement worked.
	confirmed.clear()
	pending_store = true
