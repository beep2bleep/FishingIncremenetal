extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Demo = preload("res://Games/RowDivers/RowDiversDemo.gd")
const Timing = preload("res://Games/RowDivers/RowDiversTiming.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Games/RowDivers/Translations/catalog.json"))
	check(catalog.size()==17, "All supported PC languages exist")
	var saves = root.get_node("SaveHandler")
	var web_locales: Dictionary = saves.available_locales(true)
	check(web_locales.size()==13, "Web pickers offer exactly the supported languages")
	for code in ["zh","ja","ko","th"]:
		check(not web_locales.has(code), "Unavailable web font language is hidden: "+code)
	check(saves.available_locales(false).size()==17, "PC retains every supported language")
	var results = "Distance %.1f m  |  Kills %d\nGold %s  |  Gems %s  |  Crowns %s\n\n%s"
	for locale in catalog:
		check(catalog[locale].has(results) and str(catalog[locale][results]).count("|")==3, "Plain result separators: "+locale)
	var fallback: FontFile = load("res://Theme/Fallbacks/NotoSans-Regular.ttf")
	check(fallback.has_char("Р".unicode_at(0)) and fallback.has_char("ấ".unicode_at(0)), "Bundled web fallback covers Russian and Vietnamese")
	var format := RegEx.create_from_string("%(?:[-+0#]*[0-9]*(?:\\.[0-9]+)?[sdfxX]|%)")
	var identifier := RegEx.create_from_string("^[A-Z0-9_]+$")
	for source in catalog.en:
		check(not ("_" in source and identifier.search(source)!=null), "Shared translation identifiers are not shadowed: "+source)
	for source in ["RAILWAY FURY · TRACK RUN TIMES","\n\n%s\nPaid with %s","%s ACTIVE", "RUN THE TRACKS", "MAGPIE", "ARROW STORM", "SHIELD", "REGEN", "[SPACE] ", "SPACE: Activate the highlighted power.\nEach press uses one ready power.", "Regenerates %.2f%% of maximum health per second (1.5x walking damage)."]:
		check(catalog.en.has(source), "Dynamic UI copy is covered: "+source)
	for locale in catalog:
		TranslationServer.set_locale(locale)
		check(catalog[locale].size()==catalog.en.size(), "Equal coverage: "+locale)
		for source in catalog[locale]:
			check(not str(catalog[locale][source]).is_empty(), "Nonempty: "+locale+" / "+source)
			var a = format.search_all(source).map(func(m):return m.get_string())
			var b = format.search_all(catalog[locale][source]).map(func(m):return m.get_string())
			check(a==b, "Format placeholders: "+locale+" / "+source)
		check(TranslationServer.translate("DEMO MODE")==catalog[locale]["DEMO MODE"], "Locale registered: "+locale)
	TranslationServer.set_locale("en")
	ProjectSettings.set_setting("railway_fury/demo/enabled", true)
	for free_aim in [false,true]:
		Progress.free_aim_mode = free_aim
		Progress.active_data_cache = {}
		var data = Progress.fresh()
		data.wallet = [1e15,1e15,1e15]
		data.controls_seen = true
		check(Progress.progress_path().ends_with("_demo.json"), "Demo save separated")
		for node in Progress.design().upgrades:
			if int(node.cost.currencyType)==2 or int(node.get("minPrestige",0))>0:
				check(not Progress.can_buy(data,node) and not Progress.buy(data,node), "Progression gate: "+node.id)
		for pass_index in range(20):
			for node in Progress.design().upgrades:
				if Progress.can_buy(data,node): Progress.buy(data,node)
		check(not Progress.unlock_final_chamber(data), "Ending cannot be opened in demo")
		data.prestige = 3
		data.max_prestige = 3
		Demo.constrain(data)
		check(data.prestige==0 and data.max_prestige==0, "Loaded demo cannot enter later levels")
		Progress.active_data_cache = data
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		battle.set_physics_process(false)
		battle.set_process(false)
		for enemy in battle.enemies: enemy.node.free()
		battle.enemies.clear()
		battle._spawn_enemy(battle.player_position+Vector3(0,0,-3),6)
		var boss: Dictionary = battle.enemies.back()
		battle._hit(boss,boss.hp+1)
		check(battle.ended and battle.victory and data.get("demo_completed",false), "First boss completes demo")
		check(data.max_prestige==0 and data.prestige==0 and battle.overlay_title.text=="DEMO COMPLETE", "Win cannot unlock level 2")
		check(not battle.presentation.overlay_detail.text.contains("Level 2 unlocked"), "Demo completion copy")
		check(Timing.configs().size()==1 and Timing.board_id("boss_0").contains("demo_"), "Demo leaderboard separated and capped")
		battle.free()
	ProjectSettings.set_setting("railway_fury/demo/enabled", false)
	Progress.active_data_cache = {}
	check(not Progress.progress_path().ends_with("_demo.json") and Timing.configs().size()==5, "Full game behavior restored")
	var full = Progress.fresh()
	full.max_prestige = 3
	Progress.active_data_cache = full
	Progress.cache_profile_path = Progress.progress_path()
	ProjectSettings.set_setting("railway_fury/demo/enabled", true)
	var demo = Progress.load_data()
	check(full.max_prestige==3 and demo.max_prestige==0, "Toggling demo never constrains the cached full campaign")
	ProjectSettings.set_setting("railway_fury/demo/enabled", false)
	Progress.active_data_cache = {}
	Progress.cache_profile_path = ""
	print("DEMO LOCALIZATION: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
