extends AudioStreamPlayer
@export var playlist: AudioStreamPlaylist
@export var game_over_song: AudioStreamMP3
var playing_game_over: = false
var firewall_loading_pause_active := false

func _ready() -> void :
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
