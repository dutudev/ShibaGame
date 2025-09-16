shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform sampler2D backgroudImage;
global uniform vec2 positionOffset;

void fragment() {
	vec2 uv = UV;
	vec2 uv2 = UV;
	uv.x = fract(uv.x * 25.0);
	//uv.x += fract(abs(1.0 - uv2.x) * 25.0);
	//uv.y = fract(uv.y * 25.0);
	vec2 normalizedUV = vec2((UV.x * (1100.0 / 700.0) / (1408.0 / 768.0)), UV.y) * 1.5;
	normalizedUV.x += positionOffset.x;
	normalizedUV.y += positionOffset.y;
	vec4 tex = clamp(texture(backgroudImage, fract(normalizedUV)) * 0.1, 0.0, 1.0);
	COLOR = vec4(tex.x, tex.y, tex.z, step(uv.x, progress));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
