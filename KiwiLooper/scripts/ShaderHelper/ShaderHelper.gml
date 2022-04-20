function shaderGetUniforms(shader, uniformList)
{
	var struct = {};
	for (var i = 0; i < array_length(uniformList); ++i)
	{
		variable_struct_set(struct, uniformList[i], shader_get_uniform(shader, uniformList[i]));
	}
	return struct;
}

function shaderGetSamplers(shader, uniformList)
{
	var struct = {};
	for (var i = 0; i < array_length(uniformList); ++i)
	{
		variable_struct_set(struct, uniformList[i], shader_get_sampler_index(shader, uniformList[i]));
	}
	return struct;
}
