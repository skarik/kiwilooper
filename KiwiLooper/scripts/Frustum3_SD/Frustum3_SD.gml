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