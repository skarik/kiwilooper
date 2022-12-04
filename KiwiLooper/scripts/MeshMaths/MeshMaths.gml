/// @function TriangleGetNormal(positionArray)
function TriangleGetNormal(positionArray)
{
	var delta1 = new Vector3(positionArray[1].x - positionArray[0].x, positionArray[1].y - positionArray[0].y, positionArray[1].z - positionArray[0].z);
	var delta2 = new Vector3(positionArray[2].x - positionArray[0].x, positionArray[2].y - positionArray[0].y, positionArray[2].z - positionArray[0].z);
	return delta1.cross(delta2).normalize();
}

/// @function TriangleSplit(positionArray, plane)
function TriangleSplit(positionArray, plane)
{
	assert(false);
	// TODO
}