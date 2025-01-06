extends Node2D

const BASE_ALPHA = 0.2

var size: float = 12.0
var color: Color = Color(1.0, 1.0, 1.0, BASE_ALPHA)
var angle: float = 0.0
var points: Array[Vector2]
var last_position: Vector2

func _ready() -> void:
    for i in range(5):
        points.append(Vector2(size * cos(angle + i * 2 * PI / 5), size * sin(angle + i * 2 * PI / 5)))


func _process(delta: float) -> void:
    var movement = last_position - global_position
    last_position = global_position
    color.a = min(BASE_ALPHA + movement.length() / 15.0, 1.0)
    rotation += delta
    queue_redraw()


func _draw() -> void:
    draw_circle(Vector2.ZERO, size + 0.5, color, false, 0.5, true)
    draw_polyline([points[0], points[2], points[4], points[1], points[3], points[0]], color, 0.5, true)


func _on_root_mouse_moved(x: int, y: int) -> void:
    global_position = Vector2(x, y)
    queue_redraw()
