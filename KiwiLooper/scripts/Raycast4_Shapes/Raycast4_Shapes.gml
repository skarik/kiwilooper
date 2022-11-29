function _raycast4_init()
{
	global._raycast4_hitdistance = 0;
	global._raycast4_hitnormal = new Vector3(0, 0, 0);
}
gml_pragma("global", "_raycast4_init()");

/// @function raycast4_get_hit_distance()
function raycast4_get_hit_distance()
{
	return global._raycast4_hitdistance;
}

/// @function raycast4_get_hit_normal()
function raycast4_get_hit_normal()
{
	return global._raycast4_hitnormal;
}

// TODO: Make a BBox3 version of these functions. This will cut down on extra multiply at the start.

function _raycast4_box_inner(center, extents, rayOrigin, rayDir, raySign)
{
	// Implementation borrowed from http://www.jcgt.org/published/0007/03/04/paper-lowres.pdf
	
	var l_boxCenter = center;
	var l_boxExtents = extents;
	
	var l_rayPos = rayOrigin.subtract(l_boxCenter);
	var l_sign = new Vector3(-sign(rayDir.x), -sign(rayDir.y), -sign(rayDir.z));
	
	// Distance to plane
	var l_d = l_sign.multiplyComponent(l_boxExtents).multiply(raySign).subtract(l_rayPos);
	l_d.divideComponentSelf(rayDir);
	
	// Test all axes at once
	var l_test = [
		(l_d.x > 0.0) && (abs(l_rayPos.y + rayDir.y * l_d.x) < l_boxExtents.y) && (abs(l_rayPos.z + rayDir.z * l_d.x) < l_boxExtents.z),
		(l_d.y > 0.0) && (abs(l_rayPos.z + rayDir.z * l_d.y) < l_boxExtents.z) && (abs(l_rayPos.x + rayDir.x * l_d.y) < l_boxExtents.x),
		(l_d.z > 0.0) && (abs(l_rayPos.x + rayDir.x * l_d.z) < l_boxExtents.x) && (abs(l_rayPos.y + rayDir.y * l_d.z) < l_boxExtents.y)
	];
	
	l_sign = l_test[0] ? new Vector3(l_sign.x, 0, 0) : (
			l_test[1] ? new Vector3(0, l_sign.y, 0) : (
			l_test[2] ? new Vector3(0, 0, l_sign.z) : new Vector3(0, 0, 0))
		);
	
	// Get distance
	global._raycast4_hitdistance	= (l_sign.x != 0) ? l_d.x : ((l_sign.y != 0) ? l_d.y : l_d.z);
	global._raycast4_hitnormal		= l_sign.copy();

	// Return if hit.
	return (l_sign.x != 0) || (l_sign.y != 0) || (l_sign.z != 0);
}

/// @function raycast4_box(minAB, maxAB, rayOrigin, rayDir)
/// @desc Performs a raycast against the given AABB.
function raycast4_box(minAB, maxAB, rayOrigin, rayDir)
{
	gml_pragma("forceinline");
	
	var l_boxCenter = minAB.add(maxAB).multiply(0.5);
	var l_boxExtents = maxAB.subtract(minAB).multiply(0.5);
	l_boxExtents.x = abs(l_boxExtents.x);
	l_boxExtents.y = abs(l_boxExtents.y);
	l_boxExtents.z = abs(l_boxExtents.z);
	
	return _raycast4_box_inner(l_boxCenter, l_boxExtents, rayOrigin, rayDir, 1.0);
}
/// @function raycast4_box2(bbox3, rayOrigin, rayDir)
/// @desc Performs a raycast against the given AABB.
function raycast4_box2(bbox3, rayOrigin, rayDir)
{
	gml_pragma("forceinline");
	return _raycast4_box_inner(bbox3.center, bbox3.extents, rayOrigin, rayDir, 1.0);
}

