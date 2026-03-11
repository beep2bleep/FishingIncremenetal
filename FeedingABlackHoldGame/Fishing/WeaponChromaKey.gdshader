shader_type canvas_item;

uniform vec4 dark_bg_color : source_color = vec4(0.6039, 0.6039, 0.6039, 1.0);
uniform vec4 light_bg_color : source_color = vec4(1.0, 1.0, 0.9922, 1.0);
uniform float dark_threshold : hint_range(0.0, 0.3) = 0.07;
uniform float light_threshold : hint_range(0.0, 0.3) = 0.09;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float dark_dist = distance(tex.rgb, dark_bg_color.rgb);
    float light_dist = distance(tex.rgb, light_bg_color.rgb);
    if (dark_dist <= dark_threshold || light_dist <= light_threshold) {
        discard;
    }
    COLOR = tex * COLOR;
}
