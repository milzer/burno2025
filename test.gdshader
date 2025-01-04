shader_type canvas_item;

uniform sampler2D palette;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(palette, vec2(UV.x * UV.y, 0)).rgba;
	// COLOR = vec4(UV.x, UV.y, 0.5, 1.0);
}
