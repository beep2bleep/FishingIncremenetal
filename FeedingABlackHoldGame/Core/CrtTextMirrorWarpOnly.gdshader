shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float barrel_distortion : hint_range(0.0, 0.2) = 0.055;

vec2 curve_uv(vec2 uv, float distortion) {
	vec2 centered = uv * 2.0 - 1.0;
	centered *= 1.0 + distortion * vec2(centered.y * centered.y, centered.x * centered.x);
	return centered * 0.5 + 0.5;
}

void fragment() {
	vec2 curved_uv = curve_uv(SCREEN_UV, barrel_distortion);
	if (
		curved_uv.x < 0.0 || curved_uv.x > 1.0 ||
		curved_uv.y < 0.0 || curved_uv.y > 1.0
	) {
		COLOR = vec4(0.0);
		return;
	}
	COLOR = textureLod(screen_texture, curved_uv, 0.0);
}
