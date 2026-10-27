extends RefCounted
## Session-only opt-in. Never serialized into player progress or enabled in exports.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
static var enabled = false
static var profile = ""
static var generation = 0

static func arm() -> void:
	enabled = OS.has_feature("editor")
	profile = Progress.progress_path()
	generation += 1

static func stop() -> void:
	enabled = false
	generation += 1

static func armed() -> bool:
	return OS.has_feature("editor") and enabled and profile == Progress.progress_path()

static func active(speed: int) -> bool:
	return armed() and speed > 4 and bool(ProjectSettings.get_setting("railway_fury/debug/enable_speed_cheats", false))
