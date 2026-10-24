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
	var data = Progress.fresh()
	var design = Progress.design()
	check(design.upgrades.size() == 112, "112 reference nodes")
	var edges = 0
	var positions: Dictionary = {}
	for node in design.upgrades:
		edges += node.children.size()
		positions[str(node.position)] = true
	check(edges == 114, "114 reference connections")
	check(positions.size() > 100, "Geometry is not collapsed")
	check(data.stats.MaxHP == 100 and data.stats.Arrow_Damage == 16, "Fresh reference stats")
	check(data.stats.Arrow_Speed == 5 and data.stats.Horizontal_Speed == 0.8, "Movement and arrow defaults")
	check(design.settings.movement.forwardSpeed == 1.3, "Serialized forward speed")
	var visible = design.upgrades.filter(func(n): return Progress.visible(data, n))
	check(visible.size() == 1 and visible[0].upgradeName == "Arrow Damage I", "Fresh visibility")
	check(not Progress.buy(data, visible[0]), "Empty wallet rejected")
	data.wallet = [1e30, 1e30, 1e30]
	# Buy the reachable graph in legal order, checking each effect against an independent formula.
	var purchased = 0
	var pending = true
	while pending:
		pending = false
		for node in design.upgrades:
			if not Progress.can_buy(data, node): continue
			var before = data.stats.duplicate(true)
			var rank = Progress.level(data, node)
			var expected = float(node.baseUpgradeCost) if rank == 0 else ceil(float(node.baseUpgradeCost) * pow(1.2, rank))
			check(Progress.cost(data, node) == expected, str(node.upgradeName) + " cost")
			check(Progress.buy(data, node), str(node.upgradeName) + " purchase")
			check(Progress.level(data, node) == rank + 1, "Level increments once")
			if node.unlocks.is_empty():
				for effect in node.effects:
					var old = float(before.get(effect.stat, 0))
					var result = old + (old * float(effect.amount) / 100 if effect.percentage and old > 0 else float(effect.amount))
					check(is_equal_approx(float(data.stats[effect.stat]), result), str(node.upgradeName) + " effect " + str(effect.stat))
			else:
				check(data.stats == before, "Unlock nodes do not apply stat payload")
			purchased += 1
			pending = true
	for node in design.upgrades:
		check(Progress.level(data, node) == int(node.maxLevel), str(node.upgradeName) + " is reachable")
		check(not Progress.buy(data, node), "Max level prevents payment")
	check(data.unlocks.get("Dagger", false) and data.unlocks.get("Auto", false), "Weapon/fire unlocks")
	check(data.unlocks.get("SlowDown", false) and data.unlocks.get("ThirdEye", false), "Late unlocks")
	var roundtrip = "user://row_divers_validation_roundtrip.json"
	Progress.save_data(data, roundtrip)
	var restored = Progress.load_data(roundtrip)
	for node in design.upgrades:
		check(Progress.level(restored, node) == Progress.level(data, node), "Purchased level persists: " + str(node.upgradeName))
	data.wallet = [123.0, 4.0, 1.0]
	Progress.save_data(data, roundtrip)
	check(Progress.load_data(roundtrip).wallet == data.wallet, "Atomic save replaces an existing save")
	DirAccess.remove_absolute(roundtrip)
	print("RAILWAY FURY VALIDATION %s: %d assertions; %d purchases; %d failures; all 112 nodes maxed through legal edges" % ["PASSED" if failures == 0 else "FAILED", checks, purchased, failures])
	quit(0 if failures == 0 else 1)
