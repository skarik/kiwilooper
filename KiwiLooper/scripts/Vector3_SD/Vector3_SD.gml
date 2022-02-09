// Structure Definition for Vector3

/// @function Vector3(x, y, z) struct;
/// @param {Real} n_x
/// @param {Real} n_y
/// @param {Real} n_z
function Vector3(n_x, n_y, n_z) constructor
{
	// Default values
	x = is_real(n_x) ? n_x : 0.0;
	y = is_real(n_y) ? n_y : 0.0;
	z = is_real(n_z) ? n_z : 0.0;
	
	// Functions
	
	static set = function(n_x, n_y, n_z)
	{
		x = n_x;
		y = n_y;
		z = n_z;
	}
	
	static getElement = function(index)
	{
		gml_pragma("forceinline");
		if (index == 0) return x;
		else if (index == 1) return y;
		else if (index == 2) return z;
		return undefined;
	}
	
	static copy = function()
	{
		return new Vector3(x, y, z);
	}
	
	static copyFrom = function(right)
	{
		x = right.x;
		y = right.y;
		z = right.z;
	}
	
	static addSelf = function(right)
	{
		x += right.x;
		y += right.y;
		z += right.z;
		return self;
	}
	
	static subtractSelf = function(right)
	{
		x -= right.x;
		y -= right.y;
		z -= right.z;
		return self;
	}
	
	static multiplySelf = function(right)
	{
		x *= right;
		y *= right;
		z *= right;
		return self;
	}
	
	static multiplyComponentSelf = function(right)
	{
		x *= right.x;
		y *= right.y;
		z *= right.z;
		return self;
	}
	
	static divideSelf = function(right)
	{
		x /= right;
		y /= right;
		z /= right;
		return self;
	}
	
	static divideComponentSelf = function(right)
	{
		x /= right.x;
		y /= right.y;
		z /= right.z;
		return self;
	}
	
	static add = function(right)
	{
		return new Vector3(x + right.x, y + right.y, z + right.z);
	}
	static subtract = function(right)
	{
		return new Vector3(x - right.x, y - right.y, z - right.z);
	}
	static multiply = function(right)
	{
		return new Vector3(x * right, y * right, z * right);
	}
	static divide = function(right)
	{
		return new Vector3(x / right, y / right, z / right);
	}
	static multiplyComponent = function(right)
	{
		return new Vector3(x * right.x, y * right.y, z * right.z);
	}
	static divideComponent = function(right)
	{
		return new Vector3(x / right.x, y / right.y, z / right.z);
	}
	
	static rotateZ = function(angle)
	{
		var trueAngle = angle * pi / 180.0;
		m0 = cos(trueAngle);
		m3 = m0;
		m1 = sin(trueAngle);
		m2 = -m1;
		return new Vector3(
			m0 * x + m1 * y,
			m2 * x + m3 * y,
			z
			);
	}
	
	static rotateZSelf = function(angle)
	{
		var result = rotateZ(angle);
		x = result.x;
		y = result.y;
		z = result.z;
		delete result;
		return self;
	}
	
	static sqrMagnitude = function()
	{
		return (x * x) + (y * y) + (z * z);
	}
	
	static magnitude = function()
	{
		return sqrt(sqrMagnitude());
	}
	
	static normal = function()
	{
		var invMagnitude = magnitude();
		if (abs(invMagnitude) <= KINDA_SMALL_NUMBER)
		{
			return new Vector3(0, 0, 0);
		}
		invMagnitude = 1.0 / invMagnitude;
		return self.multiply(invMagnitude);
	}
	
	static normalize = function()
	{
		var normal_result = self.normal();
		x = normal_result.x;
		y = normal_result.y;
		z = normal_result.z;
		delete normal_result;
		return self;
	}
	
	static cross = function(right)
	{
		return new Vector3(
			y * right.z - z * right.y, 
			z * right.x - x * right.z,
			x * right.y - y * right.x);
	}
	
	static dot = function(right)
	{
		return x * right.x + y * right.y + z * right.z;
	}
	
	static transformAMatrix = function(matrix)
	{
		gml_pragma("forceinline");
		
		var x0 = x;
		var y0 = y;
		var z0 = z;
		var w0 = 1.0;
		
		return new Vector3(
			matrix[ 0]*x0 + matrix[ 4]*y0 + matrix[ 8]*z0 + matrix[12]*w0,
			matrix[ 1]*x0 + matrix[ 5]*y0 + matrix[ 9]*z0 + matrix[13]*w0,
			matrix[ 2]*x0 + matrix[ 6]*y0 + matrix[10]*z0 + matrix[14]*w0
			);
	}
	
	static transformAMatrixSelf = function(matrix)
	{
		gml_pragma("forceinline");
		
		var x0 = x;
		var y0 = y;
		var z0 = z;
		var w0 = 1.0;
		
		x = matrix[ 0]*x0 + matrix[ 4]*y0 + matrix[ 8]*z0 + matrix[12]*w0;
		y = matrix[ 1]*x0 + matrix[ 5]*y0 + matrix[ 9]*z0 + matrix[13]*w0;
		z = matrix[ 2]*x0 + matrix[ 6]*y0 + matrix[10]*z0 + matrix[14]*w0;
		//w = matrix[ 3]*x0 + matrix[ 7]*y0 + matrix[11]*z0 + matrix[15]*w0;
		return self;
	}
}

/// @function Vector3FromArray(array)
/// @desc Creates a Vector3 from an input array.
function Vector3FromArray(array)
{
	return new Vector3(array[0], array[1], array[2]);
}

/// @function Vector3FromTranslation(structure)
/// @desc Creates a Vector3 from an input structure.
function Vector3FromTranslation(structure)
{
	return new Vector3(structure.x, structure.y, structure.z);
}
/// @function Vector3FromScale(structure)
/// @desc Creates a Vector3 from an input structure.
function Vector3FromScale(structure)
{
	return new Vector3(structure.xscale, structure.yscale, structure.zscale);
}