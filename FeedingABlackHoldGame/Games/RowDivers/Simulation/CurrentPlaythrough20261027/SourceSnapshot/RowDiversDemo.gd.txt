extends RefCounted
## The export feature cannot be disabled by changing a saved preference.
static func enabled() -> bool:
	return OS.has_feature("railway_demo") or bool(ProjectSettings.get_setting("railway_fury/demo/enabled", false)) or bool(ProjectSettings.get_setting("global/Demo", false))

static func locked(entry: Dictionary) -> bool:
	return enabled() and (int(entry.get("minPrestige", 0)) > 0 or int(entry.get("cost", {}).get("currencyType", 0)) == 2)

static func constrain(data: Dictionary) -> void:
	if not enabled(): return
	data.prestige = 0
	data.max_prestige = 0
	data.unlocks.erase("GodTab")
	data.erase("god_panel_unlocked")

static func save_path(path: String) -> String:
	return path.replace(".json", "_demo.json") if enabled() else path
