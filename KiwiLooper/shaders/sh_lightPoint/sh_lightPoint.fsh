//@desc Deferred surface lighting. Starts off with the ambient lighting.

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

uniform int uShadeType;

uniform sampler2D textureAlbedo;
uniform sampler2D textureNormal;
uniform sampler2D textureDepth;

#pragma include("LightingCommon.glsli")

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

float RectangleSolidAngle( vec3 worldPos, vec3 p0, vec3 p1, vec3 p2, vec3 p3)
{
	// Vector from each corner to the pixel being lit
	vec3 v0 = p0 - worldPos;
	vec3 v1 = p1 - worldPos;
	vec3 v2 = p2 - worldPos;
	vec3 v3 = p3 - worldPos;
	
	// Cross product of each edge
	vec3 n0 = normalize(cross(v0, v1));
	vec3 n1 = normalize(cross(v1, v2));
	vec3 n2 = normalize(cross(v2, v3));
	vec3 n3 = normalize(cross(v3, v0));
	
	// Angle between each edge
	float g0 = acos(dot(-n0, n1));
	float g1 = acos(dot(-n1, n2));
	float g2 = acos(dot(-n2, n3));
	float g3 = acos(dot(-n3, n0));

	// Sum the angles
	return g0 + g1 + g2 + g3 - 2.0 * 3.1415;
}// include("LightingCommon.glsli")

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
		
		// Pull light type first
		int lightType = int(uLightPositions[lightIndex].w + 0.5);
		
		// Pull light params
		vec4 lightPosition	= uLightPositions[lightIndex];
		vec4 lightColors	= uLightColors[lightIndex];
		vec4 lightParams	= uLightParams[lightIndex];
		vec4 lightDirection	= uLightDirections[lightIndex];
		vec4 lightOther		= uLightOthers[lightIndex];

		{
			vec3 point_to_light = lightPosition.xyz - pixelPosition;
			float point_to_light_len = length(point_to_light);
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_to_light_len * lightParams.y), 0.0, 1.0);
			
			// Do surface blending
			float surface_response = dot(point_to_light / point_to_light_len, pixelNormal);
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
		}
	}
	
	{
		gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
		gl_FragData[0].a = 1.0;
	}
}
