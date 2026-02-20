extends AudioStreamPlayer
@export var playlist: AudioStreamPlaylist
@export var game_over_song: AudioStreamMP3
var playing_game_over: = false

func _ready() -> void :
    AudioServer.set_bus_volume_db(
        1, 
        linear_to_db(SaveHandler.music_volume * 3.0)
    )
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

func _on_finished() -> void :

    if playing_game_over:
        playing_game_over = false
        stream = playlist
        play()
