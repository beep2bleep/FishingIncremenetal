extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var Graphics: GDScript
var failures = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	print("PASS " if ok else "FAIL ", title)
	if not ok: failures += 1
func capture(name: String) -> void:
	if "--preview" not in OS.get_cmdline_user_args(): return
	for i in range(12): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/gothic-" + name + ".png")

func capture_enemy_gallery() -> void:
	if "--preview" not in OS.get_cmdline_user_args(): return
	var layer := CanvasLayer.new()
	layer.layer = 200
	root.add_child(layer)
	var background := ColorRect.new()
	background.color = Color("17151b")
	background.size = Vector2(1920, 1200)
	layer.add_child(background)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.position = Vector2(40, 25)
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 15)
	layer.add_child(grid)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Games/RowDivers/Art/Gothic/painted-enemies.json"))
	for entry in catalog.enemies:
		var card := VBoxContainer.new()
		grid.add_child(card)
		var portrait := TextureRect.new()
		portrait.texture = load("res://Games/RowDivers/Art/Gothic/" + str(entry.file))
		portrait.custom_minimum_size = Vector2(440, 515)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(portrait)
		var caption := Label.new()
		caption.text = entry.name
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size", 24)
		card.add_child(caption)
	await capture("enemy-gallery")
	layer.free()
func run() -> void:
	Graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	root.size = Vector2i(1440, 900)
	root.content_scale_size = Vector2i(1920, 1200)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("SaveHandler").local_settings_file_path = "user://gothic_verification_settings.json"
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	Graphics.select_mode(3)
	var dark = load("res://Games/RowDivers/RowDiversGothic.gd")
	for entry in Progress.design().upgrades:
		check(load(dark.icon(entry)) != null, "Upgrade catalog symbol loads: " + str(entry.id))
	dark.texture_path("Enemy1.png")
	for source in dark.manifest.textures:
		check(Graphics.texture(source) != null, "Gothic replacement loads: " + source)
	for source in Graphics.ENEMIES + ["Bat.png"]:
		check(dark.texture_path(source).ends_with("_painted.png"), "Painted enemy replacement is active: " + source)
	var data := Progress.fresh()
	data.controls_seen = true
	data.unlocks = {"Bow": true, "Dagger": true, "Harvester": true, "ArrowShield": true, "Shuriken": true, "SlowDown": true}
	data.wallet = [100000.0, 10000.0, 100.0]
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	battle.set_process(false)
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	for i in range(8): battle._spawn_enemy(Vector3((i%3-1)*.65, .67 if i != 7 else 1.4, -4.2-float(i/3)*3.6), i, i==6)
	await process_frame
	var state_before := JSON.stringify(data)
	seed(194)
	var expected := randf()
	seed(194)
	dark.splatter(battle, Vector3(0,.67,-3), true)
	check(randf() == expected, "Blood effects preserve gameplay RNG")
	for mode in [3, 2, 1, 0, 3]:
		Graphics.select_mode(mode)
		root.get_node("SignalBus").settings_updated.emit()
		await process_frame
		check(Graphics.mode() == mode, "Live style switch: " + str(mode))
	check(JSON.stringify(data) == state_before, "Art switching preserves progression and combat data")
	check(battle.enemies.size() == 8, "All enemy types survive live switching")
	await capture("battle")
	await capture_enemy_gallery()
	battle.free()
	data.max_prestige = 3
	for pass_index in range(12):
		for entry in Progress.design().upgrades:
			if Progress.can_buy(data, entry): Progress.buy(data, entry)
	Progress.active_data_cache = data
	var global = root.get_node("Global")
	global.current_game_mode_data = null
	global.ensure_default_game_mode_data()
	global.new_game()
	global.start_in_upgrade_scene = true
	var screen = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	screen.setup()
	screen.show_screen()
	for i in range(30): await process_frame
	screen.tech_tree.set_zoom(.65)
	for upgrade in global.game_mode_data_manager.upgrades.values():
		check(upgrade.sim_icon.begins_with(dark.ROOT), "Dark upgrade symbol: " + upgrade.sim_key)
	var control = screen.get_node("RuntimeArtStyle")
	check(control.flag != null and control.flag.visible, "Pixel flag background is active")
	await capture("upgrades")
	control.art_style = 2
	await process_frame
	await process_frame
	check(Graphics.mode() == 2 and not control.flag.visible, "Remote inspector option restores existing style")
	for upgrade in global.game_mode_data_manager.upgrades.values():
		check(not upgrade.sim_icon.begins_with(dark.ROOT), "Previous upgrade symbol restored: " + upgrade.sim_key)
	screen.free()
	print("GOTHIC PRESENTATION: ", failures, " failures")
	quit(0 if failures == 0 else 1)
