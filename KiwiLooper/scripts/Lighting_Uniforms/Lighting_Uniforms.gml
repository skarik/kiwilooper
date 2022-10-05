#macro kMaxLights 8

#macro kLightingModeForward		0
#macro kLightingModeDeferred	1

#macro kLightType_SpotAngle		0x01

#macro kLightType_Point			0x00
#macro kLightType_PointSpot		(kLightType_Point | kLightType_SpotAngle)
#macro kLightType_Sphere		0x02
#macro kLightType_SphereSpot	(kLightType_Sphere | kLightType_SpotAngle)
#macro kLightType_Rect			0x04
#macro kLightType_RectSpot		(kLightType_Rect | kLightType_SpotAngle)

///@function lightInitialize()
function lightInitialize()
{
	//global.lightingMode = kLightingModeForward;
	global.lightingMode = kLightingModeDeferred;
	
	// global for the clean hack for now
	
	global.m_uLightAmbientColor = shader_get_uniform(sh_litEnvironment, "uLightAmbientColor");
	global.m_uLightPositions = shader_get_uniform(sh_litEnvironment, "uLightPositions");
	global.m_uLightParams = shader_get_uniform(sh_litEnvironment, "uLightParams");
	global.m_uLightColors = shader_get_uniform(sh_litEnvironment, "uLightColors");
	
	// globals for the deferred pipeline
	
	global.gather_uniforms = shaderGetUniforms(sh_gatherEnvironment,
	[
		"uCameraInfo",
	]);
	
	// Test lighting shader
	global.deferred_uniforms = shaderGetUniforms(sh_compositeLighting,
	[
		"uLightCount",
		"uLightPositions",
		"uLightParams",
		"uLightColors",
		"uInverseViewProjection",
		"uCameraInfo",
		"uCameraPosition",
		"uViewInfo",
	]);
	global.deferred_samplers = shaderGetSamplers(sh_compositeLighting,
	[
		"textureAlbedo",
		"textureNormal",
		"textureDepth",
	]);
	
	// Ambient lighting shader
	global.deferred_ambient_uniforms = shaderGetUniforms(sh_lightAmbient,
	[
		"uLightAmbientColor",
		"uInverseViewProjection",
		"uCameraInfo",
		"uViewInfo",
	]);
	global.deferred_ambient_samplers = shaderGetSamplers(sh_lightAmbient,
	[
		"textureAlbedo",
		"textureNormal",
		"textureIllum",
		"textureDepth",
	]);
	
	// Point lighting shader
	global.deferred_point_uniforms = shaderGetUniforms(sh_lightPoint,
	[
		"uLightIndex",
		"uLightPositions",
		"uLightParams",
		"uLightColors",
		"uInverseViewProjection",
		"uCameraInfo",
		"uViewInfo",
	]);
	global.deferred_point_samplers = shaderGetSamplers(sh_lightPoint,
	[
		"textureAlbedo",
		"textureNormal",
		"textureDepth",
	]);
	
	// Rect lighting shader
	global.deferred_rect_uniforms = shaderGetUniforms(sh_lightRect,
	[
		"uLightIndex",
		"uLightPositions",
		"uLightParams",
		"uLightColors",
		"uLightDirections",
		"uLightOthers",
		"uInverseViewProjection",
		"uCameraInfo",
		"uViewInfo",
	]);
	global.deferred_rect_samplers = shaderGetSamplers(sh_lightRect,
	[
		"textureAlbedo",
		"textureNormal",
		"textureDepth",
	]);
	
	// General lighting shader
	global.deferred_general_uniforms = shaderGetUniforms(sh_lightGeneral,
	[
		"uLightIndex",
		"uLightPositions",
		"uLightParams",
		"uLightColors",
		"uLightDirections",
		"uLightOthers",
		"uInverseViewProjection",
		"uCameraInfo",
		"uViewInfo",
	]);
	global.deferred_general_samplers = shaderGetSamplers(sh_lightGeneral,
	[
		"textureAlbedo",
		"textureNormal",
		"textureDepth",
	]);
}

///@function lightPushUniforms(params)
function lightPushUniforms(params)
{
	if (global.lightingMode == kLightingModeForward)
	{
		return lightPushUniforms_Forward(params);
	}
	else if (global.lightingMode == kLightingModeDeferred)
	{
		show_error("Should not be called - deferred mode should push uniforms per pass", true);
		//return lightPushUniforms_Deferred(params);
	}
}

