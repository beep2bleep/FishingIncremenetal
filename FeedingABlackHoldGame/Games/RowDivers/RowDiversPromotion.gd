extends RefCounted
## Saved per campaign. Menus, pauses and accelerated simulation do not count.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const MIN_PLAY_SECONDS = 20.0 * 60.0

static func visit_upgrades() -> bool:
	if not Progress.Demo.enabled(): return false
	var data = Progress.load_data()
	if float(data.get("promotion_play_seconds", 0)) < MIN_PLAY_SECONDS: return false
	data.promotion_upgrade_visits = int(data.get("promotion_upgrade_visits", 0)) + 1
	Progress.save_data(data)
	return int(data.promotion_upgrade_visits) % 3 == 0
