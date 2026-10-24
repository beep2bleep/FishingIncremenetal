extends Node
const Graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
const Original = preload("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
const ILLUSTRATED_ROOT = "res://Games/RowDivers/Audio/Illustrated/"
static var illustrated_sources: Dictionary = {}
static var music_bookmarks: Dictionary = {}
const CUES = {"step": "Footstep", "shot": "BowShot", "hit": "Pop", "dagger": "Dagger", "coin": "GrabItem", "ability": "Ability", "purchase": "Click", "click": "Click", "hover": "Blop", "damage": "Damage", "death": "EnemyExplosion", "boss_death": "EnemyScream", "mini_death": "MiniEnemyScream", "gate": "Gate", "boss_hello": "zombieHello", "horn": "DarkHorn", "win": "Success", "lose": "GameOver", "lose_voice": "GameOverVoice", "beam": "LaserBeamShort"}
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var next_effect = 0
var streams: Dictionary = {}
var timers: Dictionary = {}
var presentation_rng := RandomNumberGenerator.new()
var music_context = ""
var presentation_mode = 0

static func illustrated_catalog() -> Dictionary:
	if illustrated_sources.is_empty(): illustrated_sources = JSON.parse_string(FileAccess.get_file_as_string(ILLUSTRATED_ROOT + "sources.json"))
	return illustrated_sources

func _ready() -> void:
	add_to_group("row_divers_audio")
	add_to_group("audio_cue_override")
	presentation_rng.randomize()
	presentation_mode = Graphics.mode()
	SignalBus.settings_updated.connect(_refresh_mode)
	music = MusicPlayer.get_node_or_null("RowDiversSessionMusic") as AudioStreamPlayer
	if music == null:
		music = preload("res://Games/RowDivers/RowDiversMenuMusic.gd").new()
		music.name = "RowDiversSessionMusic"
		music.volume_db = -22
		music.bus = "Music"
		MusicPlayer.add_child(music)
	for i in range(8):
		var player = AudioStreamPlayer.new()
		player.volume_db = -13
		player.bus = "Effects"
		add_child(player)
		effects.append(player)

func _refresh_mode() -> void:
	if presentation_mode == Graphics.mode(): return
	presentation_mode = Graphics.mode()
	for player in effects: player.stop()
	timers.clear()
	if not music_context.is_empty(): play_context(music_context)

func play_music(battle: bool) -> void:
	play_context("battle" if battle else "menu")

func play_context(context: String) -> void:
	_remember_music(music)
	music_context = context
	if _select_music_player(context): return
	var bookmark: Dictionary = music_bookmarks.get(_music_key(Graphics.mode(), context), {})
	if not bookmark.is_empty():
		music.stream = bookmark.stream
		music.volume_db = bookmark.volume_db
		music.pitch_scale = bookmark.pitch
		_start_music(float(bookmark.offset))
		return
	if Graphics.illustrated():
		var catalog := illustrated_catalog()
		var choices: Array = catalog.music_pools.get(context, catalog.music_pools.menu)
		var cue: String = choices[presentation_rng.randi_range(0, choices.size() - 1)]
		var entry: Dictionary = catalog.music[cue]
		music.stream = load(ILLUSTRATED_ROOT + entry.file)
		music.stream.loop = true
		music.volume_linear = float(entry.volume)
		music.pitch_scale = 1.0
		_start_music()
		return
	if Graphics.original():
		var cue: String = {"god": "GodRoomMusic", "credits": "CreditsMusic"}.get(context, "")
		if cue.is_empty(): cue = ("InGameMusic" if context == "battle" else "MainMenuMusic") + str(presentation_rng.randi_range(1, 3))
		var entry: Dictionary = Original.catalog().audio[cue]
		music.stream = load(Original.ROOT + "Audio/" + entry.file)
		music.volume_linear = float(entry.volume)
		music.pitch_scale = float(entry.pitch)
		music.stream.loop = true
		_start_music()
		return
	var battle := context == "battle"
	music.volume_db = -22
	var path = "res://Games/RowDivers/Audio/battle.wav" if battle else "res://Games/RowDivers/Audio/upgrades.wav"
	if ResourceLoader.exists(path):
		music.stream = load(path)
		if music.stream is AudioStreamWAV:
			music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			music.stream.loop_end = int(music.stream.get_length() * music.stream.mix_rate)
		_start_music()

func _select_music_player(context: String) -> bool:
	# The player outlives scene owners, so its offset is still available when
	# the next scene arrives. Matching contexts keep playing without a restart.
	if music.playing and int(music.get_meta("presentation_mode", -1)) == Graphics.mode() and str(music.get_meta("music_context", "")) == context:
		return true
	music.stop()
	return false

static func _music_key(mode: int, context: String) -> String:
	return str(mode) + ":" + context

static func _remember_music(player: AudioStreamPlayer) -> void:
	if not is_instance_valid(player) or not player.playing or player.stream == null: return
	if not player.has_meta("music_context"): return
	var key := _music_key(int(player.get_meta("presentation_mode")), str(player.get_meta("music_context")))
	music_bookmarks[key] = {"stream": player.stream, "offset": player.get_playback_position(), "volume_db": player.volume_db, "pitch": player.pitch_scale}

func _exit_tree() -> void:
	_remember_music(music)

func _start_music(offset = 0.0) -> void:
	music.set_meta("presentation_mode", Graphics.mode())
	music.set_meta("music_context", music_context)
	# Every restored track loops too; normalize offsets at the loop boundary.
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music.stream.loop_end = int(music.stream.get_length() * music.stream.mix_rate)
	elif music.stream is AudioStreamOggVorbis or music.stream is AudioStreamMP3:
		music.stream.loop = true
	var length := music.stream.get_length()
	music.play(fposmod(offset, length) if length > 0 else 0.0)

func sound(cue: String) -> void:
	if Graphics.illustrated():
		var entry: Dictionary = illustrated_catalog().effects.get(cue, {})
		if not entry.is_empty(): _play_entry(cue, entry, ILLUSTRATED_ROOT + entry.file, 0.08 if cue in ["shot", "hit", "coin", "damage", "beam"] else 0.0, false)
		return
	if Graphics.original():
		if CUES.has(cue): original_sound(CUES[cue], 0.0 if cue in ["click", "hover", "hit", "ability", "step"] else (0.1 if cue in ["shot", "dagger", "coin", "damage", "beam"] else 0.6))
		return
	var path = "res://Games/RowDivers/Audio/" + cue + ".wav"
	if ResourceLoader.exists(path):
		if not streams.has(cue): streams[cue] = load(path)
		var player = effects[next_effect % effects.size()]
		next_effect += 1
		player.stream = streams[cue]
		player.volume_db = -24.0 if cue == "step" else -13.0
		player.pitch_scale = presentation_rng.randf_range(0.94, 1.06)
		player.play()

func original_sound(cue: String, interval = 0.6) -> void:
	var entry: Dictionary = Original.catalog().audio.get(cue, {})
	if entry.is_empty(): return
	_play_entry(cue, entry, Original.ROOT + "Audio/" + entry.file, interval, true)

func _play_entry(cue: String, entry: Dictionary, path: String, interval: float, source_gain: bool) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now < float(timers.get(cue, -1.0)) + interval: return
	timers[cue] = now
	var player: AudioStreamPlayer
	for available in effects:
		if not available.playing:
			player = available
			break
	if player == null:
		player = AudioStreamPlayer.new()
		player.bus = "Effects"
		add_child(player)
		effects.append(player)
	if not streams.has(path): streams[path] = load(path)
	player.stream = streams[path]
	# The source sets volume and also passes it to PlayOneShot.
	player.volume_linear = float(entry.volume) * (float(entry.volume) if source_gain else 1.0)
	player.pitch_scale = presentation_rng.randf_range(0.9, 1.1) if cue == "Blop" else float(entry.pitch)
	player.play()

func override_audio_cue(type: int) -> bool:
	if not Graphics.original(): return false
	var cues := {
		SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER: "hover",
		SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_CLICK: "purchase",
		SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK: "click",
		SoundEffectSettings.SOUND_EFFECT_TYPE.GAME_MODE_HOVER: "hover",
	}
	if cues.has(type):
		sound(cues[type])
		return true
	return type in [SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_POP_IN, SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_LINE_FILL]
