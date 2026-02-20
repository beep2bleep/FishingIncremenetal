shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.3;
uniform vec4 hole_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	// Convert UV coordinates from [0,1] to [-1,1] centered space
	vec2 uv = UV * 2.0 - 1.0;
	
	// Calculate distance from center
	float dist = length(uv);
	
	// Anti-aliasing: smooth over approximately 1 pixel
	float aa_width = fwidth(dist);
	float alpha = smoothstep(radius + aa_width, radius - aa_width, dist);
	
	// Use hole_color with alpha determined by distance from center
	COLOR = vec4(hole_color.rgb, hole_color.a * alpha);
}