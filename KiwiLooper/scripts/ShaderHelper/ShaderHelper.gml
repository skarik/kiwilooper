function shaderGetUniforms(shader, uniformList)
{
	var struct = {};
	for (var i = 0; i < array_length(uniformList); ++i)
	{
		var uniform_index = shader_get_uniform(shader, uniformList[i]);
		variable_struct_set(struct, uniformList[i], uniform_index);
	}
	return struct;
}

function shaderGetSamplers(shader, uniformList)
{
	var struct = {};
	for (var i = 0; i < array_length(uniformList); ++i)
	{
		var sampler_index = shader_get_sampler_index(shader, uniformList[i]);
		variable_struct_set(struct, uniformList[i], sampler_index);
	}
	return struct;
}
