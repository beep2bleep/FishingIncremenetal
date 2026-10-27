shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D bat_texture : source_color, filter_linear_mipmap;
uniform float wing_phase = 0.0;
uniform float hit_flash = 0.0;
uniform vec4 level_tint : source_color = vec4(1.0);
void vertex() {
    // Dense quad subdivisions keep the body still while wing tips flap.
    float wing = smoothstep(0.18, 0.5, abs(UV.x - 0.5));
    VERTEX.y += sin(wing_phase) * wing * 0.10;
    VERTEX.z += cos(wing_phase) * wing * 0.08;
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}
void fragment() {
    vec4 sprite = texture(bat_texture, UV);
    ALBEDO = mix(sprite.rgb * level_tint.rgb, vec3(1.0, 0.85, 0.55), clamp(hit_flash, 0.0, 0.8));
    ALPHA = sprite.a;
    // Match the black exponential-squared distance fog on the other enemies.
    float depth = length(VERTEX);
    FOG = vec4(0.0, 0.0, 0.0, 1.0 - exp(-pow(depth * 0.14, 2.0)));
}
