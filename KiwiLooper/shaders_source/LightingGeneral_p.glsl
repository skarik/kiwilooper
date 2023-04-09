//@desc Deferred surface lighting. Starts off with the ambient lighting.

#pragma include("ShadingCommon.glsli")

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
	
#if SHADE_TYPE == kShadeType_Dynamic
	if (   uShadeType == kShadeTypeDefault
		|| uShadeType == kShadeTypeDebug_Lighting)
#endif
#if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDefault || SHADE_TYPE == kShadeTypeDebug_Lighting)
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
		
		// Get common light info
		int lightSmoothBits = int(lightColors.w + 0.5);
		//float	light_levels = float(lightSmoothBits & kLightFalloff_StepMask) + 1.0;
		float	light_levels = fract(float(lightSmoothBits) / float(kLightFalloff_StepMask + 1)) * float(kLightFalloff_StepMask + 1);
		//int		light_smoothstyle = lightSmoothBits & kLightFalloff_Smooth_Mask;
		int		light_smoothstyle = (lightSmoothBits / int(kLightFalloff_StepMask + 1)) * int(kLightFalloff_StepMask + 1);

#if LIGHT_TYPE == kLightType_Dynamic
		if (lightType == kLightType_Point)
#endif
#	if (LIGHT_TYPE == kLightType_Dynamic || LIGHT_TYPE == kLightType_Point)
		{
			vec3 point_to_light = lightPosition.xyz - pixelPosition;
			float point_to_light_len = length(point_to_light);
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_to_light_len * lightParams.y), 0.0, 1.0);
			if (attenuation <= 0.0) discard;
			
			// Do surface blending
			float surface_response = dot(point_to_light / point_to_light_len, pixelNormal);
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * surface_response;
			total_response = LevelTotalLight(total_response, light_levels, light_smoothstyle);
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
		}
#	endif
#if LIGHT_TYPE == kLightType_Dynamic
		else if (lightType == kLightType_PointSpot)
#endif
#	if (LIGHT_TYPE == kLightType_Dynamic || LIGHT_TYPE == kLightType_PointSpot)
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
			if (attenuation <= 0.0) discard;

			// Now do normal-direction attenuation
			float directional_attenuation = dot(point_to_light_direction, -light_forward);
			directional_attenuation = clamp((directional_attenuation - light_max_angle) / (light_min_angle - light_max_angle), 0.0, 1.0);
			
			// Do surface blending
			float surface_response = dot(point_to_light_direction, pixelNormal);
			
			//surface_response = clamp(surface_response * 0.5 + 0.5, 0.0, 1.0); // soft backfaces
			surface_response = clamp(surface_response, 0.0, 1.0);
			
			// Get total response
			float total_response = attenuation * directional_attenuation * surface_response;
			total_response = LevelTotalLight(total_response, light_levels, light_smoothstyle);
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
		}
#	endif
#if LIGHT_TYPE == kLightType_Dynamic
		else if (lightType == kLightType_Rect)
#endif
#	if (LIGHT_TYPE == kLightType_Dynamic || LIGHT_TYPE == kLightType_Rect)
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
			
			// Do distance attentuation
			float attenuation = clamp(1.0 - (point_closest_len * lightParams.y), 0.0, 1.0);
			if (attenuation <= 0.0) discard;

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
			total_response = LevelTotalLight(total_response, light_levels, light_smoothstyle);
			
			// Acculmulate this light's lighting
			totalLighting = lightColors.rgb * total_response * lightParams.x;
		}
#	endif
	}
#endif
	
#if SHADE_TYPE == kShadeType_Dynamic
	if (uShadeType == kShadeTypeDefault)
#endif
#	if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDefault)
	{
		gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
		gl_FragData[0].a = 1.0;
	}
#	endif
#if SHADE_TYPE == kShadeType_Dynamic
	else if (uShadeType == kShadeTypeDebug_Lighting)
#endif
#	if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDebug_Lighting)
	{
		gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0);
	}
#	endif
#if SHADE_TYPE == kShadeType_Dynamic
	else if (uShadeType == kShadeTypeDebug_Normals)
#endif
#	if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDebug_Normals)
	{
		gl_FragData[0] = vec4(pixelNormal.xyz * 0.5 + 0.5, 1.0);
	}
#	endif
#if SHADE_TYPE == kShadeType_Dynamic
	else if (uShadeType == kShadeTypeDebug_Albedo)
#endif
#	if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDebug_Albedo)
	{
		gl_FragData[0] = vec4(baseAlbedo.rgb, 1.0);
	}
#	endif
#if SHADE_TYPE == kShadeType_Dynamic
	else if (uShadeType == kShadeTypeDebug_AlbedoDarken)
#endif
#	if (SHADE_TYPE == kShadeType_Dynamic || SHADE_TYPE == kShadeTypeDebug_AlbedoDarken)
	{
		gl_FragData[0] = vec4((dot(pixelNormal, vec3(1, 0.707, 0.5)) * 0.2 + 0.7 ) * baseAlbedo.rgb, 1.0);
	}
#	endif
#if SHADE_TYPE == kShadeType_Dynamic
	// Fallback for warnings
	else
	{
		gl_FragData[0] = vec4(1.0, 0.0, 1.0, 1.0);
	}
#endif
}
