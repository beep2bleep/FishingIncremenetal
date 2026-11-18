extends RefCounted
## One-time upgrade from separate demo profiles. Originals remain untouched.
static func legacy_paths(path: String) -> Array[String]:
	var paths: Array[String] = [path.replace(".json", "_demo.json")]
	# Never inspect a player's real folder from QA or an arbitrary custom folder.
	if OS.get_user_data_dir().get_file() == "RailwayFury":
		paths.append(OS.get_user_data_dir().get_base_dir().path_join("RailwayFuryDemo").path_join(path.get_file().replace(".json", "_demo.json")))
	return paths

static func merge_profiles(primary: Dictionary, legacy: Dictionary, upgrades: Array) -> Dictionary:
	if primary.is_empty(): return legacy.duplicate(true)
	var merged = primary.duplicate(true)
	# Add only missing ranks. Never add two wallet balances or claim a reward twice.
	for entry in upgrades:
		var old_rank = int(merged.get("levels", {}).get(entry.id, 0))
		var new_rank = mini(int(entry.maxLevel), maxi(old_rank, int(legacy.get("levels", {}).get(entry.id, 0))))
		for rank in range(old_rank, new_rank):
			for effect in entry.get("effects", []) if entry.get("unlocks", {}).is_empty() else []:
				var old = float(merged.stats.get(effect.stat, 0.0))
				merged.stats[effect.stat] = old + (old * float(effect.amount) / 100.0 if effect.percentage and old > 0 else float(effect.amount))
		if new_rank > old_rank: merged.levels[entry.id] = new_rank
	for field in ["unlocks", "achievements", "claimed", "crowns_dropped"]:
		if not merged.has(field): merged[field] = {}
		for key in legacy.get(field, {}):
			if legacy[field][key]: merged[field][key] = true
	for field in ["runs", "kills", "best_distance", "max_prestige", "gameplay_seconds"]:
		merged[field] = maxf(float(merged.get(field, 0)), float(legacy.get(field, 0)))
	for field in ["wallet", "spent"]:
		for i in range(3): merged[field][i] = maxf(float(merged[field][i]), float(legacy.get(field, [0,0,0])[i]))
	for field in ["controls_seen", "demo_completed", "god_panel_unlocked"]:
		merged[field] = bool(merged.get(field, false)) or bool(legacy.get(field, false))
	for key in legacy.get("bestiary", {}): merged.bestiary[key] = maxi(int(merged.bestiary.get(key, 0)), int(legacy.bestiary[key]))
	return merged

static func migrate(path: String, paths: Array[String], upgrades: Array) -> bool:
	var original = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}
	if not original is Dictionary: return false # Preserve malformed existing files for recovery.
	if original.get("shared_demo_migrated_v1", false): return false
	var merged: Dictionary = original.duplicate(true)
	for legacy_path in paths:
		if not FileAccess.file_exists(legacy_path): continue
		var legacy = JSON.parse_string(FileAccess.get_file_as_string(legacy_path))
		if legacy is Dictionary: merged = merge_profiles(merged, legacy, upgrades)
	if merged.is_empty(): return false
	if merged.get("demo_completed", false): merged.max_prestige = maxi(1, int(merged.get("max_prestige", 0)))
	merged.shared_demo_migrated_v1 = true
	if FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".pre_shared.bak"):
		if DirAccess.copy_absolute(path, path + ".pre_shared.bak") != OK: return false
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(merged, "\t"))
	file.close()
	return DirAccess.rename_absolute(path + ".tmp", path) == OK
