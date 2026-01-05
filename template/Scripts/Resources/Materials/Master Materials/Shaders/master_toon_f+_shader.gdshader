shader_type spatial;

group_uniforms albedo;
uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : hint_default_white,filter_nearest;
uniform bool clamp_diffuse_to_max = false;

group_uniforms normal;
uniform bool use_normal_texture = false;
uniform sampler2D normal_texture : hint_default_white,filter_nearest;

group_uniforms ambient_occlusion;
uniform bool use_ao_texture = false;
uniform sampler2D ao_texture : hint_default_white, filter_nearest;

group_uniforms toon;
uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

group_uniforms light;
uniform bool use_attenuation = true;

group_uniforms height;
uniform bool use_height_map = false;
uniform sampler2D height_map : hint_default_white,filter_nearest;
uniform float height_map_scale = 5.0f;
uniform int height_map_min_layers : hint_range(8, 64, 1) = 8;
uniform int height_map_max_layers : hint_range(8, 64, 1) = 32;
uniform int shadow_min_layers : hint_range(8, 64, 1) = 8;
uniform int shadow_max_layers : hint_range(8, 64, 1) = 32;
uniform vec2 height_map_flip = vec2(1.0);
uniform bool use_self_shadow = true;

group_uniforms specular;
uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : hint_default_white,filter_nearest;

group_uniforms rim;
uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0f, 16.0f) = 8.0f;
uniform vec4 rim_color : source_color = vec4(1.0f);

group_uniforms ramp;
uniform bool use_ramp = false;
uniform sampler2D ramp : hint_default_white;

group_uniforms border;
uniform bool use_borders = false;
uniform float border_width = 0.01f;

group_uniforms scaled;
uniform bool scaled = false;
uniform float texture_scale = 1.0;
uniform bool zy = false;
uniform bool yz = false;

varying vec3 vertex_pos;
varying vec3 normal;
varying vec2 base_uv;
varying vec2 scaled_uv;
varying mat3 tbn;

float split_specular(float specular) {
	return step(0.5f, specular);
}

float GetParallaxShadow(vec2 texCoord, vec3 lightDir)
{
    if ( lightDir.z >= 0.0 )
        return 0.0;

    float numLayers = mix(float(shadow_max_layers), float(shadow_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), lightDir)));

    vec2 currentTexCoords = texCoord;
    float currentDepthMapValue = 1.0 - texture(height_map, currentTexCoords).r;
    float currentLayerDepth = currentDepthMapValue;

    float layerDepth = 1.0 / numLayers;
    vec2 P = lightDir.xy / lightDir.z * height_map_scale * 0.01;
    vec2 deltaTexCoords = P / numLayers;

    while (currentLayerDepth <= currentDepthMapValue && currentLayerDepth > 0.0)
    {
        currentTexCoords += deltaTexCoords;
        currentDepthMapValue = 1.0 - texture(height_map, currentTexCoords).r;
        currentLayerDepth -= layerDepth;
    }

    float r = currentLayerDepth > currentDepthMapValue ? 0.0 : 1.0;
    return r;
}

void vertex() {
	vertex_pos = VERTEX;
	normal = NORMAL;
	if (scaled)
	{
		vec3 scale = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
		if (zy)
		{
			scaled_uv = vec2(UV.x * scale.z , UV.y * scale.y) * texture_scale;
		}
		else if (yz)
		{
			scaled_uv = vec2(UV.x * scale.y , UV.y * scale.z) * texture_scale;
		}
	}
}

void fragment() {
	base_uv = UV;
	if (scaled)
	{
		base_uv = scaled_uv;
	}
	if (use_height_map)
	{
		vec3 view_dir = normalize(normalize(-VERTEX + EYE_OFFSET) * mat3(TANGENT * height_map_flip.x, -BINORMAL * height_map_flip.y,NORMAL));
		float num_layers = mix(float(height_map_max_layers),float(height_map_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
		float layer_depth = 1.0 / num_layers;
		vec2 P = view_dir.xy / view_dir.z * height_map_scale * 0.01;
		vec2 delta = P / num_layers;
		vec2 ofs = base_uv;
		float depth = 1.0 - texture(height_map, ofs).r;
		float current_depth = 0.0;
		while(current_depth < depth) {
			ofs -= delta;
			depth = 1.0 - texture(height_map, ofs).r;
			current_depth += layer_depth;
		}
		vec2 prev_ofs = ofs + delta;
		float after_depth  = depth - current_depth;
		float before_depth = ( 1.0 - texture(height_map, prev_ofs).r  ) - current_depth + layer_depth;
		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs,prev_ofs,weight);
		base_uv = ofs;
	}
	ALBEDO = albedo.rgb * texture(albedo_texture, base_uv).rgb;
	if (use_ao_texture)
	{
		AO = texture(ao_texture,base_uv).r;
	}
	tbn = mat3(TANGENT,-BINORMAL,NORMAL);
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
	vec3 light = normalize(LIGHT);
	vec3 light_dir = -light * tbn;
	float shadow = GetParallaxShadow(base_uv,light_dir);
	
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
	if (use_self_shadow)
	{
		diffuse *= shadow;
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