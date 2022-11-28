

function collision4_rectanglecast2(rectOrigin, rectSizeX, rectSizeY, rectDir, hitMask)
{
	// for now, let's just cast corners
	
	var side = rectDir.cross((abs(rectDir.z) > 0.95) ? new Vector3(0, -1, 0) : new Vector3(0, 0, 1)).normalize();
	var up   = rectDir.cross(side.negate()).negate().normalize();
	
	var offsetX = side.multiply(rectSizeX * 0.5);
	var offsetY = up.multiply(rectSizeY * 0.5);
	
	var bHasHit = false;
	var hitDistance = undefined;
	var hitNormal = new Vector3(0, 0, 0);
	
	var rayOrigins = [
		rectOrigin.add(offsetX).add(offsetY),
		rectOrigin.subtract(offsetX).add(offsetY),
		rectOrigin.add(offsetX).subtract(offsetY),
		rectOrigin.subtract(offsetX).subtract(offsetY)
		];
		
	for (var i = 0; i < 4; ++i)
	{
		var unused_objects, hit_distances, hit_normals;
		unused_objects = [];
		hit_distances = [];
		hit_normals = [];
		if (collision4_raycast(rayOrigins[i], rectDir, unused_objects, hit_distances, hit_normals, hitMask, false, []))
		{
			//debugRay3(rayOrigins[i], rectDir.multiply(hit_distances[0]), c_red);
			if (!bHasHit || (hit_distances[0] < hitDistance))
			{
				bHasHit = true;
				hitDistance = hit_distances[0];
				hitNormal.copyFrom(hit_normals[0]);
			}
		}
	}
	
	if (bHasHit)
	{
		global._raycast4_hitdistance = hitDistance;
		global._raycast4_hitnormal = hitNormal;
	}
	return bHasHit;
}