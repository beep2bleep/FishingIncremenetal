extends "res://Games/RowDivers/Scenes/RowDiversBattleScene.gd"
var won_run = false
func fast_combat_assist_enabled() -> bool: return true
func _floating_text(_pos: Vector3, _text: String, _color: Color, _currency = false) -> void: pass
func _finish(won: bool) -> void:
	if ended: return
	ended = true
	won_run = won
	data.runs += 1
	data.kills += run_kills
	data.best_distance = maxf(data.best_distance, distance)
