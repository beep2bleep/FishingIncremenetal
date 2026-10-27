extends SceneTree
const Progress = preload("res://Games/RowDivers/RowDiversProgress.gd")
const DECORATIONS = ["plant.png","plant2.png","plant3.png","spider web.png","Decor.png","Decor2.png","Spikes.png"]
var checks = 0
var failures = 0
func _initialize(): call_deferred("run")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run():
	root.get_node("Util").set_active_game_id("rowdivers")
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	var art = load("res://Games/RowDivers/RowDiversIllustrated.gd")
	var source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	graphics.select_mode(2)
	check(art.texture_path("plant.png")!=art.texture_path("plant2.png") and art.texture_path("plant2.png")!=art.texture_path("plant3.png"),"Separate foliage art per scenery role")
	for name in ["plant.png","plant2.png","plant3.png"]:
		var image: Image = art.texture(name).get_image()
		check(image.detect_alpha()!=Image.ALPHA_NONE,"Transparent replacement: "+name)
	for width in [1.0,1.4]:
		for layout in source.catalog().layouts:
			var hall = source.build(layout)
			root.add_child(hall)
			hall.scale.x = width
			source.refresh_materials(hall)
			for visual in hall.find_children("*","MeshInstance3D",true,false):
				var key: String = visual.get_meta("row_source_material", "")
				if not source.catalog().materials.get(key,{}).get("texture","") in DECORATIONS: continue
				var plane = not visual.mesh is QuadMesh
				var bounds: Vector3 = visual.mesh.get_aabb().size
				var u: Vector3 = visual.global_basis.x * bounds.x
				var v: Vector3 = visual.global_basis.z * bounds.z if plane else visual.global_basis.y * bounds.y
				var image: Texture2D = visual.material_override.get_shader_parameter("source_texture")
				check(absf(u.length()/v.length()-float(image.get_width())/image.get_height())<.001,"Natural aspect: "+layout+"/"+str(visual.get_parent().name))
				var fitted: Vector3 = visual.scale
				check(fitted.x<=1 and fitted.y<=1 and fitted.z<=1,"Fit does not enlarge decorations")
				source.refresh_instance(visual)
				check(visual.scale.is_equal_approx(fitted),"Refresh does not compound shrinking")
			graphics.select_mode(1)
			source.refresh_materials(hall)
			check(hall.find_children("*","MeshInstance3D",true,false).all(func(v): return v.scale==Vector3.ONE),"Original artwork retains source geometry")
			graphics.select_mode(2)
			hall.free()
	if "--preview" in OS.get_cmdline_user_args():
		root.size = Vector2i(1280,720)
		Progress.free_aim_mode = true
		Progress.active_data_cache = Progress.fresh()
		Progress.active_data_cache.controls_seen = true
		var battle = load("res://Games/RowDivers/Scenes/RowDiversBattleScene.gd").new()
		battle.persist_results = false
		root.add_child(battle)
		current_scene = battle
		battle.set_physics_process(false)
		battle.set_process(false)
		for section in battle.sections: section.free()
		battle.sections.clear()
		for enemy in battle.enemies: enemy.node.free()
		battle.enemies.clear()
		for layout in ["Section 1","Section 4","MiniBoss2 Section"]:
			var hall = source.build(layout)
			battle.add_child(hall)
			hall.scale.x = 1.4
			hall.position.x *= 1.4
			source.refresh_materials(hall)
			battle.pointer_override = Vector2(640,360)
			battle._update_bow_aim()
			battle.player_position.z = -3
			battle._update_camera_presentation()
			for i in range(8): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://Games/RowDivers/Docs/Previews/scenery_"+layout.replace(" ","_")+".png")
			hall.free()
		battle.free()
	print("SCENERY PROPORTIONS: ",checks," checks, failures=",failures)
	quit(0 if failures==0 else 1)
