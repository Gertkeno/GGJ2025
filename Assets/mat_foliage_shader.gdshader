shader_type spatial;

render_mode diffuse_lambert, cull_disabled;

uniform sampler2D _texture: source_color, filter_linear_mipmap;
uniform sampler2D _noise: hint_default_white;

void fragment() {
	float a_clip = texture(_noise, UV).r;
	vec4 rgba = texture(_texture, UV);

	if (rgba.a < a_clip) {
		discard;
	}
	ALBEDO = rgba.rgb;
}
