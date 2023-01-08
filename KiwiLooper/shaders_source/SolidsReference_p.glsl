///@desc Deferred surface information

#pragma include("ShadingCommon.glsli")

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;
varying vec4 v_vAtlasParameters;

void main()
{
	// Calculate the texture-wrapping coordinate in the atlas
	vec2 coordWrapped = mod(v_vTexcoord.xy, 1.0) * 0.99 + vec2(0.005, 0.005);
	vec2 coordInAtlas = mix(v_vAtlasParameters.xy, v_vAtlasParameters.zw, coordWrapped);
	
	// Sample albedos
    vec4 baseAlbedo = texture2D( gm_BaseTexture, coordInAtlas ) * v_vColour;
	vec4 baseIllumin = vec4(0, 0, 0, 1.0);
	
	// TODO: make this a uniform for easy debugging?
	int shadeType = kShadeTypeDefault;//kShadeTypeDebug_Albedo;
	if (shadeType == kShadeTypeDefault)
	{
		// Early alphatest
		if (baseAlbedo.a < 0.5)
			discard;
	
		// Default no lighting (no glowmaps atm)
		vec3 totalLighting = baseIllumin.rgb;
	
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
	else if (shadeType == kShadeTypeDebug_Normals)
	{
		gl_FragData[0] = vec4(
			v_vNormal * 0.25 + vec3(0.5, 0.5, 0.5),
			1.0);
		gl_FragData[1] = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
		gl_FragData[2] = vec4(1.0, 1.0, 1.0, 1.0);
		gl_FragData[3] = vec4(encode_to_r8g8(v_vScreenPosition.z / v_vScreenPosition.w), 0, 1.0);
	}
	else if (shadeType == kShadeTypeDebug_Albedo)
	{
		gl_FragData[0] = baseAlbedo;
		gl_FragData[1] = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
		gl_FragData[2] = vec4(1.0, 1.0, 1.0, 1.0);
		gl_FragData[3] = vec4(encode_to_r8g8(v_vScreenPosition.z / v_vScreenPosition.w), 0, 1.0);
	}
}
