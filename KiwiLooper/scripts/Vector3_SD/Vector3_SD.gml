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
}