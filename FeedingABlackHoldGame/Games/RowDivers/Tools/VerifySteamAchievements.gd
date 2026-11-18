extends SceneTree
const Mirror = preload("res://Games/RowDivers/RowDiversSteamAchievements.gd")
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks := 0

class FakeSteam extends RefCounted:
	signal user_stats_stored(game_id: int, result: int)
	var unlocked: Dictionary = {}
	var attempts: Array = []
	var accept := true
	var store_accept := true
	var stores := 0
	func getAchievement(key): return {"ret": true, "achieved": unlocked.get(key, false)}
	func setAchievement(key):
		attempts.append(key)
		if accept: unlocked[key] = true
		return accept
	func storeStats():
		stores += 1
		return store_accept

func check(value: bool, message: String):
	checks += 1
	if not value:
		push_error(message)
		quit(1)
		assert(value, message)

func _initialize(): call_deferred("run")

func run():
	root.get_node("SteamHandler").steam_enabled = false
	var mirror = Mirror.new()
	var api = FakeSteam.new()
	var data = {"achievements": {"FirstDive": true, "FirstBoss": false, "unknown": true}, "claimed": {"FirstBoss": true}}
	var before = data.duplicate(true)
	mirror.sync(data, api)
	check(api.attempts == ["FirstDive"] and api.stores == 1, "Only earned catalog achievements unlock")
	check(data == before, "Steam sync never changes progress or grants rewards")
	mirror.sync(data, api)
	check(api.attempts.size() == 1 and api.stores == 1, "Repeated sync is idempotent")
	data.achievements.FirstMiniBoss = true
	api.accept = false
	mirror.sync(data, api)
	api.accept = true
	api.store_accept = false
	mirror.sync(data, api)
	check(mirror.pending_store, "Rejected store remains pending")
	api.store_accept = true
	mirror.sync(data, api)
	check(not mirror.pending_store and api.attempts.count("FirstMiniBoss") == 2, "Failed unlock and store both retry")
	api.user_stats_stored.emit(5520300, 2)
	check(mirror.confirmed.is_empty() and mirror.pending_store, "Asynchronous storage failures retry")
	for key in Progress.design().enums.AchievementType.values(): data.achievements[key] = true
	mirror.sync(data, api)
	check(api.unlocked.size() == 18, "All eighteen achievements backfill from existing saves")
	var imported = {"achievements": {}, "claimed": {"FirstBoss": true}, "wallet": [12,3,0]}
	check(mirror.sync(imported, api), "Steam earned flags import to shared progress")
	check(imported.achievements.size()==18, "Every earned Steam flag restores")
	check(imported.wallet==[12,3,0] and imported.claimed=={"FirstBoss":true}, "Import never grants or reclaims rewards")
	check(not mirror.sync(imported,api), "Remote flag import is idempotent")
	mirror.free()
	print("STEAM ACHIEVEMENTS: %d checks passed" % checks)
	quit()