function lightPushUniforms_Forward(params)
{
	if (iexists(o_ambientOverride))
	{
		shader_set_uniform_f(global.m_uLightAmbientColor,
			color_get_red(o_ambientOverride.color) / 255.0,
			color_get_green(o_ambientOverride.color) / 255.0,
			color_get_blue(o_ambientOverride.color) / 255.0);
	}
	else
	{
		shader_set_uniform_f(global.m_uLightAmbientColor, 0.2, 0.3, 0.2);
	}
	shader_set_uniform_f_array(global.m_uLightPositions, params.positions);
	shader_set_uniform_f_array(global.m_uLightParams, params.params);
	shader_set_uniform_f_array(global.m_uLightColors, params.colors);
}

function lightPushGatherUniforms_Deferred()
{
	shader_set_uniform_f(global.gather_uniforms.uCameraInfo, o_Camera3D.znear, o_Camera3D.zfar, 0, 0);
}
/*function lightPushUniforms_Deferred(params)
{
	shader_set_uniform_i(global.deferred_uniforms.uLightCount, array_length(params.lightlist));
	shader_set_uniform_f_array(global.deferred_uniforms.uLightPositions, params.positions);
	shader_set_uniform_f_array(global.deferred_uniforms.uLightParams, params.params);
	shader_set_uniform_f_array(global.deferred_uniforms.uLightColors, params.colors);
	
	shader_set_uniform_f_array(global.deferred_uniforms.uInverseViewProjection, o_Camera3D.m_viewprojectionInverse);
	shader_set_uniform_f(global.deferred_uniforms.uCameraInfo, o_Camera3D.znear, o_Camera3D.zfar, 0.0, 0.0);
	shader_set_uniform_f(global.deferred_uniforms.uCameraPosition, o_Camera3D.x, o_Camera3D.y, o_Camera3D.z, 1.0);
	
	shader_set_uniform_f(global.deferred_uniforms.uViewInfo, GameCamera.width, GameCamera.height, 0, 0);
}*/

///@function lightDeferredPushUniforms_Ambient(albedo, normal, illum, depth)
function lightDeferredPushUniforms_Ambient(albedo, normal, illum, depth)
{
	if (iexists(o_ambientOverride))
	{
		shader_set_uniform_f(global.deferred_ambient_uniforms.uLightAmbientColor,
			color_get_red(o_ambientOverride.color) / 255.0,
			color_get_green(o_ambientOverride.color) / 255.0,
			color_get_blue(o_ambientOverride.color) / 255.0);
	}
	else
	{
		shader_set_uniform_f(global.deferred_ambient_uniforms.uLightAmbientColor, 0.2, 0.3, 0.2);
	}
	shader_set_uniform_f_array(global.deferred_ambient_uniforms.uInverseViewProjection, o_Camera3D.m_viewprojectionInverse);
	shader_set_uniform_f(global.deferred_ambient_uniforms.uCameraInfo, o_Camera3D.znear, o_Camera3D.zfar, 0.0, 0.0);
	shader_set_uniform_f(global.deferred_ambient_uniforms.uViewInfo, GameCamera.width, GameCamera.height, 0, 0);
	
	texture_set_stage(global.deferred_ambient_samplers.textureAlbedo, surface_get_texture(albedo));
	texture_set_stage(global.deferred_ambient_samplers.textureNormal, surface_get_texture(normal));
	texture_set_stage(global.deferred_ambient_samplers.textureIllum,  surface_get_texture(illum));
	texture_set_stage(global.deferred_ambient_samplers.textureDepth,  surface_get_texture(depth));
}
///@function lightDeferredPushUniforms_Point_Index(index)
function lightDeferredPushUniforms_Point_Index(index)
{
	shader_set_uniform_i(global.deferred_point_uniforms.uLightIndex, index);
}
///@function lightDeferredPushUniforms_Point(params, albedo, normal, depth)
function lightDeferredPushUniforms_Point(params, albedo, normal, depth)
{
	shader_set_uniform_f_array(global.deferred_point_uniforms.uLightPositions, params.positions);
	shader_set_uniform_f_array(global.deferred_point_uniforms.uLightParams, params.params);
	shader_set_uniform_f_array(global.deferred_point_uniforms.uLightColors, params.colors);
	
	shader_set_uniform_f_array(global.deferred_point_uniforms.uInverseViewProjection, o_Camera3D.m_viewprojectionInverse);
	shader_set_uniform_f(global.deferred_point_uniforms.uCameraInfo, o_Camera3D.znear, o_Camera3D.zfar, 0.0, 0.0);
	shader_set_uniform_f(global.deferred_point_uniforms.uViewInfo, GameCamera.width, GameCamera.height, 0, 0);
	
	texture_set_stage(global.deferred_point_samplers.textureAlbedo, surface_get_texture(albedo));
	texture_set_stage(global.deferred_point_samplers.textureNormal, surface_get_texture(normal));
	texture_set_stage(global.deferred_point_samplers.textureDepth,  surface_get_texture(depth));
}

