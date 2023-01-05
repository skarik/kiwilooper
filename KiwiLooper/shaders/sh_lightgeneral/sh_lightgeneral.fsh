///@desc Deferred surface lighting. Starts off with the ambient lighting.

#define kLightType_SpotAngle		0x02

#define kLightType_Ambient			0x00
#define kLightType_Point			0x01
//#define kLightType_PointSpot		(kLightType_Point | kLightType_SpotAngle)
#define kLightType_PointSpot		0x02
#define kLightType_Sphere			0x04
#define kLightType_SphereSpot		(kLightType_Sphere | kLightType_SpotAngle)
#define kLightType_Rect				0x08
#define kLightType_RectSpot			(kLightType_Rect | kLightType_SpotAngle)

#define kShadeTypeDefault				0
#define kShadeTypeDebug_Normals			1
#define kShadeTypeDebug_Albedo			2
#define kShadeTypeDebug_Lighting		3
#define kShadeTypeDebug_AlbedoDarken	4

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
	if (uShadeType == kShadeTypeDefault
		|| uShadeType == kShadeTypeDebug_Lighting)
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

		if (lightType == kLightType_Point)
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
		else if (lightType == kLightType_PointSpot)
		{
			// Grab light parameters needed
			vec3 light_forward = lightDirection.xyz;
			float light_min_angle = lightParams.z;
			float light_max_angle = lightParams.w;
			
			// Calculate needed point-to-light
			vec3 point_to_light = lightPosition.xyz - pixelPosition;
			float point_to_light_len = length(point_to_light);
			vec3 point_to_light_direction = point_to_light / point_to_light_len;
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_to_light_len * lightParams.y), 0.0, 1.0);
			
			// Now do normal-direction attenuation
			float directional_attenuation = dot(point_to_light_direction, -light_forward);
			directional_attenuation = clamp((directional_attenuation - light_max_angle) / (light_min_angle - light_max_angle), 0.0, 1.0);
			
			// Do surface blending
			float surface_response = dot(point_to_light_direction, pixelNormal);
			
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * directional_attenuation * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
		}
		else if (lightType == kLightType_Rect)
		{
			// Turn plane into a n.d definition
			vec3 light_forward = lightDirection.xyz;
			//vec4 light_plane = vec4(light_forward, dot(-light_forward, lightPosition.xyz));
			vec3 point_to_light_center = lightPosition.xyz - pixelPosition; // this is our offset from "origin"
			// Our point is now at origin. Make a plane representing that.
			vec4 light_plane = vec4(light_forward, dot(-light_forward, point_to_light_center));
			// Get closest point to origin
			vec3 point_on_plane = light_forward * light_plane.w;
			
			vec3 light_up		= lightOther.xyz;
			vec3 light_side		= cross(light_forward, light_up);
			
			float up_distance	= dot(light_up, point_on_plane - point_to_light_center); // Unit vectors, so divisor (projectionto^2) is 1.0
			float side_distance	= dot(light_side, point_on_plane - point_to_light_center);
			
			// Ensure our size is in range
			float light_width	= lightDirection.w;
			float light_height	= lightOther.w;
			up_distance = clamp(up_distance, -light_height, light_height);
			side_distance = clamp(side_distance, -light_width, light_width);
			
			// Get closest point for brightness
			vec3 point_closest = point_to_light_center + light_side * side_distance + light_up * up_distance;
			float point_closest_len = length(point_closest);
			
			// Grab each corner
			vec3 p0 = point_to_light_center + light_side * -light_width + light_up * light_height;
			vec3 p1 = point_to_light_center + light_side * -light_width + light_up * -light_height;
			vec3 p2 = point_to_light_center + light_side * light_width + light_up * -light_height;
			vec3 p3 = point_to_light_center + light_side * light_width + light_up * light_height;
			
			// Do point lighting 5 times to each one
			vec3 pc_delta = point_to_light_center;
			vec3 p0_delta = p0;
			vec3 p1_delta = p1;
			vec3 p2_delta = p2;
			vec3 p3_delta = p3;
			
			float pc_len = length(pc_delta);
			float p0_len = length(p0_delta);
			float p1_len = length(p1_delta);
			float p2_len = length(p2_delta);
			float p3_len = length(p3_delta);
			
			//float total_response = 
			//	clamp(1.0 - (point_to_light_len * lightParams.y), 0.0, 1.0) * dot(point_to_light / point_to_light_len, pixelNormal)
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_closest_len * lightParams.y), 0.0, 1.0);
			
			// Do normal attenuation
			//float normal_response = clamp(dot(normalize(point_closest), pixelNormal), 0.0, 1.0);
			// Have to solve the "horizon problem":
			float normal_response = 0.2 * (
				clamp(dot(normalize(p0), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p1), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p2), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p3), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(point_to_light_center), pixelNormal), 0.0, 1.0)
				); // for now, copy the homework and just sample multiple places & average out. it seems to be close enough for what we need
			
			// Do surface response
			float surface_response = RectangleSolidAngle(vec3(0, 0, 0), p0, p1, p2, p3);
			surface_response *= normal_response;
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
			
			// Pull the contribution of the rect (some distance atten via sizes?)
			/*float solidAngle = RectangleSolidAngle(pixelPosition, p0, p1, p2, p3);
			
			// Do surface blending
			float attenuation = solidAngle * 0.2 * (
				clamp(dot(normalize(p0 - pixelPosition), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p1 - pixelPosition), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p2 - pixelPosition), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(p3 - pixelPosition), pixelNormal), 0.0, 1.0) +
				clamp(dot(normalize(point_to_light_center), pixelNormal), 0.0, 1.0)
				);
			
			attenuation = max(0.0, attenuation);
			
			// Get total response
			float total_response = attenuation;// * surface_response;
			total_response = ceil(total_response * 4.0) / 4.0;
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;*/
			
			// Get our final closest point
			/*vec3 point_to_light = light_up * up_distance + light_side * side_distance + point_to_light_center;
			//vec3 point_to_light = point_on_plane;
			float point_to_light_len = length(point_to_light);
			
			// Now we do normal lighting:
			
			// Shit stolen from https://wickedengine.net/2017/09/07/area-lights/ as usual
			
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
			totalLighting = lightColors.rgb * total_response * lightParams.x;*/
		}
	}
	
	if (uShadeType == kShadeTypeDefault)
	{
		gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
		gl_FragData[0].a = 1.0;
	}
	else if (uShadeType == kShadeTypeDebug_Lighting)
	{
		gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0);
	}
	else if (uShadeType == kShadeTypeDebug_Normals)
	{
		gl_FragData[0] = vec4(pixelNormal.xyz * 0.5 + 0.5, 1.0);
	}
	else if (uShadeType == kShadeTypeDebug_Albedo)
	{
		gl_FragData[0] = vec4(baseAlbedo.rgb, 1.0);
	}
	else if (uShadeType == kShadeTypeDebug_AlbedoDarken)
	{
		gl_FragData[0] = vec4((dot(pixelNormal, vec3(1, 0.707, 0.5)) * 0.2 + 0.7 ) * baseAlbedo.rgb, 1.0);
	}
	// Fallback for warnings
	else
	{
		gl_FragData[0] = vec4(1.0, 0.0, 1.0, 1.0);
	}
}
