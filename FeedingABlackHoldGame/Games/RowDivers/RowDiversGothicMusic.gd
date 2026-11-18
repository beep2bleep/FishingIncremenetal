extends RefCounted
## Independent session choices; never written to artwork preferences or progression.
const ROOT = "res://Games/RowDivers/Audio/Gothic/"
static var source: Dictionary = {}
static var upgrade_track = 0
static var combat_track = 0

static func catalog() -> Dictionary:
	if source.is_empty(): source = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "sources.json"))
	return source

static func entries(context: String) -> Array:
	return catalog().combat if context == "battle" else catalog().upgrade

static func selected(context: String) -> int:
	return combat_track if context == "battle" else upgrade_track

static func cue(context: String) -> String:
	var pool := entries(context)
	return pool[clampi(selected(context), 0, pool.size() - 1)]

static func select(context: String, index: int) -> void:
	index = clampi(index, 0, entries(context).size() - 1)
	if context == "battle": combat_track = index
	else: upgrade_track = index
