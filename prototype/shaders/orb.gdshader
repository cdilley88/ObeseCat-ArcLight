shader_type canvas_item;
uniform vec4 liquid_color : source_color = vec4(0.75, 0.04, 0.08, 1.0);
uniform float fill = 1.0;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float edge = 1.0 - smoothstep(0.96, 0.99, r);
	float glass = 1.0 - smoothstep(0.83, 0.85, r);
	float surface = 0.84 - clamp(fill, 0.0, 1.0) * 1.68;
	float wet = step(surface, p.y) * glass;
	float depth = 0.5 + 0.5 * sqrt(max(0.0, 1.0 - r * r));
	vec3 color = mix(vec3(0.18, 0.23, 0.27), vec3(0.025, 0.035, 0.05), glass);
	color = mix(color, liquid_color.rgb * depth, wet);
	color += liquid_color.rgb * 0.3 * wet * (1.0 - smoothstep(0.0, 0.035, abs(p.y - surface)));
	float shine = exp(-28.0 * dot(p - vec2(-0.3, -0.36), p - vec2(-0.3, -0.36)));
	color += vec3(0.7, 0.82, 0.88) * shine * 0.45 * glass;
	color += vec3(0.13) * (1.0 - smoothstep(0.0, 0.018, abs(r - 0.9)));
	COLOR = vec4(color, edge);
}
