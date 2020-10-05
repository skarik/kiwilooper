#macro kMaxLights 8

function lightInitialize()
{
	// global for the clean hack for now
	global.m_uLightAmbientColor = shader_get_uniform(sh_litEnvironment, "uLightAmbientColor");
	global.m_uLightPositions = shader_get_uniform(sh_litEnvironment, "uLightPositions");
	global.m_uLightParams = shader_get_uniform(sh_litEnvironment, "uLightParams");
	global.m_uLightColors = shader_get_uniform(sh_litEnvironment, "uLightColors");
}

function lightPushUniforms(params)
{
	shader_set_uniform_f(global.m_uLightAmbientColor, 0.2, 0.3, 0.2);
	shader_set_uniform_f_array(global.m_uLightPositions, params[0]);
	shader_set_uniform_f_array(global.m_uLightParams, params[1]);
	shader_set_uniform_f_array(global.m_uLightColors, params[2]);
}

function lightGatherLights()
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
		
		light_params_array[i * 4 + 0] = lights[i].intensity;
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
	
	return [light_position_array, light_params_array, light_color_array];
}