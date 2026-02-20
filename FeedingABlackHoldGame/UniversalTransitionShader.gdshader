shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.05);
uniform bool invert = false;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	float ratio = screen_size.x / screen_size.y;

	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, ratio), UV.y));
	float mask = step(circle_size, dist);

	// Flip mask if invert is true
	if (invert) {
		mask = 1.0 - mask;
	}

	COLOR.a = mask;
}
