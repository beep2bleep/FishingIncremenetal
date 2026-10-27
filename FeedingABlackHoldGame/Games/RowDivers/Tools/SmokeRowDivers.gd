extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var checks = 0
var failures = 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var Battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd")
	var battle = Battle.new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.data = Progress.fresh()
	battle.presentation.refresh()
	check(battle.presentation.ability_columns.values().all(func(column): return not column.visible), "Fresh run hides all unpurchased ability cards")
	battle.data.unlocks.Harvester = true
	battle.presentation.refresh()
	check(battle.presentation.ability_columns.Harvester.visible and not battle.presentation.ability_columns.ArrowShield.visible, "Only purchased ability cards appear")
	battle.health = 100
	battle.armor = 0
	battle.suspended = false
	battle.next_section_trigger = 1000
	for enemy in battle.enemies: enemy.node.queue_free()
	battle.enemies.clear()
	check(battle.presentation.root_ui.has_node("TEMP_CHEATS_REMOVE_BEFORE_RELEASE"), "Debug build shows conspicuous temporary speed buttons")
	var starting_position: Vector3 = battle.player_position
	battle.set_debug_speed(8)
	var next_dive = Battle.new()
	check(next_dive.debug_speed == 8, "Next dive inherits gameplay speed from memory")
	next_dive.free()
	for i in range(15): battle._physics_process(1.0 / 60.0)
	check(absf(battle.elapsed - 2.0) < 0.001 and absf(battle.distance - 2.6) < 0.001, "8x cheat advances eight normal simulation steps per frame")
	check(is_equal_approx(battle.health, 95.0), "Speed cheat accelerates normal row damage with movement")
	battle.suspended = true
	battle._physics_process(1.0)
	check(absf(battle.elapsed - 2.0) < 0.001, "Pause still freezes an accelerated run")
	battle.suspended = false
	var reset_speed := InputEventKey.new()
	reset_speed.keycode = KEY_F8
	reset_speed.pressed = true
	battle._unhandled_input(reset_speed)
	check(battle.debug_speed == 1, "F8 immediately restores normal speed")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", false)
	battle.set_debug_speed(8)
	check(battle.debug_speed == 1, "Shipping toggle disables accelerated simulation")
	ProjectSettings.set_setting("railway_fury/debug/enable_speed_cheats", true)
	for multiplier in [4, 8, 16, 32]:
		battle.set_debug_speed(multiplier)
		check(battle.presentation.debug_speed_buttons.has(multiplier), "%dx has a speed button" % multiplier)
		var elapsed_before: float = battle.elapsed
		battle._physics_process(1.0 / 60.0)
		check(absf(battle.elapsed - elapsed_before - multiplier / 60.0) < 0.001, "%dx advances the requested number of simulation steps" % multiplier)
		battle._spawn_enemy(battle.player_position + Vector3(1, -0.23, -3), 0)
		var aimed_enemy = battle.enemies.back()
		aimed_enemy.hp = 100
		battle._spawn_enemy(battle.player_position + Vector3(-1, -0.23, -5), 0)
		check(battle._target(10).node == aimed_enemy.node, "%dx targets the closest enemy across lanes" % multiplier)
		var lateral_position: float = battle.player_position.x
		battle.shot_timer = 0
		battle._simulate_step(1.0 / 60.0)
		check(not battle.projectiles.is_empty() and battle.projectiles[0].dir.x > 0, "%dx automatically fires toward an off-axis enemy" % multiplier)
		check(is_equal_approx(battle.player_position.x, lateral_position), "Auto aim does not steer the player")
		for i in range(120): battle._update_projectiles(1.0 / 60.0)
		check(aimed_enemy.hp < 100, "Assisted arrows hit off-axis enemies")
		var health_before: float = battle.health
		battle.armor = 20
		for kind in ["Critical", "Poison", "LifeSteal"]:
			var arrow := Node3D.new()
			battle.add_child(arrow)
			arrow.position = battle.player_position
			battle.projectiles.append({"node": arrow, "dir": Vector3.ZERO, "speed": 4.0, "type": kind, "life": 2.0, "hostile": true})
		battle._update_projectiles(1.0 / 60.0)
		battle._damage_player(10)
		check(battle.health == health_before and battle.armor == 20 and battle.poison_ticks == 0, "%dx ignores arrow damage, armor loss and poison" % multiplier)
		for foe in battle.enemies: foe.node.queue_free()
		battle.enemies.clear()
	var saved_unlocks: Dictionary = battle.data.unlocks.duplicate()
	for multiplier in [1, 2, 4, 8, 16, 32]:
		battle.set_debug_speed(multiplier)
		for key in battle.abilities:
			battle.data.unlocks[key] = true
			battle.abilities[key].active = 0.0
			battle.abilities[key].cooldown = 0.0
		battle._simulate_step(0.01)
		check(battle.abilities.keys().all(func(key): return battle.active(key) == (multiplier >= 4)), "%dx auto activates all ready abilities only at 4x and above" % multiplier)
		for key in battle.abilities:
			battle.abilities[key].active = 0.0
			battle.abilities[key].cooldown = 0.005
		battle._simulate_step(0.01)
		check(battle.abilities.keys().all(func(key): return battle.active(key) == (multiplier >= 4)), "%dx reactivates abilities the instant cooldown expires" % multiplier)
		for key in battle.abilities:
			battle.data.unlocks[key] = false
			battle.abilities[key].active = 0.0
			battle.abilities[key].cooldown = 0.0
		battle._simulate_step(0.01)
		check(battle.abilities.keys().all(func(key): return not battle.active(key)), "Locked abilities never auto activate")
	battle.data.unlocks = saved_unlocks
	var cycle_speed := InputEventKey.new()
	cycle_speed.keycode = KEY_F7
	cycle_speed.pressed = true
	battle.set_debug_speed(128)
	battle._unhandled_input(cycle_speed)
	check(battle.debug_speed == 1, "F7 cycles from 128x back to 1x")
	battle.set_debug_speed(2)
	var health_before: float = battle.health
	battle.armor = 0
	battle._damage_player(10)
	check(battle.health == health_before - 10 and not battle.fast_combat_assist_enabled(), "2x retains normal arrow damage and aiming")
	battle.set_debug_speed(1)
	battle.player_position = starting_position
	battle.elapsed = 0.0
	battle.distance = 0.0
	battle.row_timer = 0.0
	battle.health = 100.0
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(is_equal_approx(battle.health, 95.0), "Row drains 5 HP every 2 seconds")
	check(absf(battle.distance - 2.6) < 0.001, "Forward movement is 1.3 units/s")
	var shift = InputEventKey.new()
	shift.keycode = KEY_SHIFT
	shift.pressed = true
	battle._unhandled_input(shift)
	check(battle.running, "Shift toggles double speed")
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(absf(battle.distance - 7.8) < 0.001, "Double speed advances two simulation steps")
	check(is_equal_approx(battle.health, 85.0), "Double speed doubles row ticks without amplifying each hit")
	battle.running = false
	battle.row_timer = 0
	battle._spawn_enemy(battle.player_position + Vector3(0, -0.23, -3), 0)
	var enemy = battle.enemies.back()
	enemy.hp = 100
	battle._shoot()
	var count = battle.projectiles.size()
	battle._shoot()
	check(battle.projectiles.size() == count, "Bow rate limits repeated clicks")
	for i in range(45): battle._update_projectiles(1.0 / 60.0)
	check(is_equal_approx(enemy.hp, 84.0), "Arrow projectile deals base 16 damage")
	battle.data.unlocks.ArrowShield = true
	battle._activate("ArrowShield")
	check(battle.active("ArrowShield"), "Unlocked ability activates")
	var health_before_shield = battle.health
	battle.health = 100000
	for i in range(601): battle._physics_process(1.0 / 60.0)
	battle.health = health_before_shield
	check(not battle.active("ArrowShield") and battle.abilities.ArrowShield.cooldown > 29, "Shield lasts 10 seconds then 30-second cooldown")
	battle._activate("ArrowShield")
	check(not battle.active("ArrowShield"), "Cooldown blocks repeat use")
	battle.data.stats.Armor_Against_Row = 50
	battle.armor = 20
	battle.row_timer = 0
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(is_equal_approx(battle.armor, 17.5), "Row armor reduction applied before shield damage")
	var before = battle.player_position
	battle.suspended = true
	battle._physics_process(10)
	check(battle.player_position == before, "Pause freezes movement and combat")
	battle._finish(false)
	check(battle.ended and battle.overlay.visible, "Death/retreat opens run summary")
	check(battle.data.runs == 1, "Run results applied exactly once")
	battle._finish(false)
	check(battle.data.runs == 1, "Repeated finish is idempotent")
	battle.queue_free()
	var util = root.get_node("Util")
	var global_state = root.get_node("Global")
	util.set_active_game_id("rowdivers")
	global_state.current_game_mode_data = null
	global_state.ensure_default_game_mode_data()
	global_state.new_game()
	global_state.start_in_upgrade_scene = true
	var row_save_path = Progress.progress_path()
	var row_save_existed := FileAccess.file_exists(row_save_path)
	var row_save_backup := FileAccess.get_file_as_string(row_save_path) if row_save_existed else ""
	Progress.active_data_cache = Progress.fresh()
	var upgrade_scene: Node = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(upgrade_scene)
	current_scene = upgrade_scene
	upgrade_scene.setup()
	upgrade_scene.show_screen()
	for _frame in range(20):
		await process_frame
	var tree = upgrade_scene.get_node("CanvasLayer/Tech Tree")
	check(upgrade_scene.get("row_divers_wallet_label") != null and upgrade_scene.get("row_divers_wallet_label").visible, "Shared upgrade scene shows the Railway Fury three-currency wallet")
	check(upgrade_scene.get("go_again_button") != null and upgrade_scene.get("go_again_button").text == "PLAY", "Shared scene labels its battle transition PLAY")
	check(tree.node_dict.size() == root.get_node("Global").game_mode_data_manager.upgrades.size() + 1, "Shared UpgradeScreen builds center and every available Railway Fury upgrade")
	var lines: Node = tree.get_node("Pivot/Tech Lines")
	var drawn_edges = {}
	for line in lines.get_children():
		if line.from_node.upgrade==null or line.to_node.upgrade==null: continue
		var ids = [line.from_node.upgrade.sim_key,line.to_node.upgrade.sim_key]
		ids.sort()
		drawn_edges["/".join(ids)] = true
	var missing_edges = 0
	for entry in Progress.design().upgrades:
		for child in entry.children:
			var ids = [str(entry.id),str(child)]
			ids.sort()
			if not drawn_edges.has("/".join(ids)): missing_edges += 1
	check(missing_edges==0, "Shared tree draws every source connection")
	var root_entry: Dictionary = Progress.design().upgrades.filter(func(node): return node.parents.is_empty())[0]
	var root_upgrade = global_state.game_mode_data_manager.upgrades.values().filter(func(upgrade): return upgrade.sim_key == str(root_entry.id))[0]
	check(root_upgrade.sim_name == "Arrow Damage I" and root_upgrade.sim_position == Vector2(float(root_entry.position[0]), -float(root_entry.position[1])) * 20.0, "Shared tree retains source root and Unity layout position")
	check(int(tree.node_dict[root_upgrade.cell].state) == 1, "Fresh Railway Fury root is available")
	check(tree.node_dict[root_upgrade.cell].get_global_transform_with_canvas().origin.distance_to(tree.get_viewport_rect().size * 0.5) < 12, "Fresh upgrade is centered inside the visible viewport")
	check(not upgrade_scene.row_divers_prestige.visible, "Prestige selector is hidden until the first row is beaten")
	var damage5: Dictionary = Progress.design().upgrades.filter(func(entry): return entry.upgradeName == "Arrow Damage V")[0]
	var damage6: Dictionary = Progress.design().upgrades.filter(func(entry): return entry.upgradeName == "Arrow Damage VI")[0]
	check(damage5.cost.currencyType == 1 and damage6.cost.currencyType == 1, "Damage V and VI use gems, not gold")
	var upgrade5 = global_state.game_mode_data_manager.upgrades.values().filter(func(upgrade): return upgrade.sim_key == damage5.id)[0]
	var node5 = tree.node_dict[upgrade5.cell]
	node5.state = 1
	node5.update()
	check(node5.get_node("%Cost").text == "3 GEMS", "Actual upgrade tooltip spells out the gem price")
	check("Bleed Duration level 1" in node5.get_node("%Description").text, "Tooltip explains the source prerequisite")
	var branch_data: Dictionary = Progress.fresh()
	branch_data.levels[damage5.parents[0]] = 1
	branch_data.wallet = [1000000.0, 0.0, 0.0]
	check(not Progress.buy(branch_data, damage5), "Gold alone cannot buy Damage V")
	branch_data.wallet[1] = 3.0
	check(Progress.buy(branch_data, damage5) and branch_data.wallet == [1000000.0, 0.0, 0.0], "Damage V charges three gems without spending gold")
	check(not Progress.visible(branch_data, damage6), "Damage VI stays locked after only one Damage V level")
	branch_data.wallet[1] = 4.0
	check(Progress.buy(branch_data, damage5) and Progress.visible(branch_data, damage6), "Damage V level two unlocks VI on the original branch")
	check(not Progress.buy(branch_data, damage6), "Damage VI also rejects gold-only payment")
	node5.state = 0
	Progress.active_data_cache.max_prestige = 1
	upgrade_scene._refresh_bottom_wallet_display()
	check(upgrade_scene.row_divers_prestige.visible, "First victory reveals prestige selection")
	Progress.active_data_cache.max_prestige = 0
	upgrade_scene._show_row_divers_achievements()
	for frame in range(3): await process_frame
	var collection: PanelContainer = upgrade_scene.row_divers_collection_panel
	var close_button: Button = collection.get_child(0).get_child(0)
	check(close_button.has_node("RailwayButtonFeedback"), "Popup close button has hover/click feedback")
	close_button.get_node("RailwayButtonFeedback")._hover()
	await create_timer(0.07).timeout
	check(close_button.scale.x > 1.0 and absf(close_button.rotation) > 0.001, "Hover visibly grows and tilts the button")
	await create_timer(0.35).timeout
	check(close_button.scale.is_equal_approx(Vector2.ONE) and is_zero_approx(close_button.rotation), "Button hover returns to its resting transform")
	var scroll: ScrollContainer = collection.find_child("CollectionScroll", true, false)
	check(upgrade_scene._is_any_popup_visible(), "Collections block tree zoom input")
	check(scroll.get_v_scroll_bar().max_value > scroll.size.y, "Achievement list has bounded vertical overflow")
	check(scroll.get_child(0).get_children().all(func(row): return row.icon != null), "Every achievement has an icon")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	wheel.position = scroll.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = wheel.position
	motion.global_position = wheel.position
	root.push_input(motion, true)
	root.push_input(wheel, true)
	for frame in range(3): await process_frame
	check(scroll.scroll_vertical > 0, "Mouse wheel scrolls over achievement rows")
	upgrade_scene._show_row_divers_bestiary()
	for frame in range(3): await process_frame
	var bestiary_scroll: ScrollContainer = collection.find_child("CollectionScroll", true, false)
	check(bestiary_scroll.get_child(0).get_children().all(func(row): return row.get_child(0) is TextureRect and row.get_child(0).texture != null), "Every bestiary row has a portrait icon")
	collection.hide()
	var purchase_fixture: Dictionary = Progress.fresh()
	purchase_fixture.wallet[0] = 1000.0
	Progress.save_data(purchase_fixture)
	var root_node = tree.node_dict[root_upgrade.cell]
	root_node.update()
	root_node._purchase_upgrade()
	var purchased_data: Dictionary = Progress.load_data()
	check(Progress.level(purchased_data, root_entry) == 1 and purchased_data.stats.Arrow_Damage > 16.0, "Shared tree purchase applies and saves the source upgrade effect")
	if row_save_existed:
		var restore := FileAccess.open(row_save_path, FileAccess.WRITE)
		restore.store_string(row_save_backup)
		restore.close()
		Progress.active_data_cache = {}
		Progress.load_data()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(row_save_path))
		Progress.active_data_cache = {}
	upgrade_scene.queue_free()
	print("RAILWAY FURY GAMEPLAY + SHARED UPGRADE SCREEN SMOKE %s: %d assertions, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
