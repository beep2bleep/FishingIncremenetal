extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks := 0
var failures := 0
var mode := "flow"
var control: Node
var cursor: Node

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle(frames := 5) -> void:
	for i in range(frames): await process_frame
	for picker in root.find_children("EditorArtStyle", "OptionButton", true, false): picker.get_parent().hide()

func button(index: int, down := true) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = index
	event.pressed = down
	Input.parse_input_event(event)
	await settle(2)

func press(index: int) -> void:
	await button(index)
	await button(index, false)
	await settle()

func axis(index: int, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = 0
	event.axis = index
	event.axis_value = value
	Input.parse_input_event(event)
	await settle()

func activate(target: Control) -> void:
	control._scroll_to(target)
	await settle()
	cursor.move_to_control(target)
	await settle()
	await press(JOY_BUTTON_A)

func focused_activate(target: Control) -> void:
	cursor._set_virtual_cursor_active(false)
	target.grab_focus()
	control._scroll_to(target)
	await settle()
	await press(JOY_BUTTON_A)

func wait_owner(kind: String) -> bool:
	var deadline := Time.get_ticks_msec() + 12000
	while Time.get_ticks_msec() < deadline:
		await settle()
		if not is_instance_valid(control.menu_owner): continue
		if kind == "upgrades" and control.menu_owner.get_script().resource_path.ends_with("/UpgradeScreen.gd"):
			if not control.menu_owner.is_active or control.menu_owner.tech_tree == null or control.menu_owner.tech_tree.build_in_progress: continue
			await settle(30)
			return true
		if kind == "battle" and is_instance_valid(control.battle): return true
		if kind == "menu" and control.menu_owner.has_method("_on_row_divers_button_pressed"): return true
		if kind == "ending" and control.menu_owner.has_method("_choose"): return true
	check(false, "Transition reaches " + kind)
	return false

func capture(name: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/controller-flow-" + name + ".png")

func glyphs() -> void:
	var textures: Array = control.menu_hint.find_children("*", "TextureRect", true, false)
	check(control.menu_hint.visible and not textures.is_empty(), "Controller glyphs shown in " + control.menu_context)
	check(textures.all(func(icon): return icon.texture != null), "Every glyph resolves in " + control.menu_context)

func settings_actions(settings: Control) -> void:
	for name in ["Main Volume", "Music Volume", "Effect Volume Slider"]:
		var slider: Range = settings.get_node("%" + name)
		var before: float = slider.value
		cursor._set_virtual_cursor_active(false)
		slider.grab_focus()
		control._scroll_to(slider)
		await press(JOY_BUTTON_DPAD_RIGHT if before < slider.max_value else JOY_BUTTON_DPAD_LEFT)
		check(slider.value != before, "D-pad adjusts " + name)
		await press(JOY_BUTTON_DPAD_LEFT if before < slider.max_value else JOY_BUTTON_DPAD_RIGHT)
	for toggle in settings.find_children("*", "BaseButton", true, false):
		if not (toggle is CheckBox or toggle is CheckButton) or not toggle.is_visible_in_tree(): continue
		var before: bool = toggle.button_pressed
		await focused_activate(toggle)
		check(toggle.button_pressed != before, "Controller toggles " + toggle.name)
		await focused_activate(toggle)
	for name in ["Language Dropdown", "Screen Mode Dropdown", "FPS Dropdown"]:
		var dropdown: OptionButton = settings.get_node("%" + name)
		var before: int = dropdown.selected
		await focused_activate(dropdown)
		check(dropdown.get_popup().visible, "Controller opens " + name)
		await press(JOY_BUTTON_DPAD_DOWN)
		await press(JOY_BUTTON_A)
		check(not dropdown.get_popup().visible, "Controller selects and exits " + name)
		await focused_activate(dropdown)
		dropdown.get_popup().set_focused_item(before)
		await press(JOY_BUTTON_A)
	var smaller: Control = settings.get_node("GridContainer/HBoxContainer2/Text Smaller")
	var larger: Control = settings.get_node("GridContainer/HBoxContainer2/Text Larger")
	var scale_before: float = root.get_node("SaveHandler").text_scale
	await activate(smaller)
	check(root.get_node("SaveHandler").text_scale < scale_before, "Controller decreases text size")
	await activate(larger)

func quit_at(target: Control) -> void:
	print("CONTROLLER QUIT ACTIVATED: ", mode)
	await activate(target)
	await create_timer(8.0).timeout
	check(false, "Controller Quit did not exit")
	quit(1)

func new_battle_from_upgrades():
	await press(JOY_BUTTON_START)
	if not await wait_owner("battle"): return null
	var battle = control.battle
	battle.persist_results = false
	battle.set_physics_process(false)
	return battle

func both_endings() -> void:
	ProjectSettings.set_setting("railway_fury/demo/enabled", false)
	ProjectSettings.set_setting("global/Demo", false)
	Progress.free_aim_mode = true
	var data := Progress.fresh()
	data.unlocks.GodTab = true
	data.god_panel_unlocked = true
	Progress.active_data_cache = data
	Progress.save_data(data)
	var choices: Array = load("res://Games/RowDivers/RowDiversEndings.gd").CHOICES.keys()
	root.get_node("ControllerIcons")._set_last_input_type(1, 0)
	for index in range(2):
		if is_instance_valid(current_scene): current_scene.free()
		var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
		ending.persist_results = false
		root.add_child(ending)
		current_scene = ending
		await settle()
		if index == 1: await press(JOY_BUTTON_DPAD_DOWN)
		else: cursor._set_virtual_cursor_active(false)
		await press(JOY_BUTTON_A)
		check(ending.choice_made and Progress.load_data().ending == choices[index], "Controller chooses ending " + str(index + 1))
		check(root.gui_get_focus_owner() == ending.continue_button, "Ending reveal selects return action")
		await press(JOY_BUTTON_B if index == 0 else JOY_BUTTON_A)
		var reached := await wait_owner("menu")
		check(reached, "Ending returns to launcher by Back or Confirm")

func run() -> void:
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		push_error("Run through verify_controller_flow.ps1: isolated save folder required")
		quit(1)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("quit-"): mode = arg
		if arg == "endings": mode = arg
	root.size = Vector2i(1920, 1080)
	if "--small" in OS.get_cmdline_user_args():
		root.content_scale_size = Vector2i(1920, 1080)
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		root.size = Vector2i(1280, 720)
	await settle()
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	for edition in ["full", "demo"]: ProjectSettings.set_setting("gameanalytics/railway_" + edition + "_game_key", "")
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	control = root.get_node("RailwayController")
	cursor = root.get_node("VirtualCursor")
	root.get_node("SaveHandler").local_settings_file_path = "user://controller_flow_settings.json"
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	if mode == "endings":
		await both_endings()
		print("CONTROLLER ENDINGS %s: %d checks; %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
		quit(0 if failures == 0 else 1)
		return
	for demo in ([true] if OS.has_feature("railway_demo") else [false, true]):
		ProjectSettings.set_setting("railway_fury/demo/enabled", demo)
		ProjectSettings.set_setting("global/Demo", demo)
		Progress.free_aim_mode = true
		var data := Progress.fresh()
		data.wallet = [1000000.0, 1000000.0, 1000000.0]
		data.unlocks.AchievementsTab = true
		data.unlocks.BestiaryTab = true
		data.achievements.FirstDive = true
		Progress.active_data_cache = data
		Progress.save_data(data)
		var menu = load("res://Core/Boot/GameLauncher.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		await press(JOY_BUTTON_DPAD_DOWN)
		check(control.menu_context == "menu" and control.using_controller(), "Controller starts on main menu")
		glyphs()
		var position: Vector2 = cursor.get_screen_position()
		await axis(JOY_AXIS_LEFT_X, -0.8)
		await settle(5)
		await axis(JOY_AXIS_LEFT_X, 0)
		check(cursor.get_screen_position().x < position.x, "Left stick actually moves menu cursor")
		await activate(menu.language_button)
		check(control.menu_context == "language", "Language mode has a controller context")
		await press(JOY_BUTTON_B)
		check(not menu.language_panel.visible, "Back leaves language mode")
		await press(JOY_BUTTON_B)
		check(control.menu_context == "settings", "Main-menu Back opens Settings")
		if mode == "flow" and not "--quick" in OS.get_cmdline_user_args():
			await settings_actions(menu.settings_content)
			root.mode = Window.MODE_WINDOWED
			root.size = Vector2i(1280, 720) if "--small" in OS.get_cmdline_user_args() else Vector2i(1920, 1080)
			await settle(15)
		if mode == "quit-main":
			await quit_at(menu.settings_quit_button)
			return
		await activate(menu.settings_content.get_node("%Credits Button"))
		check(control.menu_context == "credits", "Credits gets its own controller context")
		glyphs()
		var credits: RichTextLabel = menu.settings_content.get_node("%Credits Text")
		cursor.move_to_control(credits)
		var scroll_before: float = credits.get_v_scroll_bar().value
		await axis(JOY_AXIS_RIGHT_Y, 0.9)
		await settle(15)
		await axis(JOY_AXIS_RIGHT_Y, 0)
		check(credits.get_v_scroll_bar().value > scroll_before, "Right stick scrolls credits text")
		await capture("credits")
		if mode == "quit-credits":
			await quit_at(menu.settings_quit_button)
			return
		await press(JOY_BUTTON_B)
		check(control.menu_context == "settings" and menu.settings_panel.visible, "Back from credits restores settings")
		await press(JOY_BUTTON_B)
		check(control.menu_context == "menu", "Back from settings restores launcher")
		await press(JOY_BUTTON_START)
		if not await wait_owner("upgrades"): break
		var screen = control.menu_owner
		check(control.menu_context == "upgrades" and not cursor._gameplay_pointer_hidden, "Main menu actually transitions to usable upgrades")
		glyphs()
		await capture("upgrades")
		check(control.menu_hint.get_global_rect().end.x + 10 <= screen.go_again_button.get_parent().get_global_rect().position.x, "Upgrade hints stay clear of Play and its Start glyph")
		var pickup_one = null
		var pickup_two = null
		for candidate in screen.tech_tree.node_dict.values():
			if candidate.upgrade == null: continue
			if candidate.upgrade.sim_name == "Pickup Range I": pickup_one = candidate
			if candidate.upgrade.sim_name == "Pickup Range II": pickup_two = candidate
		check(pickup_one != null and pickup_two != null, "Pickup Range navigation fixture exists")
		if pickup_one != null and pickup_two != null:
			var old_one: int = pickup_one.state
			var old_two: int = pickup_two.state
			pickup_one.state = pickup_one.STATES.COMPLETE
			pickup_two.state = pickup_two.STATES.AVAILABLE
			cursor._set_virtual_cursor_active(false)
			pickup_one.click_mask.grab_focus()
			await settle()
			var offset: Vector2 = pickup_two.position - pickup_one.position
			await press((JOY_BUTTON_DPAD_RIGHT if offset.x > 0 else JOY_BUTTON_DPAD_LEFT) if absf(offset.x) > absf(offset.y) else (JOY_BUTTON_DPAD_DOWN if offset.y > 0 else JOY_BUTTON_DPAD_UP))
			check(screen.tech_tree.selected_node == pickup_two and root.gui_get_focus_owner() == pickup_two.click_mask, "D-pad selects displayed Pickup Range II instead of locked upgrade")
			pickup_one._force_close_tooltip()
			pickup_two._force_close_tooltip()
			pickup_one.state = old_one
			pickup_two.state = old_two
		if mode == "quit-upgrades":
			await press(JOY_BUTTON_B)
			await quit_at(screen.settings_quit_button)
			return
		var node = null
		for candidate in screen.tech_tree.node_dict.values():
			if candidate.upgrade != null and candidate.state == candidate.STATES.AVAILABLE and candidate.can_pay_cost:
				node = candidate
				break
		check(node != null, "Fixture has an affordable real upgrade")
		if node != null:
			var before: int = node.upgrade.current_tier
			root.get_node("SaveHandler").confirm_upgrade_purchase = true
			await focused_activate(node.click_mask)
			check(node.controller_purchase_armed and node.upgrade.current_tier == before, "First confirm arms a purchase without buying")
			await press(JOY_BUTTON_B)
			check(not node.controller_purchase_armed and node.upgrade.current_tier == before, "Back cancels upgrade purchase")
			await focused_activate(node.click_mask)
			await press(JOY_BUTTON_A)
			check(node.upgrade.current_tier == before + 1, "Second controller confirm buys real upgrade")
			root.get_node("SaveHandler").confirm_upgrade_purchase = false
			# Moving the virtual pointer after a purchase must replace focused details.
			cursor.move_to_control(node.click_mask)
			await settle(20)
			var other = null
			for candidate in screen.tech_tree.node_dict.values():
				if candidate != node and candidate.upgrade != null and candidate.state in [candidate.STATES.AVAILABLE, candidate.STATES.COMPLETE]:
					other = candidate
					break
			check(other != null, "Another upgrade exists for pointer hover regression")
			if other != null:
				cursor.move_to_screen_position(Vector2(1100, 600))
				await settle(30)
				screen.tech_tree.set_tech_tree_pos(-other.position)
				await settle(30)
				cursor.move_to_control(other.click_mask)
				await settle(30)
				check(other.is_highlighted and screen.tech_tree.selected_node == other, "Virtual pointer switches upgrade details after purchase")
				check(not node.is_highlighted, "Purchased upgrade releases old tooltip")
		await press(JOY_BUTTON_Y)
		check(root.gui_get_focus_owner() == screen.go_again_button, "Y moves from tree to menu actions")
		var pan_start: Vector2 = screen.tech_tree.pivot.position
		cursor.move_to_screen_position(Vector2(800, 400))
		await button(JOY_BUTTON_X)
		await axis(JOY_AXIS_LEFT_X, -0.8)
		await settle(6)
		await axis(JOY_AXIS_LEFT_X, 0)
		await button(JOY_BUTTON_X, false)
		check(screen.tech_tree.pivot.position != pan_start, "X plus stick pans actual upgrade tree")
		pan_start = screen.tech_tree.pivot.position
		var pan_zoom: float = screen.tech_tree.current_zoom
		await axis(JOY_AXIS_RIGHT_X, 0.8)
		await axis(JOY_AXIS_RIGHT_Y, -0.8)
		await settle(10)
		await axis(JOY_AXIS_RIGHT_X, 0)
		await axis(JOY_AXIS_RIGHT_Y, 0)
		check(screen.tech_tree.pivot.position.x != pan_start.x and screen.tech_tree.pivot.position.y != pan_start.y, "Right stick pans upgrade tree on both axes")
		check(is_equal_approx(screen.tech_tree.current_zoom, pan_zoom), "Right stick panning does not zoom")
		var zoom_before: float = screen.tech_tree.current_zoom
		await axis(JOY_AXIS_TRIGGER_LEFT, 1)
		await axis(JOY_AXIS_RIGHT_Y, 0.9)
		await settle(10)
		await axis(JOY_AXIS_RIGHT_Y, 0)
		await axis(JOY_AXIS_TRIGGER_LEFT, 0)
		check(screen.tech_tree.current_zoom < zoom_before, "Left trigger plus right stick zooms actual upgrade tree")
		await activate(screen.row_divers_achievements_button)
		check(control.menu_context == "collection", "Achievements opens controller collection mode")
		var claimed_before: int = Progress.load_data().get("claimed", {}).size()
		for row in control._menu_controls():
			if row is Button and row.text.contains("CLAIM") and not row.text.contains("Claimed"):
				await activate(row)
				break
		check(Progress.load_data().get("claimed", {}).size() > claimed_before, "Controller claims an achievement reward")
		await press(JOY_BUTTON_B)
		await activate(screen.row_divers_bestiary_button)
		check(control.menu_context == "collection", "Bestiary opens with controller")
		await press(JOY_BUTTON_B)
		check(control.menu_context == "upgrades", "Back returns collections to tree")
		if screen.leaderboard_button != null and screen.leaderboard_button.visible:
			await activate(screen.leaderboard_button)
			check(control.menu_context == "leaderboard", "Controller opens leaderboard")
			await press(JOY_BUTTON_B)
			check(control.menu_context == "upgrades", "Back closes leaderboard")
		if "--quick" in OS.get_cmdline_user_args(): break
		await activate(screen.reset_progress_button)
		check(screen.reset_progress_confirm_dialog.visible and control.menu_context == "dialog", "Reset confirmation gets native dialog controller context")
		await press(JOY_BUTTON_B)
		check(not screen.reset_progress_confirm_dialog.visible, "Back cancels reset dialog")
		await activate(screen.reset_progress_button)
		screen.reset_progress_confirm_dialog.get_ok_button().grab_focus()
		await press(JOY_BUTTON_A)
		check(Progress.load_data().levels.is_empty(), "Controller confirms reset in isolated QA profile")
		var battle = await new_battle_from_upgrades()
		if battle == null: break
		check(control.menu_context == "tutorial", "First run opens navigable tutorial")
		await press(JOY_BUTTON_START)
		check(not battle.suspended and control.menu_surface == null and cursor._gameplay_pointer_hidden, "Tutorial Start enters gameplay")
		await press(JOY_BUTTON_START)
		check(battle.suspended and control.menu_context == "pause", "Gameplay Start opens usable pause menu")
		glyphs()
		await capture("pause")
		if mode == "quit-pause":
			await quit_at(battle.presentation.quit_button)
			return
		await activate(battle.presentation.settings_button)
		check(control.menu_context == "settings", "Pause Settings opens: " + control.menu_context)
		await capture("pause-settings")
		await activate(battle.presentation.settings_content.get_node("%Credits Button"))
		check(control.menu_context == "credits", "Pause Credits opens: " + control.menu_context)
		await press(JOY_BUTTON_B)
		check(control.menu_context == "settings" and battle.suspended, "Credits returns to paused settings")
		await press(JOY_BUTTON_B)
		check(control.menu_context == "pause", "Settings Back returns to pause")
		await press(JOY_BUTTON_B)
		check(not battle.suspended and cursor._gameplay_pointer_hidden, "Pause Back resumes gameplay")
		control._connection_changed(0, false)
		await settle()
		check(battle.suspended and control.event_axes.is_empty(), "Controller disconnect pauses combat and clears held axes")
		await press(JOY_BUTTON_START)
		battle._finish(false)
		await settle()
		check(control.menu_context == "results" and battle.presentation.results_input_locked and battle.presentation.choice_countdown.visible, "Controller defeat starts a visible one-second choice countdown")
		check(battle.retry.disabled and battle.presentation.upgrades_button.disabled, "Death choices cannot activate during countdown")
		var death_id: int = battle.get_instance_id()
		await press(JOY_BUTTON_A)
		await press(JOY_BUTTON_START)
		await press(JOY_BUTTON_B)
		check(is_instance_valid(battle) and battle.get_instance_id() == death_id and battle.ended, "Held gameplay buttons cannot select a death choice during countdown")
		await capture("death-countdown")
		await create_timer(1.1).timeout
		await settle()
		check(not battle.presentation.results_input_locked and not battle.presentation.choice_countdown.visible and not battle.retry.disabled, "Death choices unlock after countdown")
		check(root.gui_get_focus_owner() == null and cursor._virtual_cursor_active and battle.presentation.upgrades_button.get_global_rect().has_point(cursor.get_screen_position()), "Death cursor starts over Upgrades without controller focus navigation")
		glyphs()
		await capture("results")
		if mode == "quit-results":
			await quit_at(battle.presentation.quit_button)
			return
		await press(JOY_BUTTON_DPAD_DOWN)
		await press(JOY_BUTTON_START)
		await press(JOY_BUTTON_B)
		check(root.gui_get_focus_owner() == null and cursor._virtual_cursor_active and control.battle.get_instance_id() == death_id, "Death choices ignore D-pad and direct Start/Back shortcuts")
		await activate(battle.presentation.settings_button)
		await activate(battle.presentation.settings_content.get_node("%Credits Button"))
		await press(JOY_BUTTON_B)
		await press(JOY_BUTTON_B)
		check(control.menu_context == "results" and battle.ended, "Post-game settings Back restores results without resuming ended run")
		await activate(battle.presentation.tutorial_button)
		await press(JOY_BUTTON_B)
		check(control.menu_context == "results" and battle.ended, "Post-game tutorial Back restores results")
		var old_id: int = battle.get_instance_id()
		await activate(battle.retry)
		await settle(20)
		check(is_instance_valid(control.battle) and control.battle.get_instance_id() != old_id, "Death cursor selects Play Again and restarts the scene")
		battle = control.battle
		battle.persist_results = false
		battle.set_physics_process(false)
		battle._finish(true)
		await settle()
		check(control.menu_context == "results" and battle.retry.visible, "Victory/demo completion stays navigable")
		check(not demo or battle.data.demo_completed, "Demo completion state recorded")
		if demo:
			check(battle.presentation.results_input_locked and battle.presentation.wishlist_button.visible and battle.presentation.wishlist_button.disabled, "Demo completion shows a locked prominent Wishlist Now button")
			await press(JOY_BUTTON_START)
			await press(JOY_BUTTON_B)
			await create_timer(4.0).timeout
			check(is_instance_valid(battle) and battle.ended and battle.presentation.results_input_locked, "Demo completion blocks controller choices for at least five seconds")
			await capture("demo-complete-countdown")
			await create_timer(1.2).timeout
			await settle()
			check(not battle.presentation.results_input_locked and not battle.presentation.wishlist_button.disabled, "Demo completion choices unlock after five seconds")
		await press(JOY_BUTTON_B)
		if not await wait_owner("upgrades"): break
		screen = control.menu_owner
		check(not cursor._gameplay_pointer_hidden and cursor._scene_enabled, "Post-game Back reaches usable upgrade screen")
		battle = await new_battle_from_upgrades()
		if battle == null: break
		if battle.suspended: await press(JOY_BUTTON_START)
		await press(JOY_BUTTON_START)
		await activate(battle.presentation.upgrades_button)
		if not await wait_owner("upgrades"): break
		check(control.menu_context == "upgrades", "Pause End Run returns to upgrades")
		if not demo:
			data = Progress.load_data()
			data.unlocks.GodTab = true
			data.god_panel_unlocked = true
			Progress.save_data(data)
			current_scene.free()
			var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
			ending.persist_results = false
			root.add_child(ending)
			current_scene = ending
			await settle()
			check(control.menu_context == "ending" and root.gui_get_focus_owner() == ending.first_choice, "Ending choices establish focus")
			await focused_activate(ending.first_choice)
			check(ending.choice_made and root.gui_get_focus_owner() == ending.continue_button, "Ending choice transitions to focused main-menu action")
			await capture("ending")
			await press(JOY_BUTTON_B)
			if not await wait_owner("menu"): break
			if mode == "quit-ending":
				menu = control.menu_owner
				await press(JOY_BUTTON_B)
				await quit_at(menu.settings_quit_button)
				return
		else:
			screen = control.menu_owner
			await press(JOY_BUTTON_B)
			await activate(screen.settings_main_menu_button)
			if not await wait_owner("menu"): break
		check(control.menu_context == "menu", "Controller returns to launcher")
		current_scene.free()
		await settle()
	print("CONTROLLER FLOW %s: %d checks; %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
