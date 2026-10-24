extends AudioStreamPlayer
## Session music survives scene replacement under the persistent MusicPlayer.
func _process(_delta: float) -> void:
	if not Util.is_row_divers_game_active():
		stop()
		queue_free()
