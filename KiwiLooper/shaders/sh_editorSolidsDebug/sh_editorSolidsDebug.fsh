//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;

vec2 encode_to_r8g8( float value )
{
	float low_prec = floor(value * 255.0) / 255.0;
	float high_prec = (value - low_prec) * 255.0;
	return vec2(low_prec, high_prec);
}

void main()
{
    vec4 baseAlbedo = texture2D( gm_BaseTexture, v_vTexcoord ) * v_vColour;
	
	int shadeType = 1;
	
	if (shadeType == 0)
	{
		// Early alphatest
		if (baseAlbedo.a < 0.5)
			discard;
	
		// Default no lighting (no glowmaps atm)
		vec3 totalLighting = vec3(0.0);
	
		// Now do blood skipping
		vec4 bloodLightSkip = vec4(0.996, 0.388, 0.572, 1.0);
		if (length(bloodLightSkip.rgb - baseAlbedo.rgb) < 0.02)
		{
			totalLighting = vec3(1.0, 1.0, 1.0);
		}
	
		// Calculate custom depth
		float linearDepth = v_vScreenPosition.z / v_vScreenPosition.w;
		
		gl_FragData[0] = baseAlbedo;
		gl_FragData[1] = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
		gl_FragData[2] = vec4(totalLighting.rgb, 1.0);
		gl_FragData[3] = vec4(encode_to_r8g8(linearDepth), 0, 1.0);
	}
	else if (shadeType == 1)
	{
		gl_FragData[0] = vec4(
			v_vNormal * 0.25 + vec3(0.5, 0.5, 0.5),
			1.0);
		gl_FragData[1] = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
		gl_FragData[2] = vec4(1.0, 1.0, 1.0, 1.0);
		gl_FragData[3] = vec4(encode_to_r8g8(v_vScreenPosition.z / v_vScreenPosition.w), 0, 1.0);
	}
}
