shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv -= vec2(0.5, 0.5);
	uv.x *= 1100.0/700.0;
	uv.x = length(uv);
	uv = step(progress, uv);
	COLOR = vec4(0.0, 0.0, 0.0, uv.x);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
