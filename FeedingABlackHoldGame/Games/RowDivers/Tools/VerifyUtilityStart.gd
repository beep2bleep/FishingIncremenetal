extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks := 0
var failures := 0
var control: Node

func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle(frames := 5) -> void:
	for i in range(frames): await process_frame
func press(index: int) -> void:
	for down in [true, false]:
		var event := InputEventJoypadButton.new()
		event.device = 0
		event.button_index = index
		event.pressed = down
		Input.parse_input_event(event)
		await settle(2)
	await settle()
func wait_context(context: String) -> bool:
	var until := Time.get_ticks_msec() + 15000
	while Time.get_ticks_msec() < until:
		await settle()
		if control.menu_context == context:
			if context == "upgrades" and control.menu_owner.tech_tree.build_in_progress: continue
			await settle(10)
			return true
	check(false, "Reaches " + context)
	return false
func capture(name: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	for picker in root.find_children("EditorArtStyle", "OptionButton", true, false): picker.get_parent().hide()
	await settle()
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Godot Projects/RailwayFury/FeedingABlackHoldGame/Games/RowDivers/Docs/Previews/release-0.13-" + name + ".png")
func run() -> void:
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		quit(2)
		return
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	for edition in ["full", "demo"]: ProjectSettings.set_setting("gameanalytics/railway_" + edition + "_game_key", "")
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	root.get_node("SaveHandler").local_settings_file_path = "user://utility_start_qa.json"
	TranslationServer.set_locale("en")
	control = root.get_node("RailwayController")
	for utility in control.UTILITY_BUTTONS:
		Progress.free_aim_mode = true
		Progress.active_data_cache = Progress.fresh()
		Progress.save_data(Progress.active_data_cache)
		var launcher = load("res://Core/Boot/GameLauncher.tscn").instantiate()
		root.add_child(launcher)
		current_scene = launcher
		await settle(20)
		root.get_node("ControllerIcons")._set_last_input_type(1,0)
		control.sync_menu()
		var launcher_glyphs = launcher.find_child("UtilityPlayGlyphs",true,false)
		check(launcher_glyphs != null and launcher_glyphs.visible and launcher_glyphs.get_child_count()==4,"Launcher displays four utility glyphs")
		var card = launcher.row_divers_free_aim_button
		check(card.get_meta("card_title_label").get_line_count()==1,"Play title remains on one line beside glyphs")
		check(card.get_meta("card_detail_label").get_global_rect().end.y <= card.get_global_rect().end.y,"Play instructions fit inside the card")
		await capture("menu")
		await press(utility)
		if not await wait_context("upgrades"): break
		var screen = control.menu_owner
		var glyphs = screen.go_again_button.get_parent().get_node("UtilityPlayGlyphs")
		check(glyphs.visible and glyphs.get_child_count()==4,"Upgrade Play displays four utility glyphs")
		check(glyphs.get_global_rect().end.x <= screen.go_again_button.get_global_rect().position.x,"Glyphs do not overlap Play")
		check(control.menu_hint.get_global_rect().end.x < glyphs.get_global_rect().position.x,"Footer does not overlap Play glyphs")
		check(root.gui_get_focus_owner()==null and root.get_node("VirtualCursor")._virtual_cursor_active,"Start shortcut preserves virtual cursor menus")
		await capture("upgrades")
		await press(utility)
		if not await wait_context("tutorial"): break
		var battle = control.battle
		battle.persist_results = false
		battle.set_physics_process(false)
		check(battle.fire_mode=="Auto" and battle.data.unlocks.Auto,"Battle starts with innate auto-fire")
		check(battle.presentation.tutorial_captions[1].text=="RIGHT STICK TO AIM — AUTO FIRE","Packaged controller tutorial teaches aim without trigger")
		await capture("tutorial")
		await press(utility)
		check(not battle.suspended,"Utility button dismisses tutorial")
		await press(utility)
		check(battle.suspended and control.menu_context=="pause","Utility button pauses gameplay")
		await press(utility)
		check(not battle.suspended,"Utility button resumes gameplay")
		battle.ended = true
		battle.presentation.show_results()
		await settle()
		var result_owner = control.menu_owner
		await press(utility)
		check(control.menu_owner==result_owner and battle.ended,"Utility buttons cannot skip result countdown")
		battle.free()
		current_scene = null
		await settle()
	print("UTILITY START: %d checks; %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
