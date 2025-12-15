shader_type spatial;
//render_mode skip_vertex_transform;

uniform sampler2D noise_texture : hint_default_white,filter_nearest,repeat_enable;
uniform vec3 moss_direction = vec3(0.0,1.0,0.0);
uniform float moss_wrap : hint_range(0.1, 20.0, 0.1);
uniform vec4 moss_albedo : source_color = vec4(1.0f);
uniform sampler2D moss_texture : hint_default_white,filter_nearest,repeat_enable;

varying vec3 local_normal;
varying float dot_prod;

void vertex() {
	// Called for every vertex the material is visible on.
	//NORMAL = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	//VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	//NORMAL = normalize(MODEL_MATRIX * vec4(NORMAL,1.0)).xyz;
	local_normal = NORMAL;
	dot_prod = dot(NORMAL,normalize(moss_direction));

}

void fragment() {
	vec3 color = mix(ALBEDO,moss_albedo.rgb,texture(moss_texture,UV).r);
	float angle = acos(dot_prod);
	float prod_mult = clamp((angle/PI) * moss_wrap,0.0,1.0);
	ALBEDO = mix(ALBEDO,color,prod_mult);
	//ALBEDO = (INV_VIEW_MATRIX * vec4(NORMAL,0.0)).xyz;
	//vec3 normal = normalize(MODEL_NORMAL_MATRIX*NORMAL);
	// MaybeClamp
	//normal *= vec3(1.0,1.0,1.0);
	
	//float factor = NORMAL.y * texture(moss_texture,UV).r;
	//vec3 color = texture(moss_texture,UV).rgb * moss_albedo.rgb;
	//ALBEDO = mix (color,vec3(1.0,1.0,1.0),factor);
	
	// Called for every pixel the material is visible on.
}

