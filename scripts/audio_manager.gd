extends AudioStreamPlayer


@export var priest: Array[AudioStream] = []
@export var devil: Array[AudioStream] = []
@export var gameover: AudioStream
@export var music: Array[AudioStream] = []

var priest_playlist: Array[int]
var devil_playlist: Array[int]
var music_playlist: Array[int]


func init_playlist(source: Array[AudioStream]) -> Array[int]:
    var playlist: Array[int] = []
    for i in range(source.size()):
        playlist.append(i)

    if playlist.size() > 2:
        playlist.shuffle()

    return playlist


func _ready() -> void:
    priest.shuffle()
    devil.shuffle()
    music.shuffle()

    priest_playlist = init_playlist(priest)
    devil_playlist = init_playlist(devil)
    music_playlist = init_playlist(music)

    connect('finished', _on_music_finished)
    _on_music_finished()


func get_from_playlist(playlist: Array[int], source: Array[AudioStream]) -> AudioStream:
    if source.size() == 0:
        return null

    if playlist.size() == 0:
        playlist = init_playlist(source)

    return source[playlist.pop_front()]


func get_priest_stream() -> AudioStream:
    return get_from_playlist(priest_playlist, priest)


func get_devil_stream() -> AudioStream:
    return get_from_playlist(devil_playlist, devil)


func _on_music_finished() -> void:
    await get_tree().create_timer(1).timeout
    stream = get_from_playlist(music_playlist, music)
    play()
