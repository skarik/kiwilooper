/// @function raycast4_box(minAB, maxAB, rayOrigin, rayDir)
/// @desc Performs a raycast against the given AABB.
function raycast4_box(minAB, maxAB, rayOrigin, rayDir)
{
	// Implementation borrowed from http://www.jcgt.org/published/0007/03/04/paper-lowres.pdf
	
	var l_boxCenter = minAB.add(maxAB).multiply(0.5);
	var l_boxExtents = maxAB.subtract(minAB).multiply(0.5);
	l_boxExtents.x = abs(l_boxExtents.x);
	l_boxExtents.y = abs(l_boxExtents.y);
	l_boxExtents.z = abs(l_boxExtents.z);
	
	var l_rayPos = rayOrigin.subtract(l_boxCenter);
	var l_sign = new Vector3(-sign(rayDir.x), -sign(rayDir.y), -sign(rayDir.z));
	
	// Distance to plane
	var l_d = l_sign.multiplyComponent(l_boxExtents).subtract(l_rayPos);
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