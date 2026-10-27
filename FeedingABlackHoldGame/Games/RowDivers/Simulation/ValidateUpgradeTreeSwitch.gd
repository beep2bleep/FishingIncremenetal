extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks: Dictionary = {}

func _initialize(): call_deferred("run")
func verify(key, condition):
	checks[key] = bool(condition)
	if not condition: push_error("Tree switch: " + key)

func run():
	var settings = root.get_node("SaveHandler")
	var old_path = settings.local_settings_file_path
	var old_selection = settings.row_divers_previous_upgrade_tree
	settings.local_settings_file_path = "user://railway_tree_switch_test_settings.json"
	settings.row_divers_previous_upgrade_tree = false
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.tree_selected = false
	Progress.sync_tree_preference()
	var tuned = Progress.design().duplicate(true)
	verify("new_tree_default", Progress.active_tree == "rebalanced")
	verify("new_progress_separate", Progress.progress_path() == Progress.REBALANCED_SAVE_PATH)
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.wallet = [7.0, 2.0, 0.0]
	var screen = load("res://Settings.tscn").instantiate()
	root.add_child(screen)
	verify("setting_visible", screen.row_divers_tree_toggle != null and screen.row_divers_tree_toggle.item_count == 2)
	screen.row_divers_tree_toggle.select(1)
	screen.row_divers_tree_toggle.item_selected.emit(1)
	verify("preference_changed", settings.row_divers_previous_upgrade_tree)
	verify("active_dive_catalog_stable", Progress.design() == tuned)
	verify("active_dive_save_destination_stable", Progress.progress_path() == Progress.REBALANCED_SAVE_PATH)
	verify("active_dive_wallet_stable", Progress.active_data_cache.wallet == [7.0, 2.0, 0.0])
	settings.row_divers_previous_upgrade_tree = false
	settings.load_local_settings()
	verify("preference_persists", settings.row_divers_previous_upgrade_tree)
	Progress.tree_selected = false # Simulate a fresh process without touching either save.
	Progress.sync_tree_preference()
	verify("previous_progress_restored", Progress.progress_path() == Progress.SAVE_PATH)
	verify("old_cache_cleared", Progress.active_data_cache.is_empty())
	var previous = JSON.parse_string(FileAccess.get_file_as_string(Progress.PREVIOUS_DATA_PATH))
	verify("previous_catalog_exact", Progress.design() == previous)
	if FileAccess.file_exists(Progress.SAVE_PATH):
		var saved = JSON.parse_string(FileAccess.get_file_as_string(Progress.SAVE_PATH))
		var restored = Progress.load_data()
		verify("previous_saved_levels_restored", restored.levels == saved.levels)
		verify("previous_saved_wallet_restored", restored.wallet == saved.wallet)
	verify("catalogs_differ", tuned != previous)
	settings.row_divers_previous_upgrade_tree = false
	Progress.tree_selected = false
	Progress.sync_tree_preference()
	verify("new_tree_restored", Progress.design() == tuned)
	# Use the actual shared shop to verify the zero-threshold entry is rendered
	# as available, not merely accepted by the offline progression API.
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.wallet = [4.0, 0.0, 0.0]
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	load("res://Games/RowDivers/RowDiversUpgradeTreeAdapter.gd").apply_simulation_upgrades()
	var tree = load("res://Tech Tree Stuff/Tech Tree.tscn").instantiate()
	root.add_child(tree)
	tree.setup()
	for frame in range(30):
		await process_frame
		if not tree.build_in_progress: break
	for frame in range(4): await process_frame # Let the shop's deferred recenter finish.
	var impact_node = null
	for node in tree.node_dict.values():
		if node.upgrade != null and node.upgrade.sim_name == "Impact Armor I": impact_node = node
	verify("impact_node_exists", impact_node != null)
	if impact_node != null:
		verify("impact_available_in_real_shop", impact_node.state == 1)
		verify("impact_affordable_in_real_shop", impact_node.can_pay_cost)
		var entry = Progress.find_upgrade(impact_node.upgrade.sim_key)
		verify("starting_purchase_legal", Progress.buy(Progress.active_data_cache, entry))
		verify("starting_purchase_applies_value", Progress.stat(Progress.active_data_cache, "Impact_Armor") == float(entry.effects[0].amount))
	tree.free()
	var original = JSON.parse_string(FileAccess.get_file_as_string("res://Games/RowDivers/Simulation/Tuning/SourceSnapshot/row_divers.json"))
	verify("old_tree_preserved_exactly", previous == original)
	screen.free()
	DirAccess.remove_absolute(settings.local_settings_file_path)
	settings.local_settings_file_path = old_path
	settings.row_divers_previous_upgrade_tree = old_selection
	var passed = checks.values().all(func(value): return value)
	var file = FileAccess.open("res://Games/RowDivers/Simulation/Tuning/switch_validation.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed": passed, "checks": checks}, "\t"))
	print("TREE SWITCH ", passed, " ", checks)
	quit(0 if passed else 1)
