shader_type canvas_item;
uniform sampler2D symbols : source_color, filter_nearest, repeat_enable;
void fragment() {
	vec2 pixel = floor(UV * vec2(480.0, 300.0)) / vec2(480.0, 300.0);
	vec2 cloth = pixel * vec2(4.0, 2.5);
	cloth.x += TIME * .025;
	cloth.y += sin(cloth.x * 3.5 - TIME * .65) * .10;
	cloth.x += sin(cloth.y * 4.0 + TIME * .45) * .035;
	vec4 mark = texture(symbols, cloth);
	float fold = .75 + .25 * sin(pixel.x * 32.0 - TIME * .65 + pixel.y * 4.0);
	float grain = fract(sin(dot(floor(UV * vec2(960.0, 600.0)), vec2(12.9898,78.233))) * 43758.5453);
	vec3 base = vec3(.115,.108,.122) * fold + grain * .018;
	vec3 emblem = mix(vec3(.23,.19,.20), vec3(.33,.09,.14), step(.5, fract(cloth.y*.5)));
	COLOR = vec4(mix(base, emblem * fold, mark.a * .35), 1.0);
}
