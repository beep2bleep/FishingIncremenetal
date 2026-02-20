shader_type canvas_item;
// No blend_add, using default blend mode (blend_mix)

uniform float radius : hint_range(0.0, 1.0, 0.01) = 0.7;
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform vec4 color : source_color = vec4(0.9, 0.4, 0.1, 1.0);
uniform float angular_speed : hint_range(-5.0, 5.0, 0.01) = 2.5;
uniform float radial_speed : hint_range(-5.0, 5.0, 0.01) = 1.4;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D noise;

void fragment() {
    vec2 v = vec2(0.5) - UV;
    float d = length(v) * 2.0;
    float angle = atan(v.y, v.x) + (TIME * angular_speed);
    float thick_ratio = 1.0 - (abs(d - max(0.0, radius)) / max(0.0001, thickness));
    thick_ratio = clamp(thick_ratio, 0.0, 1.0);

    vec2 polar = fract(vec2(angle / 6.283185, d + (TIME * radial_speed)));
    vec3 tex = texture(noise, polar).rgb;

    float noise_alpha = (tex.r + tex.g + tex.b) / 3.0;
    float final_alpha = alpha * noise_alpha * thick_ratio;

    COLOR = vec4(color.rgb, final_alpha);
}
