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

/// @function raycast4_tilemap(rayOrigin, rayDir)
/// @desc Performs a raycast against the total tilemap, using AABB collision.
/// @param {Vector3} rayOrigin
/// @param {Vector3} rayDir
function raycast4_tilemap(rayOrigin, rayDir)
{
	if (iexists(o_tileset3DIze))
	{
		// Generate tileset's bbox
		var l_tilesetMin = o_tileset3DIze.m_minPosition.copy();
		l_tilesetMin.z = min(o_tileset3DIze.m_minPosition.z, o_tileset3DIze.m_heightMap.m_defaultHeight * 16);
		var l_tilesetMax = o_tileset3DIze.m_maxPosition.copy();
		l_tilesetMax.x += 16;
		l_tilesetMax.y += 16;
		
		// Raycast against the tileset's bbox.
		var l_tilesetExtents = l_tilesetMax.subtract(l_tilesetMin);
		var l_hitTileset = raycast4_box(l_tilesetMin, l_tilesetMax, rayOrigin, rayDir);
		
		if (!l_hitTileset)
		{
			return false;
		}
		
		var l_hitDistanceFront = raycast4_get_hit_distance(); // Save the hit distance so we have a place to start divvying the tiles.
		
		// Check collision with the backside of the box
		var l_hitTilesetBack = raycast4_box_backside(l_tilesetMin, l_tilesetMax, rayOrigin, rayDir);
		assert(l_hitTilesetBack);
		
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
		var l_minimumDistanceSqr = sqr(l_minimumDistance);
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
				var l_minHeight = o_tileset3DIze.m_heightMap.m_defaultHeight;
				var l_maxHeight = o_tileset3DIze.m_heightMap.get(ix, iy);
				
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