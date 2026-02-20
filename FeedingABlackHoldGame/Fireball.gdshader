shader_type canvas_item;

// Three flame colors for different noise intensity levels
uniform vec4 outer_color : source_color = vec4(1.0, 0.33, 0.068, 1.0); // Orange-red outer
uniform vec4 middle_color : source_color = vec4(1.0, 0.7, 0.1, 1.0); // Yellow-orange middle
uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.8, 1.0); // White-hot core

uniform float time_scale : hint_range(0.1, 5.0) = 2.0;
uniform float flame_speed : hint_range(0.5, 5.0) = 2.0;
uniform float roughness : hint_range(0.3, 1.0) = 0.675;
uniform float scale : hint_range(1.0, 10.0) = 4.0;
uniform int detail : hint_range(1, 6) = 4;

vec2 random2(vec2 st, float seed) {
    st = vec2(dot(st, vec2(127.1, 311.7)),
              dot(st, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123 * seed * 0.753421);
}

float map(float value, float fromMin, float fromMax, float toMin, float toMax) {
    value = (value - fromMin) / (fromMax - fromMin);
    value = toMin + value * (toMax - toMin);
    return value;
}

vec3 linearLight(vec3 a, vec3 b, float factor) {
    return a + factor * (2.0 * b - vec3(1.0));
}

float noise(vec2 st, float seed) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(random2(i + vec2(0.0, 0.0), seed), f - vec2(0.0, 0.0)),
                   dot(random2(i + vec2(1.0, 0.0), seed), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0), seed), f - vec2(0.0, 1.0)),
                   dot(random2(i + vec2(1.0, 1.0), seed), f - vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(float seed, vec2 st, float scale_val, int octaves, float roughness_val, float lacunarity) {
    float amplitude = 0.5;
    float frequency = 0.0;
    float value = 0.0;
    st *= scale_val;
    
    for (int i = 1; i < octaves; i++) {
        value += amplitude * noise(st, seed);
        st *= lacunarity;
        amplitude *= roughness_val;
    }
    return value * 0.5 + 0.5;
}

void fragment() {
    vec2 uv = UV;
    float uvX = uv.x;
    
    uv = (uv * 2.0 - 1.0);
    vec2 uvFlame = uv + vec2(TIME * flame_speed * time_scale, 0.0);
    
    float lacunarity = 2.0;
    float noise1d = fbm(24.0, uvFlame, scale, detail, roughness, lacunarity);
    vec3 noise3d = vec3(
        fbm(24.0, uvFlame, scale, detail, roughness, lacunarity),
        fbm(12.0, uvFlame, scale, detail, roughness, lacunarity),
        fbm(33.0, uvFlame, scale, detail, roughness, lacunarity)
    );
    
    float lightFactor = clamp(map(uvX, 0.13, 0.87, 1.0, 0.06), 0.06, 1.0);
    
    vec3 light = linearLight(vec3(uv * vec2(1.0, 1.0), 0.0), noise3d, lightFactor);
    light = abs(light) - vec3(0.75, 0.0, 0.0);
    light = max(light, vec3(0.0));
    float lightLength = length(light);
    
    float fireball_grad = clamp(map(uvX, -0.24, 1.0 , 0.0, 0.27), 0.0, 0.27);
    lightLength -= fireball_grad;
    lightLength = step(lightLength, -0.01);
    
    // Smooth noise without banding
    noise1d *= uvX;
    noise1d *= pow(uvX, 4.0);
    
    // Normalize noise to 0-1 range for color mapping
    float intensity = clamp(noise1d, 0.0, 1.0);
    
    // Smoothly blend between the three colors based on noise intensity
    vec3 color;
    if (intensity < 0.15) {
        color = core_color.rgb;
    } else if (intensity < 0.25) {
		color = middle_color.rgb;
    } else {
		color = outer_color.rgb;
    }
    
    float alpha = lightLength;
    
    COLOR = vec4(color, alpha);
}