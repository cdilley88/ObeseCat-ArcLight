shader_type canvas_item;
uniform bool enabled = true;
void fragment() {
	float scan = enabled ? (0.024 + 0.018 * sin(FRAGCOORD.y * 3.14159)) : 0.0;
	vec2 p = UV * 2.0 - 1.0;
	float vignette = enabled ? dot(p, p) * 0.10 : 0.0;
	COLOR = vec4(0.01, 0.035, 0.045, scan + vignette);
}