///@function lightDeferredPushUniforms_General_Index(index)
function lightDeferredPushUniforms_General_Index(index)
{
	shader_set_uniform_i(global.deferred_general_uniforms.uLightIndex, index);
}
///@function lightDeferredPushUniforms_General(params, albedo, normal, depth)
function lightDeferredPushUniforms_General(params, albedo, normal, depth)
{
	shader_set_uniform_f_array(global.deferred_general_uniforms.uLightPositions, params.positions);
	shader_set_uniform_f_array(global.deferred_general_uniforms.uLightParams, params.params);
	shader_set_uniform_f_array(global.deferred_general_uniforms.uLightColors, params.colors);
	shader_set_uniform_f_array(global.deferred_general_uniforms.uLightDirections, params.directions);
	shader_set_uniform_f_array(global.deferred_general_uniforms.uLightOthers, params.others);
	
	shader_set_uniform_f_array(global.deferred_general_uniforms.uInverseViewProjection, o_Camera3D.m_viewprojectionInverse);
	shader_set_uniform_f(global.deferred_general_uniforms.uCameraInfo, o_Camera3D.znear, o_Camera3D.zfar, 0.0, 0.0);
	shader_set_uniform_f(global.deferred_general_uniforms.uViewInfo, GameCamera.width, GameCamera.height, 0, 0);
	
	texture_set_stage(global.deferred_general_samplers.textureAlbedo, surface_get_texture(albedo));
	texture_set_stage(global.deferred_general_samplers.textureNormal, surface_get_texture(normal));
	texture_set_stage(global.deferred_general_samplers.textureDepth,  surface_get_texture(depth));
}

///@function lightGatherLights()
function lightGatherLights()
{
	if (global.lightingMode == kLightingModeForward)
	{
		return lightGatherLights_Forward();
	}
	else if (global.lightingMode == kLightingModeDeferred)
	{
		return lightGatherLights_Deferred();
	}
}

function lightGatherLights_Forward()
{
	var lights = array_create(0);
	
	with (ob_3DLight)
	{
		// Skip invalid lights
		if (intensity <= 0.0 || range <= 1.0 || type != kLightType_Point)
		{
			continue;
		}
		
		// Save this light into the data we want
		lights[array_length(lights)] = id;
		
		// Break out if we have gathered 8 lights
		if (array_length(lights) >= kMaxLights)
		{
			break;
		}
	}
	
	// Now with the lights, we want to create a uniform array
	var light_position_array = array_create(4 * kMaxLights, 0);
	var light_params_array = array_create(4 * kMaxLights, 0);
	var light_color_array = array_create(4 * kMaxLights, 0);
	
	// Fill up lights
	for (var i = 0; i < array_length(lights); ++i)
	{
		light_position_array[i * 4 + 0] = lights[i].x;
		light_position_array[i * 4 + 1] = lights[i].y;
		light_position_array[i * 4 + 2] = lights[i].z;
		
		light_params_array[i * 4 + 0] = lights[i].intensity * lights[i].brightness; // TODO make this not here
		light_params_array[i * 4 + 1] = 1.0 / lights[i].range;
		
		light_color_array[i * 4 + 0] = color_get_red(lights[i].color) / 255.0;
		light_color_array[i * 4 + 1] = color_get_green(lights[i].color) / 255.0;
		light_color_array[i * 4 + 2] = color_get_blue(lights[i].color) / 255.0;
	}
	// Disable all the other lights
	for (var i = array_length(lights); i < kMaxLights; ++i)
	{
		light_params_array[i * 4 + 0] = 0.0;
	}
	
	return {
		positions:	light_position_array,
		params:		light_params_array,
		colors:		light_color_array,
	};
}

