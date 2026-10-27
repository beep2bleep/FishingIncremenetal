extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# This exercises the real confirmation handler and disk reset. Never allow
	# running it against a normal player save directory, even accidentally.
	if not OS.get_user_data_dir().get_file().begins_with("RailwayResetFixture-"):
		push_error("Run this fixture in an isolated RailwayResetFixture project.")
		quit(2)
		return
	root.size = Vector2i(1280, 800)
	if "--capture" in OS.get_cmdline_user_args(): root.gui_embed_subwindows = true
	TranslationServer.set_locale("en")
	root.get_node("Util").set_active_game_id("rowdivers")
	var global = root.get_node("Global")
	global.current_game_mode_data = null
	global.ensure_default_game_mode_data()
	global.new_game()
	global.start_in_upgrade_scene = true
	for profile in ["previous", "rebalanced", "flying", "demo"]:
		ProjectSettings.set_setting("railway_fury/demo/enabled", profile == "demo")
		Progress.free_aim_mode = profile in ["flying", "demo"]
		Progress.active_tree = "previous" if profile == "previous" else "rebalanced"
		Progress.tree_selected = true
		Progress.catalog = {}
		var data = Progress.fresh()
		data.levels[str(Progress.design().upgrades[0].id)] = 1
		data.stats.MaxHP = 5000.0
		data.wallet = [50000.0, 40.0, 5.0]
		data.spent = [900.0, 5.0, 1.0]
		data.unlocks.merge({"Harvester": true, "SlowDown": true, "AchievementsTab": true, "BestiaryTab": true, "GodTab": true})
		data.achievements.FirstBoss = true
		data.claimed.FirstBoss = true
		data.bestiary["6"] = 9
		data.controls_seen = true
		data.max_prestige = 3
		data.prestige = 3
		data.runs = 20
		data.kills = 600
		data.best_distance = 305.0
		data.crowns_dropped = {"0": true, "1": true, "2": true, "3": true}
		data.gameplay_seconds = 2345.0
		data.timed_milestones = {"boss_0": 120.0, "boss_1": 800.0}
		data.timing_complete = false
		data.leaderboards_assisted = true
		data.ending = "LastStation"
		data.endings_seen = {"LastStation": true}
		data.god_panel_unlocked = true
		Progress.save_data(data)
		var screen = load("res://UpgradeScreen.tscn").instantiate()
		root.add_child(screen)
		current_scene = screen
		screen.setup()
		screen.show_screen()
		for frame in range(10): await process_frame
		check(screen.reset_progress_button.visible, "Reset button appears on upgrade screen")
		check(not screen.reset_progress_button.get_global_rect().intersects(screen.go_again_button.get_global_rect()), "Reset does not overlap Play")
		var before = JSON.stringify(Progress.load_data())
		var saved_before = FileAccess.get_file_as_string(Progress.progress_path())
		screen.reset_progress_button.pressed.emit()
		await process_frame
		check(screen.reset_progress_confirm_dialog.visible, "Reset first opens confirmation")
		check(JSON.stringify(Progress.load_data()) == before, "Opening confirmation preserves progress")
		if "--capture" in OS.get_cmdline_user_args() and profile == "flying":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_user_data_dir() + "/reset-confirmation.png")
		screen.reset_progress_confirm_dialog.get_cancel_button().pressed.emit()
		await process_frame
		check(not screen.reset_progress_confirm_dialog.visible, "Cancel closes confirmation")
		check(JSON.stringify(Progress.load_data()) == before and FileAccess.get_file_as_string(Progress.progress_path()) == saved_before, "Cancel preserves memory and disk")
		screen.reset_progress_button.pressed.emit()
		await process_frame
		screen.reset_progress_confirm_dialog.get_ok_button().pressed.emit()
		for frame in range(10): await process_frame
		var fresh = Progress.load_data()
		check(fresh.levels.is_empty() and fresh.stats == Progress.design().base_stats, "Reset removes upgrades and stat bonuses")
		check(fresh.wallet == [0.0, 0.0, 0.0] and fresh.spent == [0.0, 0.0, 0.0], "Reset removes currencies and spending")
		check(fresh.gameplay_seconds == 0 and fresh.timed_milestones.is_empty() and fresh.timing_complete and not fresh.leaderboards_assisted, "Reset clears track time and starts a new timing record")
		check(fresh.prestige == 0 and fresh.max_prestige == 0 and fresh.crowns_dropped.is_empty(), "Reset returns to level one")
		check(fresh.achievements.is_empty() and fresh.claimed.is_empty() and fresh.bestiary.is_empty(), "Reset clears achievement and enemy history")
		check(fresh.unlocks == {"Bow": true} and not fresh.has("ending") and not fresh.has("god_panel_unlocked"), "Reset clears powers and ending choices")
		check(fresh.runs == 0 and fresh.kills == 0 and fresh.best_distance == 0 and not fresh.controls_seen, "New campaign starts with tutorial and no run history")
		check(not screen.row_divers_prestige.visible and screen.row_divers_wallet_label.text.contains("00:00:00"), "Upgrade UI immediately shows level one and zero time")
		var starting_nodes: int = Progress.design().upgrades.filter(func(entry): return int(entry.get("minPrestige", 0)) == 0).size() + 1
		check(not screen.go_again_button.disabled and screen.tech_tree.node_dict.size() == starting_nodes, "Fresh upgrade tree is ready to play")
		var on_disk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Progress.progress_path()))
		check(on_disk == JSON.parse_string(JSON.stringify(fresh)), "Reset is persisted, with no stale cached progression")
		screen.free()
		print("RESET PROFILE: ", profile)
	print("PROGRESS RESET %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	print("RESET PREVIEW DIRECTORY: ", OS.get_user_data_dir())
	quit(0 if failures == 0 else 1)
