class_name BurningPriest
extends AnimatedSprite2D


func _ready() -> void:
    print('burning priest ready')


func _process(delta: float) -> void:
    pass


func _on_burn_update(event: String, parent: Priest) -> void:
    if event == 'burn':
        frame = parent.frame
        print(frame)
        global_position = parent.global_position
    elif event == 'kill':
        queue_free()

func _exit_tree() -> void:
    print('burning priest exit')
