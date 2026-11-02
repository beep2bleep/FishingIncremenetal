extends SceneTree
## Read-only campaign results; run the actual ending UI with persistence disabled.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var folder = "res://Games/RowDivers/Simulation/CurrentPlaythrough20261027"

func _initialize(): call_deferred("run")

func run():
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	ProjectSettings.set_setting("railway_fury/demo/enabled",false)
	Progress.free_aim_mode = true
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	var cases = []
	var passed = true
	for filename in ["campaign.json","campaign_2401027.json","campaign_2401028.json"]:
		var trace = JSON.parse_string(FileAccess.get_file_as_string(folder.path_join(filename)))
		if not trace.get("completed",false):
			push_error("Campaign is not complete: "+filename)
			quit(1)
			return
		for choice in ["LastStation","BeyondTheRails"]:
			Progress.active_data_cache = trace.final_state.duplicate(true)
			var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
			ending.persist_results = false
			root.add_child(ending)
			ending._choose(choice)
			var state = Progress.active_data_cache
			var ok = ending.choice_made and ending.continue_button.visible and state.ending==choice and ending.illustration.texture!=null
			ok = ok and state.wallet==trace.final_state.wallet
			cases.append({"seed":trace.config.seed,"choice":choice,"passed":ok,"final_state":state.duplicate(true)})
			passed = passed and ok
			ending.free()
		await process_frame
	var output = FileAccess.open(folder.path_join("ending_validation.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify({"passed":passed,"cases":cases,"persistence":false},"\t"))
	output.close()
	print("CAMPAIGN ENDINGS: ",cases.size()," cases; passed=",passed)
	quit(0 if passed else 1)
