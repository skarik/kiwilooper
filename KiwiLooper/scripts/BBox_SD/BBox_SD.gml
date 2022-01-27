// Structure Definition for BBox2 and BBox3

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

function BBox3FromMinMax(n_min, n_max)
{
	return new BBox(n_min.add(n_max).multiply(0.5), n_max.subtract(n_min).multiply(0.5));
}