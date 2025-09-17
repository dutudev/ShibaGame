shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
global uniform vec2 positionOffset;
uniform sampler2D backgroudImage;

void fragment() {
	vec2 uv = UV;
	uv -= vec2(0.5, 0.5);
	uv.x *= 1100.0/700.0;
	uv.x = length(uv);
	uv = step(progress, uv);
	vec2 normalizedUV = vec2((UV.x * (1100.0 / 700.0) / (1408.0 / 768.0)), UV.y) * 1.5;
	normalizedUV.x += positionOffset.x;
	normalizedUV.y += positionOffset.y;
	vec4 tex = clamp(texture(backgroudImage, fract(normalizedUV)) * 0.15, 0.0, 1.0);
	COLOR = vec4(tex.x, tex.y, tex.z, uv.x);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
