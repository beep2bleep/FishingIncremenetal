extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Model = preload("res://Games/RowDivers/Simulation/GeneratedFreeAimModel.gd")
const Pilot = preload("res://Games/RowDivers/Simulation/FlightPilot.gd")
const Waves = preload("res://Games/RowDivers/RowDiversFireWaves.gd")
var checks = {}
var cases = []
var output_folder = "res://Games/RowDivers/Simulation/Flight"

func _initialize(): call_deferred("run")

func execute(state, real_runtime, test_seed):
	seed(test_seed)
	var battle
	if real_runtime:
		Progress.active_data_cache = state.duplicate(true)
		battle = load("res://Games/RowDivers/Simulation/FlightRuntimeProbe.gd").new()
		battle.persist_results = false
	else:
		battle = Model.new()
		battle.data = state.duplicate(true)
	root.add_child(battle)
	battle.set_process(false)
	battle.set_physics_process(false)
	battle.suspended = false
	var pilot = Pilot.new()
	pilot.setup(test_seed ^ 734921, {})
	var frames = 0
	while not battle.ended and frames < 36000:
		pilot.step(battle, 1.0 / 60)
		battle._simulate_step(1.0 / 60)
		frames += 1
	var result = {"frames":frames,"won":battle.won_run,"distance":-battle.player_position.z,
		"kills":battle.run_kills,"loot":battle.coins.duplicate(),"health":battle.health,
		"armor":battle.armor,"damage":battle.damage_sources.duplicate(),"waves":battle.fire_waves.records.duplicate(true)}
	battle.free()
	return result

func run():
	var args = OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == "--output-dir": output_folder = args[1]
	DirAccess.make_dir_recursive_absolute(output_folder)
	root.get_node("Util").set_active_game_id("rowdivers")
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	Progress.free_aim_mode = true
	var catalog = Progress.design()
	checks.own_save = Progress.progress_path() == Progress.FREE_AIM_SAVE_PATH
	checks.nodes = catalog.upgrades.size() == 124
	var maxed = Progress.fresh()
	maxed.max_prestige = 3
	maxed.wallet = [1e30,1e30,1e30]
	# Legal order: defer arrow multipliers until all flat arrow tiers are bought.
	for loop in range(500):
		var options = catalog.upgrades.filter(func(n): return Progress.can_buy(maxed,n))
		if options.is_empty(): break
		options.sort_custom(func(a,b):
			var ap = a.effects.any(func(e): return e.stat=="Arrow_Damage" and e.percentage)
			var bp = b.effects.any(func(e): return e.stat=="Arrow_Damage" and e.percentage)
			return not ap and bp)
		Progress.buy(maxed,options[0])
	Progress.apply_reference_repairs(maxed)
	checks.all_nodes_legal = catalog.upgrades.all(func(n): return Progress.level(maxed,n)==int(n.maxLevel))
	var fixture = Progress.fresh()
	fixture.controls_seen = true
	var loadouts = [fixture]
	for p in range(4):
		var state = maxed.duplicate(true)
		state.prestige = p
		state.controls_seen = true
		loadouts.append(state)
	var no_control = maxed.duplicate(true)
	no_control.prestige = 3
	no_control.stats.Fire_Wave_Control_3 = 0
	loadouts.append(no_control)
	var output = FileAccess.open(output_folder.path_join("maxed_loadout.json"),FileAccess.WRITE)
	maxed.prestige = 3
	output.store_string(JSON.stringify(maxed,"\t"))
	output.close()
	for i in range(loadouts.size()):
		var actual = execute(loadouts[i],true,73119+i)
		var predicted = execute(loadouts[i],false,73119+i)
		var passed = actual == predicted
		checks["parity_"+str(i)] = passed
		cases.append({"case":i,"passed":passed,"runtime":actual,"model":predicted})
		print("FLIGHT PARITY ",i," ",passed," distance=",actual.distance," kills=",actual.kills)
		await process_frame
	var waves = Waves.new()
	waves.setup(2,12,catalog.settings.fire_waves)
	waves.boss_defeated(4)
	var hard = waves.parameters(0)
	waves.boss_defeated(5)
	checks.third_harder = waves.parameters(0).interval < hard.interval
	checks.control_helps = waves.parameters(80).interval > waves.parameters(0).interval and waves.parameters(80).gap_width > waves.parameters(0).gap_width
	checks.damage_constant = waves.damage == 400
	waves.setup(3,12,catalog.settings.fire_waves)
	checks.stage_resets = waves.stage == 0 and waves.waves.is_empty()
	var passed = checks.values().all(func(value): return value)
	output = FileAccess.open(output_folder.path_join("runtime_validation.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify({"passed":passed,"checks":checks,"cases":cases},"\t"))
	output.close()
	print("FLIGHT VALIDATION ",passed)
	quit(0 if passed else 1)
