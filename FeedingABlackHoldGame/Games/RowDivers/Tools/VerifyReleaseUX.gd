extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const FULL_GAME_URL = "https://store.steampowered.com/app/5520300/Railway_Fury/"
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle(frames := 10) -> void:
	for i in range(frames): await process_frame
func capture(name: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://Games/RowDivers/Docs/Previews/release-0.7-" + name + ".png"))
func prepare_progress() -> void:
	Progress.free_aim_mode = true
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	Progress.active_data_cache.unlocks.AchievementsTab = true
	Progress.cache_profile_path = Progress.progress_path()
func press_button(index: int) -> void:
	for down in [true, false]:
		var event := InputEventJoypadButton.new()
		event.device = 0
		event.button_index = index
		event.pressed = down
		Input.parse_input_event(event)
		await settle(2)
func run() -> void:
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		push_error("Release UX fixture refuses normal player saves")
		quit(2)
		return
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	root.get_node("SaveHandler").local_settings_file_path = "user://release_ux_settings.json"
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	# For exported demos, test the feature flag independently of global/Demo.
	ProjectSettings.set_setting("global/Demo", false)
	TranslationServer.set_locale("en")
	for demo in ([true] if OS.has_feature("railway_demo") else [false, true]):
		ProjectSettings.set_setting("railway_fury/demo/enabled", demo and not OS.has_feature("railway_demo"))
		prepare_progress()
		var menu = load("res://Core/Boot/GameLauncher.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		await settle(25)
		check(Progress.Demo.enabled() == demo, "Edition comes from the correct demo gate")
		check(is_instance_valid(menu.row_divers_wishlist_button) == demo, "Main menu wishlist only appears in demo")
		if demo:
			check(menu.row_divers_wishlist_button.is_visible_in_tree() and menu.row_divers_wishlist_button.text == "WISHLIST NOW" and menu.row_divers_wishlist_button.tooltip_text == FULL_GAME_URL, "Main menu Wishlist Now points to the full Steam app")
			await capture("demo-menu")
		menu.free()
		var global = root.get_node("Global")
		global.current_game_mode_data = null
		global.ensure_default_game_mode_data()
		global.new_game()
		global.start_in_upgrade_scene = true
		prepare_progress()
		var screen = load("res://UpgradeScreen.tscn").instantiate()
		root.add_child(screen)
		current_scene = screen
		screen.setup()
		screen.show_screen()
		await settle(70)
		check(screen._get_active_wishlist_button().visible == demo, "Upgrade wishlist respects the Steam demo feature even with global/Demo false")
		if demo:
			var button: Button = screen._get_active_wishlist_button()
			check(button.is_visible_in_tree() and button.text == "WISHLIST NOW" and not button.disabled and button.tooltip_text == FULL_GAME_URL, "Upgrade Wishlist Now points to full Steam app")
			await capture("demo-upgrades")
		screen._show_row_divers_achievements()
		var reward_rows := 0
		var decimal := RegEx.create_from_string("Reward: [0-9]+\\.[0-9]+")
		for row in screen.row_divers_collection_panel.find_children("*", "Button", true, false):
			if row.text.contains("Reward:"):
				reward_rows += 1
				check(decimal.search(row.text) == null, "Actual achievement reward is a whole number: " + row.text.get_slice("\n", 1))
		check(reward_rows > 0, "Real achievement UI rows were inspected")
		if demo: await capture("demo-achievements")
		screen.free()
		prepare_progress()
		root.get_node("ControllerIcons")._set_last_input_type(0, -1)
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle._finish(false)
		check(battle.overlay_title.text == "THE RAILWAY CLAIMS YOU", "Actual death screen uses THE RAILWAY CLAIMS YOU")
		battle.free()
		if not demo: continue
		prepare_progress()
		battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		var started := Time.get_ticks_msec()
		battle._finish(true)
		check(battle.presentation.wishlist_button.visible and battle.presentation.wishlist_button.tooltip_text == FULL_GAME_URL, "Demo completion displays prominent full-game Wishlist Now")
		check(battle.presentation.wishlist_button.get_theme_font_size("font_size") >= 30, "Demo completion wishlist uses prominent type")
		check(battle.presentation.results_input_locked and battle.presentation.wishlist_button.disabled and battle.retry.disabled and battle.presentation.quit_button.disabled, "All demo-complete actions locked initially")
		await settle()
		await capture("demo-complete-countdown")
		var escape := InputEventKey.new()
		escape.keycode = KEY_ESCAPE
		escape.pressed = true
		Input.parse_input_event(escape)
		escape = escape.duplicate()
		escape.pressed = false
		Input.parse_input_event(escape)
		await press_button(JOY_BUTTON_START)
		await press_button(JOY_BUTTON_B)
		await create_timer(4.0).timeout
		check(is_instance_valid(battle) and battle.ended and battle.presentation.results_input_locked and battle.retry.disabled, "Mouse/keyboard and controller cannot leave before five seconds")
		await create_timer(1.2).timeout
		await settle()
		check(Time.get_ticks_msec() - started >= 5000 and not battle.presentation.results_input_locked and not battle.presentation.wishlist_button.disabled, "Demo completion unlocks after at least five real seconds")
		check(battle.presentation.wishlist_button.get_global_rect().has_point(root.get_node("VirtualCursor").get_screen_position()), "Unlocked controller cursor targets Wishlist Now")
		await capture("demo-complete")
		battle.free()
	print("RELEASE UX: %d checks; %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
