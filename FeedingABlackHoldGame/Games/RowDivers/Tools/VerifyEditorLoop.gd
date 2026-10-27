extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Loop = preload("res://Games/RowDivers/RowDiversEditorLoop.gd")
var checks = {}

func _initialize(): call_deferred("run")
func run():
	var Battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	root.get_node("Util").set_active_game_id("rowdivers")
	Progress.free_aim_mode = true
	Battle.debug_speed = 1
	Loop.stop()
	var data = Progress.fresh()
	data.wallet = [12.0,0.0,0.0]
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.current_game_mode_data = load("res://Game Modes/Main Mode.tres")
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	screen.set_script(load("res://Games/RowDivers/Tools/EditorLoopScreenFixture.gd"))
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	await process_frame
	screen.row_divers_editor_buyer.persist_results = false
	screen.row_divers_editor_buyer.max_purchases = 1
	await screen._run_row_divers_auto_buy()
	checks.manual_buys_and_arms = Loop.armed() and not Progress.active_data_cache.levels.is_empty()
	checks.manual_speed_waits = screen.launches==0
	checks.four_x_waits = not Loop.active(4)
	checks.eight_x_loops = Loop.active(8)
	Battle.debug_speed = 8
	data = Progress.active_data_cache
	data.max_prestige = 1
	data.wallet = [0.0,0.0,1.0]
	await screen._run_row_divers_auto_buy(true)
	checks.advances_prestige = Progress.active_data_cache.prestige==1
	checks.starts_even_without_purchase = screen.launches==1
	await screen._run_row_divers_auto_buy(true)
	checks.repeats_shopping_and_launch = screen.launches==2
	var before = Progress.active_data_cache.duplicate(true)
	var pending = screen._run_row_divers_auto_buy.bind(true)
	create_timer(.01).timeout.connect(func(): screen._run_row_divers_auto_buy())
	await pending.call()
	checks.cancel_stops_loop = not Loop.armed() and screen.launches==2
	checks.cancel_preserves_progress = Progress.active_data_cache==before
	Loop.arm()
	data = Progress.active_data_cache
	data.unlocks.GodTab = true
	data.wallet = [200000.0,10.0,4.0]
	screen._start_row_divers_auto_run()
	checks.stops_at_ending_choice = not Loop.armed() and screen.endings==1 and screen.launches==2
	checks.chamber_probe_does_not_spend = data.wallet==[200000.0,10.0,4.0]
	screen.free()
	data = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Tools/EditorLoopBattleFixture.gd").new()
	battle.persist_results = false
	Loop.arm()
	root.add_child(battle)
	current_scene = battle
	battle.set_process(false)
	battle.set_physics_process(false)
	battle._finish(false)
	battle._finish(false)
	checks.run_banked_once = data.runs==1
	await battle._auto_return_to_upgrades()
	checks.returns_after_finished_run = battle.returns==1
	create_timer(.1).timeout.connect(func(): battle.set_debug_speed(4))
	await battle._auto_return_to_upgrades()
	checks.lowering_speed_cancels_return = battle.returns==1 and not Loop.armed()
	battle.set_debug_speed(8)
	Loop.arm()
	create_timer(.1).timeout.connect(func(): Loop.stop(); Loop.arm())
	await battle._auto_return_to_upgrades()
	checks.stale_return_cancelled = battle.returns==1
	Progress.free_aim_mode = false
	checks.other_profile_cannot_loop = not Loop.active(8)
	Progress.free_aim_mode = true
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	checks.disabled_cheats_cannot_loop = not Loop.active(8)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",true)
	Loop.stop()
	Battle.debug_speed = 1
	battle.free()
	var passed = checks.values().all(func(v):return v)
	print("EDITOR AUTO LOOP: ", checks.size(), " checks passed=", passed, " ", checks)
	quit(0 if passed else 1)
