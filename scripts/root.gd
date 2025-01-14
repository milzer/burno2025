class_name Root
extends Node

@onready var game_scene: PackedScene = preload('res://scenes/game.tscn')

enum State {MAIN_MENU, IN_GAME, PAUSE_MENU}

var _state: State = State.MAIN_MENU:
    set = set_state

var _game: Game = null


func _ready() -> void:
    $GUI/MainMenu/CenterContainer/VBoxContainer/Start.connect('pressed', on_start)
    $GUI/MainMenu/CenterContainer/VBoxContainer/Quit.connect('pressed', on_quit)

    $GUI/PauseMenu/CenterContainer/VBoxContainer/Resume.connect('pressed', on_resume)
    $GUI/PauseMenu/CenterContainer/VBoxContainer/Quit.connect('pressed', on_quit_to_menu)


func _input(event: InputEvent) -> void:
    if event.is_action('ui_cancel'):
        if _game:
            get_tree().paused = true
            $GUI/PauseMenu.show()


func on_start() -> void:
    $GUI/MainMenu.hide()
    _game = game_scene.instantiate()
    add_child(_game)
    move_child(_game, 0)


func on_quit() -> void:
    get_tree().quit()


func on_resume() -> void:
    $GUI/PauseMenu.hide()
    get_tree().paused = false


func on_quit_to_menu() -> void:
    get_tree().paused = false
    _game.queue_free()
    _game = null
    $GUI/PauseMenu.hide()
    $GUI/MainMenu.show()


func set_state(state: State) -> void:
    _state = state
