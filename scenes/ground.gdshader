shader_type canvas_item;

uniform sampler2D world_texture : source_color;
uniform vec2 world_texture_size = vec2(64.0, 64.0);

varying vec2 WorldSpace;

void vertex() {
	WorldSpace = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float mask = texture(TEXTURE, UV).a;
	vec4 color = texture(world_texture, WorldSpace / world_texture_size);
	COLOR.rgb = color.rgb;
	color.a = color.a * mask;
}