extends RefCounted
const MILESTONES = ["boss_0","boss_1","boss_2","boss_3","ending"]
const TITLES = ["LEVEL 1 CLEARED","LEVEL 2 CLEARED","LEVEL 3 CLEARED","LEVEL 4 CLEARED","ENDING REACHED"]

static func ensure(data: Dictionary) -> void:
	if data.has("gameplay_seconds"): return
	data.gameplay_seconds = 0.0
	# Never fabricate the missing first part of an existing campaign's clock.
	data.timing_complete = int(data.get("runs",0))==0 and data.get("levels",{}).is_empty() and int(data.get("max_prestige",0))==0
	data.timed_milestones = {}
	data.leaderboards_assisted = false

static func eligible(data: Dictionary) -> bool:
	return data.get("timing_complete",false) and not data.get("leaderboards_assisted",false)

static func format_time(seconds: float) -> String:
	var total = maxi(0,int(seconds))
	return "%02d:%02d:%02d" % [total/3600,(total/60)%60,total%60]

static func profile() -> String:
	var progress = load("res://Games/RowDivers/RowDiversProgress.gd")
	return ("demo_" if progress.Demo.enabled() else "") + ("free_aim" if progress.free_aim_mode else "classic_"+progress.active_tree)

static func board_id(milestone: String) -> String:
	return "railway_fury_"+profile()+"_"+milestone+"_time"

static func configs() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(MILESTONES.size()):
		if load("res://Games/RowDivers/RowDiversDemo.gd").enabled() and i > 0: continue
		var id = board_id(MILESTONES[i])
		result.append({"id":id,"steam_name":id,"title":TITLES[i],"milestone":MILESTONES[i],"score_unit":"milliseconds"})
	return result

static func record(data: Dictionary, milestone: String, submit = true, sink: Node = null) -> void:
	ensure(data)
	if not MILESTONES.has(milestone): return
	var times: Dictionary = data.get("timed_milestones",{})
	if times.has(milestone): return
	var seconds = float(data.gameplay_seconds)
	times[milestone] = seconds
	data.timed_milestones = times
	if submit: submit_pending(data,sink)

static func submit_pending(data: Dictionary, sink: Node = null) -> void:
	if not eligible(data): return
	if sink==null:
		var tree = Engine.get_main_loop()
		if tree is SceneTree: sink = tree.root.get_node_or_null("SteamHandler")
	if sink==null or not sink.has_method("submit_row_divers_time"): return
	# Retry persisted snapshots on the next live dive/ending if Steam was offline.
	for milestone in data.get("timed_milestones",{}):
		sink.call("submit_row_divers_time",board_id(milestone),float(data.timed_milestones[milestone]))
