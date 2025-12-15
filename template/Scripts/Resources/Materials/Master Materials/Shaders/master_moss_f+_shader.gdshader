shader_type spatial;

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

void vertex() {
	n_dot_moss_direction = dot(NORMAL,normalize(moss_direction));
}

void fragment() {
	float acos_ndot = acos(n_dot_moss_direction);
	float prod_mult = clamp(acos_ndot/(0.8*PI) * moss_wrap,0.0,1.0);
	float moss_texture_mask = clamp(pow(texture(moss_noise_texture,(UV + moss_texture_offset)/moss_texture_UV_scale).r,moss_strength),0.0,1.0);
	vec3 colored_mask = moss_albedo.rgb * moss_texture_mask;
	colored_mask = mix (vec3(1.0),colored_mask,step(0.15,moss_texture_mask));
	vec3 color = vec3(1.0);
	if (prod_mult >= moss_termination_value)
	{
		color = mix(vec3(1.0),colored_mask,prod_mult);
	}
	
	ALBEDO = color;
}

