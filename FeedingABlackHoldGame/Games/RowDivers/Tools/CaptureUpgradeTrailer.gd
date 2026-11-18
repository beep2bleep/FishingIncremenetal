extends SceneTree
## Run only from the isolated RailwayFuryTrailerReview project prepared by tools/railway_trailer.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const Pilot = preload("res://Games/RowDivers/Tools/TrailerPilot.gd")
var frame_index = 0
var markers: Array = []
var output = ""
func _initialize(): call_deferred("run")
func tick():
	for control in root.find_children("*", "OptionButton", true, false):
		if control.name in ["EditorArtStyle", "GothicUpgradeMusic", "GothicCombatMusic"]: control.hide()
	for label in root.find_children("*", "Label3D", true, false): label.hide()
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
	root.get_node("SaveHandler").damage_text = false
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
	await combat("01-level-1", opening, 0.0, 4.0)
	await shop("02-early-upgrade", opening, 2.0, "5932")
	var multi = make_data(1, true)
	await combat("03-level-2", multi, 30.0, 2.2)
	await shop("04-buy-multiple-arrows", multi, 2.0, "6721")
	assert(int(multi.stats.Amount_Of_Arrows) == 3)
	multi.prestige = 2
	multi.max_prestige = 2
	await combat("05-level-3-multiple-arrows", multi, 30.0, 5.0)
	await shop("06-buy-arrow-storm", multi, 2.0, "6388")
	multi.prestige = 3
	multi.max_prestige = 3
	await combat("07-level-4-finale", multi, 42.0, 5.0)
	var file = FileAccess.open(output + "/markers.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(markers, "\t"))
	print("REVIEW TRAILER COMPLETE: ", markers)
	quit()
func make_data(level: int, maxed: bool) -> Dictionary:
	var data = Progress.fresh()
	data.controls_seen = true
	data.prestige = level
	data.max_prestige = level
	if maxed:
		data.max_prestige = 3
		data.unlocks.GodTab = true
		data.wallet = [1e30,1e30,1e30]
		for pass_index in range(400):
			var changed = false
			for entry in Progress.design().upgrades:
				if entry.id not in ["6721", "6388"] and Progress.can_buy(data,entry):
					Progress.buy(data,entry)
					changed = true
			if not changed: break
	data.max_prestige = level
	data.wallet = [1850.0,24.0,0.0]
	return data
func visible_targets(battle) -> int:
	var count = 0
	for enemy in battle.enemies:
		if enemy.hp <= 0 or battle.camera.is_position_behind(enemy.node.position): continue
		var p = battle.camera.unproject_position(enemy.node.position)
		if Rect2(80,80,1760,900).has_point(p) and enemy.node.position.distance_to(battle.player_position) < 24: count += 1
	return count
func nearby_targets(battle, reach = 12.0) -> int:
	var count = 0
	for enemy in battle.enemies:
		if enemy.hp <= 0 or battle.camera.is_position_behind(enemy.node.position): continue
		var offset: Vector3 = enemy.node.position - battle.player_position
		if offset.z >= -0.5 or offset.length() > reach: continue
		var p = battle.camera.unproject_position(enemy.node.position)
		if Rect2(80,80,1760,900).has_point(p): count += 1
	return count
func close_combat_start(battle, pilot):
	# Capture fixture only: start seven metres behind a live group instead of
	# spending the shot travelling towards a distant silhouette.
	var best_score = -INF
	var front_z = 0.0
	var group_x = 0.0
	for candidate in battle.enemies:
		if candidate.hp <= 0 or candidate.node.position.z >= battle.player_position.z - 0.5: continue
		var count = 0
		var x = 0.0
		for enemy in battle.enemies:
			if enemy.hp > 0 and absf(enemy.node.position.z - candidate.node.position.z) < 5.0:
				count += 1
				x += enemy.node.position.x
		var score = count * 20.0 - absf(candidate.node.position.z - battle.player_position.z) * 0.1
		if score > best_score:
			best_score = score
			front_z = candidate.node.position.z
			group_x = x / maxf(1, count)
	assert(best_score > -INF)
	battle.player_position.z = front_z + 7.0
	battle.player_position.x = clampf(group_x, -1.0, 1.0)
	battle._update_camera_presentation()
	pilot.plan(battle)
	pilot.smooth_aim = pilot.desired_aim
	pilot.aim = pilot.desired_aim
	pilot.step(battle, 1.0/30.0)
	assert(nearby_targets(battle) > 0, "Closer capture must start in shooting range")
func combat(label: String, data: Dictionary, start_distance: float, seconds: float, boss = false):
	seed(211026 + markers.size())
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Tools/TrailerHalfDamageBattle.gd").new()
	battle.persist_results = false
	battle.outgoing_damage_scale = 0.25 if int(data.prestige) in [1,2] else 0.5
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	# Trailer-only clean view: tick hides world labels, including health and loot values.
	battle.presentation.root_ui.hide()
	var pilot = Pilot.new()
	pilot.setup(211026 + markers.size(), {"reaction":0.28,"aim_error":0.035})
	# Advance real simulation to this point in the same level, never spawn trailer enemies.
	for warmup in range(12000):
		if -battle.player_position.z >= start_distance and visible_targets(battle) > 0: break
		pilot.step(battle, 1.0/30.0)
		battle._physics_process(1.0/30.0)
		if battle.ended: break
	if int(data.prestige) in [1,2]: close_combat_start(battle, pilot)
	if boss:
		# The first miniboss occupies the normal fifth section, around 99 m.
		print("BOSS REVEAL at ", battle.player_position, " section=", battle.section)
	# Fast pre-roll advances simulation without audio time. Discard its queued
	# one-shots so they cannot all play together at the start of the recorded cut.
	for player in battle.audio.effects: player.stop()
	for settling in range(3): await tick()
	var marker = {"label":label,"start_frame":frame_index,"frames":int(seconds*30),"level":int(data.prestige)+1,"maxed_nodes":data.levels.size(),"arrows_per_shot":int(battle.s("Amount_Of_Arrows")),"visible_start":visible_targets(battle),"kills_start":battle.run_kills}
	marker.close_start = int(data.prestige) in [1,2]
	marker.player_start_z = battle.player_position.z
	marker.nearby_start = nearby_targets(battle)
	marker.aim_target = "visual_midsection"
	marker.battle_numbers_hidden = true
	marker.hud_hidden = not battle.presentation.root_ui.visible
	marker.outgoing_damage_scale = battle.outgoing_damage_scale
	var captured_hits_start = battle.captured_hits
	var empty_frames = 0
	var empty_streak = 0
	var longest_empty_streak = 0
	var out_of_range_frames = 0
	var out_of_range_streak = 0
	var longest_out_of_range = 0
	var hits_start = battle.fire_waves.hits
	var dodged_start = battle.fire_waves.dodged
	var gold_start: float = data.wallet[0]
	var fire_start = pilot.fire_decisions
	var loot_start = pilot.loot_decisions
	for f in range(int(seconds*30)):
		pilot.step(battle, 1.0/30.0)
		if boss: battle.fire_override = false
		battle._physics_process(1.0/30.0)
		if nearby_targets(battle) == 0:
			out_of_range_frames += 1
			out_of_range_streak += 1
			longest_out_of_range = maxi(longest_out_of_range, out_of_range_streak)
		else: out_of_range_streak = 0
		if visible_targets(battle) == 0:
			empty_frames += 1
			empty_streak += 1
			longest_empty_streak = maxi(longest_empty_streak, empty_streak)
		else: empty_streak = 0
		await tick()
	marker.out_of_range_frames = out_of_range_frames
	marker.longest_out_of_range_seconds = longest_out_of_range / 30.0
	marker.player_hits = battle.captured_hits - captured_hits_start
	marker.empty_combat_frames = empty_frames
	marker.longest_empty_seconds = longest_empty_streak / 30.0
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
class CapturePointer extends Node2D:
	var clicked = false
	func _draw():
		draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(2,29),Vector2(9,21),Vector2(16,33),Vector2(22,30),Vector2(15,18),Vector2(27,16)]), Color(0.03,0.04,0.06))
		draw_colored_polygon(PackedVector2Array([Vector2(3,4),Vector2(4,24),Vector2(10,17),Vector2(18,29),Vector2(19,28),Vector2(12,16),Vector2(22,15)]), Color.WHITE)
		if clicked: draw_arc(Vector2.ZERO, 26, 0, TAU, 40, Color(1,0.85,0.3), 3, true)
