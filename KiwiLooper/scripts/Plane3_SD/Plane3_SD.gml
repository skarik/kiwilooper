// Structure Definition for Plane3 

/// @function Plane3(normal, offset) struct;
/// @param {Vector3} normal
/// @param {Vector3} offset
function Plane3() constructor
{
	n = new Vector3(0, 0, 1);
	d = 0.0;
	
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
		var side = n.cross((abs(n.z) > 0.95) ? new Vector3(0, -1, 0) : new Vector3(0, 0, 1)).normalize();
		var up   = n.cross(side.negate()).negate().normalize();
		
		return new Vector2(side.dot(coplanar_point), up.dot(coplanar_point));
		
		// This shall remain here as a testement to...something
		/*
		//var side = n.cross(abs(n.x > 0.99) ? new Vector3(0, 1, 0) : new Vector3(1, 0, 0)).normal();
		//var up = n.cross(side).normal();
		//var up = n.cross((abs(n.x) > 0.95) ? new Vector3(0, 0, 1) : new Vector3(1, 0, 0)).negateSelf().normalize();
		//var side = n.cross(up).normalize();
		var side = n.cross((abs(n.z) > 0.95) ? new Vector3(0, -1, 0) : new Vector3(0, 0, 1)).normalize();
		var up = n.cross(side).normalize();
		
		var matrix = CE_MatrixCreate(
			side.x, up.x, n.x, 0.0,
			side.y, up.y, n.y, 0.0,
			side.z, up.z, n.z, 0.0,
			0.0, 0.0, -d, 1.0);	
		//CE_MatrixInverse(matrix);
		CE_MatrixTranspose(matrix);
		
		// IT'S TIME FOR YOUR POINT FLATTENING
		var flattened = coplanar_point.transformAMatrix(matrix);
		return new Vector2(flattened.x, flattened.y);
		*/
	}
	
	static copy = function()
	{
		gml_pragma("forceinline");
		var new_plane = new Plane3();
		new_plane.n.copyFrom(n);
		new_plane.d = d;
		return new_plane;
	}
}

function Plane3FromNormalOffset(n_normal, n_offset)
{
	gml_pragma("forceinline");
	var new_plane = new Plane3();
	new_plane.n.copyFrom(n_normal);
	new_plane.d = n_offset.dot(new_plane.n.negate());
	return new_plane;
}