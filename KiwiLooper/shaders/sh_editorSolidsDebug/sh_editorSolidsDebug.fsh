///@desc Deferred surface information

#pragma include("ShadingCommon.glsli")
// Shading types
#define kShadeTypeDefault				0
#define kShadeType_Dynamic				0xFF
#define kShadeTypeDebug_Normals			1
#define kShadeTypeDebug_Albedo			2
#define kShadeTypeDebug_Lighting		3
#define kShadeTypeDebug_AlbedoDarken	4

// Lighting types
#define kLightType_Dynamic			0xFF
#define kLightType_SpotAngle		0x02

#define kLightType_Ambient			0x00
#define kLightType_Point			0x01
//#define kLightType_PointSpot		(kLightType_Point | kLightType_SpotAngle)
#define kLightType_PointSpot		0x02
#define kLightType_Sphere			0x04
#define kLightType_SphereSpot		(kLightType_Sphere | kLightType_SpotAngle)
#define kLightType_Rect				0x08
#define kLightType_RectSpot			(kLightType_Rect | kLightType_SpotAngle)

// Default shade types
#ifndef SHADE_TYPE
#define SHADE_TYPE kShadeType_Dynamic
#endif

#ifndef LIGHT_TYPE
#define LIGHT_TYPE kLightType_Dynamic
#endif

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
// include("ShadingCommon.glsli")

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
