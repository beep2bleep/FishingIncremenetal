shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform float target_vertical_resolution : hint_range(180.0, 480.0) = 320.0;
uniform float barrel_distortion : hint_range(0.0, 0.2) = 0.055;
uniform float scanline_strength : hint_range(0.0, 0.5) = 0.18;
uniform float grille_strength : hint_range(0.0, 0.3) = 0.08;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.38;
uniform float noise_strength : hint_range(0.0, 0.15) = 0.02;
uniform float chroma_offset : hint_range(0.0, 2.0) = 0.7;
uniform vec3 tint : source_color = vec3(1.0, 0.98, 0.92);

vec2 curve_uv(vec2 uv, float distortion) {
	vec2 centered = uv * 2.0 - 1.0;
	centered *= 1.0 + distortion * vec2(centered.y * centered.y, centered.x * centered.x);
	return centered * 0.5 + 0.5;
}

float hash(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233)) + TIME * 17.0) * 43758.5453123);
}

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect = viewport_size.x / viewport_size.y;
	vec2 curved_uv = curve_uv(SCREEN_UV, barrel_distortion);

	if (
		curved_uv.x < 0.0 || curved_uv.x > 1.0 ||
		curved_uv.y < 0.0 || curved_uv.y > 1.0
	) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	float pixel_height = 1.0 / target_vertical_resolution;
	vec2 pixel_size = vec2(pixel_height / aspect, pixel_height);
	vec2 snapped_uv = (floor(curved_uv / pixel_size) + 0.5) * pixel_size;
	vec2 chroma_shift = vec2(pixel_size.x * chroma_offset, 0.0);

	float red = texture(SCREEN_TEXTURE, snapped_uv + chroma_shift).r;
	float green = texture(SCREEN_TEXTURE, snapped_uv).g;
	float blue = texture(SCREEN_TEXTURE, snapped_uv - chroma_shift).b;
	vec3 color = vec3(red, green, blue);

	float scanline = 0.5 + 0.5 * sin(snapped_uv.y * viewport_size.y * 3.14159265);
	float grille = 0.5 + 0.5 * sin(snapped_uv.x * viewport_size.x * 6.2831853);
	color *= 1.0 - scanline * scanline_strength;
	color *= 1.0 - grille * grille_strength;

	float edge = distance(curved_uv, vec2(0.5)) * 1.85;
	float vignette = clamp(1.0 - edge * edge * vignette_strength, 0.0, 1.0);
	color *= vignette;
	color *= tint;
	color += (hash(snapped_uv * viewport_size) - 0.5) * noise_strength;

	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
