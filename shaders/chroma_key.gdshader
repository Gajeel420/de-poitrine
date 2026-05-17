shader_type canvas_item;

uniform vec3 chroma_color : source_color = vec3(0.0, 1.0, 0.0);
uniform float threshold : hint_range(0.0, 1.0) = 0.35;
uniform float softness : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float dist = distance(col.rgb, chroma_color);
	float alpha = smoothstep(threshold - softness, threshold + softness, dist);
	COLOR = vec4(col.rgb, col.a * alpha);
}
