//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;

uniform vec4 uLightAmbientColor;
uniform vec4 uLightPositions [8];
uniform vec4 uLightParams [8];
uniform vec4 uLightColors [8];

void main()
{
	vec4 baseAlbedo = texture2D( gm_BaseTexture, v_vTexcoord );
	
	// Early alphatest
	if (baseAlbedo.a < 0.5)
		discard;
	
	vec3 totalLighting = uLightAmbientColor.rgb * v_vColour.rgb;
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
			totalLighting += uLightColors[i].rgb * total_response;
		}
	}
	
	//gl_FragColor = (v_vColour + total_brightness) * texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
}
