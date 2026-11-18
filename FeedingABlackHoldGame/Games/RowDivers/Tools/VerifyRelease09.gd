extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Analytics = preload("res://Games/RowDivers/RowDiversAnalytics.gd")
var checks := 0
var failures := 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle():
	for i in range(8): await process_frame
func pad(button: int):
	for down in [true,false]:
		var event = InputEventJoypadButton.new()
		event.device = 0
		event.button_index = button
		event.pressed = down
		Input.parse_input_event(event)
		await settle()
func verify_pointer(context: String):
	var controller = root.get_node("RailwayController")
	controller.sync_menu()
	await settle()
	var cursor = root.get_node("VirtualCursor")
	check(controller.menu_state.get("cursor_only",false), context+" uses cursor")
	check(cursor._virtual_cursor_active and not cursor._gameplay_pointer_hidden, context+" cursor visible")
	check(root.gui_get_focus_owner()==null, context+" has no focus selection")
	var surface = controller.menu_surface
	for button in [JOY_BUTTON_DPAD_DOWN,JOY_BUTTON_DPAD_RIGHT,JOY_BUTTON_B,JOY_BUTTON_START,JOY_BUTTON_Y]:
		await pad(button)
		check(cursor._virtual_cursor_active and root.gui_get_focus_owner()==null and controller.menu_surface==surface, context+" shortcut cannot select/change mode")
func click_control(control: Control):
	root.get_node("VirtualCursor").move_to_control(control)
	await settle()
	print("CLICK ",control.name," rect=",control.get_global_rect()," cursor=",root.get_node("VirtualCursor")._cursor_position," hovered=",root.gui_get_hovered_control()," active=",root.get_node("VirtualCursor")._virtual_cursor_active)
	await pad(JOY_BUTTON_A)
	await settle()
func run():
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		push_error("Release09 fixture refuses player saves")
		quit(2)
		return
	root.get_node("Util").set_active_game_id("rowdivers")
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("SteamHandler").steam_enabled = false
	var original = root.get_node("GameAnalytics")
	original._enabled = false
	original._pending.clear()
	original.name = "ProductionGameAnalytics"
	var capture = load(get_script().resource_path.get_base_dir().path_join("AnalyticsCapture.gd")).new()
	capture.name = "GameAnalytics"
	root.add_child(capture)
	capture._enabled = true
	Progress.free_aim_mode = true
	var data = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	Progress.cache_profile_path = Progress.progress_path()
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.persist_results = true
	battle.section = 7
	battle.distance = 105.5
	battle.player_position.z = -105.5
	battle.elapsed = 90.25
	battle.run_kills = 23
	battle.analytics_attempt = 4
	for outcome in ["start","checkpoint","heartbeat","death","complete","abandoned"]: Analytics.run_event(battle,outcome)
	var design = capture.events.filter(func(e):return e.category=="design")
	check(design.size()==6,"Per-run events cover start/checkpoint/heartbeat/death/complete/abandon")
	check(design[1].event_id=="railway_fury:section_reached:07", "Section funnel event")
	check(design.all(func(e):return e.custom_fields.section==7 and e.custom_fields.distance_m==105.5 and e.custom_fields.attempt==4 and e.custom_fields.kills==23),"Exact distance/section/attempt/kills attached")
	check(design[3].custom_fields.cause=="the railway" and design[0].custom_fields.run_seconds==90.3,"Death cause and run time attached")
	check(capture.events.filter(func(e):return e.category=="progression").size()==4,"Progression start/complete/fail events")
	battle.persist_results = false
	var size_before = capture.events.size()
	Analytics.run_event(battle,"death")
	check(capture.events.size()==size_before,"Previews never emit analytics")
	if not OS.has_feature("railway_demo"):
		ProjectSettings.set_setting("railway_fury/demo/enabled",false)
		Analytics.started(data,true,"rebalanced")
		ProjectSettings.set_setting("railway_fury/demo/enabled",true)
		Analytics.started(data,true,"rebalanced")
		check(data.has("analytics_milestones_demo") and data.has("analytics_milestones_full"),"Shared saves retain separate edition funnels")
	root.get_node("ControllerIcons")._set_last_input_type(1,0)
	battle.suspended = true
	battle.presentation.pause()
	await verify_pointer("Pause")
	await click_control(battle.presentation.settings_button)
	check(battle.presentation.settings_panel.visible,"Cursor A opens settings")
	await verify_pointer("Settings")
	battle.presentation.settings_content._on_credits_button_pressed()
	await verify_pointer("Credits")
	battle.presentation.settings_content._on_hide_credits_pressed()
	await click_control(battle.presentation.settings_back_button)
	check(not battle.presentation.settings_panel.visible,"Cursor A closes settings")
	battle.presentation.show_tutorial()
	await verify_pointer("Tutorial")
	await click_control(battle.resume)
	check(not battle.suspended and not battle.overlay.visible,"Cursor A leaves tutorial and resumes gameplay")
	battle.ended = true
	battle.victory = true
	battle.presentation.show_results("DEMO COMPLETE","Fixture")
	check(battle.presentation.results_input_locked,"Demo completion has five-second lock")
	await create_timer(5.1).timeout
	await verify_pointer("Demo victory")
	check(root.get_node("VirtualCursor")._cursor_position.distance_to(battle.presentation.wishlist_button.get_global_rect().get_center())<5,"Demo victory defaults to Wishlist cursor")
	battle.free()
	print("RELEASE09: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
