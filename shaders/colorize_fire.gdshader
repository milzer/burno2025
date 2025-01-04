shader_type canvas_item;

uniform sampler2D fire_texture;
uniform sampler2D palette_texture;

void fragment() {
	float intensity = texture(fire_texture, UV).r;

	if (intensity < 0.01)
	{
		discard;
	}

    COLOR = texture(palette_texture, vec2(intensity, 0.0));
}