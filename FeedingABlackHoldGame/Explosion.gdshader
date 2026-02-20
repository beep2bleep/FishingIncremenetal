shader_type canvas_item;

uniform float t : hint_range(0.0, 1.0); // Explosion progress
uniform vec4 color_inner : source_color = vec4(1.0, 1.0, 1.0, 1.0); // white
uniform vec4 color_mid   : source_color = vec4(1.0, 0.5, 0.0, 1.0); // orange
uniform vec4 color_outer : source_color = vec4(0.1, 0.1, 0.1, 1.0); // dark/outline

// Simple noise function (hash-based)
float hash21(vec2 p) {
    p = fract(p*vec2(123.34, 345.45));
    p += dot(p, p+34.345);
    return fract(p.x*p.y);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = hash21(i);
    float b = hash21(i+vec2(1.0,0.0));
    float c = hash21(i+vec2(0.0,1.0));
    float d = hash21(i+vec2(1.0,1.0));
    vec2 u = f*f*(3.0-2.0*f);
    return mix(a, b, u.x) +
           (c - a)* u.y * (1.0 - u.x) +
           (d - b)* u.x * u.y;
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0; // center
    float dist = length(uv);

    // Blob edge wobble
    float n = noise(uv * 6.0 + t*10.0);
    dist += (n - 0.5) * 0.1;

    // Explosion grows with time
    float radius = mix(0.0, 1.2, t);

    // Hard bands
    float band1 = step(dist, radius * 0.4);
    float band2 = step(dist, radius * 0.7);
    float band3 = step(dist, radius);

    vec4 col = vec4(0.0);

    if (band1 > 0.5) {
        col = color_inner;
    } else if (band2 > 0.5) {
        col = color_mid;
    } else if (band3 > 0.5) {
        col = color_outer;
    }

    // Fade out near the end
    col.a *= 1.0 - t;

    COLOR = col;
}
