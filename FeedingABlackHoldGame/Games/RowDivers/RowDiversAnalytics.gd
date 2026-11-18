extends RefCounted
## Persistent funnel milestones. Call only from live, persistence-enabled scenes.

static func started(data: Dictionary, flying: bool, tree: String) -> void:
	_once(data, "started", flying, tree)

static func finished_run(data: Dictionary, won: bool, flying: bool, tree: String) -> void:
	var count = int(data.get("runs", 0))
	for milestone in [1, 5]:
		if count >= milestone:
			_once(data, "runs_completed_%d" % milestone, flying, tree, {"won": won}, milestone)
	if won:
		var prestige = preload("res://Games/RowDivers/RowDiversDemo.gd").playable_level(data)
		if prestige >= 0 and prestige <= 3:
			_once(data, "prestige_%d_defeated" % prestige, flying, tree, {}, prestige)

static func ending(data: Dictionary, flying: bool, tree: String) -> void:
	var choice = str(data.get("ending", ""))
	if preload("res://Games/RowDivers/RowDiversEndings.gd").CHOICES.has(choice):
		_once(data, "ending", flying, tree, {"ending": choice})

static func _once(data: Dictionary, milestone: String, flying: bool, tree: String, extra: Dictionary = {}, value: Variant = null) -> void:
	var milestone_key = "analytics_milestones_demo" if preload("res://Games/RowDivers/RowDiversDemo.gd").enabled() else "analytics_milestones_full"
	var sent: Dictionary = data.get(milestone_key, {})
	if sent.get(milestone, false): return
	var loop = Engine.get_main_loop()
	var manager = loop.root.get_node_or_null("GameAnalytics") if loop is SceneTree else null
	if manager == null or not manager.has_method("track_design_event"): return
	var fields = {
		"mode": "free_aim" if flying else "classic",
		"upgrade_tree": "flying" if flying else tree,
		"prestige": preload("res://Games/RowDivers/RowDiversDemo.gd").playable_level(data),
		"runs_completed": int(data.get("runs", 0)),
		"demo": preload("res://Games/RowDivers/RowDiversDemo.gd").enabled(),
	}
	fields.merge(extra, true)
	manager.call("track_design_event", "railway_fury:" + milestone, value, fields)
	sent[milestone] = true
	data[milestone_key] = sent

static func run_event(battle: Node, outcome: String) -> void:
	if not battle.persist_results or battle.data.is_empty(): return
	var manager = battle.get_tree().root.get_node_or_null("GameAnalytics")
	if manager == null or not manager.has_method("track_design_event"): return
	var section = clampi(int(battle.section), 1, 15)
	var meters = maxf(float(battle.distance), maxf(0.0, -battle.player_position.z))
	var fields = {
		"analytics_schema": 2, "demo": preload("res://Games/RowDivers/RowDiversDemo.gd").enabled(),
		"level": battle.campaign_level() + 1, "section": section, "distance_m": snappedf(meters, 0.1),
		"run_seconds": snappedf(battle.elapsed, 0.1), "campaign_seconds": snappedf(float(battle.data.get("gameplay_seconds",0)),0.1),
		"attempt": int(battle.analytics_attempt),
		"kills": int(battle.run_kills), "mode": "free_aim" if battle.free_aim_mode else "classic",
		"upgrade_tree": "flying" if battle.free_aim_mode else str(load("res://Games/RowDivers/RowDiversProgress.gd").active_tree),
		"outcome": outcome, "cause": str(battle.last_damage_source) if outcome == "death" else "",
	}
	var event = "railway_fury:section_reached:%02d" % section if outcome == "checkpoint" else "railway_fury:run_" + outcome
	manager.call("track_design_event",event, meters, fields)
	if manager.has_method("track_progression_event") and outcome in ["start","death","complete","abandoned"]:
		manager.call("track_progression_event", "start" if outcome=="start" else "complete" if outcome=="complete" else "fail", "railway_fury", "level_%d" % (battle.campaign_level()+1), "", int(meters), fields, int(fields.attempt))
