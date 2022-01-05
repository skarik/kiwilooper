// Structure Definition for Vector4

/// @function Vector4(x, y, z, w) struct;
/// @param {Real} n_x
/// @param {Real} n_y
/// @param {Real} n_z
/// @param {Real} n_w
function Vector4(n_x, n_y, n_z, n_w) constructor
{
	// Default values
	x = n_x;
	y = n_y;
	z = n_z;
	w = n_w;
	
	// Functions
	
	static copy = function()
	{
		return new Vector4(x, y, z, w);
	}
	
	static addSelf = function(right)
	{
		x += right.x;
		y += right.y;
		z += right.z;
		w += right.w;
		return self;
	}
	
	static multiplySelf = function(right)
	{
		x *= right;
		y *= right;
		z *= right;
		w *= right;
		return self;
	}
	
	static multiplyComponentSelf = function(right)
	{
		x *= right.x;
		y *= right.y;
		z *= right.z;
		w *= right.w;
		return self;
	}
	
	static getXYZ = function()
	{
		return new Vector3(x, y, z);
	}
	
	static transformAMatrixSelf = function(matrix)
	{
		gml_pragma("forceinline");
		
		var x0 = x;
		var y0 = y;
		var z0 = z;
		var w0 = w;
		
		x = matrix[ 0]*x0 + matrix[ 4]*y0 + matrix[ 8]*z0 + matrix[12]*w0;
		y = matrix[ 1]*x0 + matrix[ 5]*y0 + matrix[ 9]*z0 + matrix[13]*w0;
		z = matrix[ 2]*x0 + matrix[ 6]*y0 + matrix[10]*z0 + matrix[14]*w0;
		w = matrix[ 3]*x0 + matrix[ 7]*y0 + matrix[11]*z0 + matrix[15]*w0;
		
		return self;
	}
	
	static transformAMatrixTransposeSelf = function(matrix)
	{
		gml_pragma("forceinline");
		
		var x0 = x;
		var y0 = y;
		var z0 = z;
		var w0 = w;
		
		x = matrix[ 0]*x0 + matrix[ 1]*y0 + matrix[ 2]*z0 + matrix[ 3]*w0;
		y = matrix[ 4]*x0 + matrix[ 5]*y0 + matrix[ 6]*z0 + matrix[ 7]*w0;
		z = matrix[ 8]*x0 + matrix[ 9]*y0 + matrix[10]*z0 + matrix[11]*w0;
		w = matrix[12]*x0 + matrix[13]*y0 + matrix[14]*z0 + matrix[15]*w0;
		
		return self;
	}
}