class_name Game
extends Control


const WIDTH: int = 320
const HEIGHT: int = 200

var heat_tex: Texture2D
var heat_image: Image

var fire_tex: Texture2D
var fire_buffer: PackedByteArray
var fire_image: Image
var fire_texture: ImageTexture
var palette: Array[Color] = []
var spawn_path = [
    Vector2(-32, HEIGHT - 32),
    Vector2(-32, -64),
    Vector2(WIDTH + 32, -32),
    Vector2(WIDTH + 32, HEIGHT - 64)
]

@onready var priest_scene = preload('res://scenes/priest.tscn')
@onready var burning_priest_scene = preload('res://scenes/burning_priest.tscn')

@export var fire_decay: int = 4
@export var initial_spawn_interval: float = 3.0

var spawn_interval: float


func _ready() -> void:
    process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
    await RenderingServer.frame_post_draw

    heat_tex = $HeatViewport.get_texture() as Texture2D
    assert(heat_tex, 'Failed to get heat texture')

    fire_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
    fire_texture = ImageTexture.create_from_image(fire_image)
    $FireRect.texture = fire_texture
    assert($FireRect.texture)

    fire_buffer.resize(WIDTH * HEIGHT)
    fire_buffer.fill(0)

    palette.resize(256)
    for i in range(128):
        palette[i] = Color8(i * 2, 0, 0, 255)
        if i < 64:
            palette[i + 128] = Color8(255, i * 4, 0, 255)
            palette[i + 192] = Color8(255, 255, i * 4, 255)

    start_game()


func start_game() -> void:
    spawn_interval = initial_spawn_interval

    spawn_priest()


func spawn_priest() -> void:
    var priest = priest_scene.instantiate()
    priest.connect('burn_update', _on_priest_burn_update)

    var i = randi_range(0, 2)
    priest.global_position = spawn_path[i].lerp(spawn_path[i + 1], randf())

    $Priests.add_child(priest)

    spawn_interval *= 0.99
    $SpawnTimer.wait_time = spawn_interval
    $SpawnTimer.one_shot = true
    $SpawnTimer.connect('timeout', spawn_priest, CONNECT_ONE_SHOT)
    $SpawnTimer.start()


func _process(delta: float) -> void:
    await RenderingServer.frame_post_draw
    heat_image = heat_tex.get_image()
    assert(heat_image, 'Failed to get heat image')
    assert(heat_image.get_size() == Vector2i(WIDTH, HEIGHT), 'Heat image size mismatch')

    var heat_data = heat_image.get_data()

    var pixel_index: int
    var intensity: int

    # bottom row always burns and indicates the devil's health
    var devil_health_mul = $Devil.get_health()
    for x in range(1, WIDTH - 2):
        fire_buffer[199 * WIDTH + x] = int(randf_range(devil_health_mul * 64, devil_health_mul * 256))

    for y in range(HEIGHT - 1):
        for x in range(1, WIDTH - 2):
            pixel_index = (y * WIDTH) + x
            intensity = (
                min(
                    fire_buffer[pixel_index]
                    + heat_data[pixel_index * 4] / 2,
                    255
                )
                + fire_buffer[pixel_index + WIDTH + randi_range(-1, 1)]
            )
            intensity = max(intensity / 2 - fire_decay, 0)

            fire_buffer[pixel_index] = intensity
            fire_image.set_pixel(x, y, palette[intensity])

    fire_texture.update(fire_image)

    $HeatViewport/Pentagram.global_position = get_global_mouse_position()

    # too lazy to add script for the death sprite
    var death_sprite: Sprite2D = $HeatViewport/DeathSprite
    if death_sprite.visible:
        death_sprite.scale += Vector2(delta, delta) * 7
        death_sprite.global_position.y -= 5.0 * delta
        death_sprite.modulate.a -= 0.15 * delta


func _on_priest_burn_update(event: String, parent: Priest) -> void:
    if event == 'start':
        var burning_priest = burning_priest_scene.instantiate()
        burning_priest._on_burn_update('update', parent)
        parent.disconnect('burn_update', _on_priest_burn_update)
        parent.connect('burn_update', burning_priest._on_burn_update)
        $HeatViewport.add_child(burning_priest)


func _on_devil_click(pos: Vector2) -> void:
    $HeatViewport/Pentagram.flash()

    for priest in $Priests.get_children():
        if priest is Priest:
            if priest.burning:
                continue

            if priest.global_position.distance_to(pos) < 16:
                priest.start_burning()
                break


func _on_devil_death() -> void:
    if $SpawnTimer.has_signal('timeout'):
        $SpawnTimer.disconnect('timeout', spawn_priest)

    for priest in $Priests.get_children():
        if priest is Priest:
            priest.devil_killed = true
            priest.speed *= randf_range(1.1, 1.5)

    $HeatViewport/Pentagram.visible = false
    $HeatViewport/DeathSprite.visible = true


func _on_game_over() -> void:
    $HeatViewport/DeathSprite.visible = false
    queue_free()
