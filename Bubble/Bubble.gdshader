shader_type spatial;

uniform sampler2D noise_texture;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0f;
uniform vec4 tint_color : source_color = vec4(0.2, 0.0, 1.0, 0.2);
uniform vec3 rim_color : source_color = vec3(0.2, 0.0, 1.0);
uniform float fresnel_power : hint_range(0.0, 10.0) = 2.0;
uniform float fresnel_offset : hint_range(0.0, 1.0) = 0.8;
uniform float distortion_speed : hint_range(0.1, 2.0) = 1.0;
uniform vec2 distortion_direction = vec2(1.0, 1.0);
uniform float distortion_scale : hint_range(0.1, 10.0) = 1.0;
uniform float distortion_factor : hint_range(0.1, 10.0) = 1.0;

// Ripple Effect
uniform float ripple_state : hint_range(0.0, 1.0) = 0.0;
uniform float ripple_strength : hint_range(0.0, 10.0) = 1.0;
uniform float ripple_speed : hint_range(0.0, 30.0) = 20.0;
uniform float point_strength : hint_range(0.1, 2.0) = 1.5;
uniform vec3 ripple_direction = vec3(0.0, 1.0, 0.0);


float fresnel(vec3 normal, vec3 view, float power) {
	return pow(1.0 - dot(normal, view), power);
}

float fractional_brownian_motion(vec2 point) {
	float value = 0.0;
	float amplitude = 0.5;
	float frequency = 1.0;

	for (int i = 0; i < 5; i++) {
		value += amplitude * texture(noise_texture, point * frequency).r;
		frequency *= 2.0;
		amplitude *= 0.5;
	}

	return value;
}

float calculate_distortion(vec2 uv) {
	vec2 distortion = distortion_direction * TIME * 0.1;
	vec2 distorted_point = uv * distortion_scale + distortion;
	return fractional_brownian_motion(distorted_point) * distortion_factor * 0.1;
}

float calculate_ripple(vec3 normal, float time) {
	float ripple_effect = dot(normal, normalize(ripple_direction));
	float ripple = sin(ripple_speed * (ripple_effect - time));
	float ripple_divisor = (ripple_effect + point_strength) * 1.5;
	float ripple_intensity = 0.1 * ripple / ripple_divisor * ripple_strength;
	return ripple_intensity * ripple_state;
}

void vertex() {
	// Called for every vertex the material is visible on.
	
	vec3 time_displacement = NORMAL * calculate_distortion(VERTEX.xy);
	vec3 ripple_displacement = NORMAL * calculate_ripple(NORMAL, TIME);
	VERTEX += time_displacement + ripple_displacement;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 view = normalize(VIEW);
	vec3 normal = normalize(NORMAL);

	float fresnel_term = fresnel(normal, view, fresnel_power);

	vec2 distortion = distortion_direction * TIME * 0.1;
	float noise_term = fractional_brownian_motion(UV * noise_scale + distortion);

	fresnel_term *= mix(0.8, 1.2, noise_term);

	vec3 final_color = tint_color.rgb + rim_color * fresnel_term;

	// Composite Material
	ALBEDO = final_color.rgb;
	EMISSION = vec3(0.0);
	ALPHA = clamp(fresnel_term, 0.0, 1.0) + tint_color.a;
	ROUGHNESS = 0.1;
	METALLIC = 0.8;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