/// @function raycast4_box_backside(minAB, maxAB, rayOrigin, rayDir)
/// @desc Performs a raycast against the given AABB.
function raycast4_box_backside(minAB, maxAB, rayOrigin, rayDir)
{
	// Some logic borrowed from https://tavianator.com/2011/ray_box.html to get the -1.0
	
	gml_pragma("forceinline");
	
	var l_boxCenter = minAB.add(maxAB).multiply(0.5);
	var l_boxExtents = maxAB.subtract(minAB).multiply(0.5);
	l_boxExtents.x = abs(l_boxExtents.x);
	l_boxExtents.y = abs(l_boxExtents.y);
	l_boxExtents.z = abs(l_boxExtents.z);
	
	return _raycast4_box_inner(l_boxCenter, l_boxExtents, rayOrigin, rayDir, -1.0);
}
/// @function raycast4_box_backside2(bbox3, rayOrigin, rayDir)
/// @desc Performs a raycast against the given AABB.
function raycast4_box_backside2(bbox3, rayOrigin, rayDir)
{
	// Some logic borrowed from https://tavianator.com/2011/ray_box.html to get the -1.0
	gml_pragma("forceinline");
	return _raycast4_box_inner(bbox3.center, bbox3.extents, rayOrigin, rayDir, -1.0);
}

/// @function raycast4_box_rotated(boxCenter, boxExtents, preRotation, frontfaces, rayOrigin, rayDir)
/// @desc Performs a raycast against the given rotated AABB. AABB is rotated in place, then moved to its center.
/// @param {Vector3} Center
/// @param {Vector3} Half-Extents
/// @param {AMatrix} Rotation array matrix
/// @param {Boolean} Cast Frontface
/// @param {Vector3} Ray Origin
/// @param {Vector3} Ray Dir
function raycast4_box_rotated(boxCenter, boxExtents, preRotation, frontfaces, rayOrigin, rayDir)
{
	gml_pragma("forceinline");
	
	var l_rayOrigin	= rayOrigin.transformAMatrix(preRotation);
	var l_rayDir	= rayDir.transformAMatrix(preRotation);
	
	var l_result = _raycast4_box_inner(boxCenter, boxExtents, rayOrigin, rayDir, frontfaces ? 1.0 : -1.0);
	
	return l_result;
}

function _raycast4_inside_box(point, minAB, maxAB)
{
	gml_pragma("forceinline");
	
	return point.x >= minAB.x && point.y >= minAB.y && point.z >= minAB.z
		&& point.x <= maxAB.x && point.y <= maxAB.y && point.z <= maxAB.z
}

