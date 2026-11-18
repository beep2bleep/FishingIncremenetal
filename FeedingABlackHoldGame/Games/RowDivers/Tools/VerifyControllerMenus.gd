extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func capture(name: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/controller-0.3-" + name + ".png")

func settle() -> void:
	for i in range(5): await process_frame
	# Editor-only art/music selectors cover the release menu's top-right corner.
	for picker in root.find_children("EditorArtStyle", "OptionButton", true, false):
		picker.get_parent().hide()

func confirm(target: Control) -> void:
	var cursor = root.get_node("VirtualCursor")
	root.get_node("ControllerIcons")._set_last_input_type(1, 0)
	root.get_node("RailwayController").sync_menu()
	root.get_node("RailwayController")._scroll_to(target)
	await settle()
	cursor.move_to_control(target)
	await settle()
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_RIGHT_SHOULDER
	event.pressed = true
	root.get_node("RailwayController")._input(event)
	await settle()
	event.pressed = false
	root.get_node("RailwayController")._input(event)
	await settle()

func back() -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_B
	event.pressed = true
	Input.parse_input_event(event)
	await settle()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func run() -> void:
	root.size = Vector2i(1920, 1080)
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	for edition in ["full", "demo"]: ProjectSettings.set_setting("gameanalytics/railway_" + edition + "_game_key", "")
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	root.get_node("SaveHandler").local_settings_file_path = "user://controller_menu_fixture.json"
	await settle()
	root.get_node("ControllerIcons")._set_last_input_type(1, 0)
	for demo in [false, true]:
		ProjectSettings.set_setting("railway_fury/demo/enabled", demo)
		ProjectSettings.set_setting("global/Demo", demo)
		var menu = load("res://Core/Boot/GameLauncher.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		await settle()
		check(root.get_node("VirtualCursor")._scene_enabled, "Launcher enables controller pointer")
		await capture("menu")
		await confirm(menu.language_button)
		check(menu.language_panel.visible, "Controller opens language selection")
		check(menu.language_list_container.get_child(0).focus_mode == Control.FOCUS_ALL, "Languages support D-pad focus")
		await back()
		check(not menu.language_panel.visible, "B closes language selection")
		await confirm(menu.settings_button)
		check(menu.settings_panel.visible, "Controller opens launcher settings")
		await capture("settings")
		check(menu.settings_quit_button.is_visible_in_tree() and menu.settings_quit_button.focus_mode == Control.FOCUS_ALL, "Quit is reachable by pointer and focus")
		var toggle: BaseButton = menu.settings_content.get_node("%Floating Damage CheckButton")
		var was_pressed := toggle.button_pressed
		await confirm(toggle)
		check(toggle.button_pressed != was_pressed, "Controller cursor changes checkbox state")
		await confirm(toggle)
		check(toggle.button_pressed == was_pressed, "Controller cursor restores checkbox state")
		# Test focus confirmation separately: it must toggle, not only emit pressed.
		root.get_node("VirtualCursor")._set_virtual_cursor_active(false)
		toggle.grab_focus()
		var trigger := InputEventJoypadMotion.new()
		trigger.axis = JOY_AXIS_TRIGGER_RIGHT
		trigger.axis_value = 0.9
		root.get_node("RailwayController")._input(trigger)
		await settle()
		check(toggle.button_pressed != was_pressed, "Focused trigger confirmation toggles checkbox")
		trigger.axis_value = 0.0
		root.get_node("RailwayController")._input(trigger)
		await confirm(toggle)
		var dropdown: OptionButton = menu.settings_content.get_node("%FPS Dropdown")
		dropdown.grab_focus()
		root.get_node("VirtualCursor")._set_virtual_cursor_active(false)
		trigger.axis_value = 0.9
		root.get_node("RailwayController")._input(trigger)
		await settle()
		check(dropdown.get_popup().visible, "Focused trigger opens settings dropdown")
		trigger.axis_value = 0.0
		root.get_node("RailwayController")._input(trigger)
		await back()
		check(not dropdown.get_popup().visible, "B closes settings dropdown")
		check(menu.settings_panel.visible, "Dropdown Back keeps settings open")
		await confirm(dropdown)
		dropdown.get_popup().set_focused_item(1)
		var bumper := InputEventJoypadButton.new()
		bumper.button_index = JOY_BUTTON_RIGHT_SHOULDER
		bumper.pressed = true
		Input.parse_input_event(bumper)
		await settle()
		bumper.pressed = false
		Input.parse_input_event(bumper)
		await settle()
		check(not dropdown.get_popup().visible, "Bumper confirms native dropdown selection")
		await back()
		check(not menu.settings_panel.visible, "B closes launcher settings")
		if "--quit" in OS.get_cmdline_user_args():
			await back()
			check(menu.settings_panel.visible, "B opens settings from launcher")
			print("CONTROLLER QUIT: activating actual Quit button")
			await confirm(menu.settings_quit_button)
			await create_timer(8.0).timeout
			push_error("Controller Quit did not exit the application")
			quit(1)
			return
		menu.free()
		var global = root.get_node("Global")
		global.current_game_mode_data = null
		global.ensure_default_game_mode_data()
		global.new_game()
		Progress.active_data_cache = Progress.fresh()
		Progress.active_data_cache.controls_seen = true
		var screen = load("res://UpgradeScreen.tscn").instantiate()
		root.add_child(screen)
		current_scene = screen
		screen.setup()
		screen.show_screen()
		for i in range(60): await process_frame
		check(root.get_node("VirtualCursor")._scene_enabled, "Upgrade screen keeps controller pointer enabled")
		await capture("upgrades")
		await confirm(screen.settings_button)
		check(screen.settings_panel.visible, "Controller opens upgrade settings")
		check(screen.settings_quit_button.is_visible_in_tree() and screen.settings_quit_button.focus_mode == Control.FOCUS_ALL, "Upgrade Quit is accessible")
		await back()
		check(not screen.settings_panel.visible, "B closes upgrade settings")
		screen.free()
	print("CONTROLLER MENUS: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
