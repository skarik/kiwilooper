#macro COLLISION4_SHOW_RAYS	false

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
			if (COLLISION4_SHOW_RAYS)
			{
				debugRay3(rayOrigins[i], rectDir.multiply(hit_distances[0]), c_red);
			}
			
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

function collision4_bbox2cast(bbox, bboxDir, bboxDist, hitMask)
{
	var bHasHit = false;
	var hitDistance = undefined;
	var hitNormal = new Vector3(0, 0, 0);
	
	static raySigns = [
		[ 1,  1,  1],
		[-1,  1,  1],
		[ 1, -1,  1],
		[-1, -1,  1],
		[ 1,  1, -1],
		[-1,  1, -1],
		[ 1, -1, -1],
		[-1, -1, -1],
		];
	var rayOrigins = [
		new Vector3(bbox.center.x + bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z + bbox.extents.z),
		new Vector3(bbox.center.x - bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z + bbox.extents.z),
		new Vector3(bbox.center.x + bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z + bbox.extents.z),
		new Vector3(bbox.center.x - bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z + bbox.extents.z),
		new Vector3(bbox.center.x + bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z - bbox.extents.z),
		new Vector3(bbox.center.x - bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z - bbox.extents.z),
		new Vector3(bbox.center.x + bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z - bbox.extents.z),
		new Vector3(bbox.center.x - bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z - bbox.extents.z),
		];
		
	var rayOffsets = array_create(8, 0);
	{
		var bboxDirUnscaled = new Vector3(bboxDir.x / bbox.extents.x, bboxDir.y / bbox.extents.y, bboxDir.z / bbox.extents.z);
		var bboxDirUnscaledSign = {x: sign(bboxDirUnscaled.x), y: sign(bboxDirUnscaled.y), z: sign(bboxDirUnscaled.z)};
		// Find the plane of the box we're going to hit (we select the largest dir axis, since that'll be the first one to hit)
		var hitAxisWall = 
			(abs(bboxDirUnscaled.x) > abs(bboxDirUnscaled.y)) 
			? ((abs(bboxDirUnscaled.x) > abs(bboxDirUnscaled.z)) ? kAxisX : kAxisZ)
			: ((abs(bboxDirUnscaled.y) > abs(bboxDirUnscaled.z)) ? kAxisY : kAxisZ);
		for (var i = 0; i < 8; ++i)
		{
			// Match opposite signs so we grab the "backface" of the bbox
			if (   (bboxDirUnscaledSign.x == 0 || bboxDirUnscaledSign.x == -raySigns[i][0])
				&& (bboxDirUnscaledSign.y == 0 || bboxDirUnscaledSign.y == -raySigns[i][1])
				&& (bboxDirUnscaledSign.z == 0 || bboxDirUnscaledSign.z == -raySigns[i][2]))
			{
				rayOffsets[i] = 2.0 / bboxDirUnscaled.getElement(hitAxisWall); // Get distance to the closest plane
			}
		}
	}
		
	for (var i = 0; i < 8; ++i)
	{
		var unused_objects, hit_distances, hit_normals;
		unused_objects = [];
		hit_distances = [];
		hit_normals = [];
		if (collision4_raycast(rayOrigins[i], bboxDir, unused_objects, hit_distances, hit_normals, hitMask, false, []))
		{
			hit_distances[0] -= rayOffsets[i];
			
			if (COLLISION4_SHOW_RAYS)
			{
				debugRay3(rayOrigins[i], bboxDir.multiply(hit_distances[0]), c_red);
			}
			
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

function collision4_bbox2_test(bbox, hitMask)
{
	//
	
	if (hitMask & kHitmaskGeometry)
	{
		var geometryInstance = _collision4_get_geometry();
		var geometry = (geometryInstance != null) ? geometryInstance.m_geometry : undefined;
		if (!is_undefined(geometry))
		{
			// Loop through all the triangles for now
			for (var triIndex = 0; triIndex < array_length(geometry.triangles); ++triIndex)
			{
				var triangle = geometry.triangles[triIndex];
				
				if (bbox3_triangle(
					[triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position],
					bbox))
				{
					//if (!array_contains_pred()
					/*{
						global._raycast4_hitnormal = new Vector3();
						global._raycast4_hitnormal.copyFrom(triangle.vertices[0].normal);
						l_priorityHits.add([triangle, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
					}*/
					return true;
				}
			}
		}
	}
	
	return false;
}