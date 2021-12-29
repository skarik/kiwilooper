// Structure Definition for Vector3

/// @function Vector3(x, y, z) struct;
/// @param {Real} n_x
/// @param {Real} n_y
/// @param {Real} n_z
function Vector3(n_x, n_y, n_z) constructor
{
	// Default values
	x = n_x;
	y = n_y;
	z = n_z;
	
	// Functions
	
	static copy = function()
	{
		return new Vector3(x, y, z);
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
}