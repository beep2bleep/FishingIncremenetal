shader_type canvas_item;

uniform sampler2D texture_to_scroll;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

render_mode blend_mix;
uniform float strength: hint_range(0., 1.) = 0.6;     // how strong the gold overlay is
uniform float speed: hint_range(0., 10.) = 0.5;       // scroll speed
uniform float angle: hint_range(0., 360.) = 0.;       // scroll direction
uniform float transparency: hint_range(0., 1.) = 0.3; // how see-through the overlay is
uniform vec2 tiling = vec2(2.0, 2.0);                 // texture repeat amount
uniform float texture_scale: hint_range(0.1, 10.0) = 2.0; // smaller = bigger texture

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);

	float angle_rad = radians(angle);
	vec2 direction = vec2(cos(angle_rad), sin(angle_rad));

	// Apply scale and scroll
	vec2 scaled_uv = UV * texture_scale;
	vec2 scroll_uv = scaled_uv + direction * TIME * speed;

	vec4 scroll_tex = texture(texture_to_scroll, fract(scroll_uv));

	vec3 mixed = mix(base_color.rgb, scroll_tex.rgb, strength);
	COLOR = vec4(mixed, base_color.a * (1.0 - transparency));
}