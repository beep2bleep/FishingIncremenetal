extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Model = preload("res://Games/RowDivers/Simulation/GeneratedCombatModel.gd")

func _initialize(): call_deferred("run")

func purchase_priority(state, entry):
	if not Progress.can_buy(state, entry): return 10000
	# No flat arrow node depends on a percentage arrow node. Delay those two
	# multipliers until all flat additions to demonstrate the legal damage ceiling.
	if entry.effects.any(func(effect): return effect.stat == "Arrow_Damage" and effect.percentage): return 9000
	if not entry.effects.any(func(effect): return effect.percentage): return 0
	for child_id in entry.children:
		var child = Progress.find_upgrade(str(child_id))
		if not Progress.visible(state, child) and Progress.level(state, entry) < int(child.unlockAtParentLevel): return 10
	return 1000

func execute(state, real_runtime, test_seed):
	seed(test_seed)
	var battle
	if real_runtime:
		Progress.active_data_cache = state.duplicate(true)
		battle = load("res://Games/RowDivers/Simulation/AssistedRuntimeProbe.gd").new()
		battle.persist_results = false
	else:
		battle = Model.new()
		battle.data = state.duplicate(true)
	root.add_child(battle)
	battle.set_process(false)
	battle.set_physics_process(false)
	battle.horizontal_override = 0.0
	battle.suspended = false
	var frames = 0
	while not battle.ended and frames < 108000:
		battle._simulate_step(1.0 / 60.0)
		frames += 1
	var report = {"frames": frames, "won": battle.won_run, "distance": battle.distance, "kills": battle.run_kills, "loot": battle.coins.duplicate(), "health": battle.health, "armor": battle.armor, "damage": battle.damage_sources.duplicate()}
	battle.free()
	return report

func run():
	var settings = root.get_node("SaveHandler")
	settings.row_divers_previous_upgrade_tree = "--previous" in OS.get_cmdline_user_args()
	Progress.tree_selected = false
	Progress.sync_tree_preference()
	Progress.free_aim_mode = false
	var suffix = "_previous" if settings.row_divers_previous_upgrade_tree else ""
	var output_dir = "res://Games/RowDivers/Simulation/Tuning"
	var catalog_path = Progress.PREVIOUS_DATA_PATH if settings.row_divers_previous_upgrade_tree else Progress.DATA_PATH
	var args = OS.get_cmdline_user_args()
	if "--catalog" in args:
		catalog_path = args[args.find("--catalog") + 1]
		Progress.catalog = JSON.parse_string(FileAccess.get_file_as_string(catalog_path))
	if "--output-dir" in args:
		output_dir = args[args.find("--output-dir") + 1]
	settings.row_divers_original_graphics = true
	settings.row_divers_illustrated_graphics = false
	root.get_node("Util").set_active_game_id("rowdivers")
	var fixture = Progress.fresh()
	fixture.controls_seen = true
	var cases = []
	var failures = 0
	var loadouts = [fixture]
	var maxed = Progress.fresh()
	maxed.wallet = [1e30, 1e30, 1e30]
	maxed.controls_seen = true
	for purchase in range(400):
		var bought = false
		for entry in Progress.design().upgrades:
			if Progress.buy(maxed, entry):
				bought = true
				break
		if not bought: break
	Progress.apply_reference_repairs(maxed)
	var exported = maxed.duplicate(true)
	exported.prestige = 3
	var export_file = FileAccess.open(output_dir.path_join("maxed_loadout" + suffix + ".json"), FileAccess.WRITE)
	export_file.store_string(JSON.stringify(exported, "\t"))
	export_file.close()
	for prestige in range(4):
		var state = maxed.duplicate(true)
		state.prestige = prestige
		loadouts.append(state)
	var flat_first = Progress.fresh()
	flat_first.wallet = [1e30, 1e30, 1e30]
	flat_first.controls_seen = true
	var ordered = Progress.design().upgrades.duplicate()
	for purchase in range(400):
		ordered.sort_custom(func(a,b): return purchase_priority(flat_first,a) < purchase_priority(flat_first,b))
		if not Progress.buy(flat_first,ordered[0]): break
	flat_first.prestige = 3
	loadouts.append(flat_first)
	var achievable = Progress.stat(flat_first,"Arrow_Damage") >= 60000000 and flat_first.achievements.get("BowMaster",false)
	var achievement_file = FileAccess.open(output_dir.path_join("achievement_validation" + suffix + ".json"),FileAccess.WRITE)
	achievement_file.store_string(JSON.stringify({"passed":achievable,"arrow_damage":Progress.stat(flat_first,"Arrow_Damage"),"all_nodes_maxed":ordered.all(func(entry): return Progress.level(flat_first,entry)==int(entry.maxLevel))},"\t"))
	achievement_file.close()
	var ideal_file = FileAccess.open(output_dir.path_join("maxed_flat_first_loadout" + suffix + ".json"),FileAccess.WRITE)
	ideal_file.store_string(JSON.stringify(flat_first,"\t"))
	ideal_file.close()
	if not achievable: failures += 1
	for i in range(loadouts.size()):
		var runtime = execute(loadouts[i], true, 73119 + i)
		var model = execute(loadouts[i], false, 73119 + i)
		var passed = runtime == model
		if not passed: failures += 1
		cases.append({"case": i, "prestige": loadouts[i].prestige, "passed": passed, "runtime": runtime, "model": model})
		print("MODEL PARITY ", i, " ", passed, " runtime=", runtime, " model=", model)
		await process_frame
	var path = output_dir.path_join("runtime_validation" + suffix + ".json")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"failures": failures, "cases": cases, "tree": Progress.active_tree, "catalog_path": catalog_path, "catalog_sha256": FileAccess.get_sha256(catalog_path)}, "\t"))
	file.close()
	quit(0 if failures == 0 else 1)
