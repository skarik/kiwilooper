// @function Frustum3() constructor
// @desc A simple frustum class. Can be used to test visibility.
function Frustum3() constructor
{
	plane = [
		new Plane3(),
		new Plane3(),
		new Plane3(),
		new Plane3(),
		new Plane3(),
		new Plane3(),
	];
	
	/// @function pointInside(point)
	/// @param {Vector3} point
	static pointInside = function(point)
	{
		gml_pragma("forceinline");
		for (var i = 0; i < 6; ++i)
		{
			var distance = plane[i].n.dot(point) + plane[i].d;
			
			if (distance < 0.0)
			{
				return false;
			}
		}
		return true;
	}
	
	/// @function bboxInside(bbox)
	/// @param {BBox3} bbox
	/// @desc Returns if any part of the bbox is inside the frustum.
	static bboxInside = function(bbox)
	{
		gml_pragma("forceinline");
		for (var i = 0; i < 6; ++i)
		{
			if (bbox.outsideOfPlane(plane[i]))
			{
				return false;
			}
		}
		return true;
	}
}