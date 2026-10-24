shader_type spatial;
render_mode cull_disabled;
uniform sampler2D source_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint_color : source_color = vec4(1.0);
uniform vec2 source_scale = vec2(1.0);
uniform vec2 source_offset = vec2(0.0);
uniform bool transparent_surface = false;
uniform bool unlit_surface = false;
void fragment() {
	vec4 texel = texture(source_texture, UV * source_scale + source_offset) * tint_color;
	ALBEDO = unlit_surface ? vec3(0.0) : texel.rgb;
	EMISSION = unlit_surface ? texel.rgb : vec3(0.0);
	ROUGHNESS = 1.0;
#ifdef ORIGINAL_TRANSPARENT
	ALPHA = texel.a;
#endif
	// Unity RenderSettings mode 3 (exponential squared), density 0.14, black fog.
	float depth = length(VERTEX);
	FOG = vec4(0.0, 0.0, 0.0, 1.0 - exp(-pow(depth * 0.14, 2.0)));
}
