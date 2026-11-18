extends SceneTree
## Export the exact in-game catalog and badge renderer for Steamworks bulk import.
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const OUT = "res://StoreAssets_RailwayFury/steam/achievements/"

func _initialize(): call_deferred("run")

func run():
	var Icons = load("res://Games/RowDivers/RowDiversIcons.gd")
	# Railway Fury's shipping illustrated presentation uses the same achievement
	# badges as the original art mode. No new artwork is drawn for Steam.
	load("res://Games/RowDivers/RowDiversGraphics.gd").select_mode(2)
	DirAccess.make_dir_recursive_absolute(OUT)
	var definitions = FileAccess.open(OUT + "5520300-achievements-definitions.csv", FileAccess.WRITE)
	definitions.store_csv_line(PackedStringArray(["api_name", "setid", "permission", "spoiler", "archived", "progress_stat_name", "progress_stat_min", "progress_stat_max"]))
	var localization = FileAccess.open(OUT + "5520300-achievements-localization.csv", FileAccess.WRITE)
	localization.store_csv_line(PackedStringArray(["api_name", "field", "english"]))
	for entry in Progress.design().settings.achievements:
		var key: String = Progress.design().enums.AchievementType[str(int(entry.achievementType))]
		definitions.store_csv_line(PackedStringArray([key, "", "Client", "false", "false", "", "", ""]))
		localization.store_csv_line(PackedStringArray([key, "name", entry.achievementName]))
		localization.store_csv_line(PackedStringArray([key, "description", entry.description]))
		var image = Icons.achievement(key).get_image()
		image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
		assert(image.save_png(OUT + key + "_ACHIEVED.png") == OK)
	definitions.close()
	localization.close()
	print("Exported %d Steam achievements with in-game text and pictures" % Progress.design().settings.achievements.size())
	quit()
