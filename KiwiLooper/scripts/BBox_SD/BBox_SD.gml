// Structure Definition for BBox2 and BBox3 (and Rect2)
/// @function BBox3(center, extents) struct;
/// @param {Vector3} center
/// @param {Vector3} extents
function BBox3(n_center, n_extents) constructor
{
	center	= n_center;
	extents	= n_extents;
	
	static getMin = function()
	{
		return center.subtract(extents);
	}
	static getMax = function()
	{
		return center.add(extents);
	}
}

/// @function BBox3FromMinMax(min, max)
function BBox3FromMinMax(n_min, n_max)
{
	return new BBox3(n_min.add(n_max).multiply(0.5), n_max.subtract(n_min).multiply(0.5));
}

/// @function BBox2(center, extents) struct;
/// @param {Vector2} center
/// @param {Vector2} extents
function BBox2(n_center, n_extents) constructor
{
	center	= n_center;
	extents	= n_extents;
	
	static getMin = function()
	{
		return center.subtract(extents);
	}
	static getMax = function()
	{
		return center.add(extents);
	}
	static contains = function(x, y)
	{
		return point_in_rectangle(
			x, y,
			n_center.x - n_extents.x, n_center.y - n_extents.y,
			n_center.x + n_extents.x, n_center.y + n_extents.y);
	}
}

/// @function BBox2FromMinMax(min, max)
function BBox2FromMinMax(n_min, n_max)
{
	return new BBox2(n_min.add(n_max).multiply(0.5), n_max.subtract(n_min).multiply(0.5));
}


/// @function Rect2(min, max) struct;
/// @param {Vector2} min
/// @param {Vector2} max
function Rect2(n_min, n_max) constructor
{
	m_min	= new Vector2(n_min.x, n_min.y);
	m_max	= new Vector2(n_max.y, n_max.y);;
	
	static contains = function(x, y)
	{
		return point_in_rectangle(
			x, y,
			m_min.x, m_min.y,
			m_max.x, m_max.y);
	}
	
	static contains2 = function(vec)
	{
		return point_in_rectangle(
			vec.x, vec.y,
			m_min.x, m_min.y,
			m_max.x, m_max.y);
	}
	
	static expand1Self = function(dist)
	{
		m_min.x -= dist;
		m_min.y -= dist;
		m_max.x += dist;
		m_max.y += dist;
		return self;
	}
}

/// @function Rect2FromMinSize(min, size)
function Rect2FromMinSize(n_min, n_size)
{
	return new Rect2(n_min, n_min.add(n_size));
}