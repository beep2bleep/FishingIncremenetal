extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	var original = root.get_node("GameAnalytics")
	# The launcher configuration defers production analytics. Never send test events.
	if original._enabled:
		push_error("Run this check with global/HighLevelMode=all so production analytics stays deferred.")
		quit(1)
		return
	original.name = "ProductionGameAnalytics"
	var capture = load("res://Games/RowDivers/Tools/AnalyticsCapture.gd").new()
	capture.name = "GameAnalytics"
	root.add_child(capture)
	root.get_node("Util").set_active_game_id("rowdivers")
	checks.session_identity = capture._get_active_credentials().game_id == "rowdivers"
	checks.state_identity = capture._get_state_path() == "user://gameanalytics_state_rowdivers.cfg"
	capture._enabled = true
	capture._send_active_game_progression_start_event()
	checks.session_progression = capture.events.size() == 1 and capture.events[0].event_id == "Start:rowdivers:game"
	capture.events.clear()
	for flying in [false, true]:
		Progress.free_aim_mode = flying
		var data = Progress.fresh()
		data.controls_seen = true
		Progress.active_data_cache = data
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_process(false)
		battle.set_physics_process(false)
		battle._finish(false)
		checks["preview_battle_suppressed_" + str(flying)] = capture.events.is_empty() and not data.has("analytics_milestones")
		battle.free()
		data.unlocks.GodTab = true
		data.god_panel_unlocked = true
		var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.gd").new()
		ending.persist_results = false
		root.add_child(ending)
		ending._choose("LastStation")
		checks["preview_ending_suppressed_" + str(flying)] = capture.events.is_empty() and not data.has("analytics_milestones")
		ending.free()
	var live_state = {"runs": 5, "prestige": 3, "ending": "BeyondTheRails"}
	var analytics = load("res://Games/RowDivers/RowDiversAnalytics.gd")
	analytics.started(live_state, true, "rebalanced")
	analytics.finished_run(live_state, true, true, "rebalanced")
	analytics.ending(live_state, true, "rebalanced")
	checks.real_payloads = capture.events.size() == 5 and capture.events.all(func(e): return e.category == "design" and e.custom_fields.mode == "free_aim" and e.custom_fields.active_game == "rowdivers")
	var passed = checks.values().all(func(value): return value)
	print("RAILWAY ANALYTICS INTEGRATION: ",checks.size()," checks, passed=",passed," ",checks)
	quit(0 if passed else 1)
