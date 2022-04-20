///@desc Deferred surface lighting. Performs up to 32 lights to composite.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 uLightAmbientColor;
uniform int uLightCount;
uniform vec4 uLightPositions [32];
uniform vec4 uLightParams [32];
uniform vec4 uLightColors [32];
uniform mat4 uInverseViewProjection;
uniform vec4 uCameraInfo;
uniform vec4 uCameraPosition;
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

void main()
{
	vec4 baseAlbedo = texture2D( textureAlbedo, v_vTexcoord );
	if (baseAlbedo.a < 0.5) discard;
	
	vec4 baseNormal = texture2D( textureNormal, v_vTexcoord );
	vec4 baseDepth  = texture2D( textureDepth,  v_vTexcoord );
	
	//vec3 pixelPosition = vec3(gl_FragCoord.xy, gl_FragCoord.z);
	vec3 pixelNormal = baseNormal.xyz * 2.0 - 1.0;
	
	float pixelDepth = decode_from_r8g8(baseDepth.rg);
	
	
	// Start with view coords
	vec4 viewCoords = vec4(
		(gl_FragCoord.x / uViewInfo.x - 0.5) * 2.0,
		(gl_FragCoord.y / uViewInfo.y - 0.5) * -2.0,
		pixelDepth,// * 2.0 - 1.0,
		1.0);
	// Transform to a view ray
	vec4 worldCoords = uInverseViewProjection * viewCoords;
	worldCoords.xyz = worldCoords.xyz / worldCoords.w;
	// And we have the final position
	vec3 pixelPosition = worldCoords.xyz;
	
	
	vec3 totalLighting = vec3(0, 0, 0);
	for (int i = 0; i < uLightCount; ++i)
	{
		// X is brightness. We want to make sure there's brightness for this coordinate
		if (uLightParams[i].x > 0.0)
		{
			vec3 point_to_light = uLightPositions[i].xyz - pixelPosition;
			float point_to_light_len = length(point_to_light);
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_to_light_len * uLightParams[i].y), 0.0, 1.0);
			
			// Do surface blending
			float surface_response = dot(point_to_light / point_to_light_len, pixelNormal);
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting += uLightColors[i].rgb * total_response * uLightParams[i].x;
		}
	}
	
	gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
	//gl_FragData[0].rgb = pixelPosition.xyz / 128.0 + 0.5;
	
	//gl_FragData[0].rgb = vec3(pixelDepth);
	
	//gl_FragData[0].rg = vec2(0.0);
	
	//gl_FragData[0].rgb = baseDepth.rgb;
	gl_FragData[0].a = 1.0;
}
