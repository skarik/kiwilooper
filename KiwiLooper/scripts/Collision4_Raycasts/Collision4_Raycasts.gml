#macro kHitmaskTilemap		0x01
#macro kHitmaskGeometry		0x02
#macro kHitmaskCorpse		0x04
#macro kHitmaskDoors		0x08
#macro kHitmaskProps		0x10

#macro kHitmaskAll			0xFF

function collision4_raycast(rayOrigin, rayDir, rayDist, outHitObjects, outHitDistances, outHitNormals, hitMask=kHitmaskAll, bCollectAllHits=false, ignoreList=[])
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
				//var propTranslation = matrix_build_translation(prop);
				var propRotation = matrix_build_rotation(prop);
			
				if (raycast4_box_rotated(
					propBBox.center.add(Vector3FromTranslation(prop)),
					propBBox.extents.multiplyComponent(Vector3FromScale(prop)),
					propRotation,
					true,
					rayOrigin, rayDir))
				{
					if (rayDist < 0 || raycast4_get_hit_distance() < rayDist)
					//if (!array_contains_pred(ignoreList, prop, EditorSelectionEqual)) // todo
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
			/*var rayMin = new Vector3(
				min(rayOrigin.x, rayOrigin.x + rayDir.x * rayDist),
				min(rayOrigin.y, rayOrigin.y + rayDir.y * rayDist),
				min(rayOrigin.z, rayOrigin.z + rayDir.z * rayDist));
			var rayMax = new Vector3(
				max(rayOrigin.x, rayOrigin.x + rayDir.x * rayDist),
				max(rayOrigin.y, rayOrigin.y + rayDir.y * rayDist),
				max(rayOrigin.z, rayOrigin.z + rayDir.z * rayDist));*/
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
					//if (!array_contains_pred()
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