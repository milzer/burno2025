extends Node

const WIDTH = 320
const HEIGHT = 200

var heat_tex: Texture2D
var heat_image: Image

var fire_tex: Texture2D
var fire_buffer: PackedByteArray
var fire_image: Image
var fire_texture: ImageTexture
var palette: Array[Color] = []

@onready var fire_rect: TextureRect = $FireRect
@onready var fps_counter: Label = $FPS

@export var decay: int = 4


func _ready() -> void:
    await RenderingServer.frame_post_draw

    heat_tex = $HeatViewport.get_texture() as Texture2D
    assert(heat_tex, 'Failed to get heat texture')

    fire_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
    fire_texture = ImageTexture.create_from_image(fire_image)
    fire_rect.texture = fire_texture
    assert(fire_rect.texture)

    fire_buffer.resize(WIDTH * HEIGHT)
    fire_buffer.fill(0)

    palette.resize(256)
    for i in range(128):
        palette[i] = Color8(i * 2, 0, 0, 255)
        if i < 64:
            palette[i + 128] = Color8(255, i * 4, 0, 255)
            palette[i + 192] = Color8(255, 255, i * 4, 255)


func _process(_delta: float) -> void:
    await RenderingServer.frame_post_draw
    heat_image = heat_tex.get_image()
    assert(heat_image, 'Failed to get heat image')
    assert(heat_image.get_size() == Vector2i(WIDTH, HEIGHT), 'Heat image size mismatch')

    var heat_data = heat_image.get_data()

    var pixel_index: int
    var intensity: int

    for x in range(1, WIDTH - 2):
        fire_buffer[199 * WIDTH + x] = randi_range(0, 192)

    for y in range(HEIGHT - 1):
        for x in range(1, WIDTH - 2):
            pixel_index = (y * WIDTH) + x
            fire_buffer[pixel_index] = min(fire_buffer[pixel_index] + heat_data[pixel_index * 4] / 2, 255)

    for y in range(HEIGHT - 1):
        for x in range(1, WIDTH - 2):
            pixel_index = (y * WIDTH) + x
            intensity = (fire_buffer[pixel_index] + fire_buffer[pixel_index + WIDTH + randi_range(-1, 1)])
            intensity = max(intensity / 2 - decay, 0)

            fire_buffer[pixel_index] = intensity
            fire_image.set_pixel(x, y, palette[intensity])

    fire_texture.update(fire_image)

    fps_counter.text = str(Engine.get_frames_per_second())
