extends SceneTree
## Mechanical Steam size exports; illustration masters remain unchanged.
var BASE = get_script().resource_path.get_base_dir().path_join("../../FeedingABlackHoldGame/StoreAssets_RailwayFury/steam/").simplify_path()+"/"
func _initialize():
	DirAccess.make_dir_recursive_absolute(BASE+"capsules")
	for spec in [["header",920,430,"key-art-landscape.png",0.0], ["small",462,174,"key-art-landscape.png",0.0], ["main",1232,706,"key-art-landscape.png",0.0], ["vertical",748,896,"key-art-portrait.png",0.0], ["library_capsule",600,900,"key-art-portrait.png",0.5], ["library_header",920,430,"key-art-landscape.png",0.0], ["library_hero",3840,1240,"library-hero.png",0.5]]:
		var source = Image.load_from_file(BASE+"masters/"+str(spec[3]))
		var target_ratio = float(spec[1])/float(spec[2])
		var crop_size = Vector2i(source.get_width(),roundi(source.get_width()/target_ratio))
		if crop_size.y>source.get_height(): crop_size = Vector2i(roundi(source.get_height()*target_ratio),source.get_height())
		var crop = source.get_region(Rect2i(Vector2i((source.get_width()-crop_size.x)/2,roundi((source.get_height()-crop_size.y)*float(spec[4]))),crop_size))
		crop.resize(int(spec[1]),int(spec[2]),Image.INTERPOLATE_LANCZOS)
		crop.save_png(BASE+"capsules/"+str(spec[0])+".png")
	var logo = Image.load_from_file(BASE+"masters/logo.png")
	logo.resize(1280,640,Image.INTERPOLATE_LANCZOS)
	logo.save_png(BASE+"capsules/library_logo.png")
	var icon = Image.load_from_file(BASE+"masters/app-icon.png")
	for size in [16,32,48,256,512]:
		var scaled = icon.duplicate()
		scaled.resize(size,size,Image.INTERPOLATE_LANCZOS)
		scaled.save_png(BASE+"capsules/icon_%d.png"%size)
		if size==32: scaled.save_jpg(BASE+"capsules/community_icon.jpg",.98)
		if size==512:
			var runtime_path = BASE.path_join("../../Games/RowDivers/Art/UI/").simplify_path()
			DirAccess.make_dir_recursive_absolute(runtime_path)
			scaled.save_png(runtime_path+"/railway-icon.png")
	print("Steam art sizes exported from unmodified illustration masters")
	quit()
