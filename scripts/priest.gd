class_name Priest
extends Area2D


const DEVIL_POSITION = Vector2(Game.WIDTH / 2, Game.HEIGHT - 16)

var target: Vector2
var speed: int = 100
var last_distance_to_devil: float
var burning: bool = false
var devil_killed: bool = false


signal burn_update(event: String, priest: Priest)


func random_target() -> Vector2:
    return Vector2(randi_range(16, Game.WIDTH - 16), randi_range(16, Game.HEIGHT - 16))


func _ready() -> void:
    target = random_target()
    last_distance_to_devil = DEVIL_POSITION.distance_to(target)
    speed = randi_range(10, 50)
    $Sprite.play('priest_walk')


func start_burning(no_sound: bool = false) -> void:
    if has_signal('area_enterad'):
        disconnect('area_entered', _on_area_entered)

    if burning:
        return

    burning = true
    target = global_position
    burn_update.emit('start', self)
    $Sprite.play('priest_burn')

    if no_sound:
        return

    var audio_stream = AudioManager.get_priest_stream()
    assert(audio_stream, 'Failed to get priest stream')
    $AudioPlayer.stream = audio_stream
    $AudioPlayer.pitch_scale = randf_range(0.8, 1.3)
    $AudioPlayer.volume_db = randf_range(-5, 0)
    $AudioPlayer.connect('finished', _on_audio_finished)
    $AudioPlayer.play()


func kill_by_devil() -> void:
    start_burning(true)
    visible = false
    await get_tree().create_timer(0.2).timeout
    burn_update.emit('kill', self)
    queue_free()


func _process(delta: float) -> void:
    global_position.x = move_toward(global_position.x, target.x, delta * speed)
    global_position.y = move_toward(global_position.y, target.y, delta * speed)

    if global_position.distance_to(target) < 3:
        var a = randf() * PI * 2
        if burning:
            target = global_position + Vector2(cos(a), sin(a)) * randf_range(5, 20)
            target.x = clamp(target.x, 16, Game.WIDTH - 16)
            target.y = clamp(target.y, 16, Game.HEIGHT - 16)
            speed = randi_range(30, 60)
        else:
            var v = Vector2(cos(a), -abs(sin(a))) * randf_range(last_distance_to_devil * 0.3, last_distance_to_devil * 0.7)
            target = DEVIL_POSITION + v
            last_distance_to_devil = DEVIL_POSITION.distance_to(target)
            speed = randi_range(10, 50)

    if burning:
        burn_update.emit('update', self)

    if devil_killed:
        target = DEVIL_POSITION + (global_position - DEVIL_POSITION).normalized() * 1000.0


func _on_audio_finished() -> void:
    await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
    burn_update.emit('kill', self)
    queue_free()


func _on_area_entered(area: Area2D) -> void:
    if area is Devil and area.visible:
        disconnect('area_entered', _on_area_entered)
        kill_by_devil()
        area.damage()


func get_animation() -> String:
    return $Sprite.animation


func get_frame() -> int:
    return $Sprite.frame
