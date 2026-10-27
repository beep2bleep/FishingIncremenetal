extends "res://GameAnalyticsManager.gd"
## Test transport: retain real payload construction, never initialize or send HTTP.
var events: Array = []
func _ready() -> void: pass
func refresh_active_game_session(_force_restart: bool = false) -> void: pass
func _enqueue_event(event: Dictionary) -> void: events.append(event.duplicate(true))
