shader_type canvas_item;

// --- Uniforms --- //
uniform vec2 speed = vec2(1.0, 0.0);
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // New color control

// --- Functions --- //
void fragment() {
	vec4 tex_color = texture(TEXTURE, mod(UV + TIME * speed, 1.0));
	COLOR = tex_color * tint_color;
}
