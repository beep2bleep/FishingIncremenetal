extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var failures := 0
var checks := 0
var clicks := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func axis(control, index: int, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = 0
	event.axis = index
	event.axis_value = value
	control._input(event)

func button(control, index: int, pressed := true) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = index
	event.pressed = pressed
	control._input(event)

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.get_node("Util").set_active_game_id("rowdivers")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	var control = root.get_node("RailwayController")
	var icons = root.get_node("ControllerIcons")
	var cursor = root.get_node("VirtualCursor")
	await process_frame
	for free_aim in [false, true]:
		Progress.free_aim_mode = free_aim
		Progress.active_data_cache = Progress.fresh()
		Progress.active_data_cache.controls_seen = true
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.data.unlocks.ArrowShield = true
		battle.data.unlocks.Harvester = true
		battle.suspended = false
		battle.fire_mode = "Click"
		battle.shot_timer = 0
		var count: int = battle.projectiles.size()
		axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.8)
		check(battle.projectiles.size() == count + 1, "Right trigger fires in both game modes")
		battle.shot_timer = 0
		axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.7)
		check(battle.projectiles.size() == count + 1, "Held trigger does not retrigger Click mode")
		axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.0)
		axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.8)
		check(battle.projectiles.size() == count + 2, "Trigger release rearms Click mode")
		axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.0)
		battle.shot_timer = 0
		button(control, JOY_BUTTON_RIGHT_SHOULDER)
		check(battle.projectiles.size() == count + 3, "Right bumper fires")
		axis(control, JOY_AXIS_TRIGGER_LEFT, 0.8)
		check(battle.active("ArrowShield"), "Left trigger uses first ready ability")
		axis(control, JOY_AXIS_TRIGGER_LEFT, 0.45)
		axis(control, JOY_AXIS_TRIGGER_LEFT, 0.6)
		check(not battle.active("Harvester"), "Trigger hysteresis prevents duplicate abilities")
		axis(control, JOY_AXIS_TRIGGER_LEFT, 0.0)
		button(control, JOY_BUTTON_LEFT_SHOULDER)
		check(battle.active("Harvester"), "Left bumper uses next ready ability")
		control.pointer = Vector2(320, 200)
		check(battle._aim_pointer() == control.pointer, "Aim reads controller pointer")
		check(battle._aim_direction().distance_to(battle.camera.project_ray_normal(control.pointer)) < 0.001, "Aim ray follows right-stick pointer")
		control.pointer = Vector2(-100, 99999)
		control.aim_pointer(0, Vector2(1280, 720))
		check(control.pointer == Vector2(12, 708), "Aim stays inside viewport")
		var running: bool = battle.running
		button(control, JOY_BUTTON_LEFT_STICK)
		check(battle.running != running, "Left stick click toggles running")
		button(control, JOY_BUTTON_START)
		check(battle.suspended and battle.overlay.visible, "Menu / Options pauses")
		var powers: int = battle.projectiles.size()
		battle._controller_action("fire")
		check(battle.projectiles.size() == powers, "Pause prevents gameplay firing")
		button(control, JOY_BUTTON_START)
		check(not battle.suspended, "Menu / Options resumes")
		check(not cursor._left_mouse_down, "Resume clears synthetic mouse hold")
		var motion := InputEventMouseMotion.new()
		motion.relative = Vector2(80, 50)
		icons._input(motion)
		check(not control.using_controller(), "Physical mouse returns keyboard glyphs")
		check(battle.presentation.power_hint.text.begins_with("SPACE"), "Tutorial changes back to keyboard prompts")
		button(control, JOY_BUTTON_LEFT_STICK)
		check(control.using_controller(), "Controller input restores controller glyphs")
		check(battle.presentation.power_hint.text.begins_with("Left trigger"), "Tutorial changes to controller prompts")
		for style in [ControllerSettings.Devices.XBOXONE, ControllerSettings.Devices.PS4, ControllerSettings.Devices.PS5]:
			for path in ["joypad/start", "joypad/rt", "joypad/rb", "joypad/lt", "joypad/lb", "joypad/l_stick", "joypad/r_stick"]:
				check(icons.parse_path(path, icons.InputType.CONTROLLER, 0, style) != null, "Xbox / PlayStation glyph exists: " + path)
		if free_aim and "--preview" in OS.get_cmdline_user_args():
			battle.presentation.show_tutorial()
			await create_timer(0.2).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/controller-tutorial.png")
		battle.free()
	cursor.set_scene_enabled(false)
	var confirm := Button.new()
	confirm.text = "BUY"
	root.add_child(confirm)
	confirm.pressed.connect(func(): clicks += 1)
	confirm.grab_focus()
	button(control, JOY_BUTTON_RIGHT_SHOULDER)
	check(clicks == 1, "Bumper activates focused menu / purchase button")
	axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.0)
	axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.9)
	check(clicks == 2, "Trigger activates focused menu / purchase button")
	confirm.disabled = true
	axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.0)
	axis(control, JOY_AXIS_TRIGGER_RIGHT, 0.9)
	check(clicks == 2, "Trigger respects disabled purchase button")
	confirm.free()
	var start := InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	check(start.is_action_pressed("go again"), "Menu / Options starts gameplay from upgrades")
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	space.pressed = true
	check(not space.is_action_pressed("go again"), "Space no longer starts gameplay")
	var enter := InputEventKey.new()
	enter.physical_keycode = KEY_ENTER
	enter.pressed = true
	check(enter.is_action_pressed("go again"), "Enter starts gameplay with keyboard")
	check(icons.Mapper._convert_joypad_to_ps4("joypad/start") == "ps4/options", "PlayStation shows Options")
	check(icons.Mapper._convert_joypad_to_xboxone("joypad/start") == "xboxone/menu", "Xbox shows Menu")
	print("CONTROLLER %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
