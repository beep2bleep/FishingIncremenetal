shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform int effect_kind = 0;
uniform float effect_time = 0.0;
uniform sampler2D status_art : source_color, filter_linear_mipmap, repeat_disable;

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
    MODELVIEW_MATRIX[3].z += 0.18;
}

vec4 painted_mark(vec2 uv, vec2 center, vec2 size, float phase) {
    vec2 local = (uv - center) / size + vec2(0.5);
    // Preserve the painted silhouette and dark ink edges with a restrained,
    // stepped sway instead of a smooth procedural glow.
    local.x += sin(floor(effect_time * 10.0) * 0.45 + phase + local.y * 5.0) * 0.018;
    float inside = step(0.0, local.x) * step(local.x, 1.0) * step(0.0, local.y) * step(local.y, 1.0);
    vec4 paint = texture(status_art, clamp(local, vec2(0.0), vec2(1.0)));
    paint.a *= inside;
    return paint;
}

void fragment() {
    vec4 paint = vec4(0.0);
    if (effect_kind == 0) {
        // Three small tongues of the same illustrated flame used by fire waves.
        for (int i = 0; i < 3; i++) {
            float seed = float(i);
            float flicker = sin(floor(effect_time * 10.0) * 0.7 + seed * 2.3);
            vec2 center = vec2(0.25 + seed * 0.25, 0.47 + (i == 1 ? -0.06 : 0.04));
            vec2 size = vec2(0.34, 0.52 + 0.035 * flicker);
            vec4 tongue = painted_mark(UV, center, size, seed * 2.3);
            if (tongue.a > paint.a) paint = tongue;
        }
        paint.rgb *= 0.94;
        paint.a *= 0.9;
    } else {
        // Small, muted violet charms replace the neon ring and glowing wisps.
        for (int i = 0; i < 2; i++) {
            float seed = float(i);
            vec2 center = vec2(i == 0 ? 0.16 : 0.84, 0.40 + 0.13 * seed + sin(effect_time * 1.8 + seed * 2.7) * 0.025);
            vec4 mark = painted_mark(UV, center, vec2(0.24, 0.33), seed * 3.0);
            if (mark.a > paint.a) paint = mark;
        }
        paint.rgb *= vec3(0.84, 0.82, 0.89);
        paint.a *= 0.92;
    }
    ALBEDO = paint.rgb;
    ALPHA = paint.a;
    float depth = length(VERTEX);
    FOG = vec4(0.0, 0.0, 0.0, 1.0 - exp(-pow(depth * 0.14, 2.0)));
}
