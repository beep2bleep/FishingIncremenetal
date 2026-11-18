extends "res://Games/RowDivers/Scenes/RowDiversBattleScene.gd"
## Trailer capture only. Normal gameplay never instantiates this subclass.
var outgoing_damage_scale = 0.5
var captured_hits = 0
func _hit(enemy: Dictionary, amount: float) -> void:
	captured_hits += 1
	super._hit(enemy, amount * outgoing_damage_scale)
