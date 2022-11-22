/// @function TriangleGetNormal(positionArray)
function TriangleGetNormal(positionArray)
{
	var delta1 = positionArray[1].subtract(positionArray[0]);
	var delta2 = positionArray[2].subtract(positionArray[0]);
	return delta1.cross(delta2).normal();
}

/// @function TriangleSplit(positionArray, plane)
function TriangleSplit(positionArray, plane)
{
	assert(false);
	// TODO
}