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
}