/// @function raycast4_tilemap(rayOrigin, rayDir)
/// @desc Performs a raycast against the total tilemap, using AABB collision.
/// @param {Vector3} rayOrigin
/// @param {Vector3} rayDir
function raycast4_tilemap(rayOrigin, rayDir)
{
	var tilemap = _collision4_get_tilemap();
	
	if (tilemap != null)
	{
		// Generate tileset's bbox
		var l_tilesetMin = tilemap.m_minPosition.copy();
		l_tilesetMin.z = min(tilemap.m_minPosition.z, tilemap.m_heightMap.m_defaultHeight * 16);
		var l_tilesetMax = tilemap.m_maxPosition.copy();
		l_tilesetMax.x += 16;
		l_tilesetMax.y += 16;
		
		// Raycast against the tileset's bbox.
		var l_tilesetExtents = l_tilesetMax.subtract(l_tilesetMin);
		if (l_tilesetExtents.x < 0 || l_tilesetExtents.y < 0 || l_tilesetExtents.z < 0)
		{
			return false;
		}
		
		var l_insideTileset = _raycast4_inside_box(rayOrigin, l_tilesetMin, l_tilesetMax);
		if (!l_insideTileset)
		{
			var l_hitTileset = raycast4_box(l_tilesetMin, l_tilesetMax, rayOrigin, rayDir);
		
			if (!l_hitTileset)
			{
				return false;
			}
		}
		
		var l_hitDistanceFront = l_insideTileset ? 0.0 : raycast4_get_hit_distance(); // Save the hit distance so we have a place to start divvying the tiles.
		
		// Check collision with the backside of the box
		var l_hitTilesetBack = raycast4_box_backside(l_tilesetMin, l_tilesetMax, rayOrigin, rayDir);
		assert(l_hitTilesetBack); // can happen in coplanar cases. TODO: handle properly
		if (!l_hitTilesetBack) return false;
		
		var l_hitDistanceBack = raycast4_get_hit_distance(); // Save hit distance here so we have a place to end the tile divvy.
		assert(l_hitDistanceFront != l_hitDistanceBack); // remove when ready
		
		// Also check for the exit point of the box (approximately)
		// We can choose the maximum travel distance in order to get the max point.
		var l_hitPointFront = rayOrigin.add(rayDir.multiply(l_hitDistanceFront));
		var l_hitPointBack = rayOrigin.add(rayDir.multiply(l_hitDistanceBack));
		
		var l_checkboxMin = new Vector3(min(l_hitPointFront.x, l_hitPointBack.x), min(l_hitPointFront.y, l_hitPointBack.y), min(l_hitPointFront.z, l_hitPointBack.z));
		var l_checkboxMax = new Vector3(max(l_hitPointFront.x, l_hitPointBack.x), max(l_hitPointFront.y, l_hitPointBack.y), max(l_hitPointFront.z, l_hitPointBack.z));
		
		// Now, get the minimum tile XYZ and max tile XYZ
		var l_tileMin = new Vector3(floor(l_checkboxMin.x / 16), floor(l_checkboxMin.y / 16), floor(l_checkboxMin.z / 16));
		var l_tileMax = new Vector3(ceil(l_checkboxMax.x / 16), ceil(l_checkboxMax.y / 16), ceil(l_checkboxMax.z / 16));
		
		// Now loop through every tile, trying to find the minimum distance. We can do a sqr xyz first.
		var l_minimumDistance = l_hitDistanceBack;//l_hitDistanceBack - l_hitDistanceFront;
		var l_minimumNormal = global._raycast4_hitnormal;
		//var l_minimumDistanceSqr = sqr(l_minimumDistance);
		var l_hasHit = false;
		
		for (var ix = l_tileMin.x; ix <= l_tileMax.x; ++ix)
		{
			for (var iy = l_tileMin.y; iy <= l_tileMax.y; ++iy)
			{
				// Later for 3D maps.
				/*for (var iz = l_tileMin.z; ix <= l_tileMax.z; ++iz)
				{
				}*/
				// Get if there's any blocks in the current position
				
				// Get the min & max Z for the current position.
				var l_minHeight = tilemap.m_heightMap.m_defaultHeight;
				var l_maxHeight = tilemap.m_heightMap.get(ix, iy);
				
				// Flat block, don't check.
				if (l_minHeight == l_maxHeight) continue;
				
				// Check for collision with the entire column
				var l_hitBlock = raycast4_box(
					new Vector3(ix * 16, iy * 16, l_minHeight * 16),
					new Vector3(ix * 16 + 16, iy * 16 + 16, l_maxHeight * 16),
					rayOrigin, rayDir);
					
				if (l_hitBlock)
				{
					if (raycast4_get_hit_distance() < l_minimumDistance)
					{
						l_minimumDistance = raycast4_get_hit_distance();
						l_minimumNormal.copyFrom(raycast4_get_hit_normal());
						l_hasHit = true;
					}
				}
			}
		}
		
		if (l_hasHit)
		{
			global._raycast4_hitdistance = l_minimumDistance;
			global._raycast4_hitnormal.copyFrom(l_minimumNormal);
		}
		return l_hasHit;
	}
	
	return false;
}

/// @desc kAxis enumeration.
#macro kAxisX 0
#macro kAxisY 1
#macro kAxisZ 2

