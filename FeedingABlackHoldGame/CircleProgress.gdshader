shader_type canvas_item;
#define TWO_PI 6.28318530718

uniform vec3 primary_color: source_color = vec3(1.0);
uniform float alpha: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float value: hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float smooth_ = 0.005;
uniform float width_in = 0.85;
uniform float width_out = 0.95;
uniform float border_width = 0.03;
uniform float edge_smoothness = 0.02; // Controls anti-aliasing width

vec4 radial_progress(vec2 UV_, float VAL, float SMOOTH, float IR, float OR, float EDGE_SMOOTH)
{
	vec2 uv = (UV_ * 2.0) - 1.0;
	vec2 origin = vec2(0.0, 0.0);
	float ir = IR;
	float or = OR;
	
	float d = length(uv);
	float ring = smoothstep(or + SMOOTH, or - SMOOTH, d) - smoothstep(ir + SMOOTH, ir - SMOOTH, d);
	
	float a = atan(uv.y - origin.y, uv.x - origin.x);
	float theta = (a < 0.0) ? (a + TWO_PI) / TWO_PI : a / TWO_PI;
	
	// Replace hard step with smoothstep for anti-aliasing
	float bar = smoothstep(VAL + EDGE_SMOOTH, VAL - EDGE_SMOOTH, theta);
	
	float ui = ring * bar;
	vec4 colour = vec4(ui);
	return colour;
}

void fragment()
{
	COLOR = vec4(primary_color, alpha) * radial_progress(UV, value, smooth_, width_in, width_out, edge_smoothness);
}