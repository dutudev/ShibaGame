shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv *= 3.0;
	uv -= 1.0; 
	uv.y = clamp(uv.y, 0, progress);//0.42 start 0.58 end
	COLOR = texture(TEXTURE, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
