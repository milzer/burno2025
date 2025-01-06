class_name Priest
extends AnimatedSprite2D


const DEVIL_POSITION = Vector2(160, 200 - 16)

var target: Vector2
var speed: int = 100
var last_distance_to_devil: float
var burning: bool = false


signal burn_update(event: String, priest: Priest)


func random_target() -> Vector2:
    return Vector2(randi_range(16, 320 - 16), randi_range(16, 200 - 16))


func _ready() -> void:
    target = random_target()
    last_distance_to_devil = DEVIL_POSITION.distance_to(target)
    speed = randi_range(10, 50)
    play('priest_walk')

    await get_tree().create_timer(randf_range(2, 5)).timeout
    start_burning()


func start_burning() -> void:
    burning = true
    target = global_position
    burn_update.emit('start', self)
    play('priest_burn')

    var audio_stream = AudioManager.get_priest_stream()
    assert(audio_stream, 'Failed to get priest stream')
    $AudioPlayer.stream = audio_stream
    $AudioPlayer.pitch_scale = randf_range(0.8, 1.3)
    $AudioPlayer.volume_db = randf_range(-5, 0)
    $AudioPlayer.connect('finished', _on_audio_finished)
    $AudioPlayer.play()


func _process(delta: float) -> void:
    global_position.x = move_toward(global_position.x, target.x, delta * speed)
    global_position.y = move_toward(global_position.y, target.y, delta * speed)

    if global_position.distance_to(target) < 3:
        var a = randf() * PI * 2
        if burning:
            target = global_position + Vector2(cos(a), sin(a)) * randf_range(5, 20)
            target.x = clamp(target.x, 16, 320 - 16)
            target.y = clamp(target.y, 16, 200 - 16)
            speed = randi_range(30, 60)
        else:
            var v = Vector2(cos(a), -abs(sin(a))) * randf_range(last_distance_to_devil * 0.5, last_distance_to_devil * 0.9)
            target = DEVIL_POSITION + v
            last_distance_to_devil = DEVIL_POSITION.distance_to(target)
            speed = randi_range(10, 50)

    if burning:
        burn_update.emit('update', self)


func _on_audio_finished() -> void:
    await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
    burn_update.emit('kill', self)
    queue_free()
