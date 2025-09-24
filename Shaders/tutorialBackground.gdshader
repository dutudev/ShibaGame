shader_type canvas_item;

varying vec2 world_position;
void vertex(){
	  world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 uv = world_position.xy * 0.003;
	uv.x += TIME * 0.25;
	uv = fract(uv);
	uv = step(0.5, uv);
	float empty = uv.x * uv.y;
	uv.x = uv.x + uv.y;
	uv *= 1.0 - empty;
	uv.x *= 0.1;
	COLOR = vec4(uv.x, uv.x, uv.x, 1.0);
	//COLOR = vec4(uv.x, uv.y, 0.0, 1.0);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
