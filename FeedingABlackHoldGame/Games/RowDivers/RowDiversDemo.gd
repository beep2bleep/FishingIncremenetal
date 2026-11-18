extends RefCounted
## The export feature cannot be disabled by changing a saved preference.
static func enabled() -> bool:
	return OS.has_feature("railway_demo") or bool(ProjectSettings.get_setting("railway_fury/demo/enabled", false)) or bool(ProjectSettings.get_setting("global/Demo", false))

static func locked(entry: Dictionary) -> bool:
	return enabled() and (int(entry.get("minPrestige", 0)) > 0 or int(entry.get("cost", {}).get("currencyType", 0)) == 2)

static func constrain(_data: Dictionary) -> void:
	# Restrictions belong to runtime access checks, never destructive save edits.
	pass

static func playable_level(data: Dictionary) -> int:
	return 0 if enabled() else clampi(int(data.get("prestige", 0)), 0, 3)

static func unlocked_level(data: Dictionary) -> int:
	return 0 if enabled() else clampi(int(data.get("max_prestige", 0)), 0, 3)

static func save_path(path: String) -> String:
	return path
