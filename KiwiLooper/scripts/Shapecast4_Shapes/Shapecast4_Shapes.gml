// bbox3 - triangle based on https://github.com/erich666/GraphicsGems/blob/master/gemsv/ch7-2/

function bbox3_triangle(points, bbox)
{
	// Take the points and transform them so that our bbox is at 0,0,0 and sized 1,1,1
	
	var offset = bbox.center.negate();
	var multiplier = new Vector3(0.5 / bbox.extents.x, 0.5 / bbox.extents.y, 0.5 / bbox.extents.z);
	
	var test_points = [
		offset.add(points[0]).multiplyComponent(multiplier),
		offset.add(points[1]).multiplyComponent(multiplier),
		offset.add(points[2]).multiplyComponent(multiplier),
		];
	
	/*var quick_test = _bbox3_triangle_trivial_vertex_tests(test_points);
	if (quick_test == -1)
		return _bbox3_triangle_polygon_intersects_cube(test_points, 1);
	else
	{
		global._raycast4_hitdepth = 12;
		return quick_test;
	}*/
	
	return _bbox3_triangle_polygon_intersects_cube(test_points, 0);
}

function _bbox3_triangle_trivial_vertex_tests(points)
{
	var cum_and = ~int64(0); // Set to all 1 bits
	
	// compare vertz with all six face-planes.
	for (var i = 0; i < 3; ++i)
	{
		// Test all planes.
		var face_bits = _bbox3_triangle_face_plane(points[i], ~0);
		if (face_bits = 0) // Vertex inside of the cube
			return 1;	// Trivial accept
		cum_and &= face_bits;
	}
	// All vertices outside some face plane?
	if (cum_and != 0) 
		return 0; // Trivial reject
	
	
	// Now do the just the trivial reject test against the 12 edge planes.
	cum_and = ~int64(0); // Set to all 1 bits
	for (var i = 0; i < 3; ++i)
	{
		cum_and = _bbox3_triangle_bevel_2d(points[i], cum_and);
		if (cum_and == 0)
			break; // No planes left that might trivially reject
	}
	// All vertices outside some edge plane?
	if (cum_and != 0) 
		return 0; // Trivial reject

	// Now do the trivial reject test against the 8 corner planes.
	cum_and = ~int64(0); // Set to all 1 bits
	for (var i = 0; i < 3; ++i)
	{
		cum_and = _bbox3_triangle_bevel_3d(points[i], cum_and);
		if (cum_and == 0)
			break; // No planes left that might trivially reject
	}
	// All vertices outside some corner plane?
	if (cum_and != 0) 
		return 0; // Trivial reject

	// By now we know that the polygon is not to the outside of any of the test planes and can't be trivially accepted *or* rejected.
	return -1;
}

function _bbox3_triangle_face_plane(point, mask)
{
	var outcode = int64(0);

	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x001, 0x002, point.x, 0.5)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x004, 0x008, point.y, 0.5)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x010, 0x020, point.z, 0.5)

	return outcode;
}

function _bbox3_triangle_bevel_2d(point, mask)
{
	var outcode = int64(0);

	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x001, 0x002, point.x + point.y, 1.0)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x004, 0x008, point.x - point.y, 1.0)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x010, 0x020, point.x + point.z, 1.0)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x040, 0x080, point.x - point.z, 1.0)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x100, 0x200, point.y + point.z, 1.0)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x400, 0x800, point.y - point.z, 1.0)

	return outcode;
}

function _bbox3_triangle_bevel_3d(point, mask)
{
	var outcode = int64(0);

	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x001, 0x002, point.x + point.y + point.z, 1.5)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x004, 0x008, point.x + point.y - point.z, 1.5)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x010, 0x020, point.x - point.y + point.z, 1.5)
	outcode = _bbox3_triangle_test_against_parallel_planes(mask, outcode, 0x040, 0x080, point.x - point.y - point.z, 1.5)

	return outcode;
}

function _bbox3_triangle_test_against_parallel_planes(mask, outcode, posbit, negbit, value, limit)
{
	gml_pragma("forceinline");
	if (mask & (posbit|negbit))
	{
		var temp = value;
		if ((mask & posbit) && temp > limit)
			outcode |= posbit;
		else if ((mask & negbit) && temp < -limit)
			outcode |= negbit;
	}
	return outcode;
}

function InClosedInterval(a, n, b)
{
	gml_pragma("forceinline");
	return (n - a) * (n - b) <= 0.0;
}