func shop(label: String, data: Dictionary, seconds: float, upgrade_id: String):
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
	tree.set_zoom(0.9)
	tree.set_debug_center_offset(Vector2.ZERO)
	var target
	for node in tree.node_dict.values():
		if node.upgrade != null and node.upgrade.sim_key == upgrade_id: target = node
	assert(target != null)
	tree.set_tech_tree_pos(-target.position + Vector2(-220, -40))
	for f in range(10): await tick()
	var layer = CanvasLayer.new()
	layer.layer = 120
	screen.add_child(layer)
	var pointer = CapturePointer.new()
	layer.add_child(pointer)
	var destination: Vector2 = target.click_mask.get_global_rect().get_center()
	var origin = destination + Vector2(210,130)
	var marker = {"label":label,"start_frame":frame_index,"frames":int(seconds*30),"purchases":[],"arrows_before":int(data.stats.Amount_Of_Arrows)}
	for f in range(int(seconds*30)):
		pointer.position = origin.lerp(destination, smoothstep(0.0, 1.0, minf(1.0, f/10.0)))
		Input.warp_mouse(pointer.position)
		if f == 12: target._on_click_mask_mouse_entered()
		if f == 30:
			assert(Progress.can_buy(data,Progress.find_upgrade(upgrade_id)))
			target._purchase_upgrade()
			marker.purchases.append(Progress.find_upgrade(upgrade_id).upgradeName)
		pointer.clicked = f >= 30 and f < 37
		pointer.queue_redraw()
		await tick()
	marker.arrows_after = int(data.stats.Amount_Of_Arrows)
	markers.append(marker)
	print("CLIP ",marker)
	screen.free()
