shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : hint_default_white,filter_nearest;
uniform bool clamp_diffuse_to_max = false;

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

uniform bool use_attenuation = true;

uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : hint_default_white,filter_nearest;

uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0f, 16.0f) = 8.0f;
uniform vec4 rim_color : source_color = vec4(1.0f);

uniform bool use_ramp = false;
uniform sampler2D ramp : hint_default_white;

uniform bool use_borders = false;
uniform float border_width = 0.01f;

group_uniforms Moss;
uniform sampler2D moss_noise_texture : hint_default_white,filter_nearest,repeat_enable;
uniform vec2 moss_texture_offset = vec2(0.0,0.0);
uniform float moss_texture_UV_scale : hint_range(1.0,10.0,0.1) = 2.0;
uniform vec3 moss_direction = vec3(0.0,1.0,0.0);
uniform float moss_wrap : hint_range(0.1, 10.0, 0.05) = 1.0;
uniform float moss_strength: hint_range(1.0,4.0,0.1) = 2.0;
uniform float moss_termination_value : hint_range (0.0,1.0,0.01) = 0.85;
uniform vec4 moss_albedo : source_color = vec4(1.0f);
group_uniforms;

varying float n_dot_moss_direction;
varying vec3 normal;

float split_specular(float specular) {
	return step(0.5f, specular);
}

void vertex() {
	n_dot_moss_direction = dot(NORMAL,normalize(moss_direction));
	normal = NORMAL;
}

void fragment() {
	float acos_ndot = acos(n_dot_moss_direction);
	float prod_mult = clamp(acos_ndot/(0.8*PI) * moss_wrap,0.0,1.0);
	float moss_texture_mask = clamp(pow(texture(moss_noise_texture,(UV + moss_texture_offset)/moss_texture_UV_scale).r,moss_strength),0.0,1.0);
	vec3 colored_mask = moss_albedo.rgb * texture(moss_noise_texture,(UV + moss_texture_offset)/moss_texture_UV_scale).r;
	vec3 color = albedo.rgb * texture(albedo_texture, UV).rgb;
	colored_mask = mix (color,colored_mask,step(0.15,moss_texture_mask));

	if (prod_mult >= moss_termination_value)
	{
		color = mix(color,colored_mask,prod_mult);
	}
	ALBEDO = color;
}

void light() {
	// Attenuation.
	float attenuation = 1.0f;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}

	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	//float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	float diffuse_amount = NdotL * attenuation + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);

	// Calculate borders.
	float border = 0.0f;
	if (use_borders) {
		float corr_border_width = length(cross(NORMAL, LIGHT)) * border_width * steepness;
		border = step(diffuse_stepped - corr_border_width, diffuse_amount)
				 - step(1.0 - corr_border_width, diffuse_amount);
	}

	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	if (use_ramp) {
		diffuse *= texture(ramp, vec2(diffuse_stepped * (1.0f - border), 0.0f)).rgb;
	} else {
		diffuse *= diffuse_stepped * (1.0f - border);
	}

	if (clamp_diffuse_to_max) {
		// Clamp diffuse to max for multiple light sources.
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse;
	}

	// Specular lighting.
	if (use_specular) {
		vec3 H = normalize(LIGHT + VIEW);
		float NdotH = dot(NORMAL, H);
		float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0f)
							    * texture(specular_map, UV).r
								* attenuation;
		specular_amount = split_specular(specular_amount);
		SPECULAR_LIGHT += specular_strength * specular_amount * LIGHT_COLOR;
	}

	// Simple rim lighting.
	if (use_rim) {
		float NdotV = dot(NORMAL, VIEW);
		float rim_light = pow(1.0 - NdotV, rim_width);
		DIFFUSE_LIGHT += rim_light * rim_color.rgb * rim_color.a * LIGHT_COLOR / PI;
	}
}