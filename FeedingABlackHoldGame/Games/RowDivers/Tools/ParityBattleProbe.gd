extends "res://Games/RowDivers/Scenes/RowDiversBattleScene.gd"
## Suppress world construction and floating art only; all tested gameplay is inherited.
var random_tape: Array = []
func _build_section(_number: int) -> void: pass
func _floating_text(_pos: Vector3, _text: String, _color: Color, _currency = false) -> void: pass
func _roll(key: String) -> bool:
	return float(random_tape.pop_front() if not random_tape.is_empty() else 0.5) * 100.0 < s(key)
