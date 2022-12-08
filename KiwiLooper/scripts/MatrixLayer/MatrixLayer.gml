/// @function _drawWorldMatrixInit()
/// @desc Initializes shader draw state
function _drawWorldMatrixInit()
{
	global._draw_matrixLayerWorldMatrix = null;
}
gml_pragma("global", "_drawWorldMatrixInit()");

/// @function drawWorldMatrixStore()
function drawWorldMatrixStore()
{
	gml_pragma("forceinline");
	global._draw_matrixLayerWorldMatrix = matrix_get(matrix_world);
}

/// @function drawWorldMatrixUnstore()
function drawWorldMatrixUnstore()
{
	gml_pragma("forceinline");
	matrix_set(matrix_world, global._draw_matrixLayerWorldMatrix);
}