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
		var prestige = int(data.get("prestige", 0))
		if prestige >= 0 and prestige <= 3:
			_once(data, "prestige_%d_defeated" % prestige, flying, tree, {}, prestige)

static func ending(data: Dictionary, flying: bool, tree: String) -> void:
	var choice = str(data.get("ending", ""))
	if preload("res://Games/RowDivers/RowDiversEndings.gd").CHOICES.has(choice):
		_once(data, "ending", flying, tree, {"ending": choice})

static func _once(data: Dictionary, milestone: String, flying: bool, tree: String, extra: Dictionary = {}, value: Variant = null) -> void:
	var sent: Dictionary = data.get("analytics_milestones", {})
	if sent.get(milestone, false): return
	var loop = Engine.get_main_loop()
	var manager = loop.root.get_node_or_null("GameAnalytics") if loop is SceneTree else null
	if manager == null or not manager.has_method("track_design_event"): return
	var fields = {
		"mode": "free_aim" if flying else "classic",
		"upgrade_tree": "flying" if flying else tree,
		"prestige": int(data.get("prestige", 0)),
		"runs_completed": int(data.get("runs", 0)),
		"demo": preload("res://Games/RowDivers/RowDiversDemo.gd").enabled(),
	}
	fields.merge(extra, true)
	manager.call("track_design_event", "railway_fury:" + milestone, value, fields)
	sent[milestone] = true
	data["analytics_milestones"] = sent
