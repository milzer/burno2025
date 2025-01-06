class_name BurningPriest
extends AnimatedSprite2D


func _ready() -> void:
    print('burning priest ready')


func _process(delta: float) -> void:
    pass


func _on_burn_update(event: String, parent: Priest) -> void:
    if event == 'kill':
        queue_free()
    elif event == 'update':
        animation = parent.animation
        frame = parent.frame
        global_position = parent.global_position


func _exit_tree() -> void:
    print('burning priest exit')
