extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	graphics.select_mode(2)
	root.get_node("SaveHandler").save_local_settings()
	print("Railway Fury presentation selected: Illustrated / New")
	quit()