function _bbox3_triangle_polygon_intersects_cube(points, already_know_vertices_are_outside_cube)
{
	// If any edge intersects the cube, return 1.
	if (!already_know_vertices_are_outside_cube)
	{
		for (var i = 0; i < 3; ++i)
		{
			if (_bbox3_triangle_segment_intersects_cube(points[i], points[(i + 1) % 3]))
			{
				global._raycast4_hitdepth = 6;
				return true;
			}
		}
	}
	
	// If the polygon normal is zero and none of its edges intersect the cube, then it doesn't intersect the cube
	//if (ISZEROVEC3(polynormal))
	//	return 0;
	// skip because we don't do degenerate triangles ever
	
	// Get normal now that we're about to use it:
	var normal = TriangleGetNormal(points);
	
	// Now that we know that none of the polygon's edges intersects the cube, deciding whether the polygon intersects the cube amounts
	// to testing whether any of the four cube diagonals intersects the interior of the polygon.
	//
	// Notice that we only need to consider the cube diagonal that comes closest to being perpendicular to the plane of the polygon.
	// If the polygon intersects any of the cube diagonals, it will intersect that one.
	var best_diagonal = [
		nonzero_sign(normal.x),
		nonzero_sign(normal.y),
		nonzero_sign(normal.z),
		];
		
	// Okay, we have the diagonal of interest.
	// The plane containing the polygon is the set of all points p satisfying
	//		DOT3(polynormal, p) == DOT3(polynormal, verts[0])
	// So find the point p on the cube diagonal of interest that satisfies this equation.
	// The line containing the cube diagonal is described parametrically by
	//		t * best_diagonal
	// so plug this into the previous equation and solve for t.
	//		DOT3(polynormal, t * best_diagonal) == DOT3(polynormal, verts[0])
	// i.e.
	//		t = DOT3(polynormal, verts[0]) / DOT3(polynormal, best_diagonal)
	//
	// (Note that the denominator is guaranteed to be nonzero, since polynormal is nonzero and best_diagonal was chosen to have the largest magnitude dot-product with polynormal)
	var t = normal.dot(points[0]) / (normal.x * best_diagonal[0] + normal.y * best_diagonal[1] + normal.z * best_diagonal[2]);

	// t is not in the closed interval?
	if (!InClosedInterval(-0.5, t, 0.5))
		return false; // intersection point is not in cube

	var p = [
		best_diagonal[0] * t,
		best_diagonal[1] * t,
		best_diagonal[2] * t,
		];

	return _bbox3_triangle_polygon_contains_point_3d(points, normal, p);
}


function _bbox3_triangle_segment_intersects_cube(point0, point1)
{
	var edge = [
		point1.x - point0.x,
		point1.y - point0.y,
		point1.z - point0.z,
		];
		
	var edgevec_sign = [
		nonzero_sign(edge[0]),
		nonzero_sign(edge[1]),
		nonzero_sign(edge[2]),
		];
		
	// Test the three cube faces on the v1-ward side of the cube:		if v0 is outside any of their planes then there is no intersection.
	// Also test the three cube faces on the v0-ward side of the cube:	if v1 is outside any of their planes then there is no intersection.
	for (var i = 0; i < 3; ++i)
	{
		if (point0.getElement(i) * edgevec_sign[i] >  0.5) return false;
		if (point1.getElement(i) * edgevec_sign[i] < -0.5) return false;
	}
	
	// Okay, that's the six easy faces of the rhombic dodecahedron out of the way. Six more to go.
	// The remaining six planes bound an infinite hexagonal prism joining the petrie polygons (skew hexagons) of the two cubes centered at the endpoints. 
	for (var i = 0; i < 3; ++i)
	{
		var rhomb_normal_dot_v0;
		var rhomb_normal_dot_cubedge;
		
		var iplus1 = (i + 1) % 3;
		var iplus2 = (i + 2) % 3;
		
		rhomb_normal_dot_v0 =
			  edge[iplus2] * point0.getElement(iplus1)
			- edge[iplus1] * point0.getElement(iplus2);
			
		rhomb_normal_dot_cubedge = 0.5 *
			(edge[iplus2] * edgevec_sign[iplus1] +
			 edge[iplus1] * edgevec_sign[iplus2]);
			 
		if (sqr(rhomb_normal_dot_v0) > sqr(rhomb_normal_dot_cubedge))
		{
			return false; // origin is outside this pair of opposite planes
		}
	}
	return true;
}

function _bbox3_triangle_polygon_contains_point_3d(points, normal, point)
{
	// Determine which axis to ignore (the one in which the polygon normal is largest)
	var xaxis, yaxis;
	var zaxis = vec3_largest_axis(normal);
			
	if (normal.getElement(zaxis) < 0)
	{
		xaxis = (zaxis + 2) % 3;
		yaxis = (zaxis + 1) % 3;
	}
	else
	{
		xaxis = (zaxis + 1) % 3;
		yaxis = (zaxis + 2) % 3;
	}
	
	var count = 0;
	for (var i = 0; i < 3; ++i)
	{
		var v = points[i].asArray();
		var w = points[(i + 1) % 3].asArray();
		
		var xdirection = _bbox3_triangle_seg_contains_point(v[xaxis], w[xaxis], point[xaxis]);
		if (xdirection)
		{
			if (_bbox3_triangle_seg_contains_point(v[yaxis], w[yaxis], point[yaxis]))
			{
				if (xdirection * (point[xaxis] - v[xaxis]) * (w[yaxis] - v[yaxis]) <=
					xdirection * (point[yaxis] - v[yaxis]) * (w[xaxis] - v[xaxis]))
					count += xdirection;
			}
			else
			{
				if (v[yaxis] <= point[yaxis])
					count += xdirection;
			}
		}
	}
	global._raycast4_hitdepth = count;
	return count > 0;
}

