// Structure Definition for Vector2 

/// @function Vector2(x, y) struct;
/// @param {Real} n_x
/// @param {Real} n_y
function Vector2(n_x, n_y) constructor
{
	// Default values
	x = n_x;
	y = n_y;
	
	// Functions
	
	static copy = function()
	{
		return new Vector2(x, y);
	}
	
	static addSelf = function(right)
	{
		x += right.x;
		y += right.y;
		return self;
	}
	static subtractSelf = function(right)
	{
		x -= right.x;
		y -= right.y;
		return self;
	}
	static multiplySelf = function(right)
	{
		x *= right;
		y *= right;
		return self;
	}
	static divideSelf = function(right)
	{
		x /= right;
		y /= right;
		return self;
	}
	
	static unbiasSelf = function()
	{
		x = x * 0.5 + 0.5;
		y = y * 0.5 + 0.5;
		return self;
	}
	
	static biasUVSelf = function(uvs)
	{
		x = lerp(uvs[0], uvs[2], x);
		y = lerp(uvs[1], uvs[3], y);
		return self;
	}
	
	static negateSelf = function()
	{
		x = -x;
		y = -y;
		return self;
	}
	
	static multiplyComponentSelf = function(right)
	{
		x *= right.x;
		y *= right.y;
		return self;
	}
	
	static add = function(right)
	{
		return new Vector2(x + right.x, y + right.y);
	}
	static subtract = function(right)
	{
		return new Vector2(x - right.x, y - right.y);
	}
	static multiply = function(right)
	{
		return new Vector2(x * right, y * right);
	}
	static divide = function(right)
	{
		return new Vector2(x / right, y / right);
	}
	
	static multiplyComponent = function(right)
	{
		return new Vector2(x * right.x, y * right.y);
	}
	
	static negate = function()
	{
		return new Vector2(-x, -y);
	}
	
	static lerp = function(right, t)
	{
		if (t <= 0)
			return new Vector2(x, y);
		else if (t >= 1)
			return new Vector2(right.x, right.y);
		else
		{
			return new Vector2(
				(right.x - x) * t + x,
				(right.y - y) * t + y
				);
		}
	}
	
	static dot = function(right)
	{
		return (x * right.x) + (y * right.y);
	}
	
	static cross = function(right)
	{
		return (x * right.y) - (y * right.x);
	}
	
	static rotate = function(angle)
	{
		var trueAngle = angle * pi / 180.0;
		m0 = cos(trueAngle);
		m3 = m0;
		m1 = sin(trueAngle);
		m2 = -m1;
		return new Vector2(
			m0 * x + m1 * y,
			m2 * x + m3 * y
			);
	}
	
	static rotateSelf = function(angle)
	{
		var result = rotate(angle);
		x = result.x;
		y = result.y;
		delete result;
		return self;
	}
	
	static sqrMagnitude = function()
	{
		return (x * x) + (y * y);
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
			return new Vector2(0, 0);
		}
		invMagnitude = 1.0 / invMagnitude;
		return self.multiply(invMagnitude);
	}
	
	static normalize = function()
	{
		var normal_result = self.normal();
		x = normal_result.x;
		y = normal_result.y;
		delete normal_result;
		return self;
	}
	
	static get = function(i)
	{
		if (i == 0)
			return x;
		else if (i == 1)
			return y;
		else
			show_error("Invalid index " + string(i) + "passed in for Vector2.get().", true);
		return 0.0;
	}
	
	static equals = function(right)
	{
		if (abs(x - right.x) > KINDA_SMALL_NUMBER)
			return false;
		if (abs(y - right.y) > KINDA_SMALL_NUMBER)
			return false;
		return true;
	}
	
	static toString = function()
	{
		if (sqrMagnitude() > 10)
		{
			return "{ x: " + string_format(x, 1, 0) + ", y: " + string_format(y, 1, 0) + " }";
		}
		else
		{
			return "{ x: " + string_format(x, 1, 2) + ", y: " + string_format(y, 1, 2) + " }";
		}
	}
}

/// @function Vector2FromLengthdir(length, dir)
/// @param {Real} length
/// @param {Real} dir
function Vector2FromLengthdir(length, dir)
{
	return new Vector2(lengthdir_x(length, dir), lengthdir_y(length, dir));
}

/// @function Vector2FromCopy(vector2)
/// @param {Vector2} vector2
function Vector2FromCopy(vector2)
{
	return vector2.copy();
}