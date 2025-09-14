shader_type canvas_item;


void fragment() {
	vec2 uv = UV;
	uv.y += TIME / 40.0;
	COLOR = texture(TEXTURE, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
