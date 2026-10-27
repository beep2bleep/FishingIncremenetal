extends Node
## Editor-only isolated forecasts. The live wallet is changed only after confirmation
## that the save still matches the initial snapshot. Cancel leaves it untouched.
signal progress(count: int, last_name: String)
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var process_id = -1
var cancelled = false
var busy = false
var persist_results = true
var max_purchases = 400

func cancel() -> void:
	cancelled = true
	if process_id>0 and OS.is_process_running(process_id): OS.kill(process_id)

func _exit_tree() -> void: cancel()

func buy_available() -> Dictionary:
	if not OS.has_feature("editor") or busy: return {"error":"Editor only, or already buying."}
	busy = true
	cancelled = false
	var initial = Progress.load_data().duplicate(true)
	var initial_profile = Progress.progress_path()
	var folder = "user://railway_editor_autobuy/session_%d" % Time.get_ticks_usec()
	var base = folder.path_join("Games/RowDivers")
	DirAccess.make_dir_recursive_absolute(base.path_join("Simulation"))
	DirAccess.make_dir_recursive_absolute(base.path_join("Data"))
	var files = ["RowDiversProgress.gd","RowDiversDemo.gd","RowDiversTiming.gd","RowDiversFireWaves.gd","Simulation/RunBalanceCampaign.gd","Simulation/GeneratedCombatModel.gd","Simulation/GeneratedFreeAimModel.gd","Simulation/FlightPilot.gd","Data/row_divers.json","Data/row_divers_free_aim.json"]
	for relative in files:
		var source = FileAccess.get_file_as_string("res://Games/RowDivers/"+relative)
		_write(base.path_join(relative),source)
	if not Progress.free_aim_mode and Progress.active_tree=="previous":
		_write(base.path_join("Data/row_divers.json"),FileAccess.get_file_as_string(Progress.PREVIOUS_DATA_PATH))
	_write(folder.path_join("project.godot"),'config_version=5\n[application]\nconfig/name="Railway editor forecasts"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n[railway_fury]\ndemo/enabled=%s\n' % ("true" if Progress.Demo.enabled() else "false"))
	_write(folder.path_join("input.json"),JSON.stringify(initial))
	var output = ProjectSettings.globalize_path(folder.path_join("result.json"))
	var config = {"mode":"shop","free_aim":Progress.free_aim_mode,"seed":2401026,"input":ProjectSettings.globalize_path(folder.path_join("input.json")),"output":output,"shortlist":2 if Progress.free_aim_mode else 4,"weights":{"distance":.60,"gold_rate":.28,"gem_rate":.12},"purchase_buffer":true,"shop_max_purchases":max_purchases}
	config.runner_sha256 = FileAccess.get_sha256(base.path_join("Simulation/RunBalanceCampaign.gd"))
	config.upgrade_tree = "flying" if Progress.free_aim_mode else Progress.active_tree
	config.catalog_sha256 = FileAccess.get_sha256(base.path_join("Data/row_divers_free_aim.json" if Progress.free_aim_mode else "Data/row_divers.json"))
	_write(folder.path_join("config.json"),JSON.stringify(config))
	process_id = OS.create_process(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path(folder),"--script","res://Games/RowDivers/Simulation/RunBalanceCampaign.gd","--",ProjectSettings.globalize_path(folder.path_join("config.json"))]),false)
	if process_id<0:
		busy = false
		return {"error":"Could not launch the forecast process."}
	var reported = -1
	var result: Dictionary = {}
	var last_progress = Time.get_ticks_msec()
	while OS.is_process_running(process_id) and not cancelled:
		if FileAccess.file_exists(output):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(output))
			if parsed is Dictionary:
				result = parsed
				if result.choices.size()!=reported:
					last_progress = Time.get_ticks_msec()
					reported = result.choices.size()
					progress.emit(reported,str(result.choices.back().name) if reported>0 else "")
		if Time.get_ticks_msec()-last_progress>180000:
			cancel()
			busy = false
			return {"error":"Forecast timed out. Wallet unchanged."}
		await get_tree().create_timer(.15).timeout
	process_id = -1
	busy = false
	if cancelled: return {"cancelled":true}
	if FileAccess.file_exists(output):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(output))
		if parsed is Dictionary: result = parsed
	if not result.get("shop_complete",false): return {"error":"Forecast did not finish. Wallet unchanged."}
	if Progress.progress_path() != initial_profile: return {"error":"Campaign profile changed during forecast. Wallet unchanged."}
	if JSON.stringify(Progress.load_data()) != JSON.stringify(initial): return {"error":"Save changed during forecast. Wallet unchanged."}
	result.final_state.leaderboards_assisted = true
	Progress.active_data_cache = result.final_state
	if persist_results: Progress.save_data(result.final_state)
	return {"count":result.choices.size(),"claims":result.claims.size(),"record":output}

func _write(path: String, content: String) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(content)
	file.close()
