///@desc Deferred surface lighting. Starts off with the ambient lighting.

varying vec4 v_vColour;

uniform int uLightIndex;
uniform vec4 uLightPositions [32];
uniform vec4 uLightParams [32];
uniform vec4 uLightColors [32];
uniform vec4 uLightDirections [32];
uniform vec4 uLightOthers [32];
uniform mat4 uInverseViewProjection;
uniform vec4 uCameraInfo;
uniform vec4 uViewInfo;

uniform sampler2D textureAlbedo;
uniform sampler2D textureNormal;
uniform sampler2D textureDepth;

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

vec3 calculate_world_position( float depth )
{
	// Start with view coords
	vec4 viewCoords = vec4(
		(gl_FragCoord.x / uViewInfo.x - 0.5) * 2.0,
		(gl_FragCoord.y / uViewInfo.y - 0.5) * -2.0,
		depth,
		1.0);
		
	// Transform to world coords
	vec4 worldCoords = uInverseViewProjection * viewCoords;
	worldCoords.xyz = worldCoords.xyz / worldCoords.w;
	
	return worldCoords.xyz;
}

void main()
{
	// use gl_FragCoord to sample the textures. Render in 3D space
	
	vec2 pixelTexcoord = vec2(
		gl_FragCoord.x / uViewInfo.x,
		gl_FragCoord.y / uViewInfo.y
		);
	
	vec4 baseDepth  = texture2D( textureDepth,  pixelTexcoord );
	if (baseDepth.a < 0.5) discard;
	vec4 baseAlbedo = texture2D( textureAlbedo, pixelTexcoord );
	vec4 baseNormal = texture2D( textureNormal, pixelTexcoord );
	
	vec3	pixelNormal		= baseNormal.xyz * 2.0 - 1.0;
	float	pixelDepth		= decode_from_r8g8(baseDepth.rg);
	vec3	pixelPosition	= calculate_world_position(pixelDepth);
	
	
	vec3 totalLighting = vec3(0.0);
	{
		int lightIndex = uLightIndex;
		
		vec3 point_to_light = uLightPositions[lightIndex].xyz - pixelPosition;
		float point_to_light_len = length(point_to_light);
			
		// Do distance attentuation
		float attenuation = clamp(1.0 - (point_to_light_len * uLightParams[lightIndex].y), 0.0, 1.0);
			
		// Do surface blending
		float surface_response = dot(point_to_light / point_to_light_len, pixelNormal);
		//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
		surface_response = clamp(surface_response, 0.0, 1.0);
			
		// Get total response
		float total_response = attenuation * surface_response;
		total_response = ceil(total_response * 4.0) / 4.0;
			
		// Acculmulate this light's lighting
		totalLighting = uLightColors[lightIndex].rgb * total_response * uLightParams[lightIndex].x;
	}
	
	/*
	vec3 totalLighting = vec3(0.0);//uLightAmbientColor.rgb * v_vColour.rgb;
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
	}
	*/
	
	gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
	gl_FragData[0].a = 1.0;
}
