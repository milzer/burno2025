class_name Priest
extends AnimatedSprite2D


const DEVIL_POSITION = Vector2(160, 200 - 16)

var target: Vector2
var speed: int = 100
var last_distance_to_devil: float


signal burn_update(event: String, priest: Priest)


func random_target() -> Vector2:
    return Vector2(randi_range(16, 320 - 16), randi_range(16, 200 - 16))


func _ready() -> void:
    target = random_target()
    last_distance_to_devil = DEVIL_POSITION.distance_to(target)
    speed = randi_range(10, 50)
    play('priest_walk')

    await get_tree().create_timer(randf_range(2, 5)).timeout
    burn_update.emit('start', self)
    play('priest_burn')
    await get_tree().create_timer(randf_range(2, 5)).timeout
    burn_update.emit('update', self)
    await get_tree().create_timer(randf_range(0.5, 3)).timeout
    burn_update.emit('kill', self)
    queue_free()


func _process(delta: float) -> void:
    global_position.x = move_toward(global_position.x, target.x, delta * speed)
    global_position.y = move_toward(global_position.y, target.y, delta * speed)

    if global_position.distance_to(target) < 5:
        var a = randf() * PI * 2
        var v = Vector2(cos(a), -abs(sin(a))) * randf_range(last_distance_to_devil * 0.5, last_distance_to_devil * 0.9)
        target = DEVIL_POSITION + v
        last_distance_to_devil = DEVIL_POSITION.distance_to(target)
        speed = randi_range(10, 50)

    burn_update.emit('burn', self)


func _exit_tree() -> void:
    burn_update.emit('kill', self)
