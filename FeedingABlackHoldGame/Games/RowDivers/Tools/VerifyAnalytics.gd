extends SceneTree
const Analytics = preload("res://Games/RowDivers/RowDiversAnalytics.gd")
var checks = {}

class Capture extends Node:
	var events: Array = []
	func track_design_event(id, value = null, fields = {}):
		events.append({"id": id, "value": value, "fields": fields.duplicate(true)})

func _initialize(): call_deferred("run")

func run():
	var state = {"runs": 0, "prestige": 0}
	Analytics.started(state, false, "rebalanced")
	checks.no_sink_keeps_retry_possible = not state.has("analytics_milestones")
	var capture = Capture.new()
	capture.name = "GameAnalytics"
	root.add_child(capture)
	Analytics.started(state, false, "rebalanced")
	Analytics.started(state, false, "rebalanced")
	checks.start_once = capture.events.size() == 1 and capture.events[0].id == "railway_fury:started"
	Analytics.finished_run(state, false, false, "rebalanced")
	checks.zero_runs_not_completed = capture.events.size() == 1
	state.runs = 1
	Analytics.finished_run(state, false, false, "rebalanced")
	checks.death_counts_as_run = capture.events.size() == 2 and capture.events[1].id == "railway_fury:runs_completed_1" and not capture.events[1].fields.won
	state.runs = 4
	Analytics.finished_run(state, false, false, "rebalanced")
	checks.five_not_early = capture.events.size() == 2
	state.runs = 5
	Analytics.finished_run(state, true, false, "rebalanced")
	checks.five_and_prestige = capture.events.size() == 4 and capture.events[2].id == "railway_fury:runs_completed_5" and capture.events[3].id == "railway_fury:prestige_0_defeated"
	for p in range(1, 4):
		state.prestige = p
		Analytics.finished_run(state, false, false, "rebalanced")
		checks["no_prestige_on_loss_%d" % p] = capture.events.size() == 3 + p
		Analytics.finished_run(state, true, false, "rebalanced")
		Analytics.finished_run(state, true, false, "rebalanced")
		checks["prestige_once_%d" % p] = capture.events.size() == 4 + p and capture.events.back().id == "railway_fury:prestige_%d_defeated" % p
	Analytics.ending(state, false, "rebalanced")
	checks.no_ending_before_choice = capture.events.size() == 7
	state.ending = "LastStation"
	Analytics.ending(state, false, "rebalanced")
	checks.ending_choice = capture.events.size() == 8 and capture.events.back().fields.ending == "LastStation"
	state = JSON.parse_string(JSON.stringify(state))
	Analytics.started(state, false, "rebalanced")
	Analytics.finished_run(state, true, false, "rebalanced")
	state.ending = "BeyondTheRails"
	Analytics.ending(state, false, "rebalanced")
	checks.reload_and_reentry_deduplicated = capture.events.size() == 8
	var flying = {"runs": 0, "prestige": 0}
	Analytics.started(flying, true, "previous")
	checks.flying_independent = capture.events.size() == 9 and capture.events.back().fields.mode == "free_aim" and capture.events.back().fields.upgrade_tree == "flying"
	var previous = {"runs": 8, "prestige": 2, "ending": "BeyondTheRails"}
	Analytics.started(previous, false, "previous")
	Analytics.finished_run(previous, false, false, "previous")
	checks.older_save_counts_caught_up = capture.events.size() == 12 and capture.events.back().fields.runs_completed == 8 and capture.events.back().fields.upgrade_tree == "previous"
	Analytics.ending(previous, false, "previous")
	checks.beyond_ending = capture.events.size() == 13 and capture.events.back().fields.ending == "BeyondTheRails"
	for choice in ["LastStation","BeyondTheRails"]:
		var new_ending = {"ending":choice,"runs":40,"prestige":3}
		Analytics.ending(new_ending,true,"rebalanced")
		checks["new_ending_"+choice] = capture.events.back().id=="railway_fury:ending" and capture.events.back().fields.ending==choice
	var event_count = capture.events.size()
	for obsolete in ["BenevolentGod", "EvilGod"]:
		Analytics.ending({"ending":obsolete},false,"rebalanced")
	checks.old_endings_rejected = capture.events.size()==event_count
	var passed = checks.values().all(func(value): return value)
	print("RAILWAY ANALYTICS: ", checks.size(), " checks, passed=", passed, " ", checks)
	quit(0 if passed else 1)
