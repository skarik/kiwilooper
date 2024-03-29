// Structure Definition for BBox2 and BBox3 (and Rect2)
/// @function BBox3(center, extents) struct;
/// @param {Vector3} center
/// @param {Vector3} half-extents
function BBox3(n_center, n_extents) constructor
{
	// Center of the box
	center	= n_center;
	// Half extents
	extents	= n_extents;
	
	static getMin = function()
	{
		gml_pragma("forceinline");
		return center.subtract(extents);
	}
	static getMax = function()
	{
		gml_pragma("forceinline");
		return center.add(extents);
	}
	
	static overlaps = function(right)
	{
		gml_pragma("forceinline");
		return (center.x - extents.x <= right.center.x + right.extents.x
			&& center.x + extents.x >= right.center.x - right.extents.x
			&& center.y - extents.y <= right.center.y + right.extents.y
			&& center.y + extents.y >= right.center.y - right.extents.y
			&& center.z - extents.z <= right.center.z + right.extents.z
			&& center.z + extents.z >= right.center.z - right.extents.z);
	}
	
	static contains = function(right)
	{
		gml_pragma("forceinline");
		return (abs(right.x - center.x) < extents.x
			&& abs(right.y - center.y) < extents.y
			&& abs(right.z - center.z) < extents.z);
	}
	
	static distanceToPlane = function(plane)
	{
		gml_pragma("forceinline");
		
		// Project the half extents of the AABB onto the plane normal
		var length = 
			extents.x * abs(plane.n.x)
			+ extents.y * abs(plane.n.y)
			+ extents.z * abs(plane.n.z);
	
		// Find the distance from the center of the AABB to the plane
		var distance = plane.n.dot(center) + plane.d;
		global._mathresult_sign = sign(distance);
		// Intersection occurs if the distance falls within the projected side
		return abs(distance) - length;
		// Intersection if returns < 0.0
	}
	
	static outsideOfPlane = function(plane)
	{
		gml_pragma("forceinline");
		
		// Project the half extents of the AABB onto the plane normal
		var length = 
			extents.x * abs(plane.n.x)
			+ extents.y * abs(plane.n.y)
			+ extents.z * abs(plane.n.z);
		
		// Find the distance from the center of the AABB to the plane
		var distance = plane.n.dot(center) + plane.d;
		
		// If box's centerpoint is behind the plane further than its extent, then the box is outside of the plane
		return (distance < -length);
	}
	
	static copy = function()
	{
		gml_pragma("forceinline");
		return new BBox3(center.copy(), extents.copy());
	}
}

/// @function BBox3FromMinMax(min, max)
/// @desc Creates a new BBox3 given the min and max vec3's.
function BBox3FromMinMax(n_min, n_max)
{
	gml_pragma("forceinline");
	//return new BBox3(n_min.add(n_max).multiply(0.5), n_max.subtract(n_min).multiply(0.5));
	// Vec3 variant too slow since it's hit repeatedly - so we do it without structs:
	return new BBox3(
		new Vector3(
			(n_min.x + n_max.x) * 0.5,
			(n_min.y + n_max.y) * 0.5,
			(n_min.z + n_max.z) * 0.5
			),
		new Vector3(
			(n_max.x - n_min.x) * 0.5,
			(n_max.y - n_min.y) * 0.5,
			(n_max.z - n_min.z) * 0.5
			)
		);
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
		gml_pragma("forceinline");
		return center.subtract(extents);
	}
	static getMax = function()
	{
		gml_pragma("forceinline");
		return center.add(extents);
	}
	static contains = function(x, y)
	{
		gml_pragma("forceinline");
		return point_in_rectangle(
			x, y,
			n_center.x - n_extents.x, n_center.y - n_extents.y,
			n_center.x + n_extents.x, n_center.y + n_extents.y);
	}
}

/// @function BBox2FromMinMax(min, max)
function BBox2FromMinMax(n_min, n_max)
{
	gml_pragma("forceinline");
	return new BBox2(n_min.add(n_max).multiply(0.5), n_max.subtract(n_min).multiply(0.5));
}


/// @function Rect2(min, max) struct;
/// @param {Vector2} min
/// @param {Vector2} max
function Rect2(n_min, n_max) constructor
{
	m_min	= new Vector2(n_min.x, n_min.y);
	m_max	= new Vector2(n_max.y, n_max.y);
	
	/// @function contains(x, y)
	static contains = function(x, y)
	{
		gml_pragma("forceinline");
		return point_in_rectangle(
			x, y,
			m_min.x, m_min.y,
			m_max.x, m_max.y);
	}
	
	/// @function contains2(vec)
	static contains2 = function(vec)
	{
		gml_pragma("forceinline");
		return point_in_rectangle(
			vec.x, vec.y,
			m_min.x, m_min.y,
			m_max.x, m_max.y);
	}
	
	/// @function containsSubEdge(x, y, edgeLeft, edgeUp, edgeRight, edgeDown)
	static containsSubEdge = function(x, y, edgeLeft, edgeUp, edgeRight, edgeDown)
	{
		gml_pragma("forceinline");
		return point_in_rectangle(
			x, y,
			m_min.x + edgeLeft, m_min.y + edgeUp,
			m_max.x - edgeRight, m_max.y - edgeDown);
	}
	
	static expand1Self = function(dist)
	{
		gml_pragma("forceinline");
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
	gml_pragma("forceinline");
	return new Rect2(n_min, n_min.add(n_size));
}