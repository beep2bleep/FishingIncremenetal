extends "res://UpgradeScreen.gd"
## Keep normal shopping/UI, intercept only scene navigation to protect the live save.
var launches = 0
var endings = 0
func _on_go_again_pressed() -> void: launches += 1
func _open_row_divers_ending() -> void: endings += 1
