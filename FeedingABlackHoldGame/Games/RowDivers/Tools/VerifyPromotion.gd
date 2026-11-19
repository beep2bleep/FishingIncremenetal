extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Promotion = preload("res://Games/RowDivers/RowDiversPromotion.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle(frames = 10):
	for i in range(frames): await process_frame
func prepare():
	Progress.free_aim_mode = true
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	Progress.cache_profile_path = Progress.progress_path()
func run():
	if not OS.get_user_data_dir().ends_with("RailwayFuryControllerQA"):
		quit(2)
		return
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("GameAnalytics")._enabled = false
	root.get_node("GameAnalytics")._pending.clear()
	root.get_node("SaveHandler").local_settings_file_path = "user://promotion_qa_settings.json"
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats",false)
	TranslationServer.set_locale("en")
	for demo in ([true] if OS.has_feature("railway_demo") else [false,true]):
		ProjectSettings.set_setting("railway_fury/demo/enabled",demo)
		prepare()
		var data = Progress.active_data_cache
		Progress.save_data(data)
		data.promotion_play_seconds = 1199.99
		check(not Promotion.visit_upgrades(),"No early promotion")
		check(int(data.get("promotion_upgrade_visits",0)) == 0,"Early visits do not advance cadence")
		data.promotion_play_seconds = 1200.0
		for visit in range(1,10): check(Promotion.visit_upgrades() == (demo and visit % 3 == 0),"Promotion cadence visit "+str(visit))
		Progress.active_data_cache = {}
		check(int(Progress.load_data().get("promotion_upgrade_visits",0)) == (9 if demo else 0),"Cadence survives reload")
		var menu = load("res://Core/Boot/GameLauncher.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		await settle(20)
		check(menu.find_child("PlayMyOtherGames",true,false)==null,"No start menu promotion")
		menu.free()
		var global = root.get_node("Global")
		global.current_game_mode_data = null
		global.ensure_default_game_mode_data()
		global.new_game()
		global.start_in_upgrade_scene = true
		prepare()
		data = Progress.active_data_cache
		var screen = load("res://UpgradeScreen.tscn").instantiate()
		root.add_child(screen)
		current_scene = screen
		screen.setup()
		screen.show_screen()
		await settle(20)
		check(screen.find_child("PlayMyOtherGames",true,false)==null,"No upgrade promotion before threshold")
		data.promotion_play_seconds = 1200.0
		for visit in range(1,5):
			screen.hide_screen()
			screen.show_screen()
			await settle(3)
			var promo = screen.find_child("PlayMyOtherGames",true,false)
			check((promo!=null)==(demo and visit==3),"Actual upgrade screen visit "+str(visit))
			if promo!=null:
				check(promo.fade_after_delay,"Upgrade promotion retains fade")
				screen.show_screen()
				check(int(data.promotion_upgrade_visits)==3,"Already-open screen does not count twice")
				await create_timer(6.2).timeout
				check(not promo.visible and promo.disabled and promo.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Faded promotion cannot intercept cursor")
		screen.free()
		prepare()
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		battle.persist_results = true
		battle.running = true
		battle._physics_process(0.5)
		check(is_equal_approx(float(battle.data.promotion_play_seconds),0.5),"Double speed counts real active time once")
		battle.suspended = true
		battle._physics_process(0.5)
		check(is_equal_approx(float(battle.data.promotion_play_seconds),0.5),"Pause does not count")
		battle.persist_results = false
		battle._finish(true)
		await settle(15)
		var promo = battle.presentation.other_games_button
		check((promo!=null)==demo,"Full game never constructs completion promotion")
		if demo:
			check(promo.visible and promo.disabled,"Demo completion promotion respects countdown")
			check(not promo.get_global_rect().intersects(battle.presentation.wishlist_button.get_global_rect()),"Wishlist and promotion do not overlap")
			await create_timer(5.1).timeout
			await settle()
			check(not promo.disabled and not battle.presentation.results_input_locked,"Completion actions unlock after countdown")
			if "--capture" in OS.get_cmdline_user_args():
				# Editor engine exposes authoring widgets even when running a PCK.
				for picker in root.find_children("EditorArtStyle", "OptionButton", true, false): picker.get_parent().hide()
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("C:/Godot Projects/RailwayFury/FeedingABlackHoldGame/Games/RowDivers/Docs/Previews/release-0.10-demo-complete.png")
			battle.presentation.show_settings()
			check(not promo.visible,"Settings hides completion promotion")
			battle.presentation.show_results()
			battle.presentation.show_tutorial()
			check(not promo.visible,"Tutorial hides completion promotion")
		battle.free()
	print("PROMOTION: %d checks; %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
