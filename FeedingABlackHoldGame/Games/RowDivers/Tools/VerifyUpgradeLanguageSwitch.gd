extends SceneTree

const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	var saves = root.get_node("SaveHandler")
	saves.local_settings_file_path = "user://upgrade_language_test_settings.json"
	saves.update_locale("en")
	Progress.free_aim_mode = true
	var data := Progress.fresh()
	data.wallet = [100.0, 5.0, 0.0]
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.ensure_default_game_mode_data()
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	while screen.tech_tree.build_in_progress:
		await process_frame
	# Let the initial deferred recenter finish before recording the player's view.
	for frame in range(5):
		await process_frame
	screen._on_settings_button_pressed()
	var nodes: Array = screen.tech_tree.get_nodes()
	var wallet: Array = data.wallet.duplicate()
	var levels: Dictionary = data.levels.duplicate()
	screen.tech_tree.set_zoom(0.65)
	screen.tech_tree.selected_node = nodes[1]
	var position: Vector2 = screen.tech_tree.pivot.position
	var locales: Array = saves.available_locales(false).keys()
	locales.append("en")
	for locale in locales:
		var index: int = screen.settings_content.locale_codes.find(locale)
		check(index >= 0, "Language available: " + locale)
		screen.settings_content._on_language_dropdown_item_selected(index)
		for frame in range(3):
			await process_frame
		check(not screen.tech_tree.build_in_progress, "Language switch does not rebuild tree: " + locale)
		check(is_instance_valid(nodes[1]), "Existing upgrade node survives: " + locale)
		check(screen.tech_tree.get_nodes().size() == nodes.size(), "Stable node count: " + locale)
		check(screen.tech_tree.selected_node == nodes[1], "Selection preserved: " + locale)
		check(is_equal_approx(screen.tech_tree.current_zoom, 0.65) and screen.tech_tree.pivot.position == position, "View preserved: " + locale)
		check(data.wallet == wallet and data.levels == levels, "Progress preserved: " + locale)
		for node in screen.tech_tree.get_nodes():
			if node.upgrade == null:
				continue
			var entry := Progress.find_upgrade(node.upgrade.sim_key)
			check(node.upgrade.sim_name == TranslationServer.translate(entry.upgradeName), "Localized upgrade title: " + locale)
			check(node.get_node("%Description").text.begins_with(node.upgrade.sim_name + "\n"), "Localized tooltip: " + locale)
		check(screen.settings_panel.visible, "Settings remain open: " + locale)
		# Stop early on the original destructive rebuild to avoid accessing freed nodes.
		if not is_instance_valid(nodes[1]):
			break
	screen._on_settings_close_pressed()
	check(not screen.settings_panel.visible and screen.is_active, "Upgrade screen remains usable")
	screen.free()
	DirAccess.remove_absolute(saves.local_settings_file_path)
	print("UPGRADE LANGUAGE SWITCH: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
