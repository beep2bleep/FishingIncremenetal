shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D flame : source_color, filter_linear;
uniform float phase = 0.0;
uniform vec4 level_tint : source_color = vec4(1.0);
void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.y * 13.0 + TIME * 8.0 + phase) * 0.025 * (1.0 - uv.y);
	vec4 paint = texture(flame, uv);
	ALBEDO = paint.rgb * level_tint.rgb * (0.94 + 0.10 * sin(TIME * 11.0 + phase));
	EMISSION = paint.rgb * level_tint.rgb * 0.35;
	ALPHA = paint.a;
}
