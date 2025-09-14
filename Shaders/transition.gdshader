shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	vec2 uv2 = UV;
	uv.x = fract(uv.x * 25.0);
	//uv.x += fract(abs(1.0 - uv2.x) * 25.0);
	//uv.y = fract(uv.y * 25.0);
	COLOR = vec4(0.0, 0.0, 0.0, step(uv.x, progress));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
