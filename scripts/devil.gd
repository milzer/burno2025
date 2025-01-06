class_name Devil
extends Area2D


var cooldown: float = 0.5
var click_timer: float = 0.0
var health: int = 3


signal devil_click(position: Vector2)
signal game_over()


func _ready() -> void:
    visible = true


func _process(delta: float) -> void:
    var mouse_pos = get_global_mouse_position()
    var to_mouse = (mouse_pos - global_position).normalized()
    if abs(to_mouse.angle() + PI / 2) < 0.5:
        $AnimatedSprite2D.play('devil_up')
    elif mouse_pos.x < 160:
        $AnimatedSprite2D.play('devil_left')
    else:
        $AnimatedSprite2D.play('devil_right')

    if click_timer >= 0.0:
        click_timer -= delta


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if click_timer <= 0.0:
            click_timer = cooldown
            devil_click.emit(get_global_mouse_position())


func damage() -> void:
    health -= 1
    if health <= 0:
        game_over.emit()
        visible = false