function _bbox3_triangle_seg_contains_point(a, b, n)
{
	gml_pragma("forceinline");
	return (b > n) - (a > n);
}

function vec3_largest_axis(vector3)
{
	gml_pragma("forceinline");
	return (abs(vector3.x) > abs(vector3.y)) 
			? ((abs(vector3.x) > abs(vector3.z)) ? kAxisX : kAxisZ)
			: ((abs(vector3.y) > abs(vector3.z)) ? kAxisY : kAxisZ);
}


function bbox3cast_plane(bbox, bboxDir, plane)
{
	// Take the dir, and get the width of the bbox on that dir:
	
	// The max size of a bbox will always be between the front & back of the largest plane
	var bboxDirUnscaled = new Vector3(bboxDir.x / bbox.extents.x, bboxDir.y / bbox.extents.y, bboxDir.z / bbox.extents.z);
	var bboxLargestAxis = vec3_largest_axis(bboxDirUnscaled);
	// Get the effective width of the bbox on each axis
	//var bboxRayLength = bboxDirUnscaled.invert();
	var bboxFlatLength = 1.0 / abs(bboxDirUnscaled.getElement(bboxLargestAxis));
	
	// Our plane is now that big, so we just just collision against the plane now
	var test_plane = plane.copy();
	test_plane.d -= bboxFlatLength * 2.0;
	if (raycast4_plane(test_plane, bbox.center, bboxDir))
	{
		global._raycast4_hitdistance -= bboxFlatLength * 2.0; // Congrats, I guess.
		return true;
	}
	
	return false;
}

// Alternatively: bbox3triangle

// following based on https://github.com/gszauer/GamePhysicsCookbook/blob/master/Code/Geometry3D.cpp

// Let's do:
// check if box collides with triangle, then check distance from plane to bbox
function bbox3_triangle_distance(bbox, points)
{
	if (bbox3_triangle(points, bbox))
	{
		// make plane from the verticies
		var normal = TriangleGetNormal(points);
		var plane = new Plane3(normal, new Vector3(points[0].x, points[0].y, points[0].z));
		
		global._raycast4_hitdistance = bbox.distanceToPlane(plane);
		global._raycast4_hitnormal = normal;
		
		/*if (global._raycast4_hitdepth < 6)
		{
			global._raycast4_hitnormal = normal.cross(bbox.center.subtract(points[0]));
		}*/
		
		return true;
	}
	return false;
}

function bbox3_box_rotated(bbox, rotatedBbox, preRotation)
{
	// Lets just check the bbox against each plane of the rotated BBox, and take the max distance
	
	// Let's make the planes of our bbox, then rotate em, then translate em
	// All the plane centers are in the center of the rotated BBox
	// We need the three normals for the rotated bbox
	var normalX = (new Vector3(1, 0, 0)).transformAMatrix(preRotation);
	var normalY = (new Vector3(0, 1, 0)).transformAMatrix(preRotation);
	var normalZ = (new Vector3(0, 0, 1)).transformAMatrix(preRotation);
	
	// Let's make our three planes now
	var planeX = new Plane3(normalX, rotatedBbox.center);
	var planeY = new Plane3(normalY, rotatedBbox.center);
	var planeZ = new Plane3(normalZ, rotatedBbox.center);
	
	// Take distance across each axis
	var distanceX = bbox.distanceToPlane(planeX) - rotatedBbox.extents.x;
	var signX = global._mathresult_sign;
	var distanceY = bbox.distanceToPlane(planeY) - rotatedBbox.extents.y;
	var signY = global._mathresult_sign;
	var distanceZ = bbox.distanceToPlane(planeZ) - rotatedBbox.extents.z;
	var signZ = global._mathresult_sign;
	
	// If any axis fails the test, then no collision
	if (distanceX > 0.0 || distanceY > 0.0 || distanceZ > 0.0)
		return false;
	
	// Now find maximum distance
	var distance;
	if (distanceX > distanceY && distanceX > distanceZ)
	{
		distance = distanceX;
		global._raycast4_hitdistance = distance;
		global._raycast4_hitnormal = planeX.n.multiply(signX);
	}
	else if (distanceY > distanceX && distanceY > distanceZ)
	{
		distance = distanceY;
		global._raycast4_hitdistance = distance;
		global._raycast4_hitnormal = planeY.n.multiply(signY);
	}
	else
	{
		distance = distanceZ;
		global._raycast4_hitdistance = distance;
		global._raycast4_hitnormal = planeZ.n.multiply(signZ);
	}
	
	return true;
}