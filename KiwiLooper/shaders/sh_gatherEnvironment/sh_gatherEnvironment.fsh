///@desc Deferred surface information
//#extension GL_EXT_draw_buffers : enable

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;

uniform vec4 uCameraInfo;

/*layout(location = 0) out vec4 pixelAlbedo;
layout(location = 1) out vec4 pixelNormal;
layout(location = 2) out vec4 pixelIllum;
layout(location = 3) out vec4 pixelDepth;*/

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
	vec4 baseAlbedo = texture2D( gm_BaseTexture, v_vTexcoord ) * v_vColour;
	vec4 bloodLightSkip = vec4(0.996, 0.388, 0.572, 1.0);
	
	// Early alphatest
	if (baseAlbedo.a < 0.5)
		discard;
	
	vec3 totalLighting = vec3(0.0);
	
	// Now do blood skipping
	if (length(bloodLightSkip.rgb - baseAlbedo.rgb) < 0.02)
	{
		totalLighting = vec3(1.0, 1.0, 1.0);
	}
	
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
	/*pixelAlbedo = baseAlbedo;
	pixelNormal = vec4(normalize(v_vNormal.xyz) * 0.5 + 0.5, 1.0);
	pixelIllum = vec4(totalLighting.rgb, 1.0);
	pixelDepth = vec4(encode_to_r8g8(linearDepth), 0, 1.0);*/
	
	//gl_FragData[0] = vec4(vec3(linearDepth), 1.0);
}
