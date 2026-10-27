extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUTPUT = "res://Games/RowDivers/Docs/Previews/"
var failures = 0
var checks = 0

func _initialize(): call_deferred("run")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func capture(filename: String):
	for frame in range(20): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT+filename+".png")

func run():
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	var save = root.get_node("SaveHandler")
	save.local_settings_file_path = "user://railway_menu_fixture_settings.json"
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	var menu = load("res://Core/Boot/GameLauncher.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	for frame in range(20): await process_frame
	check(Progress.free_aim_mode, "Menu selects the existing Free Aim save profile")
	check(menu.row_divers_button == null and menu.game_cards_grid.get_children().filter(func(c):return c.visible).size()==1, "One play option")
	check(menu.row_divers_free_aim_button.get_meta("card_title_label").text=="RAILWAY FURY", "Railway Fury branding")
	check(menu.get_node("RailwayVersion").text == "v0.1", "Main menu shows release version")
	var promo = menu.find_child("PlayMyOtherGames",true,false)
	check(promo != null and promo.FRANCHISE_URL=="https://store.steampowered.com/franchise/Beep2Bleep", "Franchise action")
	check(promo.capsules.size()==2, "Main menu shows two capsules")
	var names = {}
	for i in range(3):
		for title in promo.game_title.text.split("\n"): names[title] = true
		check(promo.capsules[0].texture != promo.capsules[1].texture, "Pair contains two different games")
		promo.advance()
	check(names.size()==6 and not names.has("Only Jump!") and not names.has("Umpire Simulator"), "Three pairs rotate through all eligible games")
	check(promo.heading.text=="Play my other games", "Requested button text")
	var settings = menu.settings_content
	check(settings.find_child("OriginalRowDiversGraphics",true,false)==null, "No art style selector")
	check(settings.find_child("RowDiversUpgradeTree",true,false)==null, "No tree selector in Railway Fury")
	var capture_enabled = "--capture" in OS.get_cmdline_user_args()
	if capture_enabled:
		await capture("railway_single_menu")
		menu._on_settings_button_pressed()
		await capture("railway_simple_settings")
	menu.free()
	var global = root.get_node("Global")
	global.current_game_mode_data = null
	global.ensure_default_game_mode_data()
	global.new_game()
	global.start_in_upgrade_scene = true
	Progress.active_data_cache = Progress.fresh()
	Progress.active_data_cache.controls_seen = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for frame in range(60): await process_frame
	var upgrade_promo = screen.find_child("PlayMyOtherGames",true,false)
	check(upgrade_promo != null and upgrade_promo.capsules.size()==1, "Upgrade screen shows one capsule")
	check(upgrade_promo.capsule_size.x>promo_size().x, "Upgrade capsule is larger than main menu capsule")
	check(upgrade_promo.heading.get_global_rect().end.y<=upgrade_promo.capsule.get_global_rect().position.y, "Title is above upgrade capsule")
	check(not upgrade_promo.get_global_rect().intersects(screen.go_again_button.get_global_rect()), "Promo does not overlap Play")
	if capture_enabled:
		screen.tech_tree.set_zoom(0.55)
		screen.tech_tree.recenter_on_core()
		await capture("railway_upgrade_other_games")
	screen.free()
	print("RAILWAY MENU: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)

func promo_size() -> Vector2:
	return Vector2(246,115)
