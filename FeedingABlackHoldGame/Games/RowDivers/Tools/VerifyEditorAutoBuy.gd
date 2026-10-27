extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = {}
func _initialize(): call_deferred("run")
func run():
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	data.wallet = [12.0,0.0,0.0]
	data.gameplay_seconds = 123.5
	Progress.active_data_cache = data
	checks.screen_compiles = load("res://UpgradeScreen.gd") != null
	var buyer = load("res://Games/RowDivers/RowDiversEditorBuyer.gd").new()
	root.add_child(buyer)
	buyer.persist_results = false
	buyer.max_purchases = 1
	var result: Dictionary = await buyer.buy_available()
	checks.bought_one = result.get("count",0)==1
	checks.clock_preserved = Progress.active_data_cache.gameplay_seconds==123.5
	checks.assisted_scores_stay_local = Progress.active_data_cache.leaderboards_assisted
	if result.has("record"):
		var record = JSON.parse_string(FileAccess.get_file_as_string(result.record))
		checks.same_weights = record.config.weights=={"distance":.6,"gold_rate":.28,"gem_rate":.12}
		checks.same_runner = record.config.runner_sha256 == FileAccess.get_sha256("res://Games/RowDivers/Simulation/RunBalanceCampaign.gd")
		var choice = record.choices[0]
		checks.highest_forecast_score = choice.alternatives.all(func(a):return a.score<=choice.score)
		checks.real_cost_paid = Progress.active_data_cache.wallet[0] == 12.0-choice.price
		checks.live_state_updated = Progress.active_data_cache.levels.get(choice.id,0)==1
	else:
		checks.record_exists = false
		print("AUTO BUY ERROR: ",result)
	data = Progress.fresh()
	data.wallet = [100.0,0.0,0.0]
	Progress.active_data_cache = data
	Progress.load_data() # Apply migrations before taking the cancellation snapshot.
	var before = JSON.stringify(data)
	create_timer(.01).timeout.connect(buyer.cancel)
	result = await buyer.buy_available()
	checks.cancelled = result.get("cancelled",false)
	checks.cancel_preserves_wallet = JSON.stringify(Progress.active_data_cache)==before
	checks.child_stopped = buyer.process_id == -1 and not buyer.busy
	data = Progress.fresh()
	data.wallet = [200000.0,10.0,4.0]
	data.unlocks.GodTab = true
	Progress.active_data_cache = data
	result = await buyer.buy_available()
	checks.final_fee_reserved = result.get("count",-1)==0 and Progress.active_data_cache.wallet==[200000.0,10.0,4.0]
	checks.ending_left_to_player = not Progress.active_data_cache.has("ending") and not Progress.active_data_cache.get("god_panel_unlocked",false)
	data = Progress.fresh()
	data.unlocks.AchievementsTab = true
	data.achievements.FirstDive = true
	Progress.active_data_cache = data
	result = await buyer.buy_available()
	checks.claim_funds_purchase = result.get("claims",0)==1 and result.get("count",0)==1
	checks.claim_wallet_correct = is_equal_approx(Progress.active_data_cache.wallet[0]+Progress.active_data_cache.spent[0],25)
	Progress.free_aim_mode = false
	Progress.active_tree = "previous"
	Progress.tree_selected = true
	Progress.catalog = {}
	data = Progress.fresh()
	data.wallet = [100.0,0.0,0.0]
	Progress.active_data_cache = data
	var previous_initial = data.duplicate(true)
	result = await buyer.buy_available()
	if result.has("record"):
		var record = JSON.parse_string(FileAccess.get_file_as_string(result.record))
		checks.previous_catalog_correct = record.config.catalog_sha256==FileAccess.get_sha256(Progress.PREVIOUS_DATA_PATH) and record.config.upgrade_tree=="previous"
		var choice = record.choices[0]
		Progress.buy(previous_initial,Progress.find_upgrade(choice.id))
		checks.previous_cost_paid = previous_initial.wallet==Progress.active_data_cache.wallet and previous_initial.stats==Progress.active_data_cache.stats
	else: checks.previous_catalog_correct = false
	Progress.active_tree = "rebalanced"
	Progress.free_aim_mode = true
	buyer.free()
	data = Progress.fresh()
	data.wallet = [100.0,0.0,0.0]
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for frame in range(30): await process_frame
	checks.button_visible = screen.row_divers_auto_buy_button != null and screen.row_divers_auto_buy_button.is_visible_in_tree()
	checks.button_connected = screen.row_divers_auto_buy_button.pressed.is_connected(screen._run_row_divers_auto_buy)
	screen.row_divers_editor_buyer.persist_results = false
	screen.row_divers_editor_buyer.max_purchases = 1
	await screen._run_row_divers_auto_buy()
	for frame in range(30): await process_frame
	var levels = Progress.active_data_cache.levels
	checks.button_buys_live = not levels.is_empty()
	checks.tree_updates = screen.tech_tree.node_dict.values().any(func(n):return n.upgrade!=null and levels.get(n.upgrade.sim_key,0)>0 and n.upgrade.current_tier>0)
	if "--preview" in OS.get_cmdline_user_args():
		root.size = Vector2i(1280,720)
		for frame in range(8): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/editor_auto_buy.png")
	screen.free()
	var passed = checks.values().all(func(v):return v)
	print("EDITOR AUTO BUY: ",checks.size()," checks passed=",passed," ",checks)
	quit(0 if passed else 1)
