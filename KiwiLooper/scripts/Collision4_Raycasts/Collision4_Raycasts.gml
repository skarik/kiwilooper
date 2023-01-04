#macro kHitmaskTilemap		0x01
#macro kHitmaskGeometry		0x02
#macro kHitmaskCorpse		0x04
#macro kHitmaskDoors		0x08
#macro kHitmaskProps		0x10

#macro kHitmaskAll			0xFF

#macro COLLISION4_SHOW_TRIANGLE_BBOX_RESPONSE 0

function collision4_raycast(rayOrigin, rayDir, rayDist, outHitObjects, outHitDistances, outHitNormals, hitMask=kHitmaskAll, bCollectAllHits=false, ignoreList=[])
{
	var l_priorityHits;
	if (bCollectAllHits)
		l_priorityHits = new APriorityWrapper();
	else
		l_priorityHits = new ASinglePriorityMin();
		
	// TODO: add ignore list
		
	// TODO: can probably speed things up with a AABB/Geometry tree
	if (hitMask & kHitmaskProps)
	{
		var propInstance = instance_find(o_props3DIze2, 0);
		var propmap = iexists(propInstance) ? propInstance.m_propmap : undefined;
		if (is_struct(propmap))
		{
			for (var propIndex = 0; propIndex < propmap.GetPropCount(); ++propIndex)
			{
				var prop = propmap.GetProp(propIndex);
			
				// Get the prop BBox & transform it into the world
				var propBBox = PropGetBBox(prop.sprite);
				var propRotation = matrix_build_rotation(prop);
			
				// Currently, BBox is centered around the pivot. We need to transform that center by our rotation first.
				propBBox.center.transformAMatrixSelf(propRotation);
			
				if (raycast4_box_rotated(
					propBBox.center.add(Vector3FromTranslation(prop)),
					propBBox.extents.multiplyComponent(Vector3FromScale(prop)),
					propRotation,
					true,
					rayOrigin, rayDir))
				{
					if (rayDist < 0 || raycast4_get_hit_distance() <= rayDist)
					{
						l_priorityHits.add([prop, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
					}
				}
			}
		}
	}
	
	// TODO: definitely don't do EVERY triangle, that's slow. Speed up later
	if (hitMask & kHitmaskGeometry)
	{
		var geometryInstance = _collision4_get_geometry();
		var geometry = (geometryInstance != null) ? geometryInstance.m_geometry : undefined;
		if (!is_undefined(geometry))
		{
			// create AABB for the ray
			var rayBBox = new BBox3(
				new Vector3(rayOrigin.x + rayDir.x * rayDist, rayOrigin.y + rayDir.y * rayDist, rayOrigin.z + rayDir.z * rayDist),
				new Vector3(abs(rayDir.x * rayDist), abs(rayDir.y * rayDist), abs(rayDir.z * rayDist))
				);
			
			// Loop through all the triangles for now
			for (var triIndex = 0; triIndex < array_length(geometry.triangles); ++triIndex)
			{
				var triangle = geometry.triangles[triIndex];
				
				// Check the stored triangle bbox
				if (!geometryInstance.m_triangleBBoxes[triIndex].overlaps(rayBBox))
					continue;
					
				if (raycast4_triangle(
					[triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position],
					rayOrigin,
					rayDir,
					false))
				{
					if (rayDist < 0 || raycast4_get_hit_distance() <= rayDist)
					{
						global._raycast4_hitnormal = new Vector3();
						global._raycast4_hitnormal.copyFrom(triangle.vertices[0].normal);
						l_priorityHits.add([triangle, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
					}
				}
			}
		}
	}
	
	if (hitMask & kHitmaskDoors)
	{
		var door_count = instance_number(o_livelyDoor);
		for (var doorIndex = 0; doorIndex < door_count; ++doorIndex)
		{
			var door = instance_find(o_livelyDoor, doorIndex);
			// TODO: create a bbox for the door, and cast against that. Straightforward.
		}
		// Check all the doors
		/*var results_num = collision_rectangle_list(x1, y1, x2, y2, o_livelyDoor, false, true, results, false);
		// Find the one with the highest Z
		for (var i = 0; i < results_num; ++i)
		{
			var door = results[|i];
			var area_z = door.z + door.doorheight;
			area_z_max = max(area_z_max, area_z);
		}
		ds_list_clear(results);*/
	}
	
	// Pull the priority to a list
	// TODO: someday make this less slow because we hit this all the time
	var l_priorityHitCount = l_priorityHits.size();
	for (var i = 0; i < l_priorityHitCount; ++i)
	{
		var minp = l_priorityHits.getMinimum();
		array_push(outHitObjects, minp[0]);
		array_push(outHitDistances, minp[1]);
		array_push(outHitNormals, minp[2]);
		l_priorityHits.deleteMinimum();
	}
	l_priorityHits.cleanup();
	delete l_priorityHits;
	
	return l_priorityHitCount;
}

function collision4_bbox3_test2(bbox, bboxFrom, outHitObjects, outHitDistances, outHitNormals, hitMask=kHitmaskAll, bCollectAllHits=false, ignoreList=[])
{
	var l_priorityHits;
	if (bCollectAllHits)
		l_priorityHits = new APriorityWrapper();
	else
		l_priorityHits = new ASinglePriorityMin();
	
	// TODO: can probably speed things up with a AABB/Geometry tree
	if (hitMask & kHitmaskProps)
	{
		var propInstance = instance_find(o_props3DIze2, 0);
		var propmap = iexists(propInstance) ? propInstance.m_propmap : undefined;
		if (is_struct(propmap))
		{
			for (var propIndex = 0; propIndex < propmap.GetPropCount(); ++propIndex)
			{
				var prop = propmap.GetProp(propIndex);
			
				// Get the prop BBox & transform it into the world
				var propBBox = PropGetBBox(prop.sprite);
				var propRotation = matrix_build_rotation(prop);
				
				// Currently, BBox is centered around the pivot. We need to transform that center by our rotation first.
				propBBox.center.transformAMatrixSelf(propRotation);
			
				// Add the center to the bbox so we have a place to work from
				propBBox.center.addSelf(Vector3FromTranslation(prop));
				
				if (bbox3_box_rotated(
					bbox,
					propBBox,
					propRotation))
				{
					l_priorityHits.add([prop, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
				}
			}
		}
	}
	
	// TODO: definitely don't do EVERY triangle, that's slow. Speed up later
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
				
				// Check the stored triangle bbox
				if (!geometryInstance.m_triangleBBoxes[triIndex].overlaps(bbox))
					continue;
					
					// TODO: should select ALLL colliding triangles because you can hit more than once at a time and need to push out of all of them
				if (bbox3_triangle_distance(
					bbox,
					[triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]))
				{
					
					
					/*debugRay3(
						new Vector3((triangle.vertices[0].position.x + triangle.vertices[1].position.x + triangle.vertices[2].position.x) / 3.0,
									(triangle.vertices[0].position.y + triangle.vertices[1].position.y + triangle.vertices[2].position.y) / 3.0,
									(triangle.vertices[0].position.z + triangle.vertices[1].position.z + triangle.vertices[2].position.z) / 3.0),
						TriangleGetNormal([triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]).multiply(global._raycast4_hitdepth * 3.0),
						c_aqua);*/
					/*debugRay3(
						new Vector3((triangle.vertices[0].position.x + triangle.vertices[1].position.x + triangle.vertices[2].position.x) / 3.0,
									(triangle.vertices[0].position.y + triangle.vertices[1].position.y + triangle.vertices[2].position.y) / 3.0,
									(triangle.vertices[0].position.z + triangle.vertices[1].position.z + triangle.vertices[2].position.z) / 3.0),
						TriangleGetNormal([triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]).multiply(20),
						c_aqua);*/
						
					// TODO: Cache triangle centers & triangle collision normals
						
					var triangle_normal = TriangleGetNormal([triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]);
					var triangle_center =
						new Vector3((triangle.vertices[0].position.x + triangle.vertices[1].position.x + triangle.vertices[2].position.x) / 3.0,
									(triangle.vertices[0].position.y + triangle.vertices[1].position.y + triangle.vertices[2].position.y) / 3.0,
									(triangle.vertices[0].position.z + triangle.vertices[1].position.z + triangle.vertices[2].position.z) / 3.0);
					
					var delta_center = bbox.center.subtract(triangle_center);
					var delta_direction = delta_center.normal();
						
					// so best choice is to count how many bbox vertices are in front of the triangle.
					// given that, find the closest edge
					// that edge should be the normal we push off against 
					
					var closestEdgeNormal;
					var closestEdgeDot = -1.0;
					
					for (var i = 0; i < 3; ++i)
					{
						var edge = new Vector3(
							triangle.vertices[(i + 1) % 3].position.x - triangle.vertices[i + 0].position.x,
							triangle.vertices[(i + 1) % 3].position.y - triangle.vertices[i + 0].position.y,
							triangle.vertices[(i + 1) % 3].position.z - triangle.vertices[i + 0].position.z
							);
							
						var edgeNormal = triangle_normal.cross(edge).normalize();
						var edgeDot = edgeNormal.dot(delta_center);
						
						if (edgeDot > closestEdgeDot)
						{
							closestEdgeDot = edgeDot;
							closestEdgeNormal = edgeNormal;
						}
					}
					
					// Ensure the triangle can face the bbox
					var triangle_plane = Plane3FromNormalOffset(triangle_normal, Vector3FromTranslation(triangle.vertices[0].position));
					var plane_distance = bboxFrom.distanceToPlane(triangle_plane);
					
					//if (triangle_normal.dot(delta_center) > 0.0) // fails past corner
					//if (cloestEdgeDot < triangle_normal.dot(delta_center)) // no
					//if (forward_facing_corner_count == 8 // wait, there's an easier way
					if (plane_distance >= 0.0)
					{
						if (COLLISION4_SHOW_TRIANGLE_BBOX_RESPONSE)
						{
							debugRay3(triangle_center.add(triangle_normal), raycast4_get_hit_normal().multiply(20), 
								(global._raycast4_hitdepth >= 6) ? c_aqua : (
								(global._raycast4_hitdepth >= 4) ? c_lime : (
								(global._raycast4_hitdepth >= 3) ? c_yellow : (
								(global._raycast4_hitdepth >= 2) ? c_orange : (
								(global._raycast4_hitdepth >= 1) ? c_red : c_black))))
								);
						}
					
						l_priorityHits.add([triangle, raycast4_get_hit_distance(), raycast4_get_hit_normal()], abs(raycast4_get_hit_distance()) - triangle_normal.dot(delta_center) /*- global._raycast4_hitdepth*/);
					}
					else
					{
						if (COLLISION4_SHOW_TRIANGLE_BBOX_RESPONSE)
						{
							debugRay3(triangle_center.add(triangle_normal), closestEdgeNormal.multiply(20), c_fuchsia);
						}
						
						l_priorityHits.add([triangle, raycast4_get_hit_distance(), closestEdgeNormal], abs(raycast4_get_hit_distance()) - triangle_normal.dot(delta_center) /*- global._raycast4_hitdepth*/);
					}
					/*else
					{
						debugRay3(triangle_center.add(triangle_normal), triangle_normal, c_white);
					}*/
				}
			}
		}
	}
	
	if (hitMask & kHitmaskDoors)
	{
		var door_count = instance_number(o_livelyDoor);
		for (var doorIndex = 0; doorIndex < door_count; ++doorIndex)
		{
			var door = instance_find(o_livelyDoor, doorIndex);
			
			// Get door BBox
			var doorScale = new Vector3(door.image_xscale, door.image_yscale, door.zscale); // workaround for a workaround
			var doorBBox = new BBox3(new Vector3(door.x, door.y, door.z), doorScale.multiply(16));
			var doorRotation = matrix_build_rotation(door);
			
			// Fix the pivot to the center of the door
			doorBBox.center.addSelf( doorScale.multiply(16).transformAMatrixSelf(doorRotation) );
			
			// TODO: renderables (& props!) should cache their rotation matrices so we dont have to rebuild them each frame
				
			if (bbox3_box_rotated(
				bbox,
				doorBBox,
				doorRotation))
			{
				l_priorityHits.add([door, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
			}
		}
	}
	
	// Pull the priority to a list
	// TODO: someday make this less slow because we hit this all the time
	var l_priorityHitCount = l_priorityHits.size();
	for (var i = 0; i < l_priorityHitCount; ++i)
	{
		var minp = l_priorityHits.getMinimum();
		array_push(outHitObjects, minp[0]);
		array_push(outHitDistances, minp[1]);
		array_push(outHitNormals, minp[2]);
		l_priorityHits.deleteMinimum();
	}
	l_priorityHits.cleanup();
	delete l_priorityHits;
	
	return l_priorityHitCount;
}

function collision4_rectflat3_test(
	rayOrigin, rayDir, rayDistance,
	plane0, plane0_width, plane1, plane1_width,
	outHitObjects, outHitDistances, outHitNormals,
	hitMask=kHitmaskAll, bCollectAllHits=false, ignoreList=[])
{
	var l_priorityHits;
	if (bCollectAllHits)
		l_priorityHits = new APriorityWrapper();
	else
		l_priorityHits = new ASinglePriorityMin();
		
	// set up a test bbox for hell of things
	var test_bbox = new BBox3(rayOrigin.add(rayDir.multiply(rayDistance)), new Vector3(plane0_width, plane1_width, rayDistance));
	var root_bbox = new BBox3(rayOrigin, new Vector3(plane0_width, plane1_width, 0));
	
	// TODO: can probably speed things up with a AABB/Geometry tree
	if (hitMask & kHitmaskProps)
	{
		var propInstance = instance_find(o_props3DIze2, 0);
		var propmap = iexists(propInstance) ? propInstance.m_propmap : undefined;
		if (is_struct(propmap))
		{
			for (var propIndex = 0; propIndex < propmap.GetPropCount(); ++propIndex)
			{
				var prop = propmap.GetProp(propIndex);
			
				// Get the prop BBox & transform it into the world
				var propBBox = PropGetBBox(prop.sprite);
				var propRotation = matrix_build_rotation(prop);
				
				// Currently, BBox is centered around the pivot. We need to transform that center by our rotation first.
				propBBox.center.transformAMatrixSelf(propRotation);
			
				// Add the center to the bbox so we have a place to work from
				propBBox.center.addSelf(Vector3FromTranslation(prop));
				
				if (rectflat3_box_rotated(
					rayOrigin, rayDistance,
					plane0, plane0_width, plane1, plane1_width,
					propBBox,
					propRotation))
				{
					l_priorityHits.add([prop, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
				}
			}
		}
	}
	
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
				
				// Check the stored triangle bbox
				if (!geometryInstance.m_triangleBBoxes[triIndex].overlaps(test_bbox))
					continue;
					
				if (rectflat3_triangle_distance(
					rayOrigin, rayDistance,
					plane0, plane0_width, plane1, plane1_width,
					[triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]))
				{
					// Ensure the triangle can face the bbox
					var triangle_normal = TriangleGetNormal([triangle.vertices[0].position, triangle.vertices[1].position, triangle.vertices[2].position]);
					var triangle_plane = Plane3FromNormalOffset(triangle_normal, Vector3FromTranslation(triangle.vertices[0].position));
					var plane_distance = root_bbox.distanceToPlane(triangle_plane);
					
					if (plane_distance >= 0.0)
					{
						l_priorityHits.add([triangle, raycast4_get_hit_distance(), raycast4_get_hit_normal()], abs(raycast4_get_hit_distance()));
					}
					else
					{
						// TODO
					}
				}
			}
		}
	}
	
	// Pull the priority to a list
	// TODO: someday make this less slow because we hit this all the time
	var l_priorityHitCount = l_priorityHits.size();
	for (var i = 0; i < l_priorityHitCount; ++i)
	{
		var minp = l_priorityHits.getMinimum();
		array_push(outHitObjects, minp[0]);
		array_push(outHitDistances, minp[1]);
		array_push(outHitNormals, minp[2]);
		l_priorityHits.deleteMinimum();
	}
	l_priorityHits.cleanup();
	delete l_priorityHits;
	
	return l_priorityHitCount;
}