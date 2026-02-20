shader_type canvas_item;

uniform float damage_fill : hint_range(0.0, 1.0); // 0.0 = no damage shown, 1.0 = fully damaged
uniform vec4 overlay_color : source_color = vec4(1.0, 0.0, 0.0, 0.6); // Red with some transparency

void fragment() {
    vec2 local_pos = UV; // UVs are normalized 0–1 inside the polygon

    // Fill from bottom to top based on damage_fill
    if (local_pos.y < (1.0 - damage_fill)) {
        discard; // Don't draw this part yet
    }

    COLOR = overlay_color;
}
