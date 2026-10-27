extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = false
	var classic_path = Progress.progress_path()
	var classic = Progress.design().duplicate(true)
	Progress.free_aim_mode = true
	checks.separate_slot = Progress.progress_path() != classic_path
	checks.own_catalog = Progress.design().upgrades.size()==124 and classic.upgrades.size()==112
	var fresh = Progress.fresh()
	fresh.max_prestige = 1
	fresh.levels["6660"] = 1 # Owned crown gate; eligibility still requires its prestige.
	fresh.wallet = [1000.0,0.0,0.0]
	checks.future_locked = not Progress.visible(fresh,Progress.find_upgrade("flight_2_0"))
	checks.control_purchase_legal = Progress.buy(fresh,Progress.find_upgrade("flight_1_0"))
	checks.control_whole_points = fresh.stats.Fire_Wave_Control_1 == 10 and fresh.stats.Fire_Wave_Control_2==0
	checks.cost_paid = fresh.wallet[0]==800
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_process(false)
	battle.set_physics_process(false)
	battle.set_debug_speed(32)
	battle._damage_player(10.0,false,"enemy arrows")
	checks.fast_mode_still_takes_projectiles = battle.health == 90
	battle.health = 100
	battle.data.stats.Armor_Against_Projectiles = 15
	battle._damage_player(100.0,false,"enemy arrows")
	checks.projectile_armor_works = battle.health == 15
	battle.set_debug_speed(1)
	battle.free()
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	for p in [0,1,3]:
		var state = fresh.duplicate(true)
		state.max_prestige = p
		Progress.active_data_cache = state
		load("res://Games/RowDivers/RowDiversUpgradeTreeAdapter.gd").apply_simulation_upgrades()
		checks["shop_count_"+str(p)] = global.game_mode_data_manager.upgrades.size() == {0:109,1:114,3:124}[p]
		var tree = load("res://Tech Tree Stuff/Tech Tree.tscn").instantiate()
		root.add_child(tree)
		tree.setup()
		for frame in range(30):
			await process_frame
			if not tree.build_in_progress: break
		for frame in range(4): await process_frame
		var entry = null
		for node in tree.node_dict.values():
			if node.upgrade != null and node.upgrade.sim_key=="flight_1_0": entry=node
		checks["shop_node_"+str(p)] = entry != null if p>=1 else entry==null
		if entry != null:
			checks["shop_payable_"+str(p)] = entry.can_pay_cost
		tree.free()
	Progress.free_aim_mode = false
	checks.classic_restored = Progress.design()==classic and Progress.progress_path()==classic_path
	var passed = checks.values().all(func(value):return value)
	var output_dir = "res://Games/RowDivers/Simulation/CrownValidation/runtime"
	var args = OS.get_cmdline_user_args()
	if "--output-dir" in args: output_dir = args[args.find("--output-dir")+1]
	DirAccess.make_dir_recursive_absolute(output_dir)
	var file=FileAccess.open(output_dir.path_join("tree_validation.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":passed,"checks":checks},"\t"))
	print("FLIGHT TREE ",passed," ",checks)
	quit(0 if passed else 1)
