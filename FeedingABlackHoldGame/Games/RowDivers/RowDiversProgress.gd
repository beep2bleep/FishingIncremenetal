extends RefCounted
## Purchase order matters: percentages compound against the current stat, as in UpgradeController.
const DATA_PATH = "res://Games/RowDivers/Data/row_divers.json"
const SAVE_PATH = "user://row_divers_progress_v1.json"
static var catalog: Dictionary = {}
static var active_data_cache: Dictionary = {}

static func design() -> Dictionary:
	if catalog.is_empty():
		catalog = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	return catalog

static func find_upgrade(id: String) -> Dictionary:
	for entry in design().get("upgrades", []):
		if str(entry.get("id", "")) == id:
			return entry
	return {}

static func fresh() -> Dictionary:
	return {"levels": {}, "stats": design().base_stats.duplicate(true), "unlocks": {"Bow": true}, "wallet": [0.0, 0.0, 0.0], "spent": [0.0, 0.0, 0.0], "achievements": {}, "claimed": {}, "bestiary": {}, "runs": 0, "best_distance": 0.0, "kills": 0, "prestige": 0, "max_prestige": 0, "crowns_dropped": {}, "controls_seen": false}

static func load_data(path = SAVE_PATH) -> Dictionary:
	if path == SAVE_PATH and not active_data_cache.is_empty():
		apply_reference_repairs(active_data_cache)
		return active_data_cache
	if not FileAccess.file_exists(path):
		var initial: Dictionary = fresh()
		if path == SAVE_PATH:
			active_data_cache = initial
		return initial
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	var loaded: Dictionary = fresh().merged(value, true) if value is Dictionary else fresh()
	apply_reference_repairs(loaded)
	if path == SAVE_PATH:
		active_data_cache = loaded
	return loaded

static func apply_reference_repairs(data: Dictionary) -> void:
	# UpgradeController.Start has this explicit correction for completed older
	# critical-chance trees. Match it when entering/reloading a screen.
	if stat(data, "Critic_Chance") >= 50.0: return
	for entry in design().upgrades:
		if entry.upgradeName == "Arrow Critic Chance IV" and level(data, entry) >= int(entry.maxLevel):
			data.stats.Critic_Chance = 65.3184
			return

static func save_data(data: Dictionary, path = SAVE_PATH) -> void:
	if path == SAVE_PATH:
		active_data_cache = data
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		push_error("Cannot save Row Divers progression: " + error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	var result = DirAccess.rename_absolute(path + ".tmp", path)
	if result != OK:
		push_error("Cannot finalize Row Divers save: " + error_string(result))

static func level(data: Dictionary, node: Dictionary) -> int:
	return int(data.levels.get(node.id, node.level))

static func cost(data: Dictionary, node: Dictionary) -> float:
	# Unity leaves the previous price in place when the final tier is purchased.
	var rank = mini(level(data, node), int(node.maxLevel) - 1)
	if rank <= 0:
		return float(node.baseUpgradeCost)
	return ceil(float(node.baseUpgradeCost) * pow(1.2, rank))

static func visible(data: Dictionary, node: Dictionary) -> bool:
	if node.isVisible or level(data, node) > 0:
		return true
	for parent in node.parents:
		if int(data.levels.get(parent, 0)) >= int(node.unlockAtParentLevel):
			return true
	return false

static func can_buy(data: Dictionary, node: Dictionary) -> bool:
	return visible(data, node) and level(data, node) < int(node.maxLevel) and float(data.wallet[int(node.cost.currencyType)]) >= cost(data, node)

static func buy(data: Dictionary, node: Dictionary) -> bool:
	if not can_buy(data, node):
		return false
	data.wallet[int(node.cost.currencyType)] -= cost(data, node)
	data.spent[int(node.cost.currencyType)] += cost(data, node)
	data.levels[node.id] = level(data, node) + 1
	# Unity checks weapon, fire mode, tab, then ability and applies no stats on unlock nodes.
	if not node.unlocks.is_empty():
		for key in ["weaponType", "fireType", "tabType", "abilityType"]:
			if node.unlocks.has(key):
				data.unlocks[node.unlocks[key]] = true
				break
	else:
		for effect in node.effects:
			var old = float(data.stats.get(effect.stat, 0.0))
			var amount = old * float(effect.amount) / 100.0 if effect.percentage and old > 0 else float(effect.amount)
			data.stats[effect.stat] = old + amount
	check_achievements(data)
	return true

static func check_achievements(data: Dictionary) -> void:
	var requirements = {"ArmoredTank": ["Armor", 1000.0], "BowMaster": ["Arrow_Damage", 60000000.0], "Vampire": ["HP_Steal_Chance", 1.0], "Healer": ["HealOnHit_Chance", 1.0]}
	for key in requirements:
		if stat(data, requirements[key][0]) >= requirements[key][1]: data.achievements[key] = true
	# UpgradeFlow calls AchievementChecker after IncreaseLevel/UpdateCost. The
	# reference counts that next price, including the retained last-tier price.
	var achievement_spend := [0.0, 0.0, 0.0]
	for entry in design().upgrades:
		for rank in range(1, level(data, entry) + 1):
			var price_rank := mini(rank, int(entry.maxLevel) - 1)
			achievement_spend[int(entry.cost.currencyType)] += float(entry.baseUpgradeCost) if price_rank == 0 else ceil(float(entry.baseUpgradeCost) * pow(1.2, price_rank))
	if maxf(data.spent[0], achievement_spend[0]) >= 10000: data.achievements.CoinMaster = true
	if maxf(data.spent[1], achievement_spend[1]) >= 50: data.achievements.GemMaster = true
	# UpgradesTreeManager.CheckMaxed uses 100 maxed nodes, not the full 112.
	var maxed := 0
	for entry in design().upgrades:
		if level(data, entry) >= int(entry.maxLevel): maxed += 1
	if maxed >= 100 and (data.crowns_dropped.get("3", false) or data.achievements.get("PrestigeMaster", false) or data.achievements.get("Prestige3", false)):
		data.unlocks.GodTab = true
		data.achievements.BeatTheGame = true

# PanelManager.UnlockGodButton charges this once after GodTab becomes visible.
static func unlock_final_chamber(data: Dictionary) -> bool:
	if not data.unlocks.get("GodTab", false): return false
	if data.get("god_panel_unlocked", false): return true
	var prices := [200000.0, 10.0, 4.0]
	for currency in range(3):
		if data.wallet[currency] < prices[currency]: return false
	for currency in range(3): data.wallet[currency] -= prices[currency]
	data.god_panel_unlocked = true
	return true

static func claim(data: Dictionary, achievement: Dictionary) -> bool:
	var key = str(design().enums.AchievementType[str(int(achievement.achievementType))])
	if not data.achievements.get(key, false) or data.claimed.get(key, false): return false
	var currency := int(achievement.currencyType)
	if currency >= 0 and currency < data.wallet.size():
		data.wallet[currency] += float(achievement.reward)
	data.claimed[key] = true
	return true

static func stat(data: Dictionary, key: String) -> float:
	return float(data.stats.get(key, 0.0))
