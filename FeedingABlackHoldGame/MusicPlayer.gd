extends AudioStreamPlayer
@export var playlist: AudioStreamPlaylist
@export var game_over_song: AudioStream
var playing_game_over: = false
var firewall_loading_pause_active := false

func _ready() -> void :
    # Railway Fury supplies its own persistent session music. Avoid loading the
    # unrelated shared playlist into memory (and into the web demo's package).
    if Util.is_row_divers_game_active():
        playlist = AudioStreamPlaylist.new()
        finished.connect(_on_finished)
        return
    if playlist == null:
        playlist = load("res://Audio/Main Music Playlist.tres")
    if game_over_song == null:
        game_over_song = load("res://Audio/Music/3 - Phat Phrog Studio - Wayward Realm - Moonsong Kingdom.wav")
    # Volumes come from SaveHandler.set_audio() on startup; keep playlist flags in sync.
    update()

    stream = playlist
    play()

    finished.connect(_on_finished)



func update():
    playlist.shuffle = SaveHandler.shuffle_music


func play_game_over_song():
    if game_over_song:
        playing_game_over = true

        stream = game_over_song
        play()

func pause_for_firewall_loading() -> void:
    firewall_loading_pause_active = true
    stream_paused = true

func resume_after_firewall_loading() -> void:
    if not firewall_loading_pause_active:
        return
    firewall_loading_pause_active = false
    stream_paused = false
    if not playing:
        play()

func _on_finished() -> void :

    if playing_game_over:
        playing_game_over = false
        stream = playlist
        play()
