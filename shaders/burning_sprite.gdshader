shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (tex_color.a < 0.01) {
        discard;
    }

    float color_choice = step(0.5, fract(sin(dot(UV, vec2(312.534, -12.5634))) * TIME));
	float alpha = fract(cos(dot(UV, vec2(294.54334, 42.2475))) * TIME);

    COLOR = vec4(vec3(color_choice), alpha);
}
