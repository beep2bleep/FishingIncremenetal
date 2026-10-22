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
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(is_equal_approx(battle.health, 95.0), "Row drains 5 HP every 2 seconds")
	check(absf(battle.distance - 2.6) < 0.001, "Forward movement is 1.3 units/s")
	var shift = InputEventKey.new()
	shift.keycode = KEY_SHIFT
	shift.pressed = true
	battle._unhandled_input(shift)
	check(battle.running, "Shift toggles running")
	for i in range(120): battle._physics_process(1.0 / 60.0)
	check(absf(battle.distance - 6.5) < 0.001, "Running uses 1.5 multiplier")
	check(is_equal_approx(battle.health, 87.5), "Running scales row damage")
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
	for i in range(301): battle._physics_process(1.0 / 60.0)
	check(not battle.active("ArrowShield") and battle.abilities.ArrowShield.cooldown > 119, "Shield lasts 5 seconds then 120-second cooldown")
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
	var row_save_existed := FileAccess.file_exists(Progress.SAVE_PATH)
	var row_save_backup := FileAccess.get_file_as_string(Progress.SAVE_PATH) if row_save_existed else ""
	Progress.active_data_cache = Progress.fresh()
	var upgrade_scene: Node = load("res://UpgradeScreen.tscn").instantiate()
	root.add_child(upgrade_scene)
	current_scene = upgrade_scene
	upgrade_scene.setup()
	upgrade_scene.show_screen()
	for _frame in range(20):
		await process_frame
	var tree = upgrade_scene.get_node("CanvasLayer/Tech Tree")
	check(upgrade_scene.get("row_divers_wallet_label") != null and upgrade_scene.get("row_divers_wallet_label").visible, "Shared upgrade scene shows the Row Divers three-currency wallet")
	check(upgrade_scene.get("go_again_button") != null and upgrade_scene.get("go_again_button").text == "PLAY", "Shared scene labels its battle transition PLAY")
	check(tree.node_dict.size() == 113, "Shared UpgradeScreen builds center and all 112 Row Divers upgrades")
	var lines: Node = tree.get_node("Pivot/Tech Lines")
	check(lines.get_child_count() == 115, "Shared tree draws all 114 source edges and its center edge (got %d)" % lines.get_child_count())
	var root_entry: Dictionary = Progress.design().upgrades.filter(func(node): return node.parents.is_empty())[0]
	var root_upgrade = global_state.game_mode_data_manager.upgrades.values().filter(func(upgrade): return upgrade.sim_key == str(root_entry.id))[0]
	check(root_upgrade.sim_name == "Arrow Damage I" and root_upgrade.sim_position == Vector2(float(root_entry.position[0]), -float(root_entry.position[1])) * 20.0, "Shared tree retains source root and Unity layout position")
	check(int(tree.node_dict[root_upgrade.cell].state) == 1, "Fresh Row Divers root is available")
	check(tree.node_dict[root_upgrade.cell].get_global_transform_with_canvas().origin.distance_to(tree.get_viewport_rect().size * 0.5) < 12, "Fresh upgrade is centered inside the visible viewport")
	check(not upgrade_scene.row_divers_prestige.visible, "Prestige selector is hidden until the first row is beaten")
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
		var restore := FileAccess.open(Progress.SAVE_PATH, FileAccess.WRITE)
		restore.store_string(row_save_backup)
		restore.close()
		Progress.active_data_cache = {}
		Progress.load_data()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.SAVE_PATH))
		Progress.active_data_cache = {}
	upgrade_scene.queue_free()
	print("ROW DIVERS GAMEPLAY + SHARED UPGRADE SCREEN SMOKE %s: %d assertions, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
