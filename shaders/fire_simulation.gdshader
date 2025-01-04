shader_type canvas_item;

uniform sampler2D heat_tex;
uniform sampler2D old_fire_tex;
uniform float decay = 0.02;

void fragment() {
    float old_fire = texture(old_fire_tex, UV).r;
    float new_heat = texture(heat_tex, UV).r;

    float combined = old_fire + new_heat;

    float c1 = texture(heat_tex, UV + vec2(0.0, 1.0 / 200.0)).r;
    float c2 = texture(heat_tex, UV + vec2(-1.0 / 320.0, 1.0 / 200.0)).r;
    float c3 = texture(heat_tex, UV + vec2(1.0 / 320.0, 1.0 / 200.0)).r;
    float c4 = texture(heat_tex, UV + vec2(0.0, 2.0 / 200.0)).r;

    float heat = (c1 + c2 + c3 + c4 + combined) * 0.2;
    heat = max(heat - decay, 0.0);

    COLOR = vec4(vec3(heat), 1.0);
}