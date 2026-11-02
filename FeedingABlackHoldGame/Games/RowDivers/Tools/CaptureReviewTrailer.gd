extends SceneTree
## Run only from the isolated RailwayFuryTrailerReview project prepared by tools/railway_trailer.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Pilot = preload("res://Games/RowDivers/Tools/TrailerPilot.gd")
var frame_index = 0
var markers: Array = []
var output = ""
func _initialize(): call_deferred("run")
func tick():
	frame_index += 1
	await process_frame
func run():
	assert(OS.get_user_data_dir().contains("RailwayFuryTrailerReview"), "Use the isolated capture project")
	output = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1920,1080)
	root.content_scale_size = root.size
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.get_node("Util").set_active_game_id("rowdivers")
	root.get_node("SteamHandler").steam_enabled = false
	root.get_node("SaveHandler").damage_text = true
	ProjectSettings.set_setting("railway_fury/demo/enabled", false)
	ProjectSettings.set_setting("global/Demo", false)
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	TranslationServer.set_locale("en")
	Progress.free_aim_mode = true
	Progress.tree_selected = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -6)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), 0)
	var opening = make_data(0, false)
	await combat("01-opening-combat", opening, 0.0, 8.0)
	await shop("02-buy-upgrades", opening, 3.0)
	var later = make_data(0, true)
	later.max_prestige = 0
	await combat("03-level-1-later", later, 38.0, 6.0)
	await shop("04-back-to-upgrades", opening, 2.0)
	await combat("05-distant-boss", later, 79.0, 5.0, true)
	await combat("06-level-3-maxed", make_data(2, true), 30.0, 3.0)
	await combat("07-level-4-maxed", make_data(3, true), 42.0, 3.0)
	await combat("08-level-3-maxed", make_data(2, true), 65.0, 3.0)
	await combat("09-level-4-finale", make_data(3, true), 70.0, 3.0)
	var file = FileAccess.open(output + "/markers.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(markers, "\t"))
	print("REVIEW TRAILER COMPLETE: ", markers)
	quit()
func make_data(level: int, maxed: bool) -> Dictionary:
	var data = Progress.fresh()
	data.controls_seen = true
	data.prestige = level
	data.max_prestige = 3 if maxed and level > 0 else level
	if maxed:
		data.unlocks.GodTab = true
		data.wallet = [1e30,1e30,1e30]
		for pass_index in range(400):
			var changed = false
			for entry in Progress.design().upgrades:
				if Progress.can_buy(data,entry):
					Progress.buy(data,entry)
					changed = true
			if not changed: break
	data.wallet = [1850.0,24.0,0.0]
	return data
func visible_targets(battle) -> int:
	var count = 0
	for enemy in battle.enemies:
		if enemy.hp <= 0 or battle.camera.is_position_behind(enemy.node.position): continue
		var p = battle.camera.unproject_position(enemy.node.position)
		if Rect2(80,80,1760,900).has_point(p) and enemy.node.position.distance_to(battle.player_position) < 24: count += 1
	return count
func combat(label: String, data: Dictionary, start_distance: float, seconds: float, boss = false):
	seed(211026 + markers.size())
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	# Trailer-only clean view. Enemy health and damage are Label3D nodes in
	# the world, so hiding the screen-space HUD preserves both.
	battle.presentation.root_ui.hide()
	var pilot = Pilot.new()
	pilot.setup(211026 + markers.size(), {"reaction":0.28,"aim_error":0.035})
	# Advance real simulation to this point in the same level, never spawn trailer enemies.
	for warmup in range(12000):
		if -battle.player_position.z >= start_distance and visible_targets(battle) > 0: break
		pilot.step(battle, 1.0/30.0)
		battle._physics_process(1.0/30.0)
		if battle.ended: break
	if boss:
		# The first miniboss occupies the normal fifth section, around 99 m.
		print("BOSS REVEAL at ", battle.player_position, " section=", battle.section)
	# Fast pre-roll advances simulation without audio time. Discard its queued
	# one-shots so they cannot all play together at the start of the recorded cut.
	for player in battle.audio.effects: player.stop()
	for settling in range(3): await tick()
	var marker = {"label":label,"start_frame":frame_index,"frames":int(seconds*30),"level":int(data.prestige)+1,"maxed_nodes":data.levels.size(),"visible_start":visible_targets(battle),"kills_start":battle.run_kills}
	marker.hud_hidden = not battle.presentation.root_ui.visible
	var hits_start = battle.fire_waves.hits
	var dodged_start = battle.fire_waves.dodged
	var gold_start: float = data.wallet[0]
	var fire_start = pilot.fire_decisions
	var loot_start = pilot.loot_decisions
	for f in range(int(seconds*30)):
		pilot.step(battle, 1.0/30.0)
		if boss: battle.fire_override = false
		battle._physics_process(1.0/30.0)
		await tick()
	marker.kills_end = battle.run_kills
	marker.ended = battle.ended
	marker.fire_hits = battle.fire_waves.hits-hits_start
	marker.fire_dodges = battle.fire_waves.dodged-dodged_start
	marker.gold_collected = data.wallet[0]-gold_start
	marker.fire_steering_decisions = pilot.fire_decisions-fire_start
	marker.loot_steering_decisions = pilot.loot_decisions-loot_start
	assert(not battle.ended, "Rejected ended run: " + label)
	assert(int(marker.visible_start) > 0, "Rejected empty combat cut: " + label)
	markers.append(marker)
	print("CLIP ", marker)
	battle.free()
func shop(label: String, data: Dictionary, seconds: float):
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
	for f in range(45): await tick()
	for key in ["row_divers_auto_buy_button","row_divers_color_button","editor_exit_demo_button","editor_demo_toggle_button"]:
		var control = screen.get(key)
		if control is Control: control.hide()
	var promo = screen.get_node_or_null("CanvasLayer2/PlayMyOtherGames")
	if promo != null: promo.hide()
	var tree = screen.tech_tree
	tree.set_zoom(0.65)
	tree.set_debug_center_offset(Vector2(150,-35))
	var marker = {"label":label,"start_frame":frame_index,"frames":int(seconds*30),"purchases":[]}
	for f in range(int(seconds*30)):
		if f in [12,36,60]:
			for node in tree.node_dict.values():
				if node.upgrade == null or node.upgrade.sim_key.is_empty(): continue
				var entry = Progress.find_upgrade(node.upgrade.sim_key)
				if not Progress.can_buy(data,entry): continue
				tree.set_tech_tree_pos(-node.position + Vector2(0,100))
				# Exercise the same purchase handler used by a click, including feedback and SFX.
				node._purchase_upgrade()
				marker.purchases.append(entry.upgradeName)
				break
		await tick()
	markers.append(marker)
	print("CLIP ",marker)
	screen.free()
