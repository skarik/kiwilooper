/// @function _drawShaderInit()
/// @desc Initializes shader draw state
function _drawShaderInit()
{
	global._draw_shaderLayerCurrentShader = null;
	global._draw_shaderLayerStoredShader = null;
}
gml_pragma("global", "_drawShaderInit()");

/// @function drawShaderSet(shader)
/// @desc Performs shader_set while keeping additional state.
/// @param {Shader} shader
function drawShaderSet(shader)
{
	gml_pragma("forceinline");
	
	if (shader != null)
	{
		global._draw_shaderLayerCurrentShader = shader;
		shader_set(shader);
	}
	else
	{
		global._draw_shaderLayerCurrentShader = null;
		shader_reset();
	}
}

/// @function drawShaderGet()
/// @desc Returns last set shader.
function drawShaderGet()
{
	gml_pragma("forceinline");
	
	return global._draw_shaderLayerCurrentShader;
}

/// @function drawShaderReset()
/// @desc Resets the current shader used for drawing.
function drawShaderReset()
{
	gml_pragma("forceinline");
	
	if (global._draw_shaderLayerCurrentShader != null)
	{
		shader_reset();
	}
	global._draw_shaderLayerCurrentShader = null;
}

/// @function drawShaderUnset(shader)
/// @desc Performs shader_reset, checking if input shader matches last shader_set()
/// @param {Shader} shader
function drawShaderUnset(shader)
{
	gml_pragma("forceinline");
	
	if (global._draw_shaderLayerCurrentShader != shader)
	{
		show_error("Incorrect shader passed into shader unset.", false);
	}
	shader_reset();
}

/// @function drawShaderStore()
/// @desc Stores the current shader for use later.
function drawShaderStore()
{
	global._draw_shaderLayerStoredShader = drawShaderGet();
}
/// @function drawShaderUnstore()
/// @desc Restores the saved shader for use.
function drawShaderUnstore()
{
	drawShaderSet(global._draw_shaderLayerStoredShader);
}