// Structure Definition for Plane3 

/// @function Plane3() struct;
function Plane3() constructor
{
	n = new Vector3(0, 0, 1);
	d = 0.0;
	
	/// @function nearestPoint(point)
	/// @param {Vector3} point
	/// @desc Finds the closest point on the plane to the given point.
	static nearestPoint = function(point)
	{
		// Offset from center
		var d_center = new Vector3(-point.x, -point.y, -point.z - d);
		// Project onto normal
		var t = d_center.dot(n);
		
		// Point on plane would be Offset - Projection to Normal
		return d_center.subtract(n.multiply(t));
	}
	
	/// @function flattenPoint(point)
	/// @param {Vector3} point
	/// @desc Flattens a point we assume is coplanar into 2D coordinates based on inferred Side and Up vectors
	//		Will work with points that are not coplanar.
	static flattenPoint = function(coplanar_point)
	{	
		var side = n.cross((abs(n.z) > 0.95) ? new Vector3(0, -1, 0) : new Vector3(0, 0, 1)).normalize();
		var up   = n.cross(side.negate()).negate().normalize();
		
		// IT'S TIME FOR YOUR POINT FLATTENING
		return new Vector2(side.dot(coplanar_point), up.dot(coplanar_point));
	}
	
	/// @function copy()
	/// @desc Returns a deep copy of the current plane (copies normal vector as well)
	static copy = function()
	{
		gml_pragma("forceinline");
		var new_plane = new Plane3();
		new_plane.n.copyFrom(n);
		new_plane.d = d;
		return new_plane;
	}
}

/// @function Plane3FromNormalOffset(normal, offset)
/// @param {Vector3} normal
/// @param {Vector3} offset
function Plane3FromNormalOffset(n_normal, n_offset)
{
	gml_pragma("forceinline");
	var new_plane = new Plane3();
	new_plane.n.copyFrom(n_normal);
	new_plane.d = n_offset.dot(new_plane.n.negate());
	return new_plane;
}