/// @function rayutil4_getaxis(normal)
/// @desc Returns the closest axis that matches 
function rayutil4_getaxis(normal)
{
	return (abs(normal.x) > 0) ? kAxisX : (
			(abs(normal.y) > 0) ? kAxisY : (
			(abs(normal.z) > 0) ? kAxisZ : undefined)
			);
}

/// @function raycast4_axisplane(axis, offset, rayOrigin, rayDir)
/// @desc Performs a raycast against the given axis-aligned plane.
function raycast4_axisplane(axis, offset, rayOrigin, rayDir)
{
	var l_rayPos = offset - rayOrigin.getElement(axis);
	var l_raySpeed = rayDir.getElement(axis);
	
	// Distance to plane
	var l_d = l_rayPos / l_raySpeed;
	
	// Test if we hit
	global._raycast4_hitdistance = l_d;
	global._raycast4_hitnormal =
		(axis == kAxisX) ? new Vector3(-sign(rayDir.x), 0, 0) : (
		(axis == kAxisY) ? new Vector3(0, -sign(rayDir.y), 0) : (
		(axis == kAxisZ) ? new Vector3(0, 0, -sign(rayDir.z)) : new Vector3(0, 0, 0))
		);
		
	// Return if hit.
	return (l_d >= 0.0);
}

/// @function raycast4_triangle(points, rayOrigin, rayDir, cullback)
/// @desc Performs a raycast against the given triangle
/// @param {Vector3[3]} points
/// @param {Vector3} rayOrigin
///	@param {Vector3} rayDir
function raycast4_triangle(points, rayOrigin, rayDir, cullback=false)
{
	var edge1 = new Vector3(points[1].x - points[0].x, points[1].y - points[0].y, points[1].z - points[0].z);
	var edge2 = new Vector3(points[2].x - points[0].x, points[2].y - points[0].y, points[2].z - points[0].z);
	
	/*var normal = edge1.cross(edge2);
	if (normal.sqrMagnitude() < KINDA_SMALL_NUMBER * KINDA_SMALL_NUMBER) // Degenerate triangle
		return false;
		
	var w0 = rayOrigin.subtract(points[0]);
	var offsetToTriangle = -normal.dot(w0);
	var rayDirProjection = normal.dot(rayDir);
	
	if (abs(rayDirProjection) < KINDA_SMALL_NUMBER) // Ray is parallel, miss by default
		return false;
	
	var planeProjection = offsetToTriangle / rayDirProjection;
	if (planeProjection < 0.0) // Ray points away from triangle
		return false;
		
	// Point on plane:
	var pointOnPlane = rayOrigin.add(rayDir.multiply(planeProjection));
	
	// Check if hit-point inside plane
	var uu = edge1.dot(edge1);
	var uv = edge1.dot(edge2);
	var vv = edge2.dot(edge2);
	var edgeHit = pointOnPlane.subtract(points[0]);
	var wu = edgeHit.dot(edge1);
	var wv = edgeHit.dot(edge2);
	
	var D = uv * uv - uu * vv;
	// no this is longer, not cheaper
	*/
	
	/*var pvec = rayDir.cross(edge2);
	var det = edge1.dot(pvec);
	
	if (cullback ? (det < KINDA_SMALL_NUMBER) : (abs(det) < KINDA_SMALL_NUMBER))
		return false;
	
	var inv_det = 1.0 / det;
	var tvec = rayOrigin.subtract(points[0]);
		
	// check U is in range
	var u = tvec.dot(pvec) * inv_det;
	if (u < 0.0 || u > 1.0)
		return false;
			
	var qvec = tvec.cross(edge1);
		
	// check V is in range
	var v = rayDir.dot(qvec) * inv_det;
	if (v < 0.0 || u+v > 1.0)
		return false;
		
	// get final distance
	var distance = edge2.dot(qvec) * inv_det;
	if (distance < KINDA_SMALL_NUMBER) // make sure we're pointing AT the triangle
	{
		return false;
	}
	
	global._raycast4_hitdistance = distance;
	
	return true;*/
	
	// Face normal
	var normal = edge1.cross(edge2);
	
	var pvec = rayDir.cross(edge2);
	var det = edge1.dot(pvec);
	
	// Backfacing or nearly parallel?
	if (normal.dot(rayDir) >= 0 || abs(det) < KINDA_SMALL_NUMBER)
		return false;
		
	var tvec = rayOrigin.subtract(points[0]).divideSelf(det);
	var qvec = tvec.cross(edge1);
	
	// Get the t-value now
	var distance = edge2.dot(qvec);
	// Collided behind the ray?
	if (distance < KINDA_SMALL_NUMBER) 
	{
		return false;
	}
	
	var b_x = tvec.dot(pvec);
	var b_y = qvec.dot(rayDir);
	var b_z = b_x + b_y;
	
	// Intersected outside triangle?
	if (b_x < 0.0 || b_y > 1.0 || b_z > 1.0)
	{	
		return false;
	}
	
	global._raycast4_hitdistance = distance;
	
	return true;
}

/// @function raycast4_polygon(points, rayOrigin, rayDir)
function raycast4_polygon(points, rayOrigin, rayDir)
{
	var edge1 = new Vector3(points[1].x - points[0].x, points[1].y - points[0].y, points[1].z - points[0].z);
	var edge2 = new Vector3(points[2].x - points[0].x, points[2].y - points[0].y, points[2].z - points[0].z);
	
	var normal = edge1.cross(edge2);
	if (normal.sqrMagnitude() < KINDA_SMALL_NUMBER * KINDA_SMALL_NUMBER) // Degenerate case
		return false;
		
	// Now that we have point[0] and normal, we have a plane. Collide with plane to get point
	var offsetToPlane = rayOrigin.subtract(points[0]);
	
	var planeProjectRaydir = rayDir.dot(normal);
	var planeProjectOffset = -offsetToPlane.dot(normal);
	
	if (abs(planeProjectRaydir) < KINDA_SMALL_NUMBER) // Ray is parallel to the checking plane
		return false;
		
	var distance = planeProjectOffset / planeProjectRaydir;
	if (distance < 0.0) // Ray points away
		return false;
		
	// Get the hit point
	var hitPoint = rayOrigin.add(rayDir.multiply(distance));
	
	// Check against all edges smushed to 2D
	var axis_dropped = 
		(abs(normal.x) > abs(normal.y)) 
			? ((abs(normal.x) > abs(normal.z)) ? kAxisX : kAxisZ)
			: ((abs(normal.y) > abs(normal.z)) ? kAxisY : kAxisZ);
	var axis_dropped_sign = sign(normal.getElement(axis_dropped));
	
	var edge_count = array_length(points);
	var edge_index = 0;
	while (edge_index < edge_count)
	{
		var point1 = points[(edge_index + 1) % edge_count];
		var point0 = points[edge_index];
		
		var edge = 
			(axis_dropped == kAxisX) ? [point1.y - point0.y, point1.z - point0.z] : (
			(axis_dropped == kAxisY) ? [point1.z - point0.z, point1.x - point0.x] : (
			/*axis_dropped == kAxisZ*/ [point1.x - point0.x, point1.y - point0.y]
			));
		var compare =
			(axis_dropped == kAxisX) ? [hitPoint.y - point0.y, hitPoint.z - point0.z] : (
			(axis_dropped == kAxisY) ? [hitPoint.z - point0.z, hitPoint.x - point0.x] : (
			/*axis_dropped == kAxisZ*/ [hitPoint.x - point0.x, hitPoint.y - point0.y]
			));
		
		// Cross product to check sine between two angles. 
		if ((edge[0] * compare[1] - edge[1] * compare[0]) * axis_dropped_sign < 0.0) // Is on the wrong side of the edge
			return false;
			
		edge_index++; // Next edge, let's go
	}
	
	// Otherwise, we're at the right spot
	global._raycast4_hitdistance = distance;
	global._raycast4_hitnormal = normal.copy(); // TODO

	return true;
}