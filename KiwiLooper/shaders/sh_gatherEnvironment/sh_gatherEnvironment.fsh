///@desc Deferred surface information

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;

uniform vec4 uCameraInfo;

float linearize_depth( float depth, float zNear, float zFar )
{
	return zNear * zFar / (zFar + depth * (zNear - zFar));
}

vec2 encode_to_r8g8( float value )
{
	float low_prec = floor(value * 255.0) / 255.0;
	float high_prec = (value - low_prec) * 255.0;
	return vec2(low_prec, high_prec);
}

float decode_from_r8g8( vec2 value )
{
	return value.x + value.y / 255.0;
}

void main()
{
	vec4 baseAlbedo = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 bloodLightSkip = vec4(0.996, 0.388, 0.572, 1.0);
	
	// Early alphatest
	if (baseAlbedo.a < 0.5)
		discard;
	
	/*vec3 totalLighting = uLightAmbientColor.rgb * v_vColour.rgb;
	for (int i = 0; i < 8; ++i)
	{
		// X is brightness. We want to make sure there's brightness for this coordinate
		if (uLightParams[i].x > 0.0)
		{
			vec3 point_to_light = uLightPositions[i].xyz - v_vPosition;
			float point_to_light_len = length(point_to_light);
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_to_light_len * uLightParams[i].y), 0.0, 1.0);
			
			// Do surface blending
			float surface_response = dot(point_to_light / point_to_light_len, v_vNormal);
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting += uLightColors[i].rgb * total_response * uLightParams[i].x;
		}
	}
	
	// Now do blood skipping
	if (length(bloodLightSkip.rgb - baseAlbedo.rgb) < 0.02)
	{
		totalLighting = vec3(1.0, 1.0, 1.0);
	}*/
	
	vec3 totalLighting = vec3(0.0);// uLightAmbientColor.rgb * v_vColour.rgb;
	
	// Now do blood skipping
	if (length(bloodLightSkip.rgb - baseAlbedo.rgb) < 0.02)
	{
		totalLighting = vec3(1.0, 1.0, 1.0);
	}
	
	//gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
	//float linearDepth = linearize_depth(v_vScreenPosition.z / v_vScreenPosition.w, 600.0, 4000.0);
	//float linearDepth = linearize_depth(gl_FragCoord.z, uCameraInfo.x, uCameraInfo.y);
	float linearDepth = v_vScreenPosition.z / v_vScreenPosition.w;
	
	// 0 is Albedo
	// 1 is normalized Normals, half encoded
	// 2 is base illumination
	// 3 is depth
	// We recreate position based on normals
	gl_FragData[0] = baseAlbedo;
	gl_FragData[1] = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
	gl_FragData[2] = vec4(totalLighting.rgb, 1.0);
	gl_FragData[3] = vec4(encode_to_r8g8(linearDepth), 0, 1.0);
	
	//gl_FragData[0] = vec4(vec3(linearDepth), 1.0);
}
