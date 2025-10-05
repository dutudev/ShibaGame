shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	tex = vec4(clamp(tex.x + progress, 0.0, 1.0), clamp(tex.y + progress, 0.0, 1.0), clamp(tex.z + progress, 0.0, 1.0), tex.a);
	COLOR = tex;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
