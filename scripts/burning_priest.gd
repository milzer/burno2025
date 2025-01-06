class_name BurningPriest
extends AnimatedSprite2D


func _on_burn_update(event: String, parent: Priest) -> void:
    if event == 'kill':
        queue_free()
    elif event == 'update':
        animation = parent.get_animation()
        frame = parent.get_frame()
        global_position = parent.global_position
