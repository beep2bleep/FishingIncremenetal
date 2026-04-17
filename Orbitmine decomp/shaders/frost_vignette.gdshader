shader_type canvas_item;

// ❄️ 서리 비네트 셰이더
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_val : hint_range(0.0, 1000.0) = 0.0;

void fragment() {
	// 꺼져 있으면 완전 투명
	if (intensity < 0.001) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}
	
	vec2 uv = UV;
	
	// 비네트: 가장자리일수록 큰 값
	vec2 cd = abs(uv - 0.5) * 2.0;
	float vig = max(cd.x, cd.y);
	float vig_r = length(cd);
	vig = mix(vig, vig_r, 0.3);
	
	// 서리 범위 (intensity에 따라 확장)
	float frost_start = 1.0 - intensity * 0.45;
	float mask = smoothstep(frost_start - 0.15, frost_start + 0.05, vig);
	
	// 간단 노이즈 (해시 기반)
	vec2 n1 = uv * 8.0 + vec2(time_val * 0.02, time_val * 0.015);
	float noise = fract(sin(dot(floor(n1), vec2(127.1, 311.7))) * 43758.5453);
	vec2 n2 = uv * 20.0 + vec2(time_val * 0.01);
	float detail = fract(sin(dot(floor(n2), vec2(269.5, 183.3))) * 43758.5453);
	
	// 노이즈로 경계 울퉁불퉁
	mask = smoothstep(frost_start - 0.15 + (noise - 0.5) * 0.12 * intensity,
	                   frost_start + 0.05, vig);
	
	// 결정 하이라이트
	float crystals = step(0.75, detail) * 0.3 * mask;
	
	// 모서리 강화
	float corner = smoothstep(0.85, 1.3, vig_r);
	mask += corner * 0.2 * intensity;
	
	// 최종 알파
	float alpha = mask * intensity * 0.5 + crystals * intensity;
	alpha = clamp(alpha, 0.0, 0.55);
	
	// 펄스
	alpha *= 0.92 + 0.08 * sin(time_val * 1.5);
	
	// 색상
	vec3 col = vec3(0.4, 0.75, 1.0);
	col = mix(col, vec3(0.85, 0.92, 1.0), crystals + corner * 0.3);
	
	COLOR = vec4(col, alpha);
}