function lightGatherLights_Deferred()
{
	var lights = array_create(0);
	
	with (ob_3DLight)
	{
		// Skip invalid lights
		if (intensity <= 0.0 || range <= 1.0)
		{
			continue;
		}
		
		// Save this light into the data we want
		lights[array_length(lights)] = id;
		
		// Break out if we have gathered 8 lights
		if (array_length(lights) >= 32)
		{
			break;
		}
	}
	
	// Now with the lights, we want to create a uniform array
	var light_count = array_length(lights);
	var light_position_array = array_create(4 * 32, 0);
	var light_params_array = array_create(4 * 32, 0);
	var light_color_array = array_create(4 * 32, 0);
	var light_direction_array = array_create(4 * 32, 0);
	var light_other_array = array_create(4 * 32, 0);
	
	// Fill up lights
	for (var i = 0; i < array_length(lights); ++i)
	{
		var light = lights[i];
		
		// Position {X, Y, Z, Type}
		light_position_array[i * 4 + 0] = light.x;
		light_position_array[i * 4 + 1] = light.y;
		light_position_array[i * 4 + 2] = light.z;
		light_position_array[i * 4 + 3] = light.type;
		
		// Params {Brightness, Inverse Range, Inner Angle, Outer Angle}
		light_params_array[i * 4 + 0] = light.intensity * light.brightness; // TODO make this not here? should precalculate
		light_params_array[i * 4 + 1] = 1.0 / light.range;
		
		// Color {R, G, B}
		light_color_array[i * 4 + 0] = color_get_red(lights[i].color) / 255.0;
		light_color_array[i * 4 + 1] = color_get_green(lights[i].color) / 255.0;
		light_color_array[i * 4 + 2] = color_get_blue(lights[i].color) / 255.0;
		
		// todo: clean up this conditional and try to simplify branches
		
		if (light.type == kLightType_PointSpot)
		{
			// Params {Brightness, Inverse Range, Inner Angle, Outer Angle}
			light_params_array[i * 4 + 2] = light.innerAngleCos;
			light_params_array[i * 4 + 3] = light.outerAngleCos;
			
			// Direction {Forward XYZ, Width}
			light_direction_array[i * 4 + 0] = light.facingVector.x;
			light_direction_array[i * 4 + 1] = light.facingVector.y;
			light_direction_array[i * 4 + 2] = light.facingVector.z;
			
			// Other (Up XYZ, Height}
			light_other_array[i * 4 + 0] = light.upVector.x;
			light_other_array[i * 4 + 1] = light.upVector.y;
			light_other_array[i * 4 + 2] = light.upVector.z;
		}
		else if (light.type & kLightType_Rect)
		{
			if (light.type == kLightType_RectSpot)
			{
				// Params {Brightness, Inverse Range, Inner Angle, Outer Angle}
				light_params_array[i * 4 + 2] = light.innerAngleCos;
				light_params_array[i * 4 + 3] = light.outerAngleCos;
			}
			
			// Direction {Forward XYZ, Width}
			light_direction_array[i * 4 + 0] = light.facingVector.x;
			light_direction_array[i * 4 + 1] = light.facingVector.y;
			light_direction_array[i * 4 + 2] = light.facingVector.z;
			light_direction_array[i * 4 + 3] = light.yscale * 0.5; // Half-Width
			
			// Other (Up XYZ, Height}
			light_other_array[i * 4 + 0] = light.upVector.x;
			light_other_array[i * 4 + 1] = light.upVector.y;
			light_other_array[i * 4 + 2] = light.upVector.z;
			light_other_array[i * 4 + 3] = light.zscale * 0.5; // Half-Height
		}
	}
	// Disable all the other lights
	for (var i = array_length(lights); i < 32; ++i)
	{
		light_params_array[i * 4 + 0] = 0.0;
	}
	
	return {
		lightlist:	lights,
		positions:	light_position_array,
		params:		light_params_array,
		colors:		light_color_array,
		directions:	light_direction_array,
		others:		light_other_array,
	};
}
