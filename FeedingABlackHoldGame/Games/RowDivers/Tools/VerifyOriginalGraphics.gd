extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
var Graphics: GDScript
var save_handler: Node
var signal_bus: Node
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func state(battle: Node3D) -> Dictionary:
	var foes: Array = []
	for enemy in battle.enemies:
		foes.append([enemy.kind, enemy.hp, enemy.node.position, enemy.next_shot, enemy.contact])
	return {"hp": battle.health, "armor": battle.armor, "position": battle.player_position, "wallet": battle.data.wallet.duplicate(), "enemies": foes, "elapsed": battle.elapsed, "abilities": battle.abilities.duplicate(true)}

func simulate(original: bool) -> Dictionary:
	save_handler.row_divers_original_graphics = original
	seed(41250)
	var data: Dictionary = Progress.fresh()
	data.controls_seen = true
	Progress.active_data_cache = data
	var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
	battle.persist_results = false
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	var before := state(battle)
	var random_before = randf()
	seed(101)
	var expected_random := randf()
	seed(101)
	save_handler.row_divers_original_graphics = not original
	signal_bus.settings_updated.emit()
	check(state(battle) == before, "Live switch must preserve all combat state")
	check(randf() == expected_random, "Switching graphics must not consume gameplay randomness")
	save_handler.row_divers_original_graphics = original
	signal_bus.settings_updated.emit()
	for enemy in battle.enemies:
		check((enemy.actor.source_sprite != null) == original, "Actor matches selected graphics")
	for frame in range(300):
		battle.horizontal_override = 0.2 if frame < 120 else -0.1
		battle._physics_process(1.0 / 60.0)
	var result := state(battle)
	result["next_random"] = randf()
	result["initial_random"] = random_before
	battle.free()
	return result

func run() -> void:
	Graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	save_handler = root.get_node("SaveHandler")
	signal_bus = root.get_node("SignalBus")
	root.get_node("Util").set_active_game_id("rowdivers")
	var saved_mode: bool = save_handler.row_divers_original_graphics
	var saved_settings_path: String = save_handler.local_settings_file_path
	save_handler.local_settings_file_path = "user://original_graphics_verification.json"
	for asset in Graphics.catalog().files:
		check(Graphics.texture(asset.file) != null, "Texture loads: " + str(asset.file))
	check(Graphics.catalog().upgrades.size() == 112, "All 112 original upgrade icons resolve")
	var modern := simulate(false)
	var original := simulate(true)
	check(modern == original, "Identical inputs produce identical gameplay state with either art style")
	load("res://Games/RowDivers/RowDiversUpgradeTreeAdapter.gd").apply_simulation_upgrades()
	var manager = root.get_node("Global").game_mode_data_manager
	for upgrade in manager.upgrades.values():
		check(upgrade.sim_icon.begins_with(Graphics.ROOT), "Original upgrade icon path: " + upgrade.sim_key)
	var settings = load("res://Settings.tscn").instantiate()
	root.add_child(settings)
	check(settings.row_divers_graphics_toggle != null, "Shared settings exposes original graphics toggle")
	settings.row_divers_graphics_toggle.button_pressed = not save_handler.row_divers_original_graphics
	var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_handler.local_settings_file_path))
	check(stored.row_divers_original_graphics == save_handler.row_divers_original_graphics, "Toggle persists local preference")
	for upgrade in manager.upgrades.values():
		check(not upgrade.sim_icon.begins_with(Graphics.ROOT), "Live settings switch restores modern upgrade icon")
	settings.free()
	save_handler.row_divers_original_graphics = true
	var ending_data: Dictionary = Progress.fresh()
	ending_data.unlocks.GodTab = true
	ending_data.god_panel_unlocked = true
	Progress.active_data_cache = ending_data
	var ending = load("res://Games/RowDivers/Scenes/RowDiversEnding.tscn").instantiate()
	ending.persist_results = false
	root.add_child(ending)
	check(ending.illustration.visible and ending.illustration.texture == Graphics.texture("Throne.png"), "Original final-chamber illustration")
	ending._choose("BenevolentGod")
	check(ending.illustration.texture == Graphics.texture("BenevolentGod.png"), "Original benevolent-ending illustration")
	ending._choose("EvilGod")
	check(ending.illustration.texture == Graphics.texture("DevilGod.png"), "Original evil-ending illustration")
	ending.free()
	DirAccess.remove_absolute(save_handler.local_settings_file_path)
	save_handler.local_settings_file_path = saved_settings_path
	save_handler.row_divers_original_graphics = saved_mode
	print("ORIGINAL GRAPHICS: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
