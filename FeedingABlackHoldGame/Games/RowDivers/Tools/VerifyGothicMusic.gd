extends SceneTree
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func run() -> void:
	root.get_node("Util").set_active_game_id("rowdivers")
	var graphics = load("res://Games/RowDivers/RowDiversGraphics.gd")
	var choices = load("res://Games/RowDivers/RowDiversGothicMusic.gd")
	var service = load("res://Games/RowDivers/RowDiversAudio.gd")
	var saved_original: bool = root.get_node("SaveHandler").row_divers_original_graphics
	var saved_illustrated: bool = root.get_node("SaveHandler").row_divers_illustrated_graphics
	graphics.select_mode(3)
	var audio = service.new()
	root.add_child(audio)
	for context in ["menu", "battle"]:
		for index in range(3):
			choices.select(context, index)
			audio.play_context(context)
			var cue: String = choices.cue(context)
			var stream: AudioStreamOggVorbis = audio.music.stream
			check(stream.resource_path == choices.ROOT + choices.catalog().music[cue].file, "Correct track: " + cue)
			check(stream.get_length() > 90 and stream.loop, "Sustained looping track: " + cue)
			if context == "menu":
				check(choices.catalog().music[cue].has("sustained_loop"), "Upgrade track excludes authored fade-out: " + cue)
			check(audio.music.bus == "Music" and audio.music.pitch_scale == 1.0, "Uses music volume bus at natural pitch")
	choices.select("menu", 0)
	audio.play_context("menu")
	audio.music.seek(13.0)
	await create_timer(.08).timeout
	var old_position: float = audio.music.get_playback_position()
	choices.select("battle", 1)
	root.get_node("SignalBus").settings_updated.emit()
	check(absf(audio.music.get_playback_position() - old_position) < .3, "Editing combat music leaves upgrade playback uninterrupted")
	choices.select("menu", 1)
	root.get_node("SignalBus").settings_updated.emit()
	check(audio.music.stream.resource_path.ends_with("upgrade_grimoire.ogg"), "Changing upgrade music switches immediately")
	choices.select("menu", 0)
	root.get_node("SignalBus").settings_updated.emit()
	check(absf(audio.music.get_playback_position() - old_position) < .3, "Returning to a track restores its own playback bookmark")
	audio.play_context("battle")
	check(audio.music.stream.resource_path.ends_with("combat_carnage.ogg"), "Combat remembers its independent selection")
	audio.music.seek(21.0)
	await create_timer(.08).timeout
	var player: AudioStreamPlayer = audio.music
	audio.free()
	audio = service.new()
	root.add_child(audio)
	audio.play_context("battle")
	check(audio.music == player and audio.music.get_playback_position() >= 20.9, "Scene changes keep the selected track playing")
	graphics.select_mode(2)
	root.get_node("SignalBus").settings_updated.emit()
	check(audio.music.stream.resource_path.begins_with(service.ILLUSTRATED_ROOT), "Leaving Gothic restores Illustrated music")
	audio.play_context("menu")
	check(service.illustrated_catalog().music.menu.has("sustained_loop") and audio.music.stream.loop, "Illustrated upgrade music uses sustained loop")
	var gain: float = audio.music.volume_db
	audio.music.seek(audio.music.stream.get_length() - 0.1)
	await create_timer(0.35).timeout
	check(audio.music.playing and audio.music.get_playback_position() < 1.0 and is_equal_approx(audio.music.volume_db, gain), "Upgrade music crosses loop boundary at unchanged player volume")
	graphics.select_mode(3)
	root.get_node("SignalBus").settings_updated.emit()
	audio.play_context("battle")
	check(audio.music.stream.resource_path.ends_with("combat_carnage.ogg") and audio.music.get_playback_position() >= 20.9, "Returning to Gothic restores selected combat track and offset")
	check(root.get_node("SaveHandler").row_divers_original_graphics and root.get_node("SaveHandler").row_divers_illustrated_graphics, "Gothic selections preserve saved art preference")
	var ui := Control.new()
	root.add_child(ui)
	load("res://Games/RowDivers/RowDiversArtControl.gd").install(ui)
	var control = ui.get_node("RuntimeArtStyle")
	control.upgrade_music = 2
	control.combat_music = 2
	control._process(.01)
	check(choices.upgrade_track == 2 and choices.combat_track == 2, "Remote inspector edits both session choices")
	if control.upgrade_picker != null:
		check(control.upgrade_picker.item_count == 3 and control.combat_picker.item_count == 3, "Three selectable tracks per context")
		control.upgrade_picker.item_selected.emit(1)
		control._process(.01)
		check(choices.upgrade_track == 1 and choices.combat_track == 2, "Upgrade dropdown changes only the upgrade selection")
	ui.free()
	audio.free()
	root.get_node("SaveHandler").row_divers_original_graphics = saved_original
	root.get_node("SaveHandler").row_divers_illustrated_graphics = saved_illustrated
	print("GOTHIC MUSIC: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
