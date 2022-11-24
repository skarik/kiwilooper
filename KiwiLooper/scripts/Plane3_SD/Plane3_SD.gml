// Structure Definition for Plane3 

/// @function Plane3(normal, offset) struct;
/// @param {Vector3} normal
/// @param {Vector3} offset
function Plane3(n_normal, n_offset) constructor
{
	n = new Vector3(n_normal.x, n_normal.y, n_normal.z);
	d = n_offset.dot(n.negate());
	
	static nearestPoint = function(point)
	{
		// Offset from center
		var d_center = new Vector3(-point.x, -point.y, -point.z - d);
		// Project onto normal
		var t = d_center.dot(n);
		
		// Point on plane would be Offset - Projection to Normal
		return d_center.subtract(n.multiply(t));
	}
	
	static flattenPoint = function(coplanar_point)
	{
		var side = n.cross(abs(n.x > 0.99) ? new Vector3(0, 1, 0) : new Vector3(1, 0, 0)).normal();
		var up = n.cross(side).normal();
		var matrix = CE_MatrixCreate(
			side.x, up.x, n.x, 0.0,
			side.y, up.y, n.y, 0.0,
			side.z, up.z, n.z, 0.0,
			0.0, 0.0, -d, 1.0);
		CE_MatrixInverse(matrix);
		// IT'S TIME FOR YOUR POINT FLATTENING
		var flattened = coplanar_point.transformAMatrix(matrix);
		return new Vector2(flattened.x, flattened.y);
	}
}