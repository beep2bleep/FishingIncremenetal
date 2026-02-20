shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 0.4, 0.1, 1.0);
uniform float lightness_increase : hint_range(0.0, 1.0) = 0.15;

uniform float radius_1 : hint_range(0.0, 1.0) = 0.1;
uniform float radius_2 : hint_range(0.0, 1.0) = 0.18;
uniform float radius_3 : hint_range(0.0, 1.0) = 0.26;
uniform float radius_4 : hint_range(0.0, 1.0) = 0.34;
uniform float radius_5 : hint_range(0.0, 1.0) = 0.42;
uniform float radius_6 : hint_range(0.0, 1.0) = 0.5;

uniform float rotation_speed_1 : hint_range(-2.0, 2.0) = 0.1;
uniform float rotation_speed_2 : hint_range(-2.0, 2.0) = 0.15;
uniform float rotation_speed_3 : hint_range(-2.0, 2.0) = 0.2;
uniform float rotation_speed_4 : hint_range(-2.0, 2.0) = 0.25;
uniform float rotation_speed_5 : hint_range(-2.0, 2.0) = 0.3;
uniform float rotation_speed_6 : hint_range(-2.0, 2.0) = 0.35;

uniform int num_points : hint_range(8, 32) = 16;
uniform float spike_sharpness : hint_range(0.0, 1.0) = 0.3;

uniform vec4 glow_color : source_color = vec4(1.0, 0.6, 0.2, 1.0);
uniform float glow_size : hint_range(0.0, 1.0) = 0.3;
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float glow_falloff : hint_range(1.0, 4.0) = 2.0;

uniform float scale : hint_range(0.1, 1.0) = 0.8;

void fragment() {
    vec2 uv = (UV - 0.5) / scale;
    
    float dist = length(uv);
    
    // Determine rotation speed based on distance
    float rotation_speed;
    if (dist < radius_1) {
        rotation_speed = rotation_speed_1;
    } else if (dist < radius_2) {
        rotation_speed = rotation_speed_2;
    } else if (dist < radius_3) {
        rotation_speed = rotation_speed_3;
    } else if (dist < radius_4) {
        rotation_speed = rotation_speed_4;
    } else if (dist < radius_5) {
        rotation_speed = rotation_speed_5;
    } else {
        rotation_speed = rotation_speed_6;
    }
    
    // Add rotation based on layer
    float angle = TIME * rotation_speed;
    float s = sin(angle);
    float c = cos(angle);
    uv = vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
    
    float theta = atan(uv.y, uv.x);
    
    // Create star points
    float star_angle = mod(theta + 3.14159, 6.28318 / float(num_points));
    float spike = cos(star_angle * float(num_points)) * spike_sharpness;
    float radius = dist - spike * 0.1;
    
    // Determine which layer we're in and calculate color
    vec3 color;
    int layer = 6;
    
    if (radius < radius_1) {
        layer = 1;
    } else if (radius < radius_2) {
        layer = 2;
    } else if (radius < radius_3) {
        layer = 3;
    } else if (radius < radius_4) {
        layer = 4;
    } else if (radius < radius_5) {
        layer = 5;
    } else if (radius < radius_6) {
        layer = 6;
    }
    
    // Calculate lightness based on layer (layer 6 = base color, layer 1 = lightest)
    float lightness_factor = float(6 - layer) * lightness_increase;
    color = base_color.rgb + vec3(lightness_factor);
    color = clamp(color, 0.0, 1.0);
    
    // Star alpha
    float alpha = step(radius, radius_6);
    
    // Add glow effect beyond the star
    if (radius > radius_6) {
        float glow_dist = (radius - radius_6) / glow_size;
        float glow = pow(1.0 - clamp(glow_dist, 0.0, 1.0), glow_falloff) * glow_intensity;
        color = glow_color.rgb;
        alpha = glow;
    }
    
    COLOR = vec4(color, alpha);
}