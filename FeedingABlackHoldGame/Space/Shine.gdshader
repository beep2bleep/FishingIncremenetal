shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float glow_size : hint_range(0.0, 0.5) = 0.1;
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float glow_falloff : hint_range(1.0, 5.0) = 2.0;

void fragment() {
    // Sample the sprite's original color and alpha
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Calculate distance from edge of sprite
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    // Create glow that extends beyond the sprite
    float edge_dist = 0.5 - dist;
    float glow = 0.0;
    
    if (edge_dist < glow_size) {
        float glow_factor = edge_dist / glow_size;
        glow = pow(glow_factor, glow_falloff) * glow_intensity;
    }
    
    // Combine sprite color with glow
    vec3 final_color = sprite_color.rgb;
    float final_alpha = sprite_color.a;
    
    if (sprite_color.a < 0.01 && glow > 0.0) {
        // Outside the sprite, just show glow
        final_color = glow_color.rgb;
        final_alpha = glow * glow_color.a;
    } else if (sprite_color.a > 0.01) {
        // Inside sprite, add glow to edges
        final_color = mix(sprite_color.rgb, glow_color.rgb, glow * 0.3);
        final_alpha = max(sprite_color.a, glow * glow_color.a);
    }
    
    COLOR = vec4(final_color, final_alpha);